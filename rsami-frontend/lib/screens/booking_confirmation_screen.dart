import 'dart:convert';
import 'package:flutter/material.dart';

class BookingConfirmationScreen extends StatelessWidget {
  final Map<String, dynamic> bookingData;
  final String qrCodeBase64;

  const BookingConfirmationScreen({
    super.key, 
    required this.bookingData, 
    required this.qrCodeBase64
  });

  @override
  Widget build(BuildContext context) {
    // Remove the prefix if it exists (data:image/png;base64,)
    final String cleanBase64 = qrCodeBase64.contains(',') ? qrCodeBase64.split(',')[1] : qrCodeBase64;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Ticket', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'RSAMI CINEMAS',
                style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 3),
              ),
              const SizedBox(height: 20),
              const Divider(color: Colors.grey),
              const SizedBox(height: 20),
              
              // The QR Code
              Image.memory(
                base64Decode(cleanBase64),
                width: 200,
                height: 200,
                fit: BoxFit.cover,
              ),
              
              const SizedBox(height: 20),
              const Text(
                'Scan this at the entrance',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 30),
              
              _buildTicketInfo('Booking ID', bookingData['id'].toString().substring(0, 8).toUpperCase()),
              _buildTicketInfo('Date', 'Today, 05 May'),
              _buildTicketInfo('Seats', 'A1, A2'),
              
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const Text('Back to Home'),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTicketInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }
}
