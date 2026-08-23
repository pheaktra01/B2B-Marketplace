import {
  IsIn,
  IsNotEmpty,
  IsString,
} from 'class-validator';

export class CheckoutDto {
  @IsString()
  @IsNotEmpty()
  deliveryAddress: string;

  @IsString()
  @IsIn(['delivery', 'pickup'])
  deliveryMethod: string;

  @IsString()
  @IsIn(['bakong', 'cash'])
  paymentMethod: string;
}