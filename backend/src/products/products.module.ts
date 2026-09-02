import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';

import { ProductsController } from './products.controller';
import { ProductsService } from './products.service';
import { Product } from './enterties/product.entity';
import { User } from '../users/entities/user.entity';

@Module({
  imports: [
    TypeOrmModule.forFeature([Product, User]),
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