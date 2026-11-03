import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:path/path.dart' as p;

/// Her örnek kendi deposunu kullanır; uygulama arşivinden bağımsızdır.
class HiveExampleScreen extends StatefulWidget {
  const HiveExampleScreen({super.key, required this.onHome});
  final VoidCallback onHome;
  @override
  State<HiveExampleScreen> createState() => _HiveExampleScreenState();
}

class _HiveExampleScreenState extends State<HiveExampleScreen> {
  final input = TextEditingController();
  Box<String>? box;
  @override
  void initState() {
    super.initState();
    run(() async {
      box = await Hive.openBox<String>('example_notes');
    });
  }

  bool busy = true;
  String? error;
  Future<void> run(Future<void> Function() action) async {
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await action();
    } catch (_) {
      error = 'Notlar kaydedilemedi veya okunamadı. Yeniden deneyin.';
    }
    if (mounted) setState(() => busy = false);
  }

  @override
  void dispose() {
    input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ExampleLayout(
    title: 'Hive CE · Not defteri',
    description: 'Notlar bir Hive kutusunda saklanır. Sayfayı yeniden açınca tekrar okunur.',
    onHome: widget.onHome,
    busy: busy,
    error: error,
    children: [
      TextField(
        controller: input,
        decoration: const InputDecoration(labelText: 'Yeni not'),
        maxLength: 200,
      ),
      FilledButton(
        onPressed: busy
            ? null
            : () => run(() async {
                if (box == null)
                  box = await Hive.openBox<String>('example_notes');
                if (input.text.trim().isEmpty) return;
                await box!.add(input.text.trim());
                if (mounted) input.clear();
              }),
        child: const Text('Not ekle'),
      ),
      if (box != null && box!.isEmpty) const Text('Henüz not yok.'),
      if (box != null)
        for (final key in box!.keys.toList().reversed)
          Card(
            child: ListTile(
              title: Text(box!.get(key)!),
              trailing: IconButton(
                tooltip: 'Notu sil',
                onPressed: busy ? null : () => run(() => box!.delete(key)),
                icon: const Icon(Icons.delete_outline),
              ),
            ),
          ),
      const SelectableText(
        "final box = await Hive.openBox<String>('example_notes');\nawait box.add('İlk not');\nfinal notes = box.values.toList();\nawait box.delete(key);",
      ),
    ],
  );
}

class PreferencesExampleScreen extends StatefulWidget {
  const PreferencesExampleScreen({super.key, required this.onHome});
  final VoidCallback onHome;
  @override
  State<PreferencesExampleScreen> createState() =>
      _PreferencesExampleScreenState();
}

class _PreferencesExampleScreenState extends State<PreferencesExampleScreen> {
  final prefs = SharedPreferencesAsync();
  final name = TextEditingController();
  bool notifications = true, busy = true;
  String? message;
  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      final savedName = await prefs.getString('example_name') ?? '';
      final savedNotifications =
          await prefs.getBool('example_notifications') ?? true;
      if (!mounted) return;
      name.text = savedName;
      setState(() {
        notifications = savedNotifications;
        busy = false;
      });
    } catch (_) {
      if (mounted)
        setState(() {
          message = 'Tercihler okunamadı.';
          busy = false;
        });
    }
  }

  Future<void> save() async {
    setState(() {
      busy = true;
      message = null;
    });
    try {
      await prefs.setString('example_name', name.text.trim());
      await prefs.setBool('example_notifications', notifications);
      if (mounted) setState(() => message = 'Tercihler kaydedildi.');
    } catch (_) {
      if (mounted) setState(() => message = 'Tercihler kaydedilemedi.');
    }
    if (mounted) setState(() => busy = false);
  }

  @override
  void dispose() {
    name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ExampleLayout(
    title: 'Shared Preferences · Tercihler',
    description:
        'Küçük kullanıcı tercihlerini anahtar ve değer olarak saklayın.',
    onHome: widget.onHome,
    busy: busy,
    children: [
      TextField(
        controller: name,
        enabled: !busy,
        decoration: const InputDecoration(labelText: 'Kullanıcı adı'),
      ),
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: const Text('Bildirim tercihi'),
        subtitle: const Text('Yalnızca tercih kaydedilir.'),
        value: notifications,
        onChanged: busy
            ? null
            : (value) => setState(() => notifications = value),
      ),
      FilledButton(
        onPressed: busy ? null : save,
        child: const Text('Tercihleri kaydet'),
      ),
      if (message != null) Text(message!),
      const SelectableText(
        "final prefs = SharedPreferencesAsync();\nawait prefs.setString('example_name', 'Ayşe');\nfinal name = await prefs.getString('example_name');",
      ),
    ],
  );
}

