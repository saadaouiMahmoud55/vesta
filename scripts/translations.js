#!/usr/bin/env node
// Translations (VST-70): one master file generates the texts of both apps.
// Usage (from the repo root):
//   node scripts/translations.js build        write the Flutter and React Native files
//   node scripts/translations.js check        check the master file and the generated files
//   node scripts/translations.js --self-test  check that the script itself still works
// Master file: docs/translations.csv. How to use it: docs/translations.md.

const fs = require('fs');
const path = require('path');

const ROOT = path.resolve(__dirname, '..');
const MASTER = path.join(ROOT, 'docs', 'translations.csv');
const ARB_DIR = path.join(ROOT, 'flutter-app', 'lib', 'l10n');
const RN_DIR = path.join(ROOT, 'react-native-app', 'src', 'core', 'translations');
const LANGS = ['en', 'fr', 'ar'];
const HEADER = ['key', 'en', 'fr', 'ar', 'screen', 'note'];

// ---------- keys ----------

const KEY_RE = /^[a-z][a-z0-9]*(?:[._][a-z0-9]+)*$/;

// auth.login.button -> authLoginButton (a Dart name, also used by React Native)
function toCamel(key) {
  const parts = key.split(/[._]/);
  return parts[0] + parts.slice(1).map((w) => w.charAt(0).toUpperCase() + w.slice(1)).join('');
}

// authLoginButton -> auth.login.button (used once, to create the master file)
function toDotted(camel) {
  const words = camel.match(/[A-Z]?[a-z0-9]+|[A-Z]+(?![a-z])/g) || [camel];
  return words.map((w) => w.toLowerCase()).join('.');
}

// ---------- CSV ----------

function detectDelimiter(text) {
  const first = text.split('\n')[0];
  return first.includes(';') && !first.includes(',') ? ';' : ',';
}

// Reads quoted fields, doubled quotes and line breaks inside quotes.
function parseCsv(input) {
  const text = input.replace(/^\uFEFF/, '').replace(/\r\n?/g, '\n');
  const delimiter = detectDelimiter(text);
  const rows = [];
  let row = [];
  let field = '';
  let quoted = false;
  for (let i = 0; i < text.length; i++) {
    const c = text[i];
    if (quoted) {
      if (c === '"' && text[i + 1] === '"') {
        field += '"';
        i++;
      } else if (c === '"') {
        quoted = false;
      } else {
        field += c;
      }
    } else if (c === '"') {
      quoted = true;
    } else if (c === delimiter) {
      row.push(field);
      field = '';
    } else if (c === '\n') {
      row.push(field);
      rows.push(row);
      row = [];
      field = '';
    } else {
      field += c;
    }
  }
  if (field !== '' || row.length > 0) {
    row.push(field);
    rows.push(row);
  }
  return rows.filter((r) => !(r.length === 1 && r[0].trim() === ''));
}

function csvField(value) {
  const needsQuotes = /[",\n\r]/.test(value) || value !== value.trim();
  return needsQuotes ? '"' + value.replace(/"/g, '""') + '"' : value;
}

function serializeCsv(rows) {
  return '\uFEFF' + rows.map((r) => r.map(csvField).join(',')).join('\r\n') + '\r\n';
}

function readRows(text) {
  const table = parseCsv(text);
  const header = (table[0] || []).map((h) => h.trim().toLowerCase());
  const errors = [];
  for (const col of ['key', 'en', 'fr', 'ar']) {
    if (!header.includes(col)) errors.push(`Header: the column "${col}" is missing`);
  }
  const idx = (name) => header.indexOf(name);
  const rows = table.slice(1).map((cells, i) => {
    const get = (name) => (idx(name) >= 0 ? (cells[idx(name)] || '').replace(/\r?\n/g, '\n') : '');
    return {
      line: i + 2,
      key: get('key').trim(),
      en: get('en'),
      fr: get('fr'),
      ar: get('ar'),
      screen: get('screen').trim(),
      note: get('note').trim(),
    };
  });
  return { rows, errors };
}

// ---------- placeholders ----------

const PH_RE = /\{([a-zA-Z][a-zA-Z0-9]*)(?::(string|int|double|num))?\}/g;
const ARB_TYPES = { string: 'String', int: 'int', double: 'double', num: 'num' };

function placeholdersOf(text) {
  return [...text.matchAll(PH_RE)].map((m) => ({ name: m[1], type: m[2] || 'string' }));
}

function hasStrayBrace(text) {
  return /[{}]/.test(text.replace(PH_RE, ''));
}

// Master text -> text for the Flutter ARB file: {count:int} -> {count}
function arbText(text) {
  return text.replace(PH_RE, '{$1}');
}

// Master text -> text for i18next: {count:int} -> {{count}}
function rnText(text) {
  return text.replace(PH_RE, '{{$1}}');
}

// ---------- checks ----------

const ARABIC_LETTER = /[\u0600-\u06FF]/;
const ARABIC_DIGIT = /[\u0660-\u0669\u06F0-\u06F9]/;
const ALLOWED_LATIN = /Vesta|TND|WhatsApp|m²|km|OpenStreetMap/g;

function validate(rows) {
  const errors = [];
  const warnings = [];
  const seen = new Map();
  const seenCamel = new Map();
  for (const row of rows) {
    const where = `docs/translations.csv line ${row.line} (${row.key || 'no key'})`;
    const err = (msg) => errors.push(`${where}: ${msg}`);
    const warn = (msg) => warnings.push(`${where}: ${msg}`);

    if (!KEY_RE.test(row.key)) {
      err('the key must be lowercase English with dots, for example auth.login.button');
      continue;
    }
    if (seen.has(row.key)) err(`duplicate key (first on line ${seen.get(row.key)})`);
    seen.set(row.key, row.line);
    const camel = toCamel(row.key);
    if (seenCamel.has(camel) && seenCamel.get(camel).key !== row.key) {
      err(`gives the same app key "${camel}" as ${seenCamel.get(camel).key}`);
    }
    seenCamel.set(camel, row);

    for (const lang of LANGS) {
      const text = row[lang];
      if (text.trim() === '') {
        err(`the ${lang} text is empty`);
        continue;
      }
      if (text !== text.trim()) err(`the ${lang} text starts or ends with a space`);
      if (hasStrayBrace(text)) err(`the ${lang} text has a { or } that is not a placeholder like {name}`);
      if (ARABIC_DIGIT.test(text)) err(`the ${lang} text has Arabic-Indic digits: use 0 to 9`);
    }
    if (errors.length && errors[errors.length - 1].startsWith(where)) continue;

    const names = (t) => placeholdersOf(t).map((p) => p.name).sort().join(',');
    if (names(row.en) !== names(row.fr) || names(row.en) !== names(row.ar)) {
      err('the placeholders are not the same in en, fr and ar');
    }
    const sameOk = /same/i.test(row.note);
    if (row.fr === row.en && !sameOk) {
      err('the French text is the same as the English one (if that is right, write "same in en and fr" in the note)');
    }
    if (row.ar === row.en && !sameOk) {
      err('the Arabic text is the same as the English one (if that is right, write "same in en and ar" in the note)');
    }
    if (!ARABIC_LETTER.test(row.ar) && !(row.ar === row.en && sameOk)) {
      err('the Arabic text has no Arabic letters');
    }
    if (/Vesta/.test(row.en) && (!/Vesta/.test(row.fr) || !/Vesta/.test(row.ar))) {
      err('the brand name Vesta must stay in Latin letters in fr and ar');
    }
    if (/TND/.test(row.en) && (!/TND/.test(row.fr) || !/TND/.test(row.ar))) {
      err('the currency TND must stay in fr and ar');
    }
    if (ARABIC_LETTER.test(row.ar) && /[A-Za-z]/.test(row.ar.replace(PH_RE, '').replace(ALLOWED_LATIN, ''))) {
      warn('the Arabic text has Latin letters (check it is intended)');
    }
    if (!row.screen) warn('the screen column is empty');
  }
  return { errors, warnings };
}

// ---------- generated files ----------

function renderArb(rows, lang) {
  const out = { '@@locale': lang };
  for (const row of rows) {
    const key = toCamel(row.key);
    out[key] = arbText(row[lang]);
    const placeholders = placeholdersOf(row.en);
    if (placeholders.length > 0) {
      const map = {};
      for (const p of placeholders) map[p.name] = { type: ARB_TYPES[p.type] };
      out['@' + key] = { placeholders: map };
    }
  }
  return JSON.stringify(out, null, 2) + '\n';
}

// Same style as Prettier: single quotes, double quotes when the text has more apostrophes.
function quoteTs(text) {
  const singles = (text.match(/'/g) || []).length;
  const doubles = (text.match(/"/g) || []).length;
  const q = singles > doubles ? '"' : "'";
  const escaped = text
    .replace(/\\/g, '\\\\')
    .replace(/\n/g, '\\n')
    .split(q)
    .join('\\' + q);
  return q + escaped + q;
}

function renderTs(rows, lang) {
  const lines = rows.map((row) => {
    const key = toCamel(row.key);
    const value = quoteTs(rnText(row[lang]));
    const line = `  ${key}: ${value},`;
    return [...line].length > 80 ? `  ${key}:\n    ${value},` : line;
  });
  return 'export default {\n' + lines.join('\n') + '\n};\n';
}

function targets(rows) {
  const list = [];
  for (const lang of LANGS) {
    list.push({ file: path.join(ARB_DIR, `app_${lang}.arb`), content: renderArb(rows, lang) });
  }
  for (const lang of LANGS) {
    list.push({ file: path.join(RN_DIR, `${lang}.ts`), content: renderTs(rows, lang) });
  }
  return list;
}

function eolOf(file) {
  if (!fs.existsSync(file)) return '\r\n'; // the repository files use CRLF
  return fs.readFileSync(file, 'utf8').includes('\r\n') ? '\r\n' : '\n';
}

function loadMaster() {
  if (!fs.existsSync(MASTER)) {
    return { rows: [], errors: ['docs/translations.csv not found'], warnings: [] };
  }
  const { rows, errors } = readRows(fs.readFileSync(MASTER, 'utf8'));
  const result = validate(rows);
  return { rows, errors: errors.concat(result.errors), warnings: result.warnings };
}

function printList(title, list) {
  if (list.length === 0) return;
  console.log(`${title} (${list.length}):`);
  list.forEach((m) => console.log(`  ${m}`));
}

function build() {
  const { rows, errors, warnings } = loadMaster();
  if (errors.length > 0) {
    printList('Translations not generated, fix these errors first', errors);
    return 1;
  }
  for (const t of targets(rows)) {
    const eol = eolOf(t.file);
    fs.writeFileSync(t.file, t.content.replace(/\n/g, eol), 'utf8');
    console.log(`written ${path.relative(ROOT, t.file).replace(/\\/g, '/')}`);
  }
  printList('Warnings', warnings);
  console.log(`Done: ${rows.length} keys in 3 languages.`);
  if (fs.existsSync(path.join(ROOT, 'flutter-app'))) {
    console.log('Next: cd flutter-app, then flutter gen-l10n (it rewrites lib/l10n/generated).');
  }
  return 0;
}

// Keys written by hand in a generated file (they would be lost at the next build).
function keysOnDisk(file) {
  const text = fs.readFileSync(file, 'utf8');
  if (file.endsWith('.arb')) {
    try {
      return Object.keys(JSON.parse(text.replace(/^\uFEFF/, ''))).filter((k) => !k.startsWith('@'));
    } catch (e) {
      return [];
    }
  }
  return [...text.matchAll(/^ {2}([A-Za-z0-9_]+):/gm)].map((m) => m[1]);
}

function extraKeys(file, rows) {
  const known = new Set(rows.map((r) => toCamel(r.key)));
  return keysOnDisk(file).filter((k) => k !== '@@locale' && !known.has(k));
}

function check() {
  const { rows, errors, warnings } = loadMaster();
  const problems = errors.slice();
  if (errors.length === 0) {
    for (const t of targets(rows)) {
      const rel = path.relative(ROOT, t.file).replace(/\\/g, '/');
      if (!fs.existsSync(t.file)) {
        problems.push(`${rel} is missing: run node scripts/translations.js build`);
      } else if (fs.readFileSync(t.file, 'utf8').replace(/\r\n/g, '\n') !== t.content) {
        const extra = extraKeys(t.file, rows);
        const hint = extra.length ? ` Keys not in the master file: ${extra.slice(0, 10).join(', ')}${extra.length > 10 ? ', ...' : ''}.` : '';
        problems.push(`${rel} is not the generated file: edit docs/translations.csv, then run node scripts/translations.js build.${hint}`);
      }
    }
  }
  if (problems.length > 0) {
    printList('Translations check failed', problems);
    printList('Warnings', warnings);
    return 1;
  }
  printList('Warnings (not blocking)', warnings);
  console.log(`Translations check passed (${rows.length} keys, 3 languages).`);
  return 0;
}

// ---------- self-test ----------

function selfTest() {
  const assert = require('assert');
  const cases = [];
  const test = (name, fn) => cases.push({ name, fn });
  const ok = { key: 'a.b', en: 'One', fr: 'Un', ar: 'واحد', screen: 'x', note: '', line: 2 };

  test('toCamel', () => {
    assert.strictEqual(toCamel('auth.login.button'), 'authLoginButton');
    assert.strictEqual(toCamel('listing.price.per_night'), 'listingPricePerNight');
    assert.strictEqual(toCamel('loading'), 'loading');
  });
  test('toDotted and back', () => {
    assert.strictEqual(toDotted('publishFieldArea'), 'publish.field.area');
    assert.strictEqual(toDotted('languageAR'), 'language.ar');
    assert.strictEqual(toCamel(toDotted('favoritesErrorNoNetwork')), 'favoritesErrorNoNetwork');
  });
  test('CSV: quotes, commas and line breaks', () => {
    const rows = parseCsv('key,en\r\na,"Hello, ""you""\nbye"\r\nb,Plain\r\n');
    assert.deepStrictEqual(rows, [['key', 'en'], ['a', 'Hello, "you"\nbye'], ['b', 'Plain']]);
  });
  test('CSV: semicolon and BOM (Excel)', () => {
    const rows = parseCsv('\uFEFFkey;en\r\na;Hi\r\n');
    assert.deepStrictEqual(rows, [['key', 'en'], ['a', 'Hi']]);
  });
  test('CSV: write then read gives the same data', () => {
    const data = [['key', 'en'], ['a', 'Hi, "there"'], ['b', ' spaced ']];
    assert.deepStrictEqual(parseCsv(serializeCsv(data)), data);
  });
  test('placeholders and their types', () => {
    assert.deepStrictEqual(placeholdersOf('{n:int} photos for {name}'), [
      { name: 'n', type: 'int' },
      { name: 'name', type: 'string' },
    ]);
    assert.strictEqual(hasStrayBrace('Price {price} {'), true);
    assert.strictEqual(hasStrayBrace('Price {price}'), false);
  });
  test('placeholder text for ARB and for i18next', () => {
    assert.strictEqual(arbText('{n:int} photos'), '{n} photos');
    assert.strictEqual(rnText('{n:int} photos'), '{{n}} photos');
  });
  test('ARB output has @@locale and placeholder metadata', () => {
    const rows = [{ ...ok, key: 'home.price', en: 'Price: {price}', fr: 'Prix : {price}', ar: 'السوم: {price}' }];
    const arb = JSON.parse(renderArb(rows, 'fr'));
    assert.strictEqual(arb['@@locale'], 'fr');
    assert.strictEqual(arb.homePrice, 'Prix : {price}');
    assert.deepStrictEqual(arb['@homePrice'], { placeholders: { price: { type: 'String' } } });
  });
  test('TypeScript output: apostrophes use double quotes', () => {
    assert.strictEqual(quoteTs("N'est plus disponible"), '"N\'est plus disponible"');
    assert.strictEqual(quoteTs('Hello'), "'Hello'");
    assert.strictEqual(quoteTs('Say "hi"'), "'Say \"hi\"'");
  });
  test('TypeScript output: long lines are wrapped like Prettier', () => {
    const long = 'x'.repeat(80);
    const ts = renderTs([{ ...ok, key: 'a.long', en: long, fr: long, ar: long }], 'en');
    assert.ok(ts.includes("  aLong:\n    '" + long + "',"));
    assert.ok(renderTs([ok], 'en').includes("  aB: 'One',"));
  });
  test('valid row has no error', () => {
    assert.deepStrictEqual(validate([ok]).errors, []);
  });
  test('empty and duplicate', () => {
    assert.ok(validate([{ ...ok, ar: '' }]).errors.some((e) => e.includes('ar text is empty')));
    assert.ok(validate([ok, { ...ok, line: 3 }]).errors.some((e) => e.includes('duplicate key')));
  });
  test('two keys with the same app key', () => {
    const rows = [ok, { ...ok, key: 'a_b', line: 3 }];
    assert.ok(validate(rows).errors.some((e) => e.includes('same app key')));
  });
  test('bad key', () => {
    assert.ok(validate([{ ...ok, key: 'authLoginButton' }]).errors.length > 0);
  });
  test('French or Arabic equal to English needs "same" in the note', () => {
    assert.ok(validate([{ ...ok, fr: 'One' }]).errors.some((e) => e.includes('French')));
    assert.deepStrictEqual(validate([{ ...ok, fr: 'One', note: 'same in en and fr' }]).errors, []);
    assert.ok(validate([{ ...ok, ar: 'One' }]).errors.length > 0);
  });
  test('Arabic needs Arabic letters, Latin digits only', () => {
    assert.ok(validate([{ ...ok, ar: 'Uno' }]).errors.some((e) => e.includes('no Arabic letters')));
    assert.ok(validate([{ ...ok, ar: 'واحد ٣' }]).errors.some((e) => e.includes('Arabic-Indic')));
  });
  test('placeholders must match in the three languages', () => {
    const row = { ...ok, en: 'Hi {name}', fr: 'Salut', ar: 'مرحبا {name}' };
    assert.ok(validate([row]).errors.some((e) => e.includes('placeholders')));
  });
  test('brand and currency stay', () => {
    const row = { ...ok, en: 'About Vesta', fr: 'À propos', ar: 'عن التطبيق' };
    assert.ok(validate([row]).errors.some((e) => e.includes('Vesta')));
    const price = { ...ok, en: 'TND 5', fr: 'TND 5', ar: 'دينار 5', note: 'same' };
    assert.ok(validate([price]).errors.some((e) => e.includes('TND')));
  });
  test('Latin letters in Arabic are a warning, not an error', () => {
    const r = validate([{ ...ok, ar: 'واحد one' }]);
    assert.deepStrictEqual(r.errors, []);
    assert.ok(r.warnings.some((w) => w.includes('Latin')));
    assert.deepStrictEqual(validate([{ ...ok, ar: 'عن Vesta' }]).warnings.filter((w) => w.includes('Latin')), []);
  });

  test('keys that are not in the master file are found', () => {
    const os = require('os');
    const file = path.join(os.tmpdir(), `translations-selftest-${process.pid}.arb`);
    fs.writeFileSync(file, JSON.stringify({ '@@locale': 'en', aB: 'One', newKey: 'x', '@newKey': {} }));
    try {
      assert.deepStrictEqual(extraKeys(file, [ok]), ['newKey']);
    } finally {
      fs.unlinkSync(file);
    }
  });

  let failed = 0;
  for (const c of cases) {
    try {
      c.fn();
    } catch (e) {
      failed++;
      console.log(`FAIL ${c.name}: ${e.message}`);
    }
  }
  if (failed > 0) {
    console.log(`Self-test failed (${failed} of ${cases.length}).`);
    return 1;
  }
  console.log(`Self-test passed (${cases.length} cases).`);
  return 0;
}

module.exports = { toCamel, toDotted, parseCsv, serializeCsv, readRows, validate, renderArb, renderTs, placeholdersOf, MASTER, HEADER, ROOT };

if (require.main === module) {
  const arg = process.argv[2];
  if (arg === '--self-test') process.exit(selfTest());
  else if (arg === 'build') process.exit(build());
  else if (arg === 'check') process.exit(check());
  else {
    console.log('Usage: node scripts/translations.js build | check | --self-test');
    process.exit(arg ? 1 : 0);
  }
}
