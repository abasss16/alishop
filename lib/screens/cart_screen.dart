import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../widgets/auth_gate.dart';
import 'payment_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final cart = appState.cart;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text('Keranjang (${appState.cartCount})',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: const Color(0xFFFF6000),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (cart.isNotEmpty)
            TextButton(
              onPressed: () => _showClearDialog(context, appState),
              child: const Text('Hapus Semua', style: TextStyle(color: Colors.white70, fontSize: 13)),
            ),
        ],
      ),
      body: cart.isEmpty
          ? _buildEmpty(context)
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: cart.length,
                    itemBuilder: (context, i) => _buildCartItem(context, cart[i], appState),
                  ),
                ),
                _buildSummary(context, appState),
              ],
            ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100, height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF0E8),
              borderRadius: BorderRadius.circular(50)),
            child: const Icon(Icons.shopping_cart_outlined,
              size: 50, color: Color(0xFFFF6000)),
          ),
          const SizedBox(height: 20),
          const Text('Keranjang Kosong',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Yuk tambah produk ke keranjang!',
            style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Mulai Belanja'),
          ),
        ],
      ),
    );
  }

// Update _buildCartItem method in cart_screen.dart
Widget _buildCartItem(BuildContext context, CartItem item, AppState appState) {
  final p = item.product;
  return Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
    ),
    child: Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            p.imageUrl,
            width: 76,
            height: 76,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 76,
                height: 76,
                color: p.color,
                child: Icon(p.icon, size: 40, color: p.iconColor),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(p.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text('\$${p.price.toStringAsFixed(2)}',
                    style: const TextStyle(color: Color(0xFFFF6000),
                      fontWeight: FontWeight.w800, fontSize: 14)),
                  const SizedBox(width: 6),
                  Text('-${p.discount}',
                    style: const TextStyle(color: Colors.grey, fontSize: 11)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => appState.updateQty(p.id, item.quantity - 1),
                    child: Container(
                      width: 28, height: 28,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.remove, size: 14),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('${item.quantity}',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  ),
                  GestureDetector(
                    onTap: () => appState.updateQty(p.id, item.quantity + 1),
                    child: Container(
                      width: 28, height: 28,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6000),
                        borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.add, size: 14, color: Colors.white),
                    ),
                  ),
                  const Spacer(),
                  Text('\$${(p.price * item.quantity).toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                ],
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => appState.removeFromCart(p.id),
          child: Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 50),
            child: Icon(Icons.close, color: Colors.grey[400], size: 18),
          ),
        ),
      ],
    ),
  );
}

  Widget _buildSummary(BuildContext context, AppState appState) {
    final subtotal = appState.cartTotal;
    const shipping = 0.0;
    const tax = 0.0;
    final total = subtotal + shipping + tax;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, -3))],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          _summaryRow('Subtotal', '\$${subtotal.toStringAsFixed(2)}'),
          const SizedBox(height: 6),
          _summaryRow('Ongkir', 'GRATIS', valueColor: Colors.green),
          const SizedBox(height: 6),
          _summaryRow('Pajak', '\$${tax.toStringAsFixed(2)}'),
          const Divider(height: 20),
          _summaryRow('Total', '\$${total.toStringAsFixed(2)}',
            isBold: true, valueColor: const Color(0xFFFF6000)),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: Builder(builder: (ctx) {
              final appState = ctx.watch<AppState>();
              final isLoggedIn = !appState.isGuest && appState.user != null;
              return ElevatedButton(
                onPressed: () async {
                  final ok = await requireLogin(ctx,
                      reason: 'Login untuk melanjutkan ke pembayaran');
                  if (ok && ctx.mounted) {
                    Navigator.push(ctx,
                      MaterialPageRoute(
                        builder: (_) => PaymentScreen(total: total)));
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6000),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Lanjut Pembayaran • \$${total.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    if (!isLoggedIn) ...[
                      const SizedBox(width: 6),
                      const Icon(Icons.lock_outline, size: 14),
                    ],
                  ]),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value,
      {bool isBold = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
          style: TextStyle(color: Colors.grey[600], fontSize: 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        Text(value,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            fontSize: isBold ? 16 : 13,
            color: valueColor ?? Colors.black87)),
      ],
    );
  }

  void _showClearDialog(BuildContext context, AppState appState) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Semua?'),
        content: const Text('Yakin ingin menghapus semua item dari keranjang?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal', style: TextStyle(color: Colors.grey[600]))),
          ElevatedButton(
            onPressed: () { appState.clearCart(); Navigator.pop(context); },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}