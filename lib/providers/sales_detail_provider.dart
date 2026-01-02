import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/sales_detail.dart';
import '../services/api_service.dart';
import '../utils/error_handler.dart';
import 'auth_provider.dart';

class SalesDetailState {
  final List<SalesDetail> details;
  final bool isLoading;
  final String? error;
  final String? customerName;
  final String? customerAddress;
  final String? customerPhone;
  final String? salesmanName;
  final String? salesmanPhone;
  final String? managerName;
  final String? managerPhone;

  SalesDetailState({
    this.details = const [],
    this.isLoading = false,
    this.error,
    this.customerName,
    this.customerAddress,
    this.customerPhone,
    this.salesmanName,
    this.salesmanPhone,
    this.managerName,
    this.managerPhone,
  });

  SalesDetailState copyWith({
    List<SalesDetail>? details,
    bool? isLoading,
    String? error,
    String? customerName,
    String? customerAddress,
    String? customerPhone,
    String? salesmanName,
    String? salesmanPhone,
    String? managerName,
    String? managerPhone,
  }) {
    return SalesDetailState(
      details: details ?? this.details,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      customerName: customerName ?? this.customerName,
      customerAddress: customerAddress ?? this.customerAddress,
      customerPhone: customerPhone ?? this.customerPhone,
      salesmanName: salesmanName ?? this.salesmanName,
      salesmanPhone: salesmanPhone ?? this.salesmanPhone,
      managerName: managerName ?? this.managerName,
      managerPhone: managerPhone ?? this.managerPhone,
    );
  }

  // Get total quantity
  double get totalQuantity {
    if (details.isEmpty) return 0.0;
    return details.first.tqty;
  }

  // Get net amount
  double get netAmount {
    if (details.isEmpty) return 0.0;
    return details.first.net;
  }

  // Get formatted net amount
  String get formattedNetAmount => netAmount.toStringAsFixed(2);

  // Calculate total profit/loss
  double get totalProfitLoss {
    if (details.isEmpty) return 0.0;
    return details.fold(0.0, (sum, item) => sum + item.itemProfit);
  }

  // Get formatted profit/loss
  String get formattedProfitLoss {
    final profit = totalProfitLoss;
    if (profit >= 0) {
      return profit.toStringAsFixed(2);
    } else {
      return '-${profit.abs().toStringAsFixed(2)}';
    }
  }

  // Check if overall profitable
  bool get isProfitable => totalProfitLoss >= 0;

  // Get bill number
  int? get billNumber {
    if (details.isEmpty) return null;
    return details.first.billno;
  }

  // Get bill date
  DateTime? get billDate {
    if (details.isEmpty) return null;
    return details.first.billdate;
  }
}

class SalesDetailNotifier extends StateNotifier<SalesDetailState> {
  final ApiService _apiService;

  SalesDetailNotifier(this._apiService) : super(SalesDetailState());

  Future<void> fetchSalesDetails({
    required DateTime billdate,
    required int billno,
    required String cuscod,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final details =
          await _apiService.getSalesDetails(billdate, billno, cuscod);

      if (details.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          error: 'No sales details found for this bill',
        );
        return;
      }

      // Extract customer info from first record
      final firstDetail = details.first;

      state = state.copyWith(
        details: details,
        isLoading: false,
        customerName: firstDetail.cusnam,
        customerAddress: firstDetail.fullAddress,
        customerPhone: firstDetail.phone,
        salesmanName: firstDetail.salmannam,
        salesmanPhone: firstDetail.salmanphon,
        managerName: firstDetail.managername,
        managerPhone: firstDetail.managerphon,
      );
    } catch (e) {
      final errorMessage = ErrorHandler.getErrorMessage(e);
      state = state.copyWith(
        isLoading: false,
        error: errorMessage,
      );
    }
  }

  void clearDetails() {
    state = SalesDetailState();
  }
}

final salesDetailProvider =
    StateNotifierProvider<SalesDetailNotifier, SalesDetailState>((ref) {
  return SalesDetailNotifier(ref.read(apiServiceProvider));
});
