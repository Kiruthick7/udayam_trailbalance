import 'package:dio/dio.dart';
import '../models/company.dart';
import '../models/trial_balance.dart';
import '../models/sales_detail.dart';
import '../models/daily_sales_summary.dart';
import '../services/auth_interceptor.dart';
import '../services/storage_service.dart';

class ApiService {
  late final Dio _dio;

  ApiService(
      {String baseUrl =
          // Production: 'https://h32dbgnyv3.execute-api.ap-south-1.amazonaws.com'
          // iOS Simulator: 'http://127.0.0.1:8000'
          // Android Emulator: 'http://10.0.2.2:8000'
          // Physical Device: Use your Mac's IP, e.g., 'http://192.168.1.100:8000'
          'https://h32dbgnyv3.execute-api.ap-south-1.amazonaws.com'}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        headers: {'Content-Type': 'application/json'},
      ),
    );

    _dio.interceptors.add(AuthInterceptor(_dio));
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _dio.post(
      '/auth/login',
      data: {'email': email, 'password': password},
      options: Options(headers: {'Authorization': null}),
    );

    return response.data;
  }

  Future<List<Company>> getCompanies() async {
    final response = await _dio.get('/api/companies');
    return (response.data as List).map((e) => Company.fromJson(e)).toList();
  }

  Future<List<TrialBalanceReport>> getTrialBalance(
    List<String> companyIds,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final response = await _dio.post(
      '/api/trial-balance',
      data: {
        'companyIds': companyIds,
        'startDate': startDate.toIso8601String().split('T')[0],
        'endDate': endDate.toIso8601String().split('T')[0],
      },
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
    final response = await _dio.post(
      '/api/trial-balance-store',
      options: Options(headers: {'Authorization': null}),
      data: {
        'companyIds': companyIds,
        'startDate': startDate.toIso8601String().split('T')[0],
        'endDate': endDate.toIso8601String().split('T')[0],
      },
    );
    return (response.data['companies'] as List)
        .map((e) => TrialBalanceReport.fromJson(e))
        .toList();
  }

  Future<List<DailySalesSummary>> getCurrentDayCustomerSales() async {
    final response = await _dio.get('/api/current-day-customer-sales');

    return (response.data as List)
        .map((e) => DailySalesSummary.fromJson(e))
        .toList();
  }

  Future<List<SalesDetail>> getSalesDetails(
    DateTime billdate,
    int billno,
    String cuscod,
  ) async {
    final response = await _dio.post(
      '/api/sales-details',
      data: {
        'billdate': billdate.toIso8601String().split('T')[0],
        'billno': billno,
        'cuscod': cuscod,
      },
    );

    return (response.data as List).map((e) => SalesDetail.fromJson(e)).toList();
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
}
