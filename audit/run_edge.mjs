import { WebR } from '../runtime/node_modules/webr/dist/webr.mjs';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const webR = new WebR({interactive:false});
await webR.init();
await webR.FS.mkdir('/project');
for (const dir of ['raw','prototype','audit','results']) await webR.FS.mkdir(`/project/${dir}`);
for (const dir of ['raw','prototype','audit']) {
  for (const f of fs.readdirSync(`${root}/${dir}`)) {
    if (fs.statSync(`${root}/${dir}/${f}`).isFile()) await webR.FS.writeFile(`/project/${dir}/${f}`,new Uint8Array(fs.readFileSync(`${root}/${dir}/${f}`)));
  }
}
await webR.evalRVoid('setwd("/project")');
const shelter = await new webR.Shelter();
for (const f of ['prototype/tests.R','audit/edge_tests.R']) {
  const res=await shelter.captureR(`source("${f}")`);
  console.log(`RUN ${f}:`);
  for (const o of res.output) console.log(o.data);
}
await webR.close();
