import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { In, Repository } from 'typeorm';
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

  // ==========================================================
  // GET FAVORITE PRODUCTS (OPTIMIZED: ELIMINATES N+1 QUERIES)
  // ==========================================================

  async getFavoriteProducts(userId: string) {
    const favorites = await this.favoriteRepo.find({
      where: { userId },
      relations: { product: true },
      order: { createdAt: 'DESC' },
    });

    const products = favorites
      .map((f) => f.product)
      .filter((p): p is Product => p !== null && p !== undefined);

    if (products.length === 0) {
      return [];
    }

    // Extract all unique farmer IDs to batch query in a single round-trip
    const uniqueFarmerIds = Array.from(
      new Set(products.map((p) => p.farmerId).filter(Boolean)),
    );

    const farmers =
      uniqueFarmerIds.length > 0
        ? await this.userRepo.find({
            where: { id: In(uniqueFarmerIds) },
            select: {
              id: true,
              name: true,
              avatarUrl: true,
              phone: true,
              role: true,
            },
          })
        : [];

    const farmerMap = new Map(farmers.map((farmer) => [farmer.id, farmer]));

    return products.map((product) => {
      const publisher = farmerMap.get(product.farmerId);
      return {
        ...product,
        farmer: publisher ?? null,
        farmerName: publisher?.name ?? 'Local Farm',
        farmName: publisher?.name ?? 'Local Farm',
      };
    });
  }

  // ==========================================================
  // GET FAVORITE PRODUCT IDS
  // ==========================================================

  async getFavoriteProductIds(userId: string): Promise<string[]> {
    const favorites = await this.favoriteRepo.find({
      where: { userId },
      select: { productId: true },
      order: { createdAt: 'DESC' },
    });
    return favorites.map((f) => f.productId);
  }

  // ==========================================================
  // GET FAVORITE COUNT
  // ==========================================================

  async getFavoriteCount(userId: string): Promise<{ count: number }> {
    const count = await this.favoriteRepo.count({
      where: { userId },
    });
    return { count };
  }

  // ==========================================================
  // IS FAVORITE (LIGHTWEIGHT EXISTS QUERY)
  // ==========================================================

  async isFavorite(userId: string, productId: string): Promise<{ isFavorite: boolean }> {
    const isFav = await this.favoriteRepo.exists({
      where: { userId, productId },
    });
    return { isFavorite: isFav };
  }

  // ==========================================================
  // TOGGLE FAVORITE (OPTIMIZED: PARALLEL LOOKUP & MINIMAL COLUMNS)
  // ==========================================================

  async toggleFavorite(
    userId: string,
    productId: string,
  ): Promise<{ isFavorite: boolean; message: string }> {
    // Concurrently verify product and check existing favorite status
    const [product, existing] = await Promise.all([
      this.productRepo.findOne({
        where: { id: productId },
        select: { id: true },
      }),
      this.favoriteRepo.findOne({
        where: { userId, productId },
        select: { id: true },
      }),
    ]);

    if (!product) {
      throw new NotFoundException('Product not found');
    }

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
}
