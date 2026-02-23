import 'dart:io';

class ConsoleIO {
  static int? readIntOrNull() {
    final String raw = (stdin.readLineSync() ?? '').trim();
    return int.tryParse(raw);
  }

  static int readPositiveInt(String prompt) {
    while (true) {
      stdout.write('$prompt: ');
      final int? value = readIntOrNull();
      if (value != null && value > 0) {
        return value;
      }
      print('1 이상의 숫자를 입력해주세요.');
    }
  }
}
