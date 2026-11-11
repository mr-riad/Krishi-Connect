// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../gen/colors.gen.dart';
import '../../helpers/call_helper.dart';
import '../../models/krishi_models.dart';
import '../../services/api_service.dart';
import '../shared/chat_screen.dart';

class BuyerRatesScreen extends StatefulWidget {
  const BuyerRatesScreen({super.key});

  @override
  State<BuyerRatesScreen> createState() => _BuyerRatesScreenState();
}

class _BuyerRatesScreenState extends State<BuyerRatesScreen> {
  static const Color primaryGreen = AppColors.primaryGreen;
  static const Color bgColor = AppColors.bgColor;

  final _searchController = TextEditingController();
  final _districtController = TextEditingController();

  int _selectedCategoryIndex = 0;
  String _sortBy = 'newest';
  bool _isLoading = false;
  String? _errorMsg;
  List<BuyerRate> _rates = [];

  final List<Map<String, String>> _categories = const [
    {"label": "সব", "type": ""},
    {"label": "ধান", "type": "paddy"},
    {"label": "সবজি", "type": "vegetable"},
    {"label": "ফল", "type": "fruit"},
    {"label": "ডাল", "type": "pulse"},
    {"label": "মসলা", "type": "spice"},
  ];

  final Map<String, String> _sortOptions = const {
    'newest': 'নতুন',
    'rate_desc': 'সর্বোচ্চ দর',
  };

  @override
  void initState() {
    super.initState();
    _fetchRates();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _districtController.dispose();
    super.dispose();
  }

  Future<void> _fetchRates() async {
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });
    try {
      final category = _categories[_selectedCategoryIndex]['type']!;
      final result = await KrishiApiService.instance.getRates(
        q: _searchController.text.trim().isEmpty ? null : _searchController.text.trim(),
        category: category.isEmpty ? null : category,
        district: _districtController.text.trim().isEmpty ? null : _districtController.text.trim(),
        sort: _sortBy,
        limit: 50,
      );
      if (!mounted) return;
      final items = (result['items'] as List<dynamic>?) ?? [];
      setState(() {
        _rates = items.map((e) => BuyerRate.fromJson(e as Map<String, dynamic>)).toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMsg = 'দর তালিকা লোড করতে সমস্যা হয়েছে। পুনরায় চেষ্টা করুন।';
      });
    }
  }

  Future<void> _callBuyer(BuyerRate rate) async {
    if (rate.buyerPhone != null && rate.buyerPhone!.isNotEmpty) {
      showDirectCallBottomSheet(
        context: context,
        phone: rate.buyerPhone!,
        name: rate.buyerName ?? rate.cropName,
      );
      return;
    }
    try {
      final callData = await KrishiApiService.instance
          .triggerCall(targetUid: rate.buyerId, rateId: rate.id);
      final phone = callData['phone'] as String?;
      if (phone != null && mounted) {
        showDirectCallBottomSheet(
          context: context,
          phone: phone,
          name: callData['target_name'] as String? ?? rate.buyerName ?? rate.cropName,
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ক্রেতার ফোন নম্বর পাওয়া যায়নি'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _startChat(BuyerRate rate) async {
    try {
      final conv = await KrishiApiService.instance.startConversation(
        participantId: rate.buyerId,
      );
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            conversationId: conv['id'] as String,
            peerName: rate.buyerName ?? 'ক্রেতা',
            peerPhone: rate.buyerPhone,
            listingTitle: '${rate.cropName} (দর: ৳${rate.ratePerUnit.toStringAsFixed(0)}/${rate.unitLabel})',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('চ্যাট শুরু করতে সমস্যা হয়েছে'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ক্রেতার দর বোর্ড',
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  IconButton(
                    onPressed: _fetchRates,
                    icon: Icon(Icons.refresh_rounded, color: primaryGreen, size: 22.sp),
                    tooltip: 'রিফ্রেশ',
                  ),
                ],
              ),
            ),

            // Search & District
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 0),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Container(
                      height: 44.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: TextStyle(fontSize: 13.sp),
                        onSubmitted: (_) => _fetchRates(),
                        decoration: InputDecoration(
                          hintText: 'ফসল খুঁজুন...',
                          hintStyle: TextStyle(fontSize: 13.sp, color: const Color(0xFF9CA3AF)),
                          prefixIcon: Icon(Icons.search, size: 18.sp, color: const Color(0xFF6B7280)),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    flex: 2,
                    child: Container(
                      height: 44.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: TextField(
                        controller: _districtController,
                        style: TextStyle(fontSize: 13.sp),
                        onSubmitted: (_) => _fetchRates(),
                        decoration: InputDecoration(
                          hintText: 'জেলা',
                          hintStyle: TextStyle(fontSize: 13.sp, color: const Color(0xFF9CA3AF)),
                          prefixIcon: Icon(Icons.location_on_outlined, size: 18.sp, color: const Color(0xFF6B7280)),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  GestureDetector(
                    onTap: _fetchRates,
                    child: Container(
                      height: 44.h,
                      width: 44.h,
                      decoration: BoxDecoration(
                        color: primaryGreen,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(Icons.search, color: Colors.white, size: 20.sp),
                    ),
                  ),
                ],
              ),
            ),

            // Category + Sort
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 0),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 36.h,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _categories.length,
                        separatorBuilder: (context, index) => SizedBox(width: 8.w),
                        itemBuilder: (ctx, i) {
                          final selected = i == _selectedCategoryIndex;
                          return GestureDetector(
                            onTap: () {
                              setState(() => _selectedCategoryIndex = i);
                              _fetchRates();
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                              decoration: BoxDecoration(
                                color: selected ? primaryGreen : Colors.white,
                                borderRadius: BorderRadius.circular(20.r),
                                border: Border.all(
                                    color: selected ? primaryGreen : const Color(0xFFE5E7EB)),
                              ),
                              child: Text(
                                _categories[i]['label']!,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  color: selected ? Colors.white : const Color(0xFF374151),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    height: 36.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _sortBy,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: const Color(0xFF374151),
                          fontWeight: FontWeight.w600,
                        ),
                        items: _sortOptions.entries.map((e) {
                          return DropdownMenuItem(value: e.key, child: Text(e.value));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _sortBy = val);
                            _fetchRates();
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 10.h),

            // Content List
            if (_isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (_errorMsg != null)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline, size: 40.sp, color: Colors.red.shade400),
                      SizedBox(height: 10.h),
                      Text(_errorMsg!, style: TextStyle(fontSize: 13.sp, color: Colors.red.shade600)),
                      SizedBox(height: 14.h),
                      ElevatedButton(
                        onPressed: _fetchRates,
                        style: ElevatedButton.styleFrom(backgroundColor: primaryGreen),
                        child: const Text('পুনরায় চেষ্টা করুন', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              )
            else if (_rates.isEmpty)
              Expanded(
                child: Center(
                  child: Text('কোনো দর পাওয়া যায়নি',
                      style: TextStyle(fontSize: 15.sp, color: const Color(0xFF6B7280))),
                ),
              )
            else
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _fetchRates,
                  color: primaryGreen,
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    itemCount: _rates.length,
                    itemBuilder: (ctx, i) => _buildRateCard(_rates[i]),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRateCard(BuyerRate rate) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(14.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rate.cropName,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF111827),
                        ),
                      ),
                      if (rate.buyerName != null) ...[
                        SizedBox(height: 2.h),
                        Text(
                          rate.buyerName!,
                          style: TextStyle(fontSize: 12.sp, color: const Color(0xFF6B7280)),
                        ),
                      ],
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '৳${rate.ratePerUnit.toStringAsFixed(0)}/${rate.unitLabel}',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                        color: primaryGreen,
                      ),
                    ),
                    Text(
                      rate.categoryLabel,
                      style: TextStyle(fontSize: 11.sp, color: const Color(0xFF6B7280)),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Wrap(
              spacing: 14.w,
              runSpacing: 4.h,
              children: [
                if (rate.demandQuantity != null)
                  _chip(Icons.inventory_2_outlined,
                      'চাহিদা: ${rate.demandQuantity!.toStringAsFixed(0)} ${rate.unitLabel}'),
                _chip(Icons.location_on_outlined, rate.locationLabel),
                _chip(Icons.timer_outlined, '${rate.validDays} দিন'),
              ],
            ),
            SizedBox(height: 12.h),

            // Action Buttons: Call and Chat
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: SizedBox(
                    height: 38.h,
                    child: ElevatedButton.icon(
                      onPressed: () => _callBuyer(rate),
                      icon: Icon(Icons.call_outlined, size: 16.sp),
                      label: Text('সরাসরি কল',
                          style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 38.h,
                    child: OutlinedButton.icon(
                      onPressed: () => _startChat(rate),
                      icon: Icon(Icons.chat_outlined, size: 16.sp),
                      label: Text('চ্যাট',
                          style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: primaryGreen,
                        side: const BorderSide(color: primaryGreen),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13.sp, color: const Color(0xFF6B7280)),
        SizedBox(width: 3.w),
        Text(label, style: TextStyle(fontSize: 12.sp, color: const Color(0xFF4B5563))),
      ],
    );
  }
}
