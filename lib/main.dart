import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'services/database_provider.dart';
import 'screens/dashboard_screen.dart';
import 'screens/tasks_screen.dart';
import 'screens/notes_screen.dart';
import 'screens/settings_screen.dart';
import 'widgets/premium_nav_bar.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ZenFlowApp());
}

class ZenFlowApp extends StatelessWidget {
  const ZenFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DatabaseProvider(),
      child: MaterialApp(
        title: 'ZenFlow Workspace',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark,
        home: const MainNavigationWrapper(),
      ),
    );
  }
}

class MainNavigationWrapper extends StatefulWidget {
  const MainNavigationWrapper({super.key});

  @override
  State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper> {
  int _selectedIndex = 0;

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Lista de telas integradas no IndexedStack
    final List<Widget> screens = [
      DashboardScreen(navigateToTab: _onTabTapped),
      const TasksScreen(),
      const NotesScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      extendBody: true, // Garante que a barra flutuante mostre o conteúdo por trás (efeito blur)
      body: Stack(
        children: [
          // 1. Fundo Espacial com Gradiente
          Container(
            decoration: const BoxDecoration(
              gradient: AppTheme.backgroundGradient,
            ),
          ),
          
          // 2. Luzes de Acento / Efeito Ambient Glow (subtéis bolas coloridas de luz no fundo)
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.neonPurple.withOpacity(0.08),
                    blurRadius: 100,
                    spreadRadius: 50,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            right: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.neonCyan.withOpacity(0.06),
                    blurRadius: 120,
                    spreadRadius: 60,
                  ),
                ],
              ),
            ),
          ),

          // 3. Conteúdo das Telas (IndexedStack mantém o estado de scroll/busca de cada aba)
          IndexedStack(
            index: _selectedIndex,
            children: screens,
          ),
          
          // 4. Barra de Navegação Premium Flutuante no Topo do Scaffold
          Align(
            alignment: Alignment.bottomCenter,
            child: PremiumNavBar(
              selectedIndex: _selectedIndex,
              onTap: _onTabTapped,
            ),
          ),
        ],
      ),
    );
  }
}
