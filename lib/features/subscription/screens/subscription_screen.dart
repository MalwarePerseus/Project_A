// lib/features/subscription/screens/subscription_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_a/features/subscription/providers/subscription_provider.dart';
// Add this import for isPremiumUserProvider
import 'package:project_a/features/settings/screens/settings_screen.dart';

class SubscriptionScreen extends ConsumerStatefulWidget {
  @override
  _SubscriptionScreenState createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends ConsumerState<SubscriptionScreen> {
  int _selectedPlanIndex = 1; // Default to yearly plan
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final subscriptionPlans = ref.watch(subscriptionPlansProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Premium Subscription')),
      body: subscriptionPlans.when(
        data: (plans) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Center(
                  child: Column(
                    children: [
                      Icon(Icons.star, size: 64, color: Colors.amber),
                      SizedBox(height: 16),
                      Text(
                        'Upgrade to Premium',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Unlock all features and enjoy an ad-free experience',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 32),

                // Feature list
                Text(
                  'Premium Features',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                _buildFeatureItem(
                  icon: Icons.music_note,
                  title: 'All Premium Sounds',
                  description: 'Access our complete library of sleep sounds',
                ),
                _buildFeatureItem(
                  icon: Icons.ad_units_outlined,
                  title: 'Ad-Free Experience',
                  description: 'No more interruptions during your sleep',
                ),
                _buildFeatureItem(
                  icon: Icons.analytics,
                  title: 'Advanced Sleep Analytics',
                  description:
                      'Get detailed insights about your sleep patterns',
                ),
                _buildFeatureItem(
                  icon: Icons.backup,
                  title: 'Cloud Backup',
                  description: 'Sync your alarms and sleep data across devices',
                ),
                SizedBox(height: 32),

                // Subscription plans
                Text(
                  'Choose Your Plan',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                for (int i = 0; i < plans.length; i++)
                  _buildSubscriptionPlanCard(
                    plan: plans[i],
                    isSelected: _selectedPlanIndex == i,
                    onTap: () {
                      setState(() {
                        _selectedPlanIndex = i;
                      });
                    },
                  ),
                SizedBox(height: 32),

                // Subscribe button
                ElevatedButton(
                  onPressed:
                      _isLoading
                          ? null
                          : () => _subscribe(plans[_selectedPlanIndex]),
                  child:
                      _isLoading
                          ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : Text('Subscribe Now'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                  ),
                ),
                SizedBox(height: 16),

                // Terms and privacy
                Center(
                  child: Text(
                    'By subscribing, you agree to our Terms of Service and Privacy Policy.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ),
                SizedBox(height: 8),
                Center(
                  child: Text(
                    'Subscriptions will automatically renew unless canceled at least 24 hours before the end of the current period.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ),
                SizedBox(height: 32),

                // Restore purchases
                Center(
                  child: TextButton(
                    onPressed: _isLoading ? null : _restorePurchases,
                    child: Text('Restore Purchases'),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error:
            (error, stack) =>
                Center(child: Text('Error loading subscription plans: $error')),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              // Fixed: Replace withOpacity with withAlpha
              color: Theme.of(
                context,
              ).colorScheme.primary.withAlpha(26), // 0.1 * 255 ≈ 26
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionPlanCard({
    required SubscriptionPlan plan,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color:
              isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.transparent,
          width: 2,
        ),
      ),
      elevation: isSelected ? 4 : 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Radio<bool>(
                value: true,
                groupValue: isSelected,
                onChanged: (_) => onTap(),
                activeColor: Theme.of(context).colorScheme.primary,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          plan.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(width: 8),
                        if (plan.discount > 0)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'SAVE ${plan.discount}%',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      plan.description,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${plan.price.toStringAsFixed(2)}',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  Text(
                    plan.billingPeriod,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _subscribe(SubscriptionPlan plan) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // In a real app, this would initiate the purchase process
      // using in_app_purchase package
      await Future.delayed(Duration(seconds: 2)); // Simulate API call

      // Update premium status
      ref.read(isPremiumUserProvider.notifier).state = true;

      // Show success dialog
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text('Subscription Successful'),
              content: Text(
                'Thank you for subscribing to Premium! You now have access to all features.',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context); // Go back to previous screen
                  },
                  child: Text('OK'),
                ),
              ],
            ),
      );
    } catch (e) {
      // Show error dialog
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text('Subscription Failed'),
              content: Text(
                'There was an error processing your subscription: $e',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('OK'),
                ),
              ],
            ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _restorePurchases() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // In a real app, this would check for existing purchases
      // using in_app_purchase package
      await Future.delayed(Duration(seconds: 2)); // Simulate API call

      // Show result dialog
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text('Restore Purchases'),
              content: Text('No previous purchases found.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('OK'),
                ),
              ],
            ),
      );
    } catch (e) {
      // Show error dialog
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text('Restore Failed'),
              content: Text('There was an error restoring your purchases: $e'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('OK'),
                ),
              ],
            ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
