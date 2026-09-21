import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';

import { InjectRepository } from '@nestjs/typeorm';

import {
  DataSource,
  In,
  Repository,
} from 'typeorm';

import {
  Order,
  OrderStatus,
  PaymentStatus,
} from './entities/order.entity';

import { OrderItem } from './entities/order-item.entity';

import { CheckoutDto } from './dto/checkout.dto';

import { Cart } from '../cart/entities/cart.entity';
import { CartItem } from '../cart/entities/cart-item.entity';
import { Product } from 'src/products/enterties/product.entity';
import {
  Notification,
  NotificationType,
} from '../notification/entities/notification.entity';
import { User } from '../users/entities/user.entity';
import { EventEmitter2 } from '@nestjs/event-emitter';

@Injectable()
export class OrderService {
  constructor(
    @InjectRepository(Order)
    private readonly orderRepository: Repository<Order>,

    @InjectRepository(OrderItem)
    private readonly orderItemRepository: Repository<OrderItem>,

    @InjectRepository(Cart)
    private readonly cartRepository: Repository<Cart>,

    @InjectRepository(CartItem)
    private readonly cartItemRepository: Repository<CartItem>,

    @InjectRepository(Product)
    private readonly productRepository: Repository<Product>,

    @InjectRepository(Notification)
    private readonly notificationRepository: Repository<Notification>,

    @InjectRepository(User)
    private readonly userRepository: Repository<User>,

    private readonly dataSource: DataSource,
    private readonly eventEmitter: EventEmitter2,
  ) {}

  // ==========================================
  // CHECKOUT
  // ==========================================

