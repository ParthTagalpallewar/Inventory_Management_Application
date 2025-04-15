class Receipt {
  final int id;
  final String name;
  final String address;
  final String phone;
  final String email;
  final double gst;
  final String gstin;
  final String date;

  Receipt({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.email,
    required this.gst,
    required this.gstin,
    required this.date,
  });

  factory Receipt.fromMap(Map<String, dynamic> map) {
    return Receipt(
      id: map['receipt_id'],
      name: map['customer_name'],
      address: map['customer_address'],
      phone: map['mobile_number'],
      email: map['email_address'],
      gst: map['gst_percentage'],
      gstin: map['gstin_number'] ?? '',
      date: map['date'],
    );
  }
}
