"""Conexão centralizada com o PostGIS via SQLAlchemy."""

import os

from dotenv import load_dotenv
from sqlalchemy import create_engine
from sqlalchemy.engine import Engine

load_dotenv()


def get_engine() -> Engine:
    """Cria a engine SQLAlchemy a partir das variáveis de ambiente (.env)."""
    user = os.getenv("POSTGRES_USER", "gwr_user")
    password = os.getenv("POSTGRES_PASSWORD", "gwr_pass")
    host = os.getenv("POSTGRES_HOST", "localhost")
    port = os.getenv("POSTGRES_PORT", "5432")
    db = os.getenv("POSTGRES_DB", "gwr_imoveis")

    url = f"postgresql+psycopg2://{user}:{password}@{host}:{port}/{db}"
    return create_engine(url)


if __name__ == "__main__":
    # Teste rápido de conexão: python -m gwr_imoveis.db
    engine = get_engine()
    with engine.connect() as conn:
        version = conn.exec_driver_sql("SELECT PostGIS_Version();").scalar()
        print(f"Conectado! PostGIS version: {version}")
