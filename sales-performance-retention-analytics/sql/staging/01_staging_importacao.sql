-- =========================================
--  CRIANDO A TABELA fato_vendas
--==========================================


IF OBJECT_ID('dbo.fato_vendas', 'U') IS NOT NULL
    DROP TABLE dbo.fato_vendas;
GO

CREATE TABLE dbo.fato_vendas
(
    id_pedido                         NVARCHAR(50)   NOT NULL,
    id_item_pedido                    INT            NOT NULL,
    id_cliente                        NVARCHAR(50)   NOT NULL,
    id_cliente_unico                  NVARCHAR(50)   NOT NULL,
    id_produto                        NVARCHAR(50)   NOT NULL,
    id_vendedor                       NVARCHAR(50)   NOT NULL,
    id_data_compra                    DATE           NOT NULL,
    status_pedido                     NVARCHAR(50)   NULL,

    data_hora_compra                  DATETIME2(0)   NULL,
    data_hora_aprovacao               DATETIME2(0)   NULL,
    data_hora_envio_transportadora    DATETIME2(0)   NULL,
    data_hora_entrega_cliente         DATETIME2(0)   NULL,
    data_prevista_entrega             DATE           NULL,

    qtd_itens                         INT            NULL,

    valor_item                        DECIMAL(18,2)  NULL,
    valor_frete                       DECIMAL(18,2)  NULL,
    valor_bruto_item                  DECIMAL(18,2)  NULL,
    valor_pago_total                  DECIMAL(18,2)  NULL,

    qtde_pagamentos                   INT            NULL,
    qtd_parcelas                      INT            NULL,
    nota_avaliacao                    TINYINT        NULL,

    dias_ate_aprovacao                DECIMAL(10,4)  NULL,
    dias_ate_entrega                  DECIMAL(10,4)  NULL,
    dias_transportadora               DECIMAL(10,4)  NULL,

    flag_entrega_atrasada             BIT            NULL,

    nome_cliente                      NVARCHAR(150)  NULL,
    nome_vendedor                     NVARCHAR(150)  NULL,
    categoria_produto                 NVARCHAR(100)  NULL,
    categoria                         NVARCHAR(100)  NULL,
    nome_produto                      NVARCHAR(200)  NULL,
    marca                             NVARCHAR(100)  NULL,
    tipo_produto                      NVARCHAR(100)  NULL,
    linha_produto                     NVARCHAR(100)  NULL
);
GO

select *
from    fato_vendas

-- =========================================
--  CRIANDO A STAGING fato_vendas
--==========================================

IF OBJECT_ID('dbo.stg_fato_vendas', 'U') IS NOT NULL
    DROP TABLE dbo.stg_fato_vendas;
GO

CREATE TABLE dbo.stg_fato_vendas
(
    id_pedido                         NVARCHAR(200) NULL,
    id_item_pedido                    NVARCHAR(200) NULL,
    id_cliente                        NVARCHAR(200) NULL,
    id_cliente_unico                  NVARCHAR(200) NULL,
    id_produto                        NVARCHAR(200) NULL,
    id_vendedor                       NVARCHAR(200) NULL,
    id_data_compra                    NVARCHAR(200) NULL,
    status_pedido                     NVARCHAR(200) NULL,

    data_hora_compra                  NVARCHAR(200) NULL,
    data_hora_aprovacao               NVARCHAR(200) NULL,
    data_hora_envio_transportadora    NVARCHAR(200) NULL,
    data_hora_entrega_cliente         NVARCHAR(200) NULL,
    data_prevista_entrega             NVARCHAR(200) NULL,

    qtd_itens                         NVARCHAR(200) NULL,

    valor_item                        NVARCHAR(200) NULL,
    valor_frete                       NVARCHAR(200) NULL,
    valor_bruto_item                  NVARCHAR(200) NULL,
    valor_pago_total                  NVARCHAR(200) NULL,

    qtde_pagamentos                   NVARCHAR(200) NULL,
    qtd_parcelas                      NVARCHAR(200) NULL,
    nota_avaliacao                    NVARCHAR(200) NULL,

    dias_ate_aprovacao                NVARCHAR(200) NULL,
    dias_ate_entrega                  NVARCHAR(200) NULL,
    dias_transportadora               NVARCHAR(200) NULL,

    flag_entrega_atrasada             NVARCHAR(200) NULL,

    nome_cliente                      NVARCHAR(300) NULL,
    nome_vendedor                     NVARCHAR(300) NULL,
    categoria_produto                 NVARCHAR(200) NULL,
    categoria                         NVARCHAR(200) NULL,
    nome_produto                      NVARCHAR(300) NULL,
    marca                             NVARCHAR(200) NULL,
    tipo_produto                      NVARCHAR(200) NULL,
    linha_produto                     NVARCHAR(200) NULL
);
GO

-- =========================================
--                 IMPORTANDO
--==========================================

TRUNCATE TABLE dbo.stg_fato_vendas;
GO

BULK INSERT dbo.stg_fato_vendas
FROM 'C:\Users\Oem\Downloads\Projeto Marketplace 360\bases\fato_vendas_marketplace_corrigida.csv'
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
FROM    stg_fato_vendas

-- ============================================
--  CARGA DA STAGING PARA A TABELA fato_vendas
--=============================================

TRUNCATE TABLE dbo.fato_vendas;
GO

INSERT INTO dbo.fato_vendas
(
    id_pedido,
    id_item_pedido,
    id_cliente,
    id_cliente_unico,
    id_produto,
    id_vendedor,
    id_data_compra,
    status_pedido,

    data_hora_compra,
    data_hora_aprovacao,
    data_hora_envio_transportadora,
    data_hora_entrega_cliente,
    data_prevista_entrega,

    qtd_itens,

    valor_item,
    valor_frete,
    valor_bruto_item,
    valor_pago_total,

    qtde_pagamentos,
    qtd_parcelas,
    nota_avaliacao,

    dias_ate_aprovacao,
    dias_ate_entrega,
    dias_transportadora,

    flag_entrega_atrasada,

    nome_cliente,
    nome_vendedor,
    categoria_produto,
    categoria,
    nome_produto,
    marca,
    tipo_produto,
    linha_produto
)
SELECT
    LTRIM(RTRIM(id_pedido)),

    TRY_CONVERT(INT, NULLIF(LTRIM(RTRIM(id_item_pedido)), '')),

    LTRIM(RTRIM(id_cliente)),
    LTRIM(RTRIM(id_cliente_unico)),
    LTRIM(RTRIM(id_produto)),
    LTRIM(RTRIM(id_vendedor)),

    TRY_CONVERT(DATE, NULLIF(LTRIM(RTRIM(id_data_compra)), ''), 112),

    NULLIF(LTRIM(RTRIM(status_pedido)), ''),

    TRY_CONVERT(DATETIME2(0), NULLIF(LTRIM(RTRIM(data_hora_compra)), ''), 120),
    TRY_CONVERT(DATETIME2(0), NULLIF(LTRIM(RTRIM(data_hora_aprovacao)), ''), 120),
    TRY_CONVERT(DATETIME2(0), NULLIF(LTRIM(RTRIM(data_hora_envio_transportadora)), ''), 120),
    TRY_CONVERT(DATETIME2(0), NULLIF(LTRIM(RTRIM(data_hora_entrega_cliente)), ''), 120),
    TRY_CONVERT(DATE, NULLIF(LTRIM(RTRIM(data_prevista_entrega)), ''), 23),

    TRY_CONVERT(INT, NULLIF(LTRIM(RTRIM(qtd_itens)), '')),

    TRY_CONVERT(DECIMAL(18,2), NULLIF(REPLACE(LTRIM(RTRIM(valor_item)), ',', '.'), '')),
    TRY_CONVERT(DECIMAL(18,2), NULLIF(REPLACE(LTRIM(RTRIM(valor_frete)), ',', '.'), '')),
    TRY_CONVERT(DECIMAL(18,2), NULLIF(REPLACE(LTRIM(RTRIM(valor_bruto_item)), ',', '.'), '')),
    TRY_CONVERT(DECIMAL(18,2), NULLIF(REPLACE(LTRIM(RTRIM(valor_pago_total)), ',', '.'), '')),

    TRY_CONVERT(INT, TRY_CONVERT(DECIMAL(18,2), NULLIF(REPLACE(LTRIM(RTRIM(qtde_pagamentos)), ',', '.'), ''))),
    TRY_CONVERT(INT, TRY_CONVERT(DECIMAL(18,2), NULLIF(REPLACE(LTRIM(RTRIM(qtd_parcelas)), ',', '.'), ''))),
    TRY_CONVERT(TINYINT, NULLIF(LTRIM(RTRIM(nota_avaliacao)), '')),

    TRY_CONVERT(DECIMAL(10,4), NULLIF(REPLACE(LTRIM(RTRIM(dias_ate_aprovacao)), ',', '.'), '')),
    TRY_CONVERT(DECIMAL(10,4), NULLIF(REPLACE(LTRIM(RTRIM(dias_ate_entrega)), ',', '.'), '')),
    TRY_CONVERT(DECIMAL(10,4), NULLIF(REPLACE(LTRIM(RTRIM(dias_transportadora)), ',', '.'), '')),

    TRY_CONVERT(BIT, NULLIF(LTRIM(RTRIM(flag_entrega_atrasada)), '')),

    NULLIF(LTRIM(RTRIM(nome_cliente)), ''),
    NULLIF(LTRIM(RTRIM(nome_vendedor)), ''),
    NULLIF(LTRIM(RTRIM(categoria_produto)), ''),
    NULLIF(LTRIM(RTRIM(categoria)), ''),
    NULLIF(LTRIM(RTRIM(nome_produto)), ''),
    NULLIF(LTRIM(RTRIM(marca)), ''),
    NULLIF(LTRIM(RTRIM(tipo_produto)), ''),
    NULLIF(LTRIM(RTRIM(linha_produto)), '')
FROM dbo.stg_fato_vendas;
GO

select *
from    fato_vendas