  async checkout(
    restaurantId: string,
    checkoutDto: CheckoutDto,
  ) {
    return this.dataSource.transaction(
      async (manager) => {

        // --------------------------------------
        // 1. Validate delivery address
        // --------------------------------------

        if (
          checkoutDto.deliveryMethod === 'delivery' &&
          !checkoutDto.deliveryAddress
        ) {
          throw new BadRequestException(
            'Delivery address is required for delivery',
          );
        }

        // --------------------------------------
        // 2. Find cart
        // --------------------------------------

        const cart = await manager.findOne(Cart, {
          where: {
            restaurantId,
          },
          relations: {
            items: {
              product: true,
            },
          },
        });

        if (!cart) {
          throw new NotFoundException(
            'Cart not found',
          );
        }

        if (
          !cart.items ||
          cart.items.length === 0
        ) {
          throw new BadRequestException(
            'Your cart is empty',
          );
        }

        // --------------------------------------
        // 3. Validate cart items
        // --------------------------------------

        for (const item of cart.items) {
          const product = item.product;

          if (!product) {
            throw new BadRequestException(
              'A product in your cart no longer exists',
            );
          }

          if (!product.isAvailable) {
            throw new BadRequestException(
              `${product.name} is no longer available`,
            );
          }

          if (
            Number(item.quantity) >
            Number(product.quantity)
          ) {
            throw new BadRequestException(
              `${product.name} only has ${product.quantity} available`,
            );
          }

          if (
            Number(item.quantity) <
            Number(product.minOrder)
          ) {
            throw new BadRequestException(
              `${product.name} requires a minimum order of ${product.minOrder}`,
            );
          }
        }

        // --------------------------------------
        // 4. Group cart items by farmer
        // --------------------------------------

        const farmerGroups =
          new Map<string, CartItem[]>();

        for (const item of cart.items) {
          const farmerId =
            item.product.farmerId;

          if (!farmerGroups.has(farmerId)) {
            farmerGroups.set(
              farmerId,
              [],
            );
          }

          farmerGroups
            .get(farmerId)!
            .push(item);
        }

        // --------------------------------------
        // 5. Create orders
        // --------------------------------------

        const buyer = await this.userRepository.findOne({
          where: { id: restaurantId },
        });
        const buyerName = buyer?.name ?? 'Green Garden Restaurant';

        const createdOrders: Order[] = [];
        const allOrderItems: OrderItem[] = [];
        const productsToSave: Product[] = [];
        const notificationsToSave: Notification[] = [];

        for (const [
          farmerId,
          items,
        ] of farmerGroups.entries()) {

          // ------------------------------------
          // Calculate subtotal
          // ------------------------------------

          let subtotal = 0;

          for (const item of items) {
            subtotal +=
              Number(item.quantity) *
              Number(item.unitPrice);
          }

          // Round subtotal to 2 decimals
          subtotal = Number(
            subtotal.toFixed(2),
          );

          // ------------------------------------
          // Transaction fee - 5%
          // ------------------------------------

          const transactionFee = Number(
            (subtotal * 0.05).toFixed(2),
          );

          // ------------------------------------
          // Delivery fee
          // ------------------------------------

          let deliveryFee = 0;

          if (
            checkoutDto.deliveryMethod ===
            'delivery'
          ) {
            deliveryFee = 2;
          }

          // ------------------------------------
          // Total
          // ------------------------------------

          const total = Number(
            (
              subtotal +
              transactionFee +
              deliveryFee
            ).toFixed(2),
          );

          // ------------------------------------
          // Create Order
          // ------------------------------------

          const order = manager.create(
            Order,
            {
              restaurantId,

              farmerId,

              status:
                OrderStatus.PENDING,

              paymentMethod:
                checkoutDto.paymentMethod,

              paymentStatus:
                PaymentStatus.PENDING,

              deliveryMethod:
                checkoutDto.deliveryMethod,

              deliveryAddress:
                checkoutDto.deliveryAddress ?? '',

              subtotal,

              deliveryFee,

              transactionFee,

              total,
            },
          );

          const savedOrder =
            await manager.save(
              Order,
              order,
            );

          // ------------------------------------
          // Create Order Items & Update Inventory
          // ------------------------------------

          for (const item of items) {
            const product =
              item.product;

            const itemSubtotal = Number(
              (
                Number(item.quantity) *
                Number(item.unitPrice)
              ).toFixed(2),
            );

            const orderItem =
              manager.create(
                OrderItem,
                {
                  orderId:
                    savedOrder.id,

                  productId:
                    product.id,

                  productName:
                    product.name,

                  quantity:
                    Number(item.quantity),

                  unitPrice:
                    Number(item.unitPrice),

                  subtotal:
                    itemSubtotal,

                  imageUrl:
                    product.imageUrls && product.imageUrls.length > 0
                      ? product.imageUrls[0]
                      : null,
                },
              );

            allOrderItems.push(orderItem);

            // ----------------------------------
            // Reduce inventory
            // ----------------------------------

            product.quantity =
              Number(product.quantity) -
              Number(item.quantity);

            if (
              Number(product.quantity) <=
              0
            ) {
              product.quantity = 0;
              product.isAvailable = false;

              // Out of stock notification for farmer
              notificationsToSave.push(
                manager.create(Notification, {
                  userId: farmerId,
                  type: NotificationType.PRODUCT_OUT_OF_STOCK,
                  title: 'Out of Stock',
                  message: `${product.name} is now out of stock.`,
                  referenceId: product.id,
                  referenceType: 'product',
                  isRead: false,
                }),
              );
            } else if (Number(product.quantity) <= 5) {
              // Low stock notification for farmer
              notificationsToSave.push(
                manager.create(Notification, {
                  userId: farmerId,
                  type: NotificationType.PRODUCT_LOW_STOCK,
                  title: 'Low Stock',
                  message: `Your ${product.name} stock is running low.`,
                  referenceId: product.id,
                  referenceType: 'product',
                  isRead: false,
                }),
              );
            }

            productsToSave.push(product);
          }

          const orderNum = savedOrder.id.slice(0, 8);

          // ------------------------------------
          // 1. Notify Farmer of new order
          // ------------------------------------
          notificationsToSave.push(
            manager.create(
              Notification,
              {
                userId: farmerId,
                type: NotificationType.ORDER_CREATED,
                title: 'New Order',
                message: `You received a new order from ${buyerName}.`,
                referenceId: savedOrder.id,
                referenceType: 'order',
                isRead: false,
              },
            ),
          );

          // ------------------------------------
          // 2. Notify Restaurant of order placed
          // ------------------------------------
          notificationsToSave.push(
            manager.create(
              Notification,
              {
                userId: restaurantId,
                type: NotificationType.ORDER_PLACED,
                title: 'Order Placed',
                message: 'Your order has been placed successfully.',
                referenceId: savedOrder.id,
                referenceType: 'order',
                isRead: false,
              },
            ),
          );

          // ------------------------------------
          // 3. Payment Notifications
          // ------------------------------------
          notificationsToSave.push(
            manager.create(
              Notification,
              {
                userId: restaurantId,
                type: NotificationType.PAYMENT_SUCCESS,
                title: 'Payment Successful',
                message: `Payment for order #${orderNum} was successful.`,
                referenceId: savedOrder.id,
                referenceType: 'order',
                isRead: false,
              },
            ),
          );

          notificationsToSave.push(
            manager.create(
              Notification,
              {
                userId: farmerId,
                type: NotificationType.PAYMENT_RECEIVED,
                title: 'Payment Received',
                message: `You received payment for order #${orderNum}.`,
                referenceId: savedOrder.id,
                referenceType: 'order',
                isRead: false,
              },
            ),
          );

          createdOrders.push(
            savedOrder,
          );
        }

        // --------------------------------------
        // Batch save OrderItems, Products & Notifications
        // --------------------------------------

        if (allOrderItems.length > 0) {
          await manager.save(OrderItem, allOrderItems);
        }

        if (productsToSave.length > 0) {
          await manager.save(Product, productsToSave);
        }

        if (notificationsToSave.length > 0) {
          await manager.save(Notification, notificationsToSave);
          for (const notif of notificationsToSave) {
            this.eventEmitter.emit('notification.created', notif);
          }
        }

        // --------------------------------------
        // 6. Clear cart
        // --------------------------------------

        await manager.delete(
          CartItem,
          {
            cartId: cart.id,
          },
        );

        // --------------------------------------
        // 7. Return result
        // --------------------------------------

        return {
          message:
            'Checkout successful',

          orders:
            createdOrders.map(
              (order) => ({
                id: order.id,

                farmerId:
                  order.farmerId,

                status:
                  order.status,

                paymentMethod:
                  order.paymentMethod,

                paymentStatus:
                  order.paymentStatus,

                deliveryMethod:
                  order.deliveryMethod,

                deliveryAddress:
                  order.deliveryAddress,

                subtotal:
                  Number(order.subtotal),

                transactionFee:
                  Number(
                    order.transactionFee,
                  ),

                deliveryFee:
                  Number(
                    order.deliveryFee,
                  ),

                total:
                  Number(order.total),

                createdAt:
                  order.createdAt,
              }),
            ),
        };
      },
    );
  }

