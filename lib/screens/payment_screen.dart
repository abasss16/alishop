import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import 'profile_screen.dart';

class PaymentScreen extends StatefulWidget {
  final double total;
  const PaymentScreen({super.key, required this.total});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  int _selectedPayment = 0;
  String _selectedAddress = 'Rumah';
  bool _isProcessing = false;

  final List<Map<String, dynamic>> _paymentMethods = [
    {'name': 'Kartu Kredit / Debit', 'icon': Icons.credit_card, 'color': const Color(0xFF1565C0), 'detail': '**** **** **** 4242'},
    {'name': 'Transfer Bank', 'icon': Icons.account_balance, 'color': const Color(0xFF2E7D32), 'detail': 'BCA, BNI, BRI, Mandiri'},
    {'name': 'DANA', 'icon': Icons.account_balance_wallet, 'color': const Color(0xFF0097A7), 'detail': '08123456789'},
    {'name': 'GoPay', 'icon': Icons.account_balance_wallet_outlined, 'color': const Color(0xFF00AA13), 'detail': '08123456789'},
    {'name': 'COD (Bayar di Tempat)', 'icon': Icons.payments_outlined, 'color': const Color(0xFFE65100), 'detail': 'Bayar saat barang tiba'},
  ];

  final List<Map<String, dynamic>> _addresses = [
    {'label': 'Rumah', 'name': 'Budi Santoso', 'phone': '08123456789',
      'address': 'Jl. Merdeka No. 12, Bandung, Jawa Barat 40111', 'icon': Icons.home_outlined},
    {'label': 'Kantor', 'name': 'Budi Santoso', 'phone': '08198765432',
      'address': 'Jl. Asia Afrika No. 100, Bandung, Jawa Barat 40261', 'icon': Icons.business_outlined},
  ];

  void _processPayment() async {
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _isProcessing = false);
    final order = context.read<AppState>().placeOrder();
    _showSuccessDialog(order.id);
  }

  void _showSuccessDialog(String orderId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.1),
                  shape: BoxShape.circle),
                child: const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 48),
              ),
              const SizedBox(height: 16),
              const Text('Pembayaran Berhasil!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text('Pesanan Anda telah dikonfirmasi.\nEstimasi tiba 5-10 hari kerja.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600], fontSize: 13, height: 1.5)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0E8),
                  borderRadius: BorderRadius.circular(10)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.receipt_outlined, color: Color(0xFFFF6000), size: 16),
                    const SizedBox(width: 6),
                    Text('#$orderId',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFF6000))),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Kembali ke beranda
                    Navigator.of(context).popUntil((r) => r.isFirst);
                  },
                  child: const Text('Kembali ke Beranda'),
                ),
              ),
              const SizedBox(height: 8),
              // Tombol Lacak Pesanan - mengarahkan ke halaman akun/profile
              TextButton(
                onPressed: () {
                  // Tutup dialog
                  Navigator.of(context).pop();
                  // Navigasi ke halaman akun/profile
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  );
                },
                child: const Text('Lacak Pesanan',
                  style: TextStyle(color: Color(0xFFFF6000), fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final cart = appState.cart;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Pembayaran', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFFF6000),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          // Address section
          _sectionTitle('Alamat Pengiriman', Icons.location_on_outlined),
          const SizedBox(height: 8),
          ...(_addresses.map((addr) {
            final isSelected = addr['label'] == _selectedAddress;
            return GestureDetector(
              onTap: () => setState(() => _selectedAddress = addr['label']),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? const Color(0xFFFF6000) : Colors.transparent,
                    width: 1.5),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFFF6000).withOpacity(0.1)
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(10)),
                      child: Icon(addr['icon'],
                        color: isSelected ? const Color(0xFFFF6000) : Colors.grey, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFFFF6000)
                                      : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(6)),
                                child: Text(addr['label'],
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : Colors.grey,
                                    fontSize: 11, fontWeight: FontWeight.w600)),
                              ),
                              const SizedBox(width: 8),
                              Text(addr['name'],
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(addr['phone'],
                            style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                          const SizedBox(height: 2),
                          Text(addr['address'],
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                            maxLines: 2, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    if (isSelected)
                      const Icon(Icons.check_circle, color: Color(0xFFFF6000), size: 20),
                  ],
                ),
              ),
            );
          })),
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add, color: Color(0xFFFF6000)),
            label: const Text('Tambah Alamat Baru', style: TextStyle(color: Color(0xFFFF6000))),
          ),
          const SizedBox(height: 8),

          // Order summary
          _sectionTitle('Ringkasan Pesanan', Icons.receipt_long_outlined),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
            ),
            child: Column(
              children: [
                ...cart.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          item.product.imageUrl,
                          width: 44,
                          height: 44,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 44,
                              height: 44,
                              color: item.product.color,
                              child: Icon(item.product.icon, color: item.product.iconColor, size: 24),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(item.product.name,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                          maxLines: 2, overflow: TextOverflow.ellipsis),
                      ),
                      const SizedBox(width: 8),
                      Text('x${item.quantity}', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                      const SizedBox(width: 8),
                      Text('\$${(item.product.price * item.quantity).toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    ],
                  ),
                )),
                const Divider(),
                _payRow('Subtotal', '\$${widget.total.toStringAsFixed(2)}'),
                const SizedBox(height: 4),
                _payRow('Ongkos Kirim', 'GRATIS', color: Colors.green),
                const SizedBox(height: 4),
                _payRow('Voucher', '-\$0.00', color: Colors.orange),
                const Divider(),
                _payRow('Total', '\$${widget.total.toStringAsFixed(2)}',
                  bold: true, color: const Color(0xFFFF6000)),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Payment methods
          _sectionTitle('Metode Pembayaran', Icons.payment_outlined),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
            ),
            child: Column(
              children: _paymentMethods.asMap().entries.map((entry) {
                final i = entry.key;
                final method = entry.value;
                final isSelected = _selectedPayment == i;
                final isLast = i == _paymentMethods.length - 1;
                return GestureDetector(
                  onTap: () => setState(() => _selectedPayment = i),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      border: !isLast
                          ? Border(bottom: BorderSide(color: Colors.grey[200]!))
                          : null,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            color: (method['color'] as Color).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10)),
                          child: Icon(method['icon'] as IconData,
                            color: method['color'] as Color, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(method['name'],
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                              Text(method['detail'],
                                style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                            ],
                          ),
                        ),
                        Radio(
                          value: i, groupValue: _selectedPayment,
                          onChanged: (v) => setState(() => _selectedPayment = v!),
                          activeColor: const Color(0xFFFF6000),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),

          // Promo code
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
            ),
            child: Row(
              children: [
                const Icon(Icons.discount_outlined, color: Color(0xFFFF6000)),
                const SizedBox(width: 10),
                const Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Masukkan kode promo',
                      border: InputBorder.none,
                      hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('Pakai', style: TextStyle(color: Color(0xFFFF6000))),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, -3))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Pembayaran',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                Text('\$${widget.total.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900,
                    color: Color(0xFFFF6000))),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6000),
                  disabledBackgroundColor: Colors.orange[200],
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _isProcessing
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(width: 20, height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5)),
                          SizedBox(width: 12),
                          Text('Memproses...', style: TextStyle(fontSize: 15, color: Colors.white)),
                        ],
                      )
                    : const Text('Bayar Sekarang',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFFF6000), size: 18),
        const SizedBox(width: 6),
        Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _payRow(String label, String value, {bool bold = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
        Text(value,
          style: TextStyle(
            color: color ?? Colors.black87,
            fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
            fontSize: bold ? 15 : 13)),
      ],
    );
  }
}