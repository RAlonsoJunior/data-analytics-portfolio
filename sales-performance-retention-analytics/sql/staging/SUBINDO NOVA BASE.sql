--============================================================
-- LIMPANDO STAGING
--============================================================

EXEC dbo.sp_limpa_staging;
GO

--============================================================
--				IMPORTANDO      stg_base_churn_clientes
--============================================================

TRUNCATE TABLE dbo.stg_base_churn_clientes;
GO

BULK INSERT dbo.stg_base_churn_clientes
FROM 'C:\SQLIMPORT\PROJETO PERFORMANCE 360\AtualizacaoDeBase\base_churn_clientes_update_20181231.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0A',
    CODEPAGE = '65001',
    TABLOCK,
    KEEPNULLS
);
GO

SELECT *
FROM    stg_base_churn_clientes

--============================================================
--				IMPORTANDO      stg_dim_cliente_update
--============================================================

TRUNCATE TABLE dbo.stg_dim_cliente_update;
GO

BULK INSERT dbo.stg_dim_cliente_update
FROM 'C:\SQLIMPORT\PROJETO PERFORMANCE 360\AtualizacaoDeBase\dim_cliente_update_20180904_20181231.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0A',
    CODEPAGE = '65001',
    TABLOCK,
    KEEPNULLS
);
GO

SELECT *
FROM    stg_dim_cliente_update


--============================================================
--				IMPORTANDO      stg_dim_produto_update
--============================================================

TRUNCATE TABLE dbo.stg_dim_produto_update;
GO

BULK INSERT dbo.stg_dim_produto_update
FROM 'C:\SQLIMPORT\PROJETO PERFORMANCE 360\AtualizacaoDeBase\dim_produto_update_20180904_20181231.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ';',
    ROWTERMINATOR = '0x0A',
    CODEPAGE = '65001',
    TABLOCK,
    KEEPNULLS
);
GO

SELECT  *
FROM dbo.stg_dim_produto_update;


--============================================================
--				IMPORTANDO      stg_dim_vendedor_update
--============================================================

TRUNCATE TABLE dbo.stg_dim_vendedor_update;
GO

BULK INSERT dbo.stg_dim_vendedor_update
FROM 'C:\SQLIMPORT\PROJETO PERFORMANCE 360\AtualizacaoDeBase\dim_vendedor_update_20180904_20181231.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ';',
    ROWTERMINATOR = '0x0A',
    CODEPAGE = '65001',
    TABLOCK,
    KEEPNULLS
);
GO

SELECT TOP 20 *
FROM dbo.stg_dim_vendedor_update;

--============================================================
--				IMPORTANDO      stg_fato_funil_marketing
--============================================================

TRUNCATE TABLE dbo.stg_fato_funil_marketing;
GO

BULK INSERT dbo.stg_fato_funil_marketing
FROM 'C:\SQLIMPORT\PROJETO PERFORMANCE 360\AtualizacaoDeBase\fato_funil_marketing_update_20180904_20181231.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0A',
    CODEPAGE = '65001',
    TABLOCK,
    KEEPNULLS
);
GO

SELECT TOP 20 *
FROM dbo.stg_fato_funil_marketing;



--============================================================
--				IMPORTANDO      stg_fato_vendas
--============================================================

TRUNCATE TABLE dbo.stg_fato_vendas;
GO

BULK INSERT dbo.stg_fato_vendas
FROM 'C:\SQLIMPORT\PROJETO PERFORMANCE 360\AtualizacaoDeBase\fato_vendas_update_20180904_20181231.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0A',
    CODEPAGE = '65001',
    TABLOCK,
    KEEPNULLS
);
GO

SELECT TOP 20 *
FROM dbo.stg_fato_vendas;

--============================================================
--				VERIFICANDO O NOME DAS COLUNAS
--============================================================

    SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'VW_FATO_VENDAS'
ORDER BY ORDINAL_POSITION;

--============================================================
--				VALIDANDO AS STAGING
--============================================================

SELECT 'stg_dim_cliente_update' AS tabela, COUNT(*) AS total FROM dbo.stg_dim_cliente_update
UNION ALL
SELECT 'stg_dim_produto_update', COUNT(*) FROM dbo.stg_dim_produto_update
UNION ALL
SELECT 'stg_dim_vendedor_update', COUNT(*) FROM dbo.stg_dim_vendedor_update
UNION ALL
SELECT 'stg_fato_vendas', COUNT(*) FROM dbo.stg_fato_vendas
UNION ALL
SELECT 'stg_fato_funil_marketing', COUNT(*) FROM dbo.stg_fato_funil_marketing
UNION ALL
SELECT 'stg_base_churn_clientes', COUNT(*) FROM dbo.stg_base_churn_clientes;


--============================================================
--				EXECUTANDO AS CARGAS
--============================================================

EXEC dbo.sp_carga_dim_cliente;
GO

EXEC dbo.sp_carga_dim_produto;
GO

EXEC dbo.sp_carga_dim_vendedor;
GO

EXEC dbo.sp_carga_fato_vendas;
GO

EXEC dbo.sp_carga_fato_funil_marketing;
GO

EXEC dbo.sp_carga_churn_clientes;
GO

--============================================================
--				VALIDANDO AS CARGAS NA TABELA FINAL
--============================================================

SELECT 'dim_cliente' AS tabela, COUNT(*) AS total FROM dbo.dim_cliente
UNION ALL
SELECT 'dim_produto', COUNT(*) FROM dbo.dim_produto
UNION ALL
SELECT 'dim_vendedor', COUNT(*) FROM dbo.dim_vendedor
UNION ALL
SELECT 'fato_vendas', COUNT(*) FROM dbo.fato_vendas
UNION ALL
SELECT 'fato_funil_marketing', COUNT(*) FROM dbo.fato_funil_marketing
UNION ALL
SELECT 'churn_clientes', COUNT(*) FROM dbo.churn_clientes;

--============================================================
--				VALIDANDO A CARGA INCREMENTAL
--============================================================

SELECT 
    MIN(data_hora_compra) AS menor_data,
    MAX(data_hora_compra) AS maior_data,
    COUNT(*) AS total
FROM dbo.fato_vendas;

--============================================================
--				VALIDANDO DUPLICIDADE
--============================================================

-- FATO VENDAS

SELECT 
    id_pedido,
    id_item_pedido,
    COUNT(*) AS qtd
FROM dbo.fato_vendas
GROUP BY id_pedido, id_item_pedido
HAVING COUNT(*) > 1;

-- FUNIL

SELECT 
    [ID MQL],
    COUNT(*) AS qtd
FROM dbo.fato_funil_marketing
GROUP BY [ID MQL]
HAVING COUNT(*) > 1;

--============================================================
--				VALIDANDO VW_FATO_VENDAS
--============================================================

SELECT TOP 50 *
FROM dbo.VW_FATO_VENDAS;

-- PERÍODO

SELECT 
    MIN([DATA COMPRA]) AS menor_data,
    MAX([DATA COMPRA]) AS maior_data,
    COUNT(*) AS total
FROM dbo.VW_FATO_VENDAS;