# Utility Functions - Example Usage

Working examples of all utility functions with practical code snippets you can copy and adapt.

## Table of Contents

1. [Phone Utils Examples](#phone-utils-examples)
2. [Format Utils Examples](#format-utils-examples)
3. [Dialog Utils Examples](#dialog-utils-examples)
4. [PDF Utils Examples](#pdf-utils-examples)
5. [Share Utils Examples](#share-utils-examples)
6. [Common Widgets Examples](#common-widgets-examples)
7. [Complete Screen Example](#complete-screen-example)

---

## Phone Utils Examples

### Example 1: Make a phone call with error handling

```dart
Future<void> callCustomerExample(
  BuildContext context,
  String? phoneNumber,
) async {
  if (phoneNumber == null || phoneNumber.isEmpty) {
    DialogUtils.showErrorSnackbar(context, 'Phone number not available');
    return;
  }

  try {
    final success = await PhoneUtils.makePhoneCall(phoneNumber);
    if (!success) {
      if (context.mounted) {
        DialogUtils.showErrorSnackbar(
          context,
          'Could not open phone dialer',
        );
      }
    }
  } catch (e) {
    if (context.mounted) {
      DialogUtils.showErrorSnackbar(
        context,
        'Error making call: $e',
      );
    }
  }
}
```

### Example 2: Display formatted phone number in a card

```dart
Widget buildContactCard(String name, String phoneNumber) {
  return Card(
    child: ListTile(
      leading: const Icon(Icons.person),
      title: Text(name),
      subtitle: Text(PhoneUtils.formatPhoneNumber(phoneNumber)),
      trailing: IconButton(
        icon: const Icon(Icons.phone),
        onPressed: () async {
          await PhoneUtils.makePhoneCall(phoneNumber);
        },
      ),
    ),
  );
}
```

### Example 3: Validate phone input

```dart
String? validatePhoneInput(String? value) {
  if (value == null || value.isEmpty) {
    return 'Phone number is required';
  }
  if (!PhoneUtils.isValidPhoneNumber(value)) {
    return 'Please enter a valid phone number';
  }
  return null;
}
```

---

## Format Utils Examples

### Example 1: Format amounts in a sales summary card

```dart
Widget buildSalesSummaryCard({
  required double totalSales,
  required double profit,
  required int itemsSold,
}) {
  return Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sales Summary',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Sales:'),
              Text(
                FormatUtils.formatCurrency(totalSales),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Profit:'),
              FormatUtils.formatProfitLoss(profit),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Items Sold:'),
              Text(FormatUtils.formatQuantity(itemsSold.toDouble())),
            ],
          ),
        ],
      ),
    ),
  );
}
```

### Example 2: Format date range display

```dart
Widget buildDateRangeDisplay(DateTime startDate, DateTime endDate) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.blue.shade50,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.calendar_today, size: 16),
        const SizedBox(width: 8),
        Text(FormatUtils.formatDate(startDate)),
        const Text(' - '),
        Text(FormatUtils.formatDate(endDate)),
      ],
    ),
  );
}
```

### Example 3: Display compact numbers in charts

```dart
Widget buildChartLabel(double value) {
  return Text(
    FormatUtils.formatCurrencyCompact(value),
    style: const TextStyle(fontSize: 12),
  );
}
```

### Example 4: Format trial balance amounts

```dart
Widget buildTrialBalanceRow(
  String accountName,
  double debit,
  double credit,
) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Expanded(flex: 2, child: Text(accountName)),
        Expanded(
          child: Text(
            debit > 0 ? FormatUtils.formatCurrency(debit) : '-',
            textAlign: TextAlign.right,
          ),
        ),
        Expanded(
          child: Text(
            credit > 0 ? FormatUtils.formatCurrency(credit) : '-',
            textAlign: TextAlign.right,
          ),
        ),
      ],
    ),
  );
}
```

---

## Dialog Utils Examples

### Example 1: Loading dialog during API call

```dart
Future<void> fetchDataWithLoading(BuildContext context) async {
  DialogUtils.showLoadingDialog(context, message: 'Fetching data...');

  try {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    if (context.mounted) {
      DialogUtils.hideLoadingDialog(context);
      DialogUtils.showSuccessSnackbar(context, 'Data loaded successfully');
    }
  } catch (e) {
    if (context.mounted) {
      DialogUtils.hideLoadingDialog(context);
      DialogUtils.showErrorSnackbar(context, 'Failed to load data: $e');
    }
  }
}
```

### Example 2: Confirm before deleting

```dart
Future<void> deleteItemWithConfirmation(
  BuildContext context,
  String itemName,
) async {
  final confirmed = await DialogUtils.showConfirmDialog(
    context,
    title: 'Delete Item',
    message: 'Are you sure you want to delete "$itemName"? '
        'This action cannot be undone.',
    confirmText: 'Delete',
    cancelText: 'Cancel',
    isDestructive: true,
  );

  if (confirmed == true) {
    // Proceed with deletion
    DialogUtils.showLoadingDialog(context, message: 'Deleting...');

    try {
      // Simulate deletion
      await Future.delayed(const Duration(seconds: 1));

      if (context.mounted) {
        DialogUtils.hideLoadingDialog(context);
        DialogUtils.showSuccessSnackbar(context, 'Item deleted successfully');
      }
    } catch (e) {
      if (context.mounted) {
        DialogUtils.hideLoadingDialog(context);
        DialogUtils.showErrorSnackbar(context, 'Failed to delete: $e');
      }
    }
  }
}
```

### Example 3: Show error with details

```dart
Future<void> handleApiError(
  BuildContext context,
  String operation,
  dynamic error,
) async {
  String errorMessage = 'An unexpected error occurred';

  if (error.toString().contains('No internet')) {
    errorMessage = 'No internet connection. Please check your network.';
  } else if (error.toString().contains('401')) {
    errorMessage = 'Session expired. Please login again.';
  } else if (error.toString().contains('500')) {
    errorMessage = 'Server error. Please try again later.';
  }

  await DialogUtils.showErrorDialog(
    context,
    title: 'Error: $operation',
    message: errorMessage,
  );
}
```

### Example 4: Success feedback with auto-dismiss

```dart
void showQuickSuccess(BuildContext context, String message) {
  DialogUtils.showSuccessSnackbar(
    context,
    message,
    duration: const Duration(seconds: 2),
  );
}
```

---

## PDF Utils Examples

### Example 1: Generate invoice from sales detail

```dart
Future<void> generateInvoiceFromSale(
  BuildContext context, {
  required String billNumber,
  required DateTime billDate,
  required String customerName,
  required String customerAddress,
  required String customerPhone,
  required List<Map<String, dynamic>> items,
  required double totalAmount,
}) async {
  DialogUtils.showLoadingDialog(context, message: 'Generating invoice...');

  try {
    // Prepare invoice data
    final invoiceData = InvoiceData(
      billNumber: billNumber,
      billDate: billDate,
      customerName: customerName,
      customerAddress: customerAddress,
      customerPhone: customerPhone,
      items: items
          .map(
            (item) => InvoiceItem(
              name: item['name'] ?? '',
              quantity: (item['quantity'] ?? 0).toDouble(),
              rate: (item['rate'] ?? 0).toDouble(),
              amount: (item['amount'] ?? 0).toDouble(),
            ),
          )
          .toList(),
      totalQuantity: items.fold(
        0,
        (sum, item) => sum + ((item['quantity'] ?? 0) as num).toDouble(),
      ),
      netAmount: totalAmount,
    );

    // Generate and share
    if (context.mounted) {
      DialogUtils.hideLoadingDialog(context);

      final success = await PdfUtils.generateAndShareInvoice(
        context: context,
        data: invoiceData,
        shareText: 'Invoice for Bill #$billNumber',
      );

      if (success && context.mounted) {
        DialogUtils.showSuccessSnackbar(
          context,
          'Invoice generated successfully',
        );
      }
    }
  } catch (e) {
    if (context.mounted) {
      DialogUtils.hideLoadingDialog(context);
      DialogUtils.showErrorSnackbar(
        context,
        'Failed to generate invoice: $e',
      );
    }
  }
}
```

### Example 2: Generate PDF without sharing (for saving)

```dart
Future<String?> saveInvoicePdf(InvoiceData data) async {
  try {
    final file = await PdfUtils.generateInvoicePdf(data);
    return file.path;
  } catch (e) {
    print('Error saving PDF: $e');
    return null;
  }
}
```

### Example 3: Generate invoice with custom footer

```dart
InvoiceData createInvoiceWithFooter({
  required String billNumber,
  required DateTime billDate,
  required String customerName,
  required List<InvoiceItem> items,
  required double netAmount,
}) {
  return InvoiceData(
    billNumber: billNumber,
    billDate: billDate,
    customerName: customerName,
    items: items,
    totalQuantity: items.fold(0, (sum, item) => sum + item.quantity),
    netAmount: netAmount,
    footer: 'Thank you for your business!\n'
        'For support: contact@example.com | +91-1234567890',
  );
}
```

---

## Share Utils Examples

### Example 1: Share invoice via WhatsApp

```dart
Future<void> shareInvoiceViaWhatsApp(
  BuildContext context, {
  required String pdfPath,
  required String customerPhone,
  required String billNumber,
}) async {
  // Check WhatsApp availability
  final isInstalled = await ShareUtils.isWhatsAppInstalled();

  if (!isInstalled) {
    if (context.mounted) {
      DialogUtils.showErrorSnackbar(
        context,
        'WhatsApp is not installed on this device',
      );
    }
    return;
  }

  DialogUtils.showLoadingDialog(context, message: 'Opening WhatsApp...');

  try {
    final success = await ShareUtils.shareViaWhatsApp(
      filePath: pdfPath,
      phoneNumber: customerPhone,
      text: 'Hi! Here is your invoice for Bill #$billNumber. Thank you!',
      context: context,
    );

    if (context.mounted) {
      DialogUtils.hideLoadingDialog(context);

      if (success) {
        DialogUtils.showSuccessSnackbar(
          context,
          'Invoice shared via WhatsApp',
        );
      } else {
        DialogUtils.showInfoSnackbar(
          context,
          'WhatsApp opened. Please send the invoice manually.',
        );
      }
    }
  } catch (e) {
    if (context.mounted) {
      DialogUtils.hideLoadingDialog(context);
      DialogUtils.showErrorSnackbar(
        context,
        'Failed to share via WhatsApp: $e',
      );
    }
  }
}
```

### Example 2: Share via email with recipients

```dart
Future<void> emailInvoice({
  required String pdfPath,
  required String billNumber,
  required String customerEmail,
  required double amount,
}) async {
  await ShareUtils.shareViaEmail(
    subject: 'Invoice #$billNumber',
    body: 'Dear Customer,\n\n'
        'Please find attached your invoice for the amount of '
        '${FormatUtils.formatCurrency(amount)}.\n\n'
        'Thank you for your business!\n\n'
        'Best regards,\n'
        'Your Company Name',
    recipients: [customerEmail],
    filePath: pdfPath,
  );
}
```

### Example 3: Share invoice as text

```dart
Future<void> shareInvoiceAsText(
  BuildContext context, {
  required String billNumber,
  required DateTime billDate,
  required String customerName,
  required List<Map<String, dynamic>> items,
  required double totalAmount,
}) async {
  await ShareUtils.shareInvoiceAsText(
    billNumber: billNumber,
    billDate: billDate,
    customerName: customerName,
    items: items,
    totalAmount: totalAmount,
    context: context,
  );
}
```

### Example 4: Generic file sharing

```dart
Future<void> shareFile(
  BuildContext context,
  String filePath,
  String description,
) async {
  try {
    await ShareUtils.shareFile(
      filePath: filePath,
      text: description,
      context: context,
    );
  } catch (e) {
    if (context.mounted) {
      DialogUtils.showErrorSnackbar(
        context,
        'Failed to share file: $e',
      );
    }
  }
}
```

---

## Common Widgets Examples

### Example 1: Build info cards for dashboard

```dart
Widget buildDashboardCards({
  required double totalSales,
  required int totalOrders,
  required double profit,
}) {
  return Row(
    children: [
      Expanded(
        child: CommonWidgets.buildInfoChip(
          label: 'Sales',
          value: FormatUtils.formatCurrencyCompact(totalSales),
          icon: Icons.shopping_cart,
          backgroundColor: Colors.blue.shade50,
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: CommonWidgets.buildInfoChip(
          label: 'Orders',
          value: totalOrders.toString(),
          icon: Icons.receipt,
          backgroundColor: Colors.green.shade50,
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: CommonWidgets.buildInfoChip(
          label: 'Profit',
          value: FormatUtils.formatCurrencyCompact(profit),
          icon: Icons.trending_up,
          backgroundColor: Colors.orange.shade50,
        ),
      ),
    ],
  );
}
```

### Example 2: Customer details section

```dart
Widget buildCustomerDetailsSection({
  required String name,
  required String phone,
  required String address,
}) {
  return CommonWidgets.buildCardWithTitle(
    title: 'Customer Details',
    icon: Icons.person,
    child: Column(
      children: [
        CommonWidgets.buildLabelValueRow(
          label: 'Name',
          value: name,
        ),
        const SizedBox(height: 8),
        CommonWidgets.buildLabelValueRow(
          label: 'Phone',
          value: PhoneUtils.formatPhoneNumber(phone),
        ),
        const SizedBox(height: 8),
        CommonWidgets.buildLabelValueRow(
          label: 'Address',
          value: address,
        ),
      ],
    ),
  );
}
```

### Example 3: Empty state for lists

```dart
Widget buildEmptyListState(String entityName) {
  return Center(
    child: CommonWidgets.buildEmptyState(
      icon: Icons.inbox_outlined,
      message: 'No $entityName found',
    ),
  );
}
```

### Example 4: Loading state for async operations

```dart
Widget buildLoadingState(String message) {
  return Center(
    child: CommonWidgets.buildLoadingWidget(message: message),
  );
}
```

---

## Complete Screen Example

### Sales Detail Screen with All Utilities

```dart
class SalesDetailScreenExample extends StatelessWidget {
  final String billNumber;
  final DateTime billDate;
  final String customerName;
  final String customerPhone;
  final String customerAddress;
  final List<Map<String, dynamic>> items;
  final double totalAmount;

  const SalesDetailScreenExample({
    super.key,
    required this.billNumber,
    required this.billDate,
    required this.customerName,
    required this.customerPhone,
    required this.customerAddress,
    required this.items,
    required this.totalAmount,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bill #$billNumber'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareInvoice(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date display
            _buildDateRangeDisplay(billDate, billDate),
            const SizedBox(height: 16),

            // Customer details
            _buildCustomerDetailsSection(
              name: customerName,
              phone: customerPhone,
              address: customerAddress,
            ),
            const SizedBox(height: 16),

            // Items list
            CommonWidgets.buildCardWithTitle(
              title: 'Items',
              icon: Icons.list,
              child: Column(
                children: items.map((item) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(item['name'] ?? ''),
                        ),
                        Expanded(
                          child: Text(
                            'Qty: ${FormatUtils.formatQuantity(item['quantity'])}',
                          ),
                        ),
                        Expanded(
                          child: Text(
                            FormatUtils.formatCurrency(item['amount']),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Total
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Amount',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      FormatUtils.formatCurrency(totalAmount),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _callCustomer(context),
                icon: const Icon(Icons.phone),
                label: const Text('Call Customer'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _shareViaWhatsApp(context),
                icon: const Icon(Icons.message),
                label: const Text('WhatsApp'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _shareInvoice(BuildContext context) async {
    await generateInvoiceFromSale(
      context,
      billNumber: billNumber,
      billDate: billDate,
      customerName: customerName,
      customerAddress: customerAddress,
      customerPhone: customerPhone,
      items: items,
      totalAmount: totalAmount,
    );
  }

  Future<void> _callCustomer(BuildContext context) async {
    await callCustomerExample(context, customerPhone);
  }

  Future<void> _shareViaWhatsApp(BuildContext context) async {
    // First generate PDF
    DialogUtils.showLoadingDialog(context, message: 'Generating invoice...');

    try {
      final invoiceData = InvoiceData(
        billNumber: billNumber,
        billDate: billDate,
        customerName: customerName,
        customerAddress: customerAddress,
        customerPhone: customerPhone,
        items: items
            .map(
              (item) => InvoiceItem(
                name: item['name'] ?? '',
                quantity: (item['quantity'] ?? 0).toDouble(),
                rate: (item['rate'] ?? 0).toDouble(),
                amount: (item['amount'] ?? 0).toDouble(),
              ),
            )
            .toList(),
        totalQuantity: items.fold(
          0,
          (sum, item) => sum + ((item['quantity'] ?? 0) as num).toDouble(),
        ),
        netAmount: totalAmount,
      );

      final file = await PdfUtils.generateInvoicePdf(invoiceData);

      if (context.mounted) {
        DialogUtils.hideLoadingDialog(context);

        await shareInvoiceViaWhatsApp(
          context,
          pdfPath: file.path,
          customerPhone: customerPhone,
          billNumber: billNumber,
        );
      }
    } catch (e) {
      if (context.mounted) {
        DialogUtils.hideLoadingDialog(context);
        DialogUtils.showErrorSnackbar(context, 'Failed to generate PDF: $e');
      }
    }
  }

  // Helper widgets used in the screen
  Widget _buildDateRangeDisplay(DateTime startDate, DateTime endDate) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.calendar_today, size: 16),
          const SizedBox(width: 8),
          Text(FormatUtils.formatDate(startDate)),
          const Text(' - '),
          Text(FormatUtils.formatDate(endDate)),
        ],
      ),
    );
  }

  Widget _buildCustomerDetailsSection({
    required String name,
    required String phone,
    required String address,
  }) {
    return CommonWidgets.buildCardWithTitle(
      title: 'Customer Details',
      icon: Icons.person,
      child: Column(
        children: [
          CommonWidgets.buildLabelValueRow(label: 'Name', value: name),
          const SizedBox(height: 8),
          CommonWidgets.buildLabelValueRow(
            label: 'Phone',
            value: PhoneUtils.formatPhoneNumber(phone),
          ),
          const SizedBox(height: 8),
          CommonWidgets.buildLabelValueRow(label: 'Address', value: address),
        ],
      ),
    );
  }
}
```

---

## Quick Tips

### ✅ Best Practices

1. **Error Handling**: Always wrap utility calls in try-catch blocks
2. **Context Safety**: Check `context.mounted` before using context after async operations
3. **Loading States**: Show loading dialogs for operations that take time
4. **User Feedback**: Provide clear success/error messages for all actions
5. **Null Safety**: Check for null values before passing to utilities

### 🚀 Common Patterns

**Pattern 1: Async operation with loading and feedback**
```dart
DialogUtils.showLoadingDialog(context);
try {
  await someOperation();
  if (context.mounted) {
    DialogUtils.hideLoadingDialog(context);
    DialogUtils.showSuccessSnackbar(context, 'Success!');
  }
} catch (e) {
  if (context.mounted) {
    DialogUtils.hideLoadingDialog(context);
    DialogUtils.showErrorSnackbar(context, 'Error: $e');
  }
}
```

**Pattern 2: Confirmation before destructive action**
```dart
final confirmed = await DialogUtils.showConfirmDialog(
  context,
  title: 'Confirm Delete',
  message: 'Are you sure?',
  isDestructive: true,
);

if (confirmed == true) {
  // Proceed with action
}
```

**Pattern 3: Generate and share document**
```dart
DialogUtils.showLoadingDialog(context, message: 'Generating...');
try {
  final file = await generateDocument();
  if (context.mounted) {
    DialogUtils.hideLoadingDialog(context);
    await ShareUtils.shareFile(filePath: file.path, context: context);
  }
} catch (e) {
  if (context.mounted) {
    DialogUtils.hideLoadingDialog(context);
    DialogUtils.showErrorSnackbar(context, 'Failed: $e');
  }
}
```

---

## Related Documentation

- [QUICK_REFERENCE.md](QUICK_REFERENCE.md) - Quick lookup guide
- [UTILITY_FUNCTIONS_GUIDE.md](UTILITY_FUNCTIONS_GUIDE.md) - Comprehensive documentation
- [../README.md](../../README.md) - Main project README
