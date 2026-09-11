import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';

import { OrderController } from './order.controller';
import { OrderService } from './order.service';

import { Order } from './entities/order.entity';
import { OrderItem } from './entities/order-item.entity';

import { Cart } from '../cart/entities/cart.entity';
import { CartItem } from '../cart/entities/cart-item.entity';
import { Product } from 'src/products/enterties/product.entity';
import { Notification } from '../notification/entities/notification.entity';
import { User } from '../users/entities/user.entity';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      Order,
      OrderItem,
      Cart,
      CartItem,
      Product,
      Notification,
      User,
    ]),
  ],

  controllers: [
    OrderController,
  ],

  providers: [
    OrderService,
  ],

  exports: [
    OrderService,
  ],
})
export class OrderModule {}