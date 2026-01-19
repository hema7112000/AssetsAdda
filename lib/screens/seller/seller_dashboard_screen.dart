// lib/screens/seller/seller_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_360/data/models/property_model.dart';
import 'package:real_estate_360/providers/auth_provider.dart'; // Assuming you have this
import 'package:real_estate_360/providers/seller_provider.dart';
import 'package:real_estate_360/widgets/common/property_card.dart'; // We can reuse this
import 'package:real_estate_360/widgets/common/app_scaffold.dart';

class SellerDashboardScreen extends ConsumerWidget {
  const SellerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authNotifier = ref.read(authProvider.notifier);
    final user = ref.watch(currentUserProvider);
    final sellerPropertiesAsync = ref.watch(sellerProvider);

    return AppScaffold(
    //   appBar: AppBar(
        title: 'My Properties (${user?.name ?? 'Seller'})',
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () => context.push('/profile'),
          ),
        ],
    //   ),
      body: sellerPropertiesAsync.when(
        data: (properties) {
          if (properties.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('You have no listings yet.', style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => context.push('/seller/add-property'),
                    child: const Text('Post Your First Property'),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: properties.length,
            itemBuilder: (context, index) {
              final property = properties[index];
              return _buildPropertyCard(context, ref, property);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Text('Error loading properties: $err'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/seller/add-property'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildPropertyCard(BuildContext context, WidgetRef ref, Property property) {
    // We can create a more specific card for sellers later
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to an edit/view detail screen
          // context.push('/seller/edit-property/${property.id}');
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              // Image thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  property.imageUrls.isNotEmpty ? property.imageUrls.first : 'assets/images/placeholder.png',
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(width: 80, height: 80, color: Colors.grey[300]),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(property.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text('\$${property.price.toStringAsFixed(0)}', style: const TextStyle(color: Colors.blue, fontSize: 14)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _buildStatusChip(property.status),
                        const Spacer(),
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              // context.push('/seller/edit-property/${property.id}');
                            } else if (value == 'delete') {
                              _showDeleteDialog(context, ref, property);
                            }
                          },
                          itemBuilder: (BuildContext context) => [
                            const PopupMenuItem(value: 'edit', child: Text('Edit')),
                            const PopupMenuItem(value: 'delete', child: Text('Delete')),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(PropertyStatus status) {
    Color color;
    String text;
    switch (status) {
      case PropertyStatus.approved:
        color = Colors.green;
        text = 'Approved';
        break;
      case PropertyStatus.rejected:
        color = Colors.red;
        text = 'Rejected';
        break;
      case PropertyStatus.pending:
      default:
        color = Colors.orange;
        text = 'Pending';
        break;
    }
    return Chip(
      label: Text(text, style: const TextStyle(color: Colors.white, fontSize: 12)),
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, Property property) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Property'),
        content: Text('Are you sure you want to delete "${property.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ref.read(sellerProvider.notifier).deleteProperty(property.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Property deleted')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}