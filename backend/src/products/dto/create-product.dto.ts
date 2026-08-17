import { IsNumber, IsOptional, IsString, Min } from "class-validator";

export class CreateProductDto {
    @IsString()
    name: string;

    @IsOptional()
    @IsString()
    description?: string;

    @IsNumber()
    @Min(0)
    price: number;

    @IsString()
    category: string;

    @IsString()
    unit: string;

    @IsNumber()
    @Min(0)
    quantity: number;

    @IsOptional()
    @IsString()
    imageUrl?: string;
}