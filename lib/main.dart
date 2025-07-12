import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart' as AmplifyAuthCognito;
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:progate_surfing_hackathon/utils/user_context.dart';
import 'amplifyconfiguration.dart';
import 'tabs/home.dart';
import 'tabs/account.dart';
import '../healthkit/healthkit.dart';
import '../temperature/amedas.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _configureAmplify();
  await _requestLocationPermission();
  runApp(const MyApp());
}

Future<void> _configureAmplify() async {
  try {
    final auth = AmplifyAuthCognito.AmplifyAuthCognito();
    await Amplify.addPlugin(auth);
    await Amplify.configure(amplifyconfig);
  } catch (e) {
    safePrint('Amplify configure error: $e');
  }
}

Future<void> _requestLocationPermission() async {
  try {
    // 位置情報の許可状態を確認
    PermissionStatus status = await Permission.location.status;
    
    if (status.isDenied) {
      // 許可されていない場合は許可を求める
      status = await Permission.location.request();
      
      if (status.isPermanentlyDenied) {
        // 永続的に拒否された場合は設定画面を開くことを提案
        safePrint('Location permission is permanently denied');
      } else if (status.isDenied) {
        // 拒否された場合
        safePrint('Location permission is denied');
      } else if (status.isGranted) {
        // 許可された場合
        safePrint('Location permission is granted');
      }
    } else if (status.isGranted) {
      // 既に許可されている場合
      safePrint('Location permission is already granted');
    } else if (status.isRestricted) {
      // 制限されている場合
      safePrint('Location permission is restricted');
    }
  } catch (e) {
    safePrint('Error requesting location permission: $e');
  }
}

// 位置情報の許可状態を確認するユーティリティ関数
Future<bool> _isLocationPermissionGranted() async {
  try {
    PermissionStatus status = await Permission.location.status;
    return status.isGranted;
  } catch (e) {
    safePrint('Error checking location permission status: $e');
    return false;
  }
}

// 位置情報の許可を求めるユーティリティ関数
Future<bool> _requestLocationPermissionIfNeeded() async {
  try {
    PermissionStatus status = await Permission.location.status;
    
    if (status.isDenied) {
      status = await Permission.location.request();
      return status.isGranted;
    }
    
    return status.isGranted;
  } catch (e) {
    safePrint('Error requesting location permission: $e');
    return false;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});
  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _isSignedIn = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _checkAuth();
    _checkLocationPermission();
  }

  Future<void> _checkAuth() async {
    try {
      final session = await Amplify.Auth.fetchAuthSession();
      setState(() {
        _isSignedIn = session.isSignedIn;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _isSignedIn = false;
        _loading = false;
      });
    }
  }

  Future<void> _checkLocationPermission() async {
    try {
      PermissionStatus status = await Permission.location.status;
      
      if (status.isPermanentlyDenied && mounted) {
        // 永続的に拒否された場合は設定画面を開くダイアログを表示
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showLocationPermissionDialog();
        });
      }
    } catch (e) {
      safePrint('Error checking location permission: $e');
    }
  }

  void _showLocationPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('位置情報の許可が必要です'),
          content: const Text(
            'このアプリは最寄りの気象観測所の天気情報を表示するために位置情報を使用します。\n\n'
            '設定画面から位置情報の許可を有効にしてください。',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('後で'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              child: const Text('設定を開く'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_isSignedIn) {
      return const MainScreen(title: 'Flutter Demo Home Page');
    } else {
      return SignInPage(onSignedIn: _checkAuth);
    }
  }
}

class SignInPage extends StatefulWidget {
  final VoidCallback onSignedIn;
  const SignInPage({super.key, required this.onSignedIn});
  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _error;
  bool _loading = false;
  bool _obscurePassword = true;

  Future<void> _signIn() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await Amplify.Auth.signIn(
        username: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (res.isSignedIn) {
        widget.onSignedIn();
      } else {
        setState(() {
          _error = 'サインインに失敗しました';
        });
      }
    } on AuthException catch (e) {
      if (e.runtimeType.toString() == 'UserNotFoundException' ||
          e.message.contains('User does not exist')) {
        // ユーザーが存在しない場合はサインアップ
        try {
          await Amplify.Auth.signUp(
            username: _emailController.text.trim(),
            password: _passwordController.text.trim(),
            options: SignUpOptions(
              userAttributes: {
                AuthUserAttributeKey.email: _emailController.text.trim(),
              },
            ),
          );
          // サインアップ後に認証コード入力画面へ遷移
          if (mounted) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ConfirmCodePage(
                  email: _emailController.text.trim(),
                  onConfirmed: _signIn,
                ),
              ),
            );
          }
        } on AuthException catch (e2) {
          setState(() {
            _error = 'サインアップに失敗しました: ${e2.message}';
          });
        }
      } else if (e.runtimeType.toString() == 'UserNotConfirmedException' ||
          e.message.contains('User is not confirmed')) {
        // ユーザーが未確認の場合は認証コード入力画面へ遷移
        if (mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ConfirmCodePage(
                email: _emailController.text.trim(),
                onConfirmed: _signIn,
              ),
            ),
          );
        }
      } else {
        setState(() {
          _error = e.message;
        });
      }
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('サインイン'),
        backgroundColor: theme.colorScheme.primary,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.surfing,
                    size: 64,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'メールアドレス',
                      prefixIcon: const Icon(Icons.email),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'パスワード',
                      prefixIcon: const Icon(Icons.lock),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    obscureText: _obscurePassword,
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(_error!, style: const TextStyle(color: Colors.red)),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 48,
                    child: _loading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: theme.colorScheme.onPrimary,
                              textStyle: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: _signIn,
                            icon: const Icon(Icons.login),
                            label: const Text('サインイン / 新規登録'),
                          ),
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

class MainScreen extends StatefulWidget {
  const MainScreen({super.key, required this.title});
  final String title;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final instance = UserContext();
  int _counter = 0;
  // 初期化の時にUsersDefaultから所得して値を設定しないとウィジェットが更新されない

  int _selectedIndex = 0;

  late final List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _loadCounterFromIOS();
    _loadInitialData();
    _widgetOptions = <Widget>[
      Home(title: widget.title),
      const AccountPage(),
    ];
  }

  Future<void> _loadInitialData() async {
    // 初期データの読み込み
    await saveAmedas();
    await saveTodayStepsToIOS();
  }

  static const platform = MethodChannel('com.example.progateSurfingHackathon/counter');

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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

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
    if (steps != null) {
      setState(() {
        instance.steps = steps;
      });
      print('steps: $steps');
      await _saveCounterToIOS(steps);
    }
  }

  Future<void> _incrementCounter() async {
    setState(() {
      _counter++;
    });
    await _saveCounterToIOS(_counter);
  }
  Future<void> saveAmedas() async {
    final amedas = AmedasService();
    try {
      // fetchNearestAmedasDataはdoubleを返すため、直接代入可能
      final res = await amedas.fetchNearestAmedasData();
      instance.temp = res;
      // 気象データはAmedasService内でログ出力される
    } catch (e) {
      safePrint('Error fetching weather data: $e');
    }
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Account',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        onTap: _onItemTapped,
      ),
    );
  }
}

// 認証コード入力画面
class ConfirmCodePage extends StatefulWidget {
  final String email;
  final VoidCallback onConfirmed;
  const ConfirmCodePage({
    super.key,
    required this.email,
    required this.onConfirmed,
  });

  @override
  State<ConfirmCodePage> createState() => _ConfirmCodePageState();
}

class _ConfirmCodePageState extends State<ConfirmCodePage> {
  final _codeController = TextEditingController();
  String? _error;
  bool _loading = false;
  bool _resent = false;

  Future<void> _confirm() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await Amplify.Auth.confirmSignUp(
        username: widget.email,
        confirmationCode: _codeController.text.trim(),
      );
      if (res.isSignUpComplete) {
        widget.onConfirmed();
        Navigator.of(context).pop();
      } else {
        setState(() {
          _error = '認証に失敗しました';
        });
      }
    } on AuthException catch (e) {
      setState(() {
        _error = e.message;
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _resend() async {
    setState(() {
      _loading = true;
      _error = null;
      _resent = false;
    });
    try {
      await Amplify.Auth.resendSignUpCode(username: widget.email);
      setState(() {
        _resent = true;
      });
    } on AuthException catch (e) {
      setState(() {
        _error = e.message;
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('認証コードの確認')),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.verified, size: 64, color: Colors.green),
                  const SizedBox(height: 16),
                  Text(
                    '認証コードをメールに送信しました',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _codeController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: '認証コード',
                      prefixIcon: const Icon(Icons.numbers),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(_error!, style: const TextStyle(color: Colors.red)),
                  ],
                  if (_resent) ...[
                    const SizedBox(height: 12),
                    const Text(
                      '認証コードを再送信しました',
                      style: TextStyle(color: Colors.green),
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 48,
                    child: _loading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: theme.colorScheme.onPrimary,
                              textStyle: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: _confirm,
                            icon: const Icon(Icons.verified_user),
                            label: const Text('認証'),
                          ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _loading ? null : _resend,
                    child: const Text('認証コードを再送信'),
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
