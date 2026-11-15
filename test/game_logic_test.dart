import 'package:flutter_test/flutter_test.dart';
import 'package:nursing_adventure/models/board_tile.dart';
import 'package:nursing_adventure/models/character.dart';
import 'package:nursing_adventure/models/player.dart';

void main() {
  group('Game Board & Coordinates Tests', () {
    test('100 tiles generated correctly in boustrophedon zigzag order', () {
      final tiles = BoardDefinition.generateTiles();
      expect(tiles.length, 100);

      // Square 1: bottom-left
      final tile1 = tiles.firstWhere((t) => t.number == 1);
      expect(tile1.row, 9);
      expect(tile1.col, 0);

      // Square 10: bottom-right
      final tile10 = tiles.firstWhere((t) => t.number == 10);
      expect(tile10.row, 9);
      expect(tile10.col, 9);

      // Square 11: row above square 10 (starts from right)
      final tile11 = tiles.firstWhere((t) => t.number == 11);
      expect(tile11.row, 8);
      expect(tile11.col, 9);

      // Square 20: row above square 1 (ends at left)
      final tile20 = tiles.firstWhere((t) => t.number == 20);
      expect(tile20.row, 8);
      expect(tile20.col, 0);

      // Square 21: row above square 20 (starts from left)
      final tile21 = tiles.firstWhere((t) => t.number == 21);
      expect(tile21.row, 7);
      expect(tile21.col, 0);

      // Square 100: top-left finish square
      final tile100 = tiles.firstWhere((t) => t.number == 100);
      expect(tile100.row, 0);
      expect(tile100.col, 0);
    });

    test('All 7 Golden Rescue Ladders configured properly', () {
      expect(BoardDefinition.ladders.length, 7);

      BoardDefinition.ladders.forEach((start, data) {
        final to = data['to'] as int;
        expect(to > start, true, reason: 'Ladder must move player upwards');
        expect(start >= 1 && start <= 100, true);
        expect(to >= 1 && to <= 100, true);
        expect(data['name'], isNotNull);
        expect(data['tip'], isNotNull);
      });
    });

    test('All 8 Hazard Snakes configured properly', () {
      expect(BoardDefinition.snakes.length, 8);

      BoardDefinition.snakes.forEach((start, data) {
        final to = data['to'] as int;
        expect(to < start, true, reason: 'Snake must move player downwards');
        expect(start >= 1 && start <= 100, true);
        expect(to >= 1 && to <= 100, true);
        expect(data['name'], isNotNull);
        expect(data['tip'], isNotNull);
      });
    });
  });

  group('Player & Character Tests', () {
    test('4 unique anime nursing characters available', () {
      expect(Character.allCharacters.length, 4);

      final lyra = Character.getById(CharacterId.lyra);
      final kai = Character.getById(CharacterId.kai);
      final aria = Character.getById(CharacterId.aria);
      final jin = Character.getById(CharacterId.jin);

      expect(lyra.name, 'Captain Lyra');
      expect(kai.name, 'Kai Swift');
      expect(aria.name, 'Aria Blossom');
      expect(jin.name, 'Doc Jin');

      expect(lyra.stats.containsKey('Care'), true);
      expect(kai.stats.containsKey('Speed'), true);
    });

    test('Player movement and victory detection', () {
      final player = Player(
        id: 1,
        name: 'Nurse Lyra',
        character: Character.getById(CharacterId.lyra),
      );

      expect(player.currentSquare, 1);
      expect(player.hasWon, false);

      player.currentSquare = 50;
      expect(player.hasWon, false);

      player.currentSquare = 100;
      expect(player.hasWon, true);

      player.reset();
      expect(player.currentSquare, 1);
      expect(player.hasWon, false);
    });
  });
}
