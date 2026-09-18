import {
  BadRequestException,
  Body,
  Controller,
  Delete,
  Get,
  Param,
  ParseIntPipe,
  Post,
  Patch,
  Query,
  Req,
  DefaultValuePipe,
  UploadedFile,
  UseGuards,
  UseInterceptors,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { diskStorage } from 'multer';
import { extname } from 'path';

import { ChatService } from './chat.service';
import { CreateConversationDto } from './dto/create-conversation.dto';
import { SendMessageDto } from './dto/send-message.dto';
import { MarkReadDto } from './dto/mark-read.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@Controller('chat')
@UseGuards(JwtAuthGuard)
export class ChatController {
  constructor(
    private readonly chatService: ChatService,
  ) {}

  // =========================================================
  // ATTACHMENT UPLOAD
  // =========================================================

  @Post('upload')
  @UseInterceptors(
    FileInterceptor('file', {
      storage: diskStorage({
        destination: './uploads/chat',
        filename: (req, file, callback) => {
          const uniqueName = `${Date.now()}-${Math.round(
            Math.random() * 1e9,
          )}${extname(file.originalname)}`;
          callback(null, uniqueName);
        },
      }),
      fileFilter: (req, file, callback) => {
        if (!file.mimetype.startsWith('image/')) {
          return callback(
            new BadRequestException(
              `Only image files are allowed. Received: ${file.mimetype}`,
            ),
            false,
          );
        }
        callback(null, true);
      },
      limits: {
        fileSize: 10 * 1024 * 1024, // 10MB
      },
    }),
  )
  uploadAttachment(@UploadedFile() file: Express.Multer.File) {
    if (!file) {
      throw new BadRequestException('File is required');
    }
    const relativePath = `/uploads/chat/${file.filename}`;
    return {
      url: relativePath,
      filename: file.filename,
      originalname: file.originalname,
      mimetype: file.mimetype,
      size: file.size,
    };
  }

  // =========================================================
  // CONVERSATIONS
  // =========================================================

  @Post('conversations')
  async createConversation(
    @Req() req: any,
    @Body() dto: CreateConversationDto,
  ) {
    return this.chatService.createOrGetConversation(
      req.user.id,
      dto,
    );
  }

  @Get('conversations')
  async getMyConversations(@Req() req: any) {
    return this.chatService.getMyConversations(
      req.user.id,
    );
  }

  @Get('conversations/:conversationId')
  async getConversation(
    @Req() req: any,
    @Param('conversationId') conversationId: string,
  ) {
    return this.chatService.getConversationById(
      conversationId,
      req.user.id,
    );
  }

  // =========================================================
  // MESSAGES
  // =========================================================

  @Get('conversations/:conversationId/messages')
  async getMessages(
    @Req() req: any,
    @Param('conversationId') conversationId: string,

    @Query(
      'limit',
      new DefaultValuePipe(30),
      ParseIntPipe,
    )
    limit: number,

    @Query('before') before?: string,
  ) {
    return this.chatService.getMessages(
      conversationId,
      req.user.id,
      limit,
      before,
    );
  }

  @Post('conversations/:conversationId/messages')
  async sendMessage(
    @Req() req: any,
    @Param('conversationId') conversationId: string,
    @Body() dto: SendMessageDto,
  ) {
    return this.chatService.sendMessage(
      conversationId,
      req.user.id,
      dto,
    );
  }

  // =========================================================
  // READ
  // =========================================================

  @Patch('conversations/:conversationId/read')
  async markAsRead(
    @Req() req: any,
    @Param('conversationId') conversationId: string,
    @Body() dto: MarkReadDto,
  ) {
    return this.chatService.markAsRead(
      conversationId,
      req.user.id,
      dto,
    );
  }

  // =========================================================
  // DELETE
  // =========================================================

  @Delete('conversations/:conversationId')
  async deleteConversation(
    @Req() req: any,
    @Param('conversationId') conversationId: string,
  ) {
    return this.chatService.deleteConversation(
      conversationId,
      req.user.id,
    );
  }

  @Delete('messages/:messageId')
  async deleteMessage(
    @Req() req: any,
    @Param('messageId') messageId: string,
  ) {
    return this.chatService.deleteMessage(
      messageId,
      req.user.id,
    );
  }

  @Delete('conversations/:conversationId/messages/:messageId')
  async deleteConversationMessage(
    @Req() req: any,
    @Param('messageId') messageId: string,
  ) {
    return this.chatService.deleteMessage(
      messageId,
      req.user.id,
    );
  }
}