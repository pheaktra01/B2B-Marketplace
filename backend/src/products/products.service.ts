import {
  Injectable,
  NotFoundException,
} from '@nestjs/common';

import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';

import { CreateProductDto } from './dto/create-product.dto';
import { UpdateProductDto } from './dto/update-product.dto';
import { Product } from './enterties/product.entity';
import { User } from '../users/entities/user.entity';

@Injectable()
export class ProductsService {
  constructor(
    @InjectRepository(Product)
    private readonly productRepo: Repository<Product>,
    @InjectRepository(User)
    private readonly userRepo: Repository<User>,
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

    return this.productRepo.save(
      product,
    );
  }

  // ============================================================
  // GET ALL
  // ============================================================

  async findAll() {
    const products = await this.productRepo.find({
      order: {
        createdAt: 'DESC',
      },
    });

    return Promise.all(products.map((product) => this.withPublisher(product)));
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

    return Promise.all(products.map((product) => this.withPublisher(product)));
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

    Object.assign(product, dto);

    if (dto.harvestDate) {
      product.harvestDate =
        new Date(dto.harvestDate);
    }

    if (dto.availableUntil) {
      product.availableUntil =
        new Date(dto.availableUntil);
    }

    return this.productRepo.save(product);
  }

  // ============================================================
  // DELETE
  // ============================================================

  async remove(
    id: string,
    farmerId: string,
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

    await this.productRepo.remove(product);

    return {
      message:
        'Product deleted successfully',
    };
  }
}