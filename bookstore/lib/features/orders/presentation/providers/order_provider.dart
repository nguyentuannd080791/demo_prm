import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/error/app_exception.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/place_order_params.dart';
import '../../domain/repositories/order_repository.dart';

class OrderProvider extends ChangeNotifier {
  OrderProvider(this._repository);

  final OrderRepository _repository;

  List<Order> _orders = const [];
  // true ngay từ đầu để lần dựng đầu tiên hiện vòng xoay thay vì "chưa có đơn".
  bool _isLoading = true;
  bool _isPlacing = false;
  bool _isCancelling = false;
  String? _error;

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  bool get isPlacing => _isPlacing;
  bool get isCancelling => _isCancelling;
  String? get error => _error;

  /// Xóa dữ liệu của tài khoản trước. Gọi trước khi dựng giao diện
  /// (HomeShell.initState) nên không cần notifyListeners.
  void reset() {
    _orders = const [];
    _isLoading = true;
    _isCancelling = false;
    _error = null;
  }

  Future<void> loadOrders({bool isAdmin = false}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _orders = isAdmin
          ? await _repository.getAllOrders()
          : await _repository.getOrders();
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

  /// Hủy đơn hàng với kiểm tra trạng thái và độ dài lý do hủy
  Future<String?> cancelOrder(int id, {String? reason}) async {
    final trimmedReason = reason?.trim();
    if (trimmedReason != null && trimmedReason.length > 2000) {
      return 'Lý do hủy đơn không được vượt quá 2000 ký tự';
    }

    final targetOrder = _orders.cast<Order?>().firstWhere(
          (o) => o?.id == id,
          orElse: () => null,
        );
    if (targetOrder != null && !targetOrder.canCancel) {
      return 'Chỉ có thể hủy đơn hàng ở trạng thái Chờ duyệt hoặc Đã duyệt';
    }

    _isCancelling = true;
    notifyListeners();
    try {
      await _repository.cancelOrder(id, reason: trimmedReason);
      // Cập nhật trạng thái cục bộ để UI phản hồi tức thì
      _orders = _orders.map((o) {
        if (o.id == id) {
          return o.copyWith(status: 'CANCELLED');
        }
        return o;
      }).toList();
      return null;
    } on AppException catch (e) {
      return e.message;
    } catch (_) {
      return 'Không thể hủy đơn hàng, vui lòng thử lại';
    } finally {
      _isCancelling = false;
      notifyListeners();
    }
  }

  /// Trả về thông báo lỗi, hoặc null nếu đặt hàng thành công.
  Future<String?> placeOrder(PlaceOrderParams params) async {
    final validationError = params.validate();
    if (validationError != null) {
      return validationError;
    }

    _isPlacing = true;
    notifyListeners();
    try {
      await _repository.placeOrder(params);
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

  void _updateOrderStatus(int id, String newStatus) {
    _orders = _orders.map((o) {
      if (o.id == id) {
        return o.copyWith(status: newStatus);
      }
      return o;
    }).toList();
  }

  /// Duyệt đơn hàng (Admin/Staff)
  Future<String?> approveOrder(int id, {String? reason}) async {
    try {
      await _repository.approveOrder(id, reason: reason);
      _updateOrderStatus(id, 'APPROVED');
      notifyListeners();
      return null;
    } on AppException catch (e) {
      return e.message;
    } catch (_) {
      return 'Không thể duyệt đơn hàng, vui lòng thử lại';
    }
  }

  /// Từ chối đơn hàng (Admin/Staff)
  Future<String?> rejectOrder(int id, {String? reason}) async {
    try {
      await _repository.rejectOrder(id, reason: reason);
      _updateOrderStatus(id, 'REJECTED');
      notifyListeners();
      return null;
    } on AppException catch (e) {
      return e.message;
    } catch (_) {
      return 'Không thể từ chối đơn hàng, vui lòng thử lại';
    }
  }

  /// Bắt đầu giao đơn hàng (Admin/Staff)
  Future<String?> shipOrder(int id, {String? reason}) async {
    try {
      await _repository.shipOrder(id, reason: reason);
      _updateOrderStatus(id, 'SHIPPING');
      notifyListeners();
      return null;
    } on AppException catch (e) {
      return e.message;
    } catch (_) {
      return 'Không thể chuyển sang trạng thái giao hàng, vui lòng thử lại';
    }
  }

  /// Hoàn thành đơn hàng (Admin/Staff)
  Future<String?> completeOrder(int id, {String? reason}) async {
    try {
      await _repository.completeOrder(id, reason: reason);
      _updateOrderStatus(id, 'COMPLETED');
      notifyListeners();
      return null;
    } on AppException catch (e) {
      return e.message;
    } catch (_) {
      return 'Không thể hoàn thành đơn hàng, vui lòng thử lại';
    }
  }
}
