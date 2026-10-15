class ApiEndpoints {
  static const baseUrl = 'http://localhost:8080';

  static const login = '/api/auth/login';
  static const register = '/api/auth/register';
  static const books = '/api/books';
  static const orders = '/api/orders';

  static String order(int id) => '/api/orders/$id';
}
