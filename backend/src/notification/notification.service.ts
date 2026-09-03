import {
  Injectable,
  NotFoundException,
} from '@nestjs/common';

import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';

import {
  Notification,
  NotificationType,
} from './entities/notification.entity';

import { CreateNotificationDto } from './dto/create-notification.dto';
import { EventEmitter2 } from '@nestjs/event-emitter';

@Injectable()
export class NotificationService {
  constructor(
    @InjectRepository(Notification)
    private readonly notificationRepository: Repository<Notification>,
    private readonly eventEmitter: EventEmitter2,
  ) {}

  // =========================================================
  // CREATE NOTIFICATION
  // =========================================================

  async create(
    dto: CreateNotificationDto,
  ): Promise<Notification> {
    const notification =
      this.notificationRepository.create({
        userId: dto.userId,
        type: dto.type,
        title: dto.title,
        message: dto.message,
        referenceId: dto.referenceId ?? null,
        referenceType: dto.referenceType ?? null,
        isRead: false,
      });

    const savedNotification = await this.notificationRepository.save(notification);
    this.eventEmitter.emit('notification.created', savedNotification);
    return savedNotification;
  }

  // =========================================================
  // GET MY NOTIFICATIONS
  // =========================================================

  async getMyNotifications(
    userId: string,
    limit = 30,
    offset = 0,
  ) {
    const safeLimit = Math.min(
      Math.max(limit, 1),
      100,
    );

    const [notifications, total] =
      await this.notificationRepository.findAndCount({
        where: {
          userId,
        },
        order: {
          createdAt: 'DESC',
        },
        take: safeLimit,
        skip: offset,
      });

    return {
      notifications,
      total,
      limit: safeLimit,
      offset,
      hasMore: offset + notifications.length < total,
    };
  }

  // =========================================================
  // GET UNREAD COUNT
  // =========================================================

  async getUnreadCount(userId: string) {
    const count =
      await this.notificationRepository.count({
        where: {
          userId,
          isRead: false,
        },
      });

    return {
      count,
    };
  }

  // =========================================================
  // MARK ONE AS READ
  // =========================================================

  async markAsRead(
    notificationId: string,
    userId: string,
  ) {
    const notification =
      await this.notificationRepository.findOne({
        where: {
          id: notificationId,
          userId,
        },
      });

    if (!notification) {
      throw new NotFoundException(
        'Notification not found',
      );
    }

    notification.isRead = true;

    await this.notificationRepository.save(
      notification,
    );

    return {
      success: true,
    };
  }

  // =========================================================
  // MARK ALL AS READ
  // =========================================================

  async markAllAsRead(userId: string) {
    await this.notificationRepository.update(
      {
        userId,
        isRead: false,
      },
      {
        isRead: true,
      },
    );

    return {
      success: true,
    };
  }

  // =========================================================
  // DELETE NOTIFICATION
  // =========================================================

  async delete(
    notificationId: string,
    userId: string,
  ) {
    const notification =
      await this.notificationRepository.findOne({
        where: {
          id: notificationId,
          userId,
        },
      });

    if (!notification) {
      throw new NotFoundException(
        'Notification not found',
      );
    }

    await this.notificationRepository.delete(
      notificationId,
    );

    return {
      success: true,
    };
  }

  // =========================================================
  // DELETE ALL NOTIFICATIONS
  // =========================================================

  async deleteAll(userId: string) {
    await this.notificationRepository.delete({
      userId,
    });

    return {
      success: true,
    };
  }
}