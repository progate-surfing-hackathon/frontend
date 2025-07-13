import 'package:amplify_flutter/amplify_flutter.dart';

class ActivityService {
  /// Activityデータを取得する関数
  static Future<List<Map<String, dynamic>>?> getActivities() async {
    try {
      const graphQLDocument = '''
        query GetActivities {
          getActivities {
            id
            author
            temp
            steps
            paid_monney
            created_at
          }
        }
      ''';
      
      final response = await Amplify.API.query(
        request: GraphQLRequest(document: graphQLDocument)
      ).response;
      
      print('Activity GraphQL response: $response');
      
      // レスポンスからデータを抽出
      if (response.data != null) {
        final activities = response.data!['getActivities'] as List<dynamic>?;
        if (activities != null) {
          return activities.map((activity) {
            final Map<String, dynamic> activityMap = Map<String, dynamic>.from(activity);
            // 数値フィールドを適切な型に変換
            if (activityMap['temp'] != null) {
              activityMap['temp'] = int.tryParse(activityMap['temp'].toString()) ?? 0;
            }
            if (activityMap['steps'] != null) {
              activityMap['steps'] = int.tryParse(activityMap['steps'].toString()) ?? 0;
            }
            if (activityMap['paid_monney'] != null) {
              activityMap['paid_monney'] = int.tryParse(activityMap['paid_monney'].toString()) ?? 0;
            }
            return activityMap;
          }).toList();
        }
      }
      
      return [];
    } catch (e) {
      print('Error fetching activities: $e');
      return null;
    }
  }

  /// 特定のauthorのActivityを直接取得する関数（新しいGraphQLクエリを使用）
  static Future<List<Map<String, dynamic>>?> getActivitiesByAuthorDirect(String author) async {
    try {
      final graphQLDocument = '''
        query GetActivitiesByAuthor(\$author: String!) {
          getActivitiesByAuthor(author: \$author) {
            id
            author
            temp
            steps
            paid_monney
            created_at
          }
        }
      ''';
      
      final variables = {'author': author};
      
      final response = await Amplify.API.query(
        request: GraphQLRequest(
          document: graphQLDocument,
          variables: variables,
        )
      ).response;
      
      print('GetActivitiesByAuthor response: $response');
      
      // レスポンスからデータを抽出
      if (response.data != null) {
        final activities = response.data!['getActivitiesByAuthor'] as List<dynamic>?;
        if (activities != null) {
          return activities.map((activity) {
            final Map<String, dynamic> activityMap = Map<String, dynamic>.from(activity);
            // 数値フィールドを適切な型に変換
            if (activityMap['temp'] != null) {
              activityMap['temp'] = int.tryParse(activityMap['temp'].toString()) ?? 0;
            }
            if (activityMap['steps'] != null) {
              activityMap['steps'] = int.tryParse(activityMap['steps'].toString()) ?? 0;
            }
            if (activityMap['paid_monney'] != null) {
              activityMap['paid_monney'] = int.tryParse(activityMap['paid_monney'].toString()) ?? 0;
            }
            return activityMap;
          }).toList();
        }
      }
      
      return [];
    } catch (e) {
      print('Error fetching activities by author: $e');
      return null;
    }
  }

  /// Activityを作成する関数
  static Future<Map<String, dynamic>?> createActivity({
    required String author,
    required int temp,
    required int steps,
    required int paidMoney,
    required DateTime createdAt,
  }) async {
    try {
      final graphQLDocument = '''
        mutation CreateActivity(\$input: CreateActivityInput!) {
          createActivity(input: \$input) {
            id
            author
            temp
            steps
            paid_monney
            created_at
          }
        }
      ''';
      
      final variables = {
        'input': {
          'author': author,
          'temp': temp,
          'steps': steps,
          'paid_monney': paidMoney,
          'created_at': createdAt.toIso8601String(),
        }
      };
      
      final response = await Amplify.API.mutate(
        request: GraphQLRequest(
          document: graphQLDocument,
          variables: variables,
        )
      ).response;
      
      print('Create Activity response: $response');
      
      if (response.data != null) {
        final activity = response.data!['createActivity'] as Map<String, dynamic>;
        // 数値フィールドを適切な型に変換
        final Map<String, dynamic> activityMap = Map<String, dynamic>.from(activity);
        if (activityMap['temp'] != null) {
          activityMap['temp'] = int.tryParse(activityMap['temp'].toString()) ?? 0;
        }
        if (activityMap['steps'] != null) {
          activityMap['steps'] = int.tryParse(activityMap['steps'].toString()) ?? 0;
        }
        if (activityMap['paid_monney'] != null) {
          activityMap['paid_monney'] = int.tryParse(activityMap['paid_monney'].toString()) ?? 0;
        }
        return activityMap;
      }
      
      return null;
    } catch (e) {
      print('Error creating activity: $e');
      return null;
    }
  }

