class Post {
  final String id;
  final String caption;
  final String? imageUrl;
  final String createdAt;
  final String userId;

  Post({
    required this.id,
    required this.caption,
    this.imageUrl,
    required this.createdAt,
    required this.userId,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      caption: json['caption'],
      imageUrl: json['image_url'],
      createdAt: json['created_at'],
      userId: json['user_id'],
    );
  }
}