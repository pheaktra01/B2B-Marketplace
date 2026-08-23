import {
  Body,
  Controller,
  Get,
  Param,
  Post,
  Req,
  UseGuards,
} from '@nestjs/common';

import { OrderService } from './order.service';
import { CheckoutDto } from './dto/checkout.dto';

import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@Controller('orders')
@UseGuards(JwtAuthGuard)
export class OrderController {
  constructor(
    private readonly orderService: OrderService,
  ) {}

  // POST /orders/checkout
  @Post('checkout')
  async checkout(
    @Req() req: any,
    @Body() checkoutDto: CheckoutDto,
  ) {
    return this.orderService.checkout(
      req.user.id,
      checkoutDto,
    );
  }

  // GET /orders
  @Get()
  async getOrders(
    @Req() req: any,
  ) {
    return this.orderService.getRestaurantOrders(
      req.user.id,
    );
  }

  // GET /orders/:id
  @Get(':id')
  async getOrder(
    @Req() req: any,
    @Param('id') orderId: string,
  ) {
    return this.orderService.getOrderById(
      req.user.id,
      orderId,
    );
  }
}