import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../screens/auth_screen.dart';

/// Fungsi global untuk memicu login. 
/// Mengembalikan [true] jika berhasil login atau sudah login.
Future<bool> requireLogin(BuildContext context, {String? reason}) async {
  final appState = context.read<AppState>();
  
  // Jika sudah login, langsung return true
  if (!appState.isGuest && appState.user != null) return true;

  // Tampilkan bottom sheet dan tunggu hasilnya
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _LoginGateSheet(reason: reason),
  );

  // Jika result null (karena diswipe), maka return false
  return result ?? false;
}

/// Widget untuk membungkus konten yang memerlukan login.
class AuthGateWidget extends StatelessWidget {
  final Widget child;
  final String? reason;
  final bool showOverlay;

  const AuthGateWidget({
    super.key,
    required this.child,
    this.reason,
    this.showOverlay = true,
  });

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final bool isLocked = appState.isGuest || appState.user == null;

    if (!isLocked || !showOverlay) return child;

    return Stack(
      children: [
        Opacity(opacity: 0.35, child: child),
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => requireLogin(context, reason: reason),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 20,
                      )
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 52, height: 52,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF0E8),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.lock_outline_rounded,
                            color: Color(0xFFFF6000), size: 28),
                      ),
                      const SizedBox(height: 10),
                      const Text('Masuk Diperlukan',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 4),
                      Text(reason ?? 'Login untuk mengakses fitur ini',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6000),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text('Masuk Sekarang',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            )),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── LOGIN GATE BOTTOM SHEET ──────────────────────────────────────────────────

class _LoginGateSheet extends StatelessWidget {
  final String? reason;
  const _LoginGateSheet({this.reason});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
          24, 16, 24, MediaQuery.of(context).padding.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Lock Icon with Gradient
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFF6000), Color(0xFFFF9A3C)],
              ),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF6000).withOpacity(0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                )
              ],
            ),
            child: const Icon(Icons.lock_outline_rounded, color: Colors.white, size: 36),
          ),
          const SizedBox(height: 18),

          const Text('Login Diperlukan',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text(
            reason ?? 'Silakan masuk atau daftar terlebih dahulu\nuntuk menggunakan fitur ini.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600], fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 20),

          // Fitur yang akan didapat
          _featureRow(Icons.shopping_bag_outlined, 'Buat & lacak pesanan'),
          _featureRow(Icons.chat_bubble_outline, 'Chat dengan penjual'),
          _featureRow(Icons.favorite_outline, 'Simpan wishlist'),
          _featureRow(Icons.local_offer_outlined, 'Akses promo eksklusif'),

          const SizedBox(height: 24),

          // Tombol Login
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                // Navigasi ke halaman login dan tunggu hasilnya
                // Pastikan di AuthScreen, jika login berhasil panggil Navigator.pop(context, true)
                final success = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(builder: (_) => const AuthScreen()),
                );

                if (context.mounted) {
                  // Tutup bottom sheet dan kirim status login terakhir
                  // Jika success null, cek manual via provider sebagai fallback
                  final isLoggedIn = success == true || context.read<AppState>().user != null;
                  Navigator.pop(context, isLoggedIn);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6000),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Masuk / Daftar',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 10),

          // Tombol Kembali
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context, false),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.grey[700],
                side: BorderSide(color: Colors.grey[300]!),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Lanjut Sebagai Tamu (Terbatas)',
                  style: TextStyle(fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _featureRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF0E8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFFFF6000), size: 16),
          ),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          const Spacer(),
          const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 16),
        ],
      ),
    );
  }
}