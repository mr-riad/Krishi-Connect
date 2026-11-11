// ignore_for_file: use_build_context_synchronously
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import '../../gen/colors.gen.dart';
import '../../services/api_service.dart';

class PostCropScreen extends StatefulWidget {
  final VoidCallback? onBack;
  const PostCropScreen({super.key, this.onBack});

  @override
  State<PostCropScreen> createState() => _PostCropScreenState();
}

class _PostCropScreenState extends State<PostCropScreen> {
  static const Color primaryGreen = AppColors.primaryGreen;
  static const Color bgColor = AppColors.bgColor;

  final _cropNameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  final _districtController = TextEditingController();
  final _upazilaController = TextEditingController();
  final _descController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;

  // unit mapping: display → API value
  final Map<String, String> _unitMap = {
    'কেজি': 'kg',
    'মণ': 'mon',
    'টন': 'ton',
    'বস্তা': 'bag',
  };

  // category mapping: display → API value
  final Map<String, String> _categoryMap = {
    'ধান': 'paddy',
    'সবজি': 'vegetable',
    'ফল': 'fruit',
    'ডাল': 'pulse',
    'মসলা': 'spice',
    'অন্যান্য': 'other',
  };

  String _selectedUnit = 'কেজি';
  String _selectedCategory = 'অন্যান্য';
  bool _isSubmitting = false;
  String? _errorMsg;

