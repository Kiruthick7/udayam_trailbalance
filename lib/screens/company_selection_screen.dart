import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/company_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/responsive_helper.dart';
import 'trial_balance_screen.dart';
import 'login_screen.dart';

class CompanySelectionScreen extends ConsumerStatefulWidget {
  const CompanySelectionScreen({super.key});

  @override
  ConsumerState<CompanySelectionScreen> createState() =>
      _CompanySelectionScreenState();
}

class _CompanySelectionScreenState
    extends ConsumerState<CompanySelectionScreen> {
  final DateTime _startDate = DateTime(2025, 4, 1);

  late final DateTime _endDate = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  @override
  void initState() {
    super.initState();
    _loadCompanies();
  }

  void _loadCompanies() {
    Future.microtask(() => ref.read(companyProvider.notifier).fetchCompanies());
  }

  Future<void> _viewTrialBalance() async {
    final selectedCompanies = ref.read(companyProvider).selectedCompanies;
    if (selectedCompanies.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select at least one company'),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TrialBalanceScreen(
          companyIds: selectedCompanies.map((c) => c.fircod).toList(),
          startDate: _startDate,
          endDate: _endDate,
        ),
      ),
    );

    if (mounted) _loadCompanies();
  }

  @override
  Widget build(BuildContext context) {
    final companyState = ref.watch(companyProvider);
    final isTabletOrLarger = !ResponsiveHelper.isMobile(context);

    return Scaffold(
      appBar: _buildAppBar(companyState),
      body: ResponsiveHelper.constrainedContent(
        context: context,
        child: Column(
          children: [
            _DateRangeHeader(startDate: _startDate, endDate: _endDate),
            const Divider(height: 1),
            if (companyState.selectedCompanies.isNotEmpty)
              _SelectedCountBanner(
                  count: companyState.selectedCompanies.length),
            Expanded(
              child: isTabletOrLarger
                  ? _buildGridBody(companyState)
                  : _buildListBody(companyState),
            ),
          ],
        ),
      ),
      floatingActionButton: companyState.selectedCompanies.isNotEmpty
          ? _ViewReportButton(
              count: companyState.selectedCompanies.length,
              onPressed: _viewTrialBalance,
            )
          : null,
    );
  }

  PreferredSizeWidget _buildAppBar(companyState) {
    return AppBar(
      title: Text(
        'Select Companies',
        style: TextStyle(
          fontSize: ResponsiveHelper.getResponsiveFontSize(context, 20),
        ),
      ),
      elevation: 2,
      actions: [
        if (companyState.selectedCompanies.isNotEmpty)
          TextButton.icon(
            onPressed: () =>
                ref.read(companyProvider.notifier).clearSelection(),
            icon: Icon(
              Icons.clear_all,
              color: Colors.grey[800],
              size: ResponsiveHelper.getResponsiveIconSize(context, 18),
            ),
            label: Text(
              'Clear',
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
              ),
            ),
          ),
        IconButton(
          onPressed: () async {
            await ref.read(authProvider.notifier).logout();
            if (mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            }
          },
          icon: Icon(
            Icons.logout,
            color: Colors.black,
            size: ResponsiveHelper.getResponsiveIconSize(context, 20),
          ),
          tooltip: 'Logout',
        ),
      ],
    );
  }

  Widget _buildListBody(companyState) {
    if (companyState.isLoading) return const _LoadingView();
    if (companyState.error != null) {
      return _ErrorView(error: companyState.error!, onRetry: _loadCompanies);
    }
    if (companyState.companies.isEmpty) return const _EmptyView();

    return _CompanyList(
      companies: companyState.companies,
      onToggle: (snoId) =>
          ref.read(companyProvider.notifier).toggleCompany(snoId),
    );
  }

  Widget _buildGridBody(companyState) {
    if (companyState.isLoading) return const _LoadingView();
    if (companyState.error != null) {
      return _ErrorView(error: companyState.error!, onRetry: _loadCompanies);
    }
    if (companyState.companies.isEmpty) return const _EmptyView();

    return _CompanyGrid(
      companies: companyState.companies,
      onToggle: (snoId) =>
          ref.read(companyProvider.notifier).toggleCompany(snoId),
    );
  }
}

// Extracted Widgets

class _DateRangeHeader extends StatelessWidget {
  final DateTime startDate;
  final DateTime endDate;

