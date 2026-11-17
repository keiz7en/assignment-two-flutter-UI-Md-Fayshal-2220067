import 'package:flutter/material.dart';
import 'student_details.dart';

void main() => runApp(const CampusFlowApp());

class Palette {
  static const blue = Color(0xFF2563EB);
  static const ink = Color(0xFF111827);
  static const muted = Color(0xFF6B7280);
  static const background = Color(0xFFE8EEF7);
  static const border = Color(0xFFCBD5E1);
  static const lightBlue = Color(0xFFEFF6FF);
  static const green = Color(0xFF10B981);
  static const amber = Color(0xFFF59E0B);
}

enum TaskPriority { high, medium, low }
extension PriorityInfo on TaskPriority {
  String get label => ['High', 'Medium', 'Low'][index];
  Color get color => [const Color(0xFFBE123C), const Color(0xFFB45309), const Color(0xFF047857)][index];
  Color get background => [const Color(0xFFFFE4E6), const Color(0xFFFEF3C7), const Color(0xFFD1FAE5)][index];
}

class StudyTask {
  StudyTask({required this.id, required this.title, required this.course,
    required this.due, required this.priority, this.done = false});
  final int id;
  final String title, course;
  final DateTime due;
  final TaskPriority priority;
  bool done;
}

DateTime dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);
bool sameDay(DateTime a, DateTime b) => dayOnly(a) == dayOnly(b);
const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
String timeLabel(DateTime d) => '${d.hour % 12 == 0 ? 12 : d.hour % 12}:${d.minute.toString().padLeft(2, '0')} ${d.hour >= 12 ? 'PM' : 'AM'}';
String dateLabel(DateTime d) {
  final diff = dayOnly(d).difference(dayOnly(DateTime.now())).inDays;
  if (diff == 0) return 'Today';
  if (diff == 1) return 'Tomorrow';
  return '${weekdays[d.weekday - 1]}, ${d.day} ${months[d.month - 1]}';
}

class CampusFlowApp extends StatefulWidget {
  const CampusFlowApp({super.key});
  @override
  State<CampusFlowApp> createState() => _CampusFlowAppState();
}

