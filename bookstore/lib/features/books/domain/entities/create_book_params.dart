class CreateBookParams {
  const CreateBookParams({
    required this.bookName,
    required this.price,
    required this.author,
    required this.publisher,
    required this.summary,
    this.status = true,
  });

  final String bookName;
  final double price;
  final String author;
  final String publisher;
  final String summary;
  final bool status;

  /// Chuyển đổi sang Map JSON tương thích với endpoint POST /api/books của backend
  Map<String, dynamic> toJson() => {
        'bookname': bookName.trim(),
        'price': price,
        'author': author.trim(),
        'publisher': publisher.trim(),
        'summary': summary.trim(),
        'status': status,
      };
}
