import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:produtividade_tcc/app.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('ProdutividadeTccApp renders initial Painel tab', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: ProdutividadeTccApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Painel do Dia'), findsOneWidget);
    expect(find.text('Seu Painel do Dia está pronto'), findsOneWidget);
  });
}
