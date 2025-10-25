class FamilyMember {
  final String id;
  final String name;
  final FamilyRole role;
  final String? email;
  final int todayCompletedTasks;
  final int todayTotalTasks;

  FamilyMember({
    required this.id,
    required this.name,
    required this.role,
    this.email,
    this.todayCompletedTasks = 0,
    this.todayTotalTasks = 0,
  });
}

enum FamilyRole {
  parent,
  child,
}