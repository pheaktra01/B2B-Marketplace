import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  Index,
} from 'typeorm';

export enum NotificationType {
  // Chat
  MESSAGE = 'message',
  CHAT_IMAGE = 'chat_image',
  CHAT_ORDER = 'chat_order',

  // Order - Core
  ORDER_CREATED = 'order_created',
  ORDER_PLACED = 'order_placed',
  ORDER_ACCEPTED = 'order_accepted',
  ORDER_REJECTED = 'order_rejected',
  ORDER_READY = 'order_ready',
  ORDER_COMPLETED = 'order_completed',
  ORDER_CANCELLED = 'order_cancelled',
  ORDER_STATUS_CHANGED = 'order_status_changed',

  // Payment
  PAYMENT_SUCCESS = 'payment_success',
  PAYMENT_FAILED = 'payment_failed',
  PAYMENT_RECEIVED = 'payment_received',
  PAYMENT_COMPLETED = 'payment_completed',

  // Product & Stock
  PRODUCT = 'product',
  PRODUCT_LOW_STOCK = 'product_low_stock',
  PRODUCT_OUT_OF_STOCK = 'product_out_of_stock',
  PRODUCT_PUBLISHED = 'product_published',
  PRODUCT_UPDATED = 'product_updated',
  PRODUCT_AVAILABLE = 'product_available',

  // Account & Security
  ACCOUNT_LOGIN = 'account_login',
  ACCOUNT_PASSWORD_CHANGED = 'account_password_changed',
  ACCOUNT_PHONE_CHANGED = 'account_phone_changed',
  ACCOUNT_PROFILE_UPDATED = 'account_profile_updated',
  ACCOUNT_SECURITY_ALERT = 'account_security_alert',

  // System
  SYSTEM = 'system',
  SYSTEM_ANNOUNCEMENT = 'system_announcement',
  SYSTEM_MAINTENANCE = 'system_maintenance',
  SYSTEM_NEW_FEATURE = 'system_new_feature',
  SYSTEM_POLICY_UPDATE = 'system_policy_update',
  SYSTEM_INTERRUPTION = 'system_interruption',
}

@Entity('notifications')
@Index(['userId', 'createdAt'])
@Index(['userId', 'isRead'])
@Index(['userId', 'referenceId', 'isRead'])
export class Notification {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Index()
  @Column({ name: 'user_id' })
  userId: string;

  @Column({
    type: 'varchar',
    length: 50,
    default: NotificationType.SYSTEM,
  })
  type: NotificationType | string;

  @Column({ type: 'varchar', length: 255 })
  title: string;

  @Column({ type: 'text' })
  message: string;

  @Column({
    name: 'is_read',
    default: false,
  })
  isRead: boolean;

  /**
   * Optional reference to another resource.
   *
   * Examples:
   * conversationId
   * orderId
   * productId
   */
  @Column({
    name: 'reference_id',
    type: 'uuid',
    nullable: true,
  })
  referenceId: string | null;

  @Column({
    name: 'reference_type',
    type: 'varchar',
    length: 50,
    nullable: true,
  })
  referenceType: string | null;

  @CreateDateColumn({
    name: 'created_at',
  })
  createdAt: Date;
}