/// Tham số tìm kiếm và kết hợp bộ lọc danh sách sách (Từ khóa, Tag/Thể loại, Khoảng giá, Trạng thái)
/// Tuân thủ Single Responsibility Principle (SRP) và Open/Closed Principle (OCP)
class BookFilterParams {
  const BookFilterParams({
    this.keyword,
    this.tag,
    this.isbn,
    this.categoryId,
    this.minPrice,
    this.maxPrice,
    this.minStock,
    this.maxStock,
    this.status,
  });

  final String? keyword;
  final String? tag;
  final String? isbn;
  final int? categoryId;
  final double? minPrice;
  final double? maxPrice;
  final int? minStock;
  final int? maxStock;
  final String? status; // 'ACTIVE', 'INACTIVE', hoặc null/'ALL'

  /// Kiểm tra có áp dụng bộ lọc nâng cao (khoảng giá, trạng thái) không
  bool get hasAdvancedFilters =>
      (minPrice != null && minPrice! > 0) ||
      (maxPrice != null && maxPrice! > 0) ||
      (status != null && status!.isNotEmpty && status != 'ALL');

  /// Kiểm tra xem hiện tại có bất kỳ tiêu chí lọc nào đang kích hoạt hay không
  bool get hasActiveFilters =>
      (keyword != null && keyword!.trim().isNotEmpty) ||
      (tag != null && tag!.isNotEmpty && tag != 'Tất cả') ||
      hasAdvancedFilters;

  BookFilterParams copyWith({
    String? keyword,
    String? tag,
    String? isbn,
    int? categoryId,
    double? minPrice,
    double? maxPrice,
    int? minStock,
    int? maxStock,
    String? status,
    bool clearKeyword = false,
    bool clearTag = false,
    bool clearMinPrice = false,
    bool clearMaxPrice = false,
    bool clearStatus = false,
  }) {
    return BookFilterParams(
      keyword: clearKeyword ? null : (keyword ?? this.keyword),
      tag: clearTag ? null : (tag ?? this.tag),
      isbn: isbn ?? this.isbn,
      categoryId: categoryId ?? this.categoryId,
      minPrice: clearMinPrice ? null : (minPrice ?? this.minPrice),
      maxPrice: clearMaxPrice ? null : (maxPrice ?? this.maxPrice),
      minStock: minStock ?? this.minStock,
      maxStock: maxStock ?? this.maxStock,
      status: clearStatus ? null : (status ?? this.status),
    );
  }

  /// Chuyển đổi thành Map query parameters chuẩn cho API GET /api/books
  Map<String, String> toQueryParameters() {
    final query = <String, String>{};

    if (keyword != null && keyword!.trim().isNotEmpty) {
      query['keyword'] = keyword!.trim();
    }
    if (isbn != null && isbn!.trim().isNotEmpty) {
      query['isbn'] = isbn!.trim();
    }
    if (categoryId != null && categoryId! > 0) {
      query['categoryId'] = categoryId.toString();
    }
    if (minPrice != null && minPrice! >= 0) {
      query['minPrice'] = minPrice!.toStringAsFixed(0);
    }
    if (maxPrice != null && maxPrice! >= 0) {
      query['maxPrice'] = maxPrice!.toStringAsFixed(0);
    }
    if (minStock != null && minStock! >= 0) {
      query['minStock'] = minStock.toString();
    }
    if (maxStock != null && maxStock! >= 0) {
      query['maxStock'] = maxStock.toString();
    }
    if (status != null && status!.isNotEmpty && status != 'ALL') {
      query['status'] = status!;
    }

    return query;
  }
}
