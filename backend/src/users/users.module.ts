import { Module } from '@nestjs/common';
import { UsersController } from './users.controller';
import { UsersService } from './users.service';
import { User } from './entities/user.entity';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Order } from '../order/entities/order.entity';

@Module({
  imports: [
    TypeOrmModule.forFeature([User, Order]),
  ],
  exports: [
    TypeOrmModule,
  ],
  controllers: [UsersController],
  providers: [UsersService]
})
export class UsersModule {}
