import { readdirSync, readFileSync } from 'fs';
import { join, relative, resolve, sep } from 'path';
import Ajv from 'ajv';

const root = resolve(import.meta.dirname, '..');
const schemaMappings = JSON.parse(readFileSync(join(root, '.vscode', 'settings.json'), 'utf8'))['json.schemas'] ?? [];

const ajv = new Ajv();
const validators = new Map();
const dirs = [
    './common/media/lua/shared/Translate/RU',
    './common/media/lua/shared/Translate/EN'
];

const escapeRegExp = (s) => s.replace(/[.+^${}()|[\]\\]/g, '\\$&');

const globToRegExp = (glob) => new RegExp(
    '^' + glob.split('**/').map((part) => part.split('*').map(escapeRegExp).join('[^/]*')).join('(?:.*/)?') + '$'
);

const getValidator = (url) => {
    if (!validators.has(url)) {
        validators.set(url, fetch(url).then(async (res) => {
            if (!res.ok) throw new Error(`HTTP ${res.status} for ${url}`);
            return ajv.compile(await res.json());
        }));
    }
    return validators.get(url);
};

const findMapping = (relPath) => schemaMappings.find(({ fileMatch }) =>
    [fileMatch].flat().some((glob) => globToRegExp(glob).test(relPath))
);

const files = dirs.flatMap((dir) => {
    return readdirSync(dir).filter((f) => f.endsWith('.json')).map((f) => ({ dir, file: f, locale: dir.split('/').pop() }))
});

for (const { dir, file, locale } of files) {
    const filePath = join(dir, file);
    const relPath = relative(root, resolve(filePath)).split(sep).join('/');
    const mapping = findMapping(relPath);

    if (!mapping) {
        console.warn(`? ${file}: no json.schemas entry in .vscode/settings.json`);
        continue;
    }

    const validate = await getValidator(mapping.url);
    const data = JSON.parse(readFileSync(filePath, 'utf8'));

    if (!validate(data)) {
        console.error(`✗ ${locale}/${file}: ${JSON.stringify(validate.errors)}`);
    } else {
        console.log(`✓ ${locale}/${file}`);
    }
}