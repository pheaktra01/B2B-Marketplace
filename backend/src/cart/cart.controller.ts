import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Patch,
  Post,
  Req,
  UseGuards,
} from '@nestjs/common';

import { CartService } from './cart.service';
import { AddToCartDto } from './dto/add-to-cart.dto';
import { UpdateCartDto } from './dto/update-cart.dto';

import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@Controller('cart')
@UseGuards(JwtAuthGuard)
export class CartController {
  constructor(
    private readonly cartService: CartService,
  ) {}

  // GET /cart
  @Get()
  async getCart(@Req() req: any) {
    return this.cartService.getCart(req.user.id);
  }

  // POST /cart/items
  @Post('items')
  async addToCart(
    @Req() req: any,
    @Body() addToCartDto: AddToCartDto,
  ) {
    return this.cartService.addToCart(
      req.user.id,
      addToCartDto,
    );
  }

  // PATCH /cart/items/:productId
  @Patch('items/:productId')
  async updateCartItem(
    @Req() req: any,
    @Param('productId') productId: string,
    @Body() updateCartDto: UpdateCartDto,
  ) {
    return this.cartService.updateCartItem(
      req.user.id,
      productId,
      updateCartDto,
    );
  }

  // DELETE /cart/items/:productId
  @Delete('items/:productId')
  async removeFromCart(
    @Req() req: any,
    @Param('productId') productId: string,
  ) {
    return this.cartService.removeFromCart(
      req.user.id,
      productId,
    );
  }

  // DELETE /cart
  @Delete()
  async clearCart(@Req() req: any) {
    return this.cartService.clearCart(req.user.id);
  }
}