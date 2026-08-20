import { Body, Controller, HttpCode, HttpStatus, Post, Res } from '@nestjs/common';
import type { Response } from 'express';
import { AuthService } from './auth.service';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';
import { ForgotPasswordDto } from './dto/forgot-password.dto';
import { ResetPasswordDto } from './dto/reset-password-dto.dto';

@Controller('auth')
export class AuthController {
    constructor(
        private readonly authService: AuthService,
    ) {}

    @Post('register')
    register(@Body() dto: RegisterDto) {
        return this.authService.register(dto);
    }

    @Post('verify-otp')
    verifyOtp(@Body() dto: { userId: string; otp: string }) {
        return this.authService.verifyOTP(dto);
    }

    @Post('login')
    async login(
        @Body() dto: LoginDto,
        @Res({ passthrough: true }) response: Response,
    ) {
        const result = await this.authService.login(dto);

        response.cookie('accessToken', result.accessToken, {
            httpOnly: true,
            secure: process.env.NODE_ENV === 'production',
            sameSite: 'lax',
            maxAge: 7 * 24 * 60 * 60 * 1000,
        });

        console.log('LOGIN SUCCESS');
        console.log('User ID:', result.user.id);
        console.log('User:', result.user.name);
        console.log('Role:', result.user.role);
        console.log('Access token generated:', !!result.accessToken);

        return {
            message: 'Login successful',
            accessToken: result.accessToken,
            user: result.user,
        };
    }

    @Post('logout')
    @HttpCode(HttpStatus.OK)
    logout(@Res({ passthrough: true }) response: Response) {
        console.log('=================================');
        console.log('USER LOGOUT REQUEST RECEIVED');
        console.log('Time:', new Date().toISOString());
        console.log('=================================');

        response.clearCookie('accessToken', {
            httpOnly: true,
            secure: process.env.NODE_ENV === 'production',
            sameSite: 'lax',
        });

        console.log('Access token cookie cleared');
        console.log('Logout successful');

        return {
            message: 'Logout successful',
        };
    }

    @Post('forgot-password')
    forgotPassword(@Body() dto: ForgotPasswordDto) {
        return this.authService.forgotPassword(dto);
    }

    @Post('reset-password')
    resetPassword(@Body() dto: ResetPasswordDto) {
        return this.authService.resetPassword(dto);
    }
}