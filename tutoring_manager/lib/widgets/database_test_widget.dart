import 'package:flutter/material.dart';
import '../services/database_service.dart';

class DatabaseTestWidget extends StatefulWidget {
  const DatabaseTestWidget({super.key});

  @override
  State<DatabaseTestWidget> createState() => _DatabaseTestWidgetState();
}

class _DatabaseTestWidgetState extends State<DatabaseTestWidget> {
  final DatabaseService _dbService = DatabaseService();
  Map<String, int>? _stats;
  bool _isLoading = true;
  String? _error;
  bool _connectionTest = false;

  @override
  void initState() {
    super.initState();
    _testDatabase();
  }

  Future<void> _testDatabase() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Test database connection
      _connectionTest = await _dbService.testConnection();
      
      // Get database statistics
      _stats = await _dbService.getDatabaseStats();
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.storage, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  'Database Status',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _testDatabase,
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (_isLoading)
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 8),
                    Text('Testing database connection...'),
                  ],
                ),
              )
            else if (_error != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.error, color: Colors.red.shade600),
                        const SizedBox(width: 8),
                        Text(
                          'Database Error',
                          style: TextStyle(
                            color: Colors.red.shade600,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _error!,
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                  ],
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _connectionTest 
                          ? Colors.green.shade50 
                          : Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _connectionTest 
                            ? Colors.green.shade200 
                            : Colors.orange.shade200,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _connectionTest ? Icons.check_circle : Icons.warning,
                          color: _connectionTest 
                              ? Colors.green.shade600 
                              : Colors.orange.shade600,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _connectionTest 
                              ? 'Database Connected Successfully' 
                              : 'Database Connection Failed',
                          style: TextStyle(
                            color: _connectionTest 
                                ? Colors.green.shade700 
                                : Colors.orange.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  if (_stats != null) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Database Statistics:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    ..._stats!.entries.map((entry) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.blue.shade400,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '${entry.key.substring(0, 1).toUpperCase()}${entry.key.substring(1)}:',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${entry.value}',
                              style: TextStyle(
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )).toList(),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }
}
