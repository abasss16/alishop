import 'package:flutter/material.dart';
import 'dart:async';

enum OrderStatus { waitingPayment, packing, shipped, completed }

extension OrderStatusNext on OrderStatus {
  /// Returns the next status in progression, or null if already completed.
  OrderStatus? get next {
    switch (this) {
      case OrderStatus.waitingPayment: return OrderStatus.packing;
      case OrderStatus.packing:        return OrderStatus.shipped;
      case OrderStatus.shipped:        return OrderStatus.completed;
      case OrderStatus.completed:      return null;
    }
  }
}

class OrderModel {
  final String id;
  final List<CartItem> items;
  final double total;
  final DateTime createdAt;
  OrderStatus status;
  /// Timestamps keyed by status — filled as status advances
  final Map<OrderStatus, DateTime> timestamps;

  OrderModel({
    required this.id,
    required this.items,
    required this.total,
    required this.createdAt,
    this.status = OrderStatus.packing,
  }) : timestamps = {OrderStatus.packing: createdAt};

  /// Total quantity of all items in this order
  int get totalItems => items.fold(0, (sum, i) => sum + i.quantity);

  String get statusLabel {
    switch (status) {
      case OrderStatus.waitingPayment: return 'Menunggu Pembayaran';
      case OrderStatus.packing:        return 'Dikemas';
      case OrderStatus.shipped:        return 'Dikirim';
      case OrderStatus.completed:      return 'Selesai';
    }
  }

  Color get statusColor {
    switch (status) {
      case OrderStatus.waitingPayment: return const Color(0xFFFF9800);
      case OrderStatus.packing:        return const Color(0xFF2196F3);
      case OrderStatus.shipped:        return const Color(0xFF9C27B0);
      case OrderStatus.completed:      return const Color(0xFF4CAF50);
    }
  }

  IconData get statusIcon {
    switch (status) {
      case OrderStatus.waitingPayment: return Icons.payment_outlined;
      case OrderStatus.packing:        return Icons.inventory_2_outlined;
      case OrderStatus.shipped:        return Icons.local_shipping_outlined;
      case OrderStatus.completed:      return Icons.check_circle_outline;
    }
  }

  bool get isFinished => status == OrderStatus.completed;
}

class UserModel {
  final String name;
  final String email;
  final String phone;
  final String avatar;

  UserModel({
    required this.name,
    required this.email,
    required this.phone,
    this.avatar = '',
  });
}

class ProductModel {
  final String id;
  final String name;
  final double price;
  final double originalPrice;
  final double rating;
  final int reviews;
  final String discount;
  final Color color;
  final IconData icon;
  final Color iconColor;
  final String badge;
  final String category;
  final String description;
  final List<String> specs;
  final String imageUrl; // Added image URL

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.originalPrice,
    required this.rating,
    required this.reviews,
    required this.discount,
    required this.color,
    required this.icon,
    required this.iconColor,
    required this.badge,
    required this.category,
    required this.description,
    required this.specs,
    required this.imageUrl,
  });
}

class CartItem {
  final ProductModel product;
  int quantity;
  CartItem({required this.product, this.quantity = 1});
}

class AppState extends ChangeNotifier {
  UserModel? _user;
  bool _isGuest = false;
  final List<CartItem> _cart = [];
  final List<ProductModel> _wishlist = [];
  final List<OrderModel> _orders = [];
  Timer? _statusTimer;

  AppState() {
    // Auto-advance order statuses every 5 seconds
    _statusTimer = Timer.periodic(const Duration(seconds: 23), (_) {
      _advanceOrderStatuses();
    });
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    super.dispose();
  }

  // ─── Getters ──────────────────────────────────────────────────────────────
  UserModel? get user => _user;
  bool get isGuest => _isGuest;
  bool get isLoggedIn => _user != null || _isGuest;
  List<CartItem> get cart => _cart;
  List<ProductModel> get wishlist => _wishlist;
  List<OrderModel> get orders => List.unmodifiable(_orders);

  int get cartCount => _cart.fold(0, (sum, item) => sum + item.quantity);
  double get cartTotal =>
      _cart.fold(0.0, (sum, item) => sum + item.product.price * item.quantity);

