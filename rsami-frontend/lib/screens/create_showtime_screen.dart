import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart';

class CreateShowtimeScreen extends StatefulWidget {
  const CreateShowtimeScreen({super.key});

  @override
  State<CreateShowtimeScreen> createState() => _CreateShowtimeScreenState();
}

class _CreateShowtimeScreenState extends State<CreateShowtimeScreen> {
  List<dynamic> _movies = [];
  String? _selectedMovieId;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = const TimeOfDay(hour: 18, minute: 0);
  final _priceController = TextEditingController(text: '250');
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadMovies();
  }

  Future<void> _loadMovies() async {
    try {
      final movies = await ApiService.fetchMovies();
      setState(() {
        _movies = movies;
        if (_movies.isNotEmpty) _selectedMovieId = _movies[0]['id'];
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  void _save() async {
    if (_selectedMovieId == null) return;

    setState(() => _isLoading = true);
    final auth = Provider.of<AuthProvider>(context, listen: false);

    // Construct full DateTime for start and end
    final startDateTime = DateTime(
      _selectedDate.year, _selectedDate.month, _selectedDate.day,
      _startTime.hour, _startTime.minute,
    );
    
    // Assume movie duration for end time, or just add 3 hours for now
    final endDateTime = startDateTime.add(const Duration(hours: 3));

    final showData = {
      'movie_id': _selectedMovieId,
      'show_date': startDateTime.toIso8601String(),
      'start_time': startDateTime.toIso8601String(),
      'end_time': endDateTime.toIso8601String(),
      'base_price': double.parse(_priceController.text),
    };

    try {
      await ApiService.createShowtime(auth.token!, showData);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Showtime and seats created!')));
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Showtime')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select Movie', style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              value: _selectedMovieId,
              isExpanded: true,
              items: _movies.map((m) => DropdownMenuItem<String>(
                value: m['id'],
                child: Text(m['title']),
              )).toList(),
              onChanged: (val) => setState(() => _selectedMovieId = val),
            ),
            const SizedBox(height: 30),
            
            ListTile(
              title: const Text('Date'),
              subtitle: Text(DateFormat('yyyy-MM-dd').format(_selectedDate)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context, 
                  initialDate: _selectedDate, 
                  firstDate: DateTime.now(), 
                  lastDate: DateTime.now().add(const Duration(days: 30))
                );
                if (date != null) setState(() => _selectedDate = date);
              },
            ),
            
            ListTile(
              title: const Text('Start Time'),
              subtitle: Text(_startTime.format(context)),
              trailing: const Icon(Icons.access_time),
              onTap: () async {
                final time = await showTimePicker(context: context, initialTime: _startTime);
                if (time != null) setState(() => _startTime = time);
              },
            ),

            const SizedBox(height: 20),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Base Price (₹)', border: OutlineInputBorder()),
            ),

            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _save,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black),
                child: _isLoading ? const CircularProgressIndicator() : const Text('CREATE SHOWTIME'),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Note: This will automatically generate a 50-seat layout for this show.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            )
          ],
        ),
      ),
    );
  }
}
