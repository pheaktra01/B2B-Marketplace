import { Injectable, UnauthorizedException } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor() {
    super({
      jwtFromRequest: ExtractJwt.fromExtractors([
        // 1. Read token from Authorization: Bearer <token>
        ExtractJwt.fromAuthHeaderAsBearerToken(),

        // 2. Also support cookie
        (req: any) => {
          return req?.cookies?.accessToken;
        },
      ]),

      ignoreExpiration: false,

      secretOrKey: process.env.JWT_SECRET || 'secret',
    });
  }

  async validate(payload: any) {
    console.log('========== JWT VALIDATED ==========');
    console.log('User ID:', payload?.id);
    console.log('Name:', payload?.name);
    console.log('Role:', payload?.role);
    console.log('===================================');

    if (!payload?.id) {
      throw new UnauthorizedException('Invalid token');
    }

    return {
      id: payload.id,
      name: payload.name,
      role: payload.role,
    };
  }
}