import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../gen/colors.gen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  static const Color primaryGreen = AppColors.primaryGreen;
  static const Color bgColor = AppColors.bgColor;

  final List<Map<String, dynamic>> _chats = [
    {
      'name': 'রহিম ট্রেডার্স',
      'lastMessage': 'আপনার ধান কি এখনো পাওয়া যাবে?',
      'time': 'এখন',
      'unread': 2,
      'isOnline': true,
      'role': 'ক্রেতা',
    },
    {
      'name': 'আলম ব্যবসায়ী',
      'lastMessage': 'ঠিক আছে, কাল সকালে আসবো',
      'time': '২ ঘণ্টা',
      'unread': 0,
      'isOnline': false,
      'role': 'ক্রেতা',
    },
    {
      'name': 'করিম এন্টারপ্রাইজ',
      'lastMessage': 'দাম একটু কমানো যাবে?',
      'time': 'গতকাল',
      'unread': 1,
      'isOnline': true,
      'role': 'ক্রেতা',
    },
    {
      'name': 'নাসির ফ্রেশ',
      'lastMessage': 'ঠিক আছে, চুক্তি হয়ে গেছে',
      'time': '২ দিন আগে',
      'unread': 0,
      'isOnline': false,
      'role': 'ক্রেতা',
    },
  ];

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
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              child: Text(
                'বার্তা',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF111827),
                ),
              ),
            ),

            // Search Box
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Container(
                height: 46.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Row(
                  children: [
                    SizedBox(width: 12.w),
                    Icon(Icons.search_rounded, color: const Color(0xFF9CA3AF), size: 20.sp),
                    SizedBox(width: 8.w),
                    Text(
                      'বার্তা খুঁজুন...',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: const Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 14.h),

            // Chat List
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                itemCount: _chats.length,
                separatorBuilder: (_, _) => SizedBox(height: 8.h),
                itemBuilder: (context, index) {
                  final chat = _chats[index];
                  final hasUnread = (chat['unread'] as int) > 0;
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatDetailScreen(
                            name: chat['name'] as String,
                            role: chat['role'] as String,
                            isOnline: chat['isOnline'] as bool,
                          ),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(16.r),
                    child: Container(
                      padding: EdgeInsets.all(14.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: hasUnread ? primaryGreen.withValues(alpha: 0.3) : const Color(0xFFE5E7EB),
                          width: hasUnread ? 1.5 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.025),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Avatar
                          Stack(
                            children: [
                              Container(
                                width: 50.w,
                                height: 50.w,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF0FDF4),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: const Color(0xFFD1FAE5), width: 2),
                                ),
                                child: Icon(
                                  Icons.person_rounded,
                                  size: 28.sp,
                                  color: primaryGreen,
                                ),
                              ),
                              if (chat['isOnline'] as bool)
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    width: 13.w,
                                    height: 13.w,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF22C55E),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 2),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(width: 12.w),
                          // Content
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          chat['name'] as String,
                                          style: TextStyle(
                                            fontSize: 15.sp,
                                            fontWeight: hasUnread ? FontWeight.w800 : FontWeight.w600,
                                            color: const Color(0xFF111827),
                                          ),
                                        ),
                                        SizedBox(width: 6.w),
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFE0F2FE),
                                            borderRadius: BorderRadius.circular(6.r),
                                          ),
                                          child: Text(
                                            chat['role'] as String,
                                            style: TextStyle(
                                              fontSize: 10.sp,
                                              fontWeight: FontWeight.w700,
                                              color: const Color(0xFF0284C7),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      chat['time'] as String,
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        color: hasUnread ? primaryGreen : const Color(0xFF9CA3AF),
                                        fontWeight: hasUnread ? FontWeight.w700 : FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 4.h),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        chat['lastMessage'] as String,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 13.sp,
                                          color: hasUnread
                                              ? const Color(0xFF374151)
                                              : const Color(0xFF9CA3AF),
                                          fontWeight: hasUnread ? FontWeight.w600 : FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                    if (hasUnread)
                                      Container(
                                        width: 20.w,
                                        height: 20.w,
                                        decoration: const BoxDecoration(
                                          color: primaryGreen,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${chat['unread']}',
                                            style: TextStyle(
                                              fontSize: 11.sp,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Chat Detail Screen ───────────────────────────────────────────────────────

class ChatDetailScreen extends StatefulWidget {
  final String name;
  final String role;
  final bool isOnline;

  const ChatDetailScreen({
    super.key,
    required this.name,
    required this.role,
    required this.isOnline,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  static const Color primaryGreen = AppColors.primaryGreen;
  static const Color bgColor = AppColors.bgColor;

  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, dynamic>> _messages = [
    {'isMe': false, 'text': 'আস-সালামু আলাইকুম, আপনার ধান কি এখনো পাওয়া যাবে?', 'time': '১০:৩০'},
    {'isMe': true, 'text': 'ওয়ালাইকুম সালাম। হ্যাঁ, এখনো ৩০০ কেজি আছে।', 'time': '১০:৩২'},
    {'isMe': false, 'text': 'কেজি প্রতি কত দরে দেবেন?', 'time': '১০:৩৩'},
    {'isMe': true, 'text': '৩৮ টাকা কেজি। ভালো মানের ধান।', 'time': '১০:৩৫'},
    {'isMe': false, 'text': 'আপনার ধান কি এখনো পাওয়া যাবে?', 'time': 'এখন'},
  ];

  void _sendMessage() {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add({'isMe': true, 'text': text, 'time': 'এখন'});
    });
    _msgController.clear();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leadingWidth: 40.w,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF111827)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 38.w,
                  height: 38.w,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF0FDF4),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.person_rounded, size: 22.sp, color: primaryGreen),
                ),
                if (widget.isOnline)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 11.w,
                      height: 11.w,
                      decoration: BoxDecoration(
                        color: const Color(0xFF22C55E),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(width: 10.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.name,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111827),
                  ),
                ),
                Text(
                  widget.isOnline ? 'অনলাইন' : widget.role,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: widget.isOnline ? const Color(0xFF22C55E) : const Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.call_outlined, color: primaryGreen, size: 22.sp),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              controller: _scrollController,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              itemCount: _messages.length,
              separatorBuilder: (_, _) => SizedBox(height: 8.h),
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isMe = msg['isMe'] as bool;
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment:
                        isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      Container(
                        constraints: BoxConstraints(maxWidth: 0.72.sw),
                        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                        decoration: BoxDecoration(
                          color: isMe ? primaryGreen : Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16.r),
                            topRight: Radius.circular(16.r),
                            bottomLeft: isMe ? Radius.circular(16.r) : Radius.circular(4.r),
                            bottomRight: isMe ? Radius.circular(4.r) : Radius.circular(16.r),
                          ),
                          border: isMe ? null : Border.all(color: const Color(0xFFE5E7EB)),
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
                            fontSize: 14.sp,
                            color: isMe ? Colors.white : const Color(0xFF111827),
                            height: 1.4,
                          ),
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        msg['time'] as String,
                        style: TextStyle(fontSize: 11.sp, color: const Color(0xFF9CA3AF)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Input Area
          Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(24.r),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: TextField(
                      controller: _msgController,
                      style: TextStyle(fontSize: 14.sp, color: const Color(0xFF111827)),
                      decoration: InputDecoration(
                        hintText: 'বার্তা লিখুন...',
                        hintStyle: TextStyle(fontSize: 13.sp, color: const Color(0xFF9CA3AF)),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    width: 44.w,
                    height: 44.w,
                    decoration: BoxDecoration(
                      color: primaryGreen,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: primaryGreen.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Icon(Icons.send_rounded, color: Colors.white, size: 20.sp),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
