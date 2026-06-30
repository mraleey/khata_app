import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerModel {
  final String customerId;
  final String name;
  final String? phone;
  final double netBalance; // positive = they owe you (cash in), negative = you owe them (cash out)
  final DateTime updatedAt;

  CustomerModel({
    required this.customerId,
    required this.name,
    this.phone,
    required this.netBalance,
    required this.updatedAt,
  });

  factory CustomerModel.fromMap(String id, Map<String, dynamic> map) {
    return CustomerModel(
      customerId: id,
      name: map['name'] as String,
      phone: map['phone'] as String?,
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
      'netBalance': netBalance,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  CustomerModel copyWith({
    String? customerId,
    String? name,
    String? phone,
    double? netBalance,
    DateTime? updatedAt,
  }) {
    return CustomerModel(
      customerId: customerId ?? this.customerId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      netBalance: netBalance ?? this.netBalance,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
