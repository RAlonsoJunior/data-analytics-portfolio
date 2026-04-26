-- =========================================
--  CONFERINDO QTDE DE LINHAS
--==========================================

SELECT 'staging' AS origem, COUNT(*) AS qtd_linhas
FROM dbo.stg_fato_vendas

UNION ALL

SELECT 'final' AS origem, COUNT(*) AS qtd_linhas
FROM dbo.fato_vendas;

-- =============================================
--  CONFERINDO LINHAS QUE FALHARAM EM CONVERSÃO
--==============================================

SELECT *
FROM dbo.stg_fato_vendas s
LEFT JOIN dbo.fato_vendas f
    ON s.id_pedido = f.id_pedido
   AND TRY_CONVERT(INT, s.id_item_pedido) = f.id_item_pedido
WHERE
    (NULLIF(LTRIM(RTRIM(s.valor_item)), '') IS NOT NULL AND f.valor_item IS NULL)
    OR
    (NULLIF(LTRIM(RTRIM(s.valor_frete)), '') IS NOT NULL AND f.valor_frete IS NULL)
    OR
    (NULLIF(LTRIM(RTRIM(s.valor_bruto_item)), '') IS NOT NULL AND f.valor_bruto_item IS NULL)
    OR
    (NULLIF(LTRIM(RTRIM(s.valor_pago_total)), '') IS NOT NULL AND f.valor_pago_total IS NULL);


-- =========================================
--  VALIDANDO SOMA DO ITEM + FRETE = BRUTO
--==========================================

SELECT
    id_pedido,
    id_item_pedido,
    valor_item,
    valor_frete,
    valor_bruto_item,
    CAST(valor_item + valor_frete AS DECIMAL(18,2)) AS valor_calculado,
    CAST(valor_bruto_item - (valor_item + valor_frete) AS DECIMAL(18,2)) AS diferenca
FROM dbo.fato_vendas
WHERE ABS(valor_bruto_item - (valor_item + valor_frete)) > 0.01
ORDER BY ABS(valor_bruto_item - (valor_item + valor_frete)) DESC;

-- =========================================
--  VALIDANDO TOTAL COM O BRUTO
--==========================================

-- POR LINHA

SELECT
    id_pedido,
    id_item_pedido,
    valor_bruto_item,
    valor_pago_total,
    CAST(valor_pago_total - valor_bruto_item AS DECIMAL(18,2)) AS diferenca
FROM dbo.fato_vendas
WHERE ABS(valor_pago_total - valor_bruto_item) > 0.01
ORDER BY ABS(valor_pago_total - valor_bruto_item) DESC;


-- POR PEDIDO

SELECT
    id_pedido,
    SUM(valor_bruto_item) AS soma_bruto_itens,
    MAX(valor_pago_total) AS valor_pago_pedido,
    CAST(MAX(valor_pago_total) - SUM(valor_bruto_item) AS DECIMAL(18,2)) AS diferenca
FROM dbo.fato_vendas
GROUP BY id_pedido
HAVING ABS(MAX(valor_pago_total) - SUM(valor_bruto_item)) > 0.01
ORDER BY ABS(MAX(valor_pago_total) - SUM(valor_bruto_item)) DESC;

-- ========================================================================
--  VALINDANDO DIFERENÇA ENTRE valor_bruto_item e valor_item + valor_frete
--=========================================================================

SELECT
    id_pedido,
    id_item_pedido,
    valor_item,
    valor_frete,
    valor_bruto_item,
    CAST((ISNULL(valor_item,0) + ISNULL(valor_frete,0)) AS DECIMAL(18,2)) AS soma_calculada,
    CAST(valor_bruto_item - (ISNULL(valor_item,0) + ISNULL(valor_frete,0)) AS DECIMAL(18,2)) AS diferenca
FROM dbo.fato_vendas
WHERE ABS(ISNULL(valor_bruto_item,0) - (ISNULL(valor_item,0) + ISNULL(valor_frete,0))) > 0.01;

-- =========================================
--  RESUMO QUALIDADE DA SOMA
--==========================================

SELECT
    COUNT(*) AS total_registros,
    SUM(CASE 
            WHEN ABS(ISNULL(valor_bruto_item,0) - (ISNULL(valor_item,0) + ISNULL(valor_frete,0))) <= 0.01 
            THEN 1 ELSE 0 
        END) AS registros_ok,
    SUM(CASE 
            WHEN ABS(ISNULL(valor_bruto_item,0) - (ISNULL(valor_item,0) + ISNULL(valor_frete,0))) > 0.01 
            THEN 1 ELSE 0 
        END) AS registros_com_diferenca
FROM dbo.fato_vendas;


-- =========================================
--  VALIDANDO PAG DIVERGENTE DO BRUTO
--==========================================

SELECT
    id_pedido,
    id_item_pedido,
    valor_bruto_item,
    valor_pago_total,
    CAST(ISNULL(valor_pago_total,0) - ISNULL(valor_bruto_item,0) AS DECIMAL(18,2)) AS diferenca
FROM dbo.fato_vendas
WHERE ABS(ISNULL(valor_pago_total,0) - ISNULL(valor_bruto_item,0)) > 0.01;

-- =========================================
--  AJUSTANDO O VALOR PAGO PARA NÍVEL ITEM
--==========================================

SELECT
    id_pedido,
    id_item_pedido,
    valor_bruto_item,
    valor_pago_total,

    CAST(
        valor_pago_total / COUNT(*) OVER (PARTITION BY id_pedido)
    AS DECIMAL(18,2)) AS valor_pago_item_corrigido

FROM dbo.fato_vendas;

-- =========================================
--  VALIDANDO DUPLICIDADE CHAVE LÓGICA
--==========================================

SELECT
    id_pedido,
    id_item_pedido,
    COUNT(*) AS qtd
FROM dbo.fato_vendas
GROUP BY
    id_pedido,
    id_item_pedido
HAVING COUNT(*) > 1;

-- =========================================
--  CRIANDO CHAVE PRIMÉRIA COMPOSTA
--==========================================

ALTER TABLE dbo.fato_vendas
ADD CONSTRAINT PK_fato_vendas
PRIMARY KEY (id_pedido, id_item_pedido);
GO

-- ==========================================
--  VERIFICANDO OS NULOS EM COLUNAS CRÍTICAS
--===========================================

SELECT
    SUM(CASE WHEN id_pedido IS NULL THEN 1 ELSE 0 END) AS nulo_id_pedido,
    SUM(CASE WHEN id_item_pedido IS NULL THEN 1 ELSE 0 END) AS nulo_id_item_pedido,
    SUM(CASE WHEN id_cliente IS NULL THEN 1 ELSE 0 END) AS nulo_id_cliente,
    SUM(CASE WHEN id_produto IS NULL THEN 1 ELSE 0 END) AS nulo_id_produto,
    SUM(CASE WHEN id_vendedor IS NULL THEN 1 ELSE 0 END) AS nulo_id_vendedor,
    SUM(CASE WHEN data_hora_compra IS NULL THEN 1 ELSE 0 END) AS nulo_data_hora_compra,
    SUM(CASE WHEN valor_item IS NULL THEN 1 ELSE 0 END) AS nulo_valor_item
FROM dbo.fato_vendas;

-- =========================================
--  VALIDANDO CAMPOS OBRIGATÓRIOS NULOS
--==========================================

SELECT *
FROM dbo.fato_vendas
WHERE id_pedido IS NULL
   OR id_item_pedido IS NULL
   OR id_cliente IS NULL
   OR id_cliente_unico IS NULL
   OR id_produto IS NULL
   OR id_vendedor IS NULL
   OR data_hora_compra IS NULL;

-- =========================================
--  VALIDANDO DATAS INVERTIDAS
--==========================================

SELECT
    id_pedido,
    id_item_pedido,
    data_hora_compra,
    data_hora_aprovacao,
    data_hora_envio_transportadora,
    data_hora_entrega_cliente
FROM dbo.fato_vendas
WHERE
    (data_hora_aprovacao < data_hora_compra)
    OR (data_hora_envio_transportadora < data_hora_aprovacao)
    OR (data_hora_entrega_cliente < data_hora_envio_transportadora);


-- =========================================
--  VALIDANDO DATAS INCOERENTES
--==========================================

SELECT *
FROM dbo.fato_vendas
WHERE data_hora_aprovacao < data_hora_compra
   OR data_hora_envio_transportadora < data_hora_aprovacao
   OR data_hora_entrega_cliente < data_hora_envio_transportadora;

-- =========================================
--  VALIDANDO FLAG DE ATRASO
--==========================================

SELECT
    id_pedido,
    id_item_pedido,
    data_hora_entrega_cliente,
    data_prevista_entrega,
    flag_entrega_atrasada
FROM dbo.fato_vendas
WHERE
    (
        CASE
            WHEN data_hora_entrega_cliente IS NOT NULL
             AND data_prevista_entrega IS NOT NULL
             AND CAST(data_hora_entrega_cliente AS DATE) > data_prevista_entrega
            THEN 1
            ELSE 0
        END
    ) <> ISNULL(flag_entrega_atrasada, 0);

-- =========================================
--             CRIANDO ÍNDICE
--==========================================

CREATE INDEX IX_fato_vendas_data_compra
ON dbo.fato_vendas (id_data_compra);

CREATE INDEX IX_fato_vendas_cliente
ON dbo.fato_vendas (id_cliente);

CREATE INDEX IX_fato_vendas_produto
ON dbo.fato_vendas (id_produto);

CREATE INDEX IX_fato_vendas_vendedor
ON dbo.fato_vendas (id_vendedor);
GO

select *
from        fato_vendas

-- =========================================
--    VALIDANDO AS COLUNAS DIVERGENTES
--==========================================


SELECT COUNT(*) AS divergencias
FROM dbo.fato_vendas f
INNER JOIN dbo.dim_produto d
    ON f.id_produto = d.id_produto
WHERE
       ISNULL(f.categoria, '')     <> ISNULL(d.categoria, '')
    OR ISNULL(f.nome_produto, '')  <> ISNULL(d.nome_produto, '')
    OR ISNULL(f.marca, '')         <> ISNULL(d.marca, '')
    OR ISNULL(f.tipo_produto, '')  <> ISNULL(d.tipo_produto, '')
    OR ISNULL(f.linha_produto, '') <> ISNULL(d.linha_produto, '');