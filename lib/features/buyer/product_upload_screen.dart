import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../gen/colors.gen.dart';

class ProductUploadScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const ProductUploadScreen({super.key, this.onBack});

  @override
  State<ProductUploadScreen> createState() => _ProductUploadScreenState();
}

class _ProductUploadScreenState extends State<ProductUploadScreen> {
  static const Color primaryGreen = AppColors.primaryGreen;
  static const Color bgColor = AppColors.bgColor;

  final TextEditingController _cropNameController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();
  final TextEditingController _demandController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();

  @override
  void dispose() {
    _cropNameController.dispose();
    _rateController.dispose();
    _demandController.dispose();
    _locationController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final cropName = _cropNameController.text.trim();
    final rate = _rateController.text.trim();
    final demand = _demandController.text.trim();

    if (cropName.isEmpty || rate.isEmpty || demand.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'অনুগ্রহ করে ফসলের নাম, দর এবং চাহিদা পূরণ করুন',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
      );
      return;
    }

    // Success feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'দর সফলভাবে প্রকাশ করা হয়েছে: $cropName (৳$rate, $demand)',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: primaryGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
      ),
    );

    _cropNameController.clear();
    _rateController.clear();
    _demandController.clear();
    _locationController.clear();
    _durationController.clear();
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
              // Top Bar with Badge (B-02 · ক্রেতা)
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2FE),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    "B-02 · ক্রেতা",
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0284C7),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 8.h),

              // Back button + Title
              Row(
                children: [
                  InkWell(
                    onTap: () {
                      if (widget.onBack != null) {
                        widget.onBack!();
                      } else if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
                    },
                    borderRadius: BorderRadius.circular(22.r),
                    child: Container(
                      width: 44.w,
                      height: 44.w,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 18,
                          color: Color(0xFF111827),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 14.w),
                  Text(
                    "ক্রয়ের দর পোস্ট",
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF111827),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),

              // Field 1: ফসলের নাম
              _buildFieldLabel("ফসলের নাম"),
              SizedBox(height: 8.h),
              _buildInputField(
                controller: _cropNameController,
                hintText: "[ফসল]",
              ),
              SizedBox(height: 18.h),

              // Field 2 & 3: দর & চাহিদা
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFieldLabel("দর"),
                        SizedBox(height: 8.h),
                        _buildInputField(
                          controller: _rateController,
                          hintText: "৳ [দর]",
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFieldLabel("চাহিদা"),
                        SizedBox(height: 8.h),
                        _buildInputField(
                          controller: _demandController,
                          hintText: "[পরিমাণ]",
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 18.h),

              // Field 4: ক্রয়ের লোকেশন
              _buildFieldLabel("ক্রয়ের লোকেশন"),
              SizedBox(height: 8.h),
              _buildInputField(
                controller: _locationController,
                hintText: "জেলা, উপজেলা",
              ),
              SizedBox(height: 18.h),

              // Field 5: মেয়াদ
              _buildFieldLabel("মেয়াদ"),
              SizedBox(height: 8.h),
              _buildInputField(
                controller: _durationController,
                hintText: "[তারিখ পর্যন্ত]",
              ),
              SizedBox(height: 28.h),

              // Submit Button: দর প্রকাশ করুন
              SizedBox(
                width: double.infinity,
                height: 52.h,
                child: ElevatedButton(
                  onPressed: _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  child: Text(
                    "দর প্রকাশ করুন",
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF1F2937),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
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
          hintText: hintText,
          hintStyle: TextStyle(
            fontSize: 14.sp,
            color: const Color(0xFF9CA3AF),
            fontWeight: FontWeight.normal,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
        ),
      ),
    );
  }
}