class _CampusFlowAppState extends State<CampusFlowApp> {
  bool dark = false;
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'CampusFlow', debugShowCheckedModeBanner: false,
    themeMode: dark ? ThemeMode.dark : ThemeMode.light,
    theme: makeTheme(Brightness.light), darkTheme: makeTheme(Brightness.dark),
    home: MainShell(onThemeChanged: (value) => setState(() => dark = value)),
  );

  ThemeData makeTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return ThemeData(
      useMaterial3: true, brightness: brightness,
      scaffoldBackgroundColor: isDark ? const Color(0xFF111827) : Palette.background,
      colorScheme: ColorScheme.fromSeed(seedColor: Palette.blue, brightness: brightness,
        primary: Palette.blue, surface: isDark ? const Color(0xFF1F2937) : Colors.white),
      fontFamily: 'Roboto',
      textTheme: TextTheme(
        headlineMedium: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: isDark ? Colors.white : Palette.ink),
        titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: isDark ? Colors.white : Palette.ink),
        bodyMedium: TextStyle(fontSize: 14, color: isDark ? Colors.white : Palette.ink),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true, fillColor: isDark ? const Color(0xFF374151) : Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Palette.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Palette.border)),
      ),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key, required this.onThemeChanged});
  final ValueChanged<bool> onThemeChanged;
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  // Assignment requirement: the bottom tabs drive this PageView controller.
  final PageController _pageController = PageController();
  int selectedPage = 0;
  StudentDetails student = StudentDetails.initial();
  bool notifications = true, dark = false;
  TimeOfDay reminder = const TimeOfDay(hour: 20, minute: 0);
  late final List<StudyTask> tasks;

  @override
  void initState() {
    super.initState();
    final d = dayOnly(DateTime.now());
    tasks = [
      StudyTask(id: 1, title: 'Lab 6: Navigation and routing', course: 'CSE 464', due: d.add(const Duration(hours: 23, minutes: 59)), priority: TaskPriority.high),
      StudyTask(id: 2, title: 'Read chapter 7: Normalization', course: 'CSE 303', due: d.add(const Duration(hours: 18)), priority: TaskPriority.medium),
      StudyTask(id: 3, title: 'Submit quiz 3 reflection', course: 'MAT 212', due: d.add(const Duration(hours: 14)), priority: TaskPriority.low, done: true),
      StudyTask(id: 4, title: 'ER diagram for library system', course: 'CSE 303', due: d.add(const Duration(days: 1, hours: 17)), priority: TaskPriority.medium),
      StudyTask(id: 5, title: 'Watch lecture 9', course: 'CSE 464', due: d.add(const Duration(days: 1, hours: 20)), priority: TaskPriority.low),
    ];
  }

  @override
  void dispose() { _pageController.dispose(); super.dispose(); }

  void go(int index) {
    if (index == selectedPage) return;
    _pageController.animateToPage(index, duration: const Duration(milliseconds: 260), curve: Curves.easeInOut);
  }
  void toggle(StudyTask task) => setState(() => task.done = !task.done);
  void message(String text) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  Future<void> addTask() async {
    final result = await showModalBottomSheet<StudyTask>(
      context: context, isScrollControlled: true, useSafeArea: true,
      builder: (_) => AddTaskSheet(nextId: tasks.fold<int>(0, (m, t) => t.id > m ? t.id : m) + 1),
    );
    if (result != null && mounted) setState(() => tasks.add(result));
  }

  Future<void> editProfile() async {
    final result = await showModalBottomSheet<StudentDetails>(
      context: context, isScrollControlled: true, useSafeArea: true,
      builder: (_) => EditProfileSheet(initial: student),
    );
    if (result != null && mounted) setState(() => student = result);
  }

  @override
  Widget build(BuildContext context) {
    const labels = ['Home', 'Tasks', 'Profile', 'Progress'];
    const icons = [Icons.home_outlined, Icons.check_box_outlined, Icons.person_outline, Icons.bar_chart_outlined];
    return Scaffold(
      body: SafeArea(bottom: false, child: PageView(
        controller: _pageController,
        // The assignment demo requires click interactions only.
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) => setState(() => selectedPage = index),
        children: [
          HomePage(student: student, tasks: tasks, onTasks: () => go(1), onNotification: () => message(notifications ? 'You have ${tasks.where((t) => !t.done).length} pending tasks.' : 'Notifications are turned off.'), onTimetable: () => showDialog<void>(context: context, builder: (_) => AlertDialog(title: const Text("Today's classes"), content: const Text('10:00 AM — CSE 464\nRoom 7012\n\n1:30 PM — MAT 212\nRoom 3021'), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))]))),
          TasksPage(tasks: tasks, onToggle: toggle, onAdd: addTask),
          ProfilePage(student: student, onEdit: editProfile, notifications: notifications,
            onNotifications: (v) => setState(() => notifications = v), dark: dark,
            onDark: (v) { setState(() => dark = v); widget.onThemeChanged(v); },
            reminder: reminder, onReminder: () async {
              final time = await showTimePicker(context: context, initialTime: reminder);
              if (time != null && mounted) setState(() => reminder = time);
            }, onLogout: () => message('This assignment app uses a local profile; no online account is connected.')),
          ProgressPage(tasks: tasks),
        ],
      )),
      bottomNavigationBar: DecoratedBox(
         decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, border: Border(top: BorderSide(color: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).dividerColor : Palette.border))),
        child: SafeArea(top: false, child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: Row(children: List.generate(4, (i) => Expanded(child: Semantics(
            selected: i == selectedPage, button: true, label: labels[i],
            child: InkWell(key: Key('nav_${labels[i].toLowerCase()}'), onTap: () => go(i), borderRadius: BorderRadius.circular(18),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(width: 64, height: 32, alignment: Alignment.center,
                  decoration: BoxDecoration(color: i == selectedPage ? const Color(0xFFDBEAFE) : Colors.transparent, borderRadius: BorderRadius.circular(20)),
                  child: Icon(icons[i], size: 23, color: i == selectedPage ? Palette.blue : Palette.muted)),
                const SizedBox(height: 4),
                Text(labels[i], style: TextStyle(fontSize: 12, fontWeight: i == selectedPage ? FontWeight.w700 : FontWeight.w400, color: i == selectedPage ? Palette.blue : Palette.muted)),
              ]),
            ),
          )))),
        )),
      ),
    );
  }
}

class CardSurface extends StatelessWidget {
  const CardSurface({super.key, required this.child, this.padding = const EdgeInsets.all(18)});
  final Widget child;
  final EdgeInsets padding;
  @override
  Widget build(BuildContext context) => Container(padding: padding,
    decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface,
       borderRadius: BorderRadius.circular(20), border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).dividerColor : Palette.border)), child: child);
}

