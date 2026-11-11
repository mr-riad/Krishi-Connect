// ignore_for_file: use_build_context_synchronously
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../gen/colors.gen.dart';
import '../../services/api_service.dart';

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
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _upazilaController = TextEditingController();

  final Map<String, String> _unitMap = {
    'কেজি': 'kg',
    'মণ': 'mon',
    'টন': 'ton',
    'বস্তা': 'bag',
  };

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
  int _validDays = 7;
  bool _isSubmitting = false;
  String? _errorMsg;

  @override
  void dispose() {
    _cropNameController.dispose();
    _rateController.dispose();
    _demandController.dispose();
    _districtController.dispose();
    _upazilaController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final cropName = _cropNameController.text.trim();
    final rateStr = _rateController.text.trim();
    final district = _districtController.text.trim();

    if (cropName.isEmpty || rateStr.isEmpty || district.isEmpty) {
      setState(() => _errorMsg = 'ফসলের নাম, দর এবং জেলা অবশ্যই দিতে হবে');
      return;
    }

    final rate = double.tryParse(rateStr);
    if (rate == null || rate <= 0) {
      setState(() => _errorMsg = 'সঠিক দর লিখুন');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMsg = null;
    });

    try {
      final body = <String, dynamic>{
        'crop_name': cropName,
        'category': _categoryMap[_selectedCategory] ?? 'other',
        'rate_per_unit': rate,
        'unit': _unitMap[_selectedUnit] ?? 'kg',
        'district': district,
        'valid_days': _validDays,
        if (_upazilaController.text.trim().isNotEmpty)
          'upazila': _upazilaController.text.trim(),
      };

      // Parse demand quantity if provided
      final demandStr = _demandController.text.trim();
      if (demandStr.isNotEmpty) {
        final demand = double.tryParse(demandStr);
        if (demand != null && demand > 0) {
          body['demand_quantity'] = demand;
          body['demand_unit'] = _unitMap[_selectedUnit] ?? 'kg';
        }
      }

      await KrishiApiService.instance.createRate(body);

      if (!mounted) return;
      setState(() => _isSubmitting = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$cropName এর দর সফলভাবে প্রকাশ হয়েছে!'),
          backgroundColor: primaryGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
        ),
      );

      _cropNameController.clear();
      _rateController.clear();
      _demandController.clear();
      _districtController.clear();
      _upazilaController.clear();
      setState(() {
        _selectedCategory = 'অন্যান্য';
        _validDays = 7;
      });
    } on DioException catch (dioErr) {
      if (!mounted) return;
      final status = dioErr.response?.statusCode;
      final responseData = dioErr.response?.data;
      final serverDetail = responseData is Map
          ? (responseData['detail']?.toString())
          : responseData?.toString();

      String msg = 'দর প্রকাশ করতে সমস্যা হয়েছে (ত্রুটি $status)';
      if (status == 401) {
        msg = 'অথেনটিকেশন ব্যর্থ (401 Unauthorized): দয়া করে পুনরায় লগইন করুন।';
      } else if (status == 403) {
        msg = 'অনুমতি নেই (403 Forbidden): শুধুমাত্র ক্রেতা অ্যাকাউন্টে ক্রয়ের দর প্রকাশ করা যাবে।';
      } else if (status == 422) {
        msg = 'তথ্য সঠিক নয় (422): ${serverDetail ?? "সব প্রয়োজনীয় ঘর পূরণ করুন"}';
      } else if (status == 500) {
        msg = 'সার্ভার ত্রুটি (500 Internal Server Error): ${serverDetail ?? "ব্যাকএন্ডে সমস্যা হয়েছে।"}';
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
              // Top Bar Badge
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2FE),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    "ক্রেতা · দর পোস্ট",
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
                        child: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Color(0xFF111827)),
                      ),
                    ),
                  ),
                  SizedBox(width: 14.w),
                  Text(
                    "ক্রয়ের দর পোস্ট",
                    style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w800, color: const Color(0xFF111827)),
                  ),
                ],
              ),

              if (_errorMsg != null) ...[
                SizedBox(height: 14.h),
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

              SizedBox(height: 20.h),

              // Category
              _buildFieldLabel("ফসলের ধরন"),
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
              _buildFieldLabel("ফসলের নাম *"),
              SizedBox(height: 8.h),
              _buildInputField(controller: _cropNameController, hintText: "যেমন: বোরো ধান, পেঁয়াজ"),
              SizedBox(height: 18.h),

              // Rate & Unit
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFieldLabel("ক্রয় দর (৳/একক) *"),
                        SizedBox(height: 8.h),
                        _buildInputField(
                          controller: _rateController,
                          hintText: "যেমন: ৩৮",
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFieldLabel("একক"),
                        SizedBox(height: 8.h),
                        _buildDropdown(
                          value: _selectedUnit,
                          items: _unitMap.keys.toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedUnit = val);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 18.h),

              // Demand
              _buildFieldLabel("চাহিদা (ঐচ্ছিক)"),
              SizedBox(height: 8.h),
              _buildInputField(
                controller: _demandController,
                hintText: "পরিমাণ",
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 18.h),

              // District
              _buildFieldLabel("জেলা *"),
              SizedBox(height: 8.h),
              _buildInputField(controller: _districtController, hintText: "যেমন: রাজশাহী, বগুড়া"),
              SizedBox(height: 18.h),

              // Upazila
              _buildFieldLabel("উপজেলা (ঐচ্ছিক)"),
              SizedBox(height: 8.h),
              _buildInputField(controller: _upazilaController, hintText: "যেমন: বাগমারা"),
              SizedBox(height: 18.h),

              // Validity
              _buildFieldLabel("মেয়াদ (দিন)"),
              SizedBox(height: 8.h),
              Row(
                children: [7, 14, 30].map((days) {
                  final selected = _validDays == days;
                  return Padding(
                    padding: EdgeInsets.only(right: 10.w),
                    child: GestureDetector(
                      onTap: () => setState(() => _validDays = days),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
                        decoration: BoxDecoration(
                          color: selected ? primaryGreen : Colors.white,
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(color: selected ? primaryGreen : const Color(0xFFE5E7EB)),
                        ),
                        child: Text(
                          '$days দিন',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                            color: selected ? Colors.white : const Color(0xFF374151),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
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
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                  ),
                  child: _isSubmitting
                      ? SizedBox(
                          width: 24.w,
                          height: 24.w,
                          child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                      : Text(
                          "দর প্রকাশ করুন",
                          style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w700),
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
      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: const Color(0xFF1F2937)),
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
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 3, offset: const Offset(0, 1)),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(fontSize: 14.sp, color: const Color(0xFF111827), fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(fontSize: 14.sp, color: const Color(0xFF9CA3AF), fontWeight: FontWeight.normal),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
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
          style: TextStyle(fontSize: 14.sp, color: const Color(0xFF111827), fontWeight: FontWeight.w600),
          items: items.map((item) {
            return DropdownMenuItem(value: item, child: Text(item));
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
