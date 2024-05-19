class MainUser {
  MainUser({
    required this.image,
    required this.about,
    required this.name,
    required this.branch,
    required this.college,
    required this.createdAt,
    required this.id,
    required this.email,
    required this.uploads,
  });

  late String image;
  late String about;
  late String name;
  late String branch;
  late String college;
  late String createdAt;
  late String? id;
  late String email;
  late int uploads;

  MainUser.fromJson(Map<String, dynamic> json) {
    image = json['image'] ?? '';
    about = json['about'] ?? '';
    name = json['name'] ?? '';
    branch = json['branch'] ?? '';
    college = json['college'] ?? '';
    createdAt = json['created_at'] ?? '';
    id = json['id'] ?? '';
    email = json['email'] ?? '';
    uploads = json['uploads'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['image'] = image;
    data['about'] = about;
    data['name'] = name;
    data['branch'] = branch;
    data['college'] = college;
    data['created_at'] = createdAt;
    data['id'] = id;
    data['email'] = email;
    data['uploads'] = uploads;
    return data;
  }
}
