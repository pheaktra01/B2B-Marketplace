import {
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { In, Repository } from 'typeorm';
import { User, UserRole } from './entities/user.entity';
import { UpdateUserDto } from './dto/update-user.dto';
import * as fs from 'fs';
import * as path from 'path';
import { Order, OrderStatus } from '../order/entities/order.entity';
import { NotificationService } from '../notification/notification.service';
import { NotificationType } from '../notification/entities/notification.entity';

@Injectable()
export class UsersService {
  constructor(
    @InjectRepository(User)
    private readonly userRepo: Repository<User>,
    @InjectRepository(Order)
    private readonly orderRepo: Repository<Order>,
    private readonly notificationService: NotificationService,
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

    if (!rows.length) {
      return [];
    }

    const farmerIds = rows.map((row) => row.farmerId).filter(Boolean);
    if (!farmerIds.length) {
      return [];
    }

    const farmers = await this.userRepo.find({
      where: {
        id: In(farmerIds),
        role: UserRole.FARMER,
      },
      select: {
        id: true,
        name: true,
        avatarUrl: true,
        coverUrl: true,
        businessName: true,
        address: true,
        bio: true,
        phone: true,
      },
    });

    const farmerMap = new Map(farmers.map((farmer) => [farmer.id, farmer]));

    return rows
      .map((row) => {
        const farmer = farmerMap.get(row.farmerId);
        if (!farmer) return null;
        return {
          id: farmer.id,
          name: farmer.name,
          avatarUrl: farmer.avatarUrl,
          coverUrl: farmer.coverUrl,
          businessName: farmer.businessName,
          address: farmer.address,
          bio: farmer.bio,
          phone: farmer.phone,
          orderCount: Number(row.orderCount),
        };
      })
      .filter(Boolean);
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

    const phoneChanged =
      (dto as any).phone !== undefined && (dto as any).phone !== user.phone;

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

    if (dto.businessName !== undefined) {
      user.businessName = dto.businessName;
    }

    if (dto.address !== undefined) {
      user.address = dto.address;
    }

    if (dto.bio !== undefined) {
      user.bio = dto.bio;
    }

    await this.userRepo.save(user);

    const notificationPayload = phoneChanged
      ? {
          userId: user.id,
          type: NotificationType.ACCOUNT_PHONE_CHANGED,
          title: 'Phone Number Changed',
          message: 'Your account phone number was updated successfully.',
          referenceId: null,
          referenceType: 'account',
        }
      : {
          userId: user.id,
          type: NotificationType.ACCOUNT_PROFILE_UPDATED,
          title: 'Profile Updated',
          message: 'Your profile details have been updated successfully.',
          referenceId: null,
          referenceType: 'account',
        };

    this.notificationService.create(notificationPayload).catch((e) => {
      console.error('Failed to notify profile update:', e);
    });

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

  private async deleteFile(fileUrl: string) {
    try {
      const relativePath = fileUrl.replace(/^\/+/, '');

      const filePath = path.join(
        process.cwd(),
        relativePath,
      );

      await fs.promises.unlink(filePath).catch(() => {});
    } catch (error) {
      console.error(
        'Failed to delete old file:',
        error,
      );
    }
  }
}