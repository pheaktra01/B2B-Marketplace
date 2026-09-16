import { Injectable } from '@nestjs/common';

@Injectable()
export class OnlinePresenceService {
  private readonly userSockets = new Map<string, Set<string>>();

  addUserSocket(userId: string, socketId: string): boolean {
    let sockets = this.userSockets.get(userId);
    const isFirst = !sockets || sockets.size === 0;
    if (!sockets) {
      sockets = new Set<string>();
      this.userSockets.set(userId, sockets);
    }
    sockets.add(socketId);
    return isFirst;
  }

  removeUserSocket(userId: string, socketId: string): boolean {
    const sockets = this.userSockets.get(userId);
    if (!sockets) return false;
    sockets.delete(socketId);
    if (sockets.size === 0) {
      this.userSockets.delete(userId);
      return true;
    }
    return false;
  }

  isUserOnline(userId: string): boolean {
    const sockets = this.userSockets.get(userId);
    return !!sockets && sockets.size > 0;
  }

  getOnlineStatusMap(userIds: string[]): Record<string, boolean> {
    const map: Record<string, boolean> = {};
    for (const id of userIds) {
      map[id] = this.isUserOnline(id);
    }
    return map;
  }
}
