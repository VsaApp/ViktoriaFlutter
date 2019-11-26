import 'dart:convert';
import 'dart:io';

/// The test configuration
final Map<String, dynamic> config = json.decode(File('config.test.json').readAsStringSync());
