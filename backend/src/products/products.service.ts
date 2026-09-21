import {
  Injectable,
  NotFoundException,
} from '@nestjs/common';

import { InjectRepository } from '@nestjs/typeorm';
import { In, Repository } from 'typeorm';

import { CreateProductDto } from './dto/create-product.dto';
import { QueryProductDto } from './dto/query-product.dto';
import { UpdateProductDto } from './dto/update-product.dto';
import { Product } from './enterties/product.entity';
import { User } from '../users/entities/user.entity';
import { NotificationService } from '../notification/notification.service';
import { NotificationType } from '../notification/entities/notification.entity';

@Injectable()
export class ProductsService {
  constructor(
    @InjectRepository(Product)
    private readonly productRepo: Repository<Product>,
    @InjectRepository(User)
    private readonly userRepo: Repository<User>,
    private readonly notificationService: NotificationService,
  ) {}

  // ============================================================
  // CREATE
  // ============================================================

  async create(
    farmerId: string,
    dto: CreateProductDto,
    imageUrls: string[],
  ) {
    const product =
      this.productRepo.create({
        name: dto.name,

        description:
          dto.description ?? null,

        category: dto.category,

        condition:
          dto.condition,

        price: dto.price,

        quantity:
          dto.quantity,

        minOrder:
          dto.minOrder,

        imageUrls,

        harvestDate:
          dto.harvestDate
            ? new Date(dto.harvestDate)
            : null,

        availableUntil:
          dto.availableUntil
            ? new Date(dto.availableUntil)
            : null,

        location:
          dto.location,

        deliveryMethod:
          dto.deliveryMethod,

        deliveryFee:
          dto.deliveryFee,

        farmerId,

        isAvailable: true,
      });

    const saved = await this.productRepo.save(
      product,
    );

    // Fire notification asynchronously in the background
    this.notificationService.create({
      userId: farmerId,
      type: NotificationType.PRODUCT_PUBLISHED,
      title: 'Product Published',
      message: `Your ${saved.name} product is now available.`,
      referenceId: saved.id,
      referenceType: 'product',
    }).catch((e) => {
      // Non-critical background notification error
    });

    return saved;
  }

  // ============================================================
  // GET ALL (LEGACY LIST)
  // ============================================================

  async findAll() {
    const products = await this.productRepo.find({
      order: {
        createdAt: 'DESC',
      },
    });

    return this.withPublishers(products);
  }

  // ============================================================
  // GET ALL PAGINATED & FILTERED
  // ============================================================

  async findAllPaginated(query: QueryProductDto) {
    const page = Math.max(1, query.page ?? 1);
    const limit = Math.max(1, Math.min(100, query.limit ?? 10));
    const skip = (page - 1) * limit;

    const qb = this.productRepo.createQueryBuilder('product');

    // 1. Search Query (name, description, category, location)
    if (query.search && query.search.trim().length > 0) {
      const search = `%${query.search.trim()}%`;
      qb.andWhere(
        '(product.name ILIKE :search OR product.description ILIKE :search OR product.category ILIKE :search OR product.location ILIKE :search)',
        { search },
      );
    }

    // 2. Category Filter
    if (query.category && query.category.toLowerCase() !== 'all') {
      qb.andWhere('product.category ILIKE :category', {
        category: query.category.trim(),
      });
    }

    // 3. Condition / Quality Filter
    if (query.condition && query.condition.toLowerCase() !== 'all') {
      const cond = query.condition.toLowerCase();
      if (cond.includes('organic') || cond.includes('gap')) {
        qb.andWhere(
          '(product.condition ILIKE :cond OR product.name ILIKE :cond OR product.description ILIKE :cond)',
          { cond: '%organic%' },
        );
      } else if (cond.includes('fresh')) {
        qb.andWhere('product.condition ILIKE :cond', {
          cond: '%fresh%',
        });
      } else {
        qb.andWhere('product.condition ILIKE :condition', {
          condition: query.condition.trim(),
        });
      }
    }

    // 4. Location Filter
    if (query.location && query.location.toLowerCase() !== 'all') {
      qb.andWhere('product.location ILIKE :location', {
        location: `%${query.location.trim()}%`,
      });
    }

    // 5. In Stock Only
    if (query.inStockOnly === true || `${query.inStockOnly}` === 'true') {
      qb.andWhere('product.isAvailable = true AND product.quantity > 0');
    }

    // 6. Max MOQ Filter
    if (query.maxMoq != null && query.maxMoq > 0) {
      qb.andWhere('product.minOrder <= :maxMoq', { maxMoq: query.maxMoq });
    }

    // 7. Specific Farmer Filter
    if (query.farmerId) {
      qb.andWhere('product.farmerId = :farmerId', {
        farmerId: query.farmerId,
      });
    }

    // 8. Sorting
    switch (query.sortBy) {
      case 'price_low':
        qb.orderBy('product.price', 'ASC');
        break;
      case 'price_high':
        qb.orderBy('product.price', 'DESC');
        break;
      case 'moq_low':
        qb.orderBy('product.minOrder', 'ASC');
        break;
      case 'newest':
        qb.orderBy('product.createdAt', 'DESC');
        break;
      case 'relevance':
      default:
        qb.orderBy('product.createdAt', 'DESC');
        break;
    }

    const [items, total] = await qb
      .skip(skip)
      .take(limit)
      .getManyAndCount();

    const data = await this.withPublishers(items);
    const totalPages = Math.ceil(total / limit);
    const hasMore = page < totalPages;

    return {
      data,
      total,
      page,
      limit,
      totalPages,
      hasMore,
    };
  }

