import 'package:flutter/material.dart';

abstract class AppColors {
  AppColors._();

  // Background & Surfaces
  static const Color background = Color(0xFF0A1128); // Azul Marinho Profundo
  static const Color surface = Color(0xFF151E3D); // Azul Escuro (Cards/Modais)
  static const Color surfaceLight = Color(0xFF2A365C); // Azul mais claro

  // Brand & Accent Colors
  static const Color primary = Color(0xFFFF6D00); // Laranja Vibrante
  static const Color onPrimary = Colors.white; // Texto/Ícones sobre a cor primária
  static const Color accent = Color(0xFF38BDF8); // Azul Claro (destaques/gradientes)

  // Typography / Text Colors
  static const Color textPrimary = Colors.white; // Branco puro
  static const Color textSecondary = Color(0xFF94A3B8); // Cinza azulado (suave)

  // Feedback & Status Colors
  static const Color error = Color(0xFFEF4444); // Vermelho Erro
  static const Color success = Color(0xFF22C55E); // Verde Sucesso
  static const Color warning = Color(0xFFF59E0B); // Amarelo Alerta
}