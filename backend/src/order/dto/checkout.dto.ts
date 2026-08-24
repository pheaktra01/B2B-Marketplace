import {
  IsIn,
  IsOptional,
  IsString,
} from 'class-validator';

import { PaymentMethod } from '../entities/order.entity';

export class CheckoutDto {
  @IsOptional()
  @IsString()
  deliveryAddress?: string;

  @IsString()
  @IsIn(['delivery', 'pickup'])
  deliveryMethod: string;

  @IsString()
  @IsIn([PaymentMethod.KHQR])
  paymentMethod: PaymentMethod;
}