  /// Number of *orders* in a given status.
  int ordersWithStatus(OrderStatus status) =>
      _orders.where((o) => o.status == status).length;

  /// Total *product quantity* across all orders in a given status.
  int itemsWithStatus(OrderStatus status) => _orders
      .where((o) => o.status == status)
      .fold(0, (sum, o) => sum + o.totalItems);

  // ─── Auto-advance ─────────────────────────────────────────────────────────
  /// Advances every non-completed order to its next status.
  void _advanceOrderStatuses() {
    bool changed = false;
    for (final order in _orders) {
      final next = order.status.next;
      if (next != null) {
        order.status = next;
        order.timestamps[next] = DateTime.now();
        changed = true;
      }
    }
    if (changed) notifyListeners();
  }

  // ─── Orders ───────────────────────────────────────────────────────────────
  OrderModel placeOrder() {
    final order = OrderModel(
      id: 'ALI${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      items: List<CartItem>.from(
          _cart.map((i) => CartItem(product: i.product, quantity: i.quantity))),
      total: cartTotal,
      createdAt: DateTime.now(),
      status: OrderStatus.packing,
    );
    _orders.insert(0, order);
    _cart.clear();
    notifyListeners();
    return order;
  }

  // ─── Auth ─────────────────────────────────────────────────────────────────
  void loginAsGuest() {
    _isGuest = true;
    _user = null;
    notifyListeners();
  }

  void login(String name, String email, String phone) {
    _user = UserModel(name: name, email: email, phone: phone);
    _isGuest = false;
    notifyListeners();
  }

  void logout() {
    _user = null;
    _isGuest = false;
    _cart.clear();
    _orders.clear();
    notifyListeners();
  }

  // ─── Cart ─────────────────────────────────────────────────────────────────
  void addToCart(ProductModel product, {int qty = 1}) {
    final idx = _cart.indexWhere((i) => i.product.id == product.id);
    if (idx >= 0) {
      _cart[idx].quantity += qty;
    } else {
      _cart.add(CartItem(product: product, quantity: qty));
    }
    notifyListeners();
  }

  void removeFromCart(String productId) {
    _cart.removeWhere((i) => i.product.id == productId);
    notifyListeners();
  }

  void updateQty(String productId, int qty) {
    final idx = _cart.indexWhere((i) => i.product.id == productId);
    if (idx >= 0) {
      if (qty <= 0) {
        _cart.removeAt(idx);
      } else {
        _cart[idx].quantity = qty;
      }
    }
    notifyListeners();
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  // ─── Wishlist ─────────────────────────────────────────────────────────────
  void toggleWishlist(ProductModel product) {
    final idx = _wishlist.indexWhere((p) => p.id == product.id);
    if (idx >= 0) {
      _wishlist.removeAt(idx);
    } else {
      _wishlist.add(product);
    }
    notifyListeners();
  }


  // ─── Chat ─────────────────────────────────────────────────────────────────
  final List<ChatRoom> _chatRooms = [];
  Timer? _typingTimer;

  List<ChatRoom> get chatRooms => List.unmodifiable(_chatRooms);
  int get totalUnread => _chatRooms.fold(0, (s, r) => s + r.unreadCount);

  static final List<Map<String, dynamic>> _shops = [
    {'id': 's1', 'name': 'TechZone Official', 'color': const Color(0xFF3D5AFE)},
    {'id': 's2', 'name': 'FashionHub Store', 'color': const Color(0xFFE91E63)},
    {'id': 's3', 'name': 'HomeDecor Plus',   'color': const Color(0xFF00C853)},
    {'id': 's4', 'name': 'SportsPro Shop',   'color': const Color(0xFFFF6000)},
  ];

  static const List<String> _autoReplies = [
    'Halo! Ada yang bisa kami bantu? 😊',
    'Terima kasih sudah menghubungi kami!',
    'Stok masih tersedia, silakan order sekarang!',
    'Untuk pertanyaan lebih lanjut, tim kami siap membantu.',
    'Kami memproses pesanan dalam 1x24 jam ya kak.',
    'Boleh tahu produk apa yang kamu minati?',
    'Promo hari ini diskon 20% untuk pembelian pertama!',
    'Pengiriman ke seluruh Indonesia, estimasi 3-7 hari kerja.',
  ];

  ChatRoom getOrCreateRoom(String shopId, {ProductModel? initialProduct}) {
    var idx = _chatRooms.indexWhere((r) => r.shopId == shopId);
    if (idx < 0) {
      final shop = _shops.firstWhere((s) => s['id'] == shopId,
          orElse: () => _shops.first);
      final room = ChatRoom(
        shopId: shopId,
        shopName: shop['name'],
        shopAvatar: shop['id'],
        shopColor: shop['color'],
      );
      // Welcome message from shop
      room.messages.add(ChatMessage(
        id: 'w_$shopId',
        content: 'Selamat datang di ${shop['name']}! 👋 Ada yang bisa kami bantu?',
        isFromUser: false,
        sentAt: DateTime.now().subtract(const Duration(minutes: 2)),
        isRead: false,
      ));
      if (initialProduct != null) {
        room.messages.add(ChatMessage(
          id: 'p_${initialProduct.id}',
          content: initialProduct.name,
          isFromUser: true,
          sentAt: DateTime.now().subtract(const Duration(minutes: 1)),
          type: MessageType.productCard,
          product: initialProduct,
          isRead: true,
        ));
      }
      _chatRooms.insert(0, room);
      idx = 0;
      notifyListeners();
    }
    return _chatRooms[idx];
  }

  void sendMessage(String shopId, String content, {MessageType type = MessageType.text, ProductModel? product}) {
    final idx = _chatRooms.indexWhere((r) => r.shopId == shopId);
    if (idx < 0) return;

    _chatRooms[idx].messages.add(ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      content: content,
      isFromUser: true,
      sentAt: DateTime.now(),
      type: type,
      product: product,
      isRead: true,
    ));
    _chatRooms[idx].lastTypingText = 'Mengetik...';
    notifyListeners();

    // Simulated auto-reply with typing indicator
    _typingTimer?.cancel();
    _typingTimer = Timer(Duration(milliseconds: 1200 + (content.length * 30).clamp(0, 2000)), () {
      if (idx < _chatRooms.length) {
        _chatRooms[idx].lastTypingText = null;
        final reply = _autoReplies[DateTime.now().millisecond % _autoReplies.length];
        _chatRooms[idx].messages.add(ChatMessage(
          id: 'reply_${DateTime.now().millisecondsSinceEpoch}',
          content: reply,
          isFromUser: false,
          sentAt: DateTime.now(),
          isRead: false,
        ));
        // Move to top
        final room = _chatRooms.removeAt(idx);
        _chatRooms.insert(0, room);
        notifyListeners();
      }
    });
  }

  void markRoomAsRead(String shopId) {
    final idx = _chatRooms.indexWhere((r) => r.shopId == shopId);
    if (idx < 0) return;
    final room = _chatRooms[idx];
    final updated = room.messages.map((m) => m.isFromUser ? m : m.copyWith(isRead: true)).toList();
    room.messages.clear();
    room.messages.addAll(updated);
    notifyListeners();
  }

  bool isWishlisted(String productId) =>
      _wishlist.any((p) => p.id == productId);

  // ─── Product catalogue ────────────────────────────────────────────────────
  static final List<ProductModel> allProducts = [
    // ==================== ELECTRONICS (4 products) ====================
    ProductModel(
      id: 'p1',
      name: 'Wireless Earbuds Pro Max',
      price: 24.99,
      originalPrice: 49.99,
      rating: 4.8,
      reviews: 2341,
      discount: '50%',
      color: const Color(0xFFF0F4FF),
      icon: Icons.headphones,
      iconColor: const Color(0xFF3D5AFE),
      badge: 'HOT',
      category: 'Electronics',
      description: 'Nikmati suara kristal jernih dengan teknologi Active Noise Cancellation terdepan. Baterai tahan 36 jam, koneksi Bluetooth 5.3 ultra stabil, dan desain ergonomis yang nyaman dipakai seharian.',
      specs: ['Bluetooth 5.3', 'ANC Technology', 'Battery: 36H total', 'IPX5 Water Resistant', 'Fast Charge 15min = 3H', 'Driver: 10mm Dynamic'],
      imageUrl: 'https://images.unsplash.com/photo-1590658268037-6bf12165a8df?w=400',
    ),
    ProductModel(
      id: 'p2',
      name: 'Smart Watch Series X Ultra',
      price: 59.99,
      originalPrice: 129.99,
      rating: 4.6,
      reviews: 1876,
      discount: '54%',
      color: const Color(0xFFFFF0F0),
      icon: Icons.watch,
      iconColor: const Color(0xFFFF1744),
      badge: 'SALE',
      category: 'Electronics',
      description: 'Smartwatch premium dengan layar AMOLED 1.9 inci, monitor kesehatan 24/7, GPS built-in, dan lebih dari 100 mode olahraga. Kompatibel dengan Android & iOS.',
      specs: ['AMOLED 1.9" Display', 'Heart Rate & SpO2', 'Built-in GPS', 'Battery: 7 days', '100+ Sport Modes', 'Water Resistant 50m'],
      imageUrl: 'https://images.unsplash.com/photo-1546868871-7041f2a55e12?w=400',
    ),
    ProductModel(
      id: 'p3',
      name: 'Portable Bluetooth Speaker 360°',
      price: 18.50,
      originalPrice: 35.00,
      rating: 4.5,
      reviews: 987,
      discount: '47%',
      color: const Color(0xFFF0FFF4),
      icon: Icons.speaker,
      iconColor: const Color(0xFF00C853),
      badge: 'NEW',
      category: 'Electronics',
      description: 'Speaker portabel dengan suara 360 derajat, bass yang dalam, dan tahan air IPX7. Sempurna untuk aktivitas outdoor, piknik, atau pantai.',
      specs: ['360° Surround Sound', 'IPX7 Waterproof', 'Battery: 20 hours', 'Bluetooth 5.0', 'Built-in Microphone', 'Output: 15W'],
      imageUrl: 'https://images.unsplash.com/photo-1608043152269-423dbba4e7e1?w=400',
    ),
    ProductModel(
      id: 'p4',
      name: 'LED Ring Light 18" Professional',
      price: 32.00,
      originalPrice: 58.00,
      rating: 4.7,
      reviews: 543,
      discount: '45%',
      color: const Color(0xFFFFFDE7),
      icon: Icons.lightbulb,
      iconColor: const Color(0xFFFFD600),
      badge: 'TOP',
      category: 'Electronics',
      description: 'Ring light profesional 18 inci dengan 3 mode warna (warm, natural, cool) dan 10 level kecerahan. Dilengkapi phone holder dan tripod adjustable hingga 2 meter.',
      specs: ['18" Diameter', '3 Color Modes', '10 Brightness Levels', 'Tripod included (2m)', 'Phone Holder included', 'Power: 55W LED'],
      imageUrl: 'https://www.izicart.com/cdn/shop/files/ring-light-n.webp?v=1745061853&width=1946',
    ),

    // ==================== ELECTRONICS ADDITIONAL (4 more) ====================
    ProductModel(
      id: 'p5',
      name: 'USB-C Hub 7-in-1 Pro',
      price: 22.99,
      originalPrice: 44.00,
      rating: 4.4,
      reviews: 1203,
      discount: '48%',
      color: const Color(0xFFF3E5F5),
      icon: Icons.hub,
      iconColor: const Color(0xFF9C27B0),
      badge: 'DEAL',
      category: 'Electronics',
      description: 'Hub USB-C 7-in-1 dengan transfer data super cepat. Mendukung 4K HDMI output, PD charging 100W, dan kompatibel dengan laptop, tablet, serta smartphone terbaru.',
      specs: ['4K HDMI Output', 'USB 3.0 x3 (5Gbps)', 'PD Charging 100W', 'SD & MicroSD Slot', 'Aluminium Alloy Body', 'Plug & Play'],
      imageUrl: 'https://m.media-amazon.com/images/I/71EUnuN2eIL.jpg',
    ),
    ProductModel(
      id: 'p6',
      name: 'Mechanical Gaming Keyboard RGB',
      price: 45.00,
      originalPrice: 89.99,
      rating: 4.9,
      reviews: 3200,
      discount: '50%',
      color: const Color(0xFFE8F5E9),
      icon: Icons.keyboard,
      iconColor: const Color(0xFF388E3C),
      badge: 'HOT',
      category: 'Electronics',
      description: 'Keyboard mechanical gaming dengan switch red linear, RGB per-key lighting, dan anti-ghosting 100%. Build quality aluminium solid, cocok untuk gaming marathon maupun produktivitas.',
      specs: ['Red Switch Linear', 'RGB Per-Key Lighting', '100% Anti-Ghosting', 'Aluminium Top Plate', 'Detachable Cable', 'N-Key Rollover'],
      imageUrl: 'https://img.gkbcdn.com/s3/d/202209/Redragon-K629-RGB-75--Rainbow-Backlight-Mechanical-Gaming-keyboard-516458-5.jpg',
    ),
    ProductModel(
      id: 'p7',
      name: '4K Action Camera Pro',
      price: 89.99,
      originalPrice: 199.99,
      rating: 4.7,
      reviews: 876,
      discount: '55%',
      color: const Color(0xFFE3F2FD),
      icon: Icons.videocam,
      iconColor: const Color(0xFF1565C0),
      badge: 'SALE',
      category: 'Electronics',
      description: 'Kamera aksi 4K dengan stabilisasi EIS, waterproof hingga 30m, dan baterai tahan lama. Sempurna untuk olahraga ekstrem, traveling, dan vlogging.',
      specs: ['4K@60fps', 'EIS Stabilization', 'Waterproof 30m', '2.0" Touch Screen', 'WiFi + Bluetooth', 'Battery: 1300mAh'],
      imageUrl: 'https://m.media-amazon.com/images/I/71LwiZU3oZL._AC_.jpg',
    ),
    ProductModel(
      id: 'p8',
      name: 'Fast Charging Power Bank 20000mAh',
      price: 29.99,
      originalPrice: 59.99,
      rating: 4.6,
      reviews: 1542,
      discount: '50%',
      color: const Color(0xFFFCE4EC),
      icon: Icons.battery_charging_full,
      iconColor: const Color(0xFFE91E63),
      badge: 'TOP',
      category: 'Electronics',
      description: 'Power bank kapasitas besar 20000mAh dengan fast charging 18W dan dual output port. Dapat mengisi smartphone hingga 5 kali. Layar digital menunjukkan sisa daya.',
      specs: ['20000mAh Capacity', '18W Fast Charging', 'Dual USB Output', 'Digital Display', 'Safety Protection', 'Charge: 5 hours'],
      imageUrl: 'https://sc04.alicdn.com/kf/H00c1834893f24326aa35ac5823705147l/243520447/H00c1834893f24326aa35ac5823705147l.jpg',
    ),

    // ==================== SPORTS (4 products) ====================
    ProductModel(
      id: 'p9',
      name: 'Running Shoes AirFlex Pro',
      price: 38.99,
      originalPrice: 79.99,
      rating: 4.5,
      reviews: 892,
      discount: '51%',
      color: const Color(0xFFE3F2FD),
      icon: Icons.directions_run,
      iconColor: const Color(0xFF1565C0),
      badge: 'NEW',
      category: 'Sports',
      description: 'Sepatu lari dengan teknologi AirFlex cushioning untuk kenyamanan maksimal. Upper mesh breathable, sol anti-slip, dan desain ergonomis mengikuti kontur kaki.',
      specs: ['AirFlex Cushioning', 'Breathable Mesh Upper', 'Anti-Slip Outsole', 'Weight: 280g', 'Drop: 8mm', 'Available: 36-45'],
      imageUrl: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400',
    ),
    ProductModel(
      id: 'p10',
      name: 'Yoga Mat Anti-Slip Premium',
      price: 19.99,
      originalPrice: 39.99,
      rating: 4.8,
      reviews: 2340,
      discount: '50%',
      color: const Color(0xFFE8F5E9),
      icon: Icons.fitness_center,
      iconColor: const Color(0xFF2E7D32),
      badge: 'HOT',
      category: 'Sports',
      description: 'Matras yoga premium dengan ketebalan 8mm, permukaan anti-slip, dan bahan eco-friendly. Nyaman digunakan untuk yoga, pilates, dan latihan lantai.',
      specs: ['8mm Thickness', 'Anti-Slip Surface', 'Eco-Friendly Material', 'Size: 183x68cm', 'Carry Strap Included', 'Easy to Clean'],
      imageUrl: 'https://images.unsplash.com/photo-1592432678016-e910b452f9a2?w=400',
    ),
    ProductModel(
      id: 'p11',
      name: 'Adjustable Dumbbell Set 20kg',
      price: 79.99,
      originalPrice: 149.99,
      rating: 4.9,
      reviews: 567,
      discount: '47%',
      color: const Color(0xFFFFF3E0),
      icon: Icons.fitness_center,
      iconColor: const Color(0xFFFF6F00),
      badge: 'SALE',
      category: 'Sports',
      description: 'Set dumbbell adjustable 20kg dengan 10 level beban berbeda. Menghemat ruang, ideal untuk latihan kekuatan di rumah. Handle anti-slip dan mudah diatur.',
      specs: ['20kg Max Weight', '10 Adjustment Levels', 'Anti-Slip Handle', 'Compact Design', 'Durable Metal Construction', 'Storage Tray Included'],
      imageUrl: 'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=400',
    ),
    ProductModel(
      id: 'p12',
      name: 'Smart Jump Rope with Counter',
      price: 14.99,
      originalPrice: 29.99,
      rating: 4.4,
      reviews: 1234,
      discount: '50%',
      color: const Color(0xFFF3E5F5),
      icon: Icons.sports,
      iconColor: const Color(0xFF7B1FA2),
      badge: 'DEAL',
      category: 'Sports',
      description: 'Tali skipping pintar dengan penghitung otomatis via layar LCD. Bahan kabel tahan lama, handle ergonomis, dan koneksi Bluetooth ke aplikasi smartphone.',
      specs: ['Auto Counter LCD', 'Bluetooth Connectivity', 'Adjustable Length', 'Ball Bearings', 'Companion App', 'Weight: 150g'],
      imageUrl: 'https://images.nexusapp.co/assets/f2/6d/b7/365596195.jpg',
    ),

    // ==================== BEAUTY (4 products) ====================
    ProductModel(
      id: 'p13',
      name: 'Skincare Set 5-in-1 Glow',
      price: 28.50,
      originalPrice: 55.00,
      rating: 4.7,
      reviews: 1540,
      discount: '48%',
      color: const Color(0xFFFCE4EC),
      icon: Icons.spa,
      iconColor: const Color(0xFFE91E63),
      badge: 'HOT',
      category: 'Beauty',
      description: 'Set perawatan kulit lengkap 5-in-1 dengan formula Vitamin C + Niacinamide. Mencerahkan, melembapkan, dan menjaga elastisitas kulit. Cocok untuk semua jenis kulit.',
      specs: ['Vitamin C + Niacinamide', 'Cleanser 150ml', 'Toner 200ml', 'Serum 30ml', 'Moisturizer 50ml', 'SPF 30 Sunscreen 50ml'],
      imageUrl: 'https://images.unsplash.com/photo-1570172619644-dfd03ed5d881?w=400',
    ),
    ProductModel(
      id: 'p14',
      name: 'Professional Makeup Brush Set 12pcs',
      price: 22.99,
      originalPrice: 49.99,
      rating: 4.8,
      reviews: 2103,
      discount: '54%',
      color: const Color(0xFFFFF0F5),
      icon: Icons.brush,
      iconColor: const Color(0xFFC2185B),
      badge: 'TOP',
      category: 'Beauty',
      description: 'Set kuas makeup profesional 12 pcs dengan bulu premium yang lembut dan tidak rontok. Handle ergonomis, cocok untuk aplikasi foundation, eyeshadow, blush, dan lipstik.',
      specs: ['12 Professional Brushes', 'Premium Synthetic Bristles', 'Ergonomic Handle', 'Travel Pouch Included', 'Cruelty-Free', 'Easy to Clean'],
      imageUrl: 'https://mediahub.oasisfashion.com/m0637586355738_silver_xl.jpeg',
    ),
    ProductModel(
      id: 'p15',
      name: 'Facial Serum Vitamin C 30ml',
      price: 18.99,
      originalPrice: 39.99,
      rating: 4.9,
      reviews: 3421,
      discount: '53%',
      color: const Color(0xFFE0F7FA),
      icon: Icons.opacity,
      iconColor: const Color(0xFF00838F),
      badge: 'NEW',
      category: 'Beauty',
      description: 'Serum wajah Vitamin C 20% + Hyaluronic Acid. Mencerahkan kulit, mengurangi noda hitam, dan melembapkan secara intensif. Hasil terlihat dalam 4 minggu.',
      specs: ['20% Vitamin C', 'Hyaluronic Acid', 'Brightening Effect', 'Reduces Dark Spots', '30ml Bottle', 'Dropper Included'],
      imageUrl: 'https://i5.walmartimages.com/seo/Boosts-Skin-Collagens-Hydrate-Plumps-Skin-Non-Aging-Wrinkle-Facial-Serum-Vitamin-C-Facial-Serum-Hyaluronic-Acides-Moisturizing-Repair-Skin-Restores-H_3b4882ed-4263-4788-a879-965694237019.0611c9aff9dc0f5c5d713b94cc1e440b.jpeg',
    ),
    ProductModel(
      id: 'p16',
      name: 'Hair Dryer Ionic Pro 2200W',
      price: 34.99,
      originalPrice: 79.99,
      rating: 4.6,
      reviews: 987,
      discount: '56%',
      color: const Color(0xFFFFF8E1),
      icon: Icons.air,
      iconColor: const Color(0xFFFF8F00),
      badge: 'SALE',
      category: 'Beauty',
      description: 'Hair dryer profesional dengan teknologi ionik untuk mengurangi kerusakan rambut. 3 kecepatan dan 3 suhu, termasuk tombol cool shot untuk pengaturan akhir.',
      specs: ['2200W Power', 'Ionic Technology', '3 Heat Settings', '3 Speed Settings', 'Cool Shot Button', 'Concentrator Nozzle'],
      imageUrl: 'https://images.unsplash.com/photo-1522338140262-f46f5913618a?w=400',
    ),

    // ==================== FASHION (4 products) ====================
    ProductModel(
      id: 'p17',
      name: 'Casual Hoodie Premium Cotton',
      price: 29.99,
      originalPrice: 59.99,
      rating: 4.7,
      reviews: 1890,
      discount: '50%',
      color: const Color(0xFFE8EAF6),
      icon: Icons.checkroom,
      iconColor: const Color(0xFF3949AB),
      badge: 'HOT',
      category: 'Fashion',
      description: 'Hoodie kasual berbahan katun premium yang lembut dan hangat. Desain minimalis dengan saku kanguru, cocok untuk santai atau hangout. Tersedia berbagai ukuran.',
      specs: ['80% Cotton, 20% Polyester', 'Kangaroo Pocket', 'Adjustable Hood', 'Available: S-XXL', 'Machine Washable', 'Unisex Design'],
      imageUrl: 'https://images.unsplash.com/photo-1556821840-3a63f95609a7?w=400',
    ),
    ProductModel(
      id: 'p18',
      name: 'Slim Fit Jeans Stretch',
      price: 34.99,
      originalPrice: 69.99,
      rating: 4.5,
      reviews: 2341,
      discount: '50%',
      color: const Color(0xFFE3F2FD),
      icon: Icons.shopping_bag,
      iconColor: const Color(0xFF1565C0),
      badge: 'SALE',
      category: 'Fashion',
      description: 'Jeans slim fit dengan bahan stretch yang nyaman. Model modern, cocok untuk aktivitas sehari-hari. Tersedia berbagai warna dan ukuran.',
      specs: ['98% Cotton, 2% Spandex', 'Slim Fit Design', '5 Pockets', 'Available: 28-40', 'Machine Washable', 'Classic Blue Color'],
      imageUrl: 'https://images.unsplash.com/photo-1541099649105-f69ad21f3246?w=400',
    ),
    ProductModel(
      id: 'p19',
      name: 'Women Floral Summer Dress',
      price: 39.99,
      originalPrice: 79.99,
      rating: 4.8,
      reviews: 1456,
      discount: '50%',
      color: const Color(0xFFFCE4EC),
      icon: Icons.shopping_bag,
      iconColor: const Color(0xFFC2185B),
      badge: 'NEW',
      category: 'Fashion',
      description: 'Gaun musim panas dengan motif floral yang cantik. Bahan ringan dan adem, cocok untuk pesta atau liburan. Ukuran S hingga XL.',
      specs: ['100% Polyester', 'Floral Print', 'Adjustable Straps', 'Available: S-XL', 'Lightweight Material', 'Summer Collection'],
      imageUrl: 'https://images.unsplash.com/photo-1515372039744-b8f02a3ae446?w=400',
    ),
    ProductModel(
      id: 'p20',
      name: 'Leather Backpack Vintage',
      price: 49.99,
      originalPrice: 99.99,
      rating: 4.9,
      reviews: 876,
      discount: '50%',
      color: const Color(0xFFEFEBE9),
      icon: Icons.backpack,
      iconColor: const Color(0xFF5D4037),
      badge: 'TOP',
      category: 'Fashion',
      description: 'Ransel kulit asli dengan gaya vintage. Kapasitas besar, cocok untuk kerja, traveling, atau sekolah. Kualitas premium dengan jahitan rapi.',
      specs: ['100% Genuine Leather', 'Vintage Design', '15.6" Laptop Compartment', 'Multiple Pockets', 'Adjustable Straps', 'Durable Metal Zipper'],
      imageUrl: 'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?w=400',
    ),

    // Additional product to reach total
    ProductModel(
      id: 'p21',
      name: 'Wireless Mouse Silent Click',
      price: 12.99,
      originalPrice: 25.99,
      rating: 4.6,
      reviews: 5432,
      discount: '50%',
      color: const Color(0xFFF3E5F5),
      icon: Icons.mouse,
      iconColor: const Color(0xFF7B1FA2),
      badge: 'DEAL',
      category: 'Electronics',
      description: 'Mouse wireless dengan tombol silent click, ideal untuk kantor atau penggunaan di malam hari. DPI adjustable hingga 1600, baterai tahan lama.',
      specs: ['Silent Click', 'Wireless 2.4GHz', 'DPI: 800/1200/1600', 'Battery Life: 12 months', 'Ergonomic Design', 'Plug & Play'],
      imageUrl: 'https://images.unsplash.com/photo-1615663245857-ac93bb7c39e7?w=400',
    ),
  ];
}

