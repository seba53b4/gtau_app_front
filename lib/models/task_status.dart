
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