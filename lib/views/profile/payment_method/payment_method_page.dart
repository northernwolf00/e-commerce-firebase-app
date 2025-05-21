import 'package:flutter/material.dart';

import '../../../core/constants/app_defaults.dart';

import '../../../core/components/app_back_button.dart';
import 'components/new_card_row.dart';
import 'components/default_card.dart';
import 'components/payment_option_tile.dart';

import 'package:flutter/material.dart';

import '../../../core/constants/app_defaults.dart';
import '../../../core/components/app_back_button.dart';

 List<String> cards = ['**** **** **** 1234'];
class PaymentMethodPage extends StatefulWidget {
  const PaymentMethodPage({super.key});

  @override
  State<PaymentMethodPage> createState() => _PaymentMethodPageState();
}

class _PaymentMethodPageState extends State<PaymentMethodPage> {

  void _addCard() {
    setState(() {
      cards.add('**** **** **** ${1000 + cards.length * 1234}');
    });
  }

  void _deleteCard(int index) {
    setState(() {
      cards.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Payment Option'),
      ),
      body: Column(
        children: [
          const SizedBox(height: AppDefaults.padding),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: AppDefaults.padding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'My Cards',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
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
          ),
          const SizedBox(height: AppDefaults.padding),
          Expanded(
            child: ListView.builder(
              itemCount: cards.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: AppDefaults.padding,
                    vertical: 8,
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.credit_card),
                    title: Text(cards[index]),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteCard(index),
                    ),
                  ),
                );
              },
            ),
          ),
        
        ],
      ),
    );
  }
}



class AddCardScreen extends StatefulWidget {
  const AddCardScreen({super.key});

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _nameController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  void _submitCard() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(
        context,
        '**** **** **** ${_cardNumberController.text.substring(_cardNumberController.text.length - 4)}',
      );
    }
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _nameController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add New Card")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Card UI Preview
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  colors: [Colors.green, Color(0xFF00C853)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.credit_card, color: Colors.white, size: 40),
                  const SizedBox(height: 20),
                  Text(
                    _cardNumberController.text.isEmpty
                        ? "**** **** **** ****"
                        : _cardNumberController.text,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 22, letterSpacing: 2),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _nameController.text.isEmpty
                            ? "Card Holder"
                            : _nameController.text.toUpperCase(),
                        style:
                            const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      Text(
                        _expiryController.text.isEmpty
                            ? "MM/YY"
                            : _expiryController.text,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  )
                ],
              ),
            ),

            // Card Input Form
            Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _cardNumberController,
                      keyboardType: TextInputType.number,
                      decoration:
                          const InputDecoration(labelText: "Card Number"),
                      maxLength: 19,
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            value.replaceAll(' ', '').length < 6) {
                          return 'Enter valid card number';
                        }
                        return null;
                      },
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 3),
                    TextFormField(
                      controller: _nameController,
                      decoration:
                          const InputDecoration(labelText: "Name on Card"),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter name';
                        }
                        return null;
                      },
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 3),
                    TextFormField(
                      controller: _expiryController,
                      decoration: const InputDecoration(
                          labelText: "Expiry Date (MM/YY)"),
                      keyboardType: TextInputType.datetime,
                      // validator: (value) {
                      //   if (value == null || value.isEmpty) {
                      //     return 'Enter expiry date';
                      //   }
                      //   return null;
                      // },
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _cvvController,
                      decoration: const InputDecoration(labelText: "CVV"),
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      maxLength: 4,
                      validator: (value) {
                        if (value == null || value.length < 3) {
                          return 'Enter CVV';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _submitCard,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text("Save Card"),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
