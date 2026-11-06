import { WebR } from 'webr';
import fs from 'node:fs';
import { fileURLToPath } from 'node:url';
const root = fileURLToPath(new URL('../', import.meta.url)).replace(/\/$/, '');
const webR = new WebR({interactive:false});
await webR.init();
await webR.FS.mkdir('/project');
for (const dir of ['raw','prototype','results']) await webR.FS.mkdir(`/project/${dir}`);
for (const dir of ['raw','prototype']) {
  for (const f of fs.readdirSync(`${root}/${dir}`)) {
    await webR.FS.writeFile(`/project/${dir}/${f}`,new Uint8Array(fs.readFileSync(`${root}/${dir}/${f}`)));
  }
}
await webR.evalRVoid('setwd("/project")');
const shelter = await new webR.Shelter();
for (const f of ['tests.R','demo.R']) {
  const res=await shelter.captureR(`source("prototype/${f}")`);
  console.log(`RUN ${f}:`);
  for (const o of res.output) console.log(o.data);
}
for (const name of ['col_data.csv','provenance.csv','completeness.csv','pairwise.csv','design_cells.csv','sessionInfo.txt']) {
 fs.writeFileSync(`${root}/results/${name}`, await webR.FS.readFile(`/project/results/${name}`));
}
await webR.close();
