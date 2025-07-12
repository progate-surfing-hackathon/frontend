import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  Future<AuthUser?> _getCurrentUser() async {
    try {
      return await Amplify.Auth.getCurrentUser();
    } catch (e) {
      safePrint('Error getting current user: $e');
      return null;
    }
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      await Amplify.Auth.signOut();
      if (context.mounted) {
        // サインアウト後はAuthGateに戻るため、Navigator.popは不要
        // AuthGateが自動的にサインイン画面を表示する
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('サインアウトエラー: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('アカウント'),
        backgroundColor: theme.colorScheme.inversePrimary,
      ),
      body: FutureBuilder<AuthUser?>(
        future: _getCurrentUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('ユーザー情報を読み込み中...'),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'エラーが発生しました',
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      // FutureBuilderを再実行するためにウィジェットを再構築
                      (context as Element).markNeedsBuild();
                    },
                    child: const Text('再試行'),
                  ),
                ],
              ),
            );
          }

          final user = snapshot.data;
          if (user == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person_off,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'ユーザー情報が見つかりません',
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'サインインし直してください',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ユーザー情報カード
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundColor: theme.colorScheme.primary,
                              child: Icon(
                                Icons.person,
                                size: 40,
                                color: theme.colorScheme.onPrimary,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'ユーザー情報',
                                    style: theme.textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'ログイン中',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: Colors.green,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _buildInfoRow('ユーザーID', user.userId),
                        const SizedBox(height: 8),
                        _buildInfoRow('ユーザー名', user.username),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // アカウント設定セクション
                Text(
                  'アカウント設定',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(
                          Icons.settings,
                          color: theme.colorScheme.primary,
                        ),
                        title: const Text('設定'),
                        subtitle: const Text('アプリの設定を変更'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          // 設定画面への遷移（実装予定）
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('設定画面は準備中です')),
                          );
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: Icon(
                          Icons.help_outline,
                          color: theme.colorScheme.primary,
                        ),
                        title: const Text('ヘルプ'),
                        subtitle: const Text('使い方やサポート'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          // ヘルプ画面への遷移（実装予定）
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('ヘルプ画面は準備中です')),
                          );
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: Icon(
                          Icons.info_outline,
                          color: theme.colorScheme.primary,
                        ),
                        title: const Text('アプリについて'),
                        subtitle: const Text('バージョン情報など'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          // アプリ情報画面への遷移（実装予定）
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('アプリ情報画面は準備中です')),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // サインアウトボタン
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _showSignOutDialog(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.logout),
                    label: const Text(
                      'サインアウト',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('サインアウト'),
          content: const Text('本当にサインアウトしますか？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _signOut(context);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('サインアウト'),
            ),
          ],
        );
      },
    );
  }
}