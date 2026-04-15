import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../widgets/auth_gate.dart';
import 'auth_screen.dart';
import 'chat_screen.dart';
import 'product_detail_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final user = appState.user;
    final isGuest = appState.isGuest;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(context, appState, user, isGuest)),
          if (isGuest)
            SliverToBoxAdapter(child: _buildGuestBanner(context)),
          SliverToBoxAdapter(
            child: _OrderStatusPanel(appState: appState),
          ),
          if (appState.orders.isNotEmpty)
            SliverToBoxAdapter(
              child: _RecentOrdersList(appState: appState),
            ),
          if (appState.wishlist.isNotEmpty)
            SliverToBoxAdapter(child: _buildWishlist(context, appState)),
          SliverToBoxAdapter(child: _buildMenu(context, appState)),
          const SliverToBoxAdapter(child: SizedBox(height: 30)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppState appState,
      UserModel? user, bool isGuest) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [Color(0xFFFF4500), Color(0xFFFF6000), Color(0xFFFF9A3C)]),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 26),
          child: Column(
            children: [
              Row(children: [
                const Text('Akun Saya',
                  style: TextStyle(color: Colors.white, fontSize: 20,
                    fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                  onPressed: () {}),
                IconButton(
                  icon: const Icon(Icons.settings_outlined, color: Colors.white),
                  onPressed: () {}),
              ]),
              const SizedBox(height: 14),
              Row(children: [
                Container(
                  width: 68, height: 68,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle, color: Colors.white,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15),
                      blurRadius: 12, offset: const Offset(0, 4))]),
                  child: Icon(isGuest ? Icons.person_outline : Icons.person,
                    size: 36, color: const Color(0xFFFF6000)),
                ),
                const SizedBox(width: 14),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(isGuest ? 'Pengguna Tamu' : (user?.name ?? ''),
                      style: const TextStyle(color: Colors.white,
                        fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 3),
                    Text(isGuest ? 'Masuk untuk pengalaman lebih baik'
                      : (user?.email ?? ''),
                      style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    if (!isGuest && (user?.phone.isNotEmpty ?? false)) ...[
                      const SizedBox(height: 2),
                      Text(user!.phone,
                        style: const TextStyle(color: Colors.white60, fontSize: 12)),
                    ],
                  ],
                )),
                if (!isGuest)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20)),
                    child: const Text('Edit',
                      style: TextStyle(color: Colors.white, fontSize: 12))),
              ]),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16)),
                child: Row(children: [
                  _statItem('${appState.orders.length}', 'Pesanan'),
                  _vDivider(),
                  _statItem('${appState.ordersWithStatus(OrderStatus.completed)}', 'Selesai'),
                  _vDivider(),
                  _statItem('${appState.wishlist.length}', 'Wishlist'),
                  _vDivider(),
                  _statItem('0', 'Ulasan'),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statItem(String value, String label) => Expanded(
    child: Column(children: [
      Text(value, style: const TextStyle(color: Colors.white,
        fontSize: 20, fontWeight: FontWeight.w800)),
      const SizedBox(height: 2),
      Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
    ]),
  );

  Widget _vDivider() =>
      Container(width: 1, height: 36, color: Colors.white.withOpacity(0.3));

  Widget _buildGuestBanner(BuildContext context) => Container(
    margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF0E8),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFFFF6000).withOpacity(0.3))),
    child: Row(children: [
      const Icon(Icons.info_outline, color: Color(0xFFFF6000)),
      const SizedBox(width: 10),
      const Expanded(
        child: Text('Daftar atau masuk untuk menikmati fitur lengkap',
          style: TextStyle(color: Color(0xFFFF6000), fontSize: 13))),
      TextButton(
        onPressed: () => Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => const AuthScreen())),
        child: const Text('Masuk', style: TextStyle(
          color: Color(0xFFFF6000), fontWeight: FontWeight.bold))),
    ]),
  );

  Widget _buildWishlist(BuildContext context, AppState appState) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Wishlist Saya',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          TextButton(onPressed: () {},
            child: const Text('Lihat Semua',
              style: TextStyle(color: Color(0xFFFF6000)))),
        ]),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: appState.wishlist.length,
            itemBuilder: (ctx, i) {
              final p = appState.wishlist[i];
              return GestureDetector(
                onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => ProductDetailScreen(product: p))),
                child: Container(
                  width: 100, margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: Colors.white, borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(
                      color: Colors.black.withOpacity(0.04), blurRadius: 4)]),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        p.imageUrl,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 56,
                            height: 56,
                            color: p.color,
                            child: Icon(p.icon, color: p.iconColor, size: 28),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 6),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Text(p.name,
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
                        maxLines: 2, overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center)),
                  ]),
                ),
              );
            },
          ),
        ),
      ]),
    );
  }

  Widget _buildMenu(BuildContext context, AppState appState) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Lainnya',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        _menuCard([
          _menuTile(Icons.location_on_outlined, 'Alamat Saya', Colors.blue, () {
            _showAddressPage(context, appState);
          }),
          _menuTile(Icons.credit_card_outlined, 'Metode Pembayaran', Colors.green, () {
            _showPaymentMethodsPage(context);
          }),
          _menuTile(Icons.chat_bubble_outline_rounded, 'Pesan & Chat', const Color(0xFF3D5AFE), () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatListScreen()));
          }),
          _menuTile(Icons.discount_outlined, 'Voucher & Promo', Colors.orange, () {
            _showVoucherPage(context);
          }),
          _menuTile(Icons.star_outline, 'Ulasan Saya', Colors.amber, () {
            _showReviewsPage(context, appState);
          }),
          _menuTile(Icons.headset_mic_outlined, 'Pusat Bantuan', Colors.teal, () {
            _showHelpCenterPage(context);
          }),
          _menuTile(Icons.privacy_tip_outlined, 'Privasi', Colors.purple, () {
            _showPrivacyPage(context);
          }),
          _menuTile(Icons.info_outline, 'Tentang AliShop', Colors.indigo, () {
            _showAboutPage(context);
          }),
        ]),
        const SizedBox(height: 10),
        _menuCard([
          _menuTile(Icons.logout, 'Keluar', Colors.red,
            () => _showLogoutDialog(context, appState), isDestructive: true),
        ]),
        const SizedBox(height: 20),
        Center(child: Text('AliShop v2.1.0',
          style: TextStyle(color: Colors.grey[400], fontSize: 12))),
      ]),
    );
  }

  Widget _menuCard(List<Widget> children) => Container(
    decoration: BoxDecoration(
      color: Colors.white, borderRadius: BorderRadius.circular(14),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)]),
    child: Column(children: children),
  );

  Widget _menuTile(IconData icon, String title, Color color, VoidCallback onTap,
      {bool isDestructive = false}) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon,
          color: isDestructive ? Colors.red : color, size: 20)),
      title: Text(title,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500,
          color: isDestructive ? Colors.red : Colors.black87)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
    );
  }

  // ==================== MENU FUNCTIONS ====================

  void _showAddressPage(BuildContext context, AppState appState) {
    final user = appState.user;
    final isGuest = appState.isGuest;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Container(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).padding.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Alamat Saya',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            if (isGuest)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0E8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock_outline, color: Color(0xFFFF6000)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Login Diperlukan',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('Silakan login untuk melihat alamat tersimpan',
                            style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const AuthScreen()));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6000),
                      ),
                      child: const Text('Login'),
                    ),
                  ],
                ),
              )
            else
              Column(
                children: [
                  _buildAddressCard(
                    'Rumah',
                    user?.name ?? 'Pengguna',
                    user?.phone ?? '08123456789',
                    'Jl. Merdeka No. 12, Bandung, Jawa Barat 40111',
                    true,
                  ),
                  const SizedBox(height: 12),
                  _buildAddressCard(
                    'Kantor',
                    user?.name ?? 'Pengguna',
                    '08198765432',
                    'Jl. Asia Afrika No. 100, Bandung, Jawa Barat 40261',
                    false,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.add),
                    label: const Text('Tambah Alamat Baru'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6000),
                      minimumSize: const Size(double.infinity, 45),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressCard(String label, String name, String phone, String address, bool isDefault) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDefault ? const Color(0xFFFF6000) : Colors.grey[200]!,
          width: isDefault ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isDefault ? const Color(0xFFFF6000) : Colors.grey[200],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(label,
                  style: TextStyle(
                    color: isDefault ? Colors.white : Colors.grey[600],
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  )),
              ),
              const SizedBox(width: 8),
              Text(name,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              if (isDefault) ...[
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('Utama',
                    style: TextStyle(color: Color(0xFF4CAF50), fontSize: 10)),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(phone,
            style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          const SizedBox(height: 4),
          Text(address,
            style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          const SizedBox(height: 12),
          Row(
            children: [
              if (!isDefault)
                TextButton(
                  onPressed: () {},
                  child: const Text('Jadikan Utama',
                    style: TextStyle(color: Color(0xFFFF6000), fontSize: 12)),
                ),
              const Spacer(),
              TextButton(
                onPressed: () {},
                child: const Text('Edit',
                  style: TextStyle(color: Colors.grey, fontSize: 12)),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () {},
                child: const Text('Hapus',
                  style: TextStyle(color: Colors.red, fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showPaymentMethodsPage(BuildContext context) {
    final List<Map<String, dynamic>> paymentMethods = [
      {'name': 'Kartu Kredit / Debit', 'icon': Icons.credit_card, 'color': const Color(0xFF1565C0), 'number': '**** **** **** 4242', 'expiry': '12/28'},
      {'name': 'Transfer Bank', 'icon': Icons.account_balance, 'color': const Color(0xFF2E7D32), 'number': 'BCA - 1234567890', 'expiry': null},
      {'name': 'DANA', 'icon': Icons.account_balance_wallet, 'color': const Color(0xFF0097A7), 'number': '08123456789', 'expiry': null},
      {'name': 'GoPay', 'icon': Icons.account_balance_wallet_outlined, 'color': const Color(0xFF00AA13), 'number': '08123456789', 'expiry': null},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Container(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).padding.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Metode Pembayaran',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...paymentMethods.map((method) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: (method['color'] as Color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(method['icon'] as IconData,
                      color: method['color'] as Color, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(method['name'],
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                        Text(method['number'],
                          style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                        if (method['expiry'] != null)
                          Text('Expiry: ${method['expiry']}',
                            style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert, color: Colors.grey),
                    onPressed: () {},
                  ),
                ],
              ),
            )),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add),
              label: const Text('Tambah Metode Pembayaran'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6000),
                minimumSize: const Size(double.infinity, 45),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showVoucherPage(BuildContext context) {
    final List<Map<String, dynamic>> vouchers = [
      {'code': 'WELCOME50', 'discount': '50%', 'min': 'Min. belanja \$20', 'expiry': 'Berlaku 30 hari', 'color': const Color(0xFFFF6B35)},
      {'code': 'GRATISONGKIR', 'discount': 'FREE', 'min': 'Min. belanja \$50', 'expiry': 'Berlaku 7 hari', 'color': const Color(0xFF00B4D8)},
      {'code': 'FLASH10', 'discount': '10%', 'min': 'Min. belanja \$15', 'expiry': 'Berlaku 3 hari', 'color': const Color(0xFFE91E63)},
      {'code': 'NEWUSER20', 'discount': '20%', 'min': 'Min. belanja \$25', 'expiry': 'Berlaku 14 hari', 'color': const Color(0xFF4CAF50)},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Container(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).padding.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Voucher & Promo',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Koleksi voucher eksklusif untuk Anda',
              style: TextStyle(color: Colors.grey[600], fontSize: 13)),
            const SizedBox(height: 16),
            ...vouchers.map((voucher) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [voucher['color'], voucher['color'].withOpacity(0.7)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50, height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(voucher['discount'],
                        style: TextStyle(
                          color: voucher['color'],
                          fontSize: voucher['discount'] == 'FREE' ? 12 : 14,
                          fontWeight: FontWeight.bold,
                        )),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(voucher['code'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          )),
                        Text(voucher['min'],
                          style: TextStyle(color: Colors.white70, fontSize: 11)),
                        Text(voucher['expiry'],
                          style: TextStyle(color: Colors.white60, fontSize: 10)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('Pakai',
                      style: TextStyle(color: Color(0xFFFF6000), fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  void _showReviewsPage(BuildContext context, AppState appState) {
    final completedOrders = appState.orders.where((o) => o.status == OrderStatus.completed).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Container(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).padding.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Ulasan Saya',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('${completedOrders.length} produk yang bisa diulas',
              style: TextStyle(color: Colors.grey[600], fontSize: 13)),
            const SizedBox(height: 16),
            if (completedOrders.isEmpty)
              Container(
                padding: const EdgeInsets.all(40),
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Icon(Icons.star_border, size: 64, color: Colors.grey[300]),
                    const SizedBox(height: 12),
                    Text('Belum ada ulasan',
                      style: TextStyle(color: Colors.grey[500])),
                    const SizedBox(height: 4),
                    Text('Selesaikan pesanan pertama Anda untuk memberikan ulasan',
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                      textAlign: TextAlign.center),
                  ],
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: completedOrders.length,
                itemBuilder: (context, index) {
                  final order = completedOrders[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('#${order.id}',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        ...order.items.take(2).map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  item.product.imageUrl,
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 40,
                                      height: 40,
                                      color: item.product.color,
                                      child: Icon(item.product.icon, size: 20),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(item.product.name,
                                  style: const TextStyle(fontSize: 12),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis),
                              ),
                              ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFF6000),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                ),
                                child: const Text('Beri Ulasan',
                                  style: TextStyle(fontSize: 11)),
                              ),
                            ],
                          ),
                        )),
                        if (order.items.length > 2)
                          Text('+${order.items.length - 2} produk lainnya',
                            style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showHelpCenterPage(BuildContext context) {
    final List<Map<String, dynamic>> helpTopics = [
      {'title': 'Cara Melacak Pesanan', 'icon': Icons.track_changes, 'color': const Color(0xFFFF6000)},
      {'title': 'Panduan Pengembalian Barang', 'icon': Icons.assignment_return, 'color': const Color(0xFF2196F3)},
      {'title': 'Metode Pembayaran', 'icon': Icons.payment, 'color': const Color(0xFF4CAF50)},
      {'title': 'Pusat Keamanan', 'icon': Icons.security, 'color': const Color(0xFF9C27B0)},
      {'title': 'FAQ', 'icon': Icons.help_outline, 'color': const Color(0xFFFF9800)},
      {'title': 'Hubungi Kami', 'icon': Icons.headset_mic, 'color': const Color(0xFF00BCD4)},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Container(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).padding.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Pusat Bantuan',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Ada yang bisa kami bantu?',
              style: TextStyle(color: Colors.grey[600], fontSize: 13)),
            const SizedBox(height: 16),
            Container(
              height: 45,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Cari bantuan...',
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ...helpTopics.map((topic) => ListTile(
              leading: Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: (topic['color'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(topic['icon'] as IconData,
                  color: topic['color'] as Color, size: 20),
              ),
              title: Text(topic['title'],
                style: const TextStyle(fontWeight: FontWeight.w500)),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () {},
            )),
          ],
        ),
      ),
    );
  }

  void _showPrivacyPage(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Container(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).padding.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Kebijakan Privasi',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPrivacySection(
                      'Pengumpulan Data',
                      'Kami mengumpulkan informasi yang Anda berikan saat mendaftar, seperti nama, email, dan nomor telepon.',
                    ),
                    const SizedBox(height: 16),
                    _buildPrivacySection(
                      'Penggunaan Data',
                      'Data digunakan untuk memproses pesanan, mengirim notifikasi, dan meningkatkan layanan kami.',
                    ),
                    const SizedBox(height: 16),
                    _buildPrivacySection(
                      'Perlindungan Data',
                      'Kami menggunakan enkripsi dan protokol keamanan untuk melindungi data pribadi Anda.',
                    ),
                    const SizedBox(height: 16),
                    _buildPrivacySection(
                      'Berbagi Data',
                      'Kami tidak menjual data pribadi Anda. Data hanya dibagikan dengan mitra pengiriman untuk memproses pesanan.',
                    ),
                    const SizedBox(height: 16),
                    _buildPrivacySection(
                      'Hak Anda',
                      'Anda dapat mengakses, memperbaiki, atau menghapus data pribadi Anda kapan saja.',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6000),
                minimumSize: const Size(double.infinity, 45),
              ),
              child: const Text('Setuju & Tutup'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacySection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text(content,
          style: TextStyle(color: Colors.grey[600], fontSize: 13, height: 1.5)),
      ],
    );
  }

  void _showAboutPage(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Container(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).padding.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF4500), Color(0xFFFF6000)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: Text('ali',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 16),
            const Text('AliShop',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const Text('Version 2.1.0',
              style: TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 8),
            Text('Belanja Global, Harga Lokal',
              style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildAboutRow('Developer', 'Adam Bayu Saputra'),
                  const Divider(height: 16),
                  _buildAboutRow('Email', 'adambayusaputra160606.com'),
                  const Divider(height: 16),
                  _buildAboutRow('Website', 'abasss16.github.io'),
                  const Divider(height: 16),
                  _buildAboutRow('© 2026', 'AliShop. All rights reserved.'),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
          style: TextStyle(color: Colors.grey[600], fontSize: 13)),
        Text(value,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context, AppState appState) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Keluar?'),
        content: const Text('Yakin ingin keluar dari akun?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal', style: TextStyle(color: Colors.grey[600]))),
          ElevatedButton(
            onPressed: () {
              appState.logout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const AuthScreen()),
                (route) => false);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Keluar')),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ORDER STATUS PANEL — 4 tiles with order count + product quantity
// ─────────────────────────────────────────────────────────────────────────────
class _OrderStatusPanel extends StatelessWidget {
  final AppState appState;
  const _OrderStatusPanel({required this.appState});

  static const _statuses = [
    OrderStatus.waitingPayment,
    OrderStatus.packing,
    OrderStatus.shipped,
    OrderStatus.completed,
  ];

  static const _labels = ['Menunggu\nBayar', 'Dikemas', 'Dikirim', 'Selesai'];
  static const _icons = [
    Icons.payment_outlined,
    Icons.inventory_2_outlined,
    Icons.local_shipping_outlined,
    Icons.check_circle_outline,
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Text('Status Pesanan',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const Spacer(),
          if (appState.orders.any((o) => !o.isFinished))
            _AutoAdvanceBadge(),
        ]),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(
              color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 3))]),
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 16, 8, 10),
              child: Row(
                children: List.generate(4, (i) => Expanded(
                  child: _StatusTile(
                    icon: _icons[i],
                    label: _labels[i],
                    status: _statuses[i],
                    orderCount: appState.ordersWithStatus(_statuses[i]),
                    itemCount: appState.itemsWithStatus(_statuses[i]),
                  ),
                )),
              ),
            ),
            _StatusProgressBar(appState: appState),
            const SizedBox(height: 12),
          ]),
        ),
      ]),
    );
  }
}

