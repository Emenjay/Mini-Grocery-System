import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/notification_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// COLOURS - unchanged
// ─────────────────────────────────────────────────────────────────────────────
const Color _pageBg       = Color(0xFF2F514C);
const Color _sectionLabel = Color(0xFF8DE3A9);
const Color _readCard     = Color(0xFFCCCBCB);
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
  bool _isLoading = true;
  String? _errorMessage;

  // backend splits notifications by created_at date; we split into recent (today) and previous
  List<Map<String, dynamic>> _recent   = [];
  List<Map<String, dynamic>> _previous = [];

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await NotificationService.getAll();

    if (!mounted) return;

    if (result['success']) {
      final List<Map<String, dynamic>> all = (result['notifications'] as List)
          .map((n) => Map<String, dynamic>.from(n))
          .toList();

      // recent = unread, previous = read
      setState(() {
        _recent   = all.where((n) => n['is_read'] == false || n['is_read'] == 0).toList();
        _previous = all.where((n) => n['is_read'] == true  || n['is_read'] == 1).toList();
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage = result['message'];
        _isLoading = false;
      });
    }
  }

  // mark single as read — removes from recent and moves to previous
  Future<void> _markSingleRead(Map<String, dynamic> notification) async {
    if (notification['is_read'] == true || notification['is_read'] == 1) return;

    final success = await NotificationService.markOneRead(notification['notification_id']);
    if (success && mounted) {
      setState(() {
        // remove from recent
        _recent.removeWhere(
            (n) => n['notification_id'] == notification['notification_id']);
        // add to top of previous as read
        notification['is_read'] = true;
        _previous.insert(0, notification);
      });
    }
  }

  // mark all as read — moves everything from recent to previous
  Future<void> _markAllRead() async {
    await NotificationService.markAllRead();
    if (!mounted) return;
    setState(() {
      // mark all recent as read and move to previous
      for (final n in _recent) {
        n['is_read'] = true;
      }
      _previous.insertAll(0, _recent);
      _recent.clear();
    });
  }

  // format created_at timestamp to display time string e.g. "7:10 PM"
  String _formatTime(String? createdAt) {
    if (createdAt == null) return '';
    final dt = DateTime.tryParse(createdAt);
    if (dt == null) return '';
    final hour   = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBg,
      body: Column(
        children: [
          // HEADER — unchanged
          _NotifHeader(onBack: () => Navigator.pop(context)),

          // BODY
          Expanded(
            child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.white))
              : _errorMessage != null
                ? Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.redAccent)))
                : Scrollbar(
                    thumbVisibility: true,
                    thickness: 4,
                    radius: const Radius.circular(4),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 22),

                          // ── RECENT label + Mark All Read ─────────────
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text('Recent',
                                  style: GoogleFonts.poppins(color: _sectionLabel, fontSize: 15, fontWeight: FontWeight.w500),
                                ),
                                _MarkAllReadButton(onTap: _markAllRead),
                              ],
                            ),
                          ),

                          const SizedBox(height: 10),

                          if (_recent.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              child: Text('No recent notifications',
                                style: GoogleFonts.poppins(color: Colors.white38, fontSize: 13),
                              ),
                            )
                          else
                            ..._recent.map((n) => _NotifCard(
                              title: n['title']?.toString() ?? '',
                              body: n['message']?.toString() ?? '',
                              time: _formatTime(n['created_at']?.toString()),
                              isRead: n['is_read'] == true || n['is_read'] == 1,
                              onTap: () => _markSingleRead(n),
                            )),

                          const SizedBox(height: 22),

                          // ── PREVIOUS label ────────────────────────────
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text('Previous',
                              style: GoogleFonts.poppins(color: _sectionLabel, fontSize: 15, fontWeight: FontWeight.w500),
                            ),
                          ),

                          const SizedBox(height: 10),

                          if (_previous.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              child: Text('No previous notifications',
                                style: GoogleFonts.poppins(color: Colors.white38, fontSize: 13),
                              ),
                            )
                          else
                            ..._previous.map((n) => _NotifCard(
                              title: n['title']?.toString() ?? '',
                              body: n['message']?.toString() ?? '',
                              time: _formatTime(n['created_at']?.toString()),
                              isRead: n['is_read'] == true || n['is_read'] == 1,
                              onTap: () => _markSingleRead(n),
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
// HEADER — unchanged from original
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
          colors: [Color(0xFF2E4E49), Color(0xFF2E7C71), Color(0xFF48857B)],
          stops: [0.0, 0.55, 1.0],
        ),
        boxShadow: [BoxShadow(color: Color(0x41000000), blurRadius: 18, spreadRadius: 2, offset: Offset(0, 6))],
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
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w500, letterSpacing: 0.2),
                ),
              ),
              Container(width: 1.5, height: 42, color: Colors.white38, margin: const EdgeInsets.only(right: 20)),
              GestureDetector(
                onTap: onBack,
                child: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white, shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.18), blurRadius: 8, offset: const Offset(0, 3))],
                  ),
                  child: const Icon(Icons.arrow_back_rounded, color: Colors.black87, size: 22),
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
// MARK ALL READ BUTTON — unchanged from original
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
    _scale   = Tween<double>(begin: 1.0, end: 0.92).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _opacity = Tween<double>(begin: 1.0, end: 0.65).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
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
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 4, offset: const Offset(0, 2))],
          ),
          child: Text('Mark as All Read',
            style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xFF3A5F58)),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// NOTIFICATION CARD — refactored to accept plain fields instead of _NotifItem
// styling is identical to original
// ─────────────────────────────────────────────────────────────────────────────
class _NotifCard extends StatelessWidget {
  final String title;
  final String body;
  final String time;
  final bool isRead;
  final VoidCallback onTap;

  const _NotifCard({
    required this.title,
    required this.body,
    required this.time,
    required this.isRead,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isRead ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 6),
        decoration: BoxDecoration(
          color: isRead ? _readCard : _unreadCard,
          boxShadow: isRead
              ? []
              : [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(title,
                      style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87, height: 1.3),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(time,
                    style: GoogleFonts.poppins(fontSize: 11, color: Colors.black54, fontWeight: FontWeight.w400),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Text(body,
                style: GoogleFonts.poppins(fontSize: 11.5, color: Colors.black54, height: 1.45, fontWeight: FontWeight.w400),
              ),
            ],
          ),
        ),
      ),
    );
  }
}