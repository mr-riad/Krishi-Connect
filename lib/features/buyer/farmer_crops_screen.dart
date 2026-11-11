// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../gen/colors.gen.dart';
import '../../helpers/call_helper.dart';
import '../../models/krishi_models.dart';
import '../../services/api_service.dart';
import '../shared/chat_screen.dart';

class FarmerCropsScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const FarmerCropsScreen({super.key, this.onBack});

  @override
  State<FarmerCropsScreen> createState() => _FarmerCropsScreenState();
}

class _FarmerCropsScreenState extends State<FarmerCropsScreen> {
  static const Color primaryGreen = AppColors.primaryGreen;
  static const Color bgColor = AppColors.bgColor;

  final _searchController = TextEditingController();
  final _districtController = TextEditingController();

  // Advanced filter states
  double? _minPrice;
  double? _maxPrice;
  double? _minQuantity;
  double? _maxQuantity;
  DateTime? _harvestFrom;
  DateTime? _harvestTo;
  String? _selectedUpazila;

  int _selectedCategoryIndex = 0;
  String _sortBy = 'newest';
  bool _isLoading = false;
  String? _errorMsg;
  List<CropListing> _listings = [];

  final List<Map<String, String>> _categories = const [
    {"label": "সব", "type": ""},
    {"label": "ধান", "type": "paddy"},
    {"label": "সবজি", "type": "vegetable"},
    {"label": "ফল", "type": "fruit"},
    {"label": "ডাল", "type": "pulse"},
    {"label": "মসলা", "type": "spice"},
  ];

  final Map<String, String> _sortOptions = const {
    'newest': 'সর্বশেষ',
    'price_asc': 'কম দাম',
  };

  @override
  void initState() {
    super.initState();
    _fetchListings();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _districtController.dispose();
    super.dispose();
  }

