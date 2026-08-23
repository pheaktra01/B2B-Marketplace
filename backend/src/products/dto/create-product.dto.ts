import { Type } from 'class-transformer';

import {
  IsDateString,
  IsNumber,
  IsOptional,
  IsString,
  Min,
} from 'class-validator';

export class CreateProductDto {
  @IsString()
  name: string;

  @IsOptional()
  @IsString()
  description?: string;

  @IsString()
  category: string;

  @IsString()
  condition: string;

  @Type(() => Number)
  @IsNumber()
  @Min(0)
  price: number;

  @Type(() => Number)
  @IsNumber()
  @Min(0)
  quantity: number;

  @Type(() => Number)
  @IsNumber()
  @Min(0)
  minOrder: number;

  @IsOptional()
  @IsDateString()
  harvestDate?: string;

  @IsOptional()
  @IsDateString()
  availableUntil?: string;

  @IsString()
  location: string;

  @IsString()
  deliveryMethod: string;

  @Type(() => Number)
  @IsNumber()
  @Min(0)
  deliveryFee: number;
}