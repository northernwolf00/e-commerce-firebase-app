// import 'package:flutter/material.dart';

// import '../../core/components/app_back_button.dart';
// import '../../core/constants/constants.dart';

// class ProfileEditPage extends StatelessWidget {
//   const ProfileEditPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.cardColor,
//       appBar: AppBar(
//         leading: const AppBackButton(),
//         title: const Text(
//           'Profile',
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Container(
//           margin: const EdgeInsets.all(AppDefaults.padding),
//           padding: const EdgeInsets.symmetric(
//             horizontal: AppDefaults.padding,
//             vertical: AppDefaults.padding * 2,
//           ),
//           decoration: BoxDecoration(
//             color: AppColors.scaffoldBackground,
//             borderRadius: AppDefaults.borderRadius,
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
            
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/components/app_back_button.dart';
import '../../core/constants/constants.dart';

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  User? _user;
  String? _displayName;
  String? _email;
  String? _photoURL;
  bool? _emailVerified;
  String? _uid;

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }

  Future<void> _fetchUserInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    setState(() {
      _user = user;
      _displayName = user?.displayName;
      _email = user?.email;
      _photoURL = user?.photoURL;
      _emailVerified = user?.emailVerified;
      _uid = user?.uid;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardColor,
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text(
          'Profile',
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(AppDefaults.padding),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDefaults.padding,
            vertical: AppDefaults.padding * 2,
          ),
          decoration: BoxDecoration(
            color: AppColors.scaffoldBackground,
            borderRadius: AppDefaults.borderRadius,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'User Information',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppDefaults.padding),
              ListTile(
                leading: const Icon(Icons.person),
                title: Text('Display Name'),
                subtitle: Text(_displayName ?? 'Not available'),
              ),
              ListTile(
                leading: const Icon(Icons.email),
                title: Text('Email'),
                subtitle: Text(_email ?? 'Not available'),
              ),
              ListTile(
                leading: const Icon(Icons.verified),
                title: Text('Email Verified'),
                subtitle: Text(_emailVerified == true ? 'Yes' : 'No'),
              ),
              ListTile(
                leading: const Icon(Icons.perm_identity),
                title: Text('User ID'),
                subtitle: Text(_uid ?? 'Not available'),
              ),
              if (_photoURL != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppDefaults.padding),
                    Text(
                      'Profile Picture',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppDefaults.padding / 2),
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: ClipRRect(
                      
                        child: Image.network(
                          _photoURL!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.broken_image);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: AppDefaults.padding),
              // Add more UI elements to edit user information here
            ],
          ),
        ),
      ),
    );
  }
}