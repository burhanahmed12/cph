class TaskModel {
  final String taskid;
  final String tasktitle;
  final String taskdes;
  final DateTime creatAt;
  final DateTime dueAt;
  final bool isActive;

  TaskModel({
    required this.taskid,
    required this.tasktitle,
    required this.taskdes,
    required this.creatAt,
    required this.dueAt,
    required this.isActive
  });

  factory TaskModel.fromMap(Map<String, dynamic>data, String id){
    return TaskModel(
    taskid: data["taskid"],
    taskdes: data["taskdes"],
    tasktitle: data["tasktitle"],
    dueAt: data["due date"].toDate(),
    creatAt: data["created at"].toDate(),
    isActive: data["is Actice"],
    );
  }

}