  // ============================================================
  // GET MY PRODUCTS
  // ============================================================

  async findMyProducts(
    farmerId: string,
  ) {
    const products = await this.productRepo.find({
      where: {
        farmerId,
      },
      order: {
        createdAt: 'DESC',
      },
    });

    return this.withPublishers(products);
  }

  // ============================================================
  // GET ONE
  // ============================================================

  async findOne(id: string) {
    const product =
      await this.productRepo.findOne({
        where: {
          id,
        },
      });

    if (!product) {
      throw new NotFoundException(
        'Product not found',
      );
    }

    return this.withPublisher(product);
  }

  private async withPublishers(products: Product[]) {
    if (products.length === 0) return [];

    const farmerIds = Array.from(
      new Set(products.map((p) => p.farmerId).filter(Boolean)),
    );

    const publishers =
      farmerIds.length > 0
        ? await this.userRepo.find({
            where: { id: In(farmerIds) },
            select: {
              id: true,
              name: true,
              role: true,
              avatarUrl: true,
            },
          })
        : [];

    const publisherMap = new Map(publishers.map((u) => [u.id, u]));

    return products.map((product) => {
      const publisher = publisherMap.get(product.farmerId);
      return {
        ...product,
        publisher: publisher
          ? {
              id: publisher.id,
              name: publisher.name,
              role: publisher.role,
              avatarUrl: publisher.avatarUrl,
            }
          : null,
      };
    });
  }

  private async withPublisher(product: Product) {
    const publisher = await this.userRepo.findOne({
      where: { id: product.farmerId },
      select: {
        id: true,
        name: true,
        role: true,
        avatarUrl: true,
      },
    });

    return {
      ...product,
      publisher: publisher
        ? {
            id: publisher.id,
            name: publisher.name,
            role: publisher.role,
            avatarUrl: publisher.avatarUrl,
          }
        : null,
    };
  }

  // ============================================================
  // UPDATE
  // ============================================================

  async update(
    id: string,
    farmerId: string,
    dto: UpdateProductDto,
    files?: Express.Multer.File[],
  ) {
    const product =
      await this.productRepo.findOne({
        where: {
          id,
          farmerId,
        },
      });

    if (!product) {
      throw new NotFoundException(
        'Product not found',
      );
    }

    const { existingImages, ...fieldsToUpdate } = dto as any;
    Object.assign(product, fieldsToUpdate);

    if (dto.harvestDate) {
      product.harvestDate =
        new Date(dto.harvestDate);
    }

    if (dto.availableUntil) {
      product.availableUntil =
        new Date(dto.availableUntil);
    }

    // Handle image updates
    if ((files && files.length > 0) || existingImages !== undefined) {
      let preservedImages: string[] = [];
      if (existingImages) {
        if (Array.isArray(existingImages)) {
          preservedImages = existingImages.map((img) => img.toString());
        } else if (typeof existingImages === 'string') {
          try {
            const parsed = JSON.parse(existingImages);
            if (Array.isArray(parsed)) {
              preservedImages = parsed.map((img) => img.toString());
            } else if (parsed) {
              preservedImages = [parsed.toString()];
            }
          } catch {
            preservedImages = [existingImages];
          }
        }
      }

      const newUploadedUrls = (files ?? []).map(
        (file) => `/uploads/products/${file.filename}`,
      );

      product.imageUrls = [...preservedImages, ...newUploadedUrls];
    }

    const saved = await this.productRepo.save(product);

    // Fire notifications asynchronously in the background
    this.notificationService.create({
      userId: farmerId,
      type: NotificationType.PRODUCT_UPDATED,
      title: 'Product Updated',
      message: `Your product information for ${saved.name} has been updated.`,
      referenceId: saved.id,
      referenceType: 'product',
    }).catch(() => {});

    if (Number(saved.quantity) <= 0) {
      this.notificationService.create({
        userId: farmerId,
        type: NotificationType.PRODUCT_OUT_OF_STOCK,
        title: 'Out of Stock',
        message: `${saved.name} is now out of stock.`,
        referenceId: saved.id,
        referenceType: 'product',
      }).catch(() => {});
    } else if (Number(saved.quantity) <= 5) {
      this.notificationService.create({
        userId: farmerId,
        type: NotificationType.PRODUCT_LOW_STOCK,
        title: 'Low Stock',
        message: `Your ${saved.name} stock is running low (${saved.quantity} left).`,
        referenceId: saved.id,
        referenceType: 'product',
      }).catch(() => {});
    }

    return saved;
  }

  // ============================================================
  // DELETE (ATOMIC DIRECT DELETE)
  // ============================================================

  async remove(
    id: string,
    farmerId: string,
  ) {
    const result = await this.productRepo.delete({
      id,
      farmerId,
    });

    if (result.affected === 0) {
      throw new NotFoundException(
        'Product not found',
      );
    }

    return {
      message:
        'Product deleted successfully',
    };
  }
}