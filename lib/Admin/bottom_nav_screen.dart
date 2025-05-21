import 'package:flutter/material.dart';
import 'package:shop_app_admin/Admin/all_products.dart';
import 'package:shop_app_admin/Admin/get_order.dart';

import 'package:shop_app_admin/Admin/home_fireabse.dart';
import 'package:shop_app_admin/Admin/list_banners_screen.dart';

class BottomNavScreen extends StatefulWidget {
  @override
  _BottomNavScreenState createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  int _currentIndex = 0;
  final _screens = [
    NewsHome(),
    AllProductsHome(),
    OrdersListScreen(),
    BannerListScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: Colors.green.shade700,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.green.shade100,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.store_mall_directory),
            label: 'Shops',
          ),
           BottomNavigationBarItem(
            icon: Icon(Icons.shopping_basket_sharp),
            label: 'All Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'All Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.image),
            label: 'Banners',
          ),
        ],
      ),
    );
  }
}
