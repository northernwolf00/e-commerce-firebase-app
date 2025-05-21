import 'package:flutter/material.dart';
import 'package:grocery/views/home/components/popular_packs.dart';

import '../../core/components/app_back_button.dart';
import '../../core/constants/app_defaults.dart';
import '../../core/routes/app_routes.dart';
import 'components/coupon_code_field.dart';
import 'components/items_totals_price.dart';
import 'components/single_cart_item_tile.dart';



class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  // Assume cartItems is a list of maps fetched or passed to this screen
 

  final Map<String, int> _itemQuantities = {};

  @override
  void initState() {
    super.initState();
    // Initialize quantities for each item in the cart
    for (final item in cartItems) {
      _itemQuantities[item['id'] as String] = 1;
    }
  }

  double get _totalPrice {
    double total = 0;
    for (final item in cartItems) {
      final price = double.tryParse(item['price'] ?? '0') ?? 0;
      final quantity = _itemQuantities[item['id'] as String] ?? 0;
      total += price * quantity;
    }
    return total;
  }

  void _incrementQuantity(String itemId) {
    setState(() {
      _itemQuantities[itemId] = (_itemQuantities[itemId] ?? 0) + 1;
    });
  }

  void _decrementQuantity(String itemId) {
    setState(() {
      if (_itemQuantities[itemId] != null && _itemQuantities[itemId]! > 1) {
        _itemQuantities[itemId] = _itemQuantities[itemId]! - 1;
      }
    });
  }

  void _removeItem(int index) {
    setState(() {
      final itemIdToRemove = cartItems[index]['id'];
      cartItems.removeAt(index);
      _itemQuantities.remove(itemIdToRemove);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: cartItems.isEmpty
          ? const Center(
              child: Text('Your cart is empty.', style: TextStyle(fontSize: 18)),
            )
          : ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final item = cartItems[index];
                final itemId = item['id'] as String;
                final quantity = _itemQuantities[itemId] ?? 0;
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 80,
                          height: 80,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: item['imageUrl'] != null
                                ? Image.network(
                                    item['imageUrl'],
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported),
                                  )
                                : Container(color: Colors.grey.shade300, child: const Icon(Icons.image, size: 30)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item['title'] ?? 'No Name', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              const SizedBox(height: 4),
                              Text('${item['price'] ?? '0'} TMT', style: const TextStyle(color: Colors.green)),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Text('Quantity:'),
                                  IconButton(
                                    icon: const Icon(Icons.remove),
                                    onPressed: () => _decrementQuantity(itemId),
                                  ),
                                  Text('$quantity', style: const TextStyle(fontSize: 16)),
                                  IconButton(
                                    icon: const Icon(Icons.add),
                                    onPressed: () => _incrementQuantity(itemId),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () => _removeItem(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: cartItems.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Total: ${_totalPrice.toStringAsFixed(2)} TMT', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0), // Removed AppDefaults for simplicity
                      child: ElevatedButton(
                        onPressed: () {
                          // Implement your checkout logic here
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Proceeding to checkout...')),
                          );
                           Navigator.pushNamed(context, AppRoutes.checkoutPage);
                          // Navigator.pushNamed(context, AppRoutes.orderSuccessfull);
                          // Navigator.pushNamed(context, AppRoutes.checkoutPage); // Avoid pushing to the same page
                        },
                        child: const Text('Proceed to Checkout'),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }
}
