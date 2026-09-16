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

import { User } from '../users/entities/user.entity';
import { CreateNotificationDto } from './dto/create-notification.dto';
import { EventEmitter2, OnEvent } from '@nestjs/event-emitter';

@Injectable()
export class NotificationService {
  constructor(
    @InjectRepository(Notification)
    private readonly notificationRepository: Repository<Notification>,
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
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

  async emitUnreadCount(userId: string): Promise<void> {
    try {
      const { count } = await this.getUnreadCount(userId);
      this.eventEmitter.emit('notification.count_updated', {
        userId,
        unreadCount: count,
      });
    } catch {
      // Ignored
    }
  }

  @OnEvent('notification.created')
  async handleNotificationCreatedEvent(notification: Record<string, unknown>) {
    const userId = notification?.userId?.toString();
    if (userId) {
      await this.emitUnreadCount(userId);
    }
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

    this.eventEmitter.emit('notification.read', {
      notificationId,
      userId,
    });

    await this.emitUnreadCount(userId);

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

    this.eventEmitter.emit('notification.read_all', {
      userId,
    });

    this.eventEmitter.emit('notification.count_updated', {
      userId,
      unreadCount: 0,
    });

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

    this.eventEmitter.emit('notification.deleted', {
      notificationId,
      userId,
    });

    await this.emitUnreadCount(userId);

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

    this.eventEmitter.emit('notification.deleted_all', {
      userId,
    });

    this.eventEmitter.emit('notification.count_updated', {
      userId,
      unreadCount: 0,
    });

    return {
      success: true,
    };
  }

  // =========================================================
  // CREATE OR GROUP MESSAGE NOTIFICATION
  // =========================================================

  async createOrGroupMessageNotification(params: {
    userId: string;
    conversationId: string;
    senderName: string;
    messageType?: string;
    orderId?: string;
  }): Promise<Notification> {
    const { userId, conversationId, senderName, messageType, orderId } = params;

    // Check if there is an unread chat notification for this conversation in the last 10 minutes
    const tenMinutesAgo = new Date(Date.now() - 10 * 60 * 1000);
    const existing = await this.notificationRepository
      .createQueryBuilder('n')
      .where('n.user_id = :userId', { userId })
      .andWhere('n.reference_id = :conversationId', { conversationId })
      .andWhere('n.is_read = :isRead', { isRead: false })
      .andWhere('n.created_at >= :since', { since: tenMinutesAgo })
      .orderBy('n.created_at', 'DESC')
      .getOne();

    if (existing) {
      existing.title = senderName;
      existing.message = `You have multiple unread messages from ${senderName}.`;
      existing.type = NotificationType.MESSAGE;
      const updated = await this.notificationRepository.save(existing);
      this.eventEmitter.emit('notification.created', updated);
      return updated;
    }

    let type: NotificationType = NotificationType.MESSAGE;
    let title = senderName;
    let message = `${senderName} sent you a message.`;

    if (messageType === 'image') {
      type = NotificationType.CHAT_IMAGE;
      title = senderName;
      message = `${senderName} sent you a photo.`;
    } else if (orderId || messageType === 'order') {
      type = NotificationType.CHAT_ORDER;
      title = senderName;
      message = orderId
        ? `New message about order #${orderId.slice(0, 8)}.`
        : 'New message about your order.';
    }

    return this.create({
      userId,
      type,
      title,
      message,
      referenceId: conversationId,
      referenceType: 'conversation',
    });
  }

  // =========================================================
  // BROADCAST SYSTEM NOTIFICATION
  // =========================================================

  async broadcastSystemNotification(dto: {
    type?: NotificationType;
    title: string;
    message: string;
    targetRole?: string;
  }) {
    const type = dto.type ?? NotificationType.SYSTEM_ANNOUNCEMENT;

    let usersQuery = this.userRepository.createQueryBuilder('user');
    if (dto.targetRole) {
      usersQuery = usersQuery.where('user.role = :role', {
        role: dto.targetRole,
      });
    }
    const users = await usersQuery.getMany();

    const createdNotifications: Notification[] = [];
    for (const user of users) {
      const notification = this.notificationRepository.create({
        userId: user.id,
        type,
        title: dto.title,
        message: dto.message,
        referenceId: null,
        referenceType: 'system',
        isRead: false,
      });
      createdNotifications.push(notification);
    }

    if (createdNotifications.length > 0) {
      await this.notificationRepository.save(createdNotifications);
      for (const n of createdNotifications) {
        this.eventEmitter.emit('notification.created', n);
      }
    }

    return {
      success: true,
      recipientsCount: createdNotifications.length,
    };
  }
}