import { Module } from '@nestjs/common';
import { AuthController } from './auth.controller';
import { AuthService } from './auth.service';
import { User } from 'src/users/entities/user.entity';
import { TypeOrmModule } from '@nestjs/typeorm';
import { JwtModule } from '@nestjs/jwt';
import { UsersModule } from 'src/users/users.module';
import { JwtStrategy } from './strategies/jwt.strategy';

@Module({
  imports: [
    TypeOrmModule.forFeature([User]),

    UsersModule,

    JwtModule.register({
      secret: process.env.JWT_SECRET || 'secret',
      signOptions: {
        expiresIn: '7d',
      },
    }),
  ],

  controllers: [AuthController],

  providers: [
    AuthService,
    JwtStrategy,
  ],

  exports: [
    JwtModule,
    JwtStrategy,
  ],
})
export class AuthModule {}