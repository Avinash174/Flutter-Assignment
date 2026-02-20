import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/category_model.dart';
import '../models/sub_category_model.dart';
import '../models/service_model.dart';
import '../providers/api_provider.dart';

class AddServiceViewModel extends ChangeNotifier {
  final serviceNameController = TextEditingController();
  final priceController = TextEditingController();
  final discountController = TextEditingController();
  final durationController = TextEditingController();
  final descriptionController = TextEditingController();

  CategoryModel? selectedCategory;
  SubCategoryModel? selectedSubCategory;

  final categoryController = TextEditingController();
  final subCategoryController = TextEditingController();

  String selectedImagePath = '';
  String editServiceId = '';

  List<CategoryModel> categories = [];
  List<SubCategoryModel> subCategories = [];

  AddServiceViewModel() {
    fetchCategories();
  }

  void initAddMode() {
    editServiceId = '';
    serviceNameController.clear();
    priceController.clear();
    discountController.clear();
    durationController.clear();
    descriptionController.clear();
    categoryController.clear();
    subCategoryController.clear();
    selectedCategory = null;
    selectedSubCategory = null;
    selectedImagePath = '';
    notifyListeners();
  }

  Future<void> initEditMode(ServiceModel service) async {
    editServiceId = service.id;
    serviceNameController.text = service.serviceName;
    priceController.text = service.price.toString();
    durationController.text = service.duration.toString();
    descriptionController.text = service.description;

    categoryController.text = service.categoryName;
    subCategoryController.text = service.subCategoryName;
    selectedImagePath = service.imageUrl;

    if (service.categoryId.isNotEmpty) {
      selectedCategory = CategoryModel(
        id: service.categoryId,
        name: service.categoryName,
      );
      await fetchSubCategories(service.categoryId);
    }

    if (service.subCategoryId.isNotEmpty) {
      selectedSubCategory = SubCategoryModel(
        id: service.subCategoryId,
        name: service.subCategoryName,
        categoryId: service.categoryId,
      );
    }

    notifyListeners();
  }

  Future<void> fetchCategories() async {
    final fetched = await ApiProvider.getCategories();
    categories = fetched;
    notifyListeners();
  }

  Future<void> fetchSubCategories(String categoryId) async {
    final fetched = await ApiProvider.getSubCategories(categoryId);
    subCategories = fetched;
    notifyListeners();
  }

  Future<void> pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        selectedImagePath = image.path;
        notifyListeners();
      }
    } catch (e) {
      log('Error picking image: $e');
    }
  }

  void selectCategory(BuildContext context) {
    if (categories.isEmpty) return;
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        color: Colors.white,
        child: ListView.builder(
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final cat = categories[index];
            return ListTile(
              title: Text(cat.name),
              onTap: () {
                selectedCategory = cat;
                categoryController.text = cat.name;
                selectedSubCategory = null; // reset subcategory
                subCategoryController.clear();
                subCategories.clear();
                Navigator.pop(context);
                notifyListeners();
                fetchSubCategories(cat.id);
              },
            );
          },
        ),
      ),
    );
  }

  void selectSubCategory(BuildContext context) {
    if (selectedCategory == null || subCategories.isEmpty) return;
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        color: Colors.white,
        child: ListView.builder(
          itemCount: subCategories.length,
          itemBuilder: (context, index) {
            final subCat = subCategories[index];
            return ListTile(
              title: Text(subCat.name),
              onTap: () {
                selectedSubCategory = subCat;
                subCategoryController.text = subCat.name;
                Navigator.pop(context);
                notifyListeners();
              },
            );
          },
        ),
      ),
    );
  }

  void saveAndContinue(BuildContext context) {
    if (selectedCategory == null || selectedSubCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select Category and Sub-category'),
        ),
      );
      return;
    }
    Navigator.pushNamed(
      context,
      '/booking-calendar',
      arguments: {
        if (editServiceId.isNotEmpty) 'id': editServiceId,
        'serviceName': serviceNameController.text,
        'description': descriptionController.text,
        'category': selectedCategory?.id ?? '', // backend might expect ID
        'subCategory': selectedSubCategory?.id ?? '',
        'price': int.tryParse(priceController.text) ?? 0,
        'duration': int.tryParse(durationController.text) ?? 0,
        'imagePath': selectedImagePath,
      },
    );
  }

  @override
  void dispose() {
    serviceNameController.dispose();
    priceController.dispose();
    discountController.dispose();
    durationController.dispose();
    descriptionController.dispose();
    categoryController.dispose();
    subCategoryController.dispose();
    super.dispose();
  }
}
