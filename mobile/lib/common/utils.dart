import 'package:intl/intl.dart';

import '../data/models/task.dart';

String _formatDate(DateTime date) {
  return DateFormat('d MMM yyyy, HH:mm').format(date);
}

String dateByStatus(Task task){
  switch (task.status) {
    case 'Queue':
      return _formatDate(task.createdAt!);
    case 'Review':
      return _formatDate(task.submitDate!);
    case 'Approved':
      return _formatDate(task.approvedDate!);
    case 'Rejected':
      return _formatDate(task.rejectedDate!);
    default:
      return "-";
  }
}

String iconByStatus(Task task) {
  switch (task.status) {
    case 'Queue':
      return 'assets/queue_icon.png';
    case 'Review':
      return 'assets/review_icon.png';
    case 'Approved':
      return 'assets/approved_icon.png';
    case 'Rejected':
      return 'assets/rejected_icon.png';
    default:
      return 'assets/queue_icon.png';
  }
}