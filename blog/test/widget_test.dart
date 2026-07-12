import 'package:blog/resources/app_strings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('app strings expose configured application metadata', () {
    expect(Strings.appName, isNotEmpty);
    expect(Strings.roleAdmin, 'admin');
  });
}
