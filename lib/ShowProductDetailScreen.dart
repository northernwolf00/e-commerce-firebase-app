import 'package:flutter/material.dart';
import 'package:grocery/views/home/components/popular_packs.dart';

class ShowProductDetailScreen extends StatefulWidget {
  final String productId;
  final Map<String, dynamic> productData;
  final bool isInCart;
  final VoidCallback addToCart;

  const ShowProductDetailScreen({
    super.key,
    required this.productId,
    required this.productData,
    required this.isInCart,
    required this.addToCart,
  });

  @override
  State<ShowProductDetailScreen> createState() =>
      _ShowProductDetailScreenState();
}

class _ShowProductDetailScreenState extends State<ShowProductDetailScreen> {
  late bool _isInCart;

  @override
  void initState() {
    super.initState();
    _isInCart = widget.isInCart;
  }

  void _handleAddToCart() {
    if (!_isInCart) {
      widget.addToCart();
      setState(() {
        _isInCart = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Added to cart!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text(widget.productData['title'] ?? 'Product Detail')),
      body: Column(
        children: [
          // Top section
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: widget.productData['imageUrl'] != null
                      ? Image.network(
                          widget.productData['imageUrl'],
                          height: 250,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          height: 250,
                          color: Colors.grey.shade300,
                          child: const Icon(Icons.image, size: 50),
                        ),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.productData['title'] ?? '',
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Discount: ',
                        style: TextStyle(color: Colors.grey)),
                    Text(
                      widget.productData['discount'] ?? '0%',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${widget.productData['price']} TMT',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),

          // Bottom: Add to Cart
          Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _handleAddToCart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isInCart ? Colors.grey : Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shopping_cart,
                        size: 18, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      _isInCart ? 'In Cart' : 'Add to Cart',
                      style: const TextStyle(
                          color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

