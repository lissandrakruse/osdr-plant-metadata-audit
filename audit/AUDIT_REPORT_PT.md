# Verificação automatizada do protótipo

Data: 06/11/2026 UTC. Escopo: scripts locais e resultados descritivos de metadados OSD-37, OSD-38 e OSD-120. Não é auditoria científica de meta-análise nem certificação de pacote Bioconductor.

## Resultado

Os testes descritos abaixo passaram para a demonstração estreita e descritiva. A verificação foi automatizada e não constitui revisão científica por pares. O resultado não atesta elegibilidade para submissão, equivalência biológica ou independência de réplicas.

## Evidências verificadas

- Os três arquivos brutos conferem com SHA-256 e número de registros do manifesto. Nova consulta independente aos mesmos endpoints oficiais NASA retornou HTTP 200 e bytes com SHA-256 idêntico aos snapshots.
- Totais confirmados: 218 registros de ensaio/amostra; 104 RNA-seq, sendo 56/12/36 em OSD-37/38/120; 1.456 células de proveniência; 21 comparações de campos; 23 células de desenho.
- Proveniência: 1.190 células observadas, 248 ausentes, 18 não aplicáveis. Valores fonte e respectivos campos foram reconciliados com os snapshots. Valores canônicos correspondem aos da tabela de saída.
- Todos os 23 grupos de asserções do projeto passaram via WebR. Testes adicionais verificaram conflitos, unidades não suportadas, distinção de ausência/não aplicável e as regressões de identificação.
- Classificações das 21 comparações e suas contagens de ausência foram recalculadas independentemente em Python e conferem.
- O runner foi executado em uma cópia movida para outro caminho e iniciado fora do diretório do projeto. Saiu com código zero e reproduziu os cinco CSVs byte a byte. As dependências WebR já instaladas foram compartilhadas na cópia; uma instalação npm inteiramente nova não foi testada.
- Um erro R intencional confirmou que o executor WebR rejeita a execução; asserções falhas não são silenciosamente tratadas como sucesso.

## Falhas encontradas e corrigidas

1. IDs de amostra vazios eram aceitos. Agora são rejeitados.
2. A chave concatenada com `::` gerava colisões para tuplas distintas. Agora a duplicação é testada sobre as três colunas.
3. O resumo de desenho omitia tratamento de luz, juntando grupos de OSD-120. Agora inclui `light_treatment` e mantém células de três registros separadas.
4. Os scripts utilitários dependiam de caminho absoluto. Agora resolvem a raiz pela localização do próprio script.

O estado testado de `prototype/compare.R` tem SHA-256 `5754edea8602656e617e8f32699436ca89859349f50087d11c7f737ba8d5d422`. Outros hashes constam de `verification_summary.json`.

## Limites que precisam permanecer explícitos

- Somente WebR/base R foi executado. R nativo, instalação de pacote, classes Bioconductor, R CMD check, BiocCheck e CI entre sistemas não foram executados.
- O filtro de tecnologia é estrito: rótulos diferentes de `RNA Sequencing (RNA-Seq)` são excluídos. Para novas fontes, convém relatar explicitamente os registros descartados e rótulos não reconhecidos.
- Regras de aliases são locais a três snapshots. `Col-0 PhyD` permanece um valor literal em ecotype; isso não resolve a semântica de ecótipo/genótipo. `petri dish` não representa uma curadoria completa de hardware. A tradução de treatment para light_treatment só foi verificada nestes dados.
- Comparações de conjuntos marginais não consideram distribuição ou interação de fatores. A tabela de desenho também é parcial e não avalia independência, confundimento, poder estatístico, protocolos, missões ou processamento.
- Idade e duração de crescimento permanecem separadas; a ausência do campo consultado não demonstra ausência da informação em todos os protocolos ou artigos.
- O material identifica corretamente assistência de IA e não atribui autoria ou compromisso de manutenção à usuária. Esta auditoria não prova originalidade por comparação exaustiva de código externo.

## Reexecução local da auditoria

- `node audit/run_edge.mjs`, com as dependências WebR já instaladas em runtime.
- `python audit/verify_outputs.py`, apenas biblioteca padrão, offline.

Logs: `edge_test_log.txt`, `portability_run_log.txt`. Resumo legível por máquina: `verification_summary.json`.

## Preparação para publicação

O cabeçalho do código foi atualizado para retirar a indicação de material privado, sem alterar a implementação. Os 23 grupos de asserções, as verificações adicionais e o verificador Python foram reexecutados em 06/11/2026 UTC na cópia preparada para publicação. As tabelas CSV permaneceram idênticas às originais. Os logs desta execução são `results/publication_test_log.txt` e `audit/publication_edge_test_log.txt`. Nenhuma licença geral de software foi selecionada; ver RIGHTS.md.
