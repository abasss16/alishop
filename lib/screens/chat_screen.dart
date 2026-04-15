import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

class ChatScreen extends StatefulWidget {
  final String shopId;
  final ProductModel? initialProduct;

  const ChatScreen({super.key, required this.shopId, this.initialProduct});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final _ctrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _canSend = false;
  late AnimationController _sendBtnCtrl;

  @override
  void initState() {
    super.initState();
    _sendBtnCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 200));
    _ctrl.addListener(() {
      final hasText = _ctrl.text.trim().isNotEmpty;
      if (hasText != _canSend) {
        setState(() => _canSend = hasText);
        hasText ? _sendBtnCtrl.forward() : _sendBtnCtrl.reverse();
      }
    });

    // Initialize room & mark read
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = context.read<AppState>();
      appState.getOrCreateRoom(widget.shopId,
          initialProduct: widget.initialProduct);
      appState.markRoomAsRead(widget.shopId);
      _scrollToBottom(animated: false);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scrollCtrl.dispose();
    _sendBtnCtrl.dispose();
    super.dispose();
  }

  void _send() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    _ctrl.clear();
    context.read<AppState>().sendMessage(widget.shopId, text);
    _scrollToBottom();
  }

  void _scrollToBottom({bool animated = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        if (animated) {
          _scrollCtrl.animateTo(
            _scrollCtrl.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        } else {
          _scrollCtrl.jumpTo(_scrollCtrl.position.maxScrollExtent);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final room = appState.chatRooms
        .firstWhere((r) => r.shopId == widget.shopId,
            orElse: () => ChatRoom(
              shopId: widget.shopId,
              shopName: 'Toko',
              shopAvatar: '',
              shopColor: const Color(0xFFFF6000),
            ));

    // Auto-scroll on new messages
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: _buildAppBar(room),
      body: Column(
        children: [
          Expanded(child: _buildMessageList(room, appState)),
          _buildInputBar(),
        ],
      ),
    );
  }

  AppBar _buildAppBar(ChatRoom room) {
    return AppBar(
      backgroundColor: const Color(0xFFFF6000),
      foregroundColor: Colors.white,
      titleSpacing: 0,
      leading: const BackButton(color: Colors.white),
      title: Row(
        children: [
          _ShopAvatar(room: room, size: 36),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(room.shopName,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold,
                    color: Colors.white),
                  overflow: TextOverflow.ellipsis),
                Row(children: [
                  Container(
                    width: 7, height: 7,
                    decoration: BoxDecoration(
                      color: room.isOnline ? const Color(0xFF4ADE80) : Colors.grey,
                      shape: BoxShape.circle)),
                  const SizedBox(width: 4),
                  Text(room.isOnline ? 'Online' : 'Offline',
                    style: const TextStyle(fontSize: 11, color: Colors.white70)),
                ]),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(icon: const Icon(Icons.phone_outlined, color: Colors.white), onPressed: () {}),
        IconButton(icon: const Icon(Icons.more_vert, color: Colors.white), onPressed: () {}),
      ],
    );
  }

  Widget _buildMessageList(ChatRoom room, AppState appState) {
    final messages = room.messages;
    final isTyping = room.lastTypingText != null;

    return ListView.builder(
      controller: _scrollCtrl,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      itemCount: messages.length + (isTyping ? 1 : 0),
      itemBuilder: (ctx, i) {
        if (i == messages.length) {
          return _TypingBubble(shopColor: room.shopColor);
        }
        final msg = messages[i];
        final showAvatar = !msg.isFromUser &&
            (i == 0 || messages[i - 1].isFromUser);
        final isLast = i == messages.length - 1 ||
            messages[i + 1].isFromUser != msg.isFromUser;

        return _MessageBubble(
          msg: msg,
          room: room,
          showAvatar: showAvatar,
          isLast: isLast,
        );
      },
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
          12, 8, 12, MediaQuery.of(context).padding.bottom + 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(
          color: Colors.black.withOpacity(0.07),
          blurRadius: 10, offset: const Offset(0, -2))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Attachment button
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.attach_file_rounded,
                color: Color(0xFFFF6000), size: 20)),
          ),
          const SizedBox(width: 8),
          // Text field
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 120),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(20)),
              child: TextField(
                controller: _ctrl,
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                style: const TextStyle(fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'Tulis pesan...',
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                onSubmitted: (_) => _send(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Send button — animated
          GestureDetector(
            onTap: _canSend ? _send : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 42, height: 42,
              decoration: BoxDecoration(
                color: _canSend
                    ? const Color(0xFFFF6000)
                    : const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(14)),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  _canSend ? Icons.send_rounded : Icons.mic_rounded,
                  key: ValueKey(_canSend),
                  color: Colors.white, size: 20)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Message Bubble ───────────────────────────────────────────────────────────
class _MessageBubble extends StatelessWidget {
  final ChatMessage msg;
  final ChatRoom room;
  final bool showAvatar;
  final bool isLast;

  const _MessageBubble({
    required this.msg,
    required this.room,
    required this.showAvatar,
    required this.isLast,
  });

  String _timeStr(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final isUser = msg.isFromUser;

    return Padding(
      padding: EdgeInsets.only(
        top: showAvatar ? 10 : 2,
        bottom: isLast ? 4 : 1,
        left: isUser ? 40 : 0,
        right: isUser ? 0 : 40,
      ),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Shop avatar
          if (!isUser)
            SizedBox(
              width: 32,
              child: showAvatar
                  ? _ShopAvatar(room: room, size: 28)
                  : const SizedBox(),
            ),
          if (!isUser) const SizedBox(width: 6),

          // Bubble content
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!isUser && showAvatar)
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 3),
                    child: Text(room.shopName,
                      style: TextStyle(fontSize: 11, color: Colors.grey[600],
                        fontWeight: FontWeight.w500)),
                  ),

                // The actual bubble
                _buildBubbleContent(context, isUser),

                // Time + read receipt
                Padding(
                  padding: const EdgeInsets.only(top: 2, left: 4, right: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_timeStr(msg.sentAt),
                        style: TextStyle(fontSize: 10, color: Colors.grey[500])),
                      if (isUser) ...[
                        const SizedBox(width: 3),
                        Icon(
                          msg.isRead ? Icons.done_all : Icons.done,
                          size: 13,
                          color: msg.isRead
                              ? const Color(0xFF4CAF50)
                              : Colors.grey[400]),
                      ],
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

  Widget _buildBubbleContent(BuildContext context, bool isUser) {
    if (msg.type == MessageType.productCard && msg.product != null) {
      return _ProductCardBubble(product: msg.product!, isUser: isUser);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isUser ? const Color(0xFFFF6000) : Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft: Radius.circular(isUser ? 18 : 4),
          bottomRight: Radius.circular(isUser ? 4 : 18),
        ),
        boxShadow: [BoxShadow(
          color: Colors.black.withOpacity(0.06), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Text(msg.content,
        style: TextStyle(
          fontSize: 14,
          color: isUser ? Colors.white : Colors.black87,
          height: 1.4)),
    );
  }
}

// ─── Product Card Bubble ──────────────────────────────────────────────────────
class _ProductCardBubble extends StatelessWidget {
  final ProductModel product;
  final bool isUser;

  const _ProductCardBubble({required this.product, required this.isUser});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFF6000).withOpacity(0.3)),
        boxShadow: [BoxShadow(
          color: Colors.black.withOpacity(0.06), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image area
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: product.color,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(13))),
            child: Center(
              child: Icon(product.icon, size: 52, color: product.iconColor)),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Row(children: [
                  Text('\$${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(color: Color(0xFFFF6000),
                      fontWeight: FontWeight.w800, fontSize: 13)),
                  const SizedBox(width: 6),
                  Text('-${product.discount}',
                    style: TextStyle(color: Colors.grey[500], fontSize: 10,
                      decoration: TextDecoration.lineThrough)),
                ]),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF0E8),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFFFF6000).withOpacity(0.3))),
                  child: Row(mainAxisSize: MainAxisSize.min, children: const [
                    Icon(Icons.storefront_outlined,
                      size: 12, color: Color(0xFFFF6000)),
                    SizedBox(width: 4),
                    Text('Tanya harga/ketersediaan',
                      style: TextStyle(fontSize: 10, color: Color(0xFFFF6000))),
                  ]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Typing Indicator ─────────────────────────────────────────────────────────
class _TypingBubble extends StatefulWidget {
  final Color shopColor;
  const _TypingBubble({required this.shopColor});

  @override
  State<_TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<_TypingBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 900))..repeat();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 4),
      child: Row(
        children: [
          const SizedBox(width: 38),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18), topRight: Radius.circular(18),
                bottomRight: Radius.circular(18), bottomLeft: Radius.circular(4)),
              boxShadow: [BoxShadow(
                color: Colors.black.withOpacity(0.06), blurRadius: 6)]),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) => AnimatedBuilder(
                animation: _ctrl,
                builder: (_, __) {
                  final phase = (_ctrl.value - i * 0.2).clamp(0.0, 1.0);
                  final y = phase < 0.5
                      ? -4 * phase
                      : -4 * (1 - phase);
                  return Transform.translate(
                    offset: Offset(0, y),
                    child: Container(
                      width: 7, height: 7,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: widget.shopColor.withOpacity(0.6),
                        shape: BoxShape.circle)),
                  );
                },
              )),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shop Avatar ──────────────────────────────────────────────────────────────
