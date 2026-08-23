import 'dotenv/config';
import { ValidationPipe } from '@nestjs/common';
import { NestFactory } from '@nestjs/core';
import { NestExpressApplication } from '@nestjs/platform-express';
import { join } from 'path';
import { AppModule } from './app.module';
import cookieParser from 'cookie-parser';

async function bootstrap() {
  const app =
    await NestFactory.create<NestExpressApplication>(
      AppModule,
    );

  // Cookie parser
  app.use(cookieParser());

  // CORS
  app.enableCors({
    origin: true,
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
    process.env.PORT ?? 3000,
    '0.0.0.0',
  );
}

bootstrap();