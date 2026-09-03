import {
  Controller,
  Get,
  Patch,
  Post,
  Body,
  Req,
  UseInterceptors,
  UploadedFile,
  Param,
  ParseUUIDPipe,
  UseGuards,
} from '@nestjs/common';

import { FileInterceptor } from '@nestjs/platform-express';
import { diskStorage } from 'multer';
import { extname } from 'path';
import { UsersService } from './users.service';
import { UpdateUserDto } from './dto/update-user.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@Controller('users')
export class UsersController {
  constructor(
    private readonly usersService: UsersService,
  ) {}

  @Get('profile')
  @UseGuards(JwtAuthGuard)
  async getProfile(@Req() req: any) {
    return this.usersService.getProfile(
      req.user.id,
    );
  }

  @Get('recommended/farmers')
  @UseGuards(JwtAuthGuard)
  async getRecommendedFarmers() {
    return this.usersService.getRecommendedFarmers();
  }

  @Get(':id')
  @UseGuards(JwtAuthGuard)
  async getUserById(
    @Param('id', ParseUUIDPipe) userId: string,
  ) {
    return this.usersService.getUserById(userId);
  }

  @Patch('profile')
  @UseGuards(JwtAuthGuard)
  async updateProfile(
    @Req() req: any,
    @Body() dto: UpdateUserDto,
  ) {
    return this.usersService.updateProfile(
      req.user.id,
      dto,
    );
  }

  @Post('profile/avatar')
  @UseGuards(JwtAuthGuard)
  @UseInterceptors(
    FileInterceptor('file', {
      storage: diskStorage({
        destination: './uploads/avatar',

        filename: (
          req,
          file,
          callback,
        ) => {
          const uniqueName =
            `${Date.now()}-${Math.round(
              Math.random() * 1e9,
            )}${extname(file.originalname)}`;

          callback(null, uniqueName);
        },
      }),

      fileFilter: (req, file, callback) => {
        console.log('========== UPLOAD ==========');
        console.log('Field:', file.fieldname);
        console.log('Name:', file.originalname);
        console.log('MIME:', file.mimetype);
        console.log('============================');

        if (!file.mimetype.startsWith('image/')) {
          return callback(
            new Error(`Only image files are allowed. Received: ${file.mimetype}`),
            false,
          );
        }

        callback(null, true);
      },

      limits: {
        fileSize: 5 * 1024 * 1024,
      },
    }),
  )
  async uploadAvatar(
    @Req() req: any,
    @UploadedFile() file: Express.Multer.File,
  ) {
    return this.usersService.uploadAvatar(
      req.user.id,
      file,
    );
  }

  @Post('profile/cover')
  @UseGuards(JwtAuthGuard)
  @UseInterceptors(
    FileInterceptor('file', {
      storage: diskStorage({
        destination: './uploads/cover',

        filename: (
          req,
          file,
          callback,
        ) => {
          const uniqueName =
            `${Date.now()}-${Math.round(
              Math.random() * 1e9,
            )}${extname(file.originalname)}`;

          callback(null, uniqueName);
        },
      }),

      fileFilter: (req, file, callback) => {
        console.log('========== UPLOAD ==========');
        console.log('Field:', file.fieldname);
        console.log('Name:', file.originalname);
        console.log('MIME:', file.mimetype);
        console.log('============================');

        if (!file.mimetype.startsWith('image/')) {
          return callback(
            new Error(`Only image files are allowed. Received: ${file.mimetype}`),
            false,
          );
        }

        callback(null, true);
      },

      limits: {
        fileSize: 5 * 1024 * 1024,
      },
    }),
  )
  async uploadCover(
    @Req() req: any,
    @UploadedFile() file: Express.Multer.File,
  ) {
    return this.usersService.uploadCover(
      req.user.id,
      file,
    );
  }
}