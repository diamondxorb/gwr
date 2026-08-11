# Backlog

Cada item aqui vira uma Issue no GitHub (ver README para o passo a passo). O número entre `#` é só referência interna do backlog, não é o número da issue no GitHub — o GitHub numera automaticamente.

## Epic 1 — Infraestrutura e ambiente
- [x] #1 Subir PostGIS localmente via Docker Compose (imagem `postgis/postgis`)
- [x] #2 Criar ambiente Python (venv/conda) com GeoPandas, SQLAlchemy, psycopg2, mgwr, esda, libpysal, scikit-learn, xgboost
- [x] #3 Estruturar repositório e subir README inicial explicando o objetivo do projeto
- [x] #4 Criar conexão Python ↔ PostGIS testada com uma query simples (`SELECT PostGIS_Version()`)

## Epic 2 — Ingestão e preparação dos dados
- [ ] #5 Baixar dataset de imóveis (King County House Sales) e carregar como tabela no PostGIS, convertendo lat/lon em geometria
- [ ] #6 Baixar dados do OSM via Overpass API (`osmnx`) para a região: escolas, estações de metrô/ônibus, parques, comércio
- [ ] #7 Carregar camadas do OSM no PostGIS como tabelas separadas por categoria de POI
- [ ] #8 Validar sistemas de coordenadas (SRID) e reprojetar tudo para um CRS métrico local
- [ ] #9 Checar qualidade dos dados: duplicatas, outliers de preço, geometria inválida (`ST_IsValid`)
- [x] **#9a Decidir estratégia de geocodificação do dataset ITBI-SP**: comparar (a) geocodificação por endereço via Nominatim/OSM vs (b) join pelo cadastro territorial (Setor-Quadra-Lote) com a malha de lotes do GeoSampa.
  - **Decisão**: join pelo cadastro territorial (Setor-Quadra-Lote) é a estratégia principal — demonstra uso genuíno de PostGIS (join espacial/relacional, geometria exata), em vez de depender de uma API de geocoding.
  - **v1**: transações do ITBI sem lote correspondente no join **ficam de fora do dataset**. A taxa de match e os casos sem match são medidos e documentados (#9e), não descartados silenciosamente.
  - **Nice-to-have (não faz parte do v1)**: ver #9f — fallback via Nominatim para os registros sem match.
- [ ] **#9b Baixar a malha de lotes (SQL — Setor/Quadra/Lote) do GeoSampa e carregar no PostGIS** como `raw.lotes_geosampa`
- [ ] **#9c Baixar e carregar os arquivos mensais de transações ITBI (xlsx/ods) no PostGIS** como `raw.itbi_transacoes`, padronizando a coluna de SQL entre as duas bases (formato costuma divergir — checar zeros à esquerda, separadores)
- [ ] **#9d Implementar o join espacial/relacional ITBI × lotes GeoSampa pelo SQL**, gerando uma tabela `features.itbi_geocodificado` com geometria do lote associada a cada transação
- [ ] **#9e Medir taxa de match do join** (% de transações que encontraram lote correspondente) e investigar/documentar os casos sem match
- [ ] **#9f (nice-to-have) Fallback via Nominatim/OSM para transações sem match no join** — geocodificar por endereço só os registros que sobraram sem lote correspondente após #9e, em vez de descartá-los. Só entra no backlog ativo depois que #9a–#9e estiverem completos e a taxa de match do join v1 for conhecida.

## Epic 3 — Engenharia de features espaciais
- [ ] #10 Calcular distância ao POI mais próximo por categoria usando `ST_Distance` + `LATERAL JOIN`
- [ ] #11 Calcular contagem de POIs num raio (`ST_DWithin`)
- [ ] #12 Criar índice espacial (`GIST`) nas tabelas de geometria e comparar tempo de query antes/depois
- [ ] #13 Exportar dataset final consolidado (features + preço) do PostGIS para um GeoDataFrame

## Epic 4 — Análise exploratória espacial
- [ ] #14 Mapa coroplético/preço por região
- [ ] #15 Calcular autocorrelação espacial global do preço (Moran's I) com `esda`
- [ ] #16 Calcular LISA para identificar clusters locais de preço alto/baixo
- [ ] #17 Documentar no notebook por que um modelo espacial deveria performar melhor que um global

## Epic 5 — Modelagem baseline (não-espacial)
- [ ] #18 Regressão linear (OLS) clássica
- [ ] #19 Random Forest / XGBoost com as mesmas features
- [ ] #20 Avaliar com métricas (RMSE, MAE, R²) e guardar como baseline

## Epic 6 — Reprodução do modelo GWR
- [ ] #21 Implementar GWR com `mgwr`, replicando a escolha de bandwidth via validação cruzada
- [ ] #22 Rodar o modelo e extrair os coeficientes locais
- [ ] #23 Mapear os coeficientes locais no espaço
- [ ] #24 Comparar performance do GWR com os baselines

## Epic 7 — Análise crítica e conclusões
- [ ] #25 Discutir onde GWR ganhou/perdeu do XGBoost e por quê
- [ ] #26 Testar sensibilidade do modelo ao bandwidth escolhido
- [ ] #27 Escrever relatório/notebook final no formato de um paper

## Epic 8 — Portfólio
- [ ] #28 Montar dashboard Streamlit com o mapa de coeficientes locais interativo
- [ ] #29 Escrever post/README explicando o processo
- [ ] #30 Subir no GitHub com notebooks numerados na ordem das epics
