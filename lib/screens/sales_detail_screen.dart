import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
              'Bill #${widget.billno}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            if (state.customerName != null && state.customerName!.isNotEmpty)
              Text(
                state.customerName!,
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
              )
            else
              Text(
                FormatUtils.formatDate(widget.billdate),
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
              ),
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
              onPressed: () async {
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                final success =
                    await PhoneUtils.makePhoneCall(state.customerPhone!);
                if (!success) {
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text('Could not launch phone dialer'),
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              tooltip: 'Send PDF via WhatsApp',
              onPressed: () => _generateAndSharePDF(state),
            ),
          ],
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? _ErrorView(error: state.error!, onRetry: _refresh)
              : state.details.isEmpty
                  ? const Center(child: Text('No details available'))
                  : _buildContent(state, screenWidth),
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
      onTap: () async {
        final success = await PhoneUtils.makePhoneCall(phone);
        if (!success && mounted) {
          DialogUtils.showErrorSnackbar(
              context, 'Could not launch phone dialer');
        }
      },
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.details.length,
              separatorBuilder: (context, index) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child:
                    Divider(height: 1, thickness: 1, color: Colors.grey[200]),
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
              flex: 2,
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
