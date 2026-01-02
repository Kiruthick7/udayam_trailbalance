import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trial_balance_app/providers/auth_provider.dart';
import '../models/trial_balance.dart';
import '../services/api_service.dart';
import '../services/connectivity_service.dart';
import '../utils/error_handler.dart';

class TrialBalanceState {
  final List<TrialBalanceReport> reports;
  final bool isLoading;
  final String? error;
  final DateTime? lastUpdated;

  TrialBalanceState({
    this.reports = const [],
    this.isLoading = false,
    this.error,
    this.lastUpdated,
  });

  TrialBalanceState copyWith({
    List<TrialBalanceReport>? reports,
    bool? isLoading,
    String? error,
    DateTime? lastUpdated,
  }) {
    return TrialBalanceState(
      reports: reports ?? this.reports,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

class TrialBalanceNotifier extends StateNotifier<TrialBalanceState> {
  final ApiService _apiService;
  final ConnectivityService _connectivityService;

  TrialBalanceNotifier(
    this._apiService,
    this._connectivityService,
  ) : super(TrialBalanceState());

  Future<void> fetchTrialBalance(
    List<String> companyIds,
    DateTime startDate,
    DateTime endDate, {
    bool forceRefresh = false,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final hasInternet = await _connectivityService.hasInternetConnection();

    if (!hasInternet) {
      state = state.copyWith(
        isLoading: false,
        error: 'Network not connected. Please check your internet connection.',
      );
      return;
    }

    try {
      final List<TrialBalanceReport> allReports = [];

      for (final companyId in companyIds) {
        if (companyId == "GHE01") {
          // 👉 Special store logic
          final storeReports = await _apiService.getTrialBalance(
            [companyId],
            startDate,
            endDate,
          );
          allReports.addAll(storeReports);
        } else {
          // 👉 Normal logic for others
          final normalReports = await _apiService.getTrialBalanceStore(
            [companyId],
            startDate,
            endDate,
          );
          allReports.addAll(normalReports);
        }
      }

      state = state.copyWith(
        reports: allReports,
        isLoading: false,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      final errorMessage = ErrorHandler.getErrorMessage(e);
      state = state.copyWith(
        isLoading: false,
        error: errorMessage,
      );
    }
  }
}

final trialBalanceProvider =
    StateNotifierProvider<TrialBalanceNotifier, TrialBalanceState>((ref) {
  return TrialBalanceNotifier(
    ref.watch(apiServiceProvider),
    ref.watch(connectivityServiceProvider),
  );
});
