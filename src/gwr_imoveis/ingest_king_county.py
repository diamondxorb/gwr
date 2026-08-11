"""Ingestão do dataset King County House Sales (Kaggle) para o PostGIS."""

import argparse
from pathlib import Path

import geopandas as gpd
import pandas as pd

from gwr_imoveis.db import get_engine

KAGGLE_DATASET = "harlfoxem/housesalesprediction"
DEFAULT_RAW_DIR = Path("data/raw")
DEFAULT_CSV_NAME = "kc_house_data.csv"


def download(raw_dir: Path = DEFAULT_RAW_DIR) -> Path:
    """Baixa o dataset via Kaggle API (requer ~/.kaggle/kaggle.json) e descompacta em raw_dir."""
    from kaggle.api.kaggle_api_extended import KaggleApi

    raw_dir.mkdir(parents=True, exist_ok=True)
    api = KaggleApi()
    api.authenticate()
    api.dataset_download_files(KAGGLE_DATASET, path=str(raw_dir), unzip=True)
    return raw_dir / DEFAULT_CSV_NAME


def load_to_postgis(
    csv_path: Path, table_name: str = "king_county_house_sales", schema: str = "raw"
) -> int:
    """Lê o CSV, converte lat/long em geometria (SRID 4326) e escreve no PostGIS."""
    df = pd.read_csv(csv_path)
    gdf = gpd.GeoDataFrame(
        df,
        geometry=gpd.points_from_xy(df["long"], df["lat"]),
        crs="EPSG:4326",
    )
    engine = get_engine()
    gdf.to_postgis(table_name, engine, schema=schema, if_exists="replace", index=False)
    return len(gdf)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--csv",
        type=Path,
        default=DEFAULT_RAW_DIR / DEFAULT_CSV_NAME,
        help="Caminho do CSV (padrão: data/raw/kc_house_data.csv)",
    )
    parser.add_argument(
        "--download",
        action="store_true",
        help="Baixar o dataset via Kaggle API antes de carregar",
    )
    args = parser.parse_args()

    csv_path = download() if args.download else args.csv
    n_rows = load_to_postgis(csv_path)
    print(f"Carregadas {n_rows} linhas em raw.king_county_house_sales")
