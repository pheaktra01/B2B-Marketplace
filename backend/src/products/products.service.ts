import { ForbiddenException, Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Product } from './enterties/product.entity';
import { Repository } from 'typeorm/browser/repository/Repository.js';
import { CreateProductDto } from './dto/create-product.dto';
import { UpdateProductDto } from './dto/update-product.dto';

@Injectable()
export class ProductsService {
    constructor(
        @InjectRepository(Product)
        private readonly productRepo: Repository<Product>,
    ) {}

    async create(
        farmerId: string,
        dto: CreateProductDto,
    ) {
        const product = this.productRepo.create({
            ...dto,
            farmerId,
            harvestDate: dto.harvestDate
                ? new Date(dto.harvestDate)
                : null,
            availableUntil: dto.availableUntil
                ? new Date(dto.availableUntil)
                : null,
            isAvailable: true,
        })

        return this.productRepo.save(product);
    }

    async findAll() {
        return this.productRepo.find({
            order: {
                createdAt: 'DESC',
            }
        });
    }

    async findOne(id: string) {
        const product = await this.productRepo.findOne({
            where: { id },
        })

        if (!product) {
            throw new NotFoundException('Product not found');
        }

        return product;
    }

    async update(
        id: string,
        farmerId: string,
        dto: UpdateProductDto,
    ) {
        const product = await this.productRepo.findOne({
            where: { 
                id,
                farmerId,
            },
        });

        if (!product) {
            throw new NotFoundException('Product not found');
        }

        Object.assign(product, dto);

        if (dto.harvestDate) {
            product.harvestDate = new Date(dto.harvestDate);
        }

        if (dto.availableUntil) {
            product.availableUntil = new Date(dto.availableUntil);
        }

        if (product.farmerId !== farmerId) {
            throw new ForbiddenException('You are not allowed to update this product');
        }

        return this.productRepo.save(product);
    }

    async remove(
        id: string,
        farmerId: string,
    ) {
        const product = await this.productRepo.findOne({
            where: { id },
        })

        if (!product) {
            throw new NotFoundException('Product not found');
        }

        if (product.farmerId !== farmerId) {
            throw new ForbiddenException('You are not allowed to delete this product');
        }

        await this.productRepo.remove(product); 

        return {
            message: 'Product deleted successfully',
        }
    }
    
}
