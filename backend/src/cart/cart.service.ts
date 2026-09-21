import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';

import { Cart } from './entities/cart.entity';
import { CartItem } from './entities/cart-item.entity';

import { AddToCartDto } from './dto/add-to-cart.dto';
import { UpdateCartDto } from './dto/update-cart.dto';
import { Product } from 'src/products/enterties/product.entity';

@Injectable()
export class CartService {
  constructor(
    @InjectRepository(Cart)
    private readonly cartRepository: Repository<Cart>,

    @InjectRepository(CartItem)
    private readonly cartItemRepository: Repository<CartItem>,

    @InjectRepository(Product)
    private readonly productRepository: Repository<Product>,
  ) {}

  // ==========================================================
  // GET CART
  // ==========================================================

  async getCart(restaurantId: string) {
    let cart = await this.cartRepository.findOne({
      where: { restaurantId },
      relations: {
        items: {
          product: true,
        },
      },
    });

    if (!cart) {
      cart = this.cartRepository.create({
        restaurantId,
        items: [],
      });

      await this.cartRepository.save(cart);
    }

    return this.formatCart(cart);
  }

  // ==========================================================
  // ADD TO CART (OPTIMIZED WITH PARALLEL QUERIES & IN-MEMORY FORMAT)
  // ==========================================================

  async addToCart(
    restaurantId: string,
    addToCartDto: AddToCartDto,
  ) {
    const { productId, quantity } = addToCartDto;

    // Concurrently fetch product details and existing cart in parallel
    const [product, existingCart] = await Promise.all([
      this.productRepository.findOne({
        where: { id: productId },
      }),
      this.cartRepository.findOne({
        where: { restaurantId },
        relations: {
          items: {
            product: true,
          },
        },
      }),
    ]);

    if (!product) {
      throw new NotFoundException('Product not found');
    }

    if (!product.isAvailable) {
      throw new BadRequestException('This product is currently unavailable');
    }

    if (quantity < product.minOrder) {
      throw new BadRequestException(
        `Minimum order quantity is ${product.minOrder}`,
      );
    }

    if (quantity > product.quantity) {
      throw new BadRequestException(
        `Only ${product.quantity} units are available`,
      );
    }

    // Ensure cart exists
    let cart = existingCart;
    if (!cart) {
      cart = this.cartRepository.create({
        restaurantId,
        items: [],
      });
      cart = await this.cartRepository.save(cart);
      cart.items = [];
    }

    // Check if item already exists in cart
    const cartItem = cart.items?.find((item) => item.productId === productId);

    if (cartItem) {
      const newQuantity = Number(cartItem.quantity) + Number(quantity);

      if (newQuantity > product.quantity) {
        throw new BadRequestException(
          `Only ${product.quantity} units are available`,
        );
      }

      cartItem.quantity = newQuantity;
      await this.cartItemRepository.update(cartItem.id, {
        quantity: newQuantity,
      });
    } else {
      const newItem = this.cartItemRepository.create({
        cartId: cart.id,
        productId: product.id,
        quantity,
        unitPrice: product.price,
      });

      const savedItem = await this.cartItemRepository.save(newItem);
      savedItem.product = product;

      if (!cart.items) {
        cart.items = [];
      }
      cart.items.push(savedItem);
    }

    return this.formatCart(cart);
  }

  // ==========================================================
  // UPDATE CART ITEM (OPTIMIZED: SINGLE SELECT + DIRECT UPDATE)
  // ==========================================================

  async updateCartItem(
    restaurantId: string,
    productId: string,
    updateCartDto: UpdateCartDto,
  ) {
    const cart = await this.cartRepository.findOne({
      where: { restaurantId },
      relations: {
        items: {
          product: true,
        },
      },
    });

    if (!cart) {
      throw new NotFoundException('Cart not found');
    }

    const cartItem = cart.items?.find((item) => item.productId === productId);

    if (!cartItem) {
      throw new NotFoundException('Product is not in your cart');
    }

    const product = cartItem.product;

    if (!product) {
      throw new NotFoundException('Product details could not be found');
    }

    if (!product.isAvailable) {
      throw new BadRequestException('This product is currently unavailable');
    }

    if (updateCartDto.quantity < product.minOrder) {
      throw new BadRequestException(
        `Minimum order quantity is ${product.minOrder}`,
      );
    }

    if (updateCartDto.quantity > product.quantity) {
      throw new BadRequestException(
        `Only ${product.quantity} units are available`,
      );
    }

    // Update in database directly
    cartItem.quantity = updateCartDto.quantity;
    await this.cartItemRepository.update(cartItem.id, {
      quantity: updateCartDto.quantity,
    });

    // Return formatted cart immediately without querying the database again
    return this.formatCart(cart);
  }

  // ==========================================================
  // REMOVE ITEM (OPTIMIZED: SINGLE SELECT + DIRECT DELETE)
  // ==========================================================

  async removeFromCart(
    restaurantId: string,
    productId: string,
  ) {
    const cart = await this.cartRepository.findOne({
      where: { restaurantId },
      relations: {
        items: {
          product: true,
        },
      },
    });

    if (!cart) {
      throw new NotFoundException('Cart not found');
    }

    const itemIndex = cart.items?.findIndex((item) => item.productId === productId);

    if (itemIndex === -1 || itemIndex === undefined) {
      throw new NotFoundException('Product is not in your cart');
    }

    const [removedItem] = cart.items.splice(itemIndex, 1);
    await this.cartItemRepository.delete(removedItem.id);

    return this.formatCart(cart);
  }

  // ==========================================================
  // CLEAR CART
  // ==========================================================

  async clearCart(restaurantId: string) {
    const cart = await this.cartRepository.findOne({
      where: { restaurantId },
      select: { id: true },
    });

    if (!cart) {
      throw new NotFoundException('Cart not found');
    }

    await this.cartItemRepository.delete({
      cartId: cart.id,
    });

    return {
      message: 'Cart cleared successfully',
    };
  }

  // ==========================================================
  // FORMAT CART
  // ==========================================================

  private formatCart(cart: Cart) {
    const items = cart.items ?? [];

    const formattedItems = items.map((item) => {
      const quantity = Number(item.quantity);
      const unitPrice = Number(item.unitPrice);
      const subtotal = Number((quantity * unitPrice).toFixed(2));

      return {
        id: item.id,
        productId: item.productId,
        productName: item.product?.name ?? 'Product',
        imageUrl: item.product?.imageUrls ?? [],
        quantity,
        unitPrice,
        subtotal,
        deliveryFee: Number(item.product?.deliveryFee ?? 0),
        deliveryMethod: item.product?.deliveryMethod ?? 'Local Delivery',
      };
    });

    const total = formattedItems.reduce(
      (sum, item) => sum + item.subtotal,
      0,
    );

    return {
      id: cart.id,
      restaurantId: cart.restaurantId,
      items: formattedItems,
      total: Number(total.toFixed(2)),
      itemCount: formattedItems.length,
      totalQuantity: formattedItems.reduce(
        (sum, item) => sum + item.quantity,
        0,
      ),
    };
  }
}