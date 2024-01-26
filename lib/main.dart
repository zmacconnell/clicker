import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: "Clicker App",
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
        ),
        home: const MyHomePage(title: "Clicker App Home"),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = 1;
  var logs = <LogEntry>[]; 

  void getNext() {
    current = 1;
    notifyListeners();
  }

  void toggleFavorite() {
    notifyListeners();
  }

  void addToLogs(int counterValue) {
    logs.add(LogEntry(counterValue: counterValue, timestamp: DateTime.now()));
    notifyListeners();
  }
}

class LogEntry {
  final int counterValue;
  final DateTime timestamp;

  LogEntry({required this.counterValue, required this.timestamp});
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = ClickerPage();
        break; 
      case 1:
        page = LogPage();
        break; 
      default:
        throw UnimplementedError("no widget for $selectedIndex");
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          body: Row(
            children: [
              SafeArea(
                child: NavigationRail(
                  extended: constraints.maxWidth >= 600,
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.home),
                      label: Text("Home"),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.assignment),
                      label: Text("Log"),
                    ),
                  ],
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (value) {
                    setState(() {
                      selectedIndex = value;
                    });
                  },
                ),
              ),
              Expanded(
                child: Container(
                  color: Theme.of(context).primaryColor, 
                  child: page,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ClickerPage extends StatefulWidget {
  const ClickerPage({Key? key}) : super(key: key);

  @override
  State<ClickerPage> createState() => _ClickerPageState();
}

class _ClickerPageState extends State<ClickerPage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void _resetCounter() {
    setState(() {
      _counter = 0;
    });
  }

  void _addToLogs(MyAppState appState) {
  appState.addToLogs(_counter); 
  setState(() {
    _counter = 0; 
  });
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("Added to logs")),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text("Clicker"),
        actions: [
          IconButton(
            onPressed: () => _addToLogs(context.read<MyAppState>()),
            icon: const Icon(Icons.assignment),
            tooltip: "Add to logs",
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: _incrementCounter,
              icon: const Icon(Icons.add),
              label: Text(
                "$_counter",
                style: const TextStyle(fontSize: 24), 
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(20), 
                minimumSize: const Size(200, 50), 
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _resetCounter,
              icon: const Icon(Icons.stop),
              label: const Text("Reset"),
            )
          ],
        ),
      ),
    );
  }
}

class LogPage extends StatelessWidget {
  const LogPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var logs = appState.logs; 

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text("Log"),
      ),
      body: logs.isEmpty
          ? const Center(child: Text("No Logs Yet"))
          : ListView.builder(
              itemCount: logs.length,
              itemBuilder: (context, index) {
                var logEntry = logs[index];
                return ListTile(
                  title: Text("Clicker Value: ${logEntry.counterValue}"),
                  subtitle: Text("Timestamp: ${logEntry.timestamp}"),
                );
              },
            ),
    );
  }
}
