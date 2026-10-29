import 'models/enums.dart';

/// Formatação de datas, horas e coordenadas no padrão do produto (pt-BR, 24 h, vírgula decimal).
abstract final class IcFormat {
  static String _pad2(int n) => n.toString().padLeft(2, '0');

  /// `12/06`
  static String dayMonth(DateTime d) => '${_pad2(d.day)}/${_pad2(d.month)}';

  /// `12/06/2025`
  static String date(DateTime d) => '${dayMonth(d)}/${d.year}';

  /// `08:07`
  static String time(DateTime d) => '${_pad2(d.hour)}:${_pad2(d.minute)}';

  /// `12/06 08:07`
  static String dayMonthTime(DateTime d) => '${dayMonth(d)} ${time(d)}';

  /// `1 h 34 min` / `44 min`
  static String duration(Duration d) {
    final h = d.inHours, m = d.inMinutes % 60;
    return h == 0 ? '$m min' : '$h h ${_pad2(m)} min';
  }

  /// `-23,5613 -46,6559`
  static String coordinates(double lat, double lng) =>
      '${lat.toStringAsFixed(4).replaceAll('.', ',')} ${lng.toStringAsFixed(4).replaceAll('.', ',')}';

  /// `90,5%`
  static String percent(double v) => '${v.toStringAsFixed(1).replaceAll('.', ',')}%';

  /// "Hoje", "Amanhã", "Ontem" ou `12/06` em relação a [now], seguido do turno: `Hoje · manhã`.
  static String scheduled(DateTime date, Shift shift, {DateTime? now}) {
    final today = DateTime((now ?? DateTime.now()).year, (now ?? DateTime.now()).month, (now ?? DateTime.now()).day);
    final diff = DateTime(date.year, date.month, date.day).difference(today).inDays;
    final day = switch (diff) {
      0 => 'Hoje',
      1 => 'Amanhã',
      -1 => 'Ontem',
      _ => dayMonth(date),
    };
    return '$day · ${shift.label.toLowerCase()}';
  }
}
