class PDF {
  String? id;
  String? pdfName;
  String? uploader;
  String? category;
  List<String> likes;

  PDF(this.id, this.pdfName, this.uploader, this.category, this.likes);

  Map<String, dynamic> toJson() => {
        'id': id,
        'pdfName': pdfName,
        'uploader': uploader,
        'category': category,
        'likes': likes,
      };
}
