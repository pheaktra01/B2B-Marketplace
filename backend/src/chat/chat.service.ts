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
import { NotificationService } from 'src/notification/notification.service';
import { NotificationType } from 'src/notification/entities/notification.entity';
import { EventEmitter2 } from '@nestjs/event-emitter';

@Injectable()
export class ChatService {
  constructor(
    @InjectRepository(Conversation)
    private readonly conversationRepository: Repository<Conversation>,

    @InjectRepository(ConversationParticipant)
    private readonly participantRepository: Repository<ConversationParticipant>,

    @InjectRepository(Message)
    private readonly messageRepository: Repository<Message>,

    private readonly notificationService: NotificationService,
    private readonly eventEmitter: EventEmitter2,
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
        updatedAt: conversation.updatedAt,
      });
    }

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
        await this.notificationService.create({
            userId: otherParticipant.userId,

            type: NotificationType.MESSAGE,

            title: 'New Message',

            message: 'You received a new message.',

            referenceId: conversationId,

            referenceType: 'conversation',
        });
    }

    return savedMessage;
    }

  // =========================================================
  // MARK READ
  // =========================================================

  async markAsRead(
    conversationId: string,
    currentUserId: string,
    dto: MarkReadDto,
  ) {
    const participant = await this.ensureParticipant(
      conversationId,
      currentUserId,
    );

    const message = await this.messageRepository.findOne({
      where: {
        id: dto.messageId,
        conversationId,
      },
    });

    if (!message) {
      throw new NotFoundException('Message not found');
    }

    participant.lastReadAt = message.createdAt;

    await this.participantRepository.save(participant);

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

    return {
      success: true,
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