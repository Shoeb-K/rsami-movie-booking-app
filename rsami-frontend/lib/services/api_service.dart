import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ApiService {
  // Use your local IP or the tunnel URL here
  static const String baseUrl = 'http://localhost:3000/api';

  static Future<List<dynamic>> fetchMovies() async {
    final response = await http.get(Uri.parse('$baseUrl/movies'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to load movies');
  }

  static Future<List<dynamic>> fetchShowtimes(String movieId) async {
    final response = await http.get(Uri.parse('$baseUrl/shows/movie/$movieId'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to load showtimes');
  }

  static Future<List<dynamic>> fetchShowSeats(String showId) async {
    final response = await http.get(Uri.parse('$baseUrl/shows/$showId/seats'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to load seats');
  }

  static Future<Map<String, dynamic>> createBooking(String token, String showId, List<String> showSeatIds) async {
    final response = await http.post(
      Uri.parse('$baseUrl/bookings'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'showId': showId,
        'showSeatIds': showSeatIds,
      }),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    }
    throw Exception(json.decode(response.body)['error'] ?? 'Booking failed');
  }
}

class SocketService {
  late IO.Socket socket;

  void initSocket(String showId, Function(dynamic) onSeatLocked) {
    socket = IO.io('http://localhost:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.connect();

    socket.onConnect((_) {
      print('Connected to Socket');
      socket.emit('join_show', showId);
    });

    socket.on('seat_locked', (data) {
      onSeatLocked(data);
    });

    socket.on('seats_released', (data) {
      print('Seats released: ${data['showSeatIds']}');
    });
  }

  void lockSeat(String showSeatId, String showId, String userId) {
    socket.emit('lock_seat', {
      'showSeatId': showSeatId,
      'showId': showId,
      'userId': userId,
    });
  }

  void dispose() {
    socket.dispose();
  }
}
