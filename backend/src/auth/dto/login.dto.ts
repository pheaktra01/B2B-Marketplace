import { IsNotEmpty, IsString, Matches, MinLength } from 'class-validator';

export class LoginDto {
  @IsString()
  @IsNotEmpty()
  @Matches(/^(0|\+855)\d{8,9}$/, {
    message: 'Invalid phone number format',
  })
  phone!: string;

  @IsString()
  @IsNotEmpty()
  @MinLength(6)
  password!: string;
}