class Header extends StatelessWidget {
  const Header(this.title, {super.key, required this.icon, required this.onTap});
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Row(children: [
    Expanded(child: Text(title, style: Theme.of(context).textTheme.headlineMedium)),
    Container(decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: Palette.border)),
      child: IconButton(onPressed: onTap, icon: Icon(icon, size: 22), tooltip: title == 'Profile' ? 'Edit profile' : 'Select date')),
  ]);
}

class Avatar extends StatelessWidget {
  const Avatar(this.initials, {super.key, this.size = 44});
  final String initials;
  final double size;
  @override
  Widget build(BuildContext context) => Container(width: size, height: size, alignment: Alignment.center,
    decoration: const BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF60A5FA), Palette.blue])),
    child: Text(initials, style: TextStyle(fontSize: size * .34, fontWeight: FontWeight.w800, color: Colors.white)));
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.student, required this.tasks, required this.onTasks, required this.onNotification, required this.onTimetable});
  final StudentDetails student;
  final List<StudyTask> tasks;
  final VoidCallback onTasks, onNotification, onTimetable;
  @override
  State<HomePage> createState() => _HomePageState();
}
class _HomePageState extends State<HomePage> {
  DateTime selected = dayOnly(DateTime.now());
  @override
  Widget build(BuildContext context) {
    final monday = dayOnly(DateTime.now()).subtract(Duration(days: DateTime.now().weekday - 1));
    final due = widget.tasks.where((t) => !t.done).toList()..sort((a, b) => a.due.compareTo(b.due));
    final todayCount = widget.tasks.where((t) => sameDay(t.due, selected) && !t.done).length;
    return ListView(padding: const EdgeInsets.fromLTRB(20, 16, 20, 20), children: [
      Row(children: [Avatar(widget.student.initials), const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Good morning,', style: TextStyle(color: Palette.muted, fontSize: 13)), const SizedBox(height: 3),
          Text(widget.student.fullName, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700, color: Palette.blue)),
        ])),
        Container(decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(15), border: Border.all(color: Palette.border)),
          child: IconButton(onPressed: widget.onNotification, tooltip: 'Notifications', icon: const Badge(smallSize: 5, child: Icon(Icons.notifications_none, size: 23)))),
      ]),
      const SizedBox(height: 24),
      Row(children: List.generate(7, (i) {
        final day = monday.add(Duration(days: i)); final active = sameDay(day, selected);
        return Expanded(child: InkWell(onTap: () => setState(() => selected = day), borderRadius: BorderRadius.circular(24),
          child: Container(padding: const EdgeInsets.symmetric(vertical: 12), margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(color: active ? Palette.blue : Colors.transparent, borderRadius: BorderRadius.circular(24), boxShadow: active ? [BoxShadow(color: Palette.blue.withAlpha(55), blurRadius: 14, offset: const Offset(0, 6))] : null),
            child: Column(children: [Text(weekdays[i], style: TextStyle(fontSize: 11, color: active ? Colors.white70 : Palette.muted)), const SizedBox(height: 8),
              Text('${day.day}', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: active ? Colors.white : Theme.of(context).colorScheme.onSurface))]),
          ),
        ));
      })),
      const SizedBox(height: 24),
      ClipRRect(borderRadius: BorderRadius.circular(23), child: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Palette.blue, Color(0xFF1D4ED8), Color(0xFF1E3A8A)])),
        child: Stack(children: [
          Positioned(right: -30, top: -40, child: Container(width: 170, height: 170, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withAlpha(18)))),
          Positioned(right: 30, bottom: -95, child: Container(width: 175, height: 175, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withAlpha(12)))),
          Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text("TODAY'S STUDY GOAL", style: TextStyle(color: Colors.white70, fontSize: 12, letterSpacing: .3)), const SizedBox(height: 16),
            const Text.rich(TextSpan(children: [TextSpan(text: '2h 15m', style: TextStyle(fontSize: 31, fontWeight: FontWeight.w800)), TextSpan(text: ' of 3h', style: TextStyle(fontSize: 14))]), style: TextStyle(color: Colors.white)),
            const SizedBox(height: 18),
            ClipRRect(borderRadius: BorderRadius.circular(8), child: const LinearProgressIndicator(value: .75, minHeight: 8, backgroundColor: Colors.white24, color: Colors.white)),
            const SizedBox(height: 15), Text('$todayCount tasks due ${sameDay(selected, DateTime.now()) ? 'today' : 'on ${selected.day} ${months[selected.month - 1]}'} · 6 day streak', style: const TextStyle(color: Colors.white, fontSize: 13)),
          ])),
        ]),
      )),
      const SizedBox(height: 23),
      Section('Due soon', action: 'See all', onTap: widget.onTasks), const SizedBox(height: 10),
      if (due.isEmpty) const CardSurface(child: Text('All caught up!')),
      ...due.take(2).map((t) => Padding(padding: const EdgeInsets.only(bottom: 12), child: InkWell(onTap: widget.onTasks, borderRadius: BorderRadius.circular(20), child: TaskTile(task: t, compact: true)))),
      const SizedBox(height: 10),
      Section("Today's classes", action: 'Timetable', onTap: widget.onTimetable), const SizedBox(height: 12),
      const Row(children: [Expanded(child: ClassCard(time: '10:00 AM', course: 'CSE 464', room: 'Room 7012', green: false)), SizedBox(width: 12), Expanded(child: ClassCard(time: '1:30 PM', course: 'MAT 212', room: 'Room 3021', green: true))]),
    ]);
  }
}

