import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';

import { InjectRepository } from '@nestjs/typeorm';

import {
  DataSource,
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

    private readonly dataSource: DataSource,
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

        const createdOrders: Order[] = [];

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
          // Create Order Items
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
                },
              );

            await manager.save(
              OrderItem,
              orderItem,
            );

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
            }

            await manager.save(
              Product,
              product,
            );
          }

          createdOrders.push(
            savedOrder,
          );
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

    return orders;
  }

  // ==========================================
  // GET ORDER BY ID
  // ==========================================

  async getOrderById(
    restaurantId: string,
    orderId: string,
  ) {
    const order =
      await this.orderRepository.findOne({
        where: {
          id: orderId,
          restaurantId,
        },
        relations: {
          items: true,
        },
      });

    if (!order) {
      throw new NotFoundException(
        'Order not found',
      );
    }

    return order;
  }
}