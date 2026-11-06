import 'attribute_type.dart';

enum CharacterClass {
  hustler('Hustler', 'hustler'),
  burglar('Einbrecher', 'burglar'),
  hitman('Killer', 'hitman'),
  pimp('Zuhälter', 'pimp'),
  drugDealer('Drogendealer', 'drug_dealer');

  final String label;
  final String dbValue;

  const CharacterClass(this.label, this.dbValue);

  String get description {
    switch (this) {
      case CharacterClass.hustler:
        return 'Allrounder. Kleiner Bonus auf alle Einnahmen.';
      case CharacterClass.burglar:
        return 'Heist-Spezialist. Hohe Geschicklichkeit, mehr Beute.';
      case CharacterClass.hitman:
        return 'Kriegs-Spezialist. Hohe Stärke, mehr Kampfkraft.';
      case CharacterClass.pimp:
        return 'Sozial-Spezialist. Hohes Charisma, mehr Respekt.';
      case CharacterClass.drugDealer:
        return 'Einnahmen-Spezialist. Hohe Ausdauer, passive Einnahmen.';
    }
  }

  int get difficultyStars {
    switch (this) {
      case CharacterClass.hustler:
        return 1;
      case CharacterClass.drugDealer:
        return 2;
      case CharacterClass.burglar:
        return 3;
      case CharacterClass.pimp:
        return 4;
      case CharacterClass.hitman:
        return 5;
    }
  }

  Map<AttributeType, int> get startingAttributes {
    switch (this) {
      case CharacterClass.hustler:
        return {
          AttributeType.strength: 2,
          AttributeType.dexterity: 3,
          AttributeType.endurance: 3,
          AttributeType.charisma: 4,
        };
      case CharacterClass.burglar:
        return {
          AttributeType.strength: 1,
          AttributeType.dexterity: 6,
          AttributeType.endurance: 3,
          AttributeType.charisma: 2,
        };
      case CharacterClass.hitman:
        return {
          AttributeType.strength: 6,
          AttributeType.dexterity: 3,
          AttributeType.endurance: 2,
          AttributeType.charisma: 1,
        };
      case CharacterClass.pimp:
        return {
          AttributeType.strength: 2,
          AttributeType.dexterity: 1,
          AttributeType.endurance: 3,
          AttributeType.charisma: 6,
        };
      case CharacterClass.drugDealer:
        return {
          AttributeType.strength: 1,
          AttributeType.dexterity: 2,
          AttributeType.endurance: 6,
          AttributeType.charisma: 3,
        };
    }
  }

  static CharacterClass? fromDb(String? s) {
    if (s == null) return null;
    for (var c in CharacterClass.values) {
      if (c.dbValue == s) return c;
    }
    return null;
  }
}
