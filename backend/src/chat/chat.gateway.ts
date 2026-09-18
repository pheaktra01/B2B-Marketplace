import {
  ConnectedSocket,
  MessageBody,
  OnGatewayConnection,
  OnGatewayDisconnect,
  SubscribeMessage,
  WebSocketGateway,
  WebSocketServer,
} from '@nestjs/websockets';
import { InjectRepository } from '@nestjs/typeorm';
import { JwtService } from '@nestjs/jwt';
import { OnEvent } from '@nestjs/event-emitter';
import { Server, Socket } from 'socket.io';
import { Repository } from 'typeorm';
import { ConversationParticipant } from './entities/conversation-participant.entity';

import { OnlinePresenceService } from './online-presence.service';
import { NotificationService } from '../notification/notification.service';

@WebSocketGateway({
  cors: { origin: '*' },
  transports: ['websocket'],
})
export class ChatGateway implements OnGatewayConnection, OnGatewayDisconnect {
  @WebSocketServer()
  server: Server;

  constructor(
    private readonly jwtService: JwtService,
    @InjectRepository(ConversationParticipant)
    private readonly participantRepository: Repository<ConversationParticipant>,
    private readonly onlinePresenceService: OnlinePresenceService,
    private readonly notificationService: NotificationService,
  ) {}

  async handleConnection(socket: Socket) {
    const token = this.getToken(socket);
    if (!token) {
      socket.disconnect(true);
      return;
    }

    try {
      const payload = this.jwtService.verify(token);
      socket.data.userId = payload.id;

      const isFirst = this.onlinePresenceService.addUserSocket(payload.id, socket.id);
      await socket.join(this.userRoom(payload.id));
      socket.emit('connected', { userId: payload.id });

      try {
        const unread = await this.notificationService.getUnreadCount(payload.id);
        socket.emit('notification_count_updated', { count: unread.count });
      } catch {
        // Ignored
      }

      if (isFirst) {
        this.server.emit('user_status_changed', {
          userId: payload.id,
          isOnline: true,
        });
      }
    } catch {
      socket.disconnect(true);
    }
  }

  handleDisconnect(socket: Socket) {
    const userId = socket.data?.userId;
    if (userId) {
      const isLast = this.onlinePresenceService.removeUserSocket(userId, socket.id);
      if (isLast) {
        this.server.emit('user_status_changed', {
          userId,
          isOnline: false,
        });
      }
    }
  }

  @SubscribeMessage('check_online')
  handleCheckOnline(
    @ConnectedSocket() socket: Socket,
    @MessageBody() body: { userId?: string; userIds?: string[] },
  ) {
    if (body.userId) {
      return {
        userId: body.userId,
        isOnline: this.onlinePresenceService.isUserOnline(body.userId),
      };
    }
    if (body.userIds && Array.isArray(body.userIds)) {
      return this.onlinePresenceService.getOnlineStatusMap(body.userIds);
    }
    return {};
  }

  @SubscribeMessage('join_conversation')
  async joinConversation(
    @ConnectedSocket() socket: Socket,
    @MessageBody() body: { conversationId?: string },
  ) {
    const conversationId = body?.conversationId;
    if (!conversationId || !socket.data.userId) return;

    const participant = await this.participantRepository.findOne({
      where: { conversationId, userId: socket.data.userId },
    });
    if (!participant) return;

    await socket.join(this.room(conversationId));
    socket.emit('conversation_joined', { conversationId });
  }

  @SubscribeMessage('join_notifications')
  async joinNotifications(@ConnectedSocket() socket: Socket) {
    if (!socket.data.userId) return;
    await socket.join(this.userRoom(socket.data.userId));
    socket.emit('notifications_joined', { userId: socket.data.userId });
    try {
      const unread = await this.notificationService.getUnreadCount(socket.data.userId);
      socket.emit('notification_count_updated', { count: unread.count });
    } catch {
      // Ignored
    }
  }

  @SubscribeMessage('get_unread_notification_count')
  async handleGetUnreadNotificationCount(@ConnectedSocket() socket: Socket) {
    if (!socket.data.userId) return { count: 0 };
    try {
      return await this.notificationService.getUnreadCount(socket.data.userId);
    } catch {
      return { count: 0 };
    }
  }

  @SubscribeMessage('typing')
  handleTyping(
    @ConnectedSocket() socket: Socket,
    @MessageBody() body: { conversationId?: string },
  ) {
    const conversationId = body?.conversationId;
    if (!conversationId || !socket.data.userId) return;
    socket.to(this.room(conversationId)).emit('user_typing', {
      conversationId,
      userId: socket.data.userId,
    });
  }

