import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocery/ShowProductDetailScreen.dart';
import 'package:grocery/views/home/components/popular_packs.dart';

class MarkedsHome extends StatefulWidget {
  final String? shopId;
  final String title;

  MarkedsHome({required this.title, required this.shopId, super.key});

  @override
  State<MarkedsHome> createState() => _MarkedsHomeState();
}

class _MarkedsHomeState extends State<MarkedsHome> {
  bool _isProductInCart(String productId) {
    return cartItems.any((item) => item['id'] == productId);
  }

  void _addToCart(Map<String, dynamic> product, String productId) {
    setState(() {
      cartItems.add({...product, 'id': productId});
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Added to cart!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.shopId == null) {
      return const Scaffold(
        body: Center(child: Text("Shop ID not found")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('markedLists')
              .doc(widget.shopId)
              .collection('products')
              // .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text(
                  'No products added yet.',
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            final products = snapshot.data!.docs;

            return Padding(
              padding: const EdgeInsets.all(10),
              child: GridView.builder(
                itemCount: products.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.75,
                ),
                itemBuilder: (context, index) {
                  final product = products[index];
                  final productId = product.id;
                  final productData = product.data() as Map<String, dynamic>;
                  final isInCart = _isProductInCart(productId);
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ShowProductDetailScreen(
                            productId: productId,
                            productData: productData,
                            isInCart: isInCart,
                            addToCart: () => _addToCart(productData, productId),
                          ),
                        ),
                      );
                    },
                    child: Card(
                      color: isInCart ? Colors.white : null,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      elevation: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(15)),
                              child: productData['imageUrl'] != null
                                  ? Image.network(
                                      productData['imageUrl'],
                                      width: double.infinity,
                                      height: 200,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      width: double.infinity,
                                      color: Colors.grey.shade300,
                                      child: const Icon(Icons.image,
                                          size: 50, color: Colors.grey),
                                    ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Text(
                              productData['title'] ?? 'No Name',
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Row(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 5.0),
                                child: Text(
                                  'Discount: ',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 5.0),
                                child: Text(
                                  productData['discount'] ?? 'No Date',
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 5.0),
                            child: Text(
                              productData['price'] + " TMT" ?? 'No Date',
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 16),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  _addToCart(productData, productId);
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                  backgroundColor:
                                      isInCart ? Colors.grey : null,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.shopping_cart,
                                        size: 16,
                                        color: isInCart ? Colors.white : null),
                                    const SizedBox(width: 4),
                                    Text(isInCart ? 'In Cart' : 'Add to Cart',
                                        style: TextStyle(
                                            color: isInCart
                                                ? Colors.white
                                                : null)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
