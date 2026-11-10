"""Turns Todoist completed tasks (Claude Projects Map) into a Verso import tree (merge mode)."""
import json, re, sys

# Usage: python completed_to_tree.py <todoist-completed.json> <out-tree.json> [map.json]
# map.json (git-ignored, owner-specific) names the open Todoist parents as they are called in Verso now:
# {"envs": {"<todoistId>": "Env name"}, "projects": {"<id>": "Project"},
#  "versions": {"<id>": ["Project", "v1.0.0"]}, "features": {"<id>": ["Project", null, "Feature title"]}}
import os
src, out = sys.argv[1], sys.argv[2]
map_path = sys.argv[3] if len(sys.argv) > 3 else os.path.join(os.path.dirname(os.path.abspath(__file__)), 'map.json')
m = json.load(open(map_path, encoding='utf-8')) if os.path.exists(map_path) else {}
tasks = json.load(open(src, encoding='utf-8'))['tasks']
done = {t['id']: t for t in tasks}
OPEN_ENVS = m.get('envs', {})
OPEN_PROJECTS = m.get('projects', {})
OPEN_VERSIONS = {k: tuple(v) for k, v in m.get('versions', {}).items()}
OPEN_FEATURES = {k: tuple(v) for k, v in m.get('features', {}).items()}
# Completed groups that are environments (browsers where development happened).
ENV_LIKE = {'Comet'}

children = {}
for t in tasks:
    children.setdefault(t.get('parentId'), []).append(t)
for v in children.values():
    v.sort(key=lambda t: t['addedAt'])

def clean(s):
    return re.sub(r'\*\*(.+?)\*\*', r'\1', s).strip()

def steps_of(tid):
    out = []
    def walk(pid):
        for c in children.get(pid, []):
            out.append({'title': clean(c['content']), 'done': True})
            walk(c['id'])
    walk(tid)
    return out

def feature(t):
    f = {'title': clean(t['content']), 'done': True}
    if t.get('description'):
        f['notes'] = t['description'].strip()
    st = steps_of(t['id'])
    if st:
        f['steps'] = st
    return f

envs = {}       # env name -> {name, icon, projects: {name: project dict}}
def env(name, icon='web'):
    return envs.setdefault(name, {'name': name, 'icon': icon, 'projects': {}})
def project(env_name, pname, icon='web'):
    e = env(env_name, icon)
    return e['projects'].setdefault(pname, {'name': pname, 'concept': [], 'versions': {}})
def version(p, vname, released):
    v = p['versions'].setdefault(vname, {'name': vname, 'features': []})
    if released:
        v['status'] = 'released'
    return v

def is_version(t):
    return re.match(r'^v\d', t['content'].strip()) is not None

def add_project_children(p, pid):
    for c in children.get(pid, []):
        if is_version(c):
            v = version(p, clean(c['content']), True)
            for f in children.get(c['id'], []):
                v['features'].append(feature(f))
        else:
            p['concept'].append(feature(c))

for t in tasks:
    pid = t.get('parentId')
    name = clean(t['content'])
    # Completed environment (top level, or a known browser group).
    if pid is None or name in ENV_LIKE:
        e = env(name)
        for pr in children.get(t['id'], []):
            p = project(name, clean(pr['content']))
            add_project_children(p, pr['id'])
        continue
    if pid in OPEN_ENVS:
        p = project(OPEN_ENVS[pid], name, 'folder')
        add_project_children(p, t['id'])
    elif pid in OPEN_PROJECTS:
        p = project('Claude Code', OPEN_PROJECTS[pid], 'folder')
        if is_version(t):
            v = version(p, name, True)
            for f in children.get(t['id'], []):
                v['features'].append(feature(f))
        else:
            p['concept'].append(feature(t))
    elif pid in OPEN_VERSIONS:
        pname, vname = OPEN_VERSIONS[pid]
        version(project('Claude Code', pname, 'folder'), vname, False)['features'].append(feature(t))
    elif pid in OPEN_FEATURES:
        pname, vname, ftitle = OPEN_FEATURES[pid]
        p = project('Claude Code', pname, 'folder')
        p['concept'].append({'title': ftitle, 'steps': [{'title': name, 'done': True}] + steps_of(t['id'])})
    # else: the parent is itself completed; handled when its parent was processed.

tree = {'merge': True, 'source': 'Todoist completed tasks', 'environments': []}
for e in envs.values():
    projects = []
    for p in e['projects'].values():
        d = {'name': p['name']}
        if p['concept']:
            d['concept'] = p['concept']
        if p['versions']:
            d['versions'] = list(p['versions'].values())
        projects.append(d)
    tree['environments'].append({'name': e['name'], 'icon': e['icon'], 'projects': projects})
json.dump(tree, open(out, 'w', encoding='utf-8'), ensure_ascii=False, indent=1)

# Summary
nf = 0
for e in tree['environments']:
    print('ENV', e['name'])
    for p in e['projects']:
        c = len(p.get('concept', []))
        vs = [(v['name'], v.get('status', 'open'), len(v['features'])) for v in p.get('versions', [])]
        nf += c + sum(x[2] for x in vs)
        print('   ', p['name'], '| concept', c, '|', vs)
print('features total', nf)
