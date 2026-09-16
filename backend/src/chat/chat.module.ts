import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';

import { ChatController } from './chat.controller';
import { ChatService } from './chat.service';

import { Conversation } from './entities/conversation.entity';
import { ConversationParticipant } from './entities/conversation-participant.entity';
import { Message } from './entities/message.entity';
import { User } from '../users/entities/user.entity';
import { NotificationModule } from 'src/notification/notification.module';
import { AuthModule } from 'src/auth/auth.module';
import { ChatGateway } from './chat.gateway';
import { OnlinePresenceService } from './online-presence.service';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      Conversation,
      ConversationParticipant,
      Message,
      User,
    ]),

    NotificationModule,
    AuthModule,
  ],

  controllers: [
    ChatController,
  ],

  providers: [
    ChatService,
    ChatGateway,
    OnlinePresenceService,
  ],

  exports: [
    ChatService,
    OnlinePresenceService,
  ],
})
export class ChatModule {}