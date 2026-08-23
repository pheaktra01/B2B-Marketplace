import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Patch,
  Post,
  Req,
  UploadedFiles,
  UseGuards,
  UseInterceptors,
} from '@nestjs/common';

import {
  FilesInterceptor,
} from '@nestjs/platform-express';

import {
  diskStorage,
} from 'multer';

import {
  extname,
  join,
} from 'path';

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
  @UseInterceptors(
    FilesInterceptor('images', 5, {
      storage: diskStorage({
        destination: join(
          process.cwd(),
          'uploads',
          'products',
        ),

        filename: (
          req,
          file,
          callback,
        ) => {
          const uniqueName =
            `${Date.now()}-${Math.round(Math.random() * 1e9)}${extname(file.originalname)}`;

          callback(
            null,
            uniqueName,
          );
        },
      }),

      limits: {
        fileSize: 5 * 1024 * 1024,
      },

      fileFilter: (
        req,
        file,
        callback,
      ) => {
        if (
          !file.mimetype.startsWith(
            'image/',
          )
        ) {
          return callback(
            new Error(
              'Only image files are allowed',
            ),
            false,
          );
        }

        callback(null, true);
      },
    }),
  )
  async create(
    @Req() req: any,
    @UploadedFiles() files: Express.Multer.File[],
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
      files?.length ?? 0,
    );

    console.log(
      '=================================',
    );

    const imageUrls =
      (files ?? []).map(
        (file) =>
          `/uploads/products/${file.filename}`,
      );

    return this.productsService.create(
      req.user.id,
      dto,
      imageUrls,
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