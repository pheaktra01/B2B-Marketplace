import {
  Controller,
  Delete,
  Get,
  Param,
  ParseIntPipe,
  Patch,
  Query,
  Req,
  DefaultValuePipe,
  UseGuards,
} from '@nestjs/common';

import { NotificationService } from './notification.service';

// Change this import to your actual JWT guard.
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@Controller('notifications')
@UseGuards(JwtAuthGuard)
export class NotificationController {
  constructor(
    private readonly notificationService: NotificationService,
  ) {}

  // =========================================================
  // GET NOTIFICATIONS
  // =========================================================

  @Get()
  async getMyNotifications(
    @Req() req: any,

    @Query(
      'limit',
      new DefaultValuePipe(30),
      ParseIntPipe,
    )
    limit: number,

    @Query(
      'offset',
      new DefaultValuePipe(0),
      ParseIntPipe,
    )
    offset: number,
  ) {
    return this.notificationService.getMyNotifications(
      req.user.id,
      limit,
      offset,
    );
  }

  // =========================================================
  // UNREAD COUNT
  // =========================================================

  @Get('unread-count')
  async getUnreadCount(
    @Req() req: any,
  ) {
    return this.notificationService.getUnreadCount(
      req.user.id,
    );
  }

  // =========================================================
  // MARK ONE AS READ
  // =========================================================

  @Patch(':id/read')
  async markAsRead(
    @Req() req: any,
    @Param('id') notificationId: string,
  ) {
    return this.notificationService.markAsRead(
      notificationId,
      req.user.id,
    );
  }

  // =========================================================
  // MARK ALL AS READ
  // =========================================================

  @Patch('read-all')
  async markAllAsRead(
    @Req() req: any,
  ) {
    return this.notificationService.markAllAsRead(
      req.user.id,
    );
  }

  // =========================================================
  // DELETE ONE
  // =========================================================

  @Delete(':id')
  async delete(
    @Req() req: any,
    @Param('id') notificationId: string,
  ) {
    return this.notificationService.delete(
      notificationId,
      req.user.id,
    );
  }

  // =========================================================
  // DELETE ALL
  // =========================================================

  @Delete()
  async deleteAll(
    @Req() req: any,
  ) {
    return this.notificationService.deleteAll(
      req.user.id,
    );
  }
}