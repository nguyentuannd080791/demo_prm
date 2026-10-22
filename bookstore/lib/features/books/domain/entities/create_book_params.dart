class CreateBookParams {
  const CreateBookParams({
    required this.bookName,
    required this.price,
    required this.author,
    required this.publisher,
    required this.summary,
    this.status = true,
    this.isbn,
    this.categoryId = 1,
    this.stockQuantity = 50,
    this.imageURL,
  });

  final String bookName;
  final double price;
  final String author;
  final String publisher;
  final String summary;
  final bool status;
  final String? isbn;
  final int categoryId;
  final int stockQuantity;
  final String? imageURL;

  /// Chuyển đổi sang Map JSON tương thích với các endpoint POST / PUT /api/books của backend
  Map<String, dynamic> toJson() => {
        'bookName': bookName.trim(),
        'bookname': bookName.trim(),
        'price': price,
        'author': author.trim(),
        'publisher': publisher.trim(),
        'summary': summary.trim(),
        'description': summary.trim(),
        'isbn': isbn ??
            '978-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
        'categoryId': categoryId,
        'stockQuantity': stockQuantity,
        if (imageURL != null && imageURL!.trim().isNotEmpty) ...{
          'imageURL': imageURL!.trim(),
          'imageUrl': imageURL!.trim(),
        },
        'status': (status && stockQuantity > 0) ? 'ACTIVE' : 'INACTIVE',
      };
}
