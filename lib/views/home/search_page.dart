import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:grocery/views/home/components/popular_packs.dart';

import '../../core/components/app_back_button.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_defaults.dart';
import '../../core/constants/app_icons.dart';
import '../../core/routes/app_routes.dart';
import '../../core/utils/ui_util.dart';
import 'dialogs/product_filters_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


// class SearchPage extends StatelessWidget {
//   const SearchPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const Scaffold(
//       body: SafeArea(
//         child: Column(
//           children: [
//             SearchAllProductsScreen(),
//             SizedBox(height: 8),
//             // _RecentSearchList(),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _RecentSearchList extends StatelessWidget {
//   const _RecentSearchList();

//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       child: Column(
//         children: [
//           Padding(
//             padding:
//                 const EdgeInsets.symmetric(horizontal: AppDefaults.padding),
//             child: Align(
//               alignment: Alignment.centerLeft,
//               child: Text(
//                 'Recent Search',
//                 style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//                       color: Colors.black,
//                     ),
//               ),
//             ),
//           ),
//           Expanded(
//             child: ListView.separated(
//               padding: const EdgeInsets.only(top: 16),
//               itemBuilder: (context, index) {
//                 return const SearchHistoryTile();
//               },
//               separatorBuilder: (context, index) => const Divider(
//                 thickness: 0.1,
//               ),
//               itemCount: 16,
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }

// class _SearchPageHeader extends StatelessWidget {
//   const _SearchPageHeader();

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(AppDefaults.padding),
//       child: Row(
//         children: [
//           const AppBackButton(),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Stack(
//               children: [
//                 /// Search Box
//                 Form(
//                   child: TextFormField(
//                     decoration: InputDecoration(
//                       hintText: 'Search',
//                       prefixIcon: Padding(
//                         padding: const EdgeInsets.all(AppDefaults.padding),
//                         child: SvgPicture.asset(
//                           AppIcons.search,
//                           colorFilter: const ColorFilter.mode(
//                             AppColors.primary,
//                             BlendMode.srcIn,
//                           ),
//                         ),
//                       ),
//                       prefixIconConstraints: const BoxConstraints(),
//                       contentPadding: EdgeInsets.zero,
//                       constraints: const BoxConstraints(),
//                     ),
//                     textInputAction: TextInputAction.search,
//                     autofocus: true,
//                     onChanged: (String? value) {},
//                     onFieldSubmitted: (v) {
//                       Navigator.pushNamed(context, AppRoutes.searchResult);
//                     },
//                   ),
//                 ),
              
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }



// Assuming this list is accessible globally or passed appropriately


class SearchAllProductsScreen extends StatefulWidget {
  const SearchAllProductsScreen({super.key});

  @override
  State<SearchAllProductsScreen> createState() => _SearchAllProductsScreenState();
}

class _SearchAllProductsScreenState extends State<SearchAllProductsScreen> {
  String _searchQuery = '';
  Future<QuerySnapshot>? _searchResultsFuture;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _searchProducts(_searchController.text);
  }

  void _searchProducts(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isNotEmpty) {
        _searchResultsFuture = FirebaseFirestore.instance
            .collection('all_products')
            .where('title', isGreaterThanOrEqualTo: query)
            .where('title', isLessThan: query + 'z')
            .get();
      } else {
        _searchResultsFuture = null;
      }
    });
  }

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
    return Scaffold(
       appBar: AppBar(
        title: 
         
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search Products',
                border: InputBorder.none,
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchProducts('');
                          });
                        },
                      )
                    : null,
              ),
              onSubmitted: _searchProducts,
            ),
          
        ),
      ),
      body: _searchQuery.isEmpty
          ? const Center(
              child: Text('Enter a search term to find products.'),
            )
          : FutureBuilder<QuerySnapshot>(
              future: _searchResultsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(_searchQuery.isNotEmpty ? 'No products found for "$_searchQuery".' : ''),
                  );
                }

                final searchResults = snapshot.data!.docs;

                return Padding(
                  padding: const EdgeInsets.all(10),
                  child: GridView.builder(
                    itemCount: searchResults.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.65,
                    ),
                    itemBuilder: (context, index) {
                      final product = searchResults[index];
                      final productId = product.id;
                      final productData = product.data() as Map<String, dynamic>;
                      final isInCart = _isProductInCart(productId);
                      return Card(
                        color: isInCart ? Colors.white : null,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
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
                                        child: const Icon(Icons.image, size: 50, color: Colors.grey),
                                      ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Text(
                                productData['title'] ?? 'No Name',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Row(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 5.0),
                                  child: Text(
                                    'Discount: ',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                                  child: Text(
                                    productData['discount'] ?? 'No Date',
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 5.0),
                              child: Text(
                                '${productData['price'] ?? '0'} TMT',
                                style: const TextStyle(color: Colors.black, fontSize: 16),
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
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    backgroundColor: isInCart ? Colors.grey : null,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.shopping_cart, size: 16, color: isInCart ? Colors.white : null),
                                      const SizedBox(width: 4),
                                      Text(isInCart ? 'In Cart' : 'Add to Cart', style: TextStyle(color: isInCart ? Colors.white : null)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}

