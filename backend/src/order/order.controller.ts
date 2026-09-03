import {
  Body,
  Controller,
  Get,
  Param,
  Post,
  Patch,
  Req,
  ForbiddenException,
  UseGuards,
} from '@nestjs/common';

import { OrderService } from './order.service';
import { CheckoutDto } from './dto/checkout.dto';
import { UpdateOrderStatusDto } from './dto/update-order-status.dto';
import { OrderStatus } from './entities/order.entity';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@Controller('orders')
@UseGuards(JwtAuthGuard)
export class OrderController {
  constructor(
    private readonly orderService: OrderService,
  ) {}

  // ==========================================
  // POST /orders/checkout
  // ==========================================

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

  // ==========================================
  // GET /orders
  // ==========================================

  @Get()
  async getOrders(
    @Req() req: any,
  ) {
    return this.orderService.getRestaurantOrders(
      req.user.id,
    );
  }

  @Get('farmer')
  async getFarmerOrders(@Req() req: any) {
    if (req.user.role !== 'farmer') {
      throw new ForbiddenException('Only farmers can access farmer orders');
    }
    return this.orderService.getFarmerOrders(req.user.id);
  }

  @Patch(':id/status')
  async updateStatus(
    @Req() req: any,
    @Param('id') orderId: string,
    @Body() dto: UpdateOrderStatusDto,
  ) {
    if (req.user.role !== 'farmer') {
      throw new ForbiddenException('Only farmers can update order status');
    }
    return this.orderService.updateOrderStatus(req.user.id, orderId, dto.status);
  }

  // ==========================================
  // GET /orders/:id
  // ==========================================

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