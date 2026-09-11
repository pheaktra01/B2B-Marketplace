import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';

import { ProductsController } from './products.controller';
import { ProductsService } from './products.service';
import { Product } from './enterties/product.entity';
import { User } from '../users/entities/user.entity';
import { NotificationModule } from '../notification/notification.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([Product, User]),
    NotificationModule,
  ],

  controllers: [
    ProductsController,
  ],

  providers: [
    ProductsService,
  ],

  exports: [
    ProductsService,
  ],
})
export class ProductsModule {}