class Section extends StatelessWidget {
  const Section(this.title, {super.key, this.action, this.onTap});
  final String title;
  final String? action;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Row(children: [Expanded(child: Text(title, style: Theme.of(context).textTheme.titleLarge)), if (action != null) TextButton(onPressed: onTap, style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(45, 32)), child: Text(action!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)))]);
}
class ClassCard extends StatelessWidget {
  const ClassCard({super.key, required this.time, required this.course, required this.room, required this.green});
  final String time, course, room;
  final bool green;
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: green ? const Color(0xFFECFDF5) : Palette.lightBlue, borderRadius: BorderRadius.circular(17)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(time, style: TextStyle(color: green ? const Color(0xFF047857) : const Color(0xFF1D4ED8), fontWeight: FontWeight.w700, fontSize: 13)), const SizedBox(height: 10),
    Text(course, style: const TextStyle(fontWeight: FontWeight.w700, color: Palette.ink)), const SizedBox(height: 4), Text(room, style: const TextStyle(fontSize: 12, color: Palette.muted)),
  ]));
}
class PriorityBadge extends StatelessWidget {
  const PriorityBadge(this.priority, {super.key});
  final TaskPriority priority;
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: priority.background, borderRadius: BorderRadius.circular(20)), child: Text(priority.label, style: TextStyle(color: priority.color, fontSize: 11, fontWeight: FontWeight.w600)));
}
class TaskTile extends StatelessWidget {
  const TaskTile({super.key, required this.task, this.onToggle, this.compact = false});
  final StudyTask task;
  final VoidCallback? onToggle;
  final bool compact;
  @override
  Widget build(BuildContext context) => CardSurface(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15), child: Row(children: [
    if (compact) Container(width: 4, height: 36, decoration: BoxDecoration(color: task.priority == TaskPriority.high ? const Color(0xFFF43F5E) : Palette.amber, borderRadius: BorderRadius.circular(4)))
    else SizedBox(width: 26, height: 30, child: Checkbox(key: Key('task_${task.id}'), value: task.done, onChanged: (_) => onToggle?.call(), activeColor: Palette.blue, side: const BorderSide(color: Color(0xFFCBD5E1), width: 2), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)))),
    const SizedBox(width: 14),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(task.title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: task.done ? const Color(0xFF9CA3AF) : null, decoration: task.done ? TextDecoration.lineThrough : null)),
      const SizedBox(height: 6), Text('${task.course} · ${compact ? '${dateLabel(task.due)}, ' : ''}${timeLabel(task.due)}', style: const TextStyle(fontSize: 12, color: Palette.muted)),
    ])), const SizedBox(width: 8), PriorityBadge(task.priority),
  ]));
}