  // ==========================================
  // GET RESTAURANT ORDERS
  // ==========================================

  async getRestaurantOrders(
    restaurantId: string,
  ) {
    const orders =
      await this.orderRepository.find({
        where: {
          restaurantId,
        },
        relations: {
          items: true,
        },
        order: {
          createdAt: 'DESC',
        },
      });

    return this.withOrderDetails(orders);
  }

  async getFarmerOrders(farmerId: string) {
    const orders = await this.orderRepository.find({
      where: { farmerId },
      relations: { items: true },
      order: { createdAt: 'DESC' },
    });

    return this.withOrderDetails(orders);
  }

  async updateOrderStatus(
    farmerId: string,
    orderId: string,
    status: OrderStatus,
  ) {
    const order = await this.orderRepository.findOne({
      where: { id: orderId, farmerId },
    });

    if (!order) {
      throw new NotFoundException('Order not found');
    }

    const allowed: Record<OrderStatus, OrderStatus[]> = {
      [OrderStatus.PENDING]: [OrderStatus.CONFIRMED, OrderStatus.CANCELLED],
      [OrderStatus.CONFIRMED]: [OrderStatus.PROCESSING, OrderStatus.CANCELLED],
      [OrderStatus.PROCESSING]: [OrderStatus.SHIPPED],
      [OrderStatus.SHIPPED]: [OrderStatus.DELIVERED],
      [OrderStatus.DELIVERED]: [],
      [OrderStatus.CANCELLED]: [],
    };

    if (!allowed[order.status].includes(status)) {
      throw new BadRequestException(
        `Cannot change order status from ${order.status} to ${status}`,
      );
    }

    order.status = status;
    const updatedOrder = await this.orderRepository.save(order);

    // Notify buyer (restaurant) and farmer of status change
    try {
      const notificationsToSave: Notification[] = [];
      const orderNum = order.id.slice(0, 8);
      let buyerType = NotificationType.ORDER_STATUS_CHANGED;
      let buyerTitle = 'Order Status Updated';
      let buyerMessage = `Your order #${orderNum} status changed to ${status}.`;

      let farmerType = NotificationType.ORDER_STATUS_CHANGED;
      let farmerTitle = 'Order Status Updated';
      let farmerMessage = `Order #${orderNum} status changed to ${status}.`;

      if (status === OrderStatus.CONFIRMED) {
        buyerType = NotificationType.ORDER_ACCEPTED;
        buyerTitle = 'Order Accepted';
        buyerMessage = `Your order #${orderNum} has been accepted by the farmer.`;

        farmerType = NotificationType.ORDER_ACCEPTED;
        farmerTitle = 'Order Accepted';
        farmerMessage = `You accepted order #${orderNum}.`;
      } else if (status === OrderStatus.PROCESSING) {
        buyerType = NotificationType.ORDER_READY;
        buyerTitle = 'Order Ready';
        buyerMessage = `Your order #${orderNum} is ready for pickup.`;

        farmerType = NotificationType.ORDER_READY;
        farmerTitle = 'Order Ready';
        farmerMessage = `Order #${orderNum} is ready for pickup.`;
      } else if (status === OrderStatus.SHIPPED) {
        buyerType = NotificationType.ORDER_STATUS_CHANGED;
        buyerTitle = 'Order Shipped';
        buyerMessage = `Your order #${orderNum} is on the way.`;

        farmerType = NotificationType.ORDER_STATUS_CHANGED;
        farmerTitle = 'Order Shipped';
        farmerMessage = `Order #${orderNum} is on the way.`;
      } else if (status === OrderStatus.DELIVERED) {
        buyerType = NotificationType.ORDER_COMPLETED;
        buyerTitle = 'Order Completed';
        buyerMessage = `Your order #${orderNum} has been completed.`;

        farmerType = NotificationType.ORDER_COMPLETED;
        farmerTitle = 'Order Completed';
        farmerMessage = `Order #${orderNum} has been completed.`;

        // Farmer payment completed notification
        const farmerPayNotif = this.notificationRepository.create({
          userId: order.farmerId,
          type: NotificationType.PAYMENT_COMPLETED,
          title: 'Payment Completed',
          message: `Payment for order #${orderNum} has been completed.`,
          referenceId: order.id,
          referenceType: 'order',
          isRead: false,
        });
        notificationsToSave.push(farmerPayNotif);
      } else if (status === OrderStatus.CANCELLED) {
        buyerType = NotificationType.ORDER_REJECTED;
        buyerTitle = 'Order Rejected / Cancelled';
        buyerMessage = `Your order #${orderNum} was rejected by the farmer.`;

        farmerType = NotificationType.ORDER_CANCELLED;
        farmerTitle = 'Order Cancelled';
        farmerMessage = `Order #${orderNum} has been cancelled.`;
      }

      const buyerNotification = this.notificationRepository.create({
        userId: order.restaurantId,
        type: buyerType,
        title: buyerTitle,
        message: buyerMessage,
        referenceId: order.id,
        referenceType: 'order',
        isRead: false,
      });
      notificationsToSave.push(buyerNotification);

      const farmerNotification = this.notificationRepository.create({
        userId: order.farmerId,
        type: farmerType,
        title: farmerTitle,
        message: farmerMessage,
        referenceId: order.id,
        referenceType: 'order',
        isRead: false,
      });
      notificationsToSave.push(farmerNotification);

      await this.notificationRepository.save(notificationsToSave);
      for (const n of notificationsToSave) {
        this.eventEmitter.emit('notification.created', n);
      }
    } catch (e) {
      console.error('Failed to create status notifications:', e);
    }

    return updatedOrder;
  }

  // ==========================================
  // GET ORDER BY ID
  // ==========================================

  async getOrderById(
    userId: string,
    orderId: string,
  ) {
    const order =
      await this.orderRepository.findOne({
        where: [
          {
            id: orderId,
            restaurantId: userId,
          },
          {
            id: orderId,
            farmerId: userId,
          },
        ],
        relations: {
          items: true,
        },
      });

    if (!order) {
      throw new NotFoundException(
        'Order not found',
      );
    }

    const [enriched] = await this.withOrderDetails([order]);
    return enriched;
  }

  // ==========================================
  // ENRICH ORDERS WITH USER PROFILES & PRODUCT IMAGES
  // ==========================================

  private async withOrderDetails(orders: Order[]): Promise<any[]> {
    if (!orders || orders.length === 0) return orders;

    const userIds = new Set<string>();
    const missingProductIds = new Set<string>();

    for (const order of orders) {
      if (order.restaurantId) userIds.add(order.restaurantId);
      if (order.farmerId) userIds.add(order.farmerId);

      if (order.items) {
        for (const item of order.items) {
          if (item.productId && !item.imageUrl) {
            missingProductIds.add(item.productId);
          }
        }
      }
    }

    const userQueryPromise =
      userIds.size > 0
        ? this.userRepository.find({
            where: { id: In(Array.from(userIds)) },
            select: {
              id: true,
              name: true,
              phone: true,
              role: true,
              avatarUrl: true,
            },
          })
        : Promise.resolve([]);

    const productQueryPromise =
      missingProductIds.size > 0
        ? this.productRepository.find({
            where: { id: In(Array.from(missingProductIds)) },
            select: { id: true, name: true, imageUrls: true },
          })
        : Promise.resolve([]);

    let userMap = new Map<string, any>();
    let productMap = new Map<string, Product>();

    try {
      const [users, products] = await Promise.all([
        userQueryPromise,
        productQueryPromise,
      ]);
      userMap = new Map(users.map((u) => [u.id, u]));
      productMap = new Map(products.map((p) => [p.id, p]));
    } catch (e) {
      console.error('Failed to load enrichment details for orders:', e);
    }

    return orders.map((order) => {
      const buyer = userMap.get(order.restaurantId) || null;
      const farmer = userMap.get(order.farmerId) || null;

      const updatedItems = (order.items || []).map((item) => {
        if (item.imageUrl) return item;
        const prod = productMap.get(item.productId);
        const img =
          prod?.imageUrls && prod.imageUrls.length > 0
            ? prod.imageUrls[0]
            : null;
        return {
          ...item,
          imageUrl: img,
        };
      });

      return {
        ...order,
        buyer,
        farmer,
        buyerName: buyer?.name || null,
        buyerPhone: buyer?.phone || null,
        buyerAvatarUrl: buyer?.avatarUrl || null,
        farmerName: farmer?.name || null,
        farmerPhone: farmer?.phone || null,
        farmerAvatarUrl: farmer?.avatarUrl || null,
        items: updatedItems,
      };
    });
  }
}