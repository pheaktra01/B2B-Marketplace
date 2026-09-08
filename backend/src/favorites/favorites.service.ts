import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Favorite } from './entities/favorite.entity';
import { Product } from '../products/enterties/product.entity';
import { User } from '../users/entities/user.entity';

@Injectable()
export class FavoritesService {
  constructor(
    @InjectRepository(Favorite)
    private readonly favoriteRepo: Repository<Favorite>,
    @InjectRepository(Product)
    private readonly productRepo: Repository<Product>,
    @InjectRepository(User)
    private readonly userRepo: Repository<User>,
  ) {}

  async getFavoriteProducts(userId: string) {
    const favorites = await this.favoriteRepo.find({
      where: { userId },
      relations: { product: true },
      order: { createdAt: 'DESC' },
    });

    const products = favorites
      .map((f) => f.product)
      .filter((p): p is Product => p !== null && p !== undefined);

    return Promise.all(products.map((product) => this.withPublisher(product)));
  }

  async getFavoriteProductIds(userId: string): Promise<string[]> {
    const favorites = await this.favoriteRepo.find({
      where: { userId },
      select: { productId: true },
      order: { createdAt: 'DESC' },
    });
    return favorites.map((f) => f.productId);
  }

  async getFavoriteCount(userId: string): Promise<{ count: number }> {
    const count = await this.favoriteRepo.count({
      where: { userId },
    });
    return { count };
  }

  async isFavorite(userId: string, productId: string): Promise<{ isFavorite: boolean }> {
    const existing = await this.favoriteRepo.findOne({
      where: { userId, productId },
    });
    return { isFavorite: !!existing };
  }

  async toggleFavorite(
    userId: string,
    productId: string,
  ): Promise<{ isFavorite: boolean; message: string }> {
    const product = await this.productRepo.findOne({
      where: { id: productId },
    });

    if (!product) {
      throw new NotFoundException('Product not found');
    }

    const existing = await this.favoriteRepo.findOne({
      where: { userId, productId },
    });

    if (existing) {
      await this.favoriteRepo.delete(existing.id);
      return { isFavorite: false, message: 'Removed from favorites' };
    } else {
      const favorite = this.favoriteRepo.create({
        userId,
        productId,
      });
      await this.favoriteRepo.save(favorite);
      return { isFavorite: true, message: 'Added to favorites' };
    }
  }

  private async withPublisher(product: Product) {
    const publisher = await this.userRepo.findOne({
      where: { id: product.farmerId },
      select: {
        id: true,
        name: true,
        avatarUrl: true,
        phone: true,
        role: true,
      },
    });

    return {
      ...product,
      farmer: publisher,
      farmerName: publisher?.name ?? 'Local Farm',
      farmName: publisher?.name ?? 'Local Farm',
    };
  }
}
