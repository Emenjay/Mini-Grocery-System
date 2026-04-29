// ════════════════════════════════════════════════════════════════════════════
//  notifications_screen.dart
//
//  REQUIRES in pubspec.yaml:
//    dependencies:
//      google_fonts: ^6.1.0
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DATA MODEL
// ─────────────────────────────────────────────────────────────────────────────
class _NotifItem {
  final String title;
  final String body;
  final String time;
  bool isRead;

  _NotifItem({
    required this.title,
    required this.body,
    required this.time,
    this.isRead = false,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// COLOURS
// ─────────────────────────────────────────────────────────────────────────────
const Color _pageBg       = Color(0xFF2F514C);
const Color _sectionLabel = Color(0xFF8DE3A9);
const Color _readCard     = Color(0xFFCCCBCB); // both "previous" and read-recent
const Color _unreadCard   = Colors.white;

// ─────────────────────────────────────────────────────────────────────────────
// SCREEN
// ─────────────────────────────────────────────────────────────────────────────
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<_NotifItem> _recent = [
    _NotifItem(title: 'Restock Alert: Malunggay Cream', body: 'Recently added Malunggay Pandesal on August 20, 2025 has been all sold out. Kindly follow up supplier to deliver new stocks.', time: '7:10 PM'),
    _NotifItem(title: 'Restock Alert: Malunggay Cream', body: 'Recently added Malunggay Pandesal on August 20, 2025 has been all sold out. Kindly follow up supplier to deliver new stocks.', time: '7:10 PM'),
    _NotifItem(title: 'Restock Alert: Malunggay Cream', body: 'Recently added Malunggay Pandesal on August 20, 2025 has been all sold out. Kindly follow up supplier to deliver new stocks.', time: '7:10 PM'),
    _NotifItem(title: 'Restock Alert: Malunggay Cream', body: 'Recently added Malunggay Pandesal on August 20, 2025 has been all sold out. Kindly follow up supplier to deliver new stocks.', time: '7:10 PM'),
  ];

  final List<_NotifItem> _previous = [
    _NotifItem(title: 'Restock Alert: Malunggay Cream', body: 'Recently added Malunggay Pandesal on August 20, 2025 has been all sold out. Kindly follow up supplier to deliver new stocks.', time: '7:10 PM', isRead: true),
    _NotifItem(title: 'Restock Alert: Malunggay Cream', body: 'Recently added Malunggay Pandesal on August 20, 2025 has been all sold out. Kindly follow up supplier to deliver new stocks.', time: '7:10 PM', isRead: true),
    _NotifItem(title: 'Restock Alert: Malunggay Cream', body: 'Recently added Malunggay Pandesal on August 20, 2025 has been all sold out. Kindly follow up supplier to deliver new stocks.', time: '7:10 PM', isRead: true),
    _NotifItem(title: 'Restock Alert: Malunggay Cream', body: 'Recently added Malunggay Pandesal on August 20, 2025 has been all sold out. Kindly follow up supplier to deliver new stocks.', time: '7:10 PM', isRead: true),
    _NotifItem(title: 'Restock Alert: Malunggay Cream', body: 'Recently added Malunggay Pandesal on August 20, 2025 has been all sold out. Kindly follow up supplier to deliver new stocks.', time: '7:10 PM', isRead: true),
    _NotifItem(title: 'Restock Alert: Malunggay Cream', body: 'Recently added Malunggay Pandesal on August 20, 2025 has been all sold out. Kindly follow up supplier to deliver new stocks.', time: '7:10 PM', isRead: true),
  ];

  void _markSingleRead(_NotifItem item) {
    setState(() => item.isRead = true);
  }

  void _markAllRead() {
    setState(() {
      for (final n in _recent)   n.isRead = true;
      for (final n in _previous) n.isRead = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBg,
      body: Column(
        children: [
          // HEADER
          _NotifHeader(onBack: () => Navigator.pop(context)),

          // BODY
          Expanded(
            child: Scrollbar(
              thumbVisibility: true,
              thickness: 4,
              radius: const Radius.circular(4),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 22),

                    // ── RECENT label + Mark All Read ──────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text('Recent',
                            style: GoogleFonts.poppins(
                              color: _sectionLabel,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          _MarkAllReadButton(onTap: _markAllRead),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    // ── RECENT cards — each is its own card with a gap ────
                    ..._recent.map((item) => _NotifCard(
                      item: item,
                      onTap: () => _markSingleRead(item),
                    )),

                    const SizedBox(height: 22),

                    // ── PREVIOUS label ────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text('Previous',
                        style: GoogleFonts.poppins(
                          color: _sectionLabel,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // ── PREVIOUS cards ────────────────────────────────────
                    ..._previous.map((item) => _NotifCard(
                      item: item,
                      onTap: () => _markSingleRead(item),
                    )),

                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HEADER — gradient + bottom shadow
// ─────────────────────────────────────────────────────────────────────────────
class _NotifHeader extends StatelessWidget {
  final VoidCallback onBack;
  const _NotifHeader({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0xFF2E4E49),
            Color(0xFF2E7C71),
            Color(0xFF48857B),
          ],
          stops: [0.0, 0.55, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x41000000),
            blurRadius: 18,
            spreadRadius: 2,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text('Notifications',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              Container(
                width: 1.5,
                height: 42,
                color: Colors.white38,
                margin: const EdgeInsets.only(right: 20),
              ),
              GestureDetector(
                onTap: onBack,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.18),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.arrow_back_rounded,
                      color: Colors.black87, size: 22),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK ALL READ BUTTON — scale + opacity press animation
// ─────────────────────────────────────────────────────────────────────────────
class _MarkAllReadButton extends StatefulWidget {
  final VoidCallback onTap;
  const _MarkAllReadButton({required this.onTap});

  @override
  State<_MarkAllReadButton> createState() => _MarkAllReadButtonState();
}

class _MarkAllReadButtonState extends State<_MarkAllReadButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _scale   = Tween<double>(begin: 1.0, end: 0.92).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _opacity = Tween<double>(begin: 1.0, end: 0.65).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  Future<void> _handleTap() async {
    await _ctrl.forward();
    widget.onTap();
    await _ctrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, child) => Transform.scale(
          scale: _scale.value,
          child: Opacity(opacity: _opacity.value, child: child),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text('Mark as All Read',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF3A5F58),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// NOTIFICATION CARD
//  • Each card is its own rounded container with a small bottom margin (gap)
//  • Tapping an unread card marks it as read with an animated colour fade
//  • Read cards  → _readCard  (light grey)
//  • Unread cards→ _unreadCard (white)
// ─────────────────────────────────────────────────────────────────────────────
class _NotifCard extends StatelessWidget {
  final _NotifItem   item;
  final VoidCallback onTap;

  const _NotifCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: item.isRead ? null : onTap, // only tap-able when unread
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 6), // gap between cards
        decoration: BoxDecoration(
          // Smoothly animates between white (unread) and grey (read)
          color: item.isRead ? _readCard : _unreadCard,
          boxShadow: item.isRead
              ? [] // read cards have no shadow — blend into bg
              : [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title + time row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(item.title,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                        height: 1.3,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(item.time,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.black54,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              // Body
              Text(item.body,
                style: GoogleFonts.poppins(
                  fontSize: 11.5,
                  color: Colors.black54,
                  height: 1.45,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}