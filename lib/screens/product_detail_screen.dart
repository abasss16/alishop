import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../widgets/auth_gate.dart';
import 'cart_screen.dart';
import 'chat_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _qty = 1;
  bool _descExpanded = false;

  // ── Assign product to a shop deterministically ──────────────────────────
  String get _shopId {
    final shops = ['s1', 's2', 's3', 's4'];
    return shops[widget.product.id.hashCode.abs() % shops.length];
  }

  // ── Add to cart — gated behind login ────────────────────────────────────
  Future<void> _addToCart({bool buyNow = false}) async {
    final ok = await requireLogin(context,
        reason: 'Login untuk menambahkan produk ke keranjang');
    if (!ok || !mounted) return;

    context.read<AppState>().addToCart(widget.product, qty: _qty);
    if (buyNow) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(children: const [
            Icon(Icons.check_circle, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('Produk ditambahkan ke keranjang'),
          ]),
          backgroundColor: const Color(0xFF4CAF50),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'Lihat', textColor: Colors.white,
            onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const CartScreen()))),
        ),
      );
    }
  }

  // ── Open chat with this product's shop ──────────────────────────────────
  Future<void> _openChat() async {
    final ok = await requireLogin(context,
        reason: 'Login untuk chat dengan penjual');
    if (!ok || !mounted) return;

    final appState = context.read<AppState>();
    appState.getOrCreateRoom(_shopId, initialProduct: widget.product);
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => ChatScreen(
        shopId: _shopId,
        initialProduct: widget.product)));
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final appState = context.watch<AppState>();
    final cartCount = appState.cartCount;
    final isLoggedIn = !appState.isGuest && appState.user != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: CustomScrollView(
        slivers: [
          // ── App bar ─────────────────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            expandedHeight: 280,
            backgroundColor: const Color(0xFFFF6000),
            foregroundColor: Colors.white,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12)),
              child: const BackButton(color: Colors.white)),
            actions: [
              // Cart
              Stack(children: [
                Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12)),
                  child: IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
                    onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const CartScreen())))),
                if (cartCount > 0)
                  Positioned(top: 8, right: 8,
                    child: Container(
                      width: 16, height: 16,
                      decoration: const BoxDecoration(
                        color: Colors.yellow, shape: BoxShape.circle),
                      child: Center(child: Text('$cartCount',
                        style: const TextStyle(fontSize: 9,
                          fontWeight: FontWeight.bold, color: Colors.black))))),
              ]),
              // Chat
              Container(
                margin: const EdgeInsets.only(right: 4, top: 8, bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12)),
                child: IconButton(
                  icon: const Icon(Icons.chat_bubble_outline_rounded, color: Colors.white),
                  onPressed: _openChat)),
              // Wishlist
              Container(
                margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12)),
                child: IconButton(
                  icon: Icon(
                    appState.isWishlisted(p.id)
                        ? Icons.favorite : Icons.favorite_border,
                    color: appState.isWishlisted(p.id)
                        ? Colors.pinkAccent : Colors.white),
                  onPressed: () => appState.toggleWishlist(p))),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                    colors: [p.color.withOpacity(0.5), p.color])),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Product image from URL
                    Image.network(
                      p.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(p.icon, size: 130, color: p.iconColor.withOpacity(0.8)),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            color: p.iconColor,
                            strokeWidth: 2,
                          ),
                        );
                      },
                    ),
                    // Overlay gradient for better text readability
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black.withOpacity(0.3)],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Price section ──────────────────────────────────────────
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Text('\$${p.price.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900,
                          color: Color(0xFFFF6000))),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6000),
                          borderRadius: BorderRadius.circular(6)),
                        child: Text('-${p.discount}',
                          style: const TextStyle(color: Colors.white, fontSize: 12,
                            fontWeight: FontWeight.bold))),
                      const Spacer(),
                      const Icon(Icons.share_outlined, color: Colors.grey),
                    ]),
                    const SizedBox(height: 4),
                    Text('\$${p.originalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 14, color: Colors.grey,
                        decoration: TextDecoration.lineThrough)),
                    const SizedBox(height: 10),
                    Text(p.name,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 10),
                    Row(children: [
                      ...List.generate(5, (i) => Icon(
                        i < p.rating.round() ? Icons.star : Icons.star_border,
                        color: const Color(0xFFFFC107), size: 18)),
                      const SizedBox(width: 6),
                      Text('${p.rating}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Text(' (${p.reviews} ulasan)',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                    ]),
                  ]),
                ),
                const SizedBox(height: 8),

                // ── Chat with seller ───────────────────────────────────────
                GestureDetector(
                  onTap: _openChat,
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(children: [
                      Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFF3D5AFE).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.storefront_rounded,
                          color: Color(0xFF3D5AFE), size: 22)),
                      const SizedBox(width: 12),
                      Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('TechZone Official',
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                          Row(children: [
                            Container(
                              width: 7, height: 7,
                              decoration: const BoxDecoration(
                                color: Color(0xFF4ADE80), shape: BoxShape.circle)),
                            const SizedBox(width: 4),
                            Text('Online · Respon < 5 mnt',
                              style: TextStyle(color: Colors.grey[600], fontSize: 11)),
                          ]),
                        ],
                      )),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFFF6000)),
                          borderRadius: BorderRadius.circular(20)),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          const Icon(Icons.chat_bubble_outline_rounded,
                            color: Color(0xFFFF6000), size: 15),
                          const SizedBox(width: 5),
                          const Text('Chat',
                            style: TextStyle(color: Color(0xFFFF6000),
                              fontWeight: FontWeight.w600, fontSize: 13)),
                          if (!isLoggedIn) ...[
                            const SizedBox(width: 4),
                            const Icon(Icons.lock_outline, size: 12,
                              color: Color(0xFFFF6000)),
                          ],
                        ]),
                      ),
                    ]),
                  ),
                ),
                const SizedBox(height: 8),

                // ── Quantity ───────────────────────────────────────────────
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(children: [
                    Text('Jumlah:', style: TextStyle(color: Colors.grey[700], fontSize: 14)),
                    const Spacer(),
                    GestureDetector(
                      onTap: () { if (_qty > 1) setState(() => _qty--); },
                      child: Container(
                        width: 32, height: 32,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.remove, size: 16))),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text('$_qty',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                    GestureDetector(
                      onTap: () => setState(() => _qty++),
                      child: Container(
                        width: 32, height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6000),
                          borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.add, size: 16, color: Colors.white))),
                  ]),
                ),
                const SizedBox(height: 8),

                // ── Shipping & guarantees ──────────────────────────────────
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: Column(children: [
                    _infoRow(Icons.local_shipping_outlined, 'Pengiriman Gratis',
                      'Estimasi 5-10 hari kerja', Colors.green),
                    const Divider(height: 16),
                    _infoRow(Icons.verified_user_outlined, 'Garansi Produk',
                      'Jaminan uang kembali 30 hari', Colors.blue),
                    const Divider(height: 16),
                    _infoRow(Icons.support_agent_outlined, 'Layanan Pelanggan',
                      'Tersedia 24/7', Colors.purple),
                  ]),
                ),
                const SizedBox(height: 8),

                // ── Description ────────────────────────────────────────────
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Deskripsi Produk',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    AnimatedCrossFade(
                      crossFadeState: _descExpanded
                          ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                      duration: const Duration(milliseconds: 300),
                      firstChild: Text(p.description,
                        style: TextStyle(color: Colors.grey[700], fontSize: 13, height: 1.6),
                        maxLines: 3, overflow: TextOverflow.ellipsis),
                      secondChild: Text(p.description,
                        style: TextStyle(color: Colors.grey[700], fontSize: 13, height: 1.6))),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => setState(() => _descExpanded = !_descExpanded),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Text(_descExpanded ? 'Sembunyikan' : 'Selengkapnya',
                          style: const TextStyle(color: Color(0xFFFF6000),
                            fontWeight: FontWeight.w600, fontSize: 13)),
                        Icon(_descExpanded
                          ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                          color: const Color(0xFFFF6000), size: 18),
                      ])),
                  ]),
                ),
                const SizedBox(height: 8),

                // ── Specs ──────────────────────────────────────────────────
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Spesifikasi',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    ...p.specs.map((spec) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(children: [
                        Container(
                          width: 6, height: 6,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFF6000), shape: BoxShape.circle)),
                        const SizedBox(width: 10),
                        Text(spec, style: TextStyle(color: Colors.grey[700], fontSize: 13)),
                      ]))),
                  ]),
                ),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),

      // ── Bottom action bar ──────────────────────────────────────────────────
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.1), blurRadius: 12,
            offset: const Offset(0, -3))]),
        child: Row(children: [
          // Chat shortcut
          GestureDetector(
            onTap: _openChat,
            child: Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12)),
              child: Stack(alignment: Alignment.center, children: [
                const Icon(Icons.chat_bubble_outline_rounded,
                  color: Color(0xFFFF6000), size: 22),
                if (!isLoggedIn)
                  Positioned(bottom: 6, right: 6,
                    child: Container(
                      width: 10, height: 10,
                      decoration: BoxDecoration(
                        color: Colors.orange[300], shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1)),
                      child: const Icon(Icons.lock, size: 6, color: Colors.white))),
              ])),
          ),
          const SizedBox(width: 10),
          // Add to cart
          Expanded(
            child: OutlinedButton(
              onPressed: () => _addToCart(),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFFF6000),
                side: const BorderSide(color: Color(0xFFFF6000), width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12))),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Text('+ Keranjang',
                  style: TextStyle(fontWeight: FontWeight.bold)),
                if (!isLoggedIn) ...[
                  const SizedBox(width: 4),
                  const Icon(Icons.lock_outline, size: 13),
                ],
              ]))),
          const SizedBox(width: 10),
          // Buy now
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () => _addToCart(buyNow: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6000),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12))),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Text('Beli Sekarang',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                if (!isLoggedIn) ...[
                  const SizedBox(width: 4),
                  const Icon(Icons.lock_outline, size: 13),
                ],
              ]))),
        ]),
      ),
    );
  }

  Widget _infoRow(IconData icon, String title, String subtitle, Color color) {
    return Row(children: [
      Container(
        width: 38, height: 38,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: color, size: 20)),
      const SizedBox(width: 12),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
      ]),
    ]);
  }
}