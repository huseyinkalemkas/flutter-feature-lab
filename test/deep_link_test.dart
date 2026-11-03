import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deep_link_demo/link_parser.dart';
import 'package:deep_link_demo/main.dart';

void main() {
  test('parametreler Türkçe isimleri korur ve geçersiz adedi sınırlar', () {
    const parameters = PageParameters(
      user: 'Ayşe & Can',
      quantity: 3,
      source: 'yaz kampanyası',
    );
    final uri = Uri.parse(parameters.profileLocation('42'));
    expect(uri.pathSegments.last, 'Ayşe & Can');
    expect(uri.queryParameters['product'], '42');
    final restored = PageParameters.fromUri(uri);
    expect(restored.user, parameters.user);
    expect(restored.quantity, 3);
    expect(restored.source, parameters.source);
    expect(PageParameters.fromUri(Uri.parse('/?quantity=-2')).quantity, 1);
    expect(PageParameters.fromUri(Uri.parse('/?quantity=999')).quantity, 10);
    expect(PageParameters.fromUri(Uri.parse('/?quantity=abc')).quantity, 1);
  });
  testWidgets('üründen profile ve ürüne dönüşte parametreler korunur', (
    tester,
  ) async {
    final router = createRouter(
      initialLocation: const PageParameters(
        user: 'Ayşe Yılmaz',
        quantity: 3,
        source: 'kampanya',
      ).productLocation('42'),
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      MaterialApp.router(routerConfig: router.configuration),
    );
    await tester.pumpAndSettle();
    final button = find.text('Bilgileri profile taşı');
    await tester.scrollUntilVisible(button, 200);
    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(find.text('Ayşe Yılmaz'), findsOneWidget);
    expect(find.text('Taşınan ürün ID: 42'), findsOneWidget);
    expect(find.text('Adet: 3'), findsOneWidget);
    expect(find.text('Kaynak (ref): kampanya'), findsOneWidget);
    final profileUri = Uri.parse(router.currentUrl);
    expect(profileUri.pathSegments.last, 'Ayşe Yılmaz');
    expect(profileUri.queryParameters['quantity'], '3');
    expect(profileUri.queryParameters['product'], '42');
    await tester.tap(find.text('Parametrelerle ürüne dön'));
    await tester.pumpAndSettle();
    expect(find.text('Kullanıcı: Ayşe Yılmaz'), findsOneWidget);
    expect(find.text('Adet: 3'), findsOneWidget);
  });
  test('custom scheme ve HTTPS path/query bilgisini korur', () {
    expect(
      internalLocation('linkdemo://app/products/42?ref=kampanya'),
      '/products/42?ref=kampanya',
    );
    expect(
      internalLocation('https://example.com/profile/ayse'),
      '/profile/ayse',
    );
    expect(internalLocation('/products/73'), '/products/73');
  });
  test('yabancı host ve geçersiz girişleri reddeder', () {
    for (final link in [
      'https://evil.com/products/42',
      'linkdemo://other/products/42',
      '//evil.com/profile/ayse',
      'merhaba',
      'https://example.com:444/',
      'https://user@example.com/',
      '/products/42#fragment',
    ]) {
      expect(internalLocation(link), isNull, reason: link);
    }
  });
  testWidgets('cold start ürün ve query parametresini açar', (tester) async {
    final router = createRouter(initialLocation: '/products/42?ref=kampanya');
    addTearDown(router.dispose);
    await tester.pumpWidget(
      MaterialApp.router(routerConfig: router.configuration),
    );
    await tester.pumpAndSettle();
    expect(find.text('Studio kulaklık'), findsOneWidget);
    expect(find.text('Kaynak (ref): kampanya'), findsOneWidget);
    router.navigatePath('/profile/ayse');
    await tester.pumpAndSettle();
    expect(find.text('ayse'), findsOneWidget);
  });
  testWidgets('bilinmeyen ürün ve route hata ekranına gider', (tester) async {
    final router = createRouter(initialLocation: '/products/999');
    addTearDown(router.dispose);
    await tester.pumpWidget(
      MaterialApp.router(routerConfig: router.configuration),
    );
    await tester.pumpAndSettle();
    expect(find.text('Bu bağlantının hedefi bulunamadı.'), findsOneWidget);
    router.navigatePath('/bilinmeyen');
    await tester.pumpAndSettle();
    expect(find.text('Bu bağlantının hedefi bulunamadı.'), findsOneWidget);
  });
}
