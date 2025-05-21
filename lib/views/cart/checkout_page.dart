import 'package:flutter/material.dart';
import 'package:grocery/views/entrypoint/entrypoint_ui.dart';
import 'package:grocery/views/home/components/popular_packs.dart';
import 'package:grocery/views/home/home_page.dart';

import '../../core/components/app_back_button.dart';
import '../../core/constants/app_defaults.dart';
import '../../core/routes/app_routes.dart';
import 'components/checkout_address_selector.dart';
import 'components/checkout_card_details.dart';
import 'components/checkout_payment_systems.dart';

import '../../views/profile/payment_method/payment_method_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {

  int? selectedCardIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Checkout'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Pay with Altyn Asyr Card',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                ElevatedButton.icon(
                  onPressed: () async {
                    final newCard = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AddCardScreen()),
                    );
                    if (newCard != null) {
                      setState(() {
                        cards.add(newCard);
                      });
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: const Text("Add Card"),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: cards.length,
              itemBuilder: (context, index) {
                final isSelected = selectedCardIndex == index;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCardIndex = index;
                    });
                  },
                  child: Card(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                        : Colors.white,
                    elevation: isSelected ? 4 : 1,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey.shade300,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.credit_card),
                      title: Text(cards[index]),
                      trailing: isSelected
                          ? Icon(Icons.check_circle,
                              color: Theme.of(context).colorScheme.primary)
                          : null,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            PayNowButton(
              
            ),
          ],
        ),
      ),
    );
  }
}



class PayNowButton extends StatelessWidget {
  const PayNowButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          try {
            final user = FirebaseAuth.instance.currentUser;
            if (user == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('User not logged in.')),
              );
              return;
            }

            final firestore = FirebaseFirestore.instance;

            for (var item in cartItems) {
              await firestore.collection('orderproducts').add({
                ...item,
                'userId': user.uid,
                'orderedAt': FieldValue.serverTimestamp(),
              });
            }

            cartItems.clear();

            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => EntryPointUI()),
              (Route<dynamic> route) => false,
            );

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Payment Successful!')),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Payment failed: $e')),
            );
          }
        },
        child: const Text('Pay Now'),
      ),
    );
  }
}

