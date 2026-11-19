#!/usr/bin/env node
// Design-system check (VST-78): colors must come from the theme files only.
// Usage (from the repo root): node tools/check-colors.js
//        node tools/check-colors.js --self-test
// A line with the text "color-check-ignore" is skipped (rare exception, explain it in the PR).

const fs = require('fs');
const path = require('path');

const ROOT = path.resolve(__dirname, '..');
const FLUTTER_LIB = path.join(ROOT, 'flutter-app', 'lib');
const RN_APP = path.join(ROOT, 'react-native-app');

const DART_RULES = [
  { re: /\bColor\(\s*0x/, msg: 'Color(0x...) is only allowed in lib/core/theme/' },
  { re: /\bColor\.fromRGBO\b/, msg: 'Color.fromRGBO is only allowed in lib/core/theme/' },
  { re: /\bColor\.fromARGB\b/, msg: 'Color.fromARGB is only allowed in lib/core/theme/' },
  { re: /\bColors\.(?!transparent\b)[A-Za-z_]\w*/, msg: 'Colors.x is not allowed (only Colors.transparent): use AppColors' },
  { re: /\bCupertinoColors\.(?!transparent\b)[A-Za-z_]\w*/, msg: 'CupertinoColors.x is not allowed: use AppColors' },
];

const NAMED_COLORS = new Set(
  ('aliceblue antiquewhite aqua aquamarine azure beige bisque black blanchedalmond blue blueviolet brown burlywood ' +
    'cadetblue chartreuse chocolate coral cornflowerblue cornsilk crimson cyan darkblue darkcyan darkgoldenrod darkgray ' +
    'darkgreen darkgrey darkkhaki darkmagenta darkolivegreen darkorange darkorchid darkred darksalmon darkseagreen ' +
    'darkslateblue darkslategray darkslategrey darkturquoise darkviolet deeppink deepskyblue dimgray dimgrey dodgerblue ' +
    'firebrick floralwhite forestgreen fuchsia gainsboro ghostwhite gold goldenrod gray green greenyellow grey honeydew ' +
    'hotpink indianred indigo ivory khaki lavender lavenderblush lawngreen lemonchiffon lightblue lightcoral lightcyan ' +
    'lightgoldenrodyellow lightgray lightgreen lightgrey lightpink lightsalmon lightseagreen lightskyblue lightslategray ' +
    'lightslategrey lightsteelblue lightyellow lime limegreen linen magenta maroon mediumaquamarine mediumblue ' +
    'mediumorchid mediumpurple mediumseagreen mediumslateblue mediumspringgreen mediumturquoise mediumvioletred ' +
    'midnightblue mintcream mistyrose moccasin navajowhite navy oldlace olive olivedrab orange orangered orchid ' +
    'palegoldenrod palegreen paleturquoise palevioletred papayawhip peachpuff peru pink plum powderblue purple ' +
    'rebeccapurple red rosybrown royalblue saddlebrown salmon sandybrown seagreen seashell sienna silver skyblue ' +
    'slateblue slategray slategrey snow springgreen steelblue tan teal thistle tomato turquoise violet wheat white ' +
    'whitesmoke yellow yellowgreen').split(' ')
);

const RN_HEX = /(?<![\w&])#(?:[0-9a-fA-F]{8}|[0-9a-fA-F]{6}|[0-9a-fA-F]{3,4})\b/;
const RN_FUNC = /\b(?:rgb|rgba|hsl|hsla)\s*\(/i;
const RN_NAMED = /\b[A-Za-z]*[cC]olor\b\s*[:=]\s*\{?\s*(['"`])([A-Za-z]+)\1/g;

// Removes comments but keeps the line numbers.
function stripComments(text) {
  const blank = (m) => m.replace(/[^\n]/g, ' ');
  return text
    .replace(/\/\*[\s\S]*?\*\//g, blank)
    .split('\n')
    .map((line) => line.replace(/(?<!:)\/\/.*$/, ''))
    .join('\n');
}

function scan(text, rules) {
  const found = [];
  const lines = stripComments(text).split('\n');
  const original = text.split('\n');
  lines.forEach((line, i) => {
    if (original[i].includes('color-check-ignore')) return;
    for (const rule of rules) {
      if (rule.re.test(line)) found.push({ line: i + 1, msg: rule.msg, code: original[i].trim() });
    }
  });
  return found;
}

function checkDart(text) {
  return scan(text, DART_RULES);
}

function checkRn(text) {
  const found = scan(text, [
    { re: RN_HEX, msg: 'hex color: use a token from src/core/theme.ts' },
    { re: RN_FUNC, msg: 'rgb(), rgba(), hsl() or hsla(): use a token from src/core/theme.ts' },
  ]);
  const lines = stripComments(text).split('\n');
  const original = text.split('\n');
  lines.forEach((line, i) => {
    if (original[i].includes('color-check-ignore')) return;
    for (const m of line.matchAll(RN_NAMED)) {
      const name = m[2].toLowerCase();
      if (NAMED_COLORS.has(name)) {
        found.push({ line: i + 1, msg: `named color "${m[2]}": use a token from src/core/theme.ts`, code: original[i].trim() });
      }
    }
  });
  return found.sort((a, b) => a.line - b.line);
}

function walk(dir, exts, out = []) {
  if (!fs.existsSync(dir)) return out;
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    if (entry.name === 'node_modules' || entry.name === 'generated') continue;
    const full = path.join(dir, entry.name);
    if (entry.isDirectory()) walk(full, exts, out);
    else if (exts.includes(path.extname(entry.name))) out.push(full);
  }
  return out;
}

const rel = (p) => path.relative(ROOT, p).split(path.sep).join('/');

function runCheck() {
  const problems = [];
  let files = 0;

  const dartFiles = walk(FLUTTER_LIB, ['.dart']).filter((f) => !rel(f).startsWith('flutter-app/lib/core/theme/'));
  for (const f of dartFiles) {
    files++;
    for (const p of checkDart(fs.readFileSync(f, 'utf8'))) problems.push({ file: rel(f), ...p });
  }

  const rnFiles = [...walk(path.join(RN_APP, 'src'), ['.ts', '.tsx', '.js', '.jsx']), path.join(RN_APP, 'App.tsx')]
    .filter((f) => fs.existsSync(f))
    .filter((f) => {
      const r = rel(f);
      return r !== 'react-native-app/src/core/theme.ts' && !r.startsWith('react-native-app/src/core/theme/');
    });
  for (const f of rnFiles) {
    files++;
    for (const p of checkRn(fs.readFileSync(f, 'utf8'))) problems.push({ file: rel(f), ...p });
  }

  if (problems.length > 0) {
    console.error('Color check failed. Use the theme tokens (see docs/brand/design-tokens.md):\n');
    for (const p of problems) console.error(`${p.file}:${p.line}: ${p.msg}\n    ${p.code}`);
    console.error(`\n${problems.length} problem(s) in ${files} files.`);
    return 1;
  }
  console.log(`Color check passed (${files} files).`);
  return 0;
}

function runSelfTest() {
  const cases = [
    ['dart', 'color: Colors.red,', 1],
    ['dart', 'backgroundColor: Colors.black54,', 1],
    ['dart', 'const Color(0xFF176AAB)', 1],
    ['dart', 'Color.fromRGBO(0, 0, 0, 0.5)', 1],
    ['dart', 'Color.fromARGB(255, 0, 0, 0)', 1],
    ['dart', 'color: Colors.transparent,', 0],
    ['dart', 'color: AppColors.primary,', 0],
    ['dart', '// color: Colors.red', 0],
    ['dart', 'color: Colors.red, // color-check-ignore', 0],
    ['rn', "color: '#FFF',", 1],
    ['rn', "backgroundColor: '#176AAB',", 1],
    ['rn', 'shadowColor: "rgba(0,0,0,0.3)",', 1],
    ['rn', 'borderColor: "red",', 1],
    ['rn', '<Text color="white" />', 1],
    ['rn', "backgroundColor: 'transparent',", 0],
    ['rn', 'color: theme.colors.primary,', 0],
    ['rn', "// color: '#fff'", 0],
    ['rn', "const label = 'Villa #12';", 0],
  ];
  let failed = 0;
  for (const [kind, code, expected] of cases) {
    const got = (kind === 'dart' ? checkDart(code) : checkRn(code)).length;
    if (got !== expected) {
      failed++;
      console.error(`SELF-TEST FAIL [${kind}] expected ${expected} problem(s), got ${got}: ${code}`);
    }
  }
  if (failed > 0) return 1;
  console.log(`Self-test passed (${cases.length} cases).`);
  return 0;
}

process.exit(process.argv.includes('--self-test') ? runSelfTest() : runCheck());