class TasksPage extends StatefulWidget {
  const TasksPage({super.key, required this.tasks, required this.onToggle, required this.onAdd});
  final List<StudyTask> tasks;
  final ValueChanged<StudyTask> onToggle;
  final VoidCallback onAdd;
  @override
  State<TasksPage> createState() => _TasksPageState();
}
class _TasksPageState extends State<TasksPage> {
  String search = '';
  DateTime? selectedDate;
  @override
  Widget build(BuildContext context) {
    final filtered = widget.tasks.where((t) => '${t.title} ${t.course}'.toLowerCase().contains(search.toLowerCase()) && (selectedDate == null || sameDay(t.due, selectedDate!))).toList()..sort((a, b) => a.due.compareTo(b.due));
    final groups = <DateTime, List<StudyTask>>{};
    for (final task in filtered) { groups.putIfAbsent(dayOnly(task.due), () => []).add(task); }
    return Stack(children: [ListView(padding: const EdgeInsets.fromLTRB(20, 16, 20, 90), children: [
      Header('Tasks', icon: Icons.calendar_today_outlined, onTap: () async {
        final d = await showDatePicker(context: context, initialDate: selectedDate ?? DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2100));
        if (d != null && mounted) setState(() => selectedDate = d);
      }), const SizedBox(height: 20),
      TextField(key: const Key('task_search'), onChanged: (v) => setState(() => search = v), decoration: const InputDecoration(hintText: 'Search tasks, courses...', prefixIcon: Icon(Icons.search, color: Color(0xFF9CA3AF), size: 21))),
      if (selectedDate != null) Align(alignment: Alignment.centerLeft, child: InputChip(label: Text(dateLabel(selectedDate!)), onDeleted: () => setState(() => selectedDate = null))),
      const SizedBox(height: 24),
      if (groups.isEmpty) const CardSurface(child: Text('No matching tasks.')),
      ...groups.entries.expand((entry) => [
        Padding(padding: const EdgeInsets.only(bottom: 14), child: Row(children: [
          Expanded(child: Text('${dateLabel(entry.key)} · ${weekdays[entry.key.weekday - 1]}, ${entry.key.day} ${months[entry.key.month - 1]}'.toUpperCase(), style: const TextStyle(color: Palette.muted, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: .5))),
          Text('${entry.value.length} TASKS', style: const TextStyle(color: Palette.blue, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: .5)),
        ])),
        ...entry.value.map((t) => Padding(padding: const EdgeInsets.only(bottom: 12), child: TaskTile(task: t, onToggle: () => widget.onToggle(t)))),
        const SizedBox(height: 14),
      ]),
    ]), Positioned(right: 20, bottom: 16, child: FloatingActionButton(key: const Key('add_task'), onPressed: widget.onAdd, backgroundColor: Palette.blue, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), tooltip: 'Add task', child: const Icon(Icons.add, size: 30))),
    ]);
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key, required this.student, required this.onEdit, required this.notifications, required this.onNotifications, required this.dark, required this.onDark, required this.reminder, required this.onReminder, required this.onLogout});
  final StudentDetails student;
  final VoidCallback onEdit, onReminder, onLogout;
  final bool notifications, dark;
  final ValueChanged<bool> onNotifications, onDark;
  final TimeOfDay reminder;
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.fromLTRB(20, 16, 20, 12), children: [
    Header('Profile', icon: Icons.settings_outlined, onTap: onEdit), const SizedBox(height: 12),
    Center(child: Avatar(student.initials, size: 76)), const SizedBox(height: 14),
    Center(child: Text(student.fullName, style: const TextStyle(color: Palette.blue, fontSize: 21, fontWeight: FontWeight.w700))), const SizedBox(height: 6),
    Center(child: Text(student.studentId, style: const TextStyle(color: Palette.blue, fontSize: 14, fontWeight: FontWeight.w600))), const SizedBox(height: 20),
    const Section('Personal details'), const SizedBox(height: 10),
    CardSurface(padding: EdgeInsets.zero, child: Column(children: [
      ProfileRow(icon: Icons.badge_outlined, label: 'Student ID', value: student.studentId, onTap: onEdit),
      ProfileRow(icon: Icons.mail_outline, label: 'Email', value: student.email, onTap: onEdit),
      ProfileRow(icon: Icons.phone_outlined, label: 'Phone', value: student.phone, onTap: onEdit),
      ProfileRow(icon: Icons.book_outlined, label: 'Department', value: student.department, onTap: onEdit),
      ProfileRow(icon: Icons.calendar_today_outlined, label: 'Semester', value: student.semester, onTap: onEdit, last: true),
    ])), const SizedBox(height: 18), const Section('Preferences'), const SizedBox(height: 10),
    CardSurface(padding: EdgeInsets.zero, child: Column(children: [
      ProfileRow(icon: Icons.notifications_none, label: 'Notifications', trailing: SizedBox(height: 32, child: Switch(value: notifications, onChanged: onNotifications, activeTrackColor: Palette.blue))),
      ProfileRow(icon: Icons.access_time, label: 'Study reminder', value: reminder.format(context), onTap: onReminder, arrow: true),
      ProfileRow(icon: Icons.dark_mode_outlined, label: 'Dark mode', last: true, trailing: SizedBox(height: 32, child: Switch(value: dark, onChanged: onDark, activeTrackColor: Palette.blue))),
    ])), const SizedBox(height: 14),
    SizedBox(height: 44, child: OutlinedButton(onPressed: onLogout, style: OutlinedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.surface, side: const BorderSide(color: Palette.border), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), child: const Text('Log out', style: TextStyle(color: Color(0xFFBE123C), fontWeight: FontWeight.w600)))),
    TextButton(onPressed: onEdit, child: const Text('Edit Profile')),
  ]);
}
class ProfileRow extends StatelessWidget {
  const ProfileRow({super.key, required this.icon, required this.label, this.value = '', this.trailing, this.onTap, this.last = false, this.arrow = false});
  final IconData icon;
  final String label, value;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool last, arrow;
  @override
  Widget build(BuildContext context) => InkWell(onTap: onTap, child: Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
    decoration: BoxDecoration(border: last ? null : Border(bottom: BorderSide(color: Theme.of(context).dividerColor.withAlpha(20)))),
    child: Row(children: [Container(width: 32, height: 32, decoration: BoxDecoration(color: Palette.lightBlue, borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: Palette.blue, size: 18)), const SizedBox(width: 12),
      Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)), const SizedBox(width: 12),
      Expanded(child: trailing == null ? Text(value.isEmpty ? 'Tap to add' : value, textAlign: TextAlign.right, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: arrow || value.isEmpty ? Palette.muted : Palette.blue, fontSize: 12, fontWeight: FontWeight.w600)) : Align(alignment: Alignment.centerRight, child: trailing)),
      if (arrow) const Padding(padding: EdgeInsets.only(left: 10), child: Icon(Icons.chevron_right, size: 19, color: Palette.muted)),
    ]),
  ));
}

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key, required this.tasks});
  final List<StudyTask> tasks;
  @override
  State<ProgressPage> createState() => _ProgressPageState();
}
class _ProgressPageState extends State<ProgressPage> {
  int weekOffset = 0;
  @override
  Widget build(BuildContext context) {
    final monday = dayOnly(DateTime.now()).subtract(Duration(days: DateTime.now().weekday - 1)).add(Duration(days: weekOffset * 7));
    final sunday = monday.add(const Duration(days: 6));
    final current = weekOffset == 0;
    final done = widget.tasks.where((t) => t.done).length;
    return ListView(padding: const EdgeInsets.fromLTRB(20, 16, 20, 16), children: [
      Header('Progress', icon: Icons.calendar_today_outlined, onTap: () async {
        final d = await showDatePicker(context: context, initialDate: monday, firstDate: DateTime(2020), lastDate: DateTime(2100));
        if (d != null && mounted) {
          final start = dayOnly(DateTime.now()).subtract(Duration(days: DateTime.now().weekday - 1));
          setState(() => weekOffset = dayOnly(d).difference(start).inDays ~/ 7 - (dayOnly(d).isBefore(start) && dayOnly(d).difference(start).inDays % 7 != 0 ? 1 : 0));
        }
      }), const SizedBox(height: 12),
      CardSurface(padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1), child: Row(children: [
        IconButton(tooltip: 'Previous week', onPressed: () => setState(() => weekOffset--), icon: const Icon(Icons.chevron_left, size: 20, color: Palette.muted)),
        Expanded(child: Text('${current ? 'This week' : 'Week'} · ${monday.day} ${months[monday.month - 1]} – ${sunday.day} ${months[sunday.month - 1]}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
        IconButton(tooltip: 'Next week', onPressed: () => setState(() => weekOffset++), icon: const Icon(Icons.chevron_right, size: 20, color: Palette.muted)),
      ])), const SizedBox(height: 16),
      Row(children: [Expanded(child: StatCard(icon: Icons.access_time, value: current ? '9h 21m' : '0h 0m', label: 'Studied', color: Palette.blue, background: Palette.lightBlue)), const SizedBox(width: 10),
        Expanded(child: StatCard(icon: Icons.check_box_outlined, value: current ? '${13 + done}' : '0', label: 'Tasks done', color: const Color(0xFF047857), background: const Color(0xFFD1FAE5))), const SizedBox(width: 10),
        Expanded(child: StatCard(icon: Icons.local_fire_department_outlined, value: current ? '6 days' : '0 days', label: 'Streak', color: const Color(0xFFB45309), background: const Color(0xFFFEF3C7))),
      ]), const SizedBox(height: 16),
      CardSurface(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [const Expanded(child: Text('This week', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17))), Text(current ? '78%' : '0%', style: const TextStyle(color: Palette.blue, fontWeight: FontWeight.w700))]), const SizedBox(height: 8),
        Text(current ? '9h 21m of 12h goal' : '0h of 12h goal', style: const TextStyle(color: Palette.muted, fontSize: 13)), const SizedBox(height: 15),
        ProgressBar(value: current ? .78 : 0, color: Palette.blue), const SizedBox(height: 13),
        Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5), decoration: BoxDecoration(color: const Color(0xFFD1FAE5), borderRadius: BorderRadius.circular(20)), child: Text(current ? '↗ +18% vs last week' : 'No activity recorded', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF047857)))),
      ])), const SizedBox(height: 22),
      Section('Courses', action: 'Manage', onTap: () => showDialog<void>(context: context, builder: (_) => AlertDialog(title: const Text('My courses'), content: const Text('CSE 464 · Mobile Development\nCSE 303 · Databases\nMAT 212 · Linear Algebra\n\nThese are the sample courses from the assignment design.'), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Done'))]))), const SizedBox(height: 10),
      const CourseCard(code: '464', title: 'CSE 464 · Mobile Dev', subtitle: 'Next: Lab 6, today', value: .72, color: Palette.blue, background: Palette.lightBlue), const SizedBox(height: 12),
      const CourseCard(code: '303', title: 'CSE 303 · Databases', subtitle: 'Next: ER diagram, Sat', value: .58, color: Palette.amber, background: Color(0xFFFEF3C7)), const SizedBox(height: 12),
      const CourseCard(code: '212', title: 'MAT 212 · Linear Algebra', subtitle: 'Next: Problem set 4, Mon', value: .84, color: Palette.green, background: Color(0xFFD1FAE5)),
    ]);
  }
}
class ProgressBar extends StatelessWidget {
  const ProgressBar({super.key, required this.value, required this.color});
  final double value;
  final Color color;
  @override
  Widget build(BuildContext context) => ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(value: value, minHeight: 7, backgroundColor: const Color(0xFFE2E8F0), color: color));
}
class StatCard extends StatelessWidget {
  const StatCard({super.key, required this.icon, required this.value, required this.label, required this.color, required this.background});
  final IconData icon;
  final String value, label;
  final Color color, background;
  @override
  Widget build(BuildContext context) => CardSurface(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(11)), child: Icon(icon, color: color, size: 18)), const SizedBox(height: 11),
    FittedBox(fit: BoxFit.scaleDown, child: Text(value, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800))), const SizedBox(height: 5), Text(label, style: const TextStyle(color: Palette.muted, fontSize: 11)),
  ]));
}
class CourseCard extends StatelessWidget {
  const CourseCard({super.key, required this.code, required this.title, required this.subtitle, required this.value, required this.color, required this.background});
  final String code, title, subtitle;
  final double value;
  final Color color, background;
  @override
  Widget build(BuildContext context) => CardSurface(padding: const EdgeInsets.all(16), child: Row(children: [
    Container(width: 38, height: 42, alignment: Alignment.center, decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(12)), child: Text(code, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 13))), const SizedBox(width: 12),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Expanded(child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700))), const SizedBox(width: 4), Text('${(value * 100).round()}%', style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 13))]), const SizedBox(height: 3),
      Text(subtitle, style: const TextStyle(color: Palette.muted, fontSize: 12)), const SizedBox(height: 10), ProgressBar(value: value, color: color),
    ])),
  ]));
}

