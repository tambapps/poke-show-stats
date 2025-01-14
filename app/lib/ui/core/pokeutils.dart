
class Natures {
  static const hardy = "Hardy";
  static const lonely = "Lonely";
  static const brave = "Brave";
  static const adamant = "Adamant";
  static const naughty = "Naughty";
  static const bold = "Bold";
  static const docile = "Docile";
  static const relaxed = "Relaxed";
  static const impish = "Impish";
  static const lax = "Lax";
  static const timid = "Timid";
  static const hasty = "Hasty";
  static const serious = "Serious";
  static const jolly = "Jolly";
  static const naive = "Naive";
  static const modest = "Modest";
  static const mild = "Mild";
  static const quiet = "Quiet";
  static const bashful = "Bashful";
  static const calm = "Calm";
  static const gentle = "Gentle";
  static const sassy = "Sassy";
  static const quirky = "Quirky";
  static const rash = "Rash";
  static const careful = "Careful";
  static const storm = "Storm";
  
  static const bonus = 1;
  static const neutral = 0;
  static const malus = -1;

  static int attackBonus(String nature) {
    switch (nature) {
      case lonely:
      case brave:
      case adamant:
      case naughty:
        return bonus;
      case bold:
      case timid:
      case modest:
      case calm:
        return malus;
      default:
        return neutral;
    }
  }

  static int defenseBonus(String nature) {
    switch (nature) {
      case bold:
      case impish:
      case lax:
      case relaxed:
        return bonus;
      case lonely:
      case mild:
      case gentle:
      case hardy:
        return malus;
      default:
        return neutral;
    }
  }

  static int specialAttackBonus(String nature) {
    switch (nature) {
      case quiet:
      case rash:
      case mild:
      case modest:
        return bonus;
      case adamant:
      case impish:
      case careful:
      case jolly:
        return malus;
      default:
        return neutral;
    }
  }

  static int specialDefenseBonus(String nature) {
    switch (nature) {
      case sassy:
      case careful:
      case gentle:
      case calm:
        return bonus;
      case naughty:
      case lax:
      case rash:
      case naive:
        return malus;
      default:
        return neutral;
    }
  }

  static int speedBonus(String nature) {
    switch (nature) {
      case timid:
      case hasty:
      case jolly:
      case naive:
        return bonus;
      case brave:
      case relaxed:
      case quiet:
      case sassy:
        return malus;
      default:
        return neutral;
    }
  }
}

