import {
	Body,
	Controller,
	Get,
	Post,
	Put,
	Query,
	UploadedFile,
	UseInterceptors,
} from '@nestjs/common';
import { UsersService } from './users.service';
import { UpdateUserDto } from './dto/update-user.dto';
import { FileInterceptor } from '@nestjs/platform-express';
import { diskStorage } from 'multer';
import { extname } from 'path';

@Controller('users')
export class UsersController {
	constructor(private readonly usersService: UsersService) {}

	@Get('profile')
	async getProfile(@Query('userId') userId: string) {
		return this.usersService.getProfile(userId);
	}

	@Put('profile')
	async updateProfile(@Query('userId') userId: string, @Body() dto: UpdateUserDto) {
		return this.usersService.updateProfile(userId, dto);
	}

	@Post('upload-avatar')
	@UseInterceptors(
		FileInterceptor('file', {
			storage: diskStorage({
				destination: './uploads',
				filename: (req, file, cb) => {
					const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1e9);
					const fileExt = extname(file.originalname);
					cb(null, `${uniqueSuffix}${fileExt}`);
				},
			}),
		}),
	)
	async uploadAvatar(@UploadedFile() file: Express.Multer.File) {
		// return URL path to serve the uploaded image
		return { url: `/uploads/${file.filename}` };
	}
}
