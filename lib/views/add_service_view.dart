import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../viewmodels/add_service_view_model.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController? controller;
  final bool isMultiline;
  final Widget? suffixIcon;
  final bool readOnly;
  final VoidCallback? onTap;

  const CustomTextField({
    super.key,
    required this.label,
    required this.hint,
    this.controller,
    this.isMultiline = false,
    this.suffixIcon,
    this.readOnly = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: isMultiline ? 4 : 1,
          readOnly: readOnly,
          onTap: onTap,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppTheme.buttonColor),
            ),
          ),
        ),
      ],
    );
  }
}

class AddServiceView extends StatelessWidget {
  const AddServiceView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AddServiceViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Services & Pricing'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Business logo section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(16),
                        image: DecorationImage(
                          image: viewModel.selectedImagePath.isNotEmpty
                              ? (viewModel.selectedImagePath.startsWith('http')
                                        ? NetworkImage(
                                            viewModel.selectedImagePath,
                                          )
                                        : FileImage(
                                            File(viewModel.selectedImagePath),
                                          ))
                                    as ImageProvider
                              : const NetworkImage(
                                  'https://picsum.photos/seed/mechanic/200/200',
                                ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      child: GestureDetector(
                        onTap: viewModel.pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: AppTheme.accentColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Business logo',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textDark,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            CustomTextField(
              label: 'Service Name',
              hint: 'enter business name',
              controller: viewModel.serviceNameController,
            ),
            const SizedBox(height: 16),

            CustomTextField(
              label: 'Category',
              hint: 'select category',
              readOnly: true,
              controller: viewModel.categoryController,
              onTap: () => viewModel.selectCategory(context),
              suffixIcon: const Icon(
                Icons.keyboard_arrow_down,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),

            CustomTextField(
              label: 'Sub-category',
              hint: 'select sub-category',
              readOnly: true,
              controller: viewModel.subCategoryController,
              onTap: () => viewModel.selectSubCategory(context),
              suffixIcon: const Icon(
                Icons.keyboard_arrow_down,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),

            CustomTextField(
              label: 'Price',
              hint: 'enter basic price',
              controller: viewModel.priceController,
            ),
            const SizedBox(height: 16),

            CustomTextField(
              label: 'Discount (optional)',
              hint: 'enter discount',
              controller: viewModel.discountController,
            ),
            const SizedBox(height: 16),

            CustomTextField(
              label: 'Duration',
              hint: 'enter duration',
              controller: viewModel.durationController,
            ),
            const SizedBox(height: 16),

            CustomTextField(
              label: 'About Business',
              hint: 'description',
              controller: viewModel.descriptionController,
              isMultiline: true,
            ),
            const SizedBox(height: 80), // padding for bottom button
          ],
        ),
      ),
      bottomSheet: Container(
        color: AppTheme.backgroundColor,
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () => viewModel.saveAndContinue(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.buttonColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: const Text(
              'SAVE & CONTINUE',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
