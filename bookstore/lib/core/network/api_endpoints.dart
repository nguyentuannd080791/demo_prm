class ApiEndpoints {
  static const baseUrl = 'http://localhost:8080';

  static const login = '/api/auth/login';
  static const register = '/api/auth/register';
  static const books = '/api/books';
  static const orders = '/api/orders';
  static const myOrders = '/api/orders/my-orders';

  static String order(int id) => '/api/orders/$id';
  static String orderItems(int id) => '/api/orders/$id/items';
  static String orderHistory(int id) => '/api/orders/$id/history';
  static String cancelOrder(int id) => '/api/orders/$id/cancel';
  static String approveOrder(int id) => '/api/orders/$id/approve';
  static String rejectOrder(int id) => '/api/orders/$id/reject';
  static String shipOrder(int id) => '/api/orders/$id/ship';
  static String completeOrder(int id) => '/api/orders/$id/complete';
}
