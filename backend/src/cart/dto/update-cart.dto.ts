import { IsNumber, Min } from 'class-validator';

export class UpdateCartDto {
  @IsNumber()
  @Min(0.01)
  quantity: number;
}