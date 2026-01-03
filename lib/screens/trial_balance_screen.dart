import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trial_balance_app/services/export_services.dart';
import '../providers/trial_balance_provider.dart';
import '../services/connectivity_service.dart';
import '../widgets/trial_balance_table.dart';
import '../widgets/comparison_view.dart';
import '../utils/responsive_helper.dart';

class TrialBalanceScreen extends ConsumerStatefulWidget {
  final List<String> companyIds;
  final DateTime startDate;
  final DateTime endDate;

  const TrialBalanceScreen({
    super.key,
    required this.companyIds,
    required this.startDate,
    required this.endDate,
  });

  @override
  ConsumerState<TrialBalanceScreen> createState() => _TrialBalanceScreenState();
}

class _TrialBalanceScreenState extends ConsumerState<TrialBalanceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _exportService = ExportService();
  bool _hasInitialized = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    if (!mounted) return;

    await ref.read(trialBalanceProvider.notifier).fetchTrialBalance(
          widget.companyIds,
          widget.startDate,
          widget.endDate,
          forceRefresh: true,
        );
  }

  Rect? _getSharePositionOrigin(BuildContext context) {
    // Get the screen size
    final size = MediaQuery.of(context).size;
    // Return a rect at the center-top of the screen for iPad popover
    return Rect.fromLTWH(
      size.width / 2,
      100,
      1,
      1,
    );
  }

  void _showExportOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final state = ref.read(trialBalanceProvider);
        final sharePosition = _getSharePositionOrigin(context);

        return Container(
          padding: EdgeInsets.all(
              ResponsiveHelper.getResponsivePadding(context, 20)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Export Report',
                style: TextStyle(
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 20),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                  height: ResponsiveHelper.getResponsivePadding(context, 16)),
              _buildExportOption(
                'PDF Document',
                'Export as PDF file',
                Icons.picture_as_pdf,
                Colors.red,
                () async {
                  final scaffoldMessenger = ScaffoldMessenger.of(context);
                  Navigator.pop(context);

                  try {
                    await _exportService.exportToPdf(
                      state.reports,
                      sharePositionOrigin: sharePosition,
                    );
                    scaffoldMessenger.showSnackBar(
                      SnackBar(
                        content: const Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.white),
                            SizedBox(width: 8),
                            Text('PDF exported successfully'),
                          ],
                        ),
                        backgroundColor: Colors.green[700],
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  } catch (e) {
                    scaffoldMessenger.showSnackBar(
                      SnackBar(
                        content: Text('Export failed: ${e.toString()}'),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
              ),
              SizedBox(
                  height: ResponsiveHelper.getResponsivePadding(context, 12)),
              _buildExportOption(
                'CSV Spreadsheet',
                'Export as CSV file',
                Icons.table_chart,
                Colors.green,
                () async {
                  final scaffoldMessenger = ScaffoldMessenger.of(context);
                  Navigator.pop(context);

                  try {
                    await _exportService.exportToCsv(
                      state.reports,
                      sharePositionOrigin: sharePosition,
                    );
                    scaffoldMessenger.showSnackBar(
                      SnackBar(
                        content: const Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.white),
                            SizedBox(width: 8),
                            Text('CSV exported successfully'),
                          ],
                        ),
                        backgroundColor: Colors.green[700],
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  } catch (e) {
                    scaffoldMessenger.showSnackBar(
                      SnackBar(
                        content: Text('Export failed: ${e.toString()}'),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
              ),
              SizedBox(
                  height: ResponsiveHelper.getResponsivePadding(context, 12)),
              _buildExportOption(
                'Excel Spreadsheet',
                'Export as Excel file',
                Icons.grid_on,
                Colors.blue,
                () async {
                  final scaffoldMessenger = ScaffoldMessenger.of(context);
                  Navigator.pop(context);

                  try {
                    await _exportService.exportToExcel(
                      state.reports,
                      sharePositionOrigin: sharePosition,
                    );
                    scaffoldMessenger.showSnackBar(
                      SnackBar(
                        content: const Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.white),
                            SizedBox(width: 8),
                            Text('Excel exported successfully'),
                          ],
                        ),
                        backgroundColor: Colors.green[700],
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  } catch (e) {
                    scaffoldMessenger.showSnackBar(
                      SnackBar(
                        content: Text('Export failed: ${e.toString()}'),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildExportOption(String title, String subtitle, IconData icon,
      Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding:
            EdgeInsets.all(ResponsiveHelper.getResponsivePadding(context, 16)),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(
                  ResponsiveHelper.getResponsivePadding(context, 12)),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon,
                  color: color,
                  size: ResponsiveHelper.getResponsiveIconSize(context, 24)),
            ),
            SizedBox(width: ResponsiveHelper.getResponsivePadding(context, 16)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize:
                          ResponsiveHelper.getResponsiveFontSize(context, 16),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize:
                          ResponsiveHelper.getResponsiveFontSize(context, 12),
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios,
                size: ResponsiveHelper.getResponsiveIconSize(context, 16)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(trialBalanceProvider);
    final connectivityStatus = ref.watch(connectivityProvider);

    // Initialize data fetch on first build
    if (!_hasInitialized) {
      _hasInitialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(trialBalanceProvider.notifier).fetchTrialBalance(
                widget.companyIds,
                widget.startDate,
                widget.endDate,
              );
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Trial Balance Report',
          style: TextStyle(
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 20)),
        ),
        actions: [
          // Connectivity indicator
          connectivityStatus.when(
            data: (hasConnection) => !hasConnection
                ? Padding(
                    padding: EdgeInsets.only(
                        right:
                            ResponsiveHelper.getResponsivePadding(context, 8)),
                    child: Chip(
                      avatar: Icon(Icons.wifi_off,
                          size: ResponsiveHelper.getResponsiveIconSize(
                              context, 14),
                          color: Colors.white),
                      label: Text(
                        'No Connection',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: ResponsiveHelper.getResponsiveFontSize(
                              context, 12),
                        ),
                      ),
                      backgroundColor: Colors.red,
                    ),
                  )
                : const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          if (!state.isLoading && state.reports.isNotEmpty)
            IconButton(
              icon: Icon(Icons.share,
                  size: ResponsiveHelper.getResponsiveIconSize(context, 24)),
              onPressed: _showExportOptions,
              tooltip: 'Export Report',
            ),
        ],
        bottom: state.reports.isNotEmpty
            ? TabBar(
                controller: _tabController,
                labelColor: Colors.green[700],
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.green[700],
                tabs: [
                  Tab(
                    icon: Icon(Icons.table_chart,
                        size: ResponsiveHelper.getResponsiveIconSize(
                            context, 20)),
                    text: 'Table',
                  ),
                  Tab(
                    icon: Icon(Icons.compare,
                        size: ResponsiveHelper.getResponsiveIconSize(
                            context, 20)),
                    text: 'Compare',
                  ),
                ],
              )
            : null,
      ),
      body: state.isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.green[700]),
                  SizedBox(
                      height:
                          ResponsiveHelper.getResponsivePadding(context, 16)),
                  Text(
                    'Loading data...',
                    style: TextStyle(
                        fontSize: ResponsiveHelper.getResponsiveFontSize(
                            context, 14)),
                  ),
                ],
              ),
            )
          : state.error != null
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.all(
                        ResponsiveHelper.getResponsivePadding(context, 24)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.wifi_off,
                          size: ResponsiveHelper.getResponsiveIconSize(
                              context, 64),
                          color: Colors.red[300],
                        ),
                        SizedBox(
                            height: ResponsiveHelper.getResponsivePadding(
                                context, 16)),
                        Text(
                          'Network Not Connected',
                          style: TextStyle(
                            fontSize: ResponsiveHelper.getResponsiveFontSize(
                                context, 18),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                            height: ResponsiveHelper.getResponsivePadding(
                                context, 8)),
                        Text(
                          state.error!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: ResponsiveHelper.getResponsiveFontSize(
                                context, 14),
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(
                            height: ResponsiveHelper.getResponsivePadding(
                                context, 24)),
                        ElevatedButton.icon(
                          onPressed: _refresh,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[700],
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : state.reports.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inbox,
                            size: ResponsiveHelper.getResponsiveIconSize(
                                context, 64),
                            color: Colors.grey[400],
                          ),
                          SizedBox(
                              height: ResponsiveHelper.getResponsivePadding(
                                  context, 16)),
                          Text(
                            'No data available',
                            style: TextStyle(
                              fontSize: ResponsiveHelper.getResponsiveFontSize(
                                  context, 16),
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        RefreshIndicator(
                          onRefresh: _refresh,
                          child: TrialBalanceTable(reports: state.reports),
                        ),
                        ComparisonView(reports: state.reports),
                      ],
                    ),
    );
  }
}
