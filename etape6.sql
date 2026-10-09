-- 1. Export des commandes au format Parquet vers S3
COPY orders
TO (getvariable('bucket') || '/analytics/orders.parquet')
(FORMAT parquet);

-- 2. Vérifier le fichier Parquet
SELECT count(*) AS total_orders
FROM read_parquet(getvariable('bucket') || '/analytics/orders.parquet');

-- 3. Examiner la compression Parquet
SELECT
    path_in_schema,
    type,
    compression,
    total_compressed_size,
    total_uncompressed_size
FROM parquet_metadata(
    getvariable('bucket') || '/analytics/orders.parquet'
);

-- 4. Partitionner les commandes par produit
COPY orders
TO (getvariable('bucket') || '/analytics/orders_by_product')
(FORMAT parquet, PARTITION_BY (product));

-- 5. Afficher les fichiers créés
SELECT file
FROM glob(
    getvariable('bucket') || '/analytics/orders_by_product/**'
);

-- 6. Tester le filtrage des partitions
EXPLAIN ANALYZE
SELECT count(*)
FROM read_parquet(
    getvariable('bucket') || '/analytics/orders_by_product/*/*.parquet'
)
WHERE product = 'cookie';
