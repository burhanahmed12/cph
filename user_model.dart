class UserModel {
  final String id;
  final String role;
  final String email;
  final String name;

 UserModel({
   required this.id,
   required this.role,
   required this.name,
   required this.email
 });

 factory UserModel.fromMap(Map<String, dynamic>data, String id,){
   return UserModel(
   id: "id",
   name: data["name"],
   role: data["role"],
   email: data["email"],
   );
  }

}