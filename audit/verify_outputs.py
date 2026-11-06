"""Independent offline audit of snapshots and delivered CSV outputs."""
import collections, csv, datetime, hashlib, json
from pathlib import Path
ROOT = Path(__file__).resolve().parents[1]
def rows(path):
    with (ROOT / path).open(newline='') as handle:
        return list(csv.DictReader(handle))
manifest = json.loads((ROOT / 'manifest.json').read_text())
raw_by_id = {}
for record in manifest:
    data = (ROOT / record['file']).read_bytes()
    assert hashlib.sha256(data).hexdigest() == record['sha256']
    data_rows = rows(record['file'])
    assert len(data_rows) == record['n_rows']
    for item in data_rows:
        key = tuple(item[k] for k in ['id.accession','id.assay name','id.sample name'])
        assert key not in raw_by_id
        raw_by_id[key] = item
cd = rows('results/col_data.csv')
pr = rows('results/provenance.csv')
co = rows('results/completeness.csv')
pa = rows('results/pairwise.csv')
de = rows('results/design_cells.csv')
cd_by_id = {tuple(r[k] for k in ['accession','assay','sample']):r for r in cd}
assert len(cd)==len(cd_by_id)==104
assert collections.Counter(r['accession'] for r in cd)=={'OSD-37':56,'OSD-38':12,'OSD-120':36}
assert len(pr)==104*14
assert len({tuple(r[k] for k in ['accession','assay','sample','field']) for r in pr})==len(pr)
assert len(pa)==21
assert sum(int(r['n']) for r in co)==len(pr)
for key,r in cd_by_id.items():
    assert raw_by_id[key]['investigation.study assays.study assay technology type'].lower()=='rna sequencing (rna-seq)'
for r in pr:
    key=tuple(r[k] for k in ['accession','assay','sample'])
    assert cd_by_id[key][r['field']]==r['canonical_value']
    source=raw_by_id[key]
    if r['source_fields']:
        assert ' | '.join(source[f] for f in r['source_fields'].split(' | '))==r['raw_values']
for r in pa:
    a=[x[r['field']] for x in cd if x['accession']==r['study_a']]
    b=[x[r['field']] for x in cd if x['accession']==r['study_b']]
    aa=set(a)-{''}; bb=set(b)-{''}
    expected=('unavailable_metadata' if not aa or not bb else 'incomplete_metadata' if '' in a or '' in b else 'same_observed_values' if aa==bb else 'overlapping_observed_values' if aa&bb else 'different_observed_values')
    assert expected==r['result']
    assert int(r['n_missing_a'])==a.count('')
    assert int(r['n_missing_b'])==b.count('')
assert sum(int(r['n_assay_sample_records']) for r in de)==104
assert {r['light_treatment'] for r in de if r['accession']=='OSD-120'}=={'light treatment','dark treatment'}
assert all(int(r['n_assay_sample_records'])==3 for r in de if r['accession']=='OSD-120')
assert all(r['spaceflight']=='ground control' for r in de if r['accession']=='OSD-38' and r['preservation']=='liquid nitrogen')
summary={
    'audit_utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),
    'status':'passed',
    'source_records':len(raw_by_id),'rnaseq_records':len(cd),
    'provenance_cells':len(pr),'provenance_status_counts':dict(collections.Counter(r['status'] for r in pr)),
    'pairwise_rows':len(pa),'design_cells':len(de),
    'code_sha256':{str(p.relative_to(ROOT)):hashlib.sha256(p.read_bytes()).hexdigest() for p in sorted((ROOT/'prototype').glob('*.R'))},
    'limits':['Offline verifier does not certify biological equivalence or independence of records.','Native R, Bioconductor classes, R CMD check and BiocCheck not executed.']}
(ROOT/'audit/verification_summary.json').write_text(json.dumps(summary,indent=2)+'\n')
print(json.dumps(summary,indent=2))
