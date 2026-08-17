import { Controller, Post, UseGuards, Req, Body, Get, Param, ParseUUIDPipe, Patch, Delete } from '@nestjs/common';
import { ProductsService } from './products.service';
import { JwtAuthGuard } from 'src/auth/guards/jwt-auth.guard';
import { CreateProductDto } from './dto/create-product.dto';
import { UpdateProductDto } from './dto/update-product.dto';

@Controller('products')
export class ProductsController {
    constructor(
        private readonly productsService: ProductsService
    ) {}

    @Post()
    @UseGuards(JwtAuthGuard)
    async create(
        @Req() req: any,
        @Body() dto: CreateProductDto,
    ) {
        return this.productsService.create(
            req.user.id,
            dto,
        );
    }

    @Get()
    async findAll() {
        return this.productsService.findAll();
    }

    @Get(':id')
    async findOne(
        @Param('id', ParseUUIDPipe) id: string,
    ) {
        return this.productsService.findOne(id);
    }

    @Patch(':id')
    @UseGuards(JwtAuthGuard)
    async update(
        @Param('id', ParseUUIDPipe) id: string,
        @Req() req: any,
        @Body() dto: UpdateProductDto,
    ) {
        return this.productsService.update(
            id,
            req.user.id,
            dto,
        );
    }

    @Delete(':id')
    @UseGuards(JwtAuthGuard)
    async remove(
        @Param('id', ParseUUIDPipe) id: string,
        @Req() req: any,
    ) {
        return this.productsService.remove(
            id,
            req.user.id,
        );
    }
}
