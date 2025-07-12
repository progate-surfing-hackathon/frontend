import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class AmedasService {
  // 最寄りアメダスAPI
  final String nearestAmedasUrl = "https://api.cultivationdata.net/nearest_amds";

  // メイン処理
  Future<double> fetchNearestAmedasData() async {
    print("[Amedas] 現在地取得開始");
    final position = await _getCurrentLocation();
    if (position == null) {
      throw "[Amedas] 位置情報が取得できませんでした。";
    }
    print("[Amedas] 現在地取得成功: lat=${position.latitude}, lon=${position.longitude}");

    print("[Amedas] 最寄り観測所検索開始");
    final stationNo = await _getNearestStationNo(position.latitude, position.longitude);
    if (stationNo == null) {
      throw "[Amedas] 最寄りの観測所が見つかりませんでした。";
    }
    print("[Amedas] 最寄り観測所番号: $stationNo");

    print("[Amedas] 最新アメダスデータ取得開始");
    final weather = await getLatestAmedasData(stationNo);
    if (weather == null) {
      throw "[Amedas] アメダスデータが取得できませんでした。";
    }

    print("[Amedas] 🌡️ 気温: ${weather['temp']} ℃");
    print("[Amedas] 💧 湿度: ${weather['humidity']} %");
    return weather["temp"].toDouble();
  }

  // 現在地取得
  Future<Position?> _getCurrentLocation() async {
    print("[Amedas] 位置情報サービス有効確認");
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    LocationPermission permission = await Geolocator.checkPermission();

    if (!serviceEnabled) {
      print("[Amedas] 位置情報サービスが無効です");
      return null;
    }
    if (permission == LocationPermission.deniedForever) {
      print("[Amedas] 位置情報の権限が永久に拒否されています");
      return null;
    }
    if (permission == LocationPermission.denied) {
      print("[Amedas] 位置情報の権限が未許可。リクエストします");
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.always && permission != LocationPermission.whileInUse) {
        print("[Amedas] 位置情報の権限が許可されませんでした");
        return null;
      }
    }

    print("[Amedas] 位置情報の取得リクエスト");
    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  // 最寄り観測所番号を返す
  Future<String?> _getNearestStationNo(double lat, double lon) async {
    final url = "${nearestAmedasUrl}?lat=$lat&lon=$lon";
    print("[Amedas] 最寄り観測所APIリクエスト: $url");
    final res = await http.get(Uri.parse(url));
    if (res.statusCode != 200) {
      print("[Amedas] 最寄り観測所API取得失敗: status=${res.statusCode}");
      return null;
    }
    final jsonData = json.decode(utf8.decode(res.bodyBytes));
    if (jsonData == null || jsonData['0'] == null || jsonData['0']['obs_number'] == null) {
      print("[Amedas] 最寄り観測所データが空");
      return null;
    }
    final stationNo = jsonData['0']['obs_number'].toString();
    print("[Amedas] 最寄り観測所番号取得: $stationNo");
    return stationNo;
  }

  // 最新アメダスデータ取得
  Future<Map<String, dynamic>?> getLatestAmedasData(String stationNo) async {
    final url = "https://api.cultivationdata.net/amds?no=$stationNo";
    print("[Amedas] 最新アメダスデータAPIリクエスト: $url");
    final res = await http.get(Uri.parse(url));
    if (res.statusCode != 200) {
      print("[Amedas] 最新アメダスデータ取得失敗: status=${res.statusCode}");
      return null;
    }
    final jsonData = json.decode(utf8.decode(res.bodyBytes));
    if (jsonData == null || jsonData['temp'] == null || jsonData['humidity'] == null) {
      print("[Amedas] データが空");
      return null;
    }
    print("[Amedas] データ取得成功: temp=${jsonData['temp']}, humidity=${jsonData['humidity']}");
    return {
      'temp': jsonData['temp'][0],
      'humidity': jsonData['humidity'][0],
    };
  }

  // ...不要な旧関数は削除...
  // 以降、必要に応じて拡張可
}
