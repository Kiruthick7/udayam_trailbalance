# Utility Functions Quick Reference

Quick lookup guide for all reusable utility functions in the app.

## 📞 Phone Utils (`lib/utils/phone_utils.dart`)

```dart
// Make a phone call
await PhoneUtils.makePhoneCall('+1234567890');

// Format phone number
String formatted = PhoneUtils.formatPhoneNumber('+1234567890');
// Returns: "+1 234 567 890"

// Validate phone number
bool isValid = PhoneUtils.isValidPhoneNumber('+1234567890');
```

## 💰 Format Utils (`lib/utils/format_utils.dart`)

```dart
// Currency formatting
String amount = FormatUtils.formatCurrency(1234.56);
// Returns: "₹1,234.56"

String compact = FormatUtils.formatCurrencyCompact(1500000);
// Returns: "₹15.00L"

// Date formatting
String date = FormatUtils.formatDate(DateTime.now());
// Returns: "02 Jan 2026"

String dateWithDay = FormatUtils.formatDateWithDay(DateTime.now());
// Returns: "Thu, 02 Jan 2026"

// Number formatting
String qty = FormatUtils.formatQuantity(123.45);
// Returns: "123.45"

String decimal = FormatUtils.formatDecimal(1234.567, decimalPlaces: 2);
// Returns: "1,234.57"

// Profit/Loss styling
Widget profitLoss = FormatUtils.formatProfitLoss(150.50);
// Returns colored Text widget

// Abbreviate numbers
String abbr = FormatUtils.abbreviateNumber(1500000);
// Returns: "1.5M"
```

## 🔔 Dialog Utils (`lib/utils/dialog_utils.dart`)

```dart
// Loading dialog
DialogUtils.showLoadingDialog(context, message: 'Processing...');
DialogUtils.hideLoadingDialog(context);

// Snackbars
DialogUtils.showSuccessSnackbar(context, 'Saved successfully');
DialogUtils.showErrorSnackbar(context, 'Something went wrong');
DialogUtils.showInfoSnackbar(context, 'Information message');

// Confirm dialog
bool? confirmed = await DialogUtils.showConfirmDialog(
  context,
  title: 'Delete Item',
  message: 'Are you sure?',
  confirmText: 'Delete',
  cancelText: 'Cancel',
);

// Error dialog
await DialogUtils.showErrorDialog(
  context,
  title: 'Error',
  message: 'Something went wrong',
);

// Success dialog
await DialogUtils.showSuccessDialog(
  context,
  title: 'Success',
  message: 'Operation completed',
);
```

## 🎨 Common Widgets (`lib/widgets/common_widgets.dart`)

```dart
// Info chip
Widget chip = CommonWidgets.buildInfoChip(
  label: 'Status',
  value: 'Active',
  icon: Icons.check_circle,
);

// Label-value row
Widget row = CommonWidgets.buildLabelValueRow(
  label: 'Total',
  value: '₹1,234.56',
);

// Card with title
Widget card = CommonWidgets.buildCardWithTitle(
  title: 'Summary',
  child: Text('Content'),
);

// Empty state
Widget empty = CommonWidgets.buildEmptyState(
  icon: Icons.inbox,
  message: 'No items found',
);

// Loading widget
Widget loading = CommonWidgets.buildLoadingWidget(
  message: 'Loading...',
);

// Gradient container
Widget gradient = CommonWidgets.buildGradientContainer(
  colors: [Colors.blue, Colors.purple],
  child: Text('Content'),
);

// Divider with text
Widget divider = CommonWidgets.buildDividerWithText(
  text: 'OR',
);
```

## 📄 PDF Utils (`lib/utils/pdf_utils.dart`)

```dart
// Generate and share invoice PDF
final data = InvoiceData(
  billNumber: 'INV-001',
  billDate: DateTime.now(),
  customerName: 'John Doe',
  customerAddress: '123 Main St',
  customerPhone: '+1234567890',
  items: [
    InvoiceItem(
      name: 'Product A',
      quantity: 2,
      rate: 100.0,
      amount: 200.0,
    ),
  ],
  totalQuantity: 2,
  netAmount: 200.0,
);

bool success = await PdfUtils.generateAndShareInvoice(
  context: context,
  data: data,
  shareText: 'Invoice for Bill #INV-001',
);

// Generate PDF only (without sharing)
File pdfFile = await PdfUtils.generateInvoicePdf(data);
```

## 📤 Share Utils (`lib/utils/share_utils.dart`)

```dart
// Share text
await ShareUtils.shareText(
  text: 'Check this out!',
  context: context,
);

// Share file
await ShareUtils.shareFile(
  filePath: '/path/to/file.pdf',
  text: 'Here is the document',
  context: context,
);

// Share via WhatsApp
bool success = await ShareUtils.shareViaWhatsApp(
  filePath: '/path/to/file.pdf',
  phoneNumber: '+1234567890',
  text: 'Invoice attached',
  context: context,
);

// Share invoice as text
await ShareUtils.shareInvoiceAsText(
  billNumber: 'INV-001',
  billDate: DateTime.now(),
  customerName: 'John Doe',
  items: [
    {'name': 'Product A', 'qty': 2, 'rate': 100.0, 'amount': 200.0}
  ],
  totalAmount: 200.0,
  context: context,
);

// Share via email
await ShareUtils.shareViaEmail(
  subject: 'Invoice',
  body: 'Please find attached invoice',
  recipients: ['customer@example.com'],
  filePath: '/path/to/invoice.pdf',
);

// Check WhatsApp availability
bool installed = await ShareUtils.isWhatsAppInstalled();
```

## 📚 More Information

For detailed documentation with examples and use cases, see:
- [UTILITY_FUNCTIONS_GUIDE.md](UTILITY_FUNCTIONS_GUIDE.md) - Comprehensive guide
- [EXAMPLE_USAGE.dart](EXAMPLE_USAGE.dart) - Working code examples
