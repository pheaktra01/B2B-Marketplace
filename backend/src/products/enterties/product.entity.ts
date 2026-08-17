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

  @Column({ type: 'text', nullable: true})
  description: string | null;

  @Column()
  category: string;

  @Column({ type: 'decimal', precision: 10, scale: 2 })
  price: number;

  @Column()
  unit: string;

  @Column({ type: 'decimal', precision: 10, scale: 2 })
  quantity: number;

  @Column({ type: 'varchar', nullable: true })
  imageUrl: string | null;

  @Column({ default: true })
  isAvailable: boolean;

  @Column()
  farmerId: string;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}