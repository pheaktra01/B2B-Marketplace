import { IsEnum, IsString, MinLength } from 'class-validator';
import {UserRole} from '../../users/entities/user.entity';

export class RegisterDto {
    @IsString()
    name!: string;

    @IsString()
    phone!: string;

    @MinLength(8)
    password!: string;

    @IsEnum(UserRole)
    role!: UserRole;

}