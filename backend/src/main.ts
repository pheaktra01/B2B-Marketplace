import 'dotenv/config';
import { ValidationPipe } from '@nestjs/common';
import { NestFactory } from '@nestjs/core';
import { NestExpressApplication } from '@nestjs/platform-express';
import { join } from 'path';
import * as fs from 'fs';
import { AppModule } from './app.module';
import cookieParser from 'cookie-parser';

async function bootstrap() {
  const app =
    await NestFactory.create<NestExpressApplication>(
      AppModule,
    );

  // Cookie parser
  app.use(cookieParser());

  // CORS configuration (supports env CORS_ORIGIN or allows all origins)
  const corsOrigin = process.env.CORS_ORIGIN;
  app.enableCors({
    origin:
      corsOrigin && corsOrigin !== '*'
        ? corsOrigin.split(',').map((o) => o.trim())
        : true,
    credentials: true,
  });

  // Validation
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      transform: true,
    }),
  );

  // ============================================================
  // SERVE UPLOADED IMAGES
  // ============================================================

  const uploadsPath = join(
    process.cwd(),
    'uploads',
  );

  ['', 'products', 'avatar', 'cover'].forEach((sub) => {
    const dir = join(uploadsPath, sub);
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir, { recursive: true });
    }
  });

  console.log(
    'Uploads directory:',
    uploadsPath,
  );

  app.useStaticAssets(
    uploadsPath,
    {
      prefix: '/uploads/',
    },
  );

  await app.listen(
    process.env.PORT ?? 3001,
    '0.0.0.0',
  );
}

bootstrap();