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
import { response } from 'express';

@Injectable()
export class AuthService {
    private getStaticOtp(): string {
        return process.env.STATIC_OTP ?? '123456';
    }
    constructor(
    @InjectRepository(User)
    private readonly userRepo: Repository<User>,

    private readonly jwtService: JwtService,
    ) {}

    async register(dto: RegisterDto){
        const exist = await this.userRepo.findOne({where:{phone:dto.phone}});

        if(exist) {
            // If phone exists and is already verified, block reuse
            if (exist.isVerified) {
                throw new BadRequestException('Phone number already registered');
            }

            // If phone exists but not verified, refresh OTP and update password/name/role
            const hash = await bcrypt.hash(dto.password, 10);
            exist.name = dto.name;
            exist.password = hash;
            exist.role = dto.role;
            exist.otp = this.getStaticOtp();

            await this.userRepo.save(exist);

            console.log('REGISTER: refreshed unverified user id=', exist.id, 'otp=', exist.otp);

            return {
                message: 'OTP send',
                userId: exist.id,
                otp: process.env.NODE_ENV === 'production' ? undefined : exist.otp,
            }
        }

        const hash = await bcrypt.hash(dto.password, 10);

        const user = this.userRepo.create({
            name: dto.name,
            phone: dto.phone,
            password: hash,
            role: dto.role,
            otp: this.getStaticOtp(),
        })

        await this.userRepo.save(user);

        console.log('REGISTER: saved user id=', user.id, 'otp=', user.otp);

        return {
            message: 'OTP send',
            userId: user.id,
            otp: process.env.NODE_ENV === 'production' ? undefined : user.otp,
        }        
    }

    async verifyOTP(dto: VerifyOtpDto) {
        console.log('VERIFY OTP: incoming dto=', dto);

        const user = await this.userRepo.findOne({
            where: {
                id: dto.userId,
            },
        });

        if (!user) {
            throw new NotFoundException('User not found');
        }
        console.log('VERIFY OTP: found user id=', user.id, 'storedOtp=', user.otp);

        if (user.otp !== dto.otp) {
            throw new BadRequestException('Invalid OTP');
        }

        user.isVerified = true;
        user.otp = null;

        await this.userRepo.save(user);

        return {
            message: 'User verified successfully',
        };
    }

    async login(dto: LoginDto) {
        const user = await this.userRepo.findOne({
            where: {
                phone: dto.phone,
            },
        });

        console.log('PHONE FROM REQUEST:', dto.phone);
        console.log('USER FOUND:', user);

        if (!user) {
            throw new UnauthorizedException('User not found');
        }

        const match = await bcrypt.compare(
            dto.password,
            user.password,
        );

        console.log('PASSWORD MATCH:', match);

        if (!match) {
            throw new UnauthorizedException('Wrong password');
        }

        const accessToken = this.jwtService.sign({
            id: user.id,
            name: user.name,
            role: user.role,
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

    async forgotPassword(dto: ForgotPasswordDto) {
        const user = await this.userRepo.findOne({where:{phone:dto.phone}});
        
        if(!user) {
            throw new NotFoundException('User not found');
        }
        
        const otp = this.getStaticOtp();

        user.otp = otp;

        await this.userRepo.save(user);

        // TODO: send OTP to via SMS

        return {
            message: 'OTP send successfully',
            userId: user.id,
            otp: process.env.NODE_ENV === 'production' ? undefined : user.otp,
        }
    }

    async resetPassword(dto: ResetPasswordDto) {
        const user = await this.userRepo.findOne({
            where: { phone: dto.phone },
        });

        if (!user) {
            throw new NotFoundException('User not found');
        }

            const staticOtp = this.getStaticOtp();

            // Allow verification with the stored OTP or the static OTP fallback (e.g. 123456)
            if (user.otp !== dto.otp && dto.otp !== staticOtp) {
                throw new BadRequestException('Invalid OTP');
            }

        user.password = await bcrypt.hash(dto.password, 10);
        user.otp = null;

        await this.userRepo.save(user);

        return {
            message: 'Password reset successful',
        };
    }

}
