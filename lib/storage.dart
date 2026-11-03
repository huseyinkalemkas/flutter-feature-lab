import 'package:flutter/foundation.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

/// Web'de IndexedDB, mobilde uygulamanın yerel deposu kullanılır.
class AppStorage {
  static Box<dynamic>? _box;
  static final Map<String, Map<String, dynamic>> _memory = {};
  static final changes = ValueNotifier<int>(0);
  static bool get persistent => _box != null;

  static Future<void> initialize({String? directory}) async {
    if (directory == null) {
      await Hive.initFlutter();
    } else {
      Hive.init(directory);
    }
    _box = await Hive.openBox<dynamic>('proje_dosya_v1');
    _memory.clear();
    for (final key in _box!.keys) {
      final value = _box!.get(key);
      if (key is String && value is Map) {
        _memory[key] = Map<String, dynamic>.from(value);
      }
    }
    changes.value++;
  }

  static Map<String, dynamic>? get(String key) => _memory[key];
  static List<Map<String, dynamic>> records(String prefix) => _memory.entries
      .where((entry) => entry.key.startsWith(prefix))
      .map((entry) => entry.value)
      .toList();
  static Future<void> put(String key, Map<String, dynamic> value) async {
    await _box?.put(key, value);
    _memory[key] = value;
    changes.value++;
  }

  static Future<void> remove(String key) async {
    await _box?.delete(key);
    _memory.remove(key);
    changes.value++;
  }

  static Future<void> close() async {
    await _box?.close();
    _box = null;
    _memory.clear();
    changes.value++;
  }

  static void resetForTest() {
    assert(_box == null);
    _memory.clear();
    changes.value++;
  }
}

class Customer {
  final String id, name, contact;
  const Customer({required this.id, required this.name, this.contact = ''});
  Map<String, dynamic> toMap() => {'id': id, 'name': name, 'contact': contact};
  factory Customer.fromMap(Map<String, dynamic> map) => Customer(
    id: map['id'] as String,
    name: map['name'] as String,
    contact: map['contact'] as String? ?? '',
  );
}

class Project {
  final String id, customerId, name, description;
  final bool completed;
  const Project({
    required this.id,
    required this.customerId,
    required this.name,
    this.description = '',
    this.completed = false,
  });
  Map<String, dynamic> toMap() => {
    'id': id,
    'customerId': customerId,
    'name': name,
    'description': description,
    'completed': completed,
  };
  factory Project.fromMap(Map<String, dynamic> map) => Project(
    id: map['id'] as String,
    customerId: map['customerId'] as String,
    name: map['name'] as String,
    description: map['description'] as String? ?? '',
    completed: map['completed'] as bool? ?? false,
  );
  Project copyWith({bool? completed}) => Project(
    id: id,
    customerId: customerId,
    name: name,
    description: description,
    completed: completed ?? this.completed,
  );
}

class WorkspaceStore {
  static String newId() => DateTime.now().microsecondsSinceEpoch.toString();
  static List<Customer> get customers =>
      AppStorage.records('customer:').map(Customer.fromMap).toList();
  static List<Project> get projects =>
      AppStorage.records('project:').map(Project.fromMap).toList();
  static Customer? customer(String id) {
    final map = AppStorage.get('customer:$id');
    return map == null ? null : Customer.fromMap(map);
  }

  static Project? project(String id) {
    final map = AppStorage.get('project:$id');
    return map == null ? null : Project.fromMap(map);
  }

  static Future<void> saveCustomer(Customer customer) =>
      AppStorage.put('customer:${customer.id}', customer.toMap());
  static Future<void> saveProject(Project project) =>
      AppStorage.put('project:${project.id}', project.toMap());
}
