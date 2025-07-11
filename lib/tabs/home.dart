import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../healthkit/healthkit.dart';
import '../temperature/amedas.dart';


class Home extends StatefulWidget {
  const Home({super.key, required this.title});

  final String title;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _counter = 0;
  final amedas = AmedasService();
  // 初期化の時にUsersDefaultから所得して値を設定しないとウィジェットが更新されない
  @override
  void initState() {
    print('init');
    super.initState();
    _loadCounterFromIOS();
    amedas.fetchNearestAmedasData();
  }

  Future<void> _loadCounterFromIOS() async {
    try {
      final value = await platform.invokeMethod('getCounter');
      setState(() {
        _counter = value as int? ?? 0;
      });
    } catch (e) {
      //print(e);
    }
  }

  int? _steps;

  static const platform = MethodChannel('com.example.progateSurfingHackathon/counter');
  
  Future<void> _saveCounterToIOS(int value) async {
    try{
      print(value);
      await platform.invokeMethod('saveCounter', {'value': value});
    } catch (e){
      // print(e);
    }
  }

  Future<void> saveTodayStepsToIOS() async {
    // 歩数を取得
    final steps = await fetchStepData();
    setState(() {
      _steps = steps;
    });
    print('steps: $steps');
    if (steps != null) {
      await _saveCounterToIOS(steps);
    }
  }

  Future<void> _incrementCounter() async {
    setState(() {
      _counter++;
    });
    await _saveCounterToIOS(_counter);
  }

  @override
  Widget build(BuildContext context) {
    // This method retruns every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Text(
              _steps != null ? 'Steps today: $_steps' : 'Steps not loaded',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
