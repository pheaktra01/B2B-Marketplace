import {
  Column,
  Entity,
  JoinColumn,
  ManyToOne,
  PrimaryGeneratedColumn,
} from 'typeorm';

import { Order } from './order.entity';

@Entity('order_items')
export class OrderItem {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({
    name: 'order_id',
    type: 'uuid',
  })
  orderId: string;

  @ManyToOne(
    () => Order,
    (order) => order.items,
    {
      onDelete: 'CASCADE',
    },
  )
  @JoinColumn({
    name: 'order_id',
  })
  order: Order;

  @Column({
    name: 'product_id',
    type: 'uuid',
  })
  productId: string;

  @Column({
    name: 'product_name',
    type: 'varchar',
    length: 255,
  })
  productName: string;

  @Column({
    type: 'decimal',
    precision: 12,
    scale: 2,
  })
  quantity: number;

  @Column({
    name: 'unit_price',
    type: 'decimal',
    precision: 12,
    scale: 2,
  })
  unitPrice: number;

  @Column({
    type: 'decimal',
    precision: 12,
    scale: 2,
  })
  subtotal: number;
}