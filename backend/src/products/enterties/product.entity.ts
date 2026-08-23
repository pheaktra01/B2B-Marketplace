import {
  Column,
  CreateDateColumn,
  Entity,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from 'typeorm';

@Entity('products')
export class Product {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'varchar' })
  name: string;

  @Column({ type: 'text', nullable: true })
  description: string | null;

  @Column({ type: 'varchar' })
  category: string;

  @Column({ type: 'varchar', default: 'Fresh' })
  condition: string;

  @Column({
    type: 'decimal',
    precision: 10,
    scale: 2,
  })
  price: number;

  @Column({
    type: 'decimal',
    precision: 10,
    scale: 2,
  })
  quantity: number;

  @Column({
    type: 'decimal',
    precision: 10,
    scale: 2,
  })
  minOrder: number;

  // ============================================================
  // MULTIPLE PRODUCT IMAGE PATHS
  // ============================================================

  @Column('text', {
    array: true,
    default: '{}',
  })
  imageUrls: string[];

  @Column({ type: 'date', nullable: true })
  harvestDate: Date | null;

  @Column({ type: 'date', nullable: true })
  availableUntil: Date | null;

  @Column({ type: 'varchar' })
  location: string;

  @Column({ type: 'varchar' })
  deliveryMethod: string;

  @Column({
    type: 'decimal',
    precision: 10,
    scale: 2,
    default: 0,
  })
  deliveryFee: number;

  @Column({ type: 'uuid' })
  farmerId: string;

  @Column({ type: 'boolean', default: true })
  isAvailable: boolean;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}