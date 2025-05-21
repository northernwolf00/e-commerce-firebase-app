import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;

class CreateMarkedsProductsScreen extends StatefulWidget {
  final String? shopId;
  final Map<String, dynamic>? existingData;

  CreateMarkedsProductsScreen({this.existingData, required this.shopId});

  @override
  _CreateMarkedsProductsScreen createState() =>
      _CreateMarkedsProductsScreen();
}

class _CreateMarkedsProductsScreen extends State<CreateMarkedsProductsScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _discountController = TextEditingController();
  final _countController = TextEditingController();
  final _priceController = TextEditingController();
  String? _selectedCategory;
  DateTime? _selectedDate;
  File? _image;
  String? _existingImageUrl;
  bool _isSaving = false;

  final _categories = [
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

  @override
  void initState() {
    super.initState();
    if (widget.existingData != null) {
      _titleController.text = widget.existingData?['title'] ?? '';
      _discountController.text = widget.existingData?['discount'] ?? '';
      _descriptionController.text = widget.existingData?['description'] ?? '';
      _countController.text = widget.existingData?['count'] ?? '';
      _priceController.text = widget.existingData?['price'] ?? '';
      _selectedCategory = widget.existingData?['category'];
      _selectedDate = (widget.existingData?['date'] as Timestamp?)?.toDate();
      _existingImageUrl = widget.existingData?['imageUrl'];
    }
  }

  Future<void> _selectDateAndTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (time != null) {
        setState(() {
          _selectedDate = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadFileToGitHub(File file, String folder) async {


    try {
      final bytes = await file.readAsBytes();
      final base64File = base64Encode(bytes);
      final fileName = '$folder/${path.basename(file.path)}';

      final url = Uri.parse(
          'https://api.github.com/repos/$owner/$repo/contents/$fileName');

      final response = await http.put(
        url,
        headers: {
          'Authorization': 'token $token',
          'Accept': 'application/vnd.github.v3+json',
        },
        body: jsonEncode({
          'message': 'Upload file $fileName',
          'content': base64File,
          'branch': branch,
        }),
      );

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        return responseData['content']['download_url'];
      } else {
        print('Failed to upload file: ${response.statusCode}');
        print(response.body);
        return null;
      }
    } catch (e) {
      print('Error uploading file to GitHub: $e');
      return null;
    }
  }

  Future<void> _saveMarked() async {
    if (_image == null && _existingImageUrl == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Please select an image')));
      return;
    }

    setState(() {
      _isSaving = true;
    });

    String? imageUrl = _existingImageUrl;

    if (_image != null) {
      imageUrl = await _uploadFileToGitHub(_image!, 'images');
      if (imageUrl == null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to upload image')));
        setState(() {
          _isSaving = false;
        });
        return;
      }
    }

    final formattedDate = _selectedDate != null
        ? DateFormat('dd.MM.yyyy, HH:mm').format(_selectedDate!)
        : null;

    final productsData = {
      'title': _titleController.text.trim(),
      'discount': _discountController.text.trim(),
      'description': _descriptionController.text.trim(),
      'count': _countController.text.trim(),
      'price': _priceController.text.trim(),
      'category': _selectedCategory,
      'date': formattedDate.toString(),
      'imageUrl': imageUrl,
    };

    try {
      await FirebaseFirestore.instance
          .collection('markedLists')
          .doc(widget.shopId)
          .collection('products')
          .add(productsData);

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Product added successfully')));
      Navigator.pop(context);
    } catch (e) {
      print('Failed to save: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to save: $e')));
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Save Product')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 6,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                      labelText: 'Title', border: OutlineInputBorder()),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: _discountController,
                  decoration: InputDecoration(
                      labelText: 'Discount %', border: OutlineInputBorder()),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: _priceController,
                  decoration: InputDecoration(
                      labelText: 'Price', border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 12),
                TextField(
                  controller: _countController,
                  decoration: InputDecoration(
                      labelText: 'Count', border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 12),
                TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                      labelText: 'Description', border: OutlineInputBorder()),
                  maxLines: 3,
                ),
                SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  items: _categories
                      .map((category) => DropdownMenuItem(
                          value: category, child: Text(category)))
                      .toList(),
                  onChanged: (value) =>
                      setState(() => _selectedCategory = value),
                  decoration: InputDecoration(
                      labelText: 'Category', border: OutlineInputBorder()),
                ),
                SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _selectDateAndTime,
                  icon: Icon(Icons.calendar_today),
                  label: Text(_selectedDate == null
                      ? 'Select Date'
                      : 'Selected: ${DateFormat('dd.MM.yyyy, HH:mm').format(_selectedDate!)}'),
                ),
                SizedBox(height: 12),
                Center(
                  child: _image == null
                      ? (_existingImageUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                _existingImageUrl!,
                                height: 150,
                                width: 150,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Text('No image selected',
                              style: TextStyle(color: Colors.grey)))
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(_image!,
                              height: 150, width: 150, fit: BoxFit.cover),
                        ),
                ),
                SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: Icon(Icons.image),
                  label: Text('Pick Image'),
                ),
                SizedBox(height: 20),
                Center(
                  child: _isSaving
                      ? CircularProgressIndicator()
                      : ElevatedButton.icon(
                          onPressed: _saveMarked,
                          icon: Icon(Icons.save),
                          label: Text('Save Product'),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
