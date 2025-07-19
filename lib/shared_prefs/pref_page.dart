import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrefDemoPage extends StatefulWidget {
  const PrefDemoPage({super.key});

  @override
  State<PrefDemoPage> createState() => _PrefDemoPageState();
}

class _PrefDemoPageState extends State<PrefDemoPage> {
  final _controller = TextEditingController();
  static const _singleKey = 'myValue';
  String _single = '';

  @override
  void initState() {
    super.initState();
    _loadSingleValue();
  }

  Future<void> _loadSingleValue() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _single = prefs.getString(_singleKey) ?? '';
      _controller.text = _single;
    });
  }

  Future<void> _saveValue() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_singleKey, _controller.text);
    _loadSingleValue();
    _showSnackBar('Value saved');
  }

  Future<void> _deleteValue() async {
    final confirmed = await _showConfirmationDialog(
      title: 'Delete value?',
      content: 'This will remove the saved value permanently.',
    );
    if (confirmed == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_singleKey);
      setState(() {
        _single = '';
        _controller.clear();
      });
      _showSnackBar('Value deleted');
    }
  }

  Future<bool?> _showConfirmationDialog({
    required String title,
    required String content,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('SharedPrefs example')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Enter a value:', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(controller: _controller),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(onPressed: _saveValue, child: const Text('Add / Retrieve')),
                const SizedBox(width: 12),
                ElevatedButton(onPressed: _deleteValue, child: const Text('Delete')),
              ],
            ),
            const SizedBox(height: 24),
            Text('Stored value:', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              _single.isEmpty ? '(empty)' : _single,
              style: theme.textTheme.headlineSmall,
            ),
          ],
        ),
      ),
    );
  }
}