class _ShopAvatar extends StatelessWidget {
  final ChatRoom room;
  final double size;
  const _ShopAvatar({required this.room, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        color: room.shopColor.withOpacity(0.15),
        shape: BoxShape.circle,
        border: Border.all(color: room.shopColor.withOpacity(0.3), width: 1.5)),
      child: Icon(Icons.storefront_rounded, color: room.shopColor, size: size * 0.5),
    );
  }
}

// ─── Chat List Screen (inbox) ─────────────────────────────────────────────────
class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  String _timeStr(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inHours < 1) return '${diff.inMinutes} mnt lalu';
    if (diff.inDays < 1) return '${diff.inHours} jam lalu';
    return '${diff.inDays} hari lalu';
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final rooms = appState.chatRooms;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Pesan', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFFF6000),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: rooms.isEmpty
          ? _buildEmpty(context)
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: rooms.length,
              separatorBuilder: (_, __) => const Divider(
                height: 1, indent: 78, endIndent: 16,
                color: Color(0xFFEEEEEE)),
              itemBuilder: (ctx, i) {
                final room = rooms[i];
                final last = room.lastMessage;
                return ListTile(
                  onTap: () {
                    appState.markRoomAsRead(room.shopId);
                    Navigator.push(context, MaterialPageRoute(
                      builder: (_) => ChatScreen(shopId: room.shopId)));
                  },
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 6),
                  leading: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      _ShopAvatar(room: room, size: 50),
                      if (room.isOnline)
                        Positioned(bottom: 0, right: 0,
                          child: Container(
                            width: 13, height: 13,
                            decoration: BoxDecoration(
                              color: const Color(0xFF4ADE80),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2)))),
                    ],
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(room.shopName,
                          style: TextStyle(
                            fontWeight: room.unreadCount > 0
                                ? FontWeight.w700 : FontWeight.w500,
                            fontSize: 14),
                          overflow: TextOverflow.ellipsis)),
                      if (last != null)
                        Text(_timeStr(last.sentAt),
                          style: TextStyle(
                            fontSize: 11,
                            color: room.unreadCount > 0
                                ? const Color(0xFFFF6000) : Colors.grey[500])),
                    ],
                  ),
                  subtitle: Row(
                    children: [
                      if (last != null && last.isFromUser)
                        const Icon(Icons.done_all,
                          size: 13, color: Color(0xFF4CAF50)),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          last?.type == MessageType.productCard
                              ? '📦 ${last!.product?.name ?? "Produk"}'
                              : (last?.content ?? ''),
                          style: TextStyle(
                            fontSize: 12,
                            color: room.unreadCount > 0
                                ? Colors.black87 : Colors.grey[600],
                            fontWeight: room.unreadCount > 0
                                ? FontWeight.w500 : FontWeight.normal),
                          maxLines: 1, overflow: TextOverflow.ellipsis)),
                      if (room.unreadCount > 0)
                        Container(
                          margin: const EdgeInsets.only(left: 6),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                          decoration: const BoxDecoration(
                            color: Color(0xFFFF6000), shape: BoxShape.circle),
                          child: Text('${room.unreadCount}',
                            style: const TextStyle(
                              color: Colors.white, fontSize: 10,
                              fontWeight: FontWeight.bold))),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showShopPicker(context, appState),
        backgroundColor: const Color(0xFFFF6000),
        icon: const Icon(Icons.message_outlined, color: Colors.white),
        label: const Text('Pesan Toko', style: TextStyle(color: Colors.white)),
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
              borderRadius: BorderRadius.circular(28)),
            child: const Icon(Icons.chat_bubble_outline_rounded,
              size: 52, color: Color(0xFFFF6000))),
          const SizedBox(height: 20),
          const Text('Belum Ada Pesan',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Mulai chat dengan penjual untuk\nbertanya tentang produk',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600], fontSize: 13,
              height: 1.5)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showShopPicker(
              context, context.read<AppState>()),
            icon: const Icon(Icons.storefront_outlined),
            label: const Text('Hubungi Penjual'),
          ),
        ],
      ),
    );
  }

  void _showShopPicker(BuildContext context, AppState appState) {
    final shops = [
      {'id': 's1', 'name': 'TechZone Official', 'color': const Color(0xFF3D5AFE)},
      {'id': 's2', 'name': 'FashionHub Store',  'color': const Color(0xFFE91E63)},
      {'id': 's3', 'name': 'HomeDecor Plus',    'color': const Color(0xFF00C853)},
      {'id': 's4', 'name': 'SportsPro Shop',    'color': const Color(0xFFFF6000)},
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            const Text('Pilih Toko',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...shops.map((shop) => ListTile(
              leading: Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: (shop['color'] as Color).withOpacity(0.12),
                  shape: BoxShape.circle),
                child: Icon(Icons.storefront_rounded,
                  color: shop['color'] as Color, size: 22)),
              title: Text(shop['name'] as String,
                style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Online · Respon < 5 mnt',
                style: TextStyle(fontSize: 11)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14),
              onTap: () {
                Navigator.pop(context);
                appState.getOrCreateRoom(shop['id'] as String);
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => ChatScreen(shopId: shop['id'] as String)));
              },
            )),
          ],
        ),
      ),
    );
  }
}