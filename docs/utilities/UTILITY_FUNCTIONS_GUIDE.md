# Utility Functions Comprehensive Guide

Complete documentation for all reusable utility functions with detailed examples and use cases.

## Table of Contents

1. [Phone Utils](#phone-utils)
2. [Format Utils](#format-utils)
3. [Dialog Utils](#dialog-utils)
4. [Common Widgets](#common-widgets)
5. [PDF Utils](#pdf-utils)
6. [Share Utils](#share-utils)
7. [Best Practices](#best-practices)

---

## Phone Utils

**Location**: `lib/utils/phone_utils.dart`

### Purpose
Handle phone number operations including making calls, formatting, and validation.

### Functions

#### `makePhoneCall(String phoneNumber)`
Launches the device's phone dialer with the specified number.

**Parameters:**
- `phoneNumber` (String): Phone number to call (with or without country code)

**Returns:** `Future<bool>` - true if successful, false if failed

**Example:**
```dart
final success = await PhoneUtils.makePhoneCall('+1234567890');
if (!success) {
  // Handle error - phone app not available
}
```

#### `formatPhoneNumber(String phoneNumber)`
Formats a phone number for display with spaces between groups.

**Parameters:**
- `phoneNumber` (String): Raw phone number

**Returns:** `String` - Formatted phone number

**Example:**
```dart
String formatted = PhoneUtils.formatPhoneNumber('+1234567890');
// Output: "+1 234 567 890"

String local = PhoneUtils.formatPhoneNumber('9876543210');
// Output: "987 654 3210"
```

#### `isValidPhoneNumber(String phoneNumber)`
Validates if a string is a valid phone number (basic validation).

**Parameters:**
- `phoneNumber` (String): Phone number to validate

**Returns:** `bool` - true if valid, false otherwise

**Example:**
```dart
bool isValid = PhoneUtils.isValidPhoneNumber('+1234567890'); // true
bool isInvalid = PhoneUtils.isValidPhoneNumber('abc123'); // false
```

### Use Cases
- Contact buttons in customer/manager/salesman cards
- Click-to-call functionality
- Displaying formatted phone numbers in UI
- Validating user input for phone numbers

---

## Format Utils

**Location**: `lib/utils/format_utils.dart`

### Purpose
Centralized formatting for currency, dates, numbers, and other display values.

### Currency Formatting

#### `formatCurrency(double amount, {bool showSymbol = true})`
Formats amount as currency with rupee symbol and thousand separators.

**Example:**
```dart
FormatUtils.formatCurrency(1234.56); // "₹1,234.56"
FormatUtils.formatCurrency(1234.56, showSymbol: false); // "1,234.56"
FormatUtils.formatCurrency(-500.0); // "-₹500.00"
```

#### `formatCurrencyCompact(double amount)`
Formats large amounts with K (thousands), L (lakhs), Cr (crores) abbreviations.

**Example:**
```dart
FormatUtils.formatCurrencyCompact(1500); // "₹1.50K"
FormatUtils.formatCurrencyCompact(150000); // "₹1.50L"
FormatUtils.formatCurrencyCompact(15000000); // "₹1.50Cr"
```

### Date Formatting

#### `formatDate(DateTime date, {String format = 'dd MMM yyyy'})`
Formats date in readable format.

**Example:**
```dart
FormatUtils.formatDate(DateTime(2026, 1, 2)); // "02 Jan 2026"
FormatUtils.formatDate(DateTime.now(), format: 'dd/MM/yyyy'); // "02/01/2026"
```

#### `formatDateWithDay(DateTime date)`
Formats date with day of week.

**Example:**
```dart
FormatUtils.formatDateWithDay(DateTime(2026, 1, 2)); // "Thu, 02 Jan 2026"
```

### Number Formatting

#### `formatQuantity(double quantity, {int decimalPlaces = 2})`
Formats quantity with specified decimal places.

**Example:**
```dart
FormatUtils.formatQuantity(123.456); // "123.46"
FormatUtils.formatQuantity(123.456, decimalPlaces: 0); // "123"
```

#### `formatDecimal(double value, {int decimalPlaces = 2})`
Formats decimal with thousand separators.

**Example:**
```dart
FormatUtils.formatDecimal(1234.567); // "1,234.57"
FormatUtils.formatDecimal(1234.567, decimalPlaces: 3); // "1,234.567"
```

#### `abbreviateNumber(double number)`
Abbreviates large numbers (K, M, B).

**Example:**
```dart
FormatUtils.abbreviateNumber(1500); // "1.5K"
FormatUtils.abbreviateNumber(1500000); // "1.5M"
FormatUtils.abbreviateNumber(1500000000); // "1.5B"
```

### Special Formatting

#### `formatProfitLoss(double amount)`
Returns colored Text widget for profit (green) or loss (red).

**Example:**
```dart
Widget profitWidget = FormatUtils.formatProfitLoss(150.50);
// Shows: "+₹150.50" in green

Widget lossWidget = FormatUtils.formatProfitLoss(-75.25);
// Shows: "-₹75.25" in red
```

### Use Cases
- Displaying amounts in reports and summaries
- Formatting dates in bills and reports
- Showing profit/loss with color indicators
- Compact display of large numbers in charts
- Consistent number formatting across the app

---

## Dialog Utils

**Location**: `lib/utils/dialog_utils.dart`

### Purpose
Standardized dialogs and snackbars for user feedback and confirmations.

### Loading Dialogs

#### `showLoadingDialog(BuildContext context, {String message = 'Loading...'})`
Shows a modal loading dialog.

**Example:**
```dart
DialogUtils.showLoadingDialog(context, message: 'Generating PDF...');
// Perform async operation
await Future.delayed(Duration(seconds: 2));
DialogUtils.hideLoadingDialog(context);
```

#### `hideLoadingDialog(BuildContext context)`
Hides the currently shown loading dialog.

### Snackbars

#### `showSuccessSnackbar(BuildContext context, String message, {Duration duration})`
Shows success message (green).

**Example:**
```dart
DialogUtils.showSuccessSnackbar(context, 'Invoice saved successfully');
```

#### `showErrorSnackbar(BuildContext context, String message, {Duration duration})`
Shows error message (red).

**Example:**
```dart
DialogUtils.showErrorSnackbar(context, 'Failed to connect to server');
```

#### `showInfoSnackbar(BuildContext context, String message, {Duration duration})`
Shows info message (blue).

**Example:**
```dart
DialogUtils.showInfoSnackbar(context, 'No changes detected');
```

### Confirmation Dialogs

#### `showConfirmDialog(BuildContext context, {required String title, required String message, ...})`
Shows confirmation dialog with Yes/No buttons.

**Returns:** `Future<bool?>` - true if confirmed, false if cancelled, null if dismissed

**Example:**
```dart
final confirmed = await DialogUtils.showConfirmDialog(
  context,
  title: 'Delete Bill',
  message: 'Are you sure you want to delete this bill? This action cannot be undone.',
  confirmText: 'Delete',
  cancelText: 'Cancel',
  isDestructive: true,
);

if (confirmed == true) {
  // Proceed with deletion
}
```

### Alert Dialogs

#### `showErrorDialog(BuildContext context, {required String title, required String message})`
Shows error alert dialog.

**Example:**
```dart
await DialogUtils.showErrorDialog(
  context,
  title: 'Connection Error',
  message: 'Unable to reach the server. Please check your internet connection.',
);
```

#### `showSuccessDialog(BuildContext context, {required String title, required String message})`
Shows success alert dialog.

**Example:**
```dart
await DialogUtils.showSuccessDialog(
  context,
  title: 'Success',
  message: 'Invoice generated and shared successfully!',
);
```

### Use Cases
- Loading indicators during API calls
- User feedback for operations
- Confirmation before destructive actions
- Error handling and display
- Success notifications

---

## Common Widgets

**Location**: `lib/widgets/common_widgets.dart`

### Purpose
Reusable UI components for consistent design across the app.

### buildInfoChip

Creates an info chip with label, value, and optional icon.

**Example:**
```dart
CommonWidgets.buildInfoChip(
  label: 'Total',
  value: '₹1,234.56',
  icon: Icons.account_balance_wallet,
  backgroundColor: Colors.blue.shade50,
  textColor: Colors.blue.shade900,
)
```

### buildLabelValueRow

Creates a row with label on left and value on right.

**Example:**
```dart
CommonWidgets.buildLabelValueRow(
  label: 'Bill Number',
  value: 'INV-001',
  labelStyle: TextStyle(fontWeight: FontWeight.bold),
)
```

### buildCardWithTitle

Creates a card container with a title header.

**Example:**
```dart
CommonWidgets.buildCardWithTitle(
  title: 'Customer Details',
  icon: Icons.person,
  child: Column(
    children: [
      Text('John Doe'),
      Text('+1234567890'),
    ],
  ),
)
```

### buildEmptyState

Creates an empty state widget with icon and message.

**Example:**
```dart
CommonWidgets.buildEmptyState(
  icon: Icons.inbox_outlined,
  message: 'No sales found for this date',
  iconSize: 64,
)
```

### Use Cases
- Consistent card layouts
- Status indicators and chips
- Empty states for lists
- Loading indicators
- Section dividers
- Gradient containers for headers

---

## PDF Utils

**Location**: `lib/utils/pdf_utils.dart`

### Purpose
Generate professional PDF invoices with customer details, items, and styling.

### Data Models

#### InvoiceData
Main invoice data container with fields: title, billNumber, billDate, customerName, customerAddress, customerPhone, items, totalQuantity, netAmount, footer.

#### InvoiceItem
Individual item in the invoice with fields: name, quantity, rate, amount.

### Functions

#### `generateInvoicePdf(InvoiceData data)`
Generates a PDF file from invoice data.

**Returns:** `Future<File>` - PDF file

**Example:**
```dart
final data = InvoiceData(
  billNumber: 'INV-001',
  billDate: DateTime.now(),
  customerName: 'John Doe',
  items: [
    InvoiceItem(name: 'Product A', quantity: 2, rate: 100, amount: 200),
  ],
  totalQuantity: 2,
  netAmount: 200,
);

File pdfFile = await PdfUtils.generateInvoicePdf(data);
```

#### `generateAndShareInvoice({required BuildContext context, required InvoiceData data, String? shareText})`
Generates PDF and opens share dialog.

**Returns:** `Future<bool>` - true if successful

**Example:**
```dart
bool success = await PdfUtils.generateAndShareInvoice(
  context: context,
  data: invoiceData,
  shareText: 'Invoice for Bill #INV-001',
);
```

### PDF Features
- Professional header with gradient
- Customer information section
- Items table with headers
- Summary section with totals
- Formatted currency and numbers
- Auto page breaks for large bills

---

## Share Utils

**Location**: `lib/utils/share_utils.dart`

### Purpose
Share files, text, and invoices via various channels (WhatsApp, email, generic share).

### Functions

#### `shareText({required String text, BuildContext? context})`
Shares plain text via share dialog.

#### `shareFile({required String filePath, String? text, BuildContext? context})`
Shares a single file.

#### `shareViaWhatsApp({String? filePath, String? phoneNumber, String? text, BuildContext? context})`
Shares via WhatsApp to specific number (if provided) or general.

**Example:**
```dart
// Share to specific number
bool sent = await ShareUtils.shareViaWhatsApp(
  filePath: '/path/to/invoice.pdf',
  phoneNumber: '+1234567890',
  text: 'Your invoice is attached',
  context: context,
);
```

#### `shareViaEmail({String? subject, String? body, List<String>? recipients, String? filePath})`
Opens email app with pre-filled data.

#### `isWhatsAppInstalled()`
Checks if WhatsApp is installed on the device.

### Use Cases
- Share invoices via WhatsApp to customers
- Send invoices via email
- Share text summaries of bills
- Export and share multiple documents

---

## Best Practices

### 1. Error Handling
Always handle potential errors when using utilities:

```dart
try {
  final success = await PhoneUtils.makePhoneCall(phoneNumber);
  if (!success) {
    DialogUtils.showErrorSnackbar(context, 'Could not open phone dialer');
  }
} catch (e) {
  DialogUtils.showErrorSnackbar(context, 'An error occurred: $e');
}
```

### 2. Context Usage
Capture BuildContext before async operations:

```dart
final scaffoldMessenger = ScaffoldMessenger.of(context);
await someAsyncOperation();
scaffoldMessenger.showSnackBar(...);
```

### 3. Null Safety
Check for null values before using utilities:

```dart
if (customerPhone != null && customerPhone.isNotEmpty) {
  await PhoneUtils.makePhoneCall(customerPhone);
}
```

### 4. Loading States
Show loading indicators for long operations:

```dart
DialogUtils.showLoadingDialog(context, message: 'Generating PDF...');
try {
  await PdfUtils.generateAndShareInvoice(...);
} finally {
  DialogUtils.hideLoadingDialog(context);
}
```

### 5. User Feedback
Always provide feedback for user actions:

```dart
final success = await someOperation();
if (success) {
  DialogUtils.showSuccessSnackbar(context, 'Operation completed');
} else {
  DialogUtils.showErrorSnackbar(context, 'Operation failed');
}
```

---

## Examples

For complete working examples, see [EXAMPLE_USAGE.dart](EXAMPLE_USAGE.dart).

## Contributing

When adding new utility functions:
1. Add function to appropriate utility file
2. Update this guide with documentation
3. Add examples to EXAMPLE_USAGE.dart
4. Update QUICK_REFERENCE.md
5. Test thoroughly before committing
