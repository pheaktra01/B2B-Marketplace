import 'package:mobile/features/auth/screens/verify_phone_screen.dart';
import 'package:mobile/features/cart/models/cart_model.dart';

class VerifyPhoneArgs {
  final VerificationType type;
  final String phoneNumber;
  final String? selectedRole;
  final String? userId;
  final String? initialOtp;
  final String? password;

  const VerifyPhoneArgs({
    required this.type,
    required this.phoneNumber,
    this.selectedRole,
    this.userId,
    this.initialOtp,
    this.password,
  });
}

class ResetPasswordArgs {
  final String phoneNumber;
  final String otp;

  const ResetPasswordArgs({
    required this.phoneNumber,
    required this.otp,
  });
}

class ChatConversationArgs {
  final String conversationId;
  final String participantName;
  final String? participantAvatarUrl;
  final bool isOnline;

  const ChatConversationArgs({
    required this.conversationId,
    required this.participantName,
    this.participantAvatarUrl,
    this.isOnline = false,
  });
}

class CheckoutArgs {
  final Cart cart;
  final String deliveryAddress;
  final String deliveryNotes;

  const CheckoutArgs({
    required this.cart,
    required this.deliveryAddress,
    this.deliveryNotes = '',
  });
}

class PaymentMethodArgs {
  final Cart cart;
  final String deliveryNotes;

  const PaymentMethodArgs({
    required this.cart,
    this.deliveryNotes = '',
  });
}
