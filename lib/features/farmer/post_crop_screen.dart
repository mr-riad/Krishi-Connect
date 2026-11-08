import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../gen/colors.gen.dart';

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
  final _locationController = TextEditingController();
  final _descController = TextEditingController();

  String _selectedUnit = 'কেজি';
  final List<String> _units = ['কেজি', 'মণ', 'টন', 'বস্তা'];

  bool _isSubmitting = false;

  @override
  void dispose() {
    _cropNameController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    if (_cropNameController.text.trim().isEmpty ||
        _quantityController.text.trim().isEmpty ||
        _priceController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('ফসলের নাম, পরিমাণ ও দাম অবশ্যই দিতে হবে'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_cropNameController.text.trim()} এর পোস্ট সফলভাবে প্রকাশিত হয়েছে!'),
        backgroundColor: primaryGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
      ),
    );

    _cropNameController.clear();
    _quantityController.clear();
    _priceController.clear();
    _locationController.clear();
    _descController.clear();
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
              // Header
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
              SizedBox(height: 24.h),

              // Image Upload Box
              Container(
                width: double.infinity,
                height: 120.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: const Color(0xFFD1D5DB),
                    style: BorderStyle.solid,
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 44.w,
                      height: 44.w,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF0FDF4),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.add_photo_alternate_outlined,
                          color: primaryGreen, size: 24.sp),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'ফসলের ছবি যোগ করুন (ঐচ্ছিক)',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: const Color(0xFF6B7280),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20.h),

              // Field 1: ফসলের নাম
              _buildLabel('ফসলের নাম'),
              SizedBox(height: 8.h),
              _buildInput(
                controller: _cropNameController,
                hint: 'যেমন: বোরো ধান, আলু, পেঁয়াজ',
                icon: Icons.grass_outlined,
              ),
              SizedBox(height: 18.h),

              // Field 2 & 3: পরিমাণ & একক
              _buildLabel('পরিমাণ ও একক'),
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
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 14.w),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedUnit,
                          isExpanded: true,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: const Color(0xFF111827),
                            fontWeight: FontWeight.w600,
                          ),
                          items: _units.map((unit) {
                            return DropdownMenuItem(value: unit, child: Text(unit));
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedUnit = val);
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 18.h),

              // Field 4: প্রত্যাশিত দাম
              _buildLabel('প্রত্যাশিত দাম (৳/একক)'),
              SizedBox(height: 8.h),
              _buildInput(
                controller: _priceController,
                hint: 'যেমন: ৩৫',
                icon: Icons.currency_exchange_rounded,
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 18.h),

              // Field 5: লোকেশন
              _buildLabel('আপনার লোকেশন'),
              SizedBox(height: 8.h),
              _buildInput(
                controller: _locationController,
                hint: 'উপজেলা, জেলা',
                icon: Icons.location_on_outlined,
              ),
              SizedBox(height: 18.h),

              // Field 6: বিবরণ
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
}