class SqliteExampleScreen extends StatefulWidget {
  const SqliteExampleScreen({super.key, required this.onHome});
  final VoidCallback onHome;
  @override
  State<SqliteExampleScreen> createState() => _SqliteExampleScreenState();
}

class _SqliteExampleScreenState extends State<SqliteExampleScreen> {
  Database? db;
  final input = TextEditingController();
  List<Map<String, Object?>> tasks = [];
  bool busy = true;
  String? error;
  @override
  void initState() {
    super.initState();
    run(() async {});
  }

  Future<void> run(Future<void> Function() action) async {
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final factory = kIsWeb ? databaseFactoryFfiWeb : databaseFactory;
      db ??= await factory.openDatabase(
        kIsWeb
            ? 'example_tasks.db'
            : p.join(await factory.getDatabasesPath(), 'example_tasks.db'),
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: (db, _) async {
            await db.execute(
              'CREATE TABLE tasks (id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT NOT NULL, done INTEGER NOT NULL DEFAULT 0)',
            );
          },
        ),
      );
      await action();
      final rows = await db!.query('tasks', orderBy: 'id DESC');
      if (mounted) tasks = rows;
    } catch (_) {
      error = 'Veritabanı açılamadı veya işlem tamamlanamadı. Yeniden deneyin.';
    }
    if (mounted) setState(() => busy = false);
  }

  @override
  void dispose() {
    input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ExampleLayout(
    title: 'sqflite · Yapılacaklar',
    description: 'Görev ekleyin, tamamlayın ve silin. Kayıtlar SQLite tablosunda saklanır.',
    onHome: widget.onHome,
    busy: busy,
    error: error,
    children: [
      TextField(
        controller: input,
        decoration: const InputDecoration(labelText: 'Yeni görev'),
        maxLength: 200,
      ),
      FilledButton(
        onPressed: busy
            ? null
            : () => run(() async {
                if (input.text.trim().isEmpty) return;
                await db!.insert('tasks', {
                  'title': input.text.trim(),
                  'done': 0,
                });
                if (mounted) input.clear();
              }),
        child: const Text('Görev ekle'),
      ),
      if (error != null)
        TextButton(
          onPressed: busy ? null : () => run(() async {}),
          child: const Text('Yeniden dene'),
        ),
      if (tasks.isEmpty && !busy && error == null)
        const Text('Henüz görev yok.'),
      for (final task in tasks)
        Card(
          child: ListTile(
            leading: Checkbox(
              value: task['done'] == 1,
              onChanged: busy
                  ? null
                  : (value) => run(() async {
                      await db!.update(
                        'tasks',
                        {'done': value == true ? 1 : 0},
                        where: 'id = ?',
                        whereArgs: [task['id']],
                      );
                    }),
            ),
            title: Text(
              task['title'] as String,
              style: TextStyle(
                decoration: task['done'] == 1
                    ? TextDecoration.lineThrough
                    : null,
              ),
            ),
            trailing: IconButton(
              tooltip: 'Görevi sil',
              onPressed: busy
                  ? null
                  : () => run(() async {
                      await db!.delete(
                        'tasks',
                        where: 'id = ?',
                        whereArgs: [task['id']],
                      );
                    }),
              icon: const Icon(Icons.delete_outline),
            ),
          ),
        ),
      const SelectableText(
        "await db.insert('tasks', {'title': 'Kitap oku', 'done': 0});\nfinal tasks = await db.query('tasks');\nawait db.update('tasks', {'done': 1}, where: 'id = ?', whereArgs: [id]);\nawait db.delete('tasks', where: 'id = ?', whereArgs: [id]);",
      ),
    ],
  );
}

class ExampleLayout extends StatelessWidget {
  const ExampleLayout({
    super.key,
    required this.title,
    required this.description,
    required this.onHome,
    required this.busy,
    this.error,
    required this.children,
  });
  final String title, description;
  final VoidCallback onHome;
  final bool busy;
  final String? error;
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(automaticallyImplyLeading: false, title: Text(title)),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(description),
            const SizedBox(height: 24),
            if (busy) const LinearProgressIndicator(),
            if (error != null) Text(error!),
            for (final child in children)
              Padding(padding: const EdgeInsets.only(bottom: 16), child: child),
          ],
        ),
      ),
    ),
  );
}
