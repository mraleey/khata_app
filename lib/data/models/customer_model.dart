import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerModel {
  final String customerId;
  final String name;
  final String? phone;
  final String? email;
  final String shopkeeperUid;
  final String shopkeeperName;
  final double netBalance; // positive = they owe you (cash in), negative = you owe them (cash out)
  final DateTime updatedAt;

  CustomerModel({
    required this.customerId,
    required this.name,
    this.phone,
    this.email,
    required this.shopkeeperUid,
    required this.shopkeeperName,
    required this.netBalance,
    required this.updatedAt,
  });

  factory CustomerModel.fromMap(String id, Map<String, dynamic> map) {
    return CustomerModel(
      customerId: id,
      name: map['name'] as String,
      phone: map['phone'] as String?,
      email: map['email'] as String?,
      shopkeeperUid: map['shopkeeperUid'] as String? ?? '',
      shopkeeperName: map['shopkeeperName'] as String? ?? 'Unknown',
      netBalance: (map['netBalance'] as num).toDouble(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  factory CustomerModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CustomerModel.fromMap(doc.id, data);
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'shopkeeperUid': shopkeeperUid,
      'shopkeeperName': shopkeeperName,
      'netBalance': netBalance,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  CustomerModel copyWith({
    String? customerId,
    String? name,
    String? phone,
    String? email,
    String? shopkeeperUid,
    String? shopkeeperName,
    double? netBalance,
    DateTime? updatedAt,
  }) {
    return CustomerModel(
      customerId: customerId ?? this.customerId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      shopkeeperUid: shopkeeperUid ?? this.shopkeeperUid,
      shopkeeperName: shopkeeperName ?? this.shopkeeperName,
      netBalance: netBalance ?? this.netBalance,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
