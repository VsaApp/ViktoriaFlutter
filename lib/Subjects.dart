// Define all subjects names...
Map<String, String> subjects = {
  'CH': 'Chemie',
  'PH': 'Physik',
  'MI': 'Mint',
  'DB': 'NW',
  'DP': 'PoWi',
  'PO': 'PoWi',
  'IF': 'Info',
  'S': 'Spanisch',
  'MU': 'Musik',
  'SP': 'Sport',
  'F': 'Französisch',
  'L': 'Latein',
  'ER': 'E. Reli',
  'KR': 'K. Reli',
  'D': 'Deutsch',
  'E': 'Englisch',
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

// Get a subject by short or long name
String getSubject(String name) {
  if (subjects.containsKey(name.toUpperCase())) {
    return subjects[name.toUpperCase()];
  }
  if (subjects.containsValue(name)) {
    return name;
  }
  return name;
}
