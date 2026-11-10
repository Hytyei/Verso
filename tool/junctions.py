"""Recreate Flutter Windows plugin links as directory junctions (no Developer Mode needed).
Usage: python junctions.py <flutter project dir>"""
import json, os, subprocess, sys

proj = sys.argv[1]
d = json.load(open(os.path.join(proj, '.flutter-plugins-dependencies'), encoding='utf-8'))
root = os.path.join(proj, 'windows', 'flutter', 'ephemeral', '.plugin_symlinks')
os.makedirs(root, exist_ok=True)
for p in d['plugins'].get('windows', []):
    link = os.path.join(root, p['name'])
    if os.path.lexists(link):
        subprocess.run(['cmd', '/c', 'rmdir', link], capture_output=True)
    target = p['path'].rstrip('\\/')
    r = subprocess.run(['cmd', '/c', 'mklink', '/J', link, target], capture_output=True, text=True)
    print(p['name'], 'ok' if r.returncode == 0 else r.stderr.strip())
