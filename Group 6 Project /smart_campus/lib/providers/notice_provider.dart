import 'package:flutter/foundation.dart';
import '../models/notice.dart';
import '../services/api_service.dart';
import '../services/local_db_service.dart';

class NoticeProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final LocalDbService _localDbService = LocalDbService();

  List<Notice> notices = [];
  bool isLoading = false;
  String? errorMessage;

  void setToken(String token) {
    _apiService.setToken(token);
  }

  Future<void> fetchNotices() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final response = await _apiService.get('/notices');
      if (response != null && response is List) {
        notices = response.map((data) => Notice.fromJson(data)).toList();
        await _localDbService.cacheNotices(notices);
      }

      isLoading = false;
      notifyListeners();
    } catch (e) {
      notices = await _localDbService.getCachedNotices();
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> postNotice({
    required String title,
    required String content,
    String targetRole = 'all',
    String? audience,
    String? author,
  }) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final role = audience?.toLowerCase() ?? targetRole.toLowerCase();

      await _apiService.post('/notices', {
        'title': title,
        'content': content,
        'target_role': role,
      });
      await fetchNotices();
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteNotice(int id) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      await _apiService.delete('/notices/$id');
      await fetchNotices();
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCachedNotices() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      notices = await _localDbService.getCachedNotices();

      isLoading = false;
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
    }
  }
}
