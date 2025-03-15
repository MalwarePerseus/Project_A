// lib/features/subscription/providers/subscription_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SubscriptionPlan {
  final String id;
  final String title;
  final String description;
  final double price;
  final String billingPeriod;
  final int discount;

  SubscriptionPlan({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.billingPeriod,
    this.discount = 0,
  });
}

class SubscriptionPlansNotifier
    extends StateNotifier<AsyncValue<List<SubscriptionPlan>>> {
  SubscriptionPlansNotifier() : super(const AsyncValue.loading()) {
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    try {
      // In a real app, this would load from an API
      // For this example, we'll use a hardcoded list
      await Future.delayed(Duration(milliseconds: 500)); // Simulate loading

      final plans = [
        SubscriptionPlan(
          id: 'monthly',
          title: 'Monthly',
          description: 'Billed monthly',
          price: 4.99,
          billingPeriod: 'per month',
        ),
        SubscriptionPlan(
          id: 'yearly',
          title: 'Yearly',
          description: 'Billed annually',
          price: 39.99,
          billingPeriod: 'per year',
          discount: 33, // 33% off compared to monthly
        ),
        SubscriptionPlan(
          id: 'lifetime',
          title: 'Lifetime',
          description: 'One-time payment',
          price: 99.99,
          billingPeriod: 'forever',
          discount: 50, // Compared to 2 years of annual
        ),
      ];

      state = AsyncValue.data(plans);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final subscriptionPlansProvider = StateNotifierProvider<
  SubscriptionPlansNotifier,
  AsyncValue<List<SubscriptionPlan>>
>((ref) {
  return SubscriptionPlansNotifier();
});
