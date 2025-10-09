import 'package:equatable/equatable.dart';

class Order extends Equatable {
  const Order({
    required this.id,
    required this.userId,
    this.serviceId,
    this.courseId,
    required this.amountCents,
    required this.currency,
    required this.status,
    this.stripeCheckoutId,
    this.stripePaymentIntent,
    this.metadata = const {},
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      userId: (json['user_id'] ?? '') as String,
      serviceId: json['service_id'] as String?,
      courseId: json['course_id'] as String?,
      amountCents: (json['amount_cents'] as num? ?? 0).toInt(),
      currency: (json['currency'] ?? 'sek') as String,
      status: (json['status'] ?? 'pending') as String,
      stripeCheckoutId: json['stripe_checkout_id'] as String?,
      stripePaymentIntent: json['stripe_payment_intent'] as String?,
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? const {}),
    );
  }

  final String id;
  final String userId;
  final String? serviceId;
  final String? courseId;
  final int amountCents;
  final String currency;
  final String status;
  final String? stripeCheckoutId;
  final String? stripePaymentIntent;
  final Map<String, dynamic> metadata;

  double get amount => amountCents / 100;

  @override
  List<Object?> get props => [
        id,
        userId,
        serviceId,
        courseId,
        amountCents,
        currency,
        status,
        stripeCheckoutId,
        stripePaymentIntent,
        metadata,
      ];
}
