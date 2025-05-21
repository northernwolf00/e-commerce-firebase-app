class ProductModel {
  final String category;
  final int count;
  final DateTime date;
  final String description;
  final String discount;
  final String imageUrl;
  final double price;
  final String title;

  ProductModel({
    required this.category,
    required this.count,
    required this.date,
    required this.description,
    required this.discount,
    required this.imageUrl,
    required this.price,
    required this.title,
  });

  factory ProductModel.fromFirestore(Map<String, dynamic> data) {
    return ProductModel(
      category: data['category'] as String? ?? '', // Provide default if null
      count: data['count']   ?? 0, // Handle potential parsing errors
      date: data['date'], // Helper function for date parsing
      description: data['description'] as String? ?? '',
      discount: data['discount'] as String? ?? '',
      imageUrl: data['imageUrl'] as String? ?? '',
      price: double.tryParse(data['price'] as String? ?? '') ?? 0.0, // Handle parsing errors
      title: data['title'] as String? ?? '',
    );
  }

  // Helper function to parse Firestore timestamp or string date
  // static DateTime _parseFirebaseTimestamp(dynamic dateData) {
  //   if (dateData is Timestamp) {
  //     return dateData.toDate();
  //   } else if (dateData is String) {
  //     // Attempt to parse the string format you provided
  //     try {
  //       return DateTime.parse(dateData.split(',')[0].trim());
  //     } catch (e) {
  //       print("Error parsing date: $e");
  //       return DateTime.now(); // Or handle the error as needed
  //     }
  //   }
  //   return DateTime.now(); // Default if the format is unexpected
  // }
}