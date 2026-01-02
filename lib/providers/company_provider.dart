import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/company.dart';
import '../services/api_service.dart';
import '../utils/error_handler.dart';
import 'auth_provider.dart';

class CompanyState {
  final bool isLoading;
  final List<Company> companies;
  final String? error;

  CompanyState({
    this.isLoading = false,
    this.companies = const [],
    this.error,
  });

  CompanyState copyWith({
    bool? isLoading,
    List<Company>? companies,
    String? error,
  }) {
    return CompanyState(
      isLoading: isLoading ?? this.isLoading,
      companies: companies ?? this.companies,
      error: error,
    );
  }

  List<Company> get selectedCompanies =>
      companies.where((c) => c.isSelected).toList();
}

class CompanyNotifier extends StateNotifier<CompanyState> {
  final ApiService api;

  CompanyNotifier(this.api) : super(CompanyState());

  Future<void> fetchCompanies() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final companies = await api.getCompanies();
      state = state.copyWith(isLoading: false, companies: companies);
    } catch (e) {
      final errorMessage = ErrorHandler.getErrorMessage(e);
      state = state.copyWith(isLoading: false, error: errorMessage);
    }
  }

  void toggleCompany(int companyId) {
    final updatedCompanies = state.companies.map((c) {
      if (c.snoId == companyId) {
        return c.copyWith(isSelected: !c.isSelected);
      }
      return c;
    }).toList();
    state = state.copyWith(companies: updatedCompanies);
  }

  void clearSelection() {
    final updatedCompanies =
        state.companies.map((c) => c.copyWith(isSelected: false)).toList();
    state = state.copyWith(companies: updatedCompanies);
  }
}

final companyProvider =
    StateNotifierProvider<CompanyNotifier, CompanyState>((ref) {
  return CompanyNotifier(ref.read(apiServiceProvider));
});