class AddTaskSheet extends StatefulWidget {
  const AddTaskSheet({super.key, required this.nextId});
  final int nextId;
  @override
  State<AddTaskSheet> createState() => _AddTaskSheetState();
}
class _AddTaskSheetState extends State<AddTaskSheet> {
  final form = GlobalKey<FormState>();
  final title = TextEditingController(), course = TextEditingController();
  TaskPriority priority = TaskPriority.medium;
  DateTime due = DateTime.now().add(const Duration(hours: 1));
  @override
  void dispose() { title.dispose(); course.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => Padding(padding: EdgeInsets.fromLTRB(20, 24, 20, MediaQuery.viewInsetsOf(context).bottom + 20), child: SingleChildScrollView(child: Form(key: form, child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text('Add task', style: Theme.of(context).textTheme.titleLarge), const SizedBox(height: 18),
    TextFormField(key: const Key('task_title_input'), controller: title, decoration: const InputDecoration(labelText: 'Task title'), validator: requiredField), const SizedBox(height: 12),
    TextFormField(key: const Key('task_course_input'), controller: course, decoration: const InputDecoration(labelText: 'Course'), validator: requiredField), const SizedBox(height: 12),
    DropdownButtonFormField<TaskPriority>(initialValue: priority, decoration: const InputDecoration(labelText: 'Priority'), items: TaskPriority.values.map((p) => DropdownMenuItem(value: p, child: Text(p.label))).toList(), onChanged: (p) => setState(() => priority = p ?? priority)), const SizedBox(height: 10),
    TextButton.icon(icon: const Icon(Icons.calendar_today_outlined, size: 18), label: Text('${dateLabel(due)}, ${timeLabel(due)}'), onPressed: () async {
      final date = await showDatePicker(context: context, initialDate: due, firstDate: DateTime(2020), lastDate: DateTime(2100));
      if (date == null || !context.mounted) return;
      final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(due));
      if (time != null && mounted) setState(() => due = DateTime(date.year, date.month, date.day, time.hour, time.minute));
    }), const SizedBox(height: 12),
    SizedBox(width: double.infinity, height: 48, child: FilledButton(key: const Key('save_task_button'), onPressed: () {
      if (form.currentState!.validate()) Navigator.pop(context, StudyTask(id: widget.nextId, title: title.text.trim(), course: course.text.trim(), due: due, priority: priority));
    }, child: const Text('Add Task'))),
  ]))));
}
String? requiredField(String? v) => v == null || v.trim().isEmpty ? 'Please enter a value' : null;

class EditProfileSheet extends StatefulWidget {
  const EditProfileSheet({super.key, required this.initial});
  final StudentDetails initial;
  @override
  State<EditProfileSheet> createState() => _EditProfileSheetState();
}
class _EditProfileSheetState extends State<EditProfileSheet> {
  final form = GlobalKey<FormState>();
  late final List<TextEditingController> fields;
  static const labels = ['Student Name', 'Student ID', 'IUB email', 'Phone', 'Department', 'Semester'];
  @override
  void initState() {
    super.initState(); final s = widget.initial;
    fields = [s.fullName, s.studentId, s.email, s.phone, s.department, s.semester].map((v) => TextEditingController(text: v)).toList();
  }
  @override
  void dispose() { for (final f in fields) { f.dispose(); } super.dispose(); }
  @override
  Widget build(BuildContext context) => Padding(padding: EdgeInsets.fromLTRB(20, 24, 20, MediaQuery.viewInsetsOf(context).bottom + 20), child: SingleChildScrollView(child: Form(key: form, child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text('Edit Profile', style: Theme.of(context).textTheme.titleLarge), const SizedBox(height: 8),
    const Text('Changes are kept for this app session. Set code defaults before submitting.', style: TextStyle(color: Palette.muted, fontSize: 12)), const SizedBox(height: 16),
    ...List.generate(6, (i) => Padding(padding: const EdgeInsets.only(bottom: 12), child: TextFormField(controller: fields[i], key: Key('profile_$i'), decoration: InputDecoration(labelText: labels[i]), keyboardType: i == 2 ? TextInputType.emailAddress : i == 3 ? TextInputType.phone : TextInputType.text, validator: (v) {
      if (i <= 2 || (v != null && v.isNotEmpty)) {
        if (requiredField(v) != null) return requiredField(v);
        if (i == 2 && !RegExp(r'^[^\s@]+@iub\.edu\.bd$').hasMatch(v!.trim())) return 'Enter your IUB email';
      }
      return null;
    }))),
    SizedBox(width: double.infinity, height: 48, child: FilledButton(key: const Key('save_profile'), onPressed: () {
      if (!form.currentState!.validate()) return;
      final v = fields.map((f) => f.text.trim()).toList();
      Navigator.pop(context, StudentDetails(fullName: v[0], studentId: v[1], email: v[2], phone: v[3], department: v[4], semester: v[5]));
    }, child: const Text('Save profile'))),
  ]))));
}
