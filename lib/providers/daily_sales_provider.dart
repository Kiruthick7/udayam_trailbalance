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

  const DailySalesState({
    this.salesList = const [],
    this.isLoading = false,
    this.error,
  });

  DailySalesState copyWith({
    List<DailySalesSummary>? salesList,
    bool? isLoading,
    String? error,
  }) {
    return DailySalesState(
      salesList: salesList ?? this.salesList,
      isLoading: isLoading ?? this.isLoading,
      error: error,
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
}

// StateNotifier for daily sales summary
class DailySalesNotifier extends StateNotifier<DailySalesState> {
  final ApiService _apiService;
  final Ref _ref;

  DailySalesNotifier(this._apiService, this._ref)
      : super(const DailySalesState());

  Future<void> fetchDailySales() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final salesList = await _apiService.getCurrentDayCustomerSales();
      state = state.copyWith(
        salesList: salesList,
        isLoading: false,
      );
    } catch (e) {
      // Check if auth error and logout
      if (ErrorHandler.isAuthError(e)) {
        await _ref.read(authProvider.notifier).logout();
      }

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

// Provider for daily sales summary
final dailySalesProvider =
    StateNotifierProvider<DailySalesNotifier, DailySalesState>((ref) {
  final apiService = ApiService();
  return DailySalesNotifier(apiService, ref);
});
