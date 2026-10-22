import '../../../cart/domain/entities/cart_item.dart';

/// Tham số khi thực hiện đặt hàng
/// Tuân thủ Single Responsibility Principle (SRP)
class PlaceOrderParams {
  const PlaceOrderParams({
    required this.items,
    required this.receiverName,
    required this.phone,
    required this.shippingAddress,
    this.note,
  });

  final List<CartItem> items;
  final String receiverName;
  final String phone;
  final String shippingAddress;
  final String? note;

  /// Regex xác thực số điện thoại chuẩn Việt Nam:
  /// 10 chữ số, bắt đầu bằng các đầu số di động 03, 05, 07, 08, 09
  static final RegExp vnPhoneRegex = RegExp(r'^(?:0[35789])[0-9]{8}$');

  /// Kiểm tra tính hợp lệ của tham số
  String? validate() {
    if (items.isEmpty) {
      return 'Đơn hàng phải có ít nhất một cuốn sách';
    }

    final trimmedName = receiverName.trim();
    if (trimmedName.isEmpty) {
      return 'Họ tên người nhận không được để trống';
    }
    if (trimmedName.length < 2 || trimmedName.length > 100) {
      return 'Họ tên người nhận phải từ 2 đến 100 ký tự';
    }

    final trimmedPhone = phone.trim();
    if (trimmedPhone.isEmpty) {
      return 'Số điện thoại người nhận không được để trống';
    }
    if (!vnPhoneRegex.hasMatch(trimmedPhone)) {
      return 'Số điện thoại không đúng định dạng (10 chữ số, ví dụ 0912345678)';
    }

    final trimmedAddress = shippingAddress.trim();
    if (trimmedAddress.isEmpty) {
      return 'Địa chỉ giao hàng không được để trống';
    }
    if (trimmedAddress.length < 5 || trimmedAddress.length > 1000) {
      return 'Địa chỉ giao hàng phải từ 5 đến 1000 ký tự';
    }

    if (note != null && note!.trim().length > 2000) {
      return 'Ghi chú không được vượt quá 2000 ký tự';
    }

    return null;
  }
}
