--================================================
-- CRIANDO A TABELA churn_clientes
--================================================

IF OBJECT_ID('dbo.churn_clientes', 'U') IS NOT NULL
    DROP TABLE dbo.churn_clientes;

CREATE TABLE dbo.churn_clientes (
    [ID CLIENTE]               NVARCHAR(50)   NULL,
    [ID UNICO CLIENTE]         NVARCHAR(50)   NULL,
    [CLIENTE]                  NVARCHAR(200)  NULL,
    [PRIMEIRA COMPRA]          DATETIME2      NULL,
    [ULTIMA COMPRA]            DATETIME2      NULL,
    [QTDE PEDIDOS]             INT            NULL,
    [RECEITA]                  DECIMAL(18,2)  NULL,
    [TICKET MEDIO]             DECIMAL(18,2)  NULL,
    [DIAS DA ULTIMA COMPRA]    INT            NULL,
    [FLAG RECOMPRA]            BIT            NULL,
    [FLAG CHURN 90D]           BIT            NULL,
    [FLAG CHURN 120D]          BIT            NULL,
    [FLAG CHURN 180D]          BIT            NULL
);

--================================================
-- CRIANDO A stg_churn_clientes
--================================================

IF OBJECT_ID('dbo.stg_base_churn_clientes', 'U') IS NOT NULL
    DROP TABLE dbo.stg_base_churn_clientes;

CREATE TABLE dbo.stg_base_churn_clientes (
    id_cliente                    NVARCHAR(100) NULL,
    id_cliente_unico              NVARCHAR(100) NULL,
    nome_cliente                  NVARCHAR(200) NULL,
    data_primeira_compra          NVARCHAR(50)  NULL,
    data_ultima_compra            NVARCHAR(50)  NULL,
    qtd_pedidos                   NVARCHAR(50)  NULL,
    receita_total                 NVARCHAR(50)  NULL,
    ticket_medio_cliente          NVARCHAR(50)  NULL,
    dias_desde_ultima_compra      NVARCHAR(50)  NULL,
    flag_recompra                 NVARCHAR(10)  NULL,
    flag_churn_90d                NVARCHAR(10)  NULL,
    flag_churn_120d               NVARCHAR(10)  NULL,
    flag_churn_180d               NVARCHAR(10)  NULL
);

--================================================
-- IMPORTANDO A BASE
--================================================

BULK INSERT dbo.stg_base_churn_clientes
FROM 'C:\Users\Oem\Downloads\Projeto Marketplace 360\bases\base_churn_clientes_com_nome.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    TABLOCK,
    CODEPAGE = '65001'
);

--================================================
-- INSERINDO OS DADOS NA churn_clientes
--================================================

INSERT INTO dbo.churn_clientes (
    [ID CLIENTE],
    [ID UNICO CLIENTE],
    [CLIENTE],
    [PRIMEIRA COMPRA],
    [ULTIMA COMPRA],
    [QTDE PEDIDOS],
    [RECEITA],
    [TICKET MEDIO],
    [DIAS DA ULTIMA COMPRA],
    [FLAG RECOMPRA],
    [FLAG CHURN 90D],
    [FLAG CHURN 120D],
    [FLAG CHURN 180D]
)
SELECT
    NULLIF(LTRIM(RTRIM(id_cliente)), ''),
    NULLIF(LTRIM(RTRIM(id_cliente_unico)), ''),
    NULLIF(LTRIM(RTRIM(nome_cliente)), ''),

    TRY_CAST(NULLIF(LTRIM(RTRIM(data_primeira_compra)), '') AS DATETIME2),
    TRY_CAST(NULLIF(LTRIM(RTRIM(data_ultima_compra)), '') AS DATETIME2),

    ISNULL(TRY_CAST(NULLIF(LTRIM(RTRIM(qtd_pedidos)), '') AS INT), 0),

    ISNULL(
        CAST(
            ROUND(
                TRY_CAST(NULLIF(LTRIM(RTRIM(receita_total)), '') AS DECIMAL(18,6)),
                2
            ) AS DECIMAL(18,2)
        ),
        0
    ),

    ISNULL(
        CAST(
            ROUND(
                TRY_CAST(NULLIF(LTRIM(RTRIM(ticket_medio_cliente)), '') AS DECIMAL(18,6)),
                2
            ) AS DECIMAL(18,2)
        ),
        0
    ),

    ISNULL(TRY_CAST(NULLIF(LTRIM(RTRIM(dias_desde_ultima_compra)), '') AS INT), 0),

    ISNULL(TRY_CAST(NULLIF(LTRIM(RTRIM(flag_recompra)), '') AS BIT), 0),
    ISNULL(TRY_CAST(NULLIF(LTRIM(RTRIM(flag_churn_90d)), '') AS BIT), 0),
    ISNULL(TRY_CAST(NULLIF(LTRIM(RTRIM(flag_churn_120d)), '') AS BIT), 0),
    ISNULL(TRY_CAST(NULLIF(LTRIM(RTRIM(flag_churn_180d)), '') AS BIT), 0)
FROM dbo.stg_base_churn_clientes;


select *
from    churn_clientes