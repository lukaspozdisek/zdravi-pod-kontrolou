// lib/l10n/app_strings.dart
const kSupportedLocales = ['cs', 'en'];

const Map<String, Map<String, String>> kStrings = {
  'cs': {
    // App
    'app.title': 'GLP-1 TRACKER',
    'app.subtitle': 'ULTRA GOLD + MENSTRUAL CYCLE + ACTION',

    // Bloom (woman)
    'bloom.confirmed': 'POTVRZENO',
    'bloom.tomorrow': 'ZÍTRA',
    'bloom.apply': 'APLIKOVAT',
    'bloom.confirmButton': 'Potvrdit',
    'bloom.dayLabel': '{day}. DEN ({phase})',

    // Mood labels
    'mood.rest': 'ODPOČÍVEJ',
    'mood.calm': 'KLIDNĚJI',
    'mood.balance': 'ROVNOVÁHA',
    'mood.bloom': 'ROZKVÉTÁŠ',
    'mood.shine': 'ZÁŘÍŠ',
    'mood.status': 'STATUS',

    // Cycle phases
    'cycle.menstruation': 'MENSTRUACE',
    'cycle.follicular': 'FOLIKULÁRNÍ',
    'cycle.ovulation': 'OVULACE',
    'cycle.luteal': 'LUTEÁLNÍ',

    // Demo UI
    'demo.woman': '🌸 Žena',
    'demo.man': '⚡ Muž',
    'demo.protein': 'Protein: {g}g',
    'demo.water': 'Voda: {n}',
    'demo.injection': 'Injekce za: {d} dny (nastav 0 pro test tlačítka)',
    'demo.cycle': 'Cyklus: {d}. den',
    'demo.mood': 'Nálada (1-5):',
  },

  'en': {
    // App
    'app.title': 'GLP-1 TRACKER',
    'app.subtitle': 'ULTRA GOLD + MENSTRUAL CYCLE + ACTION',

    // Bloom (woman)
    'bloom.confirmed': 'CONFIRMED',
    'bloom.tomorrow': 'TOMORROW',
    'bloom.apply': 'APPLY',
    'bloom.confirmButton': 'Confirm',
    'bloom.dayLabel': 'DAY {day} ({phase})',

    // Mood labels
    'mood.rest': 'REST',
    'mood.calm': 'CALMER',
    'mood.balance': 'BALANCE',
    'mood.bloom': 'BLOOMING',
    'mood.shine': 'SHINING',
    'mood.status': 'STATUS',

    // Cycle phases
    'cycle.menstruation': 'MENSTRUATION',
    'cycle.follicular': 'FOLLICULAR',
    'cycle.ovulation': 'OVULATION',
    'cycle.luteal': 'LUTEAL',

    // Demo UI
    'demo.woman': '🌸 Woman',
    'demo.man': '⚡ Man',
    'demo.protein': 'Protein: {g}g',
    'demo.water': 'Water: {n}',
    'demo.injection': 'Injection in: {d} days (set 0 to test button)',
    'demo.cycle': 'Cycle day: {d}',
    'demo.mood': 'Mood (1-5):',
  },
};