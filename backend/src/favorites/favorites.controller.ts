import {
  Controller,
  Get,
  Param,
  Post,
  Req,
  UseGuards,
} from '@nestjs/common';
import { FavoritesService } from './favorites.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@Controller('favorites')
@UseGuards(JwtAuthGuard)
export class FavoritesController {
  constructor(private readonly favoritesService: FavoritesService) {}

  // GET /favorites - Full product details
  @Get()
  async getFavorites(@Req() req: any) {
    return this.favoritesService.getFavoriteProducts(req.user.id);
  }

  // GET /favorites/ids - Array of favorited product IDs
  @Get('ids')
  async getFavoriteIds(@Req() req: any) {
    return this.favoritesService.getFavoriteProductIds(req.user.id);
  }

  // GET /favorites/count - Total count
  @Get('count')
  async getFavoriteCount(@Req() req: any) {
    return this.favoritesService.getFavoriteCount(req.user.id);
  }

  // GET /favorites/:productId/check - Check single product
  @Get(':productId/check')
  async checkFavorite(
    @Req() req: any,
    @Param('productId') productId: string,
  ) {
    return this.favoritesService.isFavorite(req.user.id, productId);
  }

  // POST /favorites/:productId/toggle - Toggle favorite on/off
  @Post(':productId/toggle')
  async toggleFavorite(
    @Req() req: any,
    @Param('productId') productId: string,
  ) {
    return this.favoritesService.toggleFavorite(req.user.id, productId);
  }
}
