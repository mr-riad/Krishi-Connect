String formatPostedTime(DateTime postedTime) {
  final now = DateTime.now();
  final difference = now.difference(postedTime);

  if (difference.inMinutes < 1) {
    return 'Just now';
  }

  if (difference.inHours < 1) {
    return '${difference.inMinutes} min ago';
  }

  if (difference.inHours < 24) {
    return '${difference.inHours} hours ago';
  }

  return '${postedTime.day.toString().padLeft(2, '0')}/'
      '${postedTime.month.toString().padLeft(2, '0')}/'
      '${postedTime.year}';
}
