import '../../domain/entities/book.dart';

class BookModel extends Book {
  const BookModel({
    required super.bookId,
    required super.bookName,
    required super.price,
    required super.author,
    required super.publisher,
    required super.summary,
    required super.status,
  });

  factory BookModel.fromJson(Map<String, dynamic> json) => BookModel(
        bookId: (json['bookid'] as num).toInt(),
        bookName: (json['bookname'] ?? '').toString(),
        price: double.parse(json['price'].toString()),
        author: (json['author'] ?? '').toString(),
        publisher: (json['publisher'] ?? '').toString(),
        summary: (json['summary'] ?? '').toString(),
        status: (json['status'] as bool?) ?? true,
      );
}