  @SubscribeMessage('stop_typing')
  handleStopTyping(
    @ConnectedSocket() socket: Socket,
    @MessageBody() body: { conversationId?: string },
  ) {
    const conversationId = body?.conversationId;
    if (!conversationId || !socket.data.userId) return;
    socket.to(this.room(conversationId)).emit('user_stop_typing', {
      conversationId,
      userId: socket.data.userId,
    });
  }

  @OnEvent('chat.message.created')
  async handleMessageCreated(message: Record<string, unknown>) {
    const conversationId = message.conversationId?.toString();
    if (!conversationId) return;
    this.server.to(this.room(conversationId)).emit('message_created', message);

    const participants = await this.participantRepository.find({
      where: { conversationId },
    });
    for (const participant of participants) {
      this.server
        .to(this.userRoom(participant.userId))
        .emit('conversation_updated', {
          conversationId,
          lastMessage: message,
        });
      this.server
        .to(this.userRoom(participant.userId))
        .emit('message_created', message);
    }
  }

  @OnEvent('chat.messages.read')
  async handleMessagesRead(payload: {
    conversationId: string;
    readerId: string;
    messageId?: string;
    lastReadAt: Date;
  }) {
    // 1. Notify the conversation room that messages were marked read
    this.server.to(this.room(payload.conversationId)).emit('messages_read', payload);

    // 2. Notify participants to refresh conversation list
    const participants = await this.participantRepository.find({
      where: { conversationId: payload.conversationId },
    });
    for (const participant of participants) {
      this.server
        .to(this.userRoom(participant.userId))
        .emit('conversation_updated', {
          conversationId: payload.conversationId,
          readerId: payload.readerId,
          lastReadAt: payload.lastReadAt,
        });
    }
  }

  @OnEvent('chat.conversation.created')
  handleConversationCreated(payload: {
    conversationId: string;
    participantIds: string[];
  }) {
    for (const userId of payload.participantIds) {
      this.server
        .to(this.userRoom(userId))
        .emit('conversation_updated', { conversationId: payload.conversationId });
    }
  }

  @OnEvent('chat.conversation.deleted')
  handleConversationDeleted(payload: {
    conversationId: string;
    deletedBy: string;
  }) {
    this.server
      .to(this.room(payload.conversationId))
      .emit('conversation_deleted', payload);
  }

  @OnEvent('notification.created')
  handleNotificationCreated(notification: Record<string, unknown>) {
    const userId = notification.userId?.toString();
    if (!userId) return;
    this.server.to(this.userRoom(userId)).emit('notification_created', notification);
  }

  @OnEvent('notification.read')
  handleNotificationRead(payload: { notificationId: string; userId: string }) {
    if (!payload.userId) return;
    this.server.to(this.userRoom(payload.userId)).emit('notification_read', {
      notificationId: payload.notificationId,
    });
  }

  @OnEvent('notification.read_all')
  handleNotificationReadAll(payload: { userId: string }) {
    if (!payload.userId) return;
    this.server.to(this.userRoom(payload.userId)).emit('notification_read_all', {});
  }

  @OnEvent('notification.deleted')
  handleNotificationDeleted(payload: { notificationId: string; userId: string }) {
    if (!payload.userId) return;
    this.server.to(this.userRoom(payload.userId)).emit('notification_deleted', {
      notificationId: payload.notificationId,
    });
  }

  @OnEvent('notification.deleted_all')
  handleNotificationDeletedAll(payload: { userId: string }) {
    if (!payload.userId) return;
    this.server.to(this.userRoom(payload.userId)).emit('notification_deleted_all', {});
  }

  @OnEvent('notification.count_updated')
  handleNotificationCountUpdated(payload: { userId: string; unreadCount: number }) {
    if (!payload.userId) return;
    this.server.to(this.userRoom(payload.userId)).emit('notification_count_updated', {
      count: payload.unreadCount,
    });
  }

  private room(conversationId: string) {
    return `conversation:${conversationId}`;
  }

  private userRoom(userId: string) {
    return `user:${userId}:notifications`;
  }

  private getToken(socket: Socket): string | undefined {
    const authToken = socket.handshake.auth?.token;
    if (typeof authToken === 'string' && authToken.length > 0) {
      return authToken;
    }

    const authorization = socket.handshake.headers.authorization;
    return authorization?.startsWith('Bearer ')
      ? authorization.substring(7)
      : undefined;
  }
}
