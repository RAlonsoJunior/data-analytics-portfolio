--================================================
-- CRIANDO A TABELA STAGING
--================================================

IF OBJECT_ID('dbo.stg_fato_funil_marketing', 'U') IS NOT NULL
    DROP TABLE dbo.stg_fato_funil_marketing;

CREATE TABLE dbo.stg_fato_funil_marketing (
    id_mql                          NVARCHAR(100) NULL,
    data_primeiro_contato           NVARCHAR(50)  NULL,
    id_landing_page                 NVARCHAR(100) NULL,
    origem                          NVARCHAR(100) NULL,
    flag_convertido                 NVARCHAR(10)  NULL,
    id_vendedor                     NVARCHAR(100) NULL,
    id_sdr                          NVARCHAR(100) NULL,
    id_sr                           NVARCHAR(100) NULL,
    data_ganho                      NVARCHAR(50)  NULL,
    segmento_negocio                NVARCHAR(100) NULL,
    tipo_lead                       NVARCHAR(100) NULL,
    perfil_comportamento_lead       NVARCHAR(150) NULL,
    flag_tem_empresa                NVARCHAR(20)  NULL,
    flag_tem_gtin                   NVARCHAR(20)  NULL,
    estoque_medio_declarado         NVARCHAR(50)  NULL,
    tipo_negocio                    NVARCHAR(100) NULL,
    tamanho_catalogo_declarado      NVARCHAR(50)  NULL,
    receita_mensal_declarada        NVARCHAR(50)  NULL,
    receita_180d_pos_ganho          NVARCHAR(50)  NULL,
    pedidos_180d_pos_ganho          NVARCHAR(50)  NULL,
    nome_vendedor                   NVARCHAR(150) NULL,
    flag_tem_empresa_sn             NVARCHAR(10)  NULL,
    flag_tem_gtin_sn                NVARCHAR(10)  NULL,
    flag_tem_empresa_bit            NVARCHAR(10)  NULL,
    flag_tem_gtin_bit               NVARCHAR(10)  NULL
);

--================================================
-- IMPORTANDO A BASE
--================================================

TRUNCATE TABLE dbo.stg_fato_funil_marketing;

BULK INSERT dbo.stg_fato_funil_marketing
FROM 'C:\Users\Oem\Downloads\Projeto Marketplace 360\bases\fato_funil_marketing.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    CODEPAGE = '65001',
    TABLOCK
);

--================================================
-- CRIANDO A TABELA fato_funil_marketing
--================================================

IF OBJECT_ID('dbo.fato_funill_marketing', 'U') IS NOT NULL
    DROP TABLE dbo.fato_funill_marketing;

CREATE TABLE dbo.fato_funill_marketing (
    [ID MQL]                         NVARCHAR(100)  NULL,
    [DATA PRIMEIRO CONTATO]          DATETIME2      NULL,
    [ID LANDING PAGE]                NVARCHAR(100)  NULL,
    [ORIGEM]                         NVARCHAR(100)  NULL,
    [FLAG CONVERTIDO]                BIT            NULL,
    [ID VENDEDOR]                    NVARCHAR(100)  NULL,
    [ID SDR]                         NVARCHAR(100)  NULL,
    [ID SR]                          NVARCHAR(100)  NULL,
    [DATA GANHO]                     DATETIME2      NULL,
    [SEGMENTO NEGOCIO]               NVARCHAR(100)  NULL,
    [TIPO LEAD]                      NVARCHAR(100)  NULL,
    [PERFIL COMPORTAMENTO LEAD]      NVARCHAR(150)  NULL,
    [FLAG TEM EMPRESA]               NVARCHAR(20)   NULL,
    [FLAG TEM GTIN]                  NVARCHAR(20)   NULL,
    [ESTOQUE MEDIO DECLARADO]        INT            NULL,
    [TIPO NEGOCIO]                   NVARCHAR(100)  NULL,
    [TAMANHO CATALOGO DECLARADO]     INT            NULL,
    [RECEITA MENSAL DECLARADA]       DECIMAL(18,2)  NULL,
    [RECEITA 180D POS GANHO]         DECIMAL(18,2)  NULL,
    [PEDIDOS 180D POS GANHO]         INT            NULL,
    [VENDEDOR]                       NVARCHAR(150)  NULL,
    [FLAG TEM EMPRESA SN]            NVARCHAR(10)   NULL,
    [FLAG TEM GTIN SN]               NVARCHAR(10)   NULL,
    [FLAG TEM EMPRESA BIT]           BIT            NULL,
    [FLAG TEM GTIN BIT]              BIT            NULL
);

