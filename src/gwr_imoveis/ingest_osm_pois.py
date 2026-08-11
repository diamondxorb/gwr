"""Download de POIs do OpenStreetMap (via Overpass API) para a região do King County.

Fala direto com a Overpass API em vez de usar `osmnx.features_from_bbox`: para
categorias com muita variedade de tags (ex. `shop=*`), a montagem do GeoDataFrame
do osmnx (uma coluna por tag distinta) fica lenta demais. Como só precisamos de
geometria + nome + categoria, pedimos `out center` (centro de ways/relations em
vez da geometria completa) e montamos o GeoDataFrame manualmente.
"""

import argparse
import os
from pathlib import Path

import geopandas as gpd
import requests
from dotenv import load_dotenv
from shapely.geometry import Point

load_dotenv()

OVERPASS_URL = "https://overpass-api.de/api/interpreter"
OVERPASS_TIMEOUT_S = 180
# O Apache do overpass-api.de rejeita (406) requests com o User-Agent padrão da
# lib `requests` — precisa de um UA identificável, mesma política do Nominatim.
USER_AGENT = os.getenv("NOMINATIM_USER_AGENT", "gwr-precos-imoveis")

DEFAULT_OUT_DIR = Path("data/external")

# bbox = (left, bottom, right, top) = (west, south, east, north), em EPSG:4326.
# Calculado a partir do bounding box real dos imóveis em raw.king_county_house_sales
# (em vez do condado inteiro, bem maior que a área coberta pelos dados).
DEFAULT_BBOX = (-122.519, 47.1559, -121.315, 47.7776)

CATEGORIES: dict[str, dict] = {
    "escolas": {"amenity": "school"},
    "transporte": {
        "highway": "bus_stop",
        "railway": ["station", "halt"],
        "amenity": "bus_station",
    },
    "parques": {"leisure": "park"},
    "comercio": {"shop": True},
}


def _tag_clauses(tags: dict) -> list[str]:
    """Converte {'shop': True} / {'railway': ['station', 'halt']} em filtros Overpass QL."""
    clauses = []
    for key, value in tags.items():
        if value is True:
            clauses.append(f'["{key}"]')
        elif isinstance(value, list):
            clauses.extend(f'["{key}"="{v}"]' for v in value)
        else:
            clauses.append(f'["{key}"="{value}"]')
    return clauses


def _build_query(tags: dict, bbox: tuple[float, float, float, float]) -> str:
    west, south, east, north = bbox
    overpass_bbox = f"{south},{west},{north},{east}"
    statements = [
        f"{elem}{clause}({overpass_bbox});"
        for clause in _tag_clauses(tags)
        for elem in ("node", "way", "relation")
    ]
    body = "\n  ".join(statements)
    return f"[out:json][timeout:{OVERPASS_TIMEOUT_S}];\n(\n  {body}\n);\nout center;"


def download_category(
    category: str, tags: dict, bbox: tuple[float, float, float, float], out_dir: Path
) -> Path:
    """Baixa uma categoria de POI e salva como GeoParquet em out_dir/<categoria>.parquet."""
    query = _build_query(tags, bbox)
    response = requests.post(
        OVERPASS_URL,
        data={"data": query},
        timeout=OVERPASS_TIMEOUT_S + 20,
        headers={"User-Agent": USER_AGENT},
    )
    response.raise_for_status()
    elements = response.json()["elements"]

    rows = []
    for el in elements:
        if el["type"] == "node":
            lon, lat = el["lon"], el["lat"]
        else:
            center = el.get("center")
            if center is None:
                continue
            lon, lat = center["lon"], center["lat"]
        rows.append(
            {
                "osmid": el["id"],
                "element": el["type"],
                "name": el.get("tags", {}).get("name"),
                "categoria": category,
                "geometry": Point(lon, lat),
            }
        )

    gdf = gpd.GeoDataFrame(rows, geometry="geometry", crs="EPSG:4326")
    out_dir.mkdir(parents=True, exist_ok=True)
    out_path = out_dir / f"{category}.parquet"
    gdf.to_parquet(out_path)
    return out_path


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--categoria",
        choices=list(CATEGORIES) + ["todas"],
        default="todas",
        help="Categoria de POI a baixar (padrão: todas)",
    )
    parser.add_argument("--out-dir", type=Path, default=DEFAULT_OUT_DIR)
    args = parser.parse_args()

    categorias = list(CATEGORIES) if args.categoria == "todas" else [args.categoria]
    for categoria in categorias:
        path = download_category(categoria, CATEGORIES[categoria], DEFAULT_BBOX, args.out_dir)
        print(f"{categoria}: salvo em {path}")
