import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';


class OrdersListScreen extends StatelessWidget {
  const OrdersListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ordersRef = FirebaseFirestore.instance
        .collection('orderproducts')
        .orderBy('userId');
        // .orderBy('orderedAt', descending: true);

    return Scaffold(
      appBar: AppBar(title: const Text("All Orders (Grouped by User)")),
      body: StreamBuilder<QuerySnapshot>(
        stream: ordersRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData ) {
            return const Center(child: Text("No orders found"));
          }

          final docs = snapshot.data!.docs;
          final Map<String, List<QueryDocumentSnapshot>> groupedOrders = {};

          // Group by userId
          for (var doc in docs) {
            final data = doc.data() as Map<String, dynamic>;
            final userId = data['userId'] ?? 'Unknown';
            groupedOrders.putIfAbsent(userId, () => []).add(doc);
          }

          return ListView(
            children: groupedOrders.entries.map((entry) {
              final userId = entry.key;
              final orders = entry.value;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'User: $userId',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Divider(thickness: 1),
                  ...orders.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;

                    return ListTile(
                      leading: Image.network(
                        data['imageUrl'] ?? '',
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                      title: Text(data['title'] ?? 'No Title'),
                      subtitle: Text('Price: ${data['price']}'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                OrderDetailScreen(orderData: data),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ],
              );
            }).toList(),
          );
        },
      ),
    );
  }
}





class OrderDetailScreen extends StatelessWidget {
  final Map<String, dynamic> orderData;

  const OrderDetailScreen({super.key, required this.orderData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Order Details")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            if (orderData['imageUrl'] != null)
              Image.network(orderData['imageUrl'], height: 200),
            const SizedBox(height: 16),
            Text("Title: ${orderData['title']}", style: const TextStyle(fontSize: 18)),
            Text("Category: ${orderData['category'] ?? 'Home'}"),
            Text("Description: ${orderData['description'] ?? '-'}"),
            Text("Price: ${orderData['price']}"),
            Text("Discount: ${orderData['discount']}"),
            Text("Count: ${orderData['count']}"),
            Text("Date: ${orderData['date']}"),
            Text("User ID: ${orderData['userId']}"),
          ],
        ),
      ),
    );
  }
}


