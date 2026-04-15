import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import 'product_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  final String? initialQuery;
  const SearchScreen({super.key, this.initialQuery});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _ctrl = TextEditingController();
  String _query = '';
  String _selectedCategory = 'Semua';
  String _sortBy = 'Relevan';

  final List<String> _categories = ['Semua', 'Electronics', 'Sports', 'Beauty', 'Fashion'];
  final List<String> _sortOptions = ['Relevan', 'Harga Terendah', 'Harga Tertinggi', 'Rating'];
  final List<String> _recent = ['Wireless Earbuds', 'Smart Watch', 'Speaker Bluetooth', 'Skincare'];

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null) {
      _ctrl.text = widget.initialQuery!;
      _query = widget.initialQuery!;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  List<ProductModel> get _results {
    var products = AppState.allProducts;
    if (_query.isNotEmpty) {
      products = products
          .where((p) =>
              p.name.toLowerCase().contains(_query.toLowerCase()) ||
              p.category.toLowerCase().contains(_query.toLowerCase()))
          .toList();
    }
    if (_selectedCategory != 'Semua') {
      products = products.where((p) => p.category == _selectedCategory).toList();
    }
    switch (_sortBy) {
      case 'Harga Terendah':
        products.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'Harga Tertinggi':
        products.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'Rating':
        products.sort((a, b) => b.rating.compareTo(a.rating));
        break;
    }
    return products;
  }

  @override
  Widget build(BuildContext context) {
    final results = _results;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF6000),
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        titleSpacing: 0,
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextField(
            controller: _ctrl,
            autofocus: widget.initialQuery == null,
            onChanged: (v) => setState(() => _query = v),
            onSubmitted: (v) => setState(() => _query = v),
            decoration: InputDecoration(
              hintText: 'Cari produk...',
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
              prefixIcon: const Icon(Icons.search, color: Color(0xFFFF6000), size: 20),
              suffixIcon: _query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close, size: 18, color: Colors.grey),
                      onPressed: () {
                        _ctrl.clear();
                        setState(() => _query = '');
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('Cari', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter bar
          Container(
            color: Colors.white,
            child: Column(
              children: [
                // Category chips
                SizedBox(
                  height: 46,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    itemCount: _categories.length,
                    itemBuilder: (context, i) {
                      final cat = _categories[i];
                      final sel = cat == _selectedCategory;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedCategory = cat),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                          decoration: BoxDecoration(
                            color: sel ? const Color(0xFFFF6000) : const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: sel ? const Color(0xFFFF6000) : Colors.grey[300]!),
                          ),
                          child: Text(cat,
                            style: TextStyle(
                              color: sel ? Colors.white : Colors.grey[700],
                              fontSize: 12, fontWeight: FontWeight.w500)),
                        ),
                      );
                    },
                  ),
                ),
                // Sort row
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                  child: Row(
                    children: [
                      const Icon(Icons.sort, size: 16, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text('Urutkan:', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _sortOptions.map((opt) {
                              final sel = opt == _sortBy;
                              return GestureDetector(
                                onTap: () => setState(() => _sortBy = opt),
                                child: Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: sel ? const Color(0xFFFFF0E8) : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: sel ? const Color(0xFFFF6000) : Colors.grey[300]!),
                                  ),
                                  child: Text(opt,
                                    style: TextStyle(
                                      color: sel ? const Color(0xFFFF6000) : Colors.grey[600],
                                      fontSize: 11, fontWeight: sel ? FontWeight.w600 : FontWeight.normal)),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _query.isEmpty
                ? _buildEmptySearch()
                : results.isEmpty
                    ? _buildNoResults()
                    : _buildResults(results),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySearch() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Pencarian Terbaru',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[700])),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: _recent.map((r) => GestureDetector(
            onTap: () {
              _ctrl.text = r;
              setState(() => _query = r);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.history, size: 14, color: Colors.grey),
                  const SizedBox(width: 6),
                  Text(r, style: const TextStyle(fontSize: 13)),
                ],
              ),
            ),
          )).toList(),
        ),
        const SizedBox(height: 24),
        Text('Populer Sekarang',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[700])),
        const SizedBox(height: 12),
        ...List.generate(5, (i) => ListTile(
          dense: true,
          leading: Container(
            width: 28, height: 28,
            decoration: BoxDecoration(
              color: const Color(0xFFFF6000).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text('${i + 1}',
                style: const TextStyle(color: Color(0xFFFF6000), fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ),
          title: Text(AppState.allProducts[i].name, style: const TextStyle(fontSize: 13)),
          trailing: const Icon(Icons.trending_up, color: Color(0xFFFF6000), size: 18),
          onTap: () {
            _ctrl.text = AppState.allProducts[i].name;
            setState(() => _query = AppState.allProducts[i].name);
          },
        )),
      ],
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 72, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text('Tidak ada produk untuk "$_query"',
            style: TextStyle(color: Colors.grey[500], fontSize: 15)),
          const SizedBox(height: 8),
          const Text('Coba kata kunci lain', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildResults(List<ProductModel> results) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, childAspectRatio: 0.72,
        crossAxisSpacing: 10, mainAxisSpacing: 10,
      ),
      itemCount: results.length,
      itemBuilder: (context, i) => _buildCard(results[i]),
    );
  }

// Update _buildCard method in search_screen.dart
  Widget _buildCard(ProductModel p) {
    final appState = context.watch<AppState>();
    return GestureDetector(
      onTap: () => Navigator.push(context,
        MaterialPageRoute(builder: (_) => ProductDetailScreen(product: p))),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              child: Stack(
                children: [
                  Image.network(
                    p.imageUrl,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 120,
                        color: p.color,
                        child: Center(child: Icon(p.icon, size: 58, color: p.iconColor)),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 120,
                        color: p.color,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: p.iconColor,
                            strokeWidth: 2,
                          ),
                        ),
                      );
                    },
                  ),
                  Positioned(top: 8, left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(6)),
                      child: Text(p.badge, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800)),
                    )),
                  Positioned(top: 6, right: 6,
                    child: GestureDetector(
                      onTap: () => appState.toggleWishlist(p),
                      child: Container(
                        width: 28, height: 28,
                        decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: Icon(
                          appState.isWishlisted(p.id) ? Icons.favorite : Icons.favorite_border,
                          size: 15,
                          color: appState.isWishlisted(p.id) ? Colors.red : Colors.grey,
                        ),
                      ),
                    )),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text('\$${p.price.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFFFF6000))),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6000).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4)),
                        child: Text('-${p.discount}',
                          style: const TextStyle(color: Color(0xFFFF6000), fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text('\$${p.originalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 10, color: Colors.grey,
                      decoration: TextDecoration.lineThrough)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 11, color: Color(0xFFFFC107)),
                      const SizedBox(width: 2),
                      Text('${p.rating} (${p.reviews})',
                        style: const TextStyle(fontSize: 10, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}