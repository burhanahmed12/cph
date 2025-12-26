import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cph4/Model/Tasks/task_model.dart';
import 'package:flutter/material.dart';

class TaskProvider extends ChangeNotifier{
  List<TaskModel> tasks = [];
  bool isloading = false;
  final FirebaseFirestore db = FirebaseFirestore.instance;

  Future<void> fetchtasks()async{
    isloading = true;
    notifyListeners();
    final snapshots = await db.collection('tasks').get();
    tasks = snapshots.docs
        .map((doc) => TaskModel.fromMap(doc.data(), doc.id))
        .toList();

    isloading = false;
    notifyListeners();
  }

  Future<void> addTask(String title, String desc)async{
      await db.collection('tasks').add({
      "title": title,
      "description": desc,
       "created At": Timestamp.now()
    });
    fetchtasks();
  }

  Future<void> UserStatus(String userId, String taskId, bool isdone)async{
    final query = await db.collection('TaskStatus')
        .where("taskId", isEqualTo: taskId)
        .where("userid", isEqualTo: userId)
        .get();

    if(query.docs.isEmpty){
     await db.collection("TaskStatus").add({
       "taskid": taskId,
       "userid": userId,
       "isdone": isdone
     });
    }else{
     await query.docs.first.reference.update({
       "isdone": isdone
     });
    }
  }

  Future<void> UserMsg(String userId, String taskID, String msg)async{
    await db.collection('UserReply').add({
      "userid": userId,
      "taskid": taskID,
      "message": msg,
      "created AT": Timestamp.now()
    });
  }

  Future<String?> MyReply(String taskId, String UserId)async{
    final query = await db.collection("Myreply")
    .where("userId", isEqualTo: UserId)
    .where("taskId", isEqualTo: taskId)
    .get()
  }

}