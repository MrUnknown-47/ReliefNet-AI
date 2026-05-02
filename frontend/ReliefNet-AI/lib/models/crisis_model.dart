class CrisisLocation {
  final double lat;
  final double lng;

  CrisisLocation({required this.lat, required this.lng});

  factory CrisisLocation.fromJson(Map<String, dynamic> json) {
    return CrisisLocation(
      lat: (json['lat'] ?? 0.0).toDouble(),
      lng: (json['lng'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lat': lat,
      'lng': lng,
    };
  }
}

class CrisisModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final int peopleAffected;
  final CrisisLocation? location;
  final Map<String, dynamic>? aiAnalysis;

  CrisisModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.peopleAffected,
    this.location,
    this.aiAnalysis,
  });

  factory CrisisModel.fromJson(Map<String, dynamic> json) {
    return CrisisModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      peopleAffected: json['people_affected'] ?? 0,
      location: json['location'] != null ? CrisisLocation.fromJson(json['location']) : null,
      aiAnalysis: json['ai_analysis'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'people_affected': peopleAffected,
      if (location != null) 'location': location!.toJson(),
      if (aiAnalysis != null) 'ai_analysis': aiAnalysis,
    };
  }
}