class _AutoAdvanceBadge extends StatefulWidget {
  @override
  State<_AutoAdvanceBadge> createState() => _AutoAdvanceBadgeState();
}

class _AutoAdvanceBadgeState extends State<_AutoAdvanceBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      FadeTransition(
        opacity: _ctrl,
        child: Container(
          width: 7, height: 7,
          decoration: const BoxDecoration(
            color: Color(0xFF4CAF50), shape: BoxShape.circle)),
      ),
      const SizedBox(width: 5),
      Text('',
        style: TextStyle(fontSize: 10, color: Colors.grey[500])),
    ]);
  }
}

class _StatusTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final OrderStatus status;
  final int orderCount;
  final int itemCount;

  const _StatusTile({
    required this.icon,
    required this.label,
    required this.status,
    required this.orderCount,
    required this.itemCount,
  });

  Color get _activeColor {
    switch (status) {
      case OrderStatus.waitingPayment: return const Color(0xFFFF9800);
      case OrderStatus.packing:        return const Color(0xFF2196F3);
      case OrderStatus.shipped:        return const Color(0xFF9C27B0);
      case OrderStatus.completed:      return const Color(0xFF4CAF50);
    }
  }

  bool get _hasOrders => orderCount > 0;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Stack(clipBehavior: Clip.none, children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: _hasOrders
                  ? _activeColor.withOpacity(0.12)
                  : const Color(0xFFF5F5F5),
              shape: BoxShape.circle,
              border: _hasOrders
                  ? Border.all(color: _activeColor.withOpacity(0.4), width: 1.5)
                  : Border.all(color: Colors.grey[200]!, width: 1),
            ),
            child: Icon(icon,
              color: _hasOrders ? _activeColor : Colors.grey[400], size: 24),
          ),
          if (_hasOrders)
            Positioned(top: -3, right: -3,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 20, height: 20,
                decoration: BoxDecoration(
                  color: Colors.red, shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5)),
                child: Center(child: Text('$orderCount',
                  style: const TextStyle(color: Colors.white,
                    fontSize: 9, fontWeight: FontWeight.w800))))),
        ]),
        const SizedBox(height: 8),
        Text(label, textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10,
            color: _hasOrders ? Colors.grey[850] : Colors.grey[400],
            fontWeight: _hasOrders ? FontWeight.w700 : FontWeight.normal,
            height: 1.3)),
        const SizedBox(height: 4),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          child: _hasOrders
              ? Container(
                  key: ValueKey('qty_$itemCount'),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _activeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _activeColor.withOpacity(0.3))),
                  child: Text('$itemCount produk',
                    style: TextStyle(
                      fontSize: 9, color: _activeColor,
                      fontWeight: FontWeight.w600)))
              : Container(
                  key: const ValueKey('qty_empty'),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  child: Text('—',
                    style: TextStyle(fontSize: 9, color: Colors.grey[300]))),
        ),
      ]),
    );
  }
}

