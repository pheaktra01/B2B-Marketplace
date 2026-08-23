import { IsNumber, IsUUID, Min } from 'class-validator';

export class AddToCartDto {
  @IsUUID()
  productId: string;

  @IsNumber()
  @Min(0.01)
  quantity: number;
}