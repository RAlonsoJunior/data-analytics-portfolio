-- =========================================
--  CRIANDO A COLUNA STATUS DA ENTREGA
--==========================================

ALTER TABLE dbo.fato_vendas
ADD status_entrega VARCHAR(30);

-- =========================================
--  CLASSIFICANDO CORRETAMENTE
--==========================================

UPDATE dbo.fato_vendas
SET status_entrega =
    CASE
        WHEN data_hora_entrega_cliente IS NOT NULL THEN 'ENTREGUE'
        WHEN data_hora_envio_transportadora IS NOT NULL THEN 'EM TRANSPORTE'
        WHEN data_hora_aprovacao IS NOT NULL THEN 'APROVADO'
        ELSE 'PENDENTE'
    END;

-- =========================================
--  AJUSTANDO AS DATAS
--==========================================

SELECT *
FROM dbo.fato_vendas
WHERE 
    (data_hora_aprovacao IS NOT NULL AND data_hora_compra IS NOT NULL AND data_hora_aprovacao < data_hora_compra)
 OR (data_hora_envio_transportadora IS NOT NULL AND data_hora_aprovacao IS NOT NULL AND data_hora_envio_transportadora < data_hora_aprovacao)
 OR (data_hora_entrega_cliente IS NOT NULL AND data_hora_envio_transportadora IS NOT NULL AND data_hora_entrega_cliente < data_hora_envio_transportadora);

-- =========================================
--  CRIANDO COLUNAS NOVAS
--  dias_aprovacao_int
--  dias_entrega_int
--  dias_transportadora_int
--==========================================

ALTER TABLE dbo.fato_vendas
ADD dias_aprovacao_int INT,
    dias_entrega_int INT,
    dias_transportadora_int INT;

-- ======================================================
--  PREEENCHENDO COM TRATAMENTO DE NULL + ARREDONDAMENTO
--=======================================================

UPDATE dbo.fato_vendas
SET 
    dias_aprovacao_int = 
        CASE 
            WHEN dias_ate_aprovacao IS NULL THEN NULL
            ELSE CAST(ROUND(dias_ate_aprovacao, 0) AS INT)
        END,

    dias_entrega_int = 
        CASE 
            WHEN dias_ate_entrega IS NULL THEN NULL
            ELSE CAST(ROUND(dias_ate_entrega, 0) AS INT)
        END,

    dias_transportadora_int = 
        CASE 
            WHEN dias_transportadora IS NULL THEN NULL
            ELSE CAST(ROUND(dias_transportadora, 0) AS INT)
        END;



-- ==============================================
--  COLUNAS COM DIVERGENCIAS DE TAMNAHO DE TEXTO
--===============================================
ALTER TABLE dbo.fato_vendas
ALTER COLUMN categoria NVARCHAR(150);

ALTER TABLE dbo.fato_vendas
ALTER COLUMN nome_produto NVARCHAR(300);

ALTER TABLE dbo.fato_vendas
ALTER COLUMN marca NVARCHAR(150);

ALTER TABLE dbo.fato_vendas
ALTER COLUMN tipo_produto NVARCHAR(150);

ALTER TABLE dbo.fato_vendas
ALTER COLUMN linha_produto NVARCHAR(150);

 

SELECT *
FROM        fato_vendas

-- =============================================
--  FAZENDO A ALTERAÇÃO DAS COLUNAS DIVERGENTES
--==============================================

UPDATE f
SET
    f.categoria_produto = d.categoria_produto,
    f.categoria         = d.categoria,
    f.nome_produto      = d.nome_produto,
    f.marca             = d.marca,
    f.tipo_produto      = d.tipo_produto,
    f.linha_produto     = d.linha_produto
FROM dbo.fato_vendas f
INNER JOIN dbo.dim_produto d
    ON f.id_produto = d.id_produto;

-- =========================================
--             CRIANDO VIEW
--==========================================

CREATE OR ALTER VIEW dbo.VW_FATO_VENDAS AS
SELECT
    id_pedido                           AS [ID PEDIDO],
    id_item_pedido                      AS [ID ITEM],
    id_cliente                          AS [ID CLIENTE],
    [id_cliente_unico]                  AS [ID CLIENTE UNICO],
    id_produto                          AS [ID PRODUTO],
    id_vendedor                         AS [ID VENDEDOR],
    id_data_compra                      AS [DATA COMPRA],

    CASE 
        WHEN status_pedido = 'delivered'   THEN 'Entregue'
        WHEN status_pedido = 'canceled'    THEN 'Cancelado'
        WHEN status_pedido = 'approved'    THEN 'Aprovado'
        WHEN status_pedido = 'shipped'     THEN 'Enviado'
        WHEN status_pedido = 'invoiced'    THEN 'Faturado'
        WHEN status_pedido = 'unavailable' THEN 'Indisponivel'
        ELSE status_pedido
    END                                 AS [STATUS],

    data_hora_compra                    AS [HORA COMPRA],
    [data_hora_aprovacao]               AS [DATA APROVACAO],
    data_hora_envio_transportadora      AS [DATA TRANSPORTADORA],
    data_hora_entrega_cliente           AS [DATA ENTREGA],
    data_prevista_entrega               AS [PREVISAO DE ENTREGA],

    qtd_itens                           AS [QTD ITENS],
    valor_item                          AS [VALOR ITEM],
    valor_frete                         AS [VALOR FRETE],
    valor_bruto_item                    AS [VALOR BRUTO],
    valor_pago_total                    AS [VALOR TOTAL],
    qtde_pagamentos                     AS [QTDE PAGAMENTOS],
    qtd_parcelas                        AS [PARCELAS],
    nota_avaliacao                      AS [AVALIACAO],

    flag_entrega_atrasada               AS [ENTREGA ATRASADA],

    nome_cliente                        AS [CLIENTE],
    nome_vendedor                       AS [VENDEDOR],
    categoria                           AS [CATEGORIA],
    nome_produto                        AS [PRODUTO],
    marca                               AS [MARCA],
    tipo_produto                        AS [TIPO PRODUTO],
    linha_produto                       AS [LINHA PRODUTO],
    status_entrega                      AS [STATUS ENTREGA],

    dias_aprovacao_int                  AS [DIAS P/ APROVACAO],
    dias_entrega_int                    AS [DIAS P/ ENTREGA],
    dias_transportadora_int             AS [DIAS P/ TRANSPORTADORA]

FROM dbo.fato_vendas;
GO

SELECT *
FROM    VW_FATO_VENDAS