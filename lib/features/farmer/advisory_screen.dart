import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../gen/colors.gen.dart';

class AdvisoryScreen extends StatefulWidget {
  const AdvisoryScreen({super.key});

  @override
  State<AdvisoryScreen> createState() => _AdvisoryScreenState();
}

class _AdvisoryScreenState extends State<AdvisoryScreen>
    with SingleTickerProviderStateMixin {
  static const Color primaryGreen = AppColors.primaryGreen;
  static const Color bgColor = AppColors.bgColor;

  late TabController _tabController;
  final TextEditingController _chatController = TextEditingController();
  bool _isSending = false;

  final List<Map<String, dynamic>> _messages = [
    {'isBot': true, 'text': 'আস-সালামু আলাইকুম! আমি কৃষি পরামর্শদাতা। আপনার ফসল বা কৃষি বিষয়ক যেকোনো প্রশ্ন করতে পারেন।'},
  ];

  final List<Map<String, dynamic>> _tips = [
    {
      'title': 'ধানের ব্লাস্ট রোগ',
      'desc': 'ধানে ব্লাস্ট রোগ দেখা দিলে ট্রাইসাইক্লাজোল ৭৫% WP ০.৬ গ্রাম/লিটার পানিতে মিশিয়ে স্প্রে করুন।',
      'icon': Icons.eco_outlined,
      'color': const Color(0xFFDCFCE7),
      'iconColor': const Color(0xFF16A34A),
    },
    {
      'title': 'সেচের সঠিক সময়',
      'desc': 'বোরো ধানে সকালে সেচ দিন। দুপুরে সেচ দিলে পানির বাষ্পীভবন বেশি হয় এবং গাছের ক্ষতি হতে পারে।',
      'icon': Icons.water_drop_outlined,
      'color': const Color(0xFFE0F2FE),
      'iconColor': const Color(0xFF0284C7),
    },
    {
      'title': 'সার প্রয়োগ পদ্ধতি',
      'desc': 'ইউরিয়া সার তিন ভাগে দিন: রোপণের সময়, ১৫ দিন পর এবং ৩০ দিন পর। এতে ফসলের ফলন বাড়বে।',
      'icon': Icons.science_outlined,
      'color': const Color(0xFFFEF3C7),
      'iconColor': const Color(0xFFD97706),
    },
    {
      'title': 'আলুর রোগ প্রতিরোধ',
      'desc': 'আলু চাষে লেট ব্লাইট রোগ থেকে বাঁচতে মেটালেক্সিল + ম্যানকোজেব ২ গ্রাম/লিটার পানিতে স্প্রে করুন।',
      'icon': Icons.grass_outlined,
      'color': const Color(0xFFFCE7F3),
      'iconColor': const Color(0xFFDB2777),
    },
  ];

  final List<String> _quickQuestions = [
    'ধানের হলুদ হয়ে যাওয়ার কারণ?',
    'আলুতে কোন সার ব্যবহার করবো?',
    'বৃষ্টির পর কী করণীয়?',
    'ফসলের পোকা দূর করার উপায়?',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _chatController.dispose();
    super.dispose();
  }

  void _sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    setState(() {
      _messages.add({'isBot': false, 'text': text});
      _isSending = true;
    });
    _chatController.clear();

    await Future.delayed(const Duration(milliseconds: 1200));

    if (!mounted) return;
    setState(() {
      _isSending = false;
      _messages.add({
        'isBot': true,
        'text': 'আপনার প্রশ্নটি পেয়েছি: "$text"\n\nকৃষি বিশেষজ্ঞের পরামর্শ: এ বিষয়ে স্থানীয় কৃষি অফিসে যোগাযোগ করুন অথবা নিকটস্থ কৃষি কর্মকর্তার সাথে কথা বলুন।',
      });
    });
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
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              child: Text(
                'কৃষি পরামর্শ',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF111827),
                ),
              ),
            ),

            // Tab Bar
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: primaryGreen,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.white,
                unselectedLabelColor: const Color(0xFF6B7280),
                labelStyle: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700),
                unselectedLabelStyle: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500),
                tabs: const [
                  Tab(text: 'AI পরামর্শ'),
                  Tab(text: 'কৃষি টিপস'),
                ],
              ),
            ),

            SizedBox(height: 10.h),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: AI Chat
                  Column(
                    children: [
                      Expanded(
                        child: ListView.separated(
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                          itemCount: _messages.length + (_isSending ? 1 : 0),
                          separatorBuilder: (_, _) => SizedBox(height: 12.h),
                          itemBuilder: (context, index) {
                            if (index == _messages.length) {
                              // Typing indicator
                              return Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  padding: EdgeInsets.all(12.w),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16.r),
                                    border: Border.all(color: const Color(0xFFE5E7EB)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: List.generate(3, (i) {
                                      return Container(
                                        margin: EdgeInsets.symmetric(horizontal: 3.w),
                                        width: 8.w,
                                        height: 8.w,
                                        decoration: BoxDecoration(
                                          color: primaryGreen.withValues(alpha: 0.5),
                                          shape: BoxShape.circle,
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                              );
                            }
                            final msg = _messages[index];
                            final isBot = msg['isBot'] as bool;
                            return Align(
                              alignment: isBot ? Alignment.centerLeft : Alignment.centerRight,
                              child: Container(
                                constraints: BoxConstraints(maxWidth: 0.75.sw),
                                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                                decoration: BoxDecoration(
                                  color: isBot ? Colors.white : primaryGreen,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(16.r),
                                    topRight: Radius.circular(16.r),
                                    bottomLeft: isBot ? Radius.circular(4.r) : Radius.circular(16.r),
                                    bottomRight: isBot ? Radius.circular(16.r) : Radius.circular(4.r),
                                  ),
                                  border: isBot ? Border.all(color: const Color(0xFFE5E7EB)) : null,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.04),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  msg['text'] as String,
                                  style: TextStyle(
                                    fontSize: 13.5.sp,
                                    color: isBot ? const Color(0xFF111827) : Colors.white,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // Quick Questions
                      SizedBox(
                        height: 38.h,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          itemCount: _quickQuestions.length,
                          separatorBuilder: (_, _) => SizedBox(width: 8.w),
                          itemBuilder: (context, index) {
                            return InkWell(
                              onTap: () => _sendMessage(_quickQuestions[index]),
                              borderRadius: BorderRadius.circular(20.r),
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF0FDF4),
                                  borderRadius: BorderRadius.circular(20.r),
                                  border: Border.all(color: const Color(0xFFBBF7D0)),
                                ),
                                child: Text(
                                  _quickQuestions[index],
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                    color: primaryGreen,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      SizedBox(height: 8.h),

                      // Input Area
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _chatController,
                                style: TextStyle(fontSize: 14.sp),
                                decoration: InputDecoration(
                                  hintText: 'আপনার প্রশ্ন লিখুন...',
                                  hintStyle: TextStyle(
                                    fontSize: 13.sp,
                                    color: const Color(0xFF9CA3AF),
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 14.w,
                                    vertical: 12.h,
                                  ),
                                ),
                                onSubmitted: _sendMessage,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _sendMessage(_chatController.text),
                              child: Container(
                                margin: EdgeInsets.all(6.w),
                                width: 40.w,
                                height: 40.w,
                                decoration: BoxDecoration(
                                  color: primaryGreen,
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Icon(
                                  Icons.send_rounded,
                                  color: Colors.white,
                                  size: 18.sp,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Tab 2: Tips
                  ListView.separated(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                    itemCount: _tips.length,
                    separatorBuilder: (_, _) => SizedBox(height: 12.h),
                    itemBuilder: (context, index) {
                      final tip = _tips[index];
                      return Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 44.w,
                              height: 44.w,
                              decoration: BoxDecoration(
                                color: tip['color'] as Color,
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Icon(
                                tip['icon'] as IconData,
                                color: tip['iconColor'] as Color,
                                size: 22.sp,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    tip['title']!,
                                    style: TextStyle(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF111827),
                                    ),
                                  ),
                                  SizedBox(height: 5.h),
                                  Text(
                                    tip['desc']!,
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      color: const Color(0xFF4B5563),
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
