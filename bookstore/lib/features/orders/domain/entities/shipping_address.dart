/// Đại diện cho một địa chỉ giao hàng của người nhận
/// Tuân thủ Single Responsibility Principle (SRP)
class ShippingAddress {
  const ShippingAddress({
    required this.id,
    required this.receiverName,
    required this.phone,
    required this.address,
    this.isDefault = false,
  });

  final String id;
  final String receiverName;
  final String phone;
  final String address;
  final bool isDefault;

  ShippingAddress copyWith({
    String? id,
    String? receiverName,
    String? phone,
    String? address,
    bool? isDefault,
  }) {
    return ShippingAddress(
      id: id ?? this.id,
      receiverName: receiverName ?? this.receiverName,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'receiverName': receiverName,
        'phone': phone,
        'address': address,
        'isDefault': isDefault,
      };

  factory ShippingAddress.fromJson(Map<String, dynamic> json) {
    return ShippingAddress(
      id: (json['id'] ?? '').toString(),
      receiverName: (json['receiverName'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      address: (json['address'] ?? '').toString(),
      isDefault: json['isDefault'] == true,
    );
  }
}
