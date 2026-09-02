import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { AuthModule } from './auth/auth.module';
import { UsersModule } from './users/users.module';
import { TypeOrmModule } from '@nestjs/typeorm';
import { User } from './users/entities/user.entity';
import { ProductsModule } from './products/products.module';
import { CartModule } from './cart/cart.module';
import { OrderModule } from './order/order.module';
import { ChatModule } from './chat/chat.module';
import { NotificationModule } from './notification/notification.module';
// Debug env values for DB connection troubleshooting (masked)
try {
  const pwd = process.env.DB_PASSWORD;
  console.log('DB ENV:', {
    host: process.env.DB_HOST,
    port: process.env.DB_PORT,
    username: process.env.DB_USERNAME,
    passwordType: typeof pwd,
    passwordLength: pwd ? pwd.length : 0,
    database: process.env.DB_DATABASE,
  });
} catch (e) {
  console.log('Error reading DB env:', e);
}

@Module({
  imports: [
    TypeOrmModule.forRoot({
      type:'postgres',
      host:process.env.DB_HOST,
      port:Number(process.env.DB_PORT),
      username:process.env.DB_USERNAME,
      password:process.env.DB_PASSWORD,
      database:process.env.DB_DATABASE,

      autoLoadEntities: true,
      synchronize: true,
    }),
    AuthModule,
    UsersModule,
    ProductsModule,
    CartModule,
    OrderModule, 
    ChatModule,
    NotificationModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