// ─────────────────────────────────────────────────────────────────────────────
// CHAT MODELS
// ─────────────────────────────────────────────────────────────────────────────

enum MessageType { text, image, order, productCard }

class ChatMessage {
  final String id;
  final String content;
  final bool isFromUser;
  final DateTime sentAt;
  final MessageType type;
  final ProductModel? product; // for productCard type
  final bool isRead;

  ChatMessage({
    required this.id,
    required this.content,
    required this.isFromUser,
    required this.sentAt,
    this.type = MessageType.text,
    this.product,
    this.isRead = false,
  });

  ChatMessage copyWith({bool? isRead}) => ChatMessage(
    id: id,
    content: content,
    isFromUser: isFromUser,
    sentAt: sentAt,
    type: type,
    product: product,
    isRead: isRead ?? this.isRead,
  );
}

class ChatRoom {
  final String shopId;
  final String shopName;
  final String shopAvatar;
  final Color shopColor;
  final List<ChatMessage> messages;
  bool isOnline;
  String? lastTypingText;

  ChatRoom({
    required this.shopId,
    required this.shopName,
    required this.shopAvatar,
    required this.shopColor,
    List<ChatMessage>? messages,
    this.isOnline = true,
    this.lastTypingText,
  }) : messages = messages ?? [];

  ChatMessage? get lastMessage =>
      messages.isEmpty ? null : messages.last;

  int get unreadCount =>
      messages.where((m) => !m.isFromUser && !m.isRead).length;
}
//hapus