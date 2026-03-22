import 'package:dio/dio.dart';
import '../models/company.dart';
import '../models/trial_balance.dart';
import '../models/sales_detail.dart';
import '../models/daily_sales_summary.dart';
import '../services/auth_interceptor.dart';
import '../services/storage_service.dart';
import '../core/dio_custom_retry_interceptor.dart';

// Pending bill models
class PendingBill {
  final String cuscod;
  final int bilnum;
  final DateTime bildat;
  final double debit;
  final double credit;
  final double balance;

  PendingBill({
    required this.cuscod,
    required this.bilnum,
    required this.bildat,
    required this.debit,
    required this.credit,
    required this.balance,
  });

  factory PendingBill.fromJson(Map<String, dynamic> json) {
    return PendingBill(
      cuscod: json['cuscod'] as String,
      bilnum: json['bilnum'] as int,
      bildat: DateTime.parse(json['bildat'] as String),
      debit: (json['debit'] as num).toDouble(),
      credit: (json['credit'] as num).toDouble(),
      balance: (json['balance'] as num).toDouble(),
    );
  }
}

class PendingBillSummary {
  final List<PendingBill> pendingBills;
  final double totalBalance;

  PendingBillSummary({
    required this.pendingBills,
    required this.totalBalance,
  });

  factory PendingBillSummary.fromJson(Map<String, dynamic> json) {
    return PendingBillSummary(
      pendingBills: (json['pending_bills'] as List)
          .map((e) => PendingBill.fromJson(e))
          .toList(),
      totalBalance: (json['total_balance'] as num).toDouble(),
    );
  }
}

class ApiService {
  /// Checks if the backend session is valid (user is authenticated)
  /// Uses /auth-check/check endpoint for session validity.
  Future<bool> isSessionValid() async {
    try {
      final response = await _dio.get('/auth-check/check');
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  late final Dio _dio;

  ApiService(
      // Production: 'https://h32dbgnyv3.execute-api.ap-south-1.amazonaws.com'
      // iOS Simulator: 'http://127.0.0.1:8000'
      // Android Emulator: 'http://10.0.2.2:8000'
      // Physical Device: Use your Mac's IP, e.g., 'http://192.168.1.100:8000'
      {String baseUrl =
          'https://h32dbgnyv3.execute-api.ap-south-1.amazonaws.com'}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        headers: {'Content-Type': 'application/json'},
      ),
    );

    _dio.interceptors.add(AuthInterceptor(_dio));
    _dio.interceptors.add(CustomRetryInterceptor(
        dio: _dio, maxRetries: 3, retryDelay: Duration(seconds: 2)));
  }

  Future<Map<String, dynamic>> login(String email, String password,
      {String? userId}) async {
    final response = await _dio.post(
      '/auth/login',
      data: {
        'email': email,
        'password': password,
        if (userId != null) 'user_id': userId,
      },
      options: Options(headers: {'Authorization': null}),
    );
    return response.data;
  }

  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    final response = await _dio.post(
      '/auth/refresh',
      data: {'refresh_token': refreshToken},
      options: Options(headers: {'Authorization': null}),
    );

    return response.data;
  }

  Future<List<Company>> getCompanies({String? userId}) async {
    final response = await _dio.get('/api/companies');
    final companies =
        (response.data as List).map((e) => Company.fromJson(e)).toList();
    if (userId == null || userId.isEmpty) {
      return companies;
    } else {
      final trimmedUserId = userId.trim();
      return companies
          .where((c) => c.fircodId.trim() == trimmedUserId)
          .toList();
    }
  }

  Future<List<TrialBalanceReport>> getTrialBalance(
    List<String> companyIds,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final payload = {
      'companyIds': companyIds,
      'startDate': startDate.toIso8601String().split('T')[0],
      'endDate': endDate.toIso8601String().split('T')[0],
    };
    final response = await _dio.post(
      '/api/trial-balance',
      data: payload,
    );
    return (response.data['companies'] as List)
        .map((e) => TrialBalanceReport.fromJson(e))
        .toList();
  }

  Future<List<TrialBalanceReport>> getTrialBalanceStore(
    List<String> companyIds,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final payload = {
      'companyIds': companyIds,
      'startDate': startDate.toIso8601String().split('T')[0],
      'endDate': endDate.toIso8601String().split('T')[0],
    };
    final response = await _dio.post(
      '/api/trial-balance-store',
      options: Options(headers: {'Authorization': null}),
      data: payload,
    );
    return (response.data['companies'] as List)
        .map((e) => TrialBalanceReport.fromJson(e))
        .toList();
  }

  /// For admin: returns a map with 'regular_sales' and 'shop_sales' lists
  Future<Map<String, List<DailySalesSummary>>> getCurrentDayCustomerSales({
    DateTime? date,
  }) async {
    final queryParams = <String, dynamic>{};
    if (date != null) queryParams['date'] = _formatDate(date);
    final response = await _dio.get(
      '/api/current-day-customer-sales',
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );
    final data = response.data;

    if (data is! Map) {
      throw Exception('Unexpected backend response: ${data.runtimeType}');
    }

    // Defensive: ensure both keys exist and are lists
    final regularSalesRaw =
        (data['regular_sales'] is List) ? data['regular_sales'] : [];
    final shopSalesRaw = (data['shop_sales'] is List) ? data['shop_sales'] : [];

    // Parse each list safely
    final regularSales = regularSalesRaw
        .map<DailySalesSummary>(
            (e) => DailySalesSummary.fromJson(e as Map<String, dynamic>))
        .toList();
    final shopSales = shopSalesRaw
        .map<DailySalesSummary>(
            (e) => DailySalesSummary.fromJson(e as Map<String, dynamic>))
        .toList();

    // Return as expected by provider
    return {
      'regular_sales': regularSales,
      'shop_sales': shopSales,
    };
  }

  /// For staff: returns only shop sales filtered by user_id
  Future<List<DailySalesSummary>> getCurrentDayCustomerSalesShop({
    DateTime? date,
    String? userId,
  }) async {
    final queryParams = <String, dynamic>{};
    if (date != null) queryParams['date'] = _formatDate(date);
    if (userId != null) queryParams['user_id'] = userId;
    final response = await _dio.get(
      '/api/current-day-customer-sales-shop',
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );
    return (response.data as List)
        .map((e) => DailySalesSummary.fromJson(e))
        .toList();
  }

  Future<Map<String, double>> getProfitLoss([DateTime? date]) async {
    final queryParams = date != null ? {'date': _formatDate(date)} : null;
    final response = await _dio.get(
      '/api/profit-loss',
      queryParameters: queryParams,
    );

    return {
      'total_profit': (response.data['total_profit'] as num).toDouble(),
      'total_loss': (response.data['total_loss'] as num).toDouble(),
    };
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<List<SalesDetail>> getSalesDetails(
    DateTime billdate,
    int billno,
    String cuscod,
  ) async {
    try {
      final response = await _dio.post(
        '/api/sales-details',
        data: {
          'billdate': billdate.toIso8601String().split('T')[0],
          'billno': billno,
          'cuscod': cuscod,
        },
      );
      return (response.data as List)
          .map((e) => SalesDetail.fromJson(e))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post('/auth/logout');
    } catch (_) {
      // ignore server errors on logout
    } finally {
      await StorageService.clearAll();
    }
  }

  /// Fetch customer pending bills as of a date
  Future<PendingBillSummary> getCustomerPendingBills({
    required String cuscod,
    required DateTime mfdate,
  }) async {
    final params = {
      'cuscod': cuscod,
      'mfdate': _formatDate(mfdate),
    };
    try {
      final response = await _dio.get(
        '/api/customer-pending-bills',
        queryParameters: params,
      );
      return PendingBillSummary.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
