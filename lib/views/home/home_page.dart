import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:grocery/views/home/banner_widget.dart';
import '../../core/constants/app_icons.dart';

import '../../core/constants/app_defaults.dart';
import '../../core/routes/app_routes.dart';
import 'components/ad_space.dart';
import 'components/our_new_item.dart';
import 'components/popular_packs.dart';



class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Image.asset(
          "assets/images/app_logo.jpg",
          height: 40,
          width: 50,
          fit: BoxFit.cover,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8, top: 4, bottom: 4),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.search);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF2F6F3),
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(8),
              ),
              child: SvgPicture.asset(AppIcons.search),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 200,
                child: BannerCarousel(),
              ),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Products',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              AllProductsHome(),
              // Uncomment below if needed:
              // const Padding(
              //   padding: EdgeInsets.symmetric(vertical: 16.0),
              //   child: OurNewItem(),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

