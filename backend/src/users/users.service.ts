import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User } from './entities/user.entity';
import { UpdateUserDto } from './dto/update-user.dto';

@Injectable()
export class UsersService {
	constructor(
		@InjectRepository(User)
		private readonly userRepo: Repository<User>,
	) {}

	async getProfile(userId: string) {
		const user = await this.userRepo.findOne({ where: { id: userId } });
		if (!user) throw new NotFoundException('User not found');
		// hide sensitive fields
		// eslint-disable-next-line @typescript-eslint/no-unused-vars
		const { password, refreshToken, ...rest } = user as any;
		return rest as Partial<User>;
	}

	async updateProfile(userId: string, dto: UpdateUserDto) {
		const user = await this.userRepo.findOne({ where: { id: userId } });
		if (!user) throw new NotFoundException('User not found');

		if (dto.name !== undefined) user.name = dto.name;
		if ((dto as any).phone !== undefined) user.phone = (dto as any).phone;
		if ((dto as any).avatarUrl !== undefined) user.avatarUrl = (dto as any).avatarUrl;
		if ((dto as any).coverUrl !== undefined) user.coverUrl = (dto as any).coverUrl;

		await this.userRepo.save(user);

		// hide sensitive fields
		// eslint-disable-next-line @typescript-eslint/no-unused-vars
		const { password, refreshToken, ...rest } = user as any;
		return rest as Partial<User>;
	}
}
