import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(ToDoApp());

class ToDoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-Do List',
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.yellow,
        scaffoldBackgroundColor: Colors.grey[100],
        textTheme: TextTheme(
          bodyLarge: TextStyle(fontSize: 16, color: Colors.black87),
        ),
        useMaterial3: true,
      ),
      home: ToDoHomePage(),
    );
  }
}

class Task {
  String title;
  bool isDone;
  String level;
  String leetcodeNo;
  String link;

  Task(this.title, {
    this.isDone = false,
    this.level = 'easy',
    this.leetcodeNo = '-',
    this.link = '',
  });
}

class Topic {
  String title;
  List<Task> tasks = [];
  bool isExpanded;

  Topic(this.title, {this.isExpanded = true});
}

class ToDoHomePage extends StatefulWidget {
  @override
  _ToDoHomePageState createState() => _ToDoHomePageState();
}

class _ToDoHomePageState extends State<ToDoHomePage> {
  List<Topic> topics = [];
  String filter = 'All';
  String searchQuery = '';

  void _addTopic() async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add New Topic'),
        content: TextField(controller: controller, decoration: InputDecoration(hintText: 'Topic name')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                setState(() => topics.add(Topic(controller.text.trim())));
              }
              Navigator.pop(context);
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  void _editOrDeleteTopic(int index) async {
    final topic = topics[index];
    final controller = TextEditingController(text: topic.title);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Topic'),
        content: TextField(controller: controller),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => topics.removeAt(index));
              Navigator.pop(context);
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          TextButton(
            onPressed: () {
              setState(() => topic.title = controller.text.trim());
              Navigator.pop(context);
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void _addTask(Topic topic) async {
    final taskTitleController = TextEditingController();
    String selectedLevel = 'easy';
    final leetcodeController = TextEditingController();
    final linkController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Task under ${topic.title}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: taskTitleController, decoration: InputDecoration(hintText: 'Question title')),
            StatefulBuilder(
              builder: (context, setState) {
                return DropdownButton<String>(
                  value: selectedLevel,
                  items: ['easy', 'medium', 'hard'].map((level) => DropdownMenuItem(value: level, child: Text(level))).toList(),
                  onChanged: (value) => setState(() => selectedLevel = value!),
                );
              },
            ),

            TextField(controller: leetcodeController, decoration: InputDecoration(hintText: 'LeetCode Number')),
            TextField(controller: linkController, decoration: InputDecoration(hintText: 'LeetCode Link')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          TextButton(
            onPressed: () {
              setState(() {
                topic.tasks.add(Task(
                  taskTitleController.text.trim(),
                  level: selectedLevel,
                  leetcodeNo: leetcodeController.text.trim().isEmpty ? '-' : leetcodeController.text.trim(),
                  link: linkController.text.trim(),
                ));
              });
              Navigator.pop(context);
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  void _editOrDeleteTask(Topic topic, int index) async {
    final task = topic.tasks[index];
    final taskTitleController = TextEditingController(text: task.title);
    final leetcodeController = TextEditingController(text: task.leetcodeNo);
    final linkController = TextEditingController(text: task.link);
    String selectedLevel = task.level;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Task'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: taskTitleController),
            StatefulBuilder(
              builder: (context, setState) {
                return DropdownButton<String>(
                  value: selectedLevel,
                  items: ['easy', 'medium', 'hard'].map((level) => DropdownMenuItem(value: level, child: Text(level))).toList(),
                  onChanged: (value) => setState(() => selectedLevel = value!),
                );
              },
            ),
            Column(
              children: [
                TextField(
                  controller: leetcodeController..text = (leetcodeController.text == '-' ? '' : leetcodeController.text),
                  decoration: InputDecoration(
                    hintText: 'LeetCode Number',
                  ),
                ),
                TextField(
                  controller: linkController..text = (linkController.text.isEmpty ? '' : linkController.text),
                  decoration: InputDecoration(
                    hintText: 'LeetCode Link',
                  ),
                ),
              ],
            )

          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => topic.tasks.removeAt(index));
              Navigator.pop(context);
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          TextButton(
            onPressed: () {
              setState(() {
                task.title = taskTitleController.text.trim();
                task.level = selectedLevel;
                task.leetcodeNo = leetcodeController.text.trim().isEmpty ? '-' : leetcodeController.text.trim();
                task.link = linkController.text.trim();
              });
              Navigator.pop(context);
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not open the link')));
    }
  }

  Widget _buildHeaderRow() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.yellow.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.yellow.shade600),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: const [
          Expanded(flex: 4, child: Text('Topic', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
          Expanded(flex: 1, child: Text('Link', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16), textAlign: TextAlign.center)),
          Expanded(flex: 1, child: Text('Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16), textAlign: TextAlign.center)),
          Expanded(flex: 2, child: Text('Level', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16), textAlign: TextAlign.center)),
          Expanded(flex: 2, child: Text('Leetcode', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16), textAlign: TextAlign.center)),
          SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildTaskRow(Task task, int index, VoidCallback onEdit) {
    if (filter != 'All' && task.level.toLowerCase() != filter.toLowerCase()) return SizedBox.shrink();
    if (searchQuery.isNotEmpty && !task.title.toLowerCase().contains(searchQuery.toLowerCase())) return SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: task.isDone ? Colors.green.shade100 : Colors.yellow.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.yellow.shade200),
        boxShadow: [BoxShadow(color: Colors.yellow.shade100, blurRadius: 4, offset: Offset(0, 2))],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(flex: 4, child: Text('${index + 1}. ${task.title}', style: TextStyle(fontWeight: FontWeight.w500))),
          Expanded(flex: 1, child: Center(
            child: ElevatedButton(
              onPressed: task.link.isNotEmpty ? () => _launchURL(task.link) : null,
              child: Text('Link'),
              style: ElevatedButton.styleFrom(
                backgroundColor: task.link.isNotEmpty ? Colors.blue : Colors.grey,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                textStyle: TextStyle(fontSize: 12),
              ),
            ),
          )),
          Expanded(flex: 1, child: Center(child: Checkbox(value: task.isDone, onChanged: (val) => setState(() => task.isDone = val!)))),
          Expanded(flex: 2, child: Text(task.level, textAlign: TextAlign.center)),
          Expanded(flex: 2, child: Text(task.leetcodeNo, textAlign: TextAlign.center)),
          IconButton(onPressed: onEdit, icon: Icon(Icons.edit, size: 20, color: Colors.yellow.shade800))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('To-Do List'),
        centerTitle: true,
        backgroundColor: Colors.yellow.shade700,
        actions: [
          Container(
            width: 200,
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search...',
                hintStyle: TextStyle(color: Colors.white70),
                border: InputBorder.none,
              ),
              style: TextStyle(color: Colors.white),
              onChanged: (value) => setState(() => searchQuery = value),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: DropdownButton<String>(
              value: filter,
              underline: SizedBox(),
              items: ['All', 'Easy', 'Medium', 'Hard'].map((level) => DropdownMenuItem(value: level, child: Text(level))).toList(),
              onChanged: (val) => setState(() => filter = val!),
              dropdownColor: Colors.yellow.shade100,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildHeaderRow(),
            for (var topic in topics) ...[
              GestureDetector(
                onTap: () => setState(() => topic.isExpanded = !topic.isExpanded),
                child: Row(
                  children: [
                    Expanded(
                      child: Text('${topics.indexOf(topic) + 1}. ${topic.title}',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.yellow.shade900)),
                    ),
                    IconButton(
                      icon: Icon(Icons.add_circle_outline, color: Colors.yellow.shade800),
                      onPressed: () => _addTask(topic),
                    ),
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.yellow.shade800),
                      onPressed: () => _editOrDeleteTopic(topics.indexOf(topic)),
                    ),
                  ],
                ),
              ),
              if (topic.isExpanded)
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Column(
                    children: List.generate(
                      topic.tasks.length,
                          (i) => _buildTaskRow(topic.tasks[i], i, () => _editOrDeleteTask(topic, i)),
                    ),
                  ),
                ),
              SizedBox(height: 20),
            ],
            Center(
              child: ElevatedButton.icon(
                icon: Icon(Icons.topic),
                label: Text('Add New Topic'),
                onPressed: _addTopic,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  backgroundColor: Colors.yellow.shade700,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}