class _StatusProgressBar extends StatelessWidget {
  final AppState appState;
  const _StatusProgressBar({required this.appState});

  int get _highestActiveIndex {
    if (appState.orders.isEmpty) return -1;
    int maxIdx = -1;
    for (final o in appState.orders) {
      final idx = OrderStatus.values.indexOf(o.status);
      if (idx > maxIdx) maxIdx = idx;
    }
    return maxIdx;
  }

  @override
  Widget build(BuildContext context) {
    final activeIdx = _highestActiveIndex;
    if (activeIdx < 0) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Divider(height: 1),
        const SizedBox(height: 10),
        Row(children: [
          const Icon(Icons.timeline, size: 13, color: Color(0xFFFF6000)),
          const SizedBox(width: 5),
          Text('Progres Pesanan Aktif',
            style: TextStyle(fontSize: 11, color: Colors.grey[600],
              fontWeight: FontWeight.w500)),
        ]),
        const SizedBox(height: 8),
        LayoutBuilder(builder: (ctx, constraints) {
          return Stack(children: [
            Container(
              height: 4, width: constraints.maxWidth,
              decoration: BoxDecoration(
                color: Colors.grey[200], borderRadius: BorderRadius.circular(2))),
            AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOut,
              height: 4,
              width: constraints.maxWidth *
                  ((activeIdx + 1) / OrderStatus.values.length),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF6000), Color(0xFF4CAF50)]),
                borderRadius: BorderRadius.circular(2))),
            ...List.generate(4, (i) {
              final done = i <= activeIdx;
              final frac = i / 3;
              return Positioned(
                left: constraints.maxWidth * frac - 5,
                top: -3,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  width: 10, height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: done ? const Color(0xFF4CAF50) : Colors.grey[300],
                    border: Border.all(color: Colors.white, width: 1.5),
                  )));
            }),
          ]);
        }),
        const SizedBox(height: 6),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text('Bayar', style: TextStyle(fontSize: 9, color: Colors.grey)),
            Text('Dikemas', style: TextStyle(fontSize: 9, color: Colors.grey)),
            Text('Dikirim', style: TextStyle(fontSize: 9, color: Colors.grey)),
            Text('Selesai', style: TextStyle(fontSize: 9, color: Colors.grey)),
          ]),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// RECENT ORDERS LIST
