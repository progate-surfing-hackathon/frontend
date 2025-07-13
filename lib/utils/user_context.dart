import 'package:flutter/material.dart';

class UserContext extends ChangeNotifier {
  // プライベートコンストラクタ
  UserContext._privateConstructor();

  // シングルトンインスタンス
  static final UserContext _instance = UserContext._privateConstructor();

  // インスタンスを取得するためのファクトリコンストラクタ
  factory UserContext() {
    return _instance;
  }

  double temp = 0.0;
  int steps = 0;
  int paidMoney = 0;
}