import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/sales_detail_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/phone_utils.dart';
import '../utils/format_utils.dart';
import '../utils/dialog_utils.dart';
import '../utils/pdf_utils.dart';
import '../widgets/common_widgets.dart';

class SalesDetailScreen extends ConsumerStatefulWidget {
  final DateTime billdate;
  final int billno;
  final String cuscod;

  const SalesDetailScreen({
    super.key,
    required this.billdate,
    required this.billno,
    required this.cuscod,
  });

  @override
  ConsumerState<SalesDetailScreen> createState() => _SalesDetailScreenState();
}

class _SalesDetailScreenState extends ConsumerState<SalesDetailScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(salesDetailProvider.notifier).fetchSalesDetails(
            billdate: widget.billdate,
            billno: widget.billno,
            cuscod: widget.cuscod,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(salesDetailProvider);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Bill #${widget.billno} - ${FormatUtils.formatDate(widget.billdate)}',
              style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 12),
            ),
            Text(
              state.customerName!,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            )
          ],
        ),
        backgroundColor: const Color(0xFF667eea),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (state.customerPhone != null &&
              state.customerPhone!.isNotEmpty) ...[
            IconButton(
              icon: const Icon(Icons.phone),
              tooltip: 'Call Customer',
              onPressed: () => _handlePhoneCall(state.customerPhone!),
            ),
          ],
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Send PDF via WhatsApp',
            onPressed: () => _generateAndSharePDF(state),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: screenWidth > 600 ? 1200 : double.infinity,
          ),
          child: state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : state.error != null
                  ? _ErrorView(error: state.error!, onRetry: _refresh)
                  : state.details.isEmpty
                      ? const Center(child: Text('No details available'))
                      : _buildContent(
                          state, screenWidth > 600 ? 1200 : screenWidth),
        ),
      ),
    );
  }

  Widget _buildContent(SalesDetailState state, double screenWidth) {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Contact Numbers Card
            _buildContactCard(state),

            const SizedBox(height: 16),

            // Items Card
            _buildItemsCard(state),

            const SizedBox(height: 16),

            // Summary Card
            _buildSummaryCard(state),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard(SalesDetailState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (state.managerName != null &&
              state.managerPhone != null &&
              state.managerName!.isNotEmpty &&
              state.managerPhone!.isNotEmpty)
            _buildContactAvatar(state.managerName!, state.managerPhone!),
          if (state.salesmanName != null &&
              state.salesmanPhone != null &&
              state.salesmanName!.isNotEmpty &&
              state.salesmanPhone!.isNotEmpty)
            _buildContactAvatar(state.salesmanName!, state.salesmanPhone!),
        ],
      ),
    );
  }

  Widget _buildContactAvatar(String name, String phone) {
    return InkWell(
      onTap: () => _handlePhoneCall(phone),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.phone,
              size: 16,
              color: Colors.blue[700],
            ),
            const SizedBox(width: 6),
            Text(
              name,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.blue[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsCard(SalesDetailState state) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.details.length,
              separatorBuilder: (context, index) => Divider(
                height: 16,
                thickness: 1,
                color: Colors.grey[200],
              ),
              itemBuilder: (context, index) {
                final item = state.details[index];
                return _buildItemRow(item);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemRow(item) {
    final authState = ref.watch(authProvider);
    final userRole = authState.user?['role'] as String?;
    final isAdmin = userRole == 'admin';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Item name
        Text(
          item.name,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Colors.grey[900],
          ),
        ),
        const SizedBox(height: 8),
        // Single row with all details
        Row(
          children: [
            // Qty
            Expanded(
              flex: 2,
              child: CommonWidgets.buildInfoChip(
                label: 'Qty',
                value: FormatUtils.formatQuantity(item.qty),
                color: Colors.blue,
              ),
            ),
            // const SizedBox(width: 4),
            // Rate
            Expanded(
              flex: 4,
              child: CommonWidgets.buildInfoChip(
                label: 'Rate',
                value: FormatUtils.formatDecimal(item.rate),
                color: Colors.grey,
              ),
            ),
            const SizedBox(width: 4),
            // Value (Qty * Rate)
            Expanded(
              flex: 3,
              child: CommonWidgets.buildInfoChip(
                label: 'Value',
                value: FormatUtils.formatQuantity(item.qty * item.rate),
                color: Colors.purple,
              ),
            ),
            if (isAdmin) ...[
              const SizedBox(width: 4),
              // Cost
              Expanded(
                flex: 2,
                child: _buildInfoChip(
                  'Cost',
                  item.prcost.toStringAsFixed(2),
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 4),
              // Profit/Loss
              Expanded(
                flex: 3,
                child: _buildInfoChip(
                  item.isProfitable ? 'Profit' : 'Loss',
                  item.itemProfit.abs().toStringAsFixed(2),
                  item.isProfitable ? Colors.green : Colors.red,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildInfoChip(String label, String value, MaterialColor color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color[700],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(SalesDetailState state) {
    final authState = ref.watch(authProvider);
    final userRole = authState.user?['role'] as String?;
    final isAdmin = userRole == 'admin';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'Items: ',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                    Text(
                      '${state.details.length}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      'Quantity: ',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                    Text(
                      state.totalQuantity.toStringAsFixed(0),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Divider(height: 1, thickness: 1, color: Colors.grey[300]),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Net Amount',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                Text(
                  state.formattedNetAmount,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
              ],
            ),
            if (isAdmin) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    state.isProfitable ? 'Total Profit' : 'Total Loss',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  Text(
                    state.formattedProfitLoss,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: state.isProfitable
                          ? Colors.green[700]
                          : Colors.red[700],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Handle phone call with support for multiple numbers
  Future<void> _handlePhoneCall(String phoneString) async {
    final numbers = PhoneUtils.extractPhoneNumbers(phoneString);

    if (numbers.isEmpty) {
      if (mounted) {
        DialogUtils.showErrorSnackbar(
          context,
          'No valid phone number found',
        );
      }
      return;
    }

    if (numbers.length == 1) {
      // Single number - show confirmation dialog with call button
      if (!mounted) return;

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.phone,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Call',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '+91 ${numbers[0].substring(0, 5)} ${numbers[0].substring(5)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context, false),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(color: Colors.grey[400]!),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context, true),
                        icon: const Icon(Icons.phone),
                        label: const Text(
                          'Call',
                          style: TextStyle(fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

      if (confirmed == true) {
        final success = await PhoneUtils.makePhoneCall(phoneString);
        if (!success && mounted) {
          DialogUtils.showErrorSnackbar(
            context,
            'Could not launch phone dialer',
          );
        }
      }
    } else {
      // Multiple numbers - show enhanced selection dialog
      if (!mounted) return;

      final selectedNumber = await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 8,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  Colors.grey[50]!,
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF667eea)
                                  .withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.phone_in_talk_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Select Number',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.5,
                              ),
                            ),
                            Text(
                              '${numbers.length} phone numbers found',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Phone numbers list
                  Container(
                    constraints: const BoxConstraints(maxHeight: 320),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: ListView.separated(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemCount: numbers.length,
                        separatorBuilder: (context, index) => Divider(
                          height: 1,
                          thickness: 1,
                          color: Colors.grey[200],
                          indent: 70,
                        ),
                        itemBuilder: (context, index) {
                          final number = numbers[index];
                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => Navigator.pop(context, number),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                  horizontal: 16,
                                ),
                                child: Row(
                                  children: [
                                    // Number details
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 6),
                                          Text(
                                            '+91$number',
                                            style: const TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: 0.5,
                                              height: 1.2,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.visible,
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Arrow indicator
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[100],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.phone_forwarded,
                                        size: 18,
                                        color: Color(0xFF667eea),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Cancel button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, size: 20),
                      label: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        side: BorderSide(color: Colors.grey[300]!, width: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      if (selectedNumber != null) {
        final Uri phoneUri = Uri(scheme: 'tel', path: '+91$selectedNumber');
        final success = await launchUrl(phoneUri);
        if (!success && mounted) {
          DialogUtils.showErrorSnackbar(
            context,
            'Could not launch phone dialer',
          );
        }
      }
    }
  }

  Future<void> _generateAndSharePDF(SalesDetailState state) async {
    try {
      // Show loading dialog
      if (mounted) {
        DialogUtils.showLoadingDialog(context, message: 'Generating PDF...');
      }

      // Prepare invoice data
      final invoiceData = InvoiceData(
        title: 'INVOICE',
        billNumber: widget.billno.toString(),
        billDate: widget.billdate,
        customerName: state.customerName,
        customerAddress: state.customerAddress,
        customerPhone: state.customerPhone,
        items: state.details
            .map((item) => InvoiceItem(
                  name: item.name,
                  quantity: item.qty,
                  rate: item.rate,
                  amount: item.tprice,
                ))
            .toList(),
        totalQuantity: state.totalQuantity,
        netAmount: state.netAmount,
        footer: 'Thank you for your business!',
      );

      // Generate and share PDF
      final success = await PdfUtils.generateAndShareInvoice(
        context: context,
        data: invoiceData,
      );

      // Close loading dialog
      if (mounted) {
        DialogUtils.hideLoadingDialog(context);
      }

      if (mounted) {
        if (success) {
          DialogUtils.showSuccessSnackbar(
            context,
            'PDF generated successfully!',
          );
        } else {
          DialogUtils.showErrorSnackbar(
            context,
            'Failed to generate PDF',
          );
        }
      }
    } catch (e) {
      // Close loading dialog if open
      if (mounted) {
        DialogUtils.hideLoadingDialog(context);
        DialogUtils.showErrorSnackbar(
          context,
          'Failed to generate PDF: $e',
        );
      }
    }
  }

  Future<void> _refresh() async {
    await ref.read(salesDetailProvider.notifier).fetchSalesDetails(
          billdate: widget.billdate,
          billno: widget.billno,
          cuscod: widget.cuscod,
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
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.red[50],
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red[400],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF667eea),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
