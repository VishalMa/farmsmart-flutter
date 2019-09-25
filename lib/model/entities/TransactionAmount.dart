// DART HAS NO DECIMAL NUMBER TYPE!!!!!!!!!
import 'package:decimal/decimal.dart';
import 'package:intl/intl.dart';

class _Strings {
  static const negativeSymbol = "-";
}

class _Constants {
  static const fixedDigits = 2;
  static const thousand = 1000;
}

class TransactionAmount {
  final Decimal _decimal;

  TransactionAmount._(this._decimal);

  factory TransactionAmount(String value, bool forceNegative) {
    final decimal = Decimal.parse(value);
    return TransactionAmount._(forceNegative ? -decimal : decimal);
  }

  String toString({bool allowNegative = false}) {
    final formatter = _getNumberFormat(Intl.getCurrentLocale());
    final absDecimal = _decimal.isNegative ? -_decimal : _decimal;
    final prefix =
        (_decimal.isNegative && allowNegative) ? _Strings.negativeSymbol : "";
    return prefix +
        formatter
            .format(absDecimal.toDouble())
            .replaceAll(formatter.currencyName, "");
  }

  NumberFormat _getNumberFormat(String locale) {
    int compareToResult = _decimal.abs().compareTo(Decimal.fromInt(_Constants.thousand));
    if(compareToResult.isNegative) {
      return NumberFormat.currency(locale: locale);
    } else {
      return NumberFormat.compactCurrency(locale: locale);
    }
  }

  bool isSale() {
    return !isCost();
  }

  bool isCost() {
    return _decimal.isNegative;
  }

  String rawString() {
    return _decimal.toStringAsFixed(_Constants.fixedDigits);
  }

  TransactionAmount operator +(covariant TransactionAmount other) =>
      TransactionAmount._(_decimal + other._decimal);
}