  @override
  void dispose() {
    _cropNameController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _districtController.dispose();
    _upazilaController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final img = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      if (img != null) {
        setState(() => _selectedImage = img);
      }
    } catch (e) {
      if (kDebugMode) print('Error picking image: $e');
    }
  }

  Future<void> _handleSubmit() async {
    final cropName = _cropNameController.text.trim();
    final quantityStr = _quantityController.text.trim();
    final priceStr = _priceController.text.trim();
    final district = _districtController.text.trim();

    if (cropName.isEmpty || quantityStr.isEmpty || priceStr.isEmpty || district.isEmpty) {
      setState(() => _errorMsg = 'ফসলের নাম, পরিমাণ, দাম ও জেলা অবশ্যই দিতে হবে');
      return;
    }

    final quantity = double.tryParse(quantityStr);
    final price = double.tryParse(priceStr);

    if (quantity == null || quantity <= 0) {
      setState(() => _errorMsg = 'সঠিক পরিমাণ লিখুন');
      return;
    }
    if (price == null || price <= 0) {
      setState(() => _errorMsg = 'সঠিক দাম লিখুন');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMsg = null;
    });

    try {
      List<String> photoUrls = [];

      // Upload photo to Firebase Storage if selected
      if (_selectedImage != null) {
        try {
          final uid = FirebaseAuth.instance.currentUser?.uid ?? 'anon';
          final ts = DateTime.now().millisecondsSinceEpoch;
          final ref = FirebaseStorage.instance
              .ref()
              .child('listings/$uid/$ts.jpg');
          final bytes = await _selectedImage!.readAsBytes();
          final uploadTask = await ref.putData(
            bytes,
            SettableMetadata(contentType: 'image/jpeg'),
          );
          final downloadUrl = await uploadTask.ref.getDownloadURL();
          photoUrls.add(downloadUrl);
        } catch (storageErr) {
          if (kDebugMode) print('Firebase Storage upload failed: $storageErr');
        }
      }

      final body = {
        'crop_name': cropName,
        'category': _categoryMap[_selectedCategory] ?? 'other',
        'quantity': quantity,
        'unit': _unitMap[_selectedUnit] ?? 'kg',
        'price_per_unit': price,
        'district': district,
        if (_upazilaController.text.trim().isNotEmpty)
          'upazila': _upazilaController.text.trim(),
        if (_descController.text.trim().isNotEmpty)
          'description': _descController.text.trim(),
        'photo_urls': photoUrls,
      };

      await KrishiApiService.instance.createListing(body);

      if (!mounted) return;
      setState(() => _isSubmitting = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$cropName এর পোস্ট সফলভাবে প্রকাশিত হয়েছে!'),
          backgroundColor: primaryGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
        ),
      );

      _cropNameController.clear();
      _quantityController.clear();
      _priceController.clear();
      _districtController.clear();
      _upazilaController.clear();
      _descController.clear();
      setState(() {
        _selectedCategory = 'অন্যান্য';
        _selectedImage = null;
      });
    } on DioException catch (dioErr) {
      if (!mounted) return;
      final status = dioErr.response?.statusCode;
      final responseData = dioErr.response?.data;
      final serverDetail = responseData is Map
          ? (responseData['detail']?.toString())
          : responseData?.toString();

      String msg = 'পোস্ট প্রকাশ করতে সমস্যা হয়েছে (ত্রুটি $status)';
      if (status == 401) {
        msg = 'অথেনটিকেশন ব্যর্থ (401): ${serverDetail ?? "টোকেন নেই বা মেয়াদোত্তীর্ণ"}';
      } else if (status == 403) {
        msg = 'অনুমতি নেই (403): শুধুমাত্র কৃষক অ্যাকাউন্টে পোস্ট করা যাবে।';
      } else if (status == 422) {
        msg = 'তথ্য সঠিক নয় (422): ${serverDetail ?? "সব প্রয়োজনীয় ঘর পূরণ করুন"}';
      } else if (status == 500) {
        msg = 'সার্ভার ত্রুটি (500 Internal Server Error): ${serverDetail ?? "ব্যাকএন্ডে সমস্যা হয়েছে। Render Logs চেক করুন।"}';
      } else if (serverDetail != null && serverDetail.isNotEmpty) {
        msg = serverDetail;
      }

      setState(() {
        _isSubmitting = false;
        _errorMsg = msg;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _errorMsg = 'সমস্যা: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 6.h),
              Text(
                'ফসল বিক্রির পোস্ট',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF111827),
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'আপনার ফসলের তথ্য দিন, ক্রেতারা যোগাযোগ করবেন',
                style: TextStyle(fontSize: 13.sp, color: const Color(0xFF6B7280)),
              ),

              if (_errorMsg != null) ...[
                SizedBox(height: 12.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Text(
                    _errorMsg!,
                    style: TextStyle(fontSize: 13.sp, color: Colors.red.shade700),
                  ),
                ),
              ],

              SizedBox(height: 18.h),

              // Image Upload Container
              _buildLabel('ফসলের ছবি (ঐচ্ছিক)'),
              SizedBox(height: 8.h),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 130.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: const Color(0xFFD1D5DB), width: 1.5),
                  ),
                  child: _selectedImage != null
                      ? Stack(
                          fit: StackFit.expand,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(15.r),
                              child: kIsWeb
                                  ? Image.network(_selectedImage!.path, fit: BoxFit.cover)
                                  : Image.file(File(_selectedImage!.path), fit: BoxFit.cover),
                            ),
                            Positioned(
                              top: 8.h,
                              right: 8.w,
                              child: GestureDetector(
                                onTap: () => setState(() => _selectedImage = null),
                                child: Container(
                                  padding: EdgeInsets.all(6.w),
                                  decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close, color: Colors.white, size: 16),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 44.w,
                              height: 44.w,
                              decoration: const BoxDecoration(
                                color: Color(0xFFF0FDF4),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.add_a_photo_outlined,
                                  color: primaryGreen, size: 22.sp),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              'ফসলের ছবি যোগ করুন (Firebase Storage)',
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: const Color(0xFF6B7280),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              SizedBox(height: 18.h),

              // Category selector
              _buildLabel('ফসলের ধরন'),
              SizedBox(height: 8.h),
              _buildDropdown(
                value: _selectedCategory,
                items: _categoryMap.keys.toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedCategory = val);
                },
              ),
              SizedBox(height: 18.h),

              // Crop name
              _buildLabel('ফসলের নাম *'),
              SizedBox(height: 8.h),
              _buildInput(
                controller: _cropNameController,
                hint: 'যেমন: বোরো ধান, আলু, পেঁয়াজ',
                icon: Icons.grass_outlined,
              ),
              SizedBox(height: 18.h),

              // Quantity & Unit
              _buildLabel('পরিমাণ ও একক *'),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: _buildInput(
                      controller: _quantityController,
                      hint: 'পরিমাণ',
                      icon: Icons.scale_outlined,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    flex: 2,
                    child: _buildDropdown(
                      value: _selectedUnit,
                      items: _unitMap.keys.toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedUnit = val);
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 18.h),

              // Price
              _buildLabel('প্রত্যাশিত দাম (৳/একক) *'),
              SizedBox(height: 8.h),
              _buildInput(
                controller: _priceController,
                hint: 'যেমন: ৩৫',
                icon: Icons.currency_exchange_rounded,
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 18.h),

              // District
              _buildLabel('জেলা *'),
              SizedBox(height: 8.h),
              _buildInput(
                controller: _districtController,
                hint: 'যেমন: রাজশাহী, বগুড়া',
                icon: Icons.location_city_outlined,
              ),
              SizedBox(height: 18.h),

              // Upazila
              _buildLabel('উপজেলা (ঐচ্ছিক)'),
              SizedBox(height: 8.h),
              _buildInput(
                controller: _upazilaController,
                hint: 'যেমন: বাগমারা, শিবগঞ্জ',
                icon: Icons.location_on_outlined,
              ),
              SizedBox(height: 18.h),

              // Description
              _buildLabel('বিস্তারিত (ঐচ্ছিক)'),
              SizedBox(height: 8.h),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: TextField(
                  controller: _descController,
                  maxLines: 3,
                  style: TextStyle(fontSize: 14.sp, color: const Color(0xFF111827)),
                  decoration: InputDecoration(
                    hintText: 'ফসলের মান, গ্রেড বা বিশেষ তথ্য লিখুন...',
                    hintStyle: TextStyle(fontSize: 13.sp, color: const Color(0xFF9CA3AF)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(14.w),
                  ),
                ),
              ),

              SizedBox(height: 28.h),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 52.h,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                  ),
                  child: _isSubmitting
                      ? SizedBox(
                          width: 24.w,
                          height: 24.w,
                          child: const CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5),
                        )
                      : Text(
                          'পোস্ট প্রকাশ করুন',
                          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
                        ),
                ),
              ),

              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF1F2937),
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(
          fontSize: 14.sp,
          color: const Color(0xFF111827),
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(fontSize: 13.sp, color: const Color(0xFF9CA3AF)),
          prefixIcon: Icon(icon, color: const Color(0xFF6B7280), size: 20.sp),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          style: TextStyle(
            fontSize: 14.sp,
            color: const Color(0xFF111827),
            fontWeight: FontWeight.w600,
          ),
          items: items.map((item) {
            return DropdownMenuItem(value: item, child: Text(item));
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
