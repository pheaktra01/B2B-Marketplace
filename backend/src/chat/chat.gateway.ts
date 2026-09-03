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
      socket.emit('connected', { userId: payload.id });
    } catch {
      socket.disconnect(true);
    }
  }

  handleDisconnect() {}

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

  @OnEvent('chat.message.created')
  handleMessageCreated(message: Record<string, unknown>) {
    const conversationId = message.conversationId?.toString();
    if (!conversationId) return;
    this.server.to(this.room(conversationId)).emit('message_created', message);
  }

  private room(conversationId: string) {
    return `conversation:${conversationId}`;
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
