import 'package:intl/intl.dart';

final DateFormat _documentDateFormat = DateFormat('d MMM yyyy', 'en_US');

/// Renders a document date such as `17 Oct 2026`.
String formatDocumentDate(DateTime date) => _documentDateFormat.format(date);
