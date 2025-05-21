import 'package:flutter/material.dart';


import 'profile_header_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        /// Background
        Image.asset('assets/images/profile_page_background.png'),

        /// Content
        Column(
          children: [
            AppBar(
              title: const Text('Profile'),
              elevation: 0,
              backgroundColor: Colors.transparent,
              titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const _UserData(),
            // const ProfileHeaderOptions()
          ],
        ),
      ],
    );
  }
}



class _UserData extends StatelessWidget {
  const _UserData();

  @override
  Widget build(BuildContext context) {
    final User? finalUser = FirebaseAuth.instance.currentUser;

    return Padding(
      padding: const EdgeInsets.all(16.0), // Use a concrete value instead of AppDefaults if not available here
      child: Row(
        children: [
          const SizedBox(width: 16), // Use a concrete value
          SizedBox(
            width: 100,
            height: 100,
            child: ClipOval(
              child: AspectRatio(
                aspectRatio: 1 / 1,
                child: Icon(
                  Icons.person,
                  size: 100,
                  color: Colors.grey[300]!, // Use a concrete color
                ),
              ),
            ),
          ),
          const SizedBox(width: 16), // Use a concrete value
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                finalUser?.displayName ?? 'Guest User', // Display name from Firebase or default
               style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                'ID: ${finalUser?.uid.substring(0, 8) ?? 'N/A'}...', // Partial UID or N/A
                
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                'Email: ${finalUser?.email ?? 'N/A'}', // Email or N/A
               style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: Colors.white),
              ),
              // You can add more user data here if available in finalUser
            ],
          )
        ],
      ),
    );
  }
}


// class _UserData extends StatelessWidget {
//   const _UserData();

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(AppDefaults.padding),
//       child: Row(
//         children: [
//           const SizedBox(width: AppDefaults.padding),
//           const SizedBox(
//             width: 100,
//             height: 100,
//             child: ClipOval(
//               child: AspectRatio(
//                   aspectRatio: 1 / 1,
//                   child: Icon(
//                     Icons.person,
//                     size: 100,
//                     color: Colors.white,
//                   )),
//             ),
//           ),
//           const SizedBox(width: AppDefaults.padding),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Aziz',
                
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 'ID: 1540580',
                
//               ),
//             ],
//           )
//         ],
//       ),
//     );
//   }
// }
