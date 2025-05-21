import 'package:flutter/material.dart';
import 'package:grocery/views/menu/show_products.dart';

import '../../core/constants/constants.dart';
import '../../core/routes/app_routes.dart';
import 'components/category_tile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 32),
          Text(
            'Markeds',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
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
                    onSelected: (_) {
                      setState(() {
                        selectedCategory = category;
                      });
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          CateogoriesGrid(selectedCategory: selectedCategory),
        ],
      ),
    );
  }
}


class CateogoriesGrid extends StatelessWidget {
  final String selectedCategory;

  const CateogoriesGrid({super.key, required this.selectedCategory});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: selectedCategory == 'All'
            ? FirebaseFirestore.instance.collection('markedLists').snapshots()
            : FirebaseFirestore.instance
                .collection('markedLists')
                .where('category', isEqualTo: selectedCategory)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No shops added yet.', style: TextStyle(color: Colors.white)),
            );
          }

          final markedLists = snapshot.data!.docs;

          return Padding(
            padding: const EdgeInsets.all(10),
            child: GridView.builder(
              itemCount: markedLists.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.75,
              ),
              itemBuilder: (context, index) {
                final marked = markedLists[index];
                final markedId = marked.id;
                final markedData = marked.data() as Map<String, dynamic>;

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MarkedsHome(
                          shopId: markedId,
                          title: markedData['title'] ?? 'No Name',
                        ),
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      SizedBox(
                        height: 100,
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                            side: const BorderSide(color: Colors.green, width: 1),
                          ),
                          elevation: 5,
                          child: Column(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(30),
                                  child: markedData['imageUrl'] != null
                                      ? Image.network(
                                          markedData['imageUrl'],
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              const Icon(Icons.broken_image),
                                        )
                                      : Container(
                                          color: Colors.grey.shade300,
                                          child: const Icon(Icons.image, size: 50, color: Colors.grey),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          markedData['title'] ?? 'No Name',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
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
