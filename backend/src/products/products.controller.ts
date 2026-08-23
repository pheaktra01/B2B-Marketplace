import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Patch,
  Post,
  Req,
  UseGuards,
} from '@nestjs/common';

import { ProductsService } from './products.service';
import { CreateProductDto } from './dto/create-product.dto';
import { UpdateProductDto } from './dto/update-product.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@Controller('products')
export class ProductsController {
  constructor(
    private readonly productsService: ProductsService,
  ) {}

  // ============================================================
  // GET ALL PRODUCTS
  // ============================================================

  @Get()
  async findAll() {
    return this.productsService.findAll();
  }

  // ============================================================
  // GET MY PRODUCTS
  // ============================================================

  @Get('my')
  @UseGuards(JwtAuthGuard)
  async findMyProducts(
    @Req() req: any,
  ) {
    return this.productsService.findMyProducts(
      req.user.id,
    );
  }

  // ============================================================
  // GET ONE PRODUCT
  // ============================================================

  @Get(':id')
  async findOne(
    @Param('id') id: string,
  ) {
    return this.productsService.findOne(id);
  }

  // ============================================================
  // CREATE PRODUCT
  // ============================================================

  @Post()
  @UseGuards(JwtAuthGuard)
  async create(
    @Req() req: any,
    @Body() dto: CreateProductDto,
  ) {
    console.log(
      '=================================',
    );

    console.log('CREATE PRODUCT');

    console.log(
      'Farmer ID:',
      req.user.id,
    );

    console.log(
      'Farmer Name:',
      req.user.name,
    );

    console.log(
      'Farmer Role:',
      req.user.role,
    );

    console.log(
      'Product:',
      dto.name,
    );

    console.log(
      'Images:',
      dto.imageUrls?.length ?? 0,
    );

    console.log(
      'Image URLs:',
      dto.imageUrls ?? [],
    );

    console.log(
      '=================================',
    );

    return this.productsService.create(
      req.user.id,
      dto,
    );
  }

  // ============================================================
  // UPDATE PRODUCT
  // ============================================================

  @Patch(':id')
  @UseGuards(JwtAuthGuard)
  async update(
    @Param('id') id: string,
    @Req() req: any,
    @Body() dto: UpdateProductDto,
  ) {
    return this.productsService.update(
      id,
      req.user.id,
      dto,
    );
  }

  // ============================================================
  // DELETE PRODUCT
  // ============================================================

  @Delete(':id')
  @UseGuards(JwtAuthGuard)
  async remove(
    @Param('id') id: string,
    @Req() req: any,
  ) {
    return this.productsService.remove(
      id,
      req.user.id,
    );
  }
}