  Future<void> _fetchListings() async {
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });
    try {
      final category = _categories[_selectedCategoryIndex]['type']!;
      final result = await KrishiApiService.instance.searchListings(
        q: _searchController.text.trim().isEmpty
            ? null
            : _searchController.text.trim(),
        category: category.isEmpty ? null : category,
        district: _districtController.text.trim().isEmpty
            ? null
            : _districtController.text.trim(),
        upazila: _selectedUpazila,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        minQuantity: _minQuantity,
        maxQuantity: _maxQuantity,
        harvestFrom: _harvestFrom != null
            ? DateFormat('yyyy-MM-dd').format(_harvestFrom!)
            : null,
        harvestTo: _harvestTo != null
            ? DateFormat('yyyy-MM-dd').format(_harvestTo!)
            : null,
        sort: _sortBy,
        limit: 50,
      );
      if (!mounted) return;
      final items = (result['items'] as List<dynamic>?) ?? [];
      setState(() {
        _listings = items
            .map((e) => CropListing.fromJson(e as Map<String, dynamic>))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMsg = 'তালিকা লোড করতে সমস্যা হয়েছে। পুনরায় চেষ্টা করুন।';
      });
    }
  }

  Future<void> _callFarmer(CropListing listing) async {
    if (listing.farmerPhone != null && listing.farmerPhone!.isNotEmpty) {
      showDirectCallBottomSheet(
        context: context,
        phone: listing.farmerPhone!,
        name: listing.farmerName ?? listing.cropName,
      );
      return;
    }
    try {
      final callData = await KrishiApiService.instance.triggerCall(
        targetUid: listing.farmerId,
        listingId: listing.id,
      );
      final phone = callData['phone'] as String?;
      if (phone != null && mounted) {
        showDirectCallBottomSheet(
          context: context,
          phone: phone,
          name:
              callData['target_name'] as String? ??
              listing.farmerName ??
              listing.cropName,
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('কৃষকের ফোন নম্বর পাওয়া যায়নি'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _startChat(CropListing listing) async {
    try {
      final conv = await KrishiApiService.instance.startConversation(
        participantId: listing.farmerId,
        listingId: listing.id,
      );
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            conversationId: conv['id'] as String,
            peerName: listing.farmerName ?? 'কৃষক',
            peerPhone: listing.farmerPhone,
            listingTitle:
                '${listing.cropName} (${listing.quantity} ${listing.unitLabel})',
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

  void _openFilterBottomSheet() {
    final minPriceCtrl = TextEditingController(
      text: _minPrice?.toString() ?? '',
    );
    final maxPriceCtrl = TextEditingController(
      text: _maxPrice?.toString() ?? '',
    );
    final minQtyCtrl = TextEditingController(
      text: _minQuantity?.toString() ?? '',
    );
    final maxQtyCtrl = TextEditingController(
      text: _maxQuantity?.toString() ?? '',
    );
    DateTime? fromDate = _harvestFrom;
    DateTime? toDate = _harvestTo;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20.w,
                right: 20.w,
                top: 20.h,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20.h,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40.w,
                        height: 4.h,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'উন্নত ফিল্টার (Advanced Search)',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF111827),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setSheetState(() {
                              minPriceCtrl.clear();
                              maxPriceCtrl.clear();
                              minQtyCtrl.clear();
                              maxQtyCtrl.clear();
                              fromDate = null;
                              toDate = null;
                            });
                          },
                          child: Text(
                            'রিসেট',
                            style: TextStyle(color: Colors.red.shade600),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 14.h),

                    // Price Range (BDT/kg)
                    Text(
                      'দামের সীমা (টাকা/কেজি)',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: minPriceCtrl,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'সর্বনিম্ন দাম',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 10.h,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: TextField(
                            controller: maxPriceCtrl,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'সর্বোচ্চ দাম',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 10.h,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 14.h),

                    // Quantity Range (kg)
                    Text(
                      'পরিমাণ সীমা (কেজি)',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: minQtyCtrl,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'সর্বনিম্ন পরিমাণ',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 10.h,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: TextField(
                            controller: maxQtyCtrl,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'সর্বোচ্চ পরিমাণ',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 10.h,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 14.h),

                    // Harvest Date
                    Text(
                      'ফসল তোলার তারিখ (Harvest Date)',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final d = await showDatePicker(
                                context: context,
                                initialDate: fromDate ?? DateTime.now(),
                                firstDate: DateTime(2023),
                                lastDate: DateTime(2030),
                              );
                              if (d != null) setSheetState(() => fromDate = d);
                            },
                            icon: const Icon(Icons.date_range, size: 16),
                            label: Text(
                              fromDate != null
                                  ? DateFormat('yyyy-MM-dd').format(fromDate!)
                                  : 'শুরু তারিখ',
                              style: TextStyle(fontSize: 12.sp),
                            ),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final d = await showDatePicker(
                                context: context,
                                initialDate: toDate ?? DateTime.now(),
                                firstDate: DateTime(2023),
                                lastDate: DateTime(2030),
                              );
                              if (d != null) setSheetState(() => toDate = d);
                            },
                            icon: const Icon(Icons.date_range, size: 16),
                            label: Text(
                              toDate != null
                                  ? DateFormat('yyyy-MM-dd').format(toDate!)
                                  : 'শেষ তারিখ',
                              style: TextStyle(fontSize: 12.sp),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h),

                    // Apply Button
                    SizedBox(
                      width: double.infinity,
                      height: 48.h,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _minPrice = double.tryParse(
                              minPriceCtrl.text.trim(),
                            );
                            _maxPrice = double.tryParse(
                              maxPriceCtrl.text.trim(),
                            );
                            _minQuantity = double.tryParse(
                              minQtyCtrl.text.trim(),
                            );
                            _maxQuantity = double.tryParse(
                              maxQtyCtrl.text.trim(),
                            );
                            _harvestFrom = fromDate;
                            _harvestTo = toDate;
                          });
                          Navigator.pop(ctx);
                          _fetchListings();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Text(
                          'ফিল্টার প্রয়োগ করুন',
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasActiveFilters =
        _minPrice != null ||
        _maxPrice != null ||
        _minQuantity != null ||
        _maxQuantity != null ||
        _harvestFrom != null ||
        _harvestTo != null;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Bar
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
              child: Row(
                children: [
                  if (widget.onBack != null)
                    GestureDetector(
                      onTap: widget.onBack,
                      child: Container(
                        width: 40.w,
                        height: 40.w,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 18,
                        ),
                      ),
                    ),
                  if (widget.onBack != null) SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      'কৃষকের ফসল',
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF111827),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _openFilterBottomSheet,
                    icon: Stack(
                      children: [
                        Icon(
                          Icons.tune_rounded,
                          color: primaryGreen,
                          size: 24.sp,
                        ),
                        if (hasActiveFilters)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              width: 8.w,
                              height: 8.w,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                    tooltip: 'উন্নত ফিল্টার',
                  ),
                  IconButton(
                    onPressed: _fetchListings,
                    icon: Icon(
                      Icons.refresh_rounded,
                      color: primaryGreen,
                      size: 22.sp,
                    ),
                    tooltip: 'রিফ্রেশ',
                  ),
                ],
              ),
            ),

            // Search & District inputs
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
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
                        onSubmitted: (_) => _fetchListings(),
                        decoration: InputDecoration(
                          hintText: 'ফসল খুঁজুন...',
                          hintStyle: TextStyle(
                            fontSize: 13.sp,
                            color: const Color(0xFF9CA3AF),
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            size: 18.sp,
                            color: const Color(0xFF6B7280),
                          ),
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
                        onSubmitted: (_) => _fetchListings(),
                        decoration: InputDecoration(
                          hintText: 'জেলা',
                          hintStyle: TextStyle(
                            fontSize: 13.sp,
                            color: const Color(0xFF9CA3AF),
                          ),
                          prefixIcon: Icon(
                            Icons.location_on_outlined,
                            size: 18.sp,
                            color: const Color(0xFF6B7280),
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  GestureDetector(
                    onTap: _fetchListings,
                    child: Container(
                      height: 44.h,
                      width: 44.h,
                      decoration: BoxDecoration(
                        color: primaryGreen,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        Icons.search,
                        color: Colors.white,
                        size: 20.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Category Bar + Sort Options
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
                        separatorBuilder: (_, _) => SizedBox(width: 8.w),
                        itemBuilder: (ctx, i) {
                          final selected = i == _selectedCategoryIndex;
                          return GestureDetector(
                            onTap: () {
                              setState(() => _selectedCategoryIndex = i);
                              _fetchListings();
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 14.w,
                                vertical: 6.h,
                              ),
                              decoration: BoxDecoration(
                                color: selected ? primaryGreen : Colors.white,
                                borderRadius: BorderRadius.circular(20.r),
                                border: Border.all(
                                  color: selected
                                      ? primaryGreen
                                      : const Color(0xFFE5E7EB),
                                ),
                              ),
                              child: Text(
                                _categories[i]['label']!,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  color: selected
                                      ? Colors.white
                                      : const Color(0xFF374151),
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
                          return DropdownMenuItem(
                            value: e.key,
                            child: Text(e.value),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _sortBy = val);
                            _fetchListings();
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
                      Icon(
                        Icons.error_outline,
                        size: 40.sp,
                        color: Colors.red.shade400,
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        _errorMsg!,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.red.shade600,
                        ),
                      ),
                      SizedBox(height: 14.h),
                      ElevatedButton(
                        onPressed: _fetchListings,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryGreen,
                        ),
                        child: const Text(
                          'পুনরায় চেষ্টা করুন',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else if (_listings.isEmpty)
              Expanded(
                child: Center(
                  child: Text(
                    'কোনো ফসল পাওয়া যায়নি',
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ),
              )
            else
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _fetchListings,
                  color: primaryGreen,
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    itemCount: _listings.length,
                    itemBuilder: (ctx, i) => _buildCard(_listings[i]),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(CropListing listing) {
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
                  child: Text(
                    listing.cropName,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF111827),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    listing.categoryLabel,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: primaryGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Wrap(
              spacing: 14.w,
              runSpacing: 4.h,
              children: [
                _chip(
                  Icons.scale_outlined,
                  '${listing.quantity} ${listing.unitLabel}',
                ),
                _chip(
                  Icons.currency_exchange,
                  '৳${listing.pricePerUnit.toStringAsFixed(0)}/${listing.unitLabel}',
                ),
                _chip(Icons.location_on_outlined, listing.locationLabel),
                if (listing.farmerName != null)
                  _chip(Icons.person_outline, listing.farmerName!),
              ],
            ),
            if (listing.description != null &&
                listing.description!.isNotEmpty) ...[
              SizedBox(height: 8.h),
              Text(
                listing.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
            SizedBox(height: 12.h),

            // Action Buttons: Call and Chat
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: SizedBox(
                    height: 38.h,
                    child: ElevatedButton.icon(
                      onPressed: () => _callFarmer(listing),
                      icon: Icon(Icons.call_outlined, size: 16.sp),
                      label: Text(
                        'সরাসরি কল',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
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
                      onPressed: () => _startChat(listing),
                      icon: Icon(Icons.chat_outlined, size: 16.sp),
                      label: Text(
                        'চ্যাট',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: primaryGreen,
                        side: const BorderSide(color: primaryGreen),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
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
        Text(
          label,
          style: TextStyle(fontSize: 12.sp, color: const Color(0xFF4B5563)),
        ),
      ],
    );
  }
}
