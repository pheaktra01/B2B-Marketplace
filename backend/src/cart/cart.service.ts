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

  // =========================
  // GET CART
  // =========================

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

  // =========================
  // ADD TO CART
  // =========================

  async addToCart(
    restaurantId: string,
    addToCartDto: AddToCartDto,
  ) {
    const { productId, quantity } = addToCartDto;

    // Find product
    const product = await this.productRepository.findOne({
      where: { id: productId },
    });

    if (!product) {
      throw new NotFoundException('Product not found');
    }

    // Check availability
    if (!product.isAvailable) {
      throw new BadRequestException(
        'This product is currently unavailable',
      );
    }

    // Check minimum order
    if (quantity < product.minOrder) {
      throw new BadRequestException(
        `Minimum order quantity is ${product.minOrder}`,
      );
    }

    // Check available stock
    if (quantity > product.quantity) {
      throw new BadRequestException(
        `Only ${product.quantity} units are available`,
      );
    }

    // Find or create cart
    let cart = await this.cartRepository.findOne({
      where: { restaurantId },
    });

    if (!cart) {
      cart = this.cartRepository.create({
        restaurantId,
      });

      cart = await this.cartRepository.save(cart);
    }

    // Check if product already exists in cart
    let cartItem = await this.cartItemRepository.findOne({
      where: {
        cartId: cart.id,
        productId,
      },
    });

    if (cartItem) {
      const newQuantity =
        Number(cartItem.quantity) + Number(quantity);

      if (newQuantity > product.quantity) {
        throw new BadRequestException(
          `Only ${product.quantity} units are available`,
        );
      }

      cartItem.quantity = newQuantity;

      await this.cartItemRepository.save(cartItem);
    } else {
      cartItem = this.cartItemRepository.create({
        cartId: cart.id,
        productId: product.id,
        quantity,
        unitPrice: product.price,
      });

      await this.cartItemRepository.save(cartItem);
    }

    return this.getCart(restaurantId);
  }

  // =========================
  // UPDATE CART ITEM
  // =========================

  async updateCartItem(
    restaurantId: string,
    productId: string,
    updateCartDto: UpdateCartDto,
  ) {
    const cart = await this.cartRepository.findOne({
      where: { restaurantId },
    });

    if (!cart) {
      throw new NotFoundException('Cart not found');
    }

    const cartItem = await this.cartItemRepository.findOne({
        where: {
            cartId: cart.id,
            productId,
        },
        relations: {
            product: true,
        },
    });

    if (!cartItem) {
      throw new NotFoundException(
        'Product is not in your cart',
      );
    }

    const product = cartItem.product;

    if (!product.isAvailable) {
      throw new BadRequestException(
        'This product is currently unavailable',
      );
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

    cartItem.quantity = updateCartDto.quantity;

    await this.cartItemRepository.save(cartItem);

    return this.getCart(restaurantId);
  }

  // =========================
  // REMOVE ITEM
  // =========================

  async removeFromCart(
    restaurantId: string,
    productId: string,
  ) {
    const cart = await this.cartRepository.findOne({
      where: { restaurantId },
    });

    if (!cart) {
      throw new NotFoundException('Cart not found');
    }

    const cartItem = await this.cartItemRepository.findOne({
      where: {
        cartId: cart.id,
        productId,
      },
    });

    if (!cartItem) {
      throw new NotFoundException(
        'Product is not in your cart',
      );
    }

    await this.cartItemRepository.remove(cartItem);

    return this.getCart(restaurantId);
  }

  // =========================
  // CLEAR CART
  // =========================

  async clearCart(restaurantId: string) {
    const cart = await this.cartRepository.findOne({
      where: { restaurantId },
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

  // =========================
  // FORMAT CART
  // =========================

  private formatCart(cart: Cart) {
    const items = cart.items ?? [];

    const formattedItems = items.map((item) => ({
      id: item.id,
      productId: item.productId,
      productName: item.product?.name,
      imageUrl: item.product?.imageUrls,
      quantity: Number(item.quantity),
      unitPrice: Number(item.unitPrice),
      subtotal:
        Number(item.quantity) * Number(item.unitPrice),
    }));

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
    };
  }
}