import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/deep_link.dart';

void main() {
  test('reconoce los enlaces de la carta web', () {
    expect(parseCartaPath('/carta/100001'), (code: '100001', cocktailId: null));
    expect(parseCartaPath('/carta/100001/'), (code: '100001', cocktailId: null));
    expect(parseCartaPath('/carta/100001/c/16'), (code: '100001', cocktailId: 16));
    expect(parseCartaPath('/app/'), isNull);
    expect(parseCartaPath('/carta/abc'), isNull);
    expect(parseCartaPath('/'), isNull);
  });
}
