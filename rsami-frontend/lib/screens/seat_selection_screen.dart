import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart';
import 'booking_confirmation_screen.dart';

class SeatSelectionScreen extends StatefulWidget {
  final String showId;
  const SeatSelectionScreen({super.key, required this.showId});

  @override
  State<SeatSelectionScreen> createState() => _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends State<SeatSelectionScreen> {
  final SocketService _socketService = SocketService();
  List<dynamic> _seats = [];
  List<String> _selectedSeatIds = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSeats();
    _initSocket();
  }

  void _loadSeats() async {
    try {
      final seats = await ApiService.fetchShowSeats(widget.showId);
      setState(() {
        _seats = seats;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading seats: $e');
    }
  }

  void _initSocket() {
    final userId = Provider.of<AuthProvider>(context, listen: false).userId ?? 'anonymous';
    _socketService.initSocket(widget.showId, (data) {
      // When a seat is locked by someone else, update the UI
      setState(() {
        final index = _seats.indexWhere((s) => s['id'] == data['showSeatId']);
        if (index != -1) {
          _seats[index]['status'] = 'LOCKED';
        }
      });
    });
  }

  void _toggleSeat(dynamic seat) {
    if (seat['status'] != 'AVAILABLE' && !_selectedSeatIds.contains(seat['id'])) return;

    setState(() {
      if (_selectedSeatIds.contains(seat['id'])) {
        _selectedSeatIds.remove(seat['id']);
      } else {
        _selectedSeatIds.add(seat['id']);
        // Emit lock event to server
        _socketService.lockSeat(seat['id'], widget.showId, Provider.of<AuthProvider>(context, listen: false).userId!);
      }
    });
  }

  void _confirmBooking() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    try {
      final result = await ApiService.createBooking(auth.token!, widget.showId, _selectedSeatIds);
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => BookingConfirmationScreen(
              bookingData: result['booking'],
              qrCodeBase64: result['ticketQr'],
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  void dispose() {
    _socketService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Seats')),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : Column(
            children: [
              const SizedBox(height: 20),
              // Screen
              Center(child: Container(width: 300, height: 5, color: Colors.white24)),
              const Center(child: Text('SCREEN', style: TextStyle(color: Colors.white24))),
              const SizedBox(height: 50),
              
              // Grid
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 10, mainAxisSpacing: 8, crossAxisSpacing: 8),
                  itemCount: _seats.length,
                  itemBuilder: (context, index) {
                    final seat = _seats[index];
                    bool isSelected = _selectedSeatIds.contains(seat['id']);
                    bool isBooked = seat['status'] == 'BOOKED';
                    bool isLocked = seat['status'] == 'LOCKED';

                    return GestureDetector(
                      onTap: () => _toggleSeat(seat),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isBooked ? Colors.red.withOpacity(0.3) : isLocked ? Colors.orange : isSelected ? Colors.amber : Colors.white10,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(child: Text('${seat['seat']['row']}${seat['seat']['number']}', style: const TextStyle(fontSize: 8))),
                      ),
                    );
                  },
                ),
              ),
              
              // Bottom Bar
              Container(
                padding: const EdgeInsets.all(30),
                color: Colors.black,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Seats: ${_selectedSeatIds.length}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ElevatedButton(
                      onPressed: _selectedSeatIds.isEmpty ? null : _confirmBooking,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black),
                      child: const Text('CONFIRM BOOKING'),
                    )
                  ],
                ),
              )
            ],
          ),
    );
  }
}
