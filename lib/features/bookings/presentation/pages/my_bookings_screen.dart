import 'package:flutter/material.dart';
import '../../../../core/responsive/responsive_container.dart';
import '../../../../core/services/pdf_service.dart';
import '../../../../core/services/print_service.dart';
import '../../../../core/services/share_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../models/booking.dart';
import '../../models/booking_type.dart';
import '../../services/booking_repository.dart';
import '../widgets/booking_card.dart';
import 'booking_details_screen.dart';
import 'booking_document_screen.dart';

class MyBookingsScreen extends StatefulWidget {
  final BookingRepository repository;
  final PdfService pdfService;
  final PrintService printService;
  final ShareService shareService;

  const MyBookingsScreen({
    super.key,
    required this.repository,
    required this.pdfService,
    required this.printService,
    required this.shareService,
  });

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Booking> _allBookings = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadBookings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadBookings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final bookings = await widget.repository.getBookings();
      if (mounted) {
        setState(() {
          _allBookings = bookings;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load bookings: $e';
          _isLoading = false;
        });
      }
    }
  }

  List<Booking> _filterBookings(int tabIndex) {
    switch (tabIndex) {
      case 1: // Flights
        return _allBookings.where((b) => b.bookingType == BookingType.flight).toList();
      case 2: // Hotels
        return _allBookings.where((b) => b.bookingType == BookingType.hotel).toList();
      case 3: // Packages
        return _allBookings.where((b) => b.bookingType == BookingType.flightAndHotel).toList();
      case 0: // All
      default:
        return _allBookings;
    }
  }

  void _navigateToDetails(Booking booking) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BookingDetailsScreen(
          booking: booking,
          pdfService: widget.pdfService,
          printService: widget.printService,
          shareService: widget.shareService,
        ),
      ),
    );
  }

  void _navigateToDocument(Booking booking) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BookingDocumentScreen(
          booking: booking,
          pdfService: widget.pdfService,
          printService: widget.printService,
          shareService: widget.shareService,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppTheme.accentBlue,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.travel_explore, size: 18, color: Colors.white),
            ),
            const SizedBox(width: 8),
            const Flexible(
              child: Text(
                'TRAVELGO • My Bookings',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          indicatorColor: AppTheme.electricCyan,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(text: 'All Bookings'),
            Tab(text: 'Flights'),
            Tab(text: 'Hotels'),
            Tab(text: 'Flight + Hotel'),
          ],
          onTap: (_) => setState(() {}),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: AppTheme.errorRed),
                      const SizedBox(height: 12),
                      Text(_errorMessage!),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _loadBookings,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildBookingList(_filterBookings(0)),
                    _buildBookingList(_filterBookings(1)),
                    _buildBookingList(_filterBookings(2)),
                    _buildBookingList(_filterBookings(3)),
                  ],
                ),
    );
  }

  Widget _buildBookingList(List<Booking> bookings) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inventory_2_outlined, size: 56, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            const Text(
              'No bookings found',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textMuted),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBookings,
      child: ResponsiveContainer(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 900;
            if (isWide) {
              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisExtent: 210,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: bookings.length,
                itemBuilder: (context, index) {
                  final booking = bookings[index];
                  return BookingCard(
                    booking: booking,
                    onTap: () => _navigateToDetails(booking),
                    onViewDocument: () => _navigateToDocument(booking),
                  );
                },
              );
            }

            return ListView.builder(
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final booking = bookings[index];
                return BookingCard(
                  booking: booking,
                  onTap: () => _navigateToDetails(booking),
                  onViewDocument: () => _navigateToDocument(booking),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
