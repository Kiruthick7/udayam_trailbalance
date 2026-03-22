import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/daily_sales_summary.dart';
import '../services/api_service.dart';
import '../utils/error_handler.dart';
import 'auth_provider.dart';

// State class for daily sales summary
class DailySalesState {
  final List<DailySalesSummary> salesList;
  final bool isLoading;
  final String? error;
  final double totalProfit;
  final double totalLoss;

  const DailySalesState({
    this.salesList = const [],
    this.isLoading = false,
    this.error,
    this.totalProfit = 0.0,
    this.totalLoss = 0.0,
  });

  DailySalesState copyWith({
    List<DailySalesSummary>? salesList,
    bool? isLoading,
    String? error,
    double? totalProfit,
    double? totalLoss,
  }) {
    return DailySalesState(
      salesList: salesList ?? this.salesList,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      totalProfit: totalProfit ?? this.totalProfit,
      totalLoss: totalLoss ?? this.totalLoss,
    );
  }

  // Calculate total sales for the day
  double get totalNetAmount {
    return salesList.fold(0.0, (sum, sale) => sum + sale.net);
  }

  // Calculate total quantity for the day
  double get totalQuantity {
    return salesList.fold(0.0, (sum, sale) => sum + sale.tqty);
  }

  String get formattedTotalNet {
    return totalNetAmount.toStringAsFixed(2);
  }

  String get formattedTotalProfit {
    return totalProfit.toStringAsFixed(2);
  }

  String get formattedTotalLoss {
    return totalLoss.toStringAsFixed(2);
  }
}

// StateNotifier for daily sales summary
class DailySalesNotifier extends Notifier<DailySalesState> {
  late final ApiService _apiService;

  @override
  DailySalesState build() {
    _apiService = ref.read(apiServiceProvider);
    return const DailySalesState();
  }

  Future<void> fetchDailySales([DateTime? date]) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final authState = ref.read(authProvider);
      final userRole = authState.user?['role'] as String?;
      final userId = authState.user?['user_id']?.toString();

      if (userRole == 'admin') {
        // Admin: fetch all bills
        final results = await Future.wait([
          _apiService.getCurrentDayCustomerSales(date: date),
          _apiService.getProfitLoss(date),
        ]);
        final dynamic salesMapRaw = results[0];
        final profitLoss = results[1] as Map<String, double>;

        List<DailySalesSummary> regularSales = [];
        List<DailySalesSummary> shopSales = [];
        if (salesMapRaw is Map) {
          if (salesMapRaw['regular_sales'] is List<DailySalesSummary>) {
            regularSales = salesMapRaw['regular_sales'];
          } else if (salesMapRaw['regular_sales'] is List) {
            regularSales =
                List<DailySalesSummary>.from(salesMapRaw['regular_sales']);
          }
          if (salesMapRaw['shop_sales'] is List<DailySalesSummary>) {
            shopSales = salesMapRaw['shop_sales'];
          } else if (salesMapRaw['shop_sales'] is List) {
            shopSales = List<DailySalesSummary>.from(salesMapRaw['shop_sales']);
          }
        }

        final allSales = [
          ...regularSales,
          ...shopSales,
        ];
        state = state.copyWith(
          salesList: allSales,
          totalProfit: profitLoss['total_profit'] ?? 0.0,
          totalLoss: profitLoss['total_loss'] ?? 0.0,
          isLoading: false,
        );
      } else {
        // Staff: fetch only their bills
        final salesList = await _apiService.getCurrentDayCustomerSalesShop(
          date: date,
          userId: userId,
        );
        state = state.copyWith(
          salesList: salesList,
          totalProfit: 0.0,
          totalLoss: 0.0,
          isLoading: false,
        );
      }
    } catch (e) {
      // Check if auth error and logout
      if (ErrorHandler.isAuthError(e)) {
        await ref.read(authProvider.notifier).logout();
      }

      // ...existing code...

      state = state.copyWith(
        isLoading: false,
        error: ErrorHandler.getErrorMessage(e),
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void clearSales() {
    state = const DailySalesState();
  }
}

final dailySalesProvider =
    NotifierProvider<DailySalesNotifier, DailySalesState>(
        () => DailySalesNotifier());
