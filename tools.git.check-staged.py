#!/usr/bin/env python3
"""Refuse les données, fichiers privés et secrets reconnaissables dans l'index."""
import argparse
import pathlib
import re
import subprocess
import sys

parser = argparse.ArgumentParser()
parser.add_argument('--repo', default='.')
args = parser.parse_args()

def git(*arguments):
    return subprocess.check_output(['git', '-C', args.repo, *arguments])

rejected = []
for raw in git('diff', '--cached', '--name-only', '--diff-filter=ACMR', '-z').split(b'\0'):
    if not raw:
        continue
    name = raw.decode('utf-8', errors='surrogateescape')
    path = pathlib.PurePosixPath(name)
    denied = any(part in {'persist', 'backups', 'private', '.ssh'} for part in path.parts)
    denied |= path.name == '.env' or (path.name.startswith('.env.') and path.name not in {'.env.example', '.env.template'})
    denied |= path.suffix in {'.grist', '.sqlite', '.sqlite3', '.db', '.pem', '.p12', '.pfx'}
    blob = git('show', ':' + name)
    denied |= len(blob) > 5 * 1024 * 1024
    text = blob.decode('utf-8', errors='replace')
    denied |= bool(re.search(r'-----BEGIN (?:OPENSSH |RSA |EC )?PRIVATE KEY-----', text))
    denied |= bool(re.search(r'\b(?:gh[pousr]_[A-Za-z0-9]{30,}|github_pat_[A-Za-z0-9_]{40,}|glpat-[A-Za-z0-9_-]{20,})\b', text))
    denied |= bool(re.search(r'https?://[^/\s:@]+:[^/\s@]+@', text))
    # Déclarations de secrets littéraux ; les références ${VARIABLE} sont permises.
    for match in re.finditer(r'''(?i)(?:password|passwd|api[_-]?key|session[_-]?secret)\s*[:=]\s*['"]([^'"\n]{8,})['"]''', text):
        value = match.group(1)
        if '$' not in value and not any(x in value.lower() for x in ['example', 'placeholder', 'change_me', 'redacted', 'requis']):
            denied = True
    if denied:
        rejected.append(name)
if rejected:
    print('Publication refusée pour ces chemins : ' + ', '.join(rejected), file=sys.stderr)
    sys.exit(1)
print('STAGED_FILES_CHECK_OK')
