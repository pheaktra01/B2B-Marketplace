import { Type } from 'class-transformer';
import {
  IsBoolean,
  IsNumber,
  IsOptional,
  IsString,
  Min,
} from 'class-validator';

export class QueryProductDto {
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  @Min(1)
  page?: number;

  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  @Min(1)
  limit?: number;

  @IsOptional()
  @IsString()
  search?: string;

  @IsOptional()
  @IsString()
  category?: string;

  @IsOptional()
  @IsString()
  condition?: string;

  @IsOptional()
  @IsString()
  location?: string;

  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  @Min(0)
  maxMoq?: number;

  @IsOptional()
  @Type(() => Boolean)
  @IsBoolean()
  inStockOnly?: boolean;

  @IsOptional()
  @IsString()
  sortBy?: string; // relevance, newest, price_low, price_high, moq_low

  @IsOptional()
  @IsString()
  farmerId?: string;
}
