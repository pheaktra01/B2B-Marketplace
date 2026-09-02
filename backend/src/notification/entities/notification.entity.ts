import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  Index,
} from 'typeorm';

export enum NotificationType {
  MESSAGE = 'message',

  ORDER_CREATED = 'order_created',
  ORDER_ACCEPTED = 'order_accepted',
  ORDER_REJECTED = 'order_rejected',
  ORDER_CANCELLED = 'order_cancelled',
  ORDER_STATUS_CHANGED = 'order_status_changed',

  PAYMENT_RECEIVED = 'payment_received',

  PRODUCT = 'product',

  SYSTEM = 'system',
}

@Entity('notifications')
export class Notification {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Index()
  @Column({ name: 'user_id' })
  userId: string;

  @Column({
    type: 'enum',
    enum: NotificationType,
  })
  type: NotificationType;

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