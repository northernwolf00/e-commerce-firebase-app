import 'package:flutter/material.dart';
import 'package:grocery/ShowProductDetailScreen.dart';

import '../../../core/components/bundle_tile_square.dart';
import '../../../core/components/title_and_action_button.dart';
import '../../../core/constants/constants.dart';
import '../../../core/routes/app_routes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

List<Map<String, dynamic>> cartItems = [];

class AllProductsHome extends StatefulWidget {
  const AllProductsHome({Key? key}) : super(key: key);

  @override
  State<AllProductsHome> createState() => _AllProductsHomeState();
}

class _AllProductsHomeState extends State<AllProductsHome> {
  final List<String> _categories = [
    'All',
    'Baby',
    'Electronics',
    'Fashion',
    'Beauty',
    'Home',
    'Sports',
    'Toys',
    'Groceries',
    'Education',
    'Automotive',
  ];

  String selectedCategory = 'All';

  void _addToCart(Map<String, dynamic> product, String productId) {
    setState(() {
      cartItems.add({...product, 'id': productId});
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Added to cart!')),
    );
  }

  bool _isProductInCart(String productId) {
    return cartItems.any((item) => item['id'] == productId);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 2000,
      child: Column(
        children: [
          // Categories List
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        selectedCategory = category;
                      });
                    },
                  ),
                );
              },
            ),
          ),

          // Product Grid
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: selectedCategory == 'All'
                  ? FirebaseFirestore.instance
                      .collection('all_products')
                      .snapshots()
                  : FirebaseFirestore.instance
                      .collection('all_products')
                      .where('category', isEqualTo: selectedCategory)
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'No products added yet.',
                      style: TextStyle(color: Colors.black),
                    ),
                  );
                }

                final products = snapshot.data!.docs;

                return Padding(
                  padding: const EdgeInsets.all(10),
                  child: GridView.builder(
                    itemCount: products.length,
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.65,
                    ),
                    itemBuilder: (context, index) {
                      final product = products[index];
                      final productId = product.id;
                      final productData =
                          product.data() as Map<String, dynamic>;
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
                                addToCart: () =>
                                    _addToCart(productData, productId),
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
                                  const Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 5.0),
                                    child: Text(
                                      'Discount:',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5.0),
                                    child: Text(
                                      productData['discount'] ?? '0%',
                                      style: const TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 5.0),
                                child: Text(
                                  '${productData['price']} TMT',
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
                                      if (!isInCart) {
                                        _addToCart(productData, productId);
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      backgroundColor:
                                          isInCart ? Colors.grey : null,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.shopping_cart,
                                            size: 16,
                                            color:
                                                isInCart ? Colors.white : null),
                                        const SizedBox(width: 4),
                                        Text(
                                          isInCart ? 'In Cart' : 'Add to Cart',
                                          style: TextStyle(
                                              color: isInCart
                                                  ? Colors.white
                                                  : null),
                                        ),
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
        ],
      ),
    );
  }
}
