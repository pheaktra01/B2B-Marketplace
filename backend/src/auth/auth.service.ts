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

@Injectable()
export class AuthService {
    constructor(
    @InjectRepository(User)
    private readonly userRepo: Repository<User>,

    private readonly jwtService: JwtService,
    ) {}

    async register(dto: RegisterDto){
        const exist = await this.userRepo.findOne({where:{phone:dto.phone}});

        if(exist) {
            throw new BadRequestException('Phone number already registered');
        }

        const hash = await bcrypt.hash(dto.password, 10);

        const user = this.userRepo.create({
            name: dto.name,
            phone: dto.phone,
            password: hash,
            role: dto.role,
            otp: "123456",
        })

        await this.userRepo.save(user);

        return {
            message: 'OTP send',
            userId: user.id,
        }        
    }

    async verifyOTP(dto: VerifyOtpDto) {
        const user = await this.userRepo.findOne({
            where: {
                id: dto.userId,
            },
        });

        if (!user) {
            throw new NotFoundException('User not found');
        }

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
                phone: dto.phone
            }
        });

        console.log("PHONE FROM REQUEST:", dto.phone);
        console.log("USER FOUND:", user);

        if (!user) {
            throw new UnauthorizedException('User not found');
        }

        const match = await bcrypt.compare(
            dto.password,
            user.password
        );

        console.log("PASSWORD MATCH:", match);

        if (!match) {
            throw new UnauthorizedException('Wrong password');
        }

        const token = this.jwtService.sign({
            id: user.id,
            name: user.name,
            role: user.role
        });

        return {
            accessToken: token,
            user: {
                id: user.id,
                name: user.name,
                role: user.role
            }
        };
    }

    async forgotPassword(dto: ForgotPasswordDto) {
        const user = await this.userRepo.findOne({where:{phone:dto.phone}});
        
        if(!user) {
            throw new NotFoundException('User not found');
        }
        
        const otp = "123456";

        user.otp = otp;

        await this.userRepo.save(user);

        // TODO: send OTP to via SMS

        return {
            message: 'OTP send successfully',
        }
    }

    async resetPassword(dto: ResetPasswordDto) {
    const user = await this.userRepo.findOne({
        where: { phone: dto.phone },
    });

    if (!user) {
        throw new NotFoundException('User not found');
    }

    if (user.otp !== dto.otp) {
        throw new BadRequestException('Invalid OTP');
    }

    user.password = await bcrypt.hash(dto.password, 10);
    user.otp = '';

    await this.userRepo.save(user);

    return {
        message: 'Password reset successful',
    };
    }

}
