import { BadRequestException, Injectable, NotFoundException, UnauthorizedException } from '@nestjs/common';
import { User } from 'src/users/entities/user.entity';
import { Repository } from 'typeorm';
import { RegisterDto } from './dto/register.dto';
import { InjectRepository } from '@nestjs/typeorm';
import * as bcrypt from 'bcrypt';
import { JwtService } from '@nestjs/jwt';
import { VerifyOtpDto } from './dto/verify-otp.dto';
import { ResetPasswordDto } from './dto/reset-password-dto.dto';
import { LoginDto } from './dto/login.dto';
import { ForgotPasswordDto } from './dto/forgot-password.dto';

import { NotificationService } from '../notification/notification.service';
import { NotificationType } from '../notification/entities/notification.entity';

@Injectable()
export class AuthService {
    private getStaticOtp(): string {
        return process.env.STATIC_OTP ?? '123456';
    }

    constructor(
        @InjectRepository(User)
        private readonly userRepo: Repository<User>,
        private readonly jwtService: JwtService,
        private readonly notificationService: NotificationService,
    ) {}

    // ==========================================================
    // REGISTER
    // ==========================================================

    async register(dto: RegisterDto) {
        const exist = await this.userRepo.findOne({
            where: { phone: dto.phone },
        });

        if (exist) {
            // If phone exists and is already verified, block reuse
            if (exist.isVerified) {
                throw new BadRequestException('Phone number already registered');
            }

            // If phone exists but not verified, refresh OTP and update credentials
            const hash = await bcrypt.hash(dto.password, 10);
            exist.name = dto.name;
            exist.password = hash;
            exist.role = dto.role;
            exist.otp = this.getStaticOtp();

            await this.userRepo.save(exist);

            return {
                message: 'OTP sent successfully',
                userId: exist.id,
                otp: process.env.NODE_ENV === 'production' ? undefined : (exist.otp ?? this.getStaticOtp()),
            };
        }

        const hash = await bcrypt.hash(dto.password, 10);

        const user = this.userRepo.create({
            name: dto.name,
            phone: dto.phone,
            password: hash,
            role: dto.role,
            otp: this.getStaticOtp(),
        });

        await this.userRepo.save(user);

        return {
            message: 'OTP sent successfully',
            userId: user.id,
            otp: process.env.NODE_ENV === 'production' ? undefined : (user.otp ?? this.getStaticOtp()),
        };
    }

    // ==========================================================
    // VERIFY OTP
    // ==========================================================

    async verifyOTP(dto: VerifyOtpDto) {
        const user = await this.userRepo.findOne({
            where: {
                id: dto.userId,
            },
        });

        if (!user) {
            throw new NotFoundException('User not found');
        }

        const staticOtp = this.getStaticOtp();
        if (user.otp !== dto.otp && dto.otp !== staticOtp) {
            throw new BadRequestException('Invalid OTP');
        }

        user.isVerified = true;
        user.otp = null;

        await this.userRepo.save(user);

        return {
            message: 'User verified successfully',
        };
    }

    // ==========================================================
    // LOGIN (FAST & NON-BLOCKING NOTIFICATION)
    // ==========================================================

    async login(dto: LoginDto) {
        const user = await this.userRepo.findOne({
            where: {
                phone: dto.phone,
            },
        });

        if (!user) {
            throw new UnauthorizedException('User not found');
        }

        const match = await bcrypt.compare(
            dto.password,
            user.password,
        );

        if (!match) {
            throw new UnauthorizedException('Wrong password');
        }

        const accessToken = this.jwtService.sign({
            id: user.id,
            name: user.name,
            role: user.role,
        });

        // Fire notification in background without blocking response latency
        this.notificationService.create({
            userId: user.id,
            type: NotificationType.ACCOUNT_LOGIN,
            title: 'Login from New Device',
            message: 'New login detected on your account.',
            referenceId: null,
            referenceType: 'account',
        }).catch((e) => {
            // Non-critical background notification error
        });

        return {
            accessToken,
            user: {
                id: user.id,
                name: user.name,
                role: user.role,
            },
        };
    }

    // ==========================================================
    // FORGOT PASSWORD
    // ==========================================================

    async forgotPassword(dto: ForgotPasswordDto) {
        const user = await this.userRepo.findOne({
            where: { phone: dto.phone },
        });

        if (!user) {
            throw new NotFoundException('User not found');
        }

        const otp = this.getStaticOtp();
        user.otp = otp;

        await this.userRepo.save(user);

        return {
            message: 'OTP sent successfully',
            userId: user.id,
            otp: process.env.NODE_ENV === 'production' ? undefined : user.otp,
        };
    }

    // ==========================================================
    // RESET PASSWORD
    // ==========================================================

    async resetPassword(dto: ResetPasswordDto) {
        const user = await this.userRepo.findOne({
            where: { phone: dto.phone },
        });

        if (!user) {
            throw new NotFoundException('User not found');
        }

        const staticOtp = this.getStaticOtp();

        // Allow verification with stored OTP or static fallback
        if (user.otp !== dto.otp && dto.otp !== staticOtp) {
            throw new BadRequestException('Invalid OTP');
        }

        user.password = await bcrypt.hash(dto.password, 10);
        user.otp = null;

        await this.userRepo.save(user);

        // Fire notification in background without blocking response latency
        this.notificationService.create({
            userId: user.id,
            type: NotificationType.ACCOUNT_PASSWORD_CHANGED,
            title: 'Password Changed',
            message: 'Your account password was changed successfully.',
            referenceId: null,
            referenceType: 'account',
        }).catch((e) => {
            // Non-critical background notification error
        });

        return {
            message: 'Password reset successful',
        };
    }
}
