import 'package:flutter_test/flutter_test.dart';
import 'package:fasting_tracker_app/core/utils/date_utils.dart';

void main() {
  group('AppDateUtils', () {
    // ─── formatDuration ───────────────────────────────────────────────────────

    group('formatDuration', () {
      test('duração zero retorna 00:00:00', () {
        expect(AppDateUtils.formatDuration(Duration.zero), '00:00:00');
      });

      test('1 hora retorna 01:00:00', () {
        expect(
          AppDateUtils.formatDuration(const Duration(hours: 1)),
          '01:00:00',
        );
      });

      test('1h30m45s retorna 01:30:45', () {
        expect(
          AppDateUtils.formatDuration(
            const Duration(hours: 1, minutes: 30, seconds: 45),
          ),
          '01:30:45',
        );
      });

      test('horas > 9 não são truncadas', () {
        expect(
          AppDateUtils.formatDuration(const Duration(hours: 16)),
          '16:00:00',
        );
      });

      test('duração negativa exibe prefixo "-"', () {
        final result = AppDateUtils.formatDuration(
          const Duration(hours: -1, minutes: -30),
        );
        expect(result, startsWith('-'));
        expect(result, contains('01:30:00'));
      });

      test('apenas segundos formata corretamente', () {
        expect(
          AppDateUtils.formatDuration(const Duration(seconds: 59)),
          '00:00:59',
        );
      });

      test('minutos e segundos sem horas completos', () {
        expect(
          AppDateUtils.formatDuration(
            const Duration(minutes: 5, seconds: 3),
          ),
          '00:05:03',
        );
      });
    });

    // ─── formatDate ───────────────────────────────────────────────────────────

    group('formatDate', () {
      final date = DateTime(2024, 3, 5);

      test('formato padrão dd/MM/yyyy', () {
        expect(AppDateUtils.formatDate(date), '05/03/2024');
      });

      test('formato personalizado yyyy-MM-dd', () {
        expect(
          AppDateUtils.formatDate(date, format: 'yyyy-MM-dd'),
          '2024-03-05',
        );
      });

      test('formato E retorna abreviação do dia da semana', () {
        // 2024-03-05 é uma terça-feira
        final dayStr = AppDateUtils.formatDate(date, format: 'E');
        expect(dayStr, isNotEmpty);
      });

      test('data com dia e mês de um dígito usa zero à esquerda', () {
        final d = DateTime(2024, 1, 9);
        expect(AppDateUtils.formatDate(d), '09/01/2024');
      });
    });

    // ─── formatTime ───────────────────────────────────────────────────────────

    group('formatTime', () {
      test('formata hora e minuto corretamente', () {
        final date = DateTime(2024, 1, 1, 14, 35);
        expect(AppDateUtils.formatTime(date), '14:35');
      });

      test('meia-noite retorna 00:00', () {
        final date = DateTime(2024, 1, 1, 0, 0);
        expect(AppDateUtils.formatTime(date), '00:00');
      });

      test('horário com zero a esquerda nos minutos', () {
        final date = DateTime(2024, 1, 1, 9, 5);
        expect(AppDateUtils.formatTime(date), '09:05');
      });
    });

    // ─── isToday ──────────────────────────────────────────────────────────────

    group('isToday', () {
      test('retorna true para DateTime.now()', () {
        expect(AppDateUtils.isToday(DateTime.now()), isTrue);
      });

      test('retorna true para hoje com horário diferente', () {
        final now = DateTime.now();
        final sameDay = DateTime(now.year, now.month, now.day, 0, 0, 0);
        expect(AppDateUtils.isToday(sameDay), isTrue);
      });

      test('retorna false para ontem', () {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        expect(AppDateUtils.isToday(yesterday), isFalse);
      });

      test('retorna false para amanhã', () {
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        expect(AppDateUtils.isToday(tomorrow), isFalse);
      });

      test('retorna false para data com mesmo dia mas mês diferente', () {
        final now = DateTime.now();
        final differentMonth = DateTime(now.year, now.month - 1, now.day);
        expect(AppDateUtils.isToday(differentMonth), isFalse);
      });
    });
  });
}
