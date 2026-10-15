import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/error/app_exception.dart';
import '../../../cart/domain/entities/cart_item.dart';
import '../../domain/entities/order.dart';
import '../../domain/repositories/order_repository.dart';

class OrderProvider extends ChangeNotifier {
  OrderProvider(this._repository);

  final OrderRepository _repository;

  List<Order> _orders = const [];
  // true ngay từ đầu để lần dựng đầu tiên hiện vòng xoay thay vì "chưa có đơn".
  bool _isLoading = true;
  bool _isPlacing = false;
  String? _error;

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  bool get isPlacing => _isPlacing;
  String? get error => _error;

  /// Xóa dữ liệu của tài khoản trước. Gọi trước khi dựng giao diện
  /// (HomeShell.initState) nên không cần notifyListeners.
  void reset() {
    _orders = const [];
    _isLoading = true;
    _error = null;
  }

  Future<void> loadOrders() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _orders = await _repository.getOrders();
    } on AppException catch (e) {
      _error = e.message;
    } catch (_) {
      _error = 'Không tải được danh sách đơn hàng';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Order> fetchOrder(int id) => _repository.getOrder(id);

  /// Trả về thông báo lỗi, hoặc null nếu đặt hàng thành công.
  Future<String?> placeOrder(List<CartItem> items) async {
    _isPlacing = true;
    notifyListeners();
    try {
      await _repository.placeOrder(items);
      unawaited(loadOrders());
      return null;
    } on AppException catch (e) {
      return e.message;
    } catch (_) {
      return 'Đặt hàng thất bại, vui lòng thử lại';
    } finally {
      _isPlacing = false;
      notifyListeners();
    }
  }
}
