import { CreateProductDto } from "./create-product.dto";
import { PartialType } from '@nestjs/mapped-types';
import { IsBoolean, IsOptional } from 'class-validator';
import { Transform } from 'class-transformer';

export class UpdateProductDto extends PartialType(CreateProductDto) {
  @IsOptional()
  existingImages?: any;

  @IsOptional()
  @Transform(({ value }) => {
    if (value === 'true' || value === true || value === 1 || value === '1') return true;
    if (value === 'false' || value === false || value === 0 || value === '0') return false;
    return value;
  })
  @IsBoolean()
  isAvailable?: boolean;
}