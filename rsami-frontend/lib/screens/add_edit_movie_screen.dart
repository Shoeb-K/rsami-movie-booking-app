import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart';

class AddEditMovieScreen extends StatefulWidget {
  final Map<String, dynamic>? movie;
  const AddEditMovieScreen({super.key, this.movie});

  @override
  State<AddEditMovieScreen> createState() => _AddEditMovieScreenState();
}

class _AddEditMovieScreenState extends State<AddEditMovieScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _langController;
  late TextEditingController _durationController;
  late TextEditingController _genreController;
  late TextEditingController _posterController;
  late TextEditingController _trailerController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.movie?['title'] ?? '');
    _descController = TextEditingController(text: widget.movie?['description'] ?? '');
    _langController = TextEditingController(text: widget.movie?['language'] ?? '');
    _durationController = TextEditingController(text: widget.movie?['duration_minutes']?.toString() ?? '');
    _genreController = TextEditingController(text: widget.movie?['genre'] ?? '');
    _posterController = TextEditingController(text: widget.movie?['poster_url'] ?? '');
    _trailerController = TextEditingController(text: widget.movie?['trailer_url'] ?? '');
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    
    final movieData = {
      'title': _titleController.text,
      'description': _descController.text,
      'language': _langController.text,
      'duration_minutes': int.parse(_durationController.text),
      'genre': _genreController.text,
      'poster_url': _posterController.text,
      'trailer_url': _trailerController.text,
    };

    try {
      if (widget.movie == null) {
        await ApiService.createMovie(auth.token!, movieData);
      } else {
        await ApiService.updateMovie(auth.token!, widget.movie!['id'], movieData);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.movie == null ? 'Add Movie' : 'Edit Movie')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildField(_titleController, 'Title'),
              const SizedBox(height: 15),
              _buildField(_descController, 'Description', maxLines: 3),
              const SizedBox(height: 15),
              _buildField(_langController, 'Language'),
              const SizedBox(height: 15),
              _buildField(_durationController, 'Duration (minutes)', keyboardType: TextInputType.number),
              const SizedBox(height: 15),
              _buildField(_genreController, 'Genre'),
              const SizedBox(height: 15),
              _buildField(_posterController, 'Poster URL'),
              const SizedBox(height: 15),
              _buildField(_trailerController, 'Trailer URL'),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _save,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black),
                  child: _isLoading ? const CircularProgressIndicator() : const Text('SAVE MOVIE'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String label, {int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
    );
  }
}
