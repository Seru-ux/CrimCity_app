enum AttributeType { strength, dexterity, endurance, charisma }

extension AttributeTypeX on AttributeType {
  String get dbValue => switch (this) {
    AttributeType.strength => 'strength',
    AttributeType.dexterity => 'dexterity',
    AttributeType.endurance => 'endurance',
    AttributeType.charisma => 'charisma',
  };

  String get label => switch (this) {
    AttributeType.strength => 'Stärke',
    AttributeType.dexterity => 'Geschicklichkeit',
    AttributeType.endurance => 'Ausdauer',
    AttributeType.charisma => 'Charisma',
  };

  String get shortLabel => switch (this) {
    AttributeType.strength => 'STR',
    AttributeType.dexterity => 'DEX',
    AttributeType.endurance => 'END',
    AttributeType.charisma => 'CHA',
  };

  static AttributeType fromDb(String s) => switch (s) {
    'strength' => AttributeType.strength,
    'dexterity' => AttributeType.dexterity,
    'endurance' => AttributeType.endurance,
    'charisma' => AttributeType.charisma,
    _ => throw ArgumentError('Unknown attribute: $s'),
  };
}
