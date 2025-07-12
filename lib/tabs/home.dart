import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../healthkit/healthkit.dart';


class Home extends StatefulWidget {
  const Home({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // 初期化の時にUsersDefaultから所得して値を設定しないとウィジェットが更新されない
  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: RefreshIndicator(
        onRefresh: saveTodayStepsToIOS,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height - 
                   AppBar().preferredSize.height - 
                   MediaQuery.of(context).padding.top,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text('You have pushed the button this many times:'),
                  const SizedBox(height: 16),
                  Text(
                    _steps != null ? 'Steps today: $_steps' : 'Steps not loaded',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