// ─────────────────────────────────────────────────────────────────────────────
class _RecentOrdersList extends StatelessWidget {
  final AppState appState;
  const _RecentOrdersList({required this.appState});

  String _formatDate(DateTime dt) {
    final months = ['Jan','Feb','Mar','Apr','Mei','Jun',
                    'Jul','Ags','Sep','Okt','Nov','Des'];
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '${dt.day} ${months[dt.month - 1]} ${dt.year} • $h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final orders = appState.orders;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Pesanan Terakhir (${orders.length})',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          if (orders.length > 3)
            TextButton(onPressed: () {},
              child: const Text('Lihat Semua',
                style: TextStyle(color: Color(0xFFFF6000), fontSize: 13))),
        ]),
        const SizedBox(height: 8),
        ...orders.take(5).map((order) => _OrderCard(
          order: order, formatDate: _formatDate)),
      ]),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  final String Function(DateTime) formatDate;
  const _OrderCard({required this.order, required this.formatDate});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: order.isFinished
              ? const Color(0xFF4CAF50).withOpacity(0.25)
              : order.statusColor.withOpacity(0.25),
          width: 1.2),
        boxShadow: [BoxShadow(
          color: Colors.black.withOpacity(0.04), blurRadius: 8)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
          decoration: BoxDecoration(
            color: order.statusColor.withOpacity(0.06),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15))),
          child: Row(children: [
            const Icon(Icons.receipt_outlined, size: 14, color: Colors.grey),
            const SizedBox(width: 6),
            Text('#${order.id}',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            const Spacer(),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: Container(
                key: ValueKey(order.status),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: order.statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: order.statusColor.withOpacity(0.4))),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(order.statusIcon, size: 12, color: order.statusColor),
                  const SizedBox(width: 4),
                  Text(order.statusLabel,
                    style: TextStyle(color: order.statusColor,
                      fontSize: 11, fontWeight: FontWeight.w700)),
                ]),
              ),
            ),
          ]),
        ),
        _OrderStepper(order: order),
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
          child: Row(children: [
            SizedBox(
              height: 38,
              width: (order.items.length.clamp(1, 4) * 32).toDouble() + 6,
              child: Stack(
                children: [
                  ...order.items.take(4).toList().reversed.toList()
                    .asMap().entries.map((e) {
                      final idx = e.key;
                      final item = e.value;
                      return Positioned(
                        left: idx * 28.0,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            item.product.imageUrl,
                            width: 36,
                            height: 36,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 36,
                                height: 36,
                                color: item.product.color,
                                child: Icon(item.product.icon, size: 18),
                              );
                            },
                          ),
                        ));
                    }),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${order.totalItems} produk',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                Text(formatDate(order.createdAt),
                  style: TextStyle(fontSize: 10, color: Colors.grey[400])),
              ],
            )),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('\$${order.total.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.w800,
                  color: Color(0xFFFF6000), fontSize: 15)),
              Text('Total', style: TextStyle(fontSize: 10, color: Colors.grey[400])),
            ]),
          ]),
        ),
        if (!order.isFinished)
          Container(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
            child: Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey[700],
                    side: BorderSide(color: Colors.grey[300]!),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
                  child: const Text('Lacak', style: TextStyle(fontSize: 12)))),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    final shopId = 's${(order.id.hashCode.abs() % 4) + 1}';
                    Navigator.push(context, MaterialPageRoute(
                      builder: (_) => ChatScreen(shopId: shopId)));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6000),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
                  child: const Text('Hubungi Penjual',
                    style: TextStyle(fontSize: 12)))),
            ]),
          )
        else
          Container(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.star_outline, size: 16),
                label: const Text('Beri Ulasan',
                  style: TextStyle(fontSize: 12)),
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)))),
            ),
          ),
      ]),
    );
  }
}

class _OrderStepper extends StatelessWidget {
  final OrderModel order;
  const _OrderStepper({required this.order});

  static const _steps = [
    OrderStatus.waitingPayment,
    OrderStatus.packing,
    OrderStatus.shipped,
    OrderStatus.completed,
  ];
  static const _stepLabels = ['Bayar', 'Kemas', 'Kirim', 'Selesai'];
  static const _stepIcons = [
    Icons.payment_outlined,
    Icons.inventory_2_outlined,
    Icons.local_shipping_outlined,
    Icons.check_circle_outline,
  ];

  @override
  Widget build(BuildContext context) {
    final currentIdx = _steps.indexOf(order.status);

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 12),
      child: Row(
        children: List.generate(_steps.length * 2 - 1, (i) {
          if (i.isOdd) {
            final lineIdx = i ~/ 2;
            final filled = lineIdx < currentIdx;
            return Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                height: 2,
                color: filled ? order.statusColor : Colors.grey[200],
              ));
          }
          final stepIdx = i ~/ 2;
          final done = stepIdx <= currentIdx;
          final isCurrent = stepIdx == currentIdx;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: 28, height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: done ? order.statusColor : Colors.grey[100],
                  border: Border.all(
                    color: isCurrent
                        ? order.statusColor
                        : done ? order.statusColor : Colors.grey[300]!,
                    width: isCurrent ? 2 : 1)),
                child: Icon(_stepIcons[stepIdx],
                  size: 14,
                  color: done ? Colors.white : Colors.grey[400]),
              ),
              const SizedBox(height: 3),
              Text(_stepLabels[stepIdx],
                style: TextStyle(
                  fontSize: 8,
                  color: done ? order.statusColor : Colors.grey[400],
                  fontWeight: isCurrent ? FontWeight.w700 : FontWeight.normal)),
            ]),
          );
        }),
      ),
    );
  }
}