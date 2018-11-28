Map<String, String> subjects = {
  'CH': 'Chemie',
  'PH': 'Physik',
  'MI': 'Mint',
  'DB': 'NW',
  'DP': 'PoWi',
  'PO': 'PoWi',
  'IF': 'Info',
  'S8': 'Spanisch',
  'S1': 'Spanisch',
  'MU': 'Musik',
  'SP': 'Sport',
  'F6': 'Französisch',
  'L6': 'Latein',
  'ER': 'E. Reli',
  'KR': 'K. Reli',
  'D': 'Deutsch',
  'E5': 'Englisch',
  'M': 'Mathe',
  'PK': 'Politik',
  'BI': 'Bio',
  'UC': 'U. Chor',
  'MC': 'M. Chor',
  'EK': 'Erdkunde',
  'KU': 'Kunst',
  'KW': 'Kunst',
  'SW': 'SoWi',
  'PL': 'Philosophie',
  'GE': 'Geschichte',
  'VM': 'Vertiefung Mathe',
  'VD': 'Vertiefung Deutsch',
  'VE': 'Vertiefung Englisch',
  'FF': 'Französisch Förder',
  'LF': 'Latein Förder',
  'PJ': 'Projektkurs'
};

String getSubject(String name) {
  if (subjects.containsKey(name.toUpperCase())) {
    return subjects[name.toUpperCase()];
  }
  if (subjects.containsValue(name)) {
    return name;
  }
  return name;
}
