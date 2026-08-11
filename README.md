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
python -m venv venv && source venv/bin/activate
pip install -r requirements.txt
pip install -e .

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
│   ├── raw/            # dados brutos baixados (Kaggle) — não versionado, só a pasta
│   ├── processed/      # dados após limpeza/engenharia de features — não versionado
│   └── external/       # dados auxiliares (POIs do OSM, cadastro territorial) — não versionado
├── notebooks/          # notebooks numerados seguindo as Epics do backlog
├── scripts/            # scripts utilitários (ex. criação das Issues no GitHub)
├── sql/                # scripts SQL (extensões, schemas, migrações, auditorias)
├── src/gwr_imoveis/    # código Python reutilizável (conexão db, ingestão, features)
├── docker-compose.yml  # ambiente PostGIS local
├── pyproject.toml      # instalação editável do pacote (pip install -e .)
└── requirements.txt
```

`data/` só existe no repositório como estrutura de pastas (arquivos `.gitkeep`) — o conteúdo em si nunca é versionado, tanto pelo tamanho quanto porque o dataset do Kaggle não pode ser redistribuído fora da plataforma. Rode os scripts de ingestão (`src/gwr_imoveis/ingest_*.py`) para reconstruir os dados localmente.

## Backlog / Roadmap

O backlog completo, com todas as tasks por Epic e o progresso atual, está em [`BACKLOG.md`](BACKLOG.md) — é a fonte de verdade, refletida como Issues no GitHub.

Resumo das Epics:

- [x] Epic 1 — Infraestrutura e ambiente
- [ ] Epic 2 — Ingestão e preparação dos dados (inclui geocodificação do ITBI-SP via join com o cadastro territorial do GeoSampa)
- [ ] Epic 3 — Engenharia de features espaciais
- [ ] Epic 4 — Análise exploratória espacial
- [ ] Epic 5 — Modelagem baseline (não-espacial)
- [ ] Epic 6 — Reprodução do modelo GWR
- [ ] Epic 7 — Análise crítica e conclusões
- [ ] Epic 8 — Portfólio (dashboard + documentação)

## Licença

MIT — ver [LICENSE](LICENSE)