--================================================
-- IMPORTANDO OS DADOS PARA A TABELA
--================================================

INSERT INTO dbo.fato_funill_marketing (
    [ID MQL],
    [DATA PRIMEIRO CONTATO],
    [ID LANDING PAGE],
    [ORIGEM],
    [FLAG CONVERTIDO],
    [ID VENDEDOR],
    [ID SDR],
    [ID SR],
    [DATA GANHO],
    [SEGMENTO NEGOCIO],
    [TIPO LEAD],
    [PERFIL COMPORTAMENTO LEAD],
    [FLAG TEM EMPRESA],
    [FLAG TEM GTIN],
    [ESTOQUE MEDIO DECLARADO],
    [TIPO NEGOCIO],
    [TAMANHO CATALOGO DECLARADO],
    [RECEITA MENSAL DECLARADA],
    [RECEITA 180D POS GANHO],
    [PEDIDOS 180D POS GANHO],
    [VENDEDOR],
    [FLAG TEM EMPRESA SN],
    [FLAG TEM GTIN SN],
    [FLAG TEM EMPRESA BIT],
    [FLAG TEM GTIN BIT]
)
SELECT
    NULLIF(LTRIM(RTRIM(id_mql)), ''),
    TRY_CAST(NULLIF(LTRIM(RTRIM(data_primeiro_contato)), '') AS DATETIME2),
    NULLIF(LTRIM(RTRIM(id_landing_page)), ''),
    NULLIF(LTRIM(RTRIM(origem)), ''),
    ISNULL(TRY_CAST(NULLIF(LTRIM(RTRIM(flag_convertido)), '') AS BIT), 0),
    NULLIF(LTRIM(RTRIM(id_vendedor)), ''),
    NULLIF(LTRIM(RTRIM(id_sdr)), ''),
    NULLIF(LTRIM(RTRIM(id_sr)), ''),
    TRY_CAST(NULLIF(LTRIM(RTRIM(data_ganho)), '') AS DATETIME2),
    NULLIF(LTRIM(RTRIM(segmento_negocio)), ''),
    NULLIF(LTRIM(RTRIM(tipo_lead)), ''),
    NULLIF(LTRIM(RTRIM(perfil_comportamento_lead)), ''),
    NULLIF(LTRIM(RTRIM(flag_tem_empresa)), ''),
    NULLIF(LTRIM(RTRIM(flag_tem_gtin)), ''),
    TRY_CAST(NULLIF(LTRIM(RTRIM(estoque_medio_declarado)), '') AS INT),
    NULLIF(LTRIM(RTRIM(tipo_negocio)), ''),
    TRY_CAST(NULLIF(LTRIM(RTRIM(tamanho_catalogo_declarado)), '') AS INT),
    ISNULL(CAST(ROUND(TRY_CAST(NULLIF(LTRIM(RTRIM(receita_mensal_declarada)), '') AS DECIMAL(18,6)), 2) AS DECIMAL(18,2)), 0),
    ISNULL(CAST(ROUND(TRY_CAST(NULLIF(LTRIM(RTRIM(receita_180d_pos_ganho)), '') AS DECIMAL(18,6)), 2) AS DECIMAL(18,2)), 0),
    ISNULL(TRY_CAST(NULLIF(LTRIM(RTRIM(pedidos_180d_pos_ganho)), '') AS INT), 0),
    NULLIF(LTRIM(RTRIM(nome_vendedor)), ''),
    NULLIF(LTRIM(RTRIM(flag_tem_empresa_sn)), ''),
    NULLIF(LTRIM(RTRIM(flag_tem_gtin_sn)), ''),
    ISNULL(TRY_CAST(NULLIF(LTRIM(RTRIM(flag_tem_empresa_bit)), '') AS BIT), 0),
    ISNULL(TRY_CAST(NULLIF(LTRIM(RTRIM(flag_tem_gtin_bit)), '') AS BIT), 0)
FROM dbo.stg_fato_funil_marketing;

SELECT *
FROM        fato_funill_marketing