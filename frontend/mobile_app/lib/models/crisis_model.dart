class CrisisModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final int peopleAffected;

  CrisisModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.peopleAffected,
  });

  factory CrisisModel.fromJson(Map<String, dynamic> json) {
    return CrisisModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      peopleAffected: json['people_affected'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'people_affected': peopleAffected,
    };
  }
}