  const _DateRangeHeader({required this.startDate, required this.endDate});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.getResponsivePadding(context, 16),
        vertical: ResponsiveHelper.getResponsivePadding(context, 12),
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green[700]!, Colors.green[600]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(
                ResponsiveHelper.getResponsivePadding(context, 8)),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.calendar_today,
              color: Colors.white,
              size: ResponsiveHelper.getResponsiveIconSize(context, 20),
            ),
          ),
          SizedBox(width: ResponsiveHelper.getResponsivePadding(context, 12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Report Period',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize:
                        ResponsiveHelper.getResponsiveFontSize(context, 11),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(
                    height: ResponsiveHelper.getResponsivePadding(context, 4)),
                Text(
                  '01/04/2025 - ${endDate.day.toString().padLeft(2, '0')}/${endDate.month.toString().padLeft(2, '0')}/${endDate.year}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize:
                        ResponsiveHelper.getResponsiveFontSize(context, 15),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectedCountBanner extends StatelessWidget {
  final int count;

  const _SelectedCountBanner({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.getResponsivePadding(context, 16),
        vertical: ResponsiveHelper.getResponsivePadding(context, 10),
      ),
      color: Colors.green[50],
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: Colors.green[700],
            size: ResponsiveHelper.getResponsiveIconSize(context, 18),
          ),
          SizedBox(width: ResponsiveHelper.getResponsivePadding(context, 8)),
          Text(
            '$count ${count == 1 ? 'company' : 'companies'} selected',
            style: TextStyle(
              color: Colors.green[700],
              fontWeight: FontWeight.w600,
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.green[700]),
          SizedBox(height: ResponsiveHelper.getResponsivePadding(context, 16)),
          Text(
            'Loading companies...',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding:
            EdgeInsets.all(ResponsiveHelper.getResponsivePadding(context, 24)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: ResponsiveHelper.getResponsiveIconSize(context, 64),
              color: Colors.red[300],
            ),
            SizedBox(
                height: ResponsiveHelper.getResponsivePadding(context, 16)),
            Text(
              'Error Loading Companies',
              style: TextStyle(
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 18),
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: ResponsiveHelper.getResponsivePadding(context, 8)),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
              ),
            ),
            SizedBox(
                height: ResponsiveHelper.getResponsivePadding(context, 24)),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal:
                      ResponsiveHelper.getResponsivePadding(context, 24),
                  vertical: ResponsiveHelper.getResponsivePadding(context, 12),
                ),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.business_outlined,
            size: ResponsiveHelper.getResponsiveIconSize(context, 64),
            color: Colors.grey[400],
          ),
          SizedBox(height: ResponsiveHelper.getResponsivePadding(context, 16)),
          Text(
            'No companies found',
            style: TextStyle(
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

class _CompanyList extends StatelessWidget {
  final List companies;
  final void Function(int) onToggle;

  const _CompanyList({required this.companies, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(
        vertical: ResponsiveHelper.getResponsivePadding(context, 8),
      ),
      itemCount: companies.length,
      itemBuilder: (context, index) => _CompanyListItem(
        company: companies[index],
        onToggle: () => onToggle(companies[index].snoId),
      ),
    );
  }
}

class _CompanyGrid extends StatelessWidget {
  final List companies;
  final void Function(int) onToggle;

  const _CompanyGrid({required this.companies, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final columns = ResponsiveHelper.getGridColumns(context);

    return GridView.builder(
      padding:
          EdgeInsets.all(ResponsiveHelper.getResponsivePadding(context, 12)),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        childAspectRatio: 4,
        crossAxisSpacing: ResponsiveHelper.getResponsivePadding(context, 12),
        mainAxisSpacing: ResponsiveHelper.getResponsivePadding(context, 12),
      ),
      itemCount: companies.length,
      itemBuilder: (context, index) => _CompanyListItem(
        company: companies[index],
        onToggle: () => onToggle(companies[index].snoId),
      ),
    );
  }
}

class _CompanyListItem extends StatelessWidget {
  final dynamic company;
  final VoidCallback onToggle;

  const _CompanyListItem({required this.company, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final isSelected = company.isSelected;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.getResponsivePadding(context, 12),
        vertical: ResponsiveHelper.getResponsivePadding(context, 4),
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isSelected
              ? [Colors.white, Colors.green[50]!]
              : [Colors.green[200]!, Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSelected ? Colors.green[300]! : Colors.grey[200]!,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: Colors.green.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: CheckboxListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: ResponsiveHelper.getResponsivePadding(context, 16),
          vertical: ResponsiveHelper.getResponsivePadding(context, 4),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                company.firname,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
                  color: isSelected ? Colors.green[900] : Colors.grey[800],
                ),
              ),
            ),
            _CompanyCodeBadge(code: company.fircodId, isSelected: isSelected),
          ],
        ),
        value: isSelected,
        activeColor: Colors.green[700],
        checkColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        onChanged: (_) => onToggle(),
      ),
    );
  }
}

class _CompanyCodeBadge extends StatelessWidget {
  final String code;
  final bool isSelected;

  const _CompanyCodeBadge({required this.code, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.getResponsivePadding(context, 8),
        vertical: ResponsiveHelper.getResponsivePadding(context, 4),
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isSelected
              ? [Colors.white, Colors.green[100]!]
              : [Colors.white, Colors.grey[100]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isSelected ? Colors.green[200]! : Colors.grey[300]!,
          width: 0.5,
        ),
      ),
      child: Text(
        code,
        style: TextStyle(
          fontSize: ResponsiveHelper.getResponsiveFontSize(context, 11),
          fontWeight: FontWeight.w600,
          fontFamily: 'monospace',
          color: isSelected ? Colors.green[700] : Colors.grey[600],
        ),
      ),
    );
  }
}

class _ViewReportButton extends StatelessWidget {
  final int count;
  final VoidCallback onPressed;

  const _ViewReportButton({required this.count, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: onPressed,
      backgroundColor: Colors.green[700],
      icon: Icon(
        Icons.assessment,
        size: ResponsiveHelper.getResponsiveIconSize(context, 24),
      ),
      label: Text(
        'View Report ($count)',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
        ),
      ),
    );
  }
}
