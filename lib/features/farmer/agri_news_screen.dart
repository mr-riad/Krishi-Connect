import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../gen/colors.gen.dart';
import '../../models/weather_machinery_news_models.dart';
import '../../services/api_service.dart';

class AgriNewsScreen extends StatefulWidget {
  const AgriNewsScreen({super.key});

  @override
  State<AgriNewsScreen> createState() => _AgriNewsScreenState();
}

class _AgriNewsScreenState extends State<AgriNewsScreen> {
  static const Color primaryGreen = AppColors.primaryGreen;
  static const Color bgColor = AppColors.bgColor;

  /// Tabs: (Bengali label, API category value or null for 'all')
  static const List<(String, String?)> _tabs = [
    ('সব', null),
    ('ভর্তুকি', 'subsidy'),
    ('নীতিমালা', 'policy'),
    ('মূল্য সহায়তা', 'price_support'),
    ('প্রশিক্ষণ', 'training'),
    ('প্রযুক্তি', 'technology'),
    ('আবহাওয়া', 'weather'),
  ];

  int _selectedTab = 0;
  List<NewsItem> _news = [];
  bool _loading = false;
  String? _error;

  final _api = KrishiApiService.instance;

  @override
  void initState() {
    super.initState();
    _loadNews();
  }

  Future<void> _loadNews() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final category = _tabs[_selectedTab].$2;
      final res = await _api.getNews(category: category, limit: 50);
      final page = NewsPage.fromJson(res);
      if (mounted) {
        setState(() {
          _news = page.items;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'সংবাদ লোড করতে সমস্যা হয়েছে।\n$e';
          _loading = false;
        });
      }
    }
  }

  /// Map category to badge colors
  ({Color bg, Color text}) _categoryColors(String category) {
    switch (category.toLowerCase()) {
      case 'subsidy':
        return (bg: const Color(0xFFDCFCE7), text: const Color(0xFF166534));
      case 'policy':
        return (bg: const Color(0xFFFEF3C7), text: const Color(0xFF92400E));
      case 'price_support':
        return (bg: const Color(0xFFDCFCE7), text: const Color(0xFF166534));
      case 'training':
        return (bg: const Color(0xFFEDE9FE), text: const Color(0xFF5B21B6));
      case 'technology':
        return (bg: const Color(0xFFE0F2FE), text: const Color(0xFF0369A1));
      case 'weather':
        return (bg: const Color(0xFFF0F9FF), text: const Color(0xFF0284C7));
      case 'general':
      default:
        return (bg: const Color(0xFFF3F4F6), text: const Color(0xFF374151));
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
            // Badge
            Padding(
              padding: EdgeInsets.only(right: 16.w, top: 12.h),
              child: Align(
                alignment: Alignment.topRight,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    'F-11 · কৃষক',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: primaryGreen,
                    ),
                  ),
                ),
              ),
            ),

            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.maybePop(context),
                    child: Container(
                      width: 40.w,
                      height: 40.w,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    'সরকারি ও কৃষি খবর',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF111827),
                    ),
                  ),
                ],
              ),
            ),

            // Category Tabs
            SizedBox(
              height: 40.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                itemCount: _tabs.length,
                separatorBuilder: (_, _) => SizedBox(width: 10.w),
                itemBuilder: (context, index) {
                  final isSelected = _selectedTab == index;
                  return InkWell(
                    onTap: () {
                      if (_selectedTab != index) {
                        setState(() => _selectedTab = index);
                        _loadNews();
                      }
                    },
                    borderRadius: BorderRadius.circular(20.r),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: isSelected ? primaryGreen : Colors.white,
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: isSelected ? primaryGreen : const Color(0xFFE5E7EB),
                        ),
                      ),
                      child: Text(
                        _tabs[index].$1,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? Colors.white : const Color(0xFF374151),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 14.h),

            // News List
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.wifi_off_rounded, size: 48.sp, color: Colors.grey),
              SizedBox(height: 12.h),
              Text(
                'সংবাদ লোড করা যায়নি',
                style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 6.h),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12.sp, color: Colors.grey),
              ),
              SizedBox(height: 16.h),
              ElevatedButton.icon(
                onPressed: _loadNews,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('আবার চেষ্টা করুন'),
              ),
            ],
          ),
        ),
      );
    }
    if (_news.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.article_outlined, size: 52.sp, color: Colors.grey.shade300),
            SizedBox(height: 12.h),
            Text(
              'এই বিভাগে কোনো সংবাদ নেই',
              style: TextStyle(fontSize: 15.sp, color: Colors.grey),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadNews,
      color: primaryGreen,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: _news.length,
        separatorBuilder: (_, _) => SizedBox(height: 10.h),
        itemBuilder: (context, index) {
          final item = _news[index];
          final colors = _categoryColors(item.category);
          return GestureDetector(
            onTap: () => _showNewsDetail(item),
            child: Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: const Color(0xFFE5E7EB)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: colors.bg,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      item.categoryBn,
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: colors.text,
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    item.titleBn,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF111827),
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 12.sp,
                        color: const Color(0xFF9CA3AF),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        item.formattedDate,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                      if (item.source != null && item.source!.isNotEmpty) ...[
                        SizedBox(width: 10.w),
                        Text('·', style: TextStyle(color: const Color(0xFF9CA3AF))),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Text(
                            item.source!,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: const Color(0xFF6B7280),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showNewsDetail(NewsItem item) {
    final colors = _categoryColors(item.category);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        builder: (_, controller) => SingleChildScrollView(
          controller: controller,
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: colors.bg,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  item.categoryBn,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: colors.text,
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                item.titleBn,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF111827),
                  height: 1.4,
                ),
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 12.sp,
                    color: const Color(0xFF9CA3AF),
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    item.formattedDate,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  if (item.source != null) ...[
                    SizedBox(width: 10.w),
                    Text('·', style: TextStyle(color: const Color(0xFF9CA3AF))),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Text(
                        item.source!,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: const Color(0xFF6B7280),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
              SizedBox(height: 16.h),
              const Divider(),
              SizedBox(height: 12.h),
              Text(
                item.bodyBn,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF374151),
                  height: 1.7,
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}
