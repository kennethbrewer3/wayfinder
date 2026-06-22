import 'package:intl/intl.dart';

String formatLocaleCount(int value, String localeName) {
  return NumberFormat.decimalPattern(localeName).format(value);
}
