from urllib.request import urlopen
from urllib.parse import quote
from pathlib import Path
import csv, io, json, hashlib, datetime
from concurrent.futures import ThreadPoolExecutor
ROOT=Path(__file__).resolve().parent
def one(acc):
    query='id.accession='+acc+'&study.characteristics&study.factor%20value&study.parameter%20value&investigation.study%20assays.study%20assay%20technology%20type'
    url='https://visualization.osdr.nasa.gov/biodata/api/v2/query/metadata/?'+query
    with urlopen(url,timeout=45) as r: data=r.read()
    (ROOT/'raw'/f'{acc}.csv').write_bytes(data)
    rows=list(csv.DictReader(io.StringIO(data.decode('utf-8-sig'))))
    print(acc,len(rows),len(data),flush=True)
    for k in rows[0]:
        print(k, sorted({r[k] for r in rows})[:10],flush=True)
    return dict(accession=acc,url=url,retrieved_at_utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),sha256=hashlib.sha256(data).hexdigest(),n_rows=len(rows),file=f'raw/{acc}.csv')
with ThreadPoolExecutor(max_workers=3) as pool:
    manifest=list(pool.map(one,['OSD-37','OSD-38','OSD-120']))
(ROOT/'manifest.json').write_text(json.dumps(manifest,indent=2))
