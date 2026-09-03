import {
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User } from './entities/user.entity';
import { UpdateUserDto } from './dto/update-user.dto';
import * as fs from 'fs';
import * as path from 'path';
import { Order, OrderStatus } from '../order/entities/order.entity';

@Injectable()
export class UsersService {
  constructor(
    @InjectRepository(User)
    private readonly userRepo: Repository<User>,
    @InjectRepository(Order)
    private readonly orderRepo: Repository<Order>,
  ) {}

  async getProfile(userId: string) {
    const user = await this.userRepo.findOne({
      where: { id: userId },
    });

    if (!user) {
      throw new NotFoundException('User not found');
    }

    const { password, refreshToken, ...rest } = user as any;

    return rest as Partial<User>;
  }

  async getUserById(userId: string) {
    const user = await this.userRepo.findOne({
      where: { id: userId },
    });

    if (!user) {
      throw new NotFoundException('User not found');
    }

    const {
      password,
      refreshToken,
      phone,
      otp,
      otpExpiresAt,
      ...publicUser
    } = user as any;

    return publicUser as Partial<User>;
  }

  async getRecommendedFarmers(limit = 5) {
    const rows = await this.orderRepo
      .createQueryBuilder('order')
      .select('order.farmerId', 'farmerId')
      .addSelect('COUNT(order.id)', 'orderCount')
      .where('order.status != :cancelled', {
        cancelled: OrderStatus.CANCELLED,
      })
      .groupBy('order.farmerId')
      .orderBy('COUNT(order.id)', 'DESC')
      .limit(Math.min(Math.max(limit, 1), 20))
      .getRawMany();

    const farmers = await Promise.all(
      rows.map(async (row) => {
        const farmer = await this.userRepo.findOne({
          where: { id: row.farmerId, role: 'farmer' as any },
        });
        if (!farmer) return null;
        return {
          id: farmer.id,
          name: farmer.name,
          avatarUrl: farmer.avatarUrl,
          orderCount: Number(row.orderCount),
        };
      }),
    );

    return farmers.filter(Boolean);
  }

  async updateProfile(
    userId: string,
    dto: UpdateUserDto,
  ) {
    const user = await this.userRepo.findOne({
      where: { id: userId },
    });

    if (!user) {
      throw new NotFoundException('User not found');
    }

    if (dto.name !== undefined) {
      user.name = dto.name;
    }

    if ((dto as any).phone !== undefined) {
      user.phone = (dto as any).phone;
    }

    if ((dto as any).avatarUrl !== undefined) {
      user.avatarUrl = (dto as any).avatarUrl;
    }

    if ((dto as any).coverUrl !== undefined) {
      user.coverUrl = (dto as any).coverUrl;
    }

    await this.userRepo.save(user);

    const { password, refreshToken, ...rest } = user as any;

    return rest as Partial<User>;
  }

  async uploadAvatar(
    userId: string,
    file: Express.Multer.File,
  ) {
    const user = await this.userRepo.findOne({
      where: { id: userId },
    });

    if (!user) {
      throw new NotFoundException('User not found');
    }

    if (!file) {
      throw new Error('Avatar file is required');
    }

    // Delete old avatar
    if (user.avatarUrl) {
      this.deleteFile(user.avatarUrl);
    }

    // URL saved in database
    const avatarUrl = `/uploads/avatar/${file.filename}`;

    user.avatarUrl = avatarUrl;

    await this.userRepo.save(user);

    const { password, refreshToken, ...rest } = user as any;

    return {
      message: 'Avatar uploaded successfully',
      avatarUrl,
      user: rest,
    };
  }

  async uploadCover(
    userId: string,
    file: Express.Multer.File,
  ) {
    const user = await this.userRepo.findOne({
      where: { id: userId },
    });

    if (!user) {
      throw new NotFoundException('User not found');
    }

    if (!file) {
      throw new Error('Cover file is required');
    }

    // Delete old cover
    if (user.coverUrl) {
      this.deleteFile(user.coverUrl);
    }

    // URL saved in database
    const coverUrl = `/uploads/cover/${file.filename}`;

    user.coverUrl = coverUrl;

    await this.userRepo.save(user);

    const { password, refreshToken, ...rest } = user as any;

    return {
      message: 'Cover uploaded successfully',
      coverUrl,
      user: rest,
    };
  }

  private deleteFile(fileUrl: string) {
    try {
      const relativePath = fileUrl.replace(/^\/+/, '');

      const filePath = path.join(
        process.cwd(),
        relativePath,
      );

      if (fs.existsSync(filePath)) {
        fs.unlinkSync(filePath);
      }
    } catch (error) {
      console.error(
        'Failed to delete old file:',
        error,
      );
    }
  }
}