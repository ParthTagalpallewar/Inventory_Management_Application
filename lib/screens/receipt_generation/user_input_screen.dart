import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory_management_software/screens/app_drawer.dart';
import 'package:inventory_management_software/screens/receipt_generation/select_inventory_screen.dart';

class UserInputScreen extends StatefulWidget {
  const UserInputScreen({super.key});

  @override
  State<UserInputScreen> createState() => _UserInputScreenState();
}

class _UserInputScreenState extends State<UserInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quotationToController = TextEditingController();
  final _addressController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _gstinController = TextEditingController();

  @override
  void dispose() {
    _quotationToController.dispose();
    _addressController.dispose();
    _mobileController.dispose();
    _gstinController.dispose();
    super.dispose();
  }

  void _goToNextScreen() {
    if (_formKey.currentState!.validate()) {
      Get.off(SelectInventoryScreen(
        name: _quotationToController.text,
        address: _addressController.text,
        emailAddress: _emailController.text,
        mobile: _mobileController.text,
        gstin: _gstinController.text,
      ),);






    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("User Details")),
      drawer: AppDrawer(),
      body: Center(
        child: SizedBox(
          width: 500,
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _quotationToController,
                    decoration: const InputDecoration(labelText: 'Quotation To (Name)'),
                    validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter a name' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: 'Address',
                      alignLabelWithHint: true, // aligns the label to the top-left
                      border: OutlineInputBorder(), // optional: makes it visually distinct for multiline
                    ),
                    maxLines: 4, // allows 4 lines, adjust as needed
                    minLines: 2,
                    validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter an address' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Email Address'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an email address';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Enter a valid email address';
                      }
                      return null;
                    },
                  ),


                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _mobileController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(labelText: 'Mobile Number'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a mobile number';
                      }
                      if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                        return 'Enter a valid 10-digit number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _gstinController,
                    decoration: const InputDecoration(
                      labelText: 'GSTIN Number (optional)',
                    ),
                  ),
                  const SizedBox(height: 50),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _goToNextScreen,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary, // optional, uses your theme
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(7), // adjust the radius as needed
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16), // optional for height
                      ),
                      child: const Text(
                        'Select Inventory',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
