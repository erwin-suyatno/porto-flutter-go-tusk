import 'package:intl/intl.dart';

import '../data/models/task.dart';

String _formatDate(DateTime date) {
  return DateFormat('d MMM yyyy, HH:mm').format(date);
}

String dateByStatus(Task task){
  switch (task.status) {
    case 'queue':
      return _formatDate(task.createdAt!);
    case 'review':
      return _formatDate(task.submitDate!);
    case 'approved':
      return _formatDate(task.approvedDate!);
    case 'rejected':
      return _formatDate(task.rejectedDate!);
    default:
      return "-";
  }
}

String iconByStatus(Task task) {
  switch (task.status) {
    case 'queue':
      return 'assets/queue_icon.png';
    case 'review':
      return 'assets/review_icon.png';
    case 'approved':
      return 'assets/approved_icon.png';
    case 'rejected':
      return 'assets/rejected_icon.png';
    default:
      return 'assets/queue_icon.png';
  }
}