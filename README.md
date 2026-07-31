# Preço de Imóveis com Geographically Weighted Regression (GWR)

Reprodução de metodologia acadêmica de **Geographically Weighted Regression** (Brunsdon, Fotheringham & Charlton, 1998; Fotheringham, Crespo & Yao, 2015) aplicada à predição de preços de imóveis, usando **PostGIS** para engenharia de features espaciais e comparando o modelo espacial local (GWR) com baselines não-espaciais (OLS, Random Forest, XGBoost).

## Motivação

Modelos tradicionais de precificação de imóveis (hedonic pricing) assumem que o efeito de cada variável (área, nº de quartos, distância ao metrô) é constante em toda a cidade. Isso raramente é verdade: um metro quadrado extra vale mais em um bairro do que em outro. O GWR resolve isso ajustando um modelo de regressão *local*, um por localização, ponderado por proximidade geográfica.

## Datasets

Este projeto reproduz a análise com **duas fontes de dados**, para comparar diferenças de granularidade, completude e vieses:

| | King County (Kaggle) | ITBI São Paulo |
|---|---|---|
| Geometria | Lat/lon direto | **Não vem geocodificado** — precisa geocodificar endereço ou casar com o cadastro territorial (Setor-Quadra-Lote) do GeoSampa |
| Atributos hedônicos | Completo (quartos, banheiros, área, ano de construção...) | Limitado (valor da transação, área do imóvel, tipo de uso — sem quartos/banheiros) |
| Granularidade temporal | Snapshot (2014-2015) | Mensal, por ano (arquivos .xlsx/.ods) |
| Uso no projeto | Baseline "ideal" — dataset já pronto para hedonic pricing | Caso realista de dado público bruto — exige mais engenharia de dados |

Ver `docs/datasets.md` (a criar) para as instruções de download e as decisões de geocodificação tomadas.

## Metodologia (papers de referência)

1. Brunsdon, Fotheringham & Charlton (1998) — *"Geographically Weighted Regression: A Method for Exploring Spatial Nonstationarity"*, Geographical Analysis.
2. Fotheringham, Crespo & Yao (2015) — *"Application of Geographically Weighted Regression to a 19-Year Set of House Price Data in London to Calibrate Local Hedonic Price Models"*.

## Stack

- **PostGIS** — armazenamento e engenharia de features espaciais (distâncias, contagens em raio)
- **GeoPandas / Shapely** — manipulação de geometrias em Python
- **mgwr / libpysal / esda** — modelagem GWR e estatística espacial (Moran's I, LISA)
- **scikit-learn / XGBoost** — baselines não-espaciais
- **Streamlit** — dashboard final (opcional, Epic 8)

## Como rodar

```bash
# 1. Configurar ambiente
cp .env.example .env
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt

# 2. Subir o PostGIS
docker compose up -d

# 3. Testar conexão
python -m gwr_imoveis.db

# 4. Rodar os notebooks em ordem (ver pasta notebooks/)
jupyter lab
```

## Estrutura do repositório

```
├── data/
│   ├── raw/          # dados brutos baixados (não versionado)
│   ├── processed/    # dados após limpeza/engenharia de features (não versionado)
│   └── external/     # dados auxiliares (OSM, cadastro territorial)
├── notebooks/        # notebooks numerados seguindo as Epics do backlog
├── src/gwr_imoveis/  # código Python reutilizável (conexão db, ingestão, features)
├── sql/               # scripts SQL (extensões, schemas, queries de feature engineering)
├── docker-compose.yml # ambiente PostGIS local
└── requirements.txt
```

## Backlog / Roadmap

O backlog completo, com todas as tasks por Epic, está em [`BACKLOG.md`](BACKLOG.md). Ele é a fonte de verdade; o script em `scripts/create_github_issues.sh` usa exatamente essa lista para criar as Issues no GitHub automaticamente (ver seção abaixo).

Resumo das Epics:

- [ ] Epic 1 — Infraestrutura e ambiente
- [ ] Epic 2 — Ingestão e preparação dos dados (inclui geocodificação do ITBI-SP via join com o cadastro territorial do GeoSampa)
- [ ] Epic 3 — Engenharia de features espaciais
- [ ] Epic 4 — Análise exploratória espacial
- [ ] Epic 5 — Modelagem baseline (não-espacial)
- [ ] Epic 6 — Reprodução do modelo GWR
- [ ] Epic 7 — Análise crítica e conclusões
- [ ] Epic 8 — Portfólio (dashboard + documentação)

## Gerenciando o backlog no GitHub

1. Rode `scripts/create_github_issues.sh` (requer [GitHub CLI](https://cli.github.com/) autenticado, `gh auth login`) para criar automaticamente um label por Epic e uma Issue por task.
2. Crie um **Project (board)** no repositório (aba "Projects" → "New project" → template "Board") e adicione as issues nele — assim vocês visualizam To Do / In Progress / Done.
3. Use **Milestones** (aba "Issues" → "Milestones") se quiser agrupar por Epic com data alvo, além dos labels.

## Licença

MIT — ver [LICENSE](LICENSE)
