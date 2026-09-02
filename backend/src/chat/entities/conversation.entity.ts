import {
  Entity,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  UpdateDateColumn,
  OneToMany,
} from 'typeorm';
import { ConversationParticipant } from './conversation-participant.entity';
import { Message } from './message.entity';

@Entity('conversations')
export class Conversation {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @OneToMany(
    () => ConversationParticipant,
    (participant) => participant.conversation,
    {
      cascade: true,
    },
  )
  participants: ConversationParticipant[];

  @OneToMany(() => Message, (message) => message.conversation)
  messages: Message[];

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}