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
    super.isbn = '',
    super.stockQuantity = 0,
    super.categoryId,
    super.imageURL,
  });

  factory BookModel.fromJson(Map<String, dynamic> json) {
    final statusRaw = json['status'];
    final bool statusBool;
    if (statusRaw is bool) {
      statusBool = statusRaw;
    } else if (statusRaw is String) {
      statusBool = statusRaw.toUpperCase() == 'ACTIVE';
    } else {
      statusBool = true;
    }

    final stockRaw = json['stockQuantity'] ?? json['stockquantity'];
    final int stock = stockRaw is num
        ? stockRaw.toInt()
        : (int.tryParse(stockRaw?.toString() ?? '') ?? (statusBool ? 10 : 0));

    return BookModel(
      bookId: ((json['bookId'] ?? json['bookid'] ?? 0) as num).toInt(),
      bookName: (json['bookName'] ?? json['bookname'] ?? '').toString(),
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      author: (json['author'] ?? '').toString(),
      publisher: (json['publisher'] ?? '').toString(),
      summary: (json['description'] ?? json['summary'] ?? '').toString(),
      status: statusBool,
      isbn: (json['isbn'] ?? '').toString(),
      stockQuantity: stock,
      categoryId: (json['categoryId'] as num?)?.toInt(),
      imageURL: json['imageURL']?.toString(),
    );
  }
}
