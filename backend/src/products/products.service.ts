import {
  Injectable,
  NotFoundException,
} from '@nestjs/common';

import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';

import { CreateProductDto } from './dto/create-product.dto';
import { UpdateProductDto } from './dto/update-product.dto';
import { Product } from './enterties/product.entity';

@Injectable()
export class ProductsService {
  constructor(
    @InjectRepository(Product)
    private readonly productRepo: Repository<Product>,
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
    return this.productRepo.find({
      order: {
        createdAt: 'DESC',
      },
    });
  }

  // ============================================================
  // GET MY PRODUCTS
  // ============================================================

  async findMyProducts(
    farmerId: string,
  ) {
    return this.productRepo.find({
      where: {
        farmerId,
      },
      order: {
        createdAt: 'DESC',
      },
    });
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

    return product;
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