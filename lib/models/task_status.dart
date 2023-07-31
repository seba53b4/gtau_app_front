
enum TaskStatus {
  Doing,
  Done,
  Blocked,
  Pending,
}

extension TaskStatusExtension on TaskStatus {
  String get value {
    switch (this) {
      case TaskStatus.Doing:
        return 'DOING';
      case TaskStatus.Done:
        return 'DONE';
      case TaskStatus.Blocked:
        return 'BLOCKED';
      case TaskStatus.Pending:
        return 'PENDING';
    }
  }
}

TaskStatus getTaskStatusFromString(String statusString) {
  switch (statusString) {
    case 'DOING':
      return TaskStatus.Doing;
    case 'DONE':
      return TaskStatus.Done;
    case 'BLOCKED':
      return TaskStatus.Blocked;
    case 'PENDING':
      return TaskStatus.Pending;
    default:
      throw Exception('Invalid status string: $statusString');
  }
}