// ignore_for_file: use_build_context_synchronously
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../gen/colors.gen.dart';
import '../../helpers/call_helper.dart';
import '../../services/api_service.dart';

class ChatScreen extends StatefulWidget {
  final String conversationId;
  final String peerName;
  final String? peerPhone;
  final String? listingTitle;

  const ChatScreen({
    super.key,
    required this.conversationId,
    required this.peerName,
    this.peerPhone,
    this.listingTitle,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  static const Color primaryGreen = AppColors.primaryGreen;
  static const Color bgColor = AppColors.bgColor;

  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSending = false;
  late final String _currentUid;

  @override
  void initState() {
    super.initState();
    _currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    _markRead();
  }

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _markRead() async {
    try {
      await KrishiApiService.instance.markRead(widget.conversationId);
    } catch (_) {}
  }

  Future<void> _sendMessage() async {
    final text = _msgController.text.trim();
    if (text.isEmpty || _isSending) return;

    _msgController.clear();
    setState(() => _isSending = true);

    try {
      await KrishiApiService.instance.sendMessage(widget.conversationId, text);
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('বার্তা পাঠাতে সমস্যা হয়েছে'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 60.h,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final messagesStream = FirebaseFirestore.instance
        .collection('conversations')
        .doc(widget.conversationId)
        .collection('messages')
        .orderBy('created_at', descending: false)
        .snapshots();

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF111827), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.peerName,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF111827),
              ),
            ),
            if (widget.listingTitle != null)
              Text(
                widget.listingTitle!,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: primaryGreen,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        actions: [
          if (widget.peerPhone != null && widget.peerPhone!.isNotEmpty)
            IconButton(
              icon: Icon(Icons.phone_in_talk_rounded, color: primaryGreen, size: 22.sp),
              tooltip: 'সরাসরি কল',
              onPressed: () => showDirectCallBottomSheet(
                context: context,
                phone: widget.peerPhone!,
                name: widget.peerName,
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Messages list (Real-time Firestore snapshots)
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: messagesStream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return _buildRestFallback();
                  }

                  if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data?.docs ?? [];
                  if (docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.chat_bubble_outline_rounded,
                              size: 48.sp, color: const Color(0xFF9CA3AF)),
                          SizedBox(height: 10.h),
                          Text(
                            'কথোপকথন শুরু করুন',
                            style: TextStyle(fontSize: 14.sp, color: const Color(0xFF6B7280)),
                          ),
                        ],
                      ),
                    );
                  }

                  WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

                  return ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    itemCount: docs.length,
                    itemBuilder: (ctx, i) {
                      final data = docs[i].data();
                      final isMe = data['sender_id'] == _currentUid;
                      final text = data['text'] as String? ?? '';
                      final dynamic rawTs = data['created_at'];

                      DateTime? dt;
                      if (rawTs is Timestamp) {
                        dt = rawTs.toDate();
                      } else if (rawTs is String) {
                        dt = DateTime.tryParse(rawTs);
                      }

                      final timeStr = dt != null ? DateFormat('hh:mm a').format(dt) : '';

                      return _buildMessageBubble(text: text, isMe: isMe, time: timeStr);
                    },
                  );
                },
              ),
            ),

            // Input bar
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(24.r),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: TextField(
                        controller: _msgController,
                        style: TextStyle(fontSize: 14.sp),
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        decoration: InputDecoration(
                          hintText: 'বার্তা লিখুন...',
                          hintStyle: TextStyle(fontSize: 14.sp, color: const Color(0xFF9CA3AF)),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 10.h),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      width: 44.w,
                      height: 44.w,
                      decoration: const BoxDecoration(
                        color: primaryGreen,
                        shape: BoxShape.circle,
                      ),
                      child: _isSending
                          ? Center(
                              child: SizedBox(
                                width: 20.w,
                                height: 20.w,
                                child: const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                          : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRestFallback() {
    return FutureBuilder<List<dynamic>>(
      future: KrishiApiService.instance.getMessages(widget.conversationId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final msgs = snapshot.data ?? [];
        if (msgs.isEmpty) {
          return Center(
            child: Text('কোনো বার্তা নেই', style: TextStyle(fontSize: 14.sp, color: Colors.grey)),
          );
        }
        return ListView.builder(
          controller: _scrollController,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          itemCount: msgs.length,
          itemBuilder: (ctx, i) {
            final m = msgs[i] as Map<String, dynamic>;
            final isMe = m['sender_id'] == _currentUid;
            return _buildMessageBubble(
              text: m['text'] as String? ?? '',
              isMe: isMe,
              time: '',
            );
          },
        );
      },
    );
  }

  Widget _buildMessageBubble({
    required String text,
    required bool isMe,
    required String time,
  }) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        constraints: BoxConstraints(maxWidth: 0.75.sw),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isMe ? primaryGreen : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.r),
            topRight: Radius.circular(16.r),
            bottomLeft: Radius.circular(isMe ? 16.r : 4.r),
            bottomRight: Radius.circular(isMe ? 4.r : 16.r),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: 14.sp,
                color: isMe ? Colors.white : const Color(0xFF111827),
                fontWeight: FontWeight.w500,
              ),
            ),
            if (time.isNotEmpty) ...[
              SizedBox(height: 4.h),
              Text(
                time,
                style: TextStyle(
                  fontSize: 10.sp,
                  color: isMe ? Colors.white70 : const Color(0xFF9CA3AF),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

