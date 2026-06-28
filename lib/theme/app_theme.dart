import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Cores Principais (Paleta Dark Neon Premium)
  static const Color spaceBlack = Color(0xFF090A0F);
  static const Color deepPurple = Color(0xFF140D26);
  static const Color darkBackground = Color(0xFF0C0E14);
  
  // Cores de Acento
  static const Color neonPurple = Color(0xFF9D4EDD);
  static const Color neonCyan = Color(0xFF00F5D4);
  static const Color neonPink = Color(0xFFFF007F);
  static const Color neonGold = Color(0xFFFFB703);
  static const Color neonGreen = Color(0xFF39FF14);
  
  // Tons de Cinza e Texto
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF9EAEB8);
  static const Color textMuted = Color(0xFF62727B);

  // Gradiente de Fundo Principal
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0E0B16), // Roxo ultra escuro
      Color(0xFF05050A), // Quase preto
      Color(0xFF0D1B2A), // Azul meia-noite
    ],
    stops: [0.0, 0.5, 1.0],
  );

  // Gradiente de Acento para Botões e Destaques
  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      neonPurple,
      Color(0xFF7B2CBF),
    ],
  );

  // Gradiente Cyan-Pink para Destaques Especiais
  static const LinearGradient neonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      neonCyan,
      neonPurple,
    ],
  );

  // Efeito de Vidro Fosco (Glassmorphism Decoration)
  static BoxDecoration glassDecoration({
    double blur = 16.0,
    double opacity = 0.08,
    double borderRadius = 20.0,
    Color borderColor = Colors.white24,
  }) {
    return BoxDecoration(
      color: Colors.white.withOpacity(opacity),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: borderColor,
        width: 1.0,
      ),
    );
  }

  // Definição do ThemeData do Flutter
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: neonPurple,
      scaffoldBackgroundColor: Colors.transparent, // Permite visualizar o gradiente de fundo
      colorScheme: const ColorScheme.dark(
        primary: neonPurple,
        secondary: neonCyan,
        tertiary: neonPink,
        surface: Colors.white10,
        error: neonPink,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.outfit(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          letterSpacing: -0.5,
        ),
        titleLarge: GoogleFonts.outfit(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleMedium: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        bodyLarge: GoogleFonts.outfit(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: textPrimary,
        ),
        bodyMedium: GoogleFonts.outfit(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: textSecondary,
        ),
        bodySmall: GoogleFonts.outfit(
          fontSize: 12,
          fontWeight: FontWeight.w300,
          color: textMuted,
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white.withOpacity(0.06),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Colors.white12, width: 1),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: neonPurple,
        foregroundColor: Colors.white,
        elevation: 6,
        shape: CircleBorder(),
      ),
    );
  }
}
