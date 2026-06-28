// Teste de fumaça de widget básico para o ZenFlowApp.
import 'package:flutter_test/flutter_test.dart';
import 'package:zenflow/main.dart';
import 'package:zenflow/widgets/premium_nav_bar.dart';

void main() {
  testWidgets('Smoke test de carregamento do ZenFlowApp', (WidgetTester tester) async {
    // Constrói o aplicativo e atualiza um frame.
    await tester.pumpWidget(const ZenFlowApp());

    // Verifica se a barra de navegação flutuante está na tela.
    expect(find.byType(PremiumNavBar), findsOneWidget);
  });
}
