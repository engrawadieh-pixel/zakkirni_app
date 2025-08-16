import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(const ZakkirniApp());
}

class ZakkirniApp extends StatelessWidget {
  const ZakkirniApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF66CCFF),
          brightness: Brightness.light,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> _people = ['أمي', 'أبي'];
  TimeOfDay _reminderTime = const TimeOfDay(hour: 8, minute: 0);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('ذكّرني'),
          leading: IconButton(onPressed: () {}, icon: const Icon(Icons.settings_outlined)),
          actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.info_outline))],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: _showAddPersonSheet,
                  icon: const Icon(Icons.add),
                  label: const Text('إضافة قريب', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: _people.isEmpty
                    ? _EmptyState(onAdd: _showAddPersonSheet)
                    : ListView.separated(
                        itemCount: _people.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final name = _people[index];
                          return ListTile(
                            leading: const Icon(Icons.notifications_active_outlined),
                            title: Text('اتصل بـ $name'),
                            subtitle: const Text('تذكير لطيف للتواصل'),
                            trailing: IconButton(
                              onPressed: () => setState(() => _people.removeAt(index)),
                              icon: const Icon(Icons.delete_outline),
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: _pickTime,
                  child: Text('يوميًا ${_formatTime(_reminderTime)}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddPersonSheet() {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            right: 16, left: 16, top: 16, bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('أضف قريبًا', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: 'الاسم (مثال: أمي، أبي، صديقي)',
                  prefixIcon: const Icon(Icons.favorite_border),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onSubmitted: (_) => _addPerson(controller.text),
              ),
              const SizedBox(height: 12),
              FilledButton(onPressed: () => _addPerson(controller.text), child: const Text('إضافة')),
            ],
          ),
        );
      },
    );
  }

  void _addPerson(String name) {
    final trimmed = name.trim();
    if (trimmed.isNotEmpty) {
      setState(() => _people.insert(0, trimmed));
      Navigator.of(context).pop();
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
      builder: (context, child) => Directionality(textDirection: TextDirection.rtl, child: child!),
    );
    if (picked != null) setState(() => _reminderTime = picked);
  }

  String _formatTime(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.notifications_none, size: 64),
        const SizedBox(height: 8),
        const Text('لا يوجد تذكيرات بعد', style: TextStyle(fontSize: 16)),
        const SizedBox(height: 8),
        OutlinedButton.icon(onPressed: onAdd, icon: const Icon(Icons.add), label: const Text('أضف أول تذكير')),
      ]),
    );
  }
}
