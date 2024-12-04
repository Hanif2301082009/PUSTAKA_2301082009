class Book {
  final int id;
  final String title;
  final String author;
  final String coverUrl;
  final bool isAvailable;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.coverUrl,
    this.isAvailable = true,
  });

  // Jika menggunakan API, tambahkan fromJson factory
  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'],
      title: json['title'],
      author: json['author'],
      coverUrl: json['cover_url'],
      isAvailable: json['is_available'] ?? true,
    );
  }
} 