class PDF {
  String? id;
  String? name;
  int likes;

  PDF(this.id, this.name, this.likes);

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'likes': likes,
  };
}