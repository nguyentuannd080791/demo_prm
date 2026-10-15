class Book {
  const Book({
    required this.bookId,
    required this.bookName,
    required this.price,
    required this.author,
    required this.publisher,
    required this.summary,
    required this.status,
  });

  final int bookId;
  final String bookName;
  final double price;
  final String author;
  final String publisher;
  final String summary;

  /// true = đang bán.
  final bool status;

  /// Danh sách các tag phân loại chủ đề của sách
  List<String> get tags {
    final result = <String>[];
    final text = '$bookName $author $publisher $summary'.toLowerCase();

    if (text.contains('code') ||
        text.contains('program') ||
        text.contains('design pattern') ||
        text.contains('refactor') ||
        text.contains('trí tuệ nhân tạo') ||
        text.contains('mã nguồn') ||
        text.contains('phần mềm') ||
        text.contains('lập trình')) {
      result.add('Công nghệ');
    }
    if (text.contains('giả kim') ||
        text.contains('hoàng tử') ||
        text.contains('dế mèn') ||
        text.contains('chiến tranh') ||
        text.contains('văn học') ||
        text.contains('tiểu thuyết')) {
      result.add('Văn học');
    }
    if (text.contains('đắc nhân tâm') ||
        text.contains('nghĩ giàu') ||
        text.contains('atomic') ||
        text.contains('thói quen') ||
        text.contains('kỹ năng') ||
        text.contains('giao tiếp')) {
      result.add('Kỹ năng');
    }
    if (text.contains('cha giàu') ||
        text.contains('tư duy nhanh') ||
        text.contains('kinh tế') ||
        text.contains('freakonomics') ||
        text.contains('tài chính')) {
      result.add('Kinh tế');
    }
    if (text.contains('lược sử') ||
        text.contains('sapiens') ||
        text.contains('gen') ||
        text.contains('thời gian') ||
        text.contains('khoa học') ||
        text.contains('vũ trụ')) {
      result.add('Khoa học');
    }

    if (result.isEmpty && publisher.isNotEmpty) {
      result.add(publisher);
    }
    return result;
  }
}
