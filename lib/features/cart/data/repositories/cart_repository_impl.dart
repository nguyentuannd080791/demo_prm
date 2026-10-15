import '../../domain/entities/cart.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/cart_local_datasource.dart';
import '../models/cart_item_model.dart';

class CartRepositoryImpl implements CartRepository {
  CartRepositoryImpl(this._local);

  final CartLocalDataSource _local;

  @override
  Future<Cart> getCart() async => Cart(List<CartItem>.of(_local.read()));

  @override
  Future<void> saveCart(Cart cart) {
    return _local.write(cart.items.map(CartItemModel.fromEntity).toList());
  }
}
