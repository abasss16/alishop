import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../providers/app_state.dart';
import 'search_screen.dart';
import 'product_detail_screen.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';
import 'chat_screen.dart';
import '../widgets/auth_gate.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  int _bannerIndex = 0;
  final PageController _bannerController = PageController();
  Timer? _bannerTimer;
  
  String _selectedCategory = 'Semua';

  final List<Map<String, dynamic>> _banners = [
    {
      'title': 'Mega Sale!',
      'subtitle': 'Diskon hingga 80% untuk Elektronik',
      'color1': const Color(0xFFFF4500),
      'color2': const Color(0xFFFF8C42),
      'icon': Icons.phone_android,
      'imageUrl': 'https://images.unsplash.com/photo-1498049794561-7780e7231661?w=800&h=400&fit=crop',
    },
    {
      'title': 'Fashion Terbaru',
      'subtitle': 'Koleksi Tren 2025 Sudah Hadir',
      'color1': const Color(0xFF6C63FF),
      'color2': const Color(0xFF9B8FFF),
      'icon': Icons.checkroom,
      'imageUrl': 'https://images.unsplash.com/photo-1445205170230-053b83016050?w=800&h=400&fit=crop',
    },
    {
      'title': 'Gratis Ongkir!',
      'subtitle': 'Pembelian di atas \$50 ke seluruh dunia',
      'color1': const Color(0xFF00B4D8),
      'color2': const Color(0xFF48CAE4),
      'icon': Icons.local_shipping,
      'imageUrl': 'https://images.unsplash.com/photo-1601924994987-69e26d50dc26?w=800&h=400&fit=crop',
    },
    {
      'title': 'Flash Deal Hari Ini',
      'subtitle': 'Stok terbatas, buruan beli!',
      'color1': const Color(0xFFFF6B6B),
      'color2': const Color(0xFFFFD93D),
      'icon': Icons.bolt,
      'imageUrl': 'https://images.unsplash.com/photo-1607083206968-13611e3d76db?w=800&h=400&fit=crop',
    },
  ];

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Semua', 'icon': Icons.apps, 'color': const Color(0xFFFF6000)},
    {'name': 'Elektronik', 'icon': Icons.devices, 'color': const Color(0xFFFF6B35)},
    {'name': 'Fashion', 'icon': Icons.checkroom, 'color': const Color(0xFF9B59B6)},
    {'name': 'Olahraga', 'icon': Icons.sports_soccer, 'color': const Color(0xFF2ECC71)},
    {'name': 'Kecantikan', 'icon': Icons.spa, 'color': const Color(0xFFE91E63)},
    {'name': 'Rumah Tangga', 'icon': Icons.home, 'color': const Color(0xFF3498DB)},
    {'name': 'Otomotif', 'icon': Icons.directions_car, 'color': const Color(0xFF607D8B)},
    {'name': 'Mainan', 'icon': Icons.toys, 'color': const Color(0xFFFF9800)},
  ];

  @override
  void initState() {
    super.initState();
    _bannerTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (_bannerController.hasClients && mounted) {
        setState(() {
          _bannerIndex = (_bannerIndex + 1) % _banners.length;
        });
        _bannerController.animateToPage(
          _bannerIndex,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    super.dispose();
  }

  List<ProductModel> _getFilteredProducts() {
    final allProducts = AppState.allProducts;
    if (_selectedCategory == 'Semua') {
      return allProducts;
    }
    final categoryMap = {
      'Elektronik': 'Electronics',
      'Fashion': 'Fashion',
      'Olahraga': 'Sports',
      'Kecantikan': 'Beauty',
    };
    final englishCategory = categoryMap[_selectedCategory] ?? _selectedCategory;
    return allProducts.where((p) => p.category == englishCategory).toList();
  }

  bool _isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 900;
  bool _isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600;

  @override
  Widget build(BuildContext context) {
    final isDesktop = _isDesktop(context);

    if (isDesktop) {
      return _buildDesktopLayout();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomeTab(context),
          const SearchScreen(),
          const CartScreen(),
          const ProfileScreen(),
          const ChatListScreen(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildDesktopLayout() {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          _buildDesktopAppBar(),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDesktopSideNav(),
                Expanded(
                  child: IndexedStack(
                    index: _currentIndex,
                    children: [
                      _buildHomeTab(context),
                      const SearchScreen(),
                      const CartScreen(),
                      const ProfileScreen(),
                      const ChatListScreen(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopAppBar() {
    final cartCount = context.watch<AppState>().cartCount;
    return Container(
      height: 60,
      color: const Color(0xFFFF6000),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(8)),
            child: const Text('ali',
              style: TextStyle(color: Color(0xFFFF6000),
                fontWeight: FontWeight.w900, fontSize: 18)),
          ),
          const SizedBox(width: 8),
          const Text('Shop', style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w300)),
          const SizedBox(width: 20),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _currentIndex = 1),
              child: Container(
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(20)),
                child: Row(
                  children: [
                    const SizedBox(width: 14),
                    const Icon(Icons.search, color: Color(0xFFFF6000), size: 16),
                    const SizedBox(width: 6),
                    Text('Cari produk, merek, kategori...',
                      style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: () => setState(() => _currentIndex = 2),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(18)),
              child: Row(
                children: [
                  Stack(
                    children: [
                      const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 18),
                      if (cartCount > 0)
                        Positioned(top: -3, right: -3,
                          child: Container(
                            width: 13, height: 13,
                            decoration: const BoxDecoration(color: Colors.yellow, shape: BoxShape.circle),
                            child: Center(
                              child: Text('$cartCount',
                                style: const TextStyle(fontSize: 7, fontWeight: FontWeight.bold, color: Colors.black)),
                            ))),
                    ],
                  ),
                  const SizedBox(width: 5),
                  const Text('Keranjang', style: TextStyle(color: Colors.white, fontSize: 12)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => setState(() => _currentIndex = 3),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(18)),
              child: Row(
                children: [
                  const Icon(Icons.person_outline, color: Colors.white, size: 18),
                  const SizedBox(width: 5),
                  const Text('Akun', style: TextStyle(color: Colors.white, fontSize: 12)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopSideNav() {
    final items = [
      {'icon': Icons.home_outlined, 'active': Icons.home, 'label': 'Beranda'},
      {'icon': Icons.search, 'active': Icons.search, 'label': 'Cari'},
      {'icon': Icons.shopping_cart_outlined, 'active': Icons.shopping_cart, 'label': 'Keranjang'},
      {'icon': Icons.person_outline, 'active': Icons.person, 'label': 'Akun'},
      {'icon': Icons.chat_bubble_outline, 'active': Icons.chat_bubble, 'label': 'Chat'},
    ];
    final cartCount = context.watch<AppState>().cartCount;

    return Container(
      width: 180,
      color: Colors.white,
      child: Column(
        children: [
          const SizedBox(height: 12),
          ...List.generate(items.length, (i) {
            final item = items[i];
            final isSelected = _currentIndex == i;
            final badge = i == 2 ? cartCount : 0;
            return GestureDetector(
              onTap: () => setState(() => _currentIndex = i),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFFF6000).withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Icon(
                          isSelected
                              ? item['active'] as IconData
                              : item['icon'] as IconData,
                          color: isSelected ? const Color(0xFFFF6000) : Colors.grey[600],
                          size: 20,
                        ),
                        if (badge > 0)
                          Positioned(top: -3, right: -3,
                            child: Container(
                              width: 12, height: 12,
                              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                              child: Center(
                                child: Text('$badge',
                                  style: const TextStyle(color: Colors.white, fontSize: 7, fontWeight: FontWeight.bold)),
                              ))),
                      ],
                    ),
                    const SizedBox(width: 8),
                    Text(item['label'] as String,
                      style: TextStyle(
                        fontSize: 13,
                        color: isSelected ? const Color(0xFFFF6000) : Colors.grey[700],
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      )),
                  ],
                ),
              ),
            );
          }),
          const Divider(indent: 12, endIndent: 12, height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('KATEGORI',
                style: TextStyle(fontSize: 9, color: Colors.grey[400],
                  fontWeight: FontWeight.w700, letterSpacing: 1)),
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final cat = _categories[index];
                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedCategory = cat['name'] as String;
                      _currentIndex = 0;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Row(
                      children: [
                        Container(
                          width: 24, height: 24,
                          decoration: BoxDecoration(
                            color: (cat['color'] as Color).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6)),
                          child: Icon(cat['icon'] as IconData, color: cat['color'] as Color, size: 13),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(cat['name'],
                            style: TextStyle(
                              fontSize: 12, 
                              color: _selectedCategory == cat['name'] 
                                  ? const Color(0xFFFF6000) 
                                  : Colors.grey[700],
                              fontWeight: _selectedCategory == cat['name'] 
                                  ? FontWeight.w600 
                                  : FontWeight.normal,
                            )),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text('AliShop v2.0', style: TextStyle(color: Colors.grey[400], fontSize: 10)),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeTab(BuildContext context) {
    final filteredProducts = _getFilteredProducts();
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = _isDesktop(context);
    final isTablet = _isTablet(context);

    int crossAxisCount;
    double childAspectRatio;
    double horizontalPadding;

    if (isDesktop) {
      final contentWidth = screenWidth - 180;
      crossAxisCount = contentWidth > 1100 ? 4 : 3;
      childAspectRatio = 0.75;
      horizontalPadding = 16;
    } else if (isTablet) {
      crossAxisCount = 3;
      childAspectRatio = 0.72;
      horizontalPadding = 12;
    } else {
      crossAxisCount = 2;
      childAspectRatio = 0.70;
      horizontalPadding = 10;
    }

    return CustomScrollView(
      slivers: [
        if (!isDesktop)
          SliverAppBar(
            pinned: true,
            backgroundColor: const Color(0xFFFF6000),
            toolbarHeight: 56,
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white, borderRadius: BorderRadius.circular(8)),
                  child: const Text('ali',
                    style: TextStyle(color: Color(0xFFFF6000),
                      fontWeight: FontWeight.w900, fontSize: 14)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const SearchScreen())),
                    child: Container(
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white, borderRadius: BorderRadius.circular(18)),
                      child: Row(
                        children: [
                          const SizedBox(width: 12),
                          const Icon(Icons.search, color: Color(0xFFFF6000), size: 16),
                          const SizedBox(width: 6),
                          Text('Cari produk...', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Stack(
                  children: [
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 22),
                      onPressed: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const CartScreen())),
                    ),
                    if (context.watch<AppState>().cartCount > 0)
                      Positioned(top: 0, right: 0,
                        child: Container(
                          width: 14, height: 14,
                          decoration: const BoxDecoration(color: Colors.yellow, shape: BoxShape.circle),
                          child: Center(
                            child: Text('${context.watch<AppState>().cartCount}',
                              style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.black)),
                          ))),
                  ],
                ),
              ],
            ),
          ),

        SliverToBoxAdapter(child: _buildBanner(context)),
        SliverToBoxAdapter(child: _buildCategories(context)),
        
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(horizontalPadding, 10, horizontalPadding, 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text('Produk', 
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    if (_selectedCategory != 'Semua') ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6000).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(_selectedCategory,
                          style: const TextStyle(color: Color(0xFFFF6000), fontSize: 11)),
                      ),
                    ],
                  ],
                ),
                Text('${filteredProducts.length} produk',
                  style: TextStyle(color: Colors.grey[600], fontSize: 11)),
              ],
            ),
          ),
        ),

        SliverPadding(
          padding: EdgeInsets.fromLTRB(horizontalPadding, 0, horizontalPadding, 80),
          sliver: filteredProducts.isEmpty
              ? SliverToBoxAdapter(
                  child: SizedBox(
                    height: 200,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.category_outlined, size: 48, color: Colors.grey[400]),
                          const SizedBox(height: 12),
                          Text('Tidak ada produk di kategori $_selectedCategory',
                            style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                          const SizedBox(height: 6),
                          TextButton(
                            onPressed: () => setState(() => _selectedCategory = 'Semua'),
                            child: const Text('Lihat semua produk', style: TextStyle(fontSize: 12)),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => _buildProductCard(filteredProducts[i], context),
                    childCount: filteredProducts.length,
                  ),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: childAspectRatio,
                    crossAxisSpacing: isDesktop ? 12 : 8,
                    mainAxisSpacing: isDesktop ? 12 : 8,
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildBanner(BuildContext context) {
    final isDesktop = _isDesktop(context);
    final bannerHeight = isDesktop ? 160.0 : 140.0;
    final margin = isDesktop ? 16.0 : 10.0;

    return Container(
      height: bannerHeight,
      margin: EdgeInsets.all(margin),
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(isDesktop ? 16 : 14),
              child: PageView.builder(
                controller: _bannerController,
                onPageChanged: (i) {
                  if (mounted) {
                    setState(() => _bannerIndex = i);
                  }
                },
                itemCount: _banners.length,
                itemBuilder: (context, index) {
                  final b = _banners[index];
                  return GestureDetector(
                    onTap: () {
                      if (b['title'] == 'Mega Sale!') {
                        setState(() => _selectedCategory = 'Elektronik');
                      } else if (b['title'] == 'Fashion Terbaru') {
                        setState(() => _selectedCategory = 'Fashion');
                      } else if (b['title'] == 'Flash Deal Hari Ini') {
                        setState(() => _selectedCategory = 'Semua');
                      }
                    },
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          b['imageUrl'] as String,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [b['color1'], b['color2']],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: Center(
                                child: Icon(b['icon'], 
                                  size: isDesktop ? 70 : 50,
                                  color: Colors.white.withOpacity(0.3)),
                              ),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [b['color1'], b['color2']],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, Colors.black.withOpacity(0.4)],
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(isDesktop ? 16 : 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.25),
                                  borderRadius: BorderRadius.circular(16)),
                                child: const Text('PENAWARAN TERBATAS',
                                  style: TextStyle(color: Colors.white, fontSize: 7,
                                    fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                              ),
                              SizedBox(height: isDesktop ? 6 : 4),
                              Text(b['title'],
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isDesktop ? 20 : 16,
                                  fontWeight: FontWeight.w900,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 3,
                                    ),
                                  ],
                                )),
                              const SizedBox(height: 2),
                              Text(b['subtitle'],
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.95),
                                  fontSize: isDesktop ? 10 : 9,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 2,
                                    ),
                                  ],
                                )),
                              SizedBox(height: isDesktop ? 8 : 6),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isDesktop ? 12 : 10,
                                  vertical: isDesktop ? 6 : 5),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text('Beli Sekarang',
                                  style: TextStyle(
                                    color: b['color1'],
                                    fontWeight: FontWeight.bold,
                                    fontSize: isDesktop ? 10 : 9)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_banners.length, (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: _bannerIndex == i ? 12 : 4,
              height: 4,
              decoration: BoxDecoration(
                color: _bannerIndex == i ? const Color(0xFFFF6000) : Colors.grey[400],
                borderRadius: BorderRadius.circular(2)),
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories(BuildContext context) {
    final isDesktop = _isDesktop(context);
    final isTablet = _isTablet(context);

    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(
        isDesktop ? 16 : 12, 10,
        isDesktop ? 16 : 12, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Kategori',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (isDesktop || isTablet)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isDesktop ? 8 : 4,
                childAspectRatio: 0.9,
                crossAxisSpacing: 6,
                mainAxisSpacing: 6,
              ),
              itemCount: _categories.length,
              itemBuilder: (context, i) => _buildCategoryItem(_categories[i], isDesktop),
            )
          else
            SizedBox(
              height: 70,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                itemBuilder: (context, i) => SizedBox(
                  width: 65,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: _buildCategoryItem(_categories[i], false),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(Map<String, dynamic> cat, bool isDesktop) {
    final isSelected = _selectedCategory == cat['name'];
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = cat['name'] as String;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: isDesktop ? 44 : 42,
            height: isDesktop ? 44 : 42,
            decoration: BoxDecoration(
              color: isSelected
                  ? (cat['color'] as Color)
                  : (cat['color'] as Color).withOpacity(0.12),
              borderRadius: BorderRadius.circular(isDesktop ? 14 : 12),
              border: Border.all(
                color: isSelected
                    ? (cat['color'] as Color)
                    : (cat['color'] as Color).withOpacity(0.2), 
                width: isSelected ? 1.5 : 1),
            ),
            child: Icon(cat['icon'] as IconData,
              color: isSelected ? Colors.white : cat['color'] as Color, 
              size: isDesktop ? 20 : 18),
          ),
          const SizedBox(height: 4),
          Text(cat['name'],
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isDesktop ? 9 : 8,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? const Color(0xFFFF6000) : Colors.grey[700],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildProductCard(ProductModel p, BuildContext context) {
    final appState = context.watch<AppState>();
    final isDesktop = _isDesktop(context);

    return GestureDetector(
      onTap: () => Navigator.push(context,
        MaterialPageRoute(builder: (_) => ProductDetailScreen(product: p))),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 55,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Stack(
                  children: [
                    Image.network(
                      p.imageUrl,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: p.color,
                          child: Center(
                            child: Icon(p.icon, size: isDesktop ? 50 : 45, color: p.iconColor),
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: p.color,
                          child: Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: p.iconColor,
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    Positioned(top: 6, left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red, borderRadius: BorderRadius.circular(4)),
                        child: Text(p.badge,
                          style: const TextStyle(color: Colors.white,
                            fontSize: 8, fontWeight: FontWeight.w800)),
                      )),
                    Positioned(top: 6, right: 6,
                      child: GestureDetector(
                        onTap: () => appState.toggleWishlist(p),
                        child: Container(
                          width: 24, height: 24,
                          decoration: BoxDecoration(
                            color: Colors.white, shape: BoxShape.circle,
                            boxShadow: [BoxShadow(
                              color: Colors.black.withOpacity(0.08), blurRadius: 3)]),
                          child: Icon(
                            appState.isWishlisted(p.id)
                                ? Icons.favorite
                                : Icons.favorite_border,
                            size: 12,
                            color: appState.isWishlisted(p.id)
                                ? Colors.red : Colors.grey),
                        ),
                      )),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 45,
              child: Padding(
                padding: EdgeInsets.all(isDesktop ? 8 : 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(p.name,
                        style: TextStyle(
                          fontSize: isDesktop ? 11 : 10,
                          fontWeight: FontWeight.w600),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Flexible(
                          child: Text('\$${p.price.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: isDesktop ? 13 : 12,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFFFF6000)),
                            overflow: TextOverflow.ellipsis),
                        ),
                        const SizedBox(width: 3),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF6000).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(3)),
                          child: Text('-${p.discount}',
                            style: const TextStyle(
                              color: Color(0xFFFF6000), fontSize: 8,
                              fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 1),
                    Text('\$${p.originalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 9, color: Colors.grey,
                        decoration: TextDecoration.lineThrough)),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 9, color: Color(0xFFFFC107)),
                        const SizedBox(width: 2),
                        Flexible(
                          child: Text('${p.rating} (${p.reviews})',
                            style: const TextStyle(fontSize: 8, color: Colors.grey),
                            overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    final cartCount = context.watch<AppState>().cartCount;
    final tabs = [
      {'icon': Icons.home_outlined, 'active': Icons.home, 'label': 'Home', 'badge': 0},
      {'icon': Icons.search, 'active': Icons.search, 'label': 'Cari', 'badge': 0},
      {'icon': Icons.shopping_cart_outlined, 'active': Icons.shopping_cart, 'label': 'Keranjang', 'badge': cartCount},
      {'icon': Icons.person_outline, 'active': Icons.person, 'label': 'Akun', 'badge': 0},
      {'icon': Icons.chat_bubble_outline, 'active': Icons.chat_bubble, 'label': 'Chat', 'badge': 0},
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(
          color: Colors.black.withOpacity(0.08), blurRadius: 10,
          offset: const Offset(0, -2))],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(tabs.length, (i) {
              final tab = tabs[i];
              final isSelected = _currentIndex == i;
              final badge = tab['badge'] as int;
              return GestureDetector(
                onTap: () => setState(() => _currentIndex = i),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Icon(
                          isSelected
                              ? tab['active'] as IconData
                              : tab['icon'] as IconData,
                          color: isSelected ? const Color(0xFFFF6000) : Colors.grey,
                          size: 22),
                        if (badge > 0)
                          Positioned(top: -4, right: -4,
                            child: Container(
                              width: 14, height: 14,
                              decoration: const BoxDecoration(
                                color: Colors.red, shape: BoxShape.circle),
                              child: Center(
                                child: Text('$badge',
                                  style: const TextStyle(
                                    color: Colors.white, fontSize: 8,
                                    fontWeight: FontWeight.bold))))),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(tab['label'] as String,
                      style: TextStyle(
                        fontSize: 10,
                        color: isSelected ? const Color(0xFFFF6000) : Colors.grey,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal)),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}