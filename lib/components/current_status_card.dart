import 'package:flutter/material.dart';
import '../utils/user_context.dart';

class CurrentStatusCard extends StatefulWidget {
  const CurrentStatusCard({
    super.key,
  });

  @override
  State<CurrentStatusCard> createState() => _CurrentStatusCardState();
}

class _CurrentStatusCardState extends State<CurrentStatusCard> {
  late final UserContext _instance;

  @override
  void initState() {
    super.initState();
    _instance = UserContext();
    // UserContextの変更を監視
    _instance.addListener(_onUserContextChanged);
  }

  @override
  void dispose() {
    _instance.removeListener(_onUserContextChanged);
    super.dispose();
  }

  void _onUserContextChanged() {
    setState(() {
      // UserContextが変更されたらUIを更新
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.thermostat,
                  size: 32,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  '現在の状況',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // 気温
            Row(
              children: [
                Icon(Icons.wb_sunny, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  '気温: ${_instance.temp > 0 ? '${_instance.temp.toStringAsFixed(1)}°C' : '取得中...'}',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _instance.temp > 0 ? Colors.orange : Colors.grey,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // 歩数
            Row(
              children: [
                Icon(Icons.directions_walk, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  '今日の歩数: ${_instance.steps > 0 ? '${_instance.steps} 歩' : '取得中...'}',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _instance.steps > 0 ? Colors.green : Colors.grey,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // 使用金額
            Row(
              children: [
                Icon(Icons.currency_yen, color: Colors.amber),
                const SizedBox(width: 8),
                Text(
                  '今日使った金額: ¥${_instance.paidMoney}',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 