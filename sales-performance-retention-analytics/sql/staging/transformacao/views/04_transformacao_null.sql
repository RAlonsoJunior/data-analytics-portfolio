CREATE OR ALTER VIEW VW_FATO_VENDAS AS
SELECT

-- =========================
-- IDENTIFICAÇÃO
-- =========================
ISNULL(id_pedido, 'N/A')                   AS [ID PEDIDO],
ISNULL(id_item_pedido, 0)                  AS [ID ITEM],
ISNULL(id_cliente, 'N/A')                  AS [ID CLIENTE],
ISNULL(id_cliente_unico, 'N/A')            AS [ID CLIENTE UNICO],
ISNULL(id_produto, 'N/A')                  AS [ID PRODUTO],
ISNULL(id_vendedor, 'N/A')                 AS [ID VENDEDOR],

-- =========================
-- NOMES
-- =========================
ISNULL(nome_cliente, 'NÃO INFORMADO')      AS [CLIENTE],
ISNULL(nome_vendedor, 'NÃO INFORMADO')     AS [VENDEDOR],
ISNULL(categoria, 'NÃO INFORMADO')         AS [CATEGORIA],
ISNULL(nome_produto, 'NÃO INFORMADO')      AS [PRODUTO],
ISNULL(marca, 'NÃO INFORMADO')             AS [MARCA],
ISNULL(tipo_produto, 'NÃO INFORMADO')      AS [TIPO PRODUTO],
ISNULL(linha_produto, 'NÃO INFORMADO')     AS [LINHA PRODUTO],

-- =========================
-- DATAS
-- =========================
data_hora_compra                           AS [DATA COMPRA],
data_hora_aprovacao                        AS [DATA APROVACAO],
data_hora_envio_transportadora             AS [DATA TRANSPORTADORA],
data_hora_entrega_cliente                  AS [DATA ENTREGA],
data_prevista_entrega                      AS [PREVISAO ENTREGA],

-- =========================
-- STATUS
-- =========================
CASE 
    WHEN status_pedido = 'delivered'   THEN 'Entregue'
    WHEN status_pedido = 'shipped'     THEN 'Enviado'
    WHEN status_pedido = 'approved'    THEN 'Aprovado'
    WHEN status_pedido = 'canceled'    THEN 'Cancelado'
    WHEN status_pedido = 'invoiced'    THEN 'Faturado'
    WHEN status_pedido = 'processing'  THEN 'Em Processamento'
    WHEN status_pedido = 'unavailable' THEN 'Indisponível'
    WHEN status_pedido IS NULL         THEN 'NÃO INFORMADO'
    ELSE status_pedido
END AS [STATUS],

ISNULL(status_entrega, 'NÃO INFORMADO')    AS [STATUS ENTREGA],

-- =========================
-- MÉTRICAS
-- =========================
ISNULL(qtd_itens, 0)                       AS [QTD ITENS],
ISNULL(valor_item, 0)                      AS [VALOR ITEM],
ISNULL(valor_frete, 0)                     AS [VALOR FRETE],
ISNULL(valor_bruto_item, 0)                AS [VALOR BRUTO],
ISNULL(valor_pago_total, 0)                AS [VALOR TOTAL],

-- =========================
-- PAGAMENTO
-- =========================
ISNULL(qtde_pagamentos, 0)                 AS [QTD PAGAMENTOS],
ISNULL(qtd_parcelas, 0)                    AS [PARCELAS],

-- =========================
-- QUALIDADE / FLAGS
-- =========================
ISNULL(nota_avaliacao, 0)                  AS [AVALIACAO],
ISNULL(flag_entrega_atrasada, 0)           AS [ENTREGA ATRASADA],

-- =========================
-- TEMPO
-- =========================
ISNULL(dias_aprovacao_int, 0)              AS [DIAS APROVACAO],
ISNULL(dias_entrega_int, 0)                AS [DIAS ENTREGA],
ISNULL(dias_transportadora_int, 0)         AS [DIAS TRANSPORTADORA]

FROM fato_vendas;

SELECT *
FROM	VW_FATO_VENDAS