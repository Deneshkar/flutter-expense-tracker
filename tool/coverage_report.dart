// ignore_for_file: avoid_print, prefer_interpolation_to_compose_strings
import 'dart:io';

void main() {
  final file = File('coverage/lcov.info');
  if (!file.existsSync()) {
    print('coverage/lcov.info not found');
    return;
  }

  final lines = file.readAsLinesSync();
  String currentFile = '';
  int totalFound = 0;
  int totalHit = 0;

  print('----------------------------------------------------------------------');
  print('FILE                                       | HIT / TOTAL | COVERAGE');
  print('----------------------------------------------------------------------');

  for (final line in lines) {
    if (line.startsWith('SF:')) {
      currentFile = line.substring(3).replaceAll(r'd:\Flutter Task\', '').replaceAll(r'd:/Flutter Task/', '');
    } else if (line.startsWith('LF:')) {
      final found = int.parse(line.substring(3));
      totalFound += found;
    } else if (line.startsWith('LH:')) {
      final hit = int.parse(line.substring(3));
      totalHit += hit;
      // Get the corresponding LF from recent entries or track it
    }
  }

  // Let's do a structured parse
  int fileFound = 0;
  int fileHit = 0;
  totalFound = 0;
  totalHit = 0;

  for (final line in lines) {
    if (line.startsWith('SF:')) {
      currentFile = line.substring(3).replaceAll(r'd:\Flutter Task\', '').replaceAll(r'd:/Flutter Task/', '');
    } else if (line.startsWith('LF:')) {
      fileFound = int.parse(line.substring(3));
    } else if (line.startsWith('LH:')) {
      fileHit = int.parse(line.substring(3));
      totalFound += fileFound;
      totalHit += fileHit;
      final pct = fileFound > 0 ? (fileHit / fileFound * 100).toStringAsFixed(1) : '0.0';
      final fileName = currentFile.padRight(42);
      final stats = '$fileHit / $fileFound'.padLeft(11);
      print('$fileName | $stats | $pct%');
    }
  }

  print('----------------------------------------------------------------------');
  final totalPct = totalFound > 0 ? (totalHit / totalFound * 100).toStringAsFixed(1) : '0.0';
  print('TOTAL                                      | ${(totalHit.toString() + ' / ' + totalFound.toString()).padLeft(11)} | $totalPct%');
  print('----------------------------------------------------------------------');
}
