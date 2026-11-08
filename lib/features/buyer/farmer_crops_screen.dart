import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../gen/colors.gen.dart';
import '../../helpers/call_helper.dart';

class FarmerCropsScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const FarmerCropsScreen({super.key, this.onBack});

  @override
  State<FarmerCropsScreen> createState() => _FarmerCropsScreenState();
}

class _FarmerCropsScreenState extends State<FarmerCropsScreen> {
  static const Color primaryGreen = AppColors.primaryGreen;
  static const Color bgColor = AppColors.bgColor;

  int _selectedCategoryIndex = 0;

  final List<Map<String, String>> _categories = const [
    {"label": "সব", "type": "all"},
    {"label": "ধান", "type": "paddy"},
    {"label": "সবজি", "type": "vegetable"},
  ];

  final List<Map<String, String>> _allCrops = const [
    {
      "crop": "বোরো ধান",
      "quantity": "৫০০ কেজি",
      "farmer": "মো: রফিকুল",
      "location": "বাগমারা",
      "expectedPrice": "৩৫",
      "type": "paddy",
      "phone": "01712-345678",
    },
    {
      "crop": "গোল আলু",
      "quantity": "৩০০ কেজি",
      "farmer": "আকমল হোসেন",
      "location": "শিবগঞ্জ",
      "expectedPrice": "২৫",
      "type": "vegetable",
      "phone": "01819-234567",
    },
    {
      "crop": "দেশি পেঁয়াজ",
      "quantity": "২০০ কেজি",
      "farmer": "জামাল উদ্দিন",
      "location": "ঈশ্বরদী",
      "expectedPrice": "৭৫",
      "type": "vegetable",
      "phone": "01723-456789",
    },
    {
      "crop": "পাকা টমেটো",
      "quantity": "১৫০ কেজি",
      "farmer": "করিম মিয়া",
      "location": "পবা",
      "expectedPrice": "৪০",
      "type": "vegetable",
      "phone": "01914-567890",
    },
    {
      "crop": "আমন ধান",
      "quantity": "৪০০ কেজি",
      "farmer": "নুরুল ইসলাম",
      "location": "দুপচাঁচিয়া",
      "expectedPrice": "৩৮",
      "type": "paddy",
      "phone": "01735-678901",
    },
  ];

  List<Map<String, String>> get _filteredCrops {
    final type = _categories[_selectedCategoryIndex]["type"]!;
    if (type == "all") return _allCrops;
    return _allCrops.where((item) => item["type"] == type).toList();
  }

  void _openCallDialog(Map<String, String> crop) {
    showDirectCallBottomSheet(
      context: context,
      name: crop["farmer"] ?? "কৃষক",
      phone: crop["phone"] ?? "01712-345678",
      roleOrType: "কৃষক",
      subtitle: "${crop["crop"]} (${crop["quantity"]}) · আশা ৳${crop["expectedPrice"]}/কেজি",
      location: crop["location"],
    );
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
              // Top Bar with Badge (B-03 · ক্রেতা)
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2FE),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    "B-03 · ক্রেতা",
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0284C7),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 8.h),

              // Header: Back Button + Title
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
                    "কৃষকদের ফসল",
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF111827),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),

              // Circular Category Chips: সব, ধান, সবজি
              Row(
                children: List.generate(_categories.length, (index) {
                  final isSelected = _selectedCategoryIndex == index;
                  final item = _categories[index];

                  return Padding(
                    padding: EdgeInsets.only(right: 12.w),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedCategoryIndex = index;
                        });
                      },
                      borderRadius: BorderRadius.circular(25.r),
                      child: Container(
                        width: 50.w,
                        height: 50.w,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? primaryGreen
                                : const Color(0xFFE5E7EB),
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 3,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            item["label"]!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: isSelected
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                              color: isSelected
                                  ? primaryGreen
                                  : const Color(0xFF374151),
                              height: 1.1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              SizedBox(height: 22.h),

              // Crop Cards List
              ..._filteredCrops.map((crop) => _buildCropCard(crop)),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCropCard(Map<String, String> crop) {
    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Crop Details (Left)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${crop["crop"]} · ${crop["quantity"]}",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF111827),
                  ),
                ),
                SizedBox(height: 5.h),
                Text(
                  "${crop["farmer"]} · ${crop["location"]} · আশা ৳${crop["expectedPrice"]}",
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),

          // Call Button (Right)
          ElevatedButton.icon(
            onPressed: () => _openCallDialog(crop),
            icon: Icon(Icons.phone_in_talk_rounded, size: 16.sp),
            label: Text(
              "সরাসরি কল",
              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGreen,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
