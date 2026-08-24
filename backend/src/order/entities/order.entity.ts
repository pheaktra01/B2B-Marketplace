import {
  Column,
  CreateDateColumn,
  Entity,
  OneToMany,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from 'typeorm';

import { OrderItem } from './order-item.entity';

export enum OrderStatus {
  PENDING = 'pending',
  CONFIRMED = 'confirmed',
  PROCESSING = 'processing',
  SHIPPED = 'shipped',
  DELIVERED = 'delivered',
  CANCELLED = 'cancelled',
}

export enum PaymentStatus {
  PENDING = 'pending',
  PAID = 'paid',
  FAILED = 'failed',
  REFUNDED = 'refunded',
}

export enum PaymentMethod {
  KHQR = 'khqr',
}

@Entity('orders')
export class Order {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({
    name: 'restaurant_id',
    type: 'uuid',
  })
  restaurantId: string;

  @Column({
    name: 'farmer_id',
    type: 'uuid',
  })
  farmerId: string;

  @Column({
    type: 'enum',
    enum: OrderStatus,
    default: OrderStatus.PENDING,
  })
  status: OrderStatus;

  @Column({
    name: 'payment_method',
    type: 'enum',
    enum: PaymentMethod,
  })
  paymentMethod: PaymentMethod;

  @Column({
    name: 'payment_status',
    type: 'enum',
    enum: PaymentStatus,
    default: PaymentStatus.PENDING,
  })
  paymentStatus: PaymentStatus;

  @Column({
    name: 'delivery_method',
    type: 'varchar',
    length: 50,
  })
  deliveryMethod: string;

  @Column({
    name: 'delivery_address',
    type: 'text',
  })
  deliveryAddress: string;

  @Column({
    type: 'decimal',
    precision: 12,
    scale: 2,
  })
  subtotal: number;

  @Column({
    name: 'delivery_fee',
    type: 'decimal',
    precision: 12,
    scale: 2,
    default: 0,
  })
  deliveryFee: number;

  @Column({
    name: 'transaction_fee',
    type: 'decimal',
    precision: 12,
    scale: 2,
    default: 0,
  })
  transactionFee: number;

  @Column({
    type: 'decimal',
    precision: 12,
    scale: 2,
  })
  total: number;

  @OneToMany(
    () => OrderItem,
    (orderItem) => orderItem.order,
    {
      cascade: true,
    },
  )
  items: OrderItem[];

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}