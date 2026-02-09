import 'lib/utils/normalizers.dart';

void main() {
  final sports = [
    'Gym',
    'Soccer',
    'Running',
    'Tennis',
    'Other',
    'None',
    'Muay Thai'
  ];

  print('Normalizing sports:');
  for (final sport in sports) {
    print('$sport -> ${normalizeToSpanish(sport, 'sport')}');
  }

  print('\nNormalizing diet difficulties:');
  print('Other -> ${normalizeToSpanish('Other', 'diet_difficulties')}');
}
