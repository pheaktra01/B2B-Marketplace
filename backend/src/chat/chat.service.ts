import {
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';

import { Conversation } from './entities/conversation.entity';
import { ConversationParticipant } from './entities/conversation-participant.entity';
import {
  Message,
  MessageStatus,
  MessageType,
} from './entities/message.entity';

import { CreateConversationDto } from './dto/create-conversation.dto';
import { SendMessageDto } from './dto/send-message.dto';
import { MarkReadDto } from './dto/mark-read.dto';
import { User } from '../users/entities/user.entity';
import { NotificationService } from 'src/notification/notification.service';
import { NotificationType } from 'src/notification/entities/notification.entity';
import { EventEmitter2 } from '@nestjs/event-emitter';
import * as fs from 'fs';
import { join } from 'path';
import { OnlinePresenceService } from './online-presence.service';

@Injectable()
export class ChatService {
  constructor(
    @InjectRepository(Conversation)
    private readonly conversationRepository: Repository<Conversation>,

    @InjectRepository(ConversationParticipant)
    private readonly participantRepository: Repository<ConversationParticipant>,

    @InjectRepository(Message)
    private readonly messageRepository: Repository<Message>,

    @InjectRepository(User)
    private readonly userRepository: Repository<User>,

    private readonly notificationService: NotificationService,
    private readonly eventEmitter: EventEmitter2,
    private readonly onlinePresenceService: OnlinePresenceService,
  ) {}

  // =========================================================
  // CREATE / GET CONVERSATION
  // =========================================================

  async createOrGetConversation(
    currentUserId: string,
    dto: CreateConversationDto,
  ) {
    if (currentUserId === dto.participantId) {
      throw new ForbiddenException(
        'You cannot create a conversation with yourself',
      );
    }

    // Check whether a conversation already exists
    const existingConversation = await this.findExistingConversation(
      currentUserId,
      dto.participantId,
    );

    if (existingConversation) {
      return this.getConversationById(
        existingConversation.id,
        currentUserId,
      );
    }

    // Create conversation
    const conversation = this.conversationRepository.create();

    const savedConversation =
      await this.conversationRepository.save(conversation);

    // Add both users
    const participants = this.participantRepository.create([
      {
        conversationId: savedConversation.id,
        userId: currentUserId,
        lastReadAt: null,
      },
      {
        conversationId: savedConversation.id,
        userId: dto.participantId,
        lastReadAt: null,
      },
    ]);

    await this.participantRepository.save(participants);

    this.eventEmitter.emit('chat.conversation.created', {
      conversationId: savedConversation.id,
      participantIds: [currentUserId, dto.participantId],
    });

    return this.getConversationById(
      savedConversation.id,
      currentUserId,
    );
  }

  // =========================================================
  // FIND EXISTING CONVERSATION
  // =========================================================

  private async findExistingConversation(
    userA: string,
    userB: string,
  ): Promise<Conversation | null> {
    const conversations = await this.conversationRepository
      .createQueryBuilder('conversation')
      .innerJoin(
        'conversation.participants',
        'participantA',
        'participantA.userId = :userA',
        { userA },
      )
      .innerJoin(
        'conversation.participants',
        'participantB',
        'participantB.userId = :userB',
        { userB },
      )
      .getMany();

    return conversations.length > 0 ? conversations[0] : null;
  }

  // =========================================================
  // GET USER CONVERSATIONS
  // =========================================================

  async getMyConversations(currentUserId: string) {
    const participants = await this.participantRepository.find({
      where: {
        userId: currentUserId,
      },
      relations: {
        conversation: {
          participants: {
            user: true,
          },
        },
      },
      order: {
        joinedAt: 'DESC',
      },
    });

    const results: any[] = [];

    for (const participant of participants) {
      const conversation = participant.conversation;

      const otherParticipant = conversation.participants.find(
        (p) => p.userId !== currentUserId,
      );

      if (!otherParticipant) {
        continue;
      }

      const lastMessage = await this.messageRepository.findOne({
        where: {
          conversationId: conversation.id,
        },
        order: {
          createdAt: 'DESC',
        },
      });

      const unreadCount = await this.messageRepository
        .createQueryBuilder('message')
        .where('message.conversation_id = :conversationId', {
          conversationId: conversation.id,
        })
        .andWhere('message.sender_id != :userId', {
          userId: currentUserId,
        })
        .andWhere('message.status = :sentStatus', {
          sentStatus: MessageStatus.SENT,
        })
        .andWhere(
          participant.lastReadAt
            ? 'message.created_at > :lastReadAt'
            : '1=1',
          participant.lastReadAt
            ? { lastReadAt: participant.lastReadAt }
            : {},
        )
        .getCount();

      results.push({
        id: conversation.id,

        participant: {
          id: otherParticipant.user.id,
          name: otherParticipant.user.name,
          role: otherParticipant.user.role,
          avatarUrl: otherParticipant.user.avatarUrl,
          isOnline: this.onlinePresenceService.isUserOnline(otherParticipant.user.id),
        },

        lastMessage: lastMessage
          ? {
              id: lastMessage.id,
              content: lastMessage.content,
              messageType: lastMessage.messageType,
              createdAt: lastMessage.createdAt,
            }
          : null,

        unreadCount,

        createdAt: conversation.createdAt,
        updatedAt: lastMessage ? lastMessage.createdAt : conversation.updatedAt,
      });
    }

    // Sort by latest message time (most recent first)
    results.sort((a, b) => {
      const timeA = a.lastMessage?.createdAt
        ? new Date(a.lastMessage.createdAt).getTime()
        : new Date(a.updatedAt || a.createdAt).getTime();
      const timeB = b.lastMessage?.createdAt
        ? new Date(b.lastMessage.createdAt).getTime()
        : new Date(b.updatedAt || b.createdAt).getTime();
      return timeB - timeA;
    });

    return results;
  }

  // =========================================================
  // GET CONVERSATION
  // =========================================================

  async getConversationById(
    conversationId: string,
    currentUserId: string,
  ) {
    await this.ensureParticipant(conversationId, currentUserId);

    const conversation = await this.conversationRepository.findOne({
      where: {
        id: conversationId,
      },
      relations: {
        participants: {
          user: true,
        },
      },
    });

    if (!conversation) {
      throw new NotFoundException('Conversation not found');
    }

    const otherParticipant = conversation.participants.find(
      (p) => p.userId !== currentUserId,
    );

    return {
      id: conversation.id,

      participant: otherParticipant
        ? {
            id: otherParticipant.user.id,
            name: otherParticipant.user.name,
            role: otherParticipant.user.role,
            avatarUrl: otherParticipant.user.avatarUrl,
            isOnline: this.onlinePresenceService.isUserOnline(otherParticipant.user.id),
          }
        : null,

      createdAt: conversation.createdAt,
      updatedAt: conversation.updatedAt,
    };
  }

  // =========================================================
  // GET MESSAGES
  // =========================================================

  async getMessages(
    conversationId: string,
    currentUserId: string,
    limit = 30,
    before?: string,
  ) {
    await this.ensureParticipant(conversationId, currentUserId);

    const query = this.messageRepository
      .createQueryBuilder('message')
      .where('message.conversation_id = :conversationId', {
        conversationId,
      })
      .orderBy('message.created_at', 'DESC')
      .take(Math.min(limit, 100));

    if (before) {
      const beforeMessage = await this.messageRepository.findOne({
        where: {
          id: before,
          conversationId,
        },
      });

      if (beforeMessage) {
        query.andWhere('message.created_at < :beforeDate', {
          beforeDate: beforeMessage.createdAt,
        });
      }
    }

    const messages = await query.getMany();

    return {
      messages: messages.reverse(),
      hasMore: messages.length === Math.min(limit, 100),
    };
  }

  // =========================================================
  // SEND MESSAGE
  // =========================================================

    async sendMessage(
        conversationId: string,
        currentUserId: string,
        dto: SendMessageDto,
    ) {
    await this.ensureParticipant(
        conversationId,
        currentUserId,
    );

    const message = this.messageRepository.create({
        conversationId,
        senderId: currentUserId,
        content: dto.content,
        messageType:
        dto.messageType ?? MessageType.TEXT,
        status: MessageStatus.SENT,
    });

    const savedMessage =
        await this.messageRepository.save(message);

    try {
      await this.conversationRepository.update(conversationId, {
        updatedAt: new Date(),
      });
    } catch {
      // Ignored
    }

    this.eventEmitter.emit('chat.message.created', {
      id: savedMessage.id,
      conversationId: savedMessage.conversationId,
      senderId: savedMessage.senderId,
      content: savedMessage.content,
      messageType: savedMessage.messageType,
      status: savedMessage.status,
      createdAt: savedMessage.createdAt,
      updatedAt: savedMessage.updatedAt,
    });

    // Find the other participant
    const participants =
        await this.participantRepository.find({
            where: {
            conversationId,
            },
        });

    const otherParticipant = participants.find(
        (participant) =>
            participant.userId !== currentUserId,
        );

    if (otherParticipant) {
      try {
        const sender = await this.userRepository.findOne({
          where: { id: currentUserId },
        });
        const senderName = sender?.name ?? 'Someone';

        await this.notificationService.createOrGroupMessageNotification({
          userId: otherParticipant.userId,
          conversationId,
          senderName,
          messageType: savedMessage.messageType,
        });
      } catch (e) {
        console.error('Failed to create chat notification:', e);
      }
    }

    return savedMessage;
    }

  // =========================================================
  // MARK READ
  // =========================================================

  async markAsRead(
    conversationId: string,
    currentUserId: string,
    dto?: MarkReadDto,
  ) {
    const participant = await this.ensureParticipant(
      conversationId,
      currentUserId,
    );

    let message: Message | null = null;
    if (dto?.messageId) {
      message = await this.messageRepository.findOne({
        where: {
          id: dto.messageId,
          conversationId,
        },
      });
    }

    // Set lastReadAt to the current timestamp so all prior messages are read
    participant.lastReadAt = new Date();

    await this.participantRepository.save(participant);

    // Update message status to READ for incoming messages
    const updateQuery = this.messageRepository
      .createQueryBuilder()
      .update(Message)
      .set({ status: MessageStatus.READ })
      .where('conversation_id = :conversationId', { conversationId })
      .andWhere('sender_id != :currentUserId', { currentUserId })
      .andWhere('status = :sentStatus', { sentStatus: MessageStatus.SENT });

    if (message) {
      updateQuery.andWhere('created_at <= :createdAt', { createdAt: message.createdAt });
    }

    await updateQuery.execute();

    // Mark corresponding notifications as read if any
    try {
      await this.notificationService.markConversationNotificationsAsRead(
        currentUserId,
        conversationId,
      );
    } catch (_) {}

    this.eventEmitter.emit('chat.messages.read', {
      conversationId,
      readerId: currentUserId,
      messageId: dto?.messageId,
      lastReadAt: participant.lastReadAt,
    });

    return {
      success: true,
      lastReadAt: participant.lastReadAt,
    };
  }

  // =========================================================
  // DELETE / ARCHIVE CONVERSATION
  // =========================================================

  async deleteConversation(
    conversationId: string,
    currentUserId: string,
  ) {
    await this.ensureParticipant(conversationId, currentUserId);

    await this.conversationRepository.delete(conversationId);

    this.eventEmitter.emit('chat.conversation.deleted', {
      conversationId,
      deletedBy: currentUserId,
    });

    return {
      success: true,
    };
  }

  // =========================================================
  // DELETE MESSAGE
  // =========================================================

  async deleteMessage(
    messageId: string,
    currentUserId: string,
  ) {
    const message = await this.messageRepository.findOne({
      where: { id: messageId },
    });

    if (!message) {
      throw new NotFoundException('Message not found');
    }

    await this.ensureParticipant(message.conversationId, currentUserId);

    if (message.senderId !== currentUserId) {
      throw new ForbiddenException('You can only delete your own messages');
    }

    const conversationId = message.conversationId;

    // If it was an image message, clean up local file if exists
    if (message.messageType === MessageType.IMAGE && message.content) {
      try {
        const filePath = join(process.cwd(), message.content.replace(/^\//, ''));
        if (fs.existsSync(filePath)) {
          fs.unlinkSync(filePath);
        }
      } catch {
        // Ignored
      }
    }

    await this.messageRepository.delete(messageId);

    this.eventEmitter.emit('chat.message.deleted', {
      conversationId,
      messageId,
      deletedBy: currentUserId,
    });

    return {
      success: true,
      messageId,
      conversationId,
    };
  }

  // =========================================================
  // AUTHORIZATION
  // =========================================================

  private async ensureParticipant(
    conversationId: string,
    userId: string,
  ) {
    const participant = await this.participantRepository.findOne({
      where: {
        conversationId,
        userId,
      },
    });

    if (!participant) {
      throw new ForbiddenException(
        'You are not a participant in this conversation',
      );
    }

    return participant;
  }
}