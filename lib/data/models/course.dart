class Course {
  final String id;
  final String? slug;
  final String title;
  final String? description;
  final String? coverUrl;
  final String? videoUrl;
  final bool isFreeIntro;
  final bool isPublished;

  const Course({
    required this.id,
    this.slug,
    required this.title,
    this.description,
    this.coverUrl,
    this.videoUrl,
    this.isFreeIntro = false,
    this.isPublished = false,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] as String,
      slug: json['slug'] as String?,
      title: (json['title'] ?? '') as String,
      description: json['description'] as String?,
      coverUrl: json['cover_url'] as String?,
      videoUrl: json['video_url'] as String?,
      isFreeIntro: json['is_free_intro'] == true,
      isPublished: json['is_published'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (slug != null) 'slug': slug,
      'title': title,
      if (description != null) 'description': description,
      if (coverUrl != null) 'cover_url': coverUrl,
      if (videoUrl != null) 'video_url': videoUrl,
      'is_free_intro': isFreeIntro,
      'is_published': isPublished,
    };
  }
}
