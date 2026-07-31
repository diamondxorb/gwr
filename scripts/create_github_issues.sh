#!/usr/bin/env bash
# Cria labels (uma por Epic) e uma Issue por task no repositório atual,
# usando o GitHub CLI. Rode a partir da raiz do repositório, já com
# `gh auth login` feito e dentro do repo remoto correto.
#
# Uso: bash scripts/create_github_issues.sh

set -euo pipefail

if ! command -v gh &> /dev/null; then
    echo "GitHub CLI (gh) não encontrado. Instale em https://cli.github.com/ e rode 'gh auth login' antes."
    exit 1
fi

# Cria os labels de epic (idempotente: ignora erro se já existir)
EPICS=(
  "epic-1:1f77b4:Infraestrutura e ambiente"
  "epic-2:ff7f0e:Ingestão e preparação dos dados"
  "epic-3:2ca02c:Engenharia de features espaciais"
  "epic-4:d62728:Análise exploratória espacial"
  "epic-5:9467bd:Modelagem baseline"
  "epic-6:8c564b:Reprodução do modelo GWR"
  "epic-7:e377c2:Análise crítica e conclusões"
  "epic-8:7f7f7f:Portfólio"
)

for epic in "${EPICS[@]}"; do
  IFS=":" read -r name color desc <<< "$epic"
  gh label create "$name" --color "$color" --description "$desc" --force
done

# Formato de cada linha: epic_label|título da issue
TASKS=(
  "epic-1|Subir PostGIS localmente via Docker Compose"
  "epic-1|Criar ambiente Python com dependências geoespaciais"
  "epic-1|Estruturar repositório e README inicial"
  "epic-1|Testar conexão Python <-> PostGIS"
  "epic-2|Baixar e carregar King County House Sales no PostGIS"
  "epic-2|Baixar POIs do OSM via osmnx"
  "epic-2|Carregar camadas do OSM no PostGIS por categoria"
  "epic-2|Validar e reprojetar SRID para CRS métrico local"
  "epic-2|Checar qualidade dos dados (duplicatas, outliers, geometria inválida)"
  "epic-2|Decidir estratégia de geocodificação do ITBI-SP (Nominatim vs join Setor-Quadra-Lote)"
  "epic-2|Baixar malha de lotes (SQL) do GeoSampa e carregar no PostGIS"
  "epic-2|Baixar e carregar arquivos mensais de transações ITBI"
  "epic-2|Implementar join espacial ITBI x lotes GeoSampa pelo SQL"
  "epic-2|Medir e documentar taxa de match do join ITBI x GeoSampa"
  "epic-3|Calcular distância ao POI mais próximo (ST_Distance + LATERAL JOIN)"
  "epic-3|Calcular contagem de POIs em raio (ST_DWithin)"
  "epic-3|Criar índice espacial GIST e comparar performance de query"
  "epic-3|Exportar dataset final consolidado para GeoDataFrame"
  "epic-4|Mapa coroplético de preço por região"
  "epic-4|Calcular Moran's I (autocorrelação espacial global)"
  "epic-4|Calcular LISA (clusters locais)"
  "epic-4|Documentar justificativa para uso de modelo espacial"
  "epic-5|Baseline OLS"
  "epic-5|Baseline Random Forest / XGBoost"
  "epic-5|Avaliar baselines com RMSE, MAE, R2"
  "epic-6|Implementar GWR com mgwr e validação cruzada de bandwidth"
  "epic-6|Extrair coeficientes locais do modelo"
  "epic-6|Mapear coeficientes locais no espaço"
  "epic-6|Comparar performance do GWR com os baselines"
  "epic-7|Discutir onde GWR ganhou/perdeu do XGBoost"
  "epic-7|Testar sensibilidade ao bandwidth"
  "epic-7|Escrever relatório final estilo paper"
  "epic-8|Montar dashboard Streamlit"
  "epic-8|Escrever post/README explicando o processo"
  "epic-8|Organizar notebooks numerados no GitHub"
)

for task in "${TASKS[@]}"; do
  IFS="|" read -r epic title <<< "$task"
  gh issue create --title "$title" --label "$epic" --body "Task gerada a partir do BACKLOG.md."
done

echo "Concluído: labels e issues criadas a partir do backlog."