  /// Activityを更新する関数
  static Future<Map<String, dynamic>?> updateActivity({
    required String id,
    String? author,
    int? temp,
    int? steps,
    int? paidMoney,
    DateTime? createdAt,
  }) async {
    try {
      final graphQLDocument = '''
        mutation UpdateActivity(\$input: UpdateActivityInput!) {
          updateActivity(input: \$input) {
            id
            author
            temp
            steps
            paid_monney
            created_at
          }
        }
      ''';
      
      final input = <String, dynamic>{'id': id};
      if (author != null) input['author'] = author;
      if (temp != null) input['temp'] = temp;
      if (steps != null) input['steps'] = steps;
      if (paidMoney != null) input['paid_monney'] = paidMoney;
      if (createdAt != null) input['created_at'] = createdAt.toIso8601String();
      
      final variables = {'input': input};
      
      final response = await Amplify.API.mutate(
        request: GraphQLRequest(
          document: graphQLDocument,
          variables: variables,
        )
      ).response;
      
      print('Update Activity response: $response');
      
      if (response.data != null) {
        final activity = response.data!['updateActivity'] as Map<String, dynamic>;
        // 数値フィールドを適切な型に変換
        final Map<String, dynamic> activityMap = Map<String, dynamic>.from(activity);
        if (activityMap['temp'] != null) {
          activityMap['temp'] = int.tryParse(activityMap['temp'].toString()) ?? 0;
        }
        if (activityMap['steps'] != null) {
          activityMap['steps'] = int.tryParse(activityMap['steps'].toString()) ?? 0;
        }
        if (activityMap['paid_monney'] != null) {
          activityMap['paid_monney'] = int.tryParse(activityMap['paid_monney'].toString()) ?? 0;
        }
        return activityMap;
      }
      
      return null;
    } catch (e) {
      print('Error updating activity: $e');
      return null;
    }
  }

  /// Activityを削除する関数
  static Future<bool> deleteActivity(String id) async {
    try {
      const graphQLDocument = '''
        mutation DeleteActivity(\$input: DeleteActivityInput!) {
          deleteActivity(input: \$input) {
            id
          }
        }
      ''';
      
      final variables = {
        'input': {'id': id}
      };
      
      final response = await Amplify.API.mutate(
        request: GraphQLRequest(
          document: graphQLDocument,
          variables: variables,
        )
      ).response;
      
      print('Delete Activity response: $response');
      
      return response.data != null && response.data!['deleteActivity'] != null;
    } catch (e) {
      print('Error deleting activity: $e');
      return false;
    }
  }

  /// 特定のユーザーのActivityを取得する関数（従来の方法 - 全件取得後にフィルタリング）
  static Future<List<Map<String, dynamic>>?> getActivitiesByAuthor(String author) async {
    try {
      final allActivities = await getActivities();
      if (allActivities != null) {
        return allActivities.where((activity) => activity['author'] == author).toList();
      }
      return null;
    } catch (e) {
      print('Error fetching activities by author: $e');
      return null;
    }
  }

  /// 最新のActivityを取得する関数
  static Future<Map<String, dynamic>?> getLatestActivity() async {
    try {
      final activities = await getActivities();
      if (activities != null && activities.isNotEmpty) {
        // created_atでソートして最新のものを取得
        activities.sort((a, b) {
          final aDate = DateTime.parse(a['created_at']);
          final bDate = DateTime.parse(b['created_at']);
          return bDate.compareTo(aDate); // 降順（最新が先頭）
        });
        return activities.first;
      }
      return null;
    } catch (e) {
      print('Error fetching latest activity: $e');
      return null;
    }
  }

  /// 特定のauthorの最新のActivityを取得する関数
  static Future<Map<String, dynamic>?> getLatestActivityByAuthor(String author) async {
    try {
      final activities = await getActivitiesByAuthorDirect(author);
      if (activities != null && activities.isNotEmpty) {
        // created_atでソートして最新のものを取得
        activities.sort((a, b) {
          final aDate = DateTime.parse(a['created_at']);
          final bDate = DateTime.parse(b['created_at']);
          return bDate.compareTo(aDate); // 降順（最新が先頭）
        });
        return activities.first;
      }
      return null;
    } catch (e) {
      print('Error fetching latest activity by author: $e');
      return null;
    }
  }
} 