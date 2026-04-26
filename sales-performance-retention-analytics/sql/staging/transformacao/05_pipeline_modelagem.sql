--============================================================
-- CRIANDO stg_dim_cliente_udpdate
--============================================================

CREATE TABLE dbo.stg_dim_cliente_update
(
    id_cliente            NVARCHAR(100),
    id_cliente_unico      NVARCHAR(100),
    cep_prefixo_cliente   NVARCHAR(50),
    cidade_cliente        NVARCHAR(200),
    uf_cliente            NVARCHAR(10),
    nome_cliente          NVARCHAR(200)
);
GO



--============================================================
-- CRIANDO stg_dim_produto_udpdate
--============================================================

CREATE TABLE dbo.stg_dim_produto_update
(
    id_produto                                NVARCHAR(100),
    categoria_produto                         NVARCHAR(100),
    qtde_caracteres_nome_produto              NVARCHAR(50),
    qtde_caracteres_descricao_produto         NVARCHAR(200),
    qtde_fotos_produto                        NVARCHAR(10),
    peso_produto_g                            NVARCHAR(200),
    comprimento_produto_cm                    NVARCHAR(200),
    altura_produto_cm                         NVARCHAR(200),
    largura_produto_cm                        NVARCHAR(200),
    categoria                                 NVARCHAR(200),
    nome_produto                              NVARCHAR(200),
    marca                                     NVARCHAR(200),
    tipo_produto                              NVARCHAR(200),
    linha_produto                             NVARCHAR(200),

);
GO

--============================================================
-- CRIANDO stg_dim_vendedor_udpdate
--============================================================

CREATE TABLE dbo.stg_dim_vendedor_update
(
    id_vendedor              NVARCHAR(100),
    cep_prefixo_vendedor     NVARCHAR(100),
    cidade_vendedor          NVARCHAR(50),
    uf_vendedor              NVARCHAR(200),
    nome_vendedor            NVARCHAR(10),
    
);
GO

--============================================================
-- CRIANDO PROCEDURE DIM_CLEINTE (INCREMENTAL)
--============================================================

CREATE OR ALTER PROCEDURE dbo.sp_carga_dim_cliente
AS
BEGIN
    SET NOCOUNT ON;

    -- =========================
    -- UPDATE
    -- =========================
    UPDATE dc
       SET dc.id_cliente_unico    = s.id_cliente_unico,
           dc.cep_prefixo_cliente = TRY_CONVERT(INT, s.cep_prefixo_cliente),
           dc.cidade_cliente      = s.cidade_cliente,
           dc.uf_cliente          = s.uf_cliente,
           dc.nome_cliente        = s.nome_cliente
    FROM dbo.dim_cliente dc
    INNER JOIN dbo.stg_dim_cliente_update s
        ON dc.id_cliente = s.id_cliente;

    -- =========================
    -- INSERT
    -- =========================
    INSERT INTO dbo.dim_cliente
    (
        id_cliente,
        id_cliente_unico,
        cep_prefixo_cliente,
        cidade_cliente,
        uf_cliente,
        nome_cliente
    )
    SELECT
        s.id_cliente,
        s.id_cliente_unico,
        TRY_CONVERT(INT, s.cep_prefixo_cliente),
        s.cidade_cliente,
        s.uf_cliente,
        s.nome_cliente
    FROM dbo.stg_dim_cliente_update s
    WHERE NOT EXISTS
    (
        SELECT 1
        FROM dbo.dim_cliente dc
        WHERE dc.id_cliente = s.id_cliente
    );
END;
GO

--============================================================
-- CRIANDO PROCEDURE DIM_VENDEDOR (INCREMENTAL)
--============================================================

CREATE OR ALTER PROCEDURE dbo.sp_carga_dim_vendedor
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dv
       SET dv.cep_prefixo_vendedor = TRY_CONVERT(INT, s.cep_prefixo_vendedor),
           dv.cidade_vendedor      = s.cidade_vendedor,
           dv.uf_vendedor          = s.uf_vendedor,
           dv.nome_vendedor        = s.nome_vendedor
    FROM dbo.dim_vendedor dv
    INNER JOIN dbo.stg_dim_vendedor_update s
        ON dv.id_vendedor = s.id_vendedor;

    INSERT INTO dbo.dim_vendedor
    (
        id_vendedor,
        cep_prefixo_vendedor,
        cidade_vendedor,
        uf_vendedor,
        nome_vendedor
    )
    SELECT
        s.id_vendedor,
        TRY_CONVERT(INT, s.cep_prefixo_vendedor),
        s.cidade_vendedor,
        s.uf_vendedor,
        s.nome_vendedor
    FROM dbo.stg_dim_vendedor_update s
    WHERE NOT EXISTS
    (
        SELECT 1
        FROM dbo.dim_vendedor dv
        WHERE dv.id_vendedor = s.id_vendedor
    );
END;
GO

--============================================================
-- CRIANDO PROCEDURE DIM_PRODUTO (INCREMENTAL)
--============================================================

CREATE OR ALTER PROCEDURE dbo.sp_carga_dim_produto
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dp
       SET dp.categoria_produto = s.categoria_produto,
           dp.categoria         = s.categoria,
           dp.nome_produto      = s.nome_produto,
           dp.marca             = s.marca,
           dp.tipo_produto      = s.tipo_produto,
           dp.linha_produto     = s.linha_produto
    FROM dbo.dim_produto dp
    INNER JOIN dbo.stg_dim_produto_update s
        ON dp.id_produto = s.id_produto;

    INSERT INTO dbo.dim_produto
    (
        id_produto,
        categoria_produto,
        categoria,
        nome_produto,
        marca,
        tipo_produto,
        linha_produto
    )
    SELECT
        s.id_produto,
        s.categoria_produto,
        s.categoria,
        s.nome_produto,
        s.marca,
        s.tipo_produto,
        s.linha_produto
    FROM dbo.stg_dim_produto_update s
    WHERE NOT EXISTS
    (
        SELECT 1
        FROM dbo.dim_produto dp
        WHERE dp.id_produto = s.id_produto
    );
END;
GO

--============================================================
-- CRIANDO PROCEDURE fato_vendas (INCREMENTAL)
--============================================================

CREATE OR ALTER PROCEDURE dbo.sp_carga_fato_vendas
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE fv
       SET fv.id_cliente = s.id_cliente,
           fv.id_cliente_unico = s.id_cliente_unico,
           fv.id_produto = s.id_produto,
           fv.id_vendedor = s.id_vendedor,
           fv.id_data_compra = TRY_CONVERT(DATE, s.id_data_compra),
           fv.status_pedido = s.status_pedido,
           fv.data_hora_compra = TRY_CONVERT(DATETIME2, s.data_hora_compra),
           fv.data_hora_aprovacao = TRY_CONVERT(DATETIME2, s.data_hora_aprovacao),
           fv.data_hora_envio_transportadora = TRY_CONVERT(DATETIME2, s.data_hora_envio_transportadora),
           fv.data_hora_entrega_cliente = TRY_CONVERT(DATETIME2, s.data_hora_entrega_cliente),
           fv.data_prevista_entrega = TRY_CONVERT(DATE, s.data_prevista_entrega),
           fv.qtd_itens = TRY_CONVERT(INT, s.qtd_itens),
           fv.valor_item = TRY_CONVERT(DECIMAL(18,2), REPLACE(s.valor_item, ',', '.')),
           fv.valor_frete = TRY_CONVERT(DECIMAL(18,2), REPLACE(s.valor_frete, ',', '.')),
           fv.valor_bruto_item = TRY_CONVERT(DECIMAL(18,2), REPLACE(s.valor_bruto_item, ',', '.')),
           fv.valor_pago_total = TRY_CONVERT(DECIMAL(18,2), REPLACE(s.valor_pago_total, ',', '.')),
           fv.qtde_pagamentos = TRY_CONVERT(INT, s.qtde_pagamentos),
           fv.qtd_parcelas = TRY_CONVERT(INT, s.qtd_parcelas),
           fv.nota_avaliacao = TRY_CONVERT(TINYINT, s.nota_avaliacao),
           fv.dias_ate_aprovacao = TRY_CONVERT(DECIMAL(18,2), REPLACE(s.dias_ate_aprovacao, ',', '.')),
           fv.dias_ate_entrega = TRY_CONVERT(DECIMAL(18,2), REPLACE(s.dias_ate_entrega, ',', '.')),
           fv.dias_transportadora = TRY_CONVERT(DECIMAL(18,2), REPLACE(s.dias_transportadora, ',', '.')),
           fv.flag_entrega_atrasada =
                CASE 
                    WHEN UPPER(LTRIM(RTRIM(s.flag_entrega_atrasada))) IN ('1','SIM','TRUE','S') THEN 1
                    ELSE 0
                END,
           fv.nome_cliente = s.nome_cliente,
           fv.nome_vendedor = s.nome_vendedor,
           fv.categoria_produto = s.categoria_produto,
           fv.categoria = s.categoria,
           fv.nome_produto = s.nome_produto,
           fv.marca = s.marca,
           fv.tipo_produto = s.tipo_produto,
           fv.linha_produto = s.linha_produto,
           fv.status_entrega =
                CASE 
                    WHEN TRY_CONVERT(DATETIME2, s.data_hora_entrega_cliente) IS NULL THEN 'NÃO ENTREGUE'
                    WHEN UPPER(LTRIM(RTRIM(s.flag_entrega_atrasada))) IN ('1','SIM','TRUE','S') THEN 'ATRASADA'
                    ELSE 'NO PRAZO'
                END,
           fv.dias_aprovacao_int = TRY_CONVERT(INT, TRY_CONVERT(DECIMAL(18,2), REPLACE(s.dias_ate_aprovacao, ',', '.'))),
           fv.dias_entrega_int = TRY_CONVERT(INT, TRY_CONVERT(DECIMAL(18,2), REPLACE(s.dias_ate_entrega, ',', '.'))),
           fv.dias_transportadora_int = TRY_CONVERT(INT, TRY_CONVERT(DECIMAL(18,2), REPLACE(s.dias_transportadora, ',', '.')))
    FROM dbo.fato_vendas fv
    INNER JOIN dbo.stg_fato_vendas s
        ON fv.id_pedido = s.id_pedido
       AND fv.id_item_pedido = TRY_CONVERT(INT, s.id_item_pedido);

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
        linha_produto,
        status_entrega,
        dias_aprovacao_int,
        dias_entrega_int,
        dias_transportadora_int
    )
    SELECT
        s.id_pedido,
        TRY_CONVERT(INT, s.id_item_pedido),
        s.id_cliente,
        s.id_cliente_unico,
        s.id_produto,
        s.id_vendedor,
        TRY_CONVERT(DATE, s.id_data_compra),
        s.status_pedido,
        TRY_CONVERT(DATETIME2, s.data_hora_compra),
        TRY_CONVERT(DATETIME2, s.data_hora_aprovacao),
        TRY_CONVERT(DATETIME2, s.data_hora_envio_transportadora),
        TRY_CONVERT(DATETIME2, s.data_hora_entrega_cliente),
        TRY_CONVERT(DATE, s.data_prevista_entrega),
        TRY_CONVERT(INT, s.qtd_itens),
        TRY_CONVERT(DECIMAL(18,2), REPLACE(s.valor_item, ',', '.')),
        TRY_CONVERT(DECIMAL(18,2), REPLACE(s.valor_frete, ',', '.')),
        TRY_CONVERT(DECIMAL(18,2), REPLACE(s.valor_bruto_item, ',', '.')),
        TRY_CONVERT(DECIMAL(18,2), REPLACE(s.valor_pago_total, ',', '.')),
        TRY_CONVERT(INT, s.qtde_pagamentos),
        TRY_CONVERT(INT, s.qtd_parcelas),
        TRY_CONVERT(TINYINT, s.nota_avaliacao),
        TRY_CONVERT(DECIMAL(18,2), REPLACE(s.dias_ate_aprovacao, ',', '.')),
        TRY_CONVERT(DECIMAL(18,2), REPLACE(s.dias_ate_entrega, ',', '.')),
        TRY_CONVERT(DECIMAL(18,2), REPLACE(s.dias_transportadora, ',', '.')),
        CASE 
            WHEN UPPER(LTRIM(RTRIM(s.flag_entrega_atrasada))) IN ('1','SIM','TRUE','S') THEN 1
            ELSE 0
        END,
        s.nome_cliente,
        s.nome_vendedor,
        s.categoria_produto,
        s.categoria,
        s.nome_produto,
        s.marca,
        s.tipo_produto,
        s.linha_produto,
        CASE 
            WHEN TRY_CONVERT(DATETIME2, s.data_hora_entrega_cliente) IS NULL THEN 'NÃO ENTREGUE'
            WHEN UPPER(LTRIM(RTRIM(s.flag_entrega_atrasada))) IN ('1','SIM','TRUE','S') THEN 'ATRASADA'
            ELSE 'NO PRAZO'
        END,
        TRY_CONVERT(INT, TRY_CONVERT(DECIMAL(18,2), REPLACE(s.dias_ate_aprovacao, ',', '.'))),
        TRY_CONVERT(INT, TRY_CONVERT(DECIMAL(18,2), REPLACE(s.dias_ate_entrega, ',', '.'))),
        TRY_CONVERT(INT, TRY_CONVERT(DECIMAL(18,2), REPLACE(s.dias_transportadora, ',', '.')))
    FROM dbo.stg_fato_vendas s
    WHERE NOT EXISTS
    (
        SELECT 1
        FROM dbo.fato_vendas fv
        WHERE fv.id_pedido = s.id_pedido
          AND fv.id_item_pedido = TRY_CONVERT(INT, s.id_item_pedido)
    );
END;
GO

--============================================================
-- CRIANDO PROCEDURE churn_clientes (INCREMENTAL)
--============================================================

CREATE OR ALTER PROCEDURE dbo.sp_carga_churn_clientes
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE c
       SET c.[ID UNICO CLIENTE] = s.id_cliente_unico,
           c.[CLIENTE] = s.nome_cliente,
           c.[PRIMEIRA COMPRA] = TRY_CONVERT(DATETIME2, s.data_primeira_compra),
           c.[ULTIMA COMPRA] = TRY_CONVERT(DATETIME2, s.data_ultima_compra),
           c.[QTDE PEDIDOS] = TRY_CONVERT(INT, s.qtd_pedidos),
           c.[RECEITA] = TRY_CONVERT(DECIMAL(18,2), REPLACE(s.receita_total, ',', '.')),
           c.[TICKET MEDIO] = TRY_CONVERT(DECIMAL(18,2), REPLACE(s.ticket_medio_cliente, ',', '.')),
           c.[DIAS DA ULTIMA COMPRA] = TRY_CONVERT(INT, s.dias_desde_ultima_compra),
           c.[FLAG RECOMPRA] = CASE WHEN UPPER(LTRIM(RTRIM(s.flag_recompra))) IN ('1','SIM','TRUE','S') THEN 1 ELSE 0 END,
           c.[FLAG CHURN 90D] = CASE WHEN UPPER(LTRIM(RTRIM(s.flag_churn_90d))) IN ('1','SIM','TRUE','S') THEN 1 ELSE 0 END,
           c.[FLAG CHURN 120D] = CASE WHEN UPPER(LTRIM(RTRIM(s.flag_churn_120d))) IN ('1','SIM','TRUE','S') THEN 1 ELSE 0 END,
           c.[FLAG CHURN 180D] = CASE WHEN UPPER(LTRIM(RTRIM(s.flag_churn_180d))) IN ('1','SIM','TRUE','S') THEN 1 ELSE 0 END
    FROM dbo.churn_clientes c
    INNER JOIN dbo.stg_base_churn_clientes s
        ON c.[ID CLIENTE] = s.id_cliente;

    INSERT INTO dbo.churn_clientes
    (
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
        s.id_cliente,
        s.id_cliente_unico,
        s.nome_cliente,
        TRY_CONVERT(DATETIME2, s.data_primeira_compra),
        TRY_CONVERT(DATETIME2, s.data_ultima_compra),
        TRY_CONVERT(INT, s.qtd_pedidos),
        TRY_CONVERT(DECIMAL(18,2), REPLACE(s.receita_total, ',', '.')),
        TRY_CONVERT(DECIMAL(18,2), REPLACE(s.ticket_medio_cliente, ',', '.')),
        TRY_CONVERT(INT, s.dias_desde_ultima_compra),
        CASE WHEN UPPER(LTRIM(RTRIM(s.flag_recompra))) IN ('1','SIM','TRUE','S') THEN 1 ELSE 0 END,
        CASE WHEN UPPER(LTRIM(RTRIM(s.flag_churn_90d))) IN ('1','SIM','TRUE','S') THEN 1 ELSE 0 END,
        CASE WHEN UPPER(LTRIM(RTRIM(s.flag_churn_120d))) IN ('1','SIM','TRUE','S') THEN 1 ELSE 0 END,
        CASE WHEN UPPER(LTRIM(RTRIM(s.flag_churn_180d))) IN ('1','SIM','TRUE','S') THEN 1 ELSE 0 END
    FROM dbo.stg_base_churn_clientes s
    WHERE NOT EXISTS
    (
        SELECT 1
        FROM dbo.churn_clientes c
        WHERE c.[ID CLIENTE] = s.id_cliente
    );
END;
GO

--============================================================
-- CRIANDO PROCEDURE funil_marketing (INCREMENTAL)
--============================================================

CREATE OR ALTER PROCEDURE dbo.sp_carga_fato_funil_marketing
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE f
       SET f.[DATA PRIMEIRO CONTATO] = TRY_CONVERT(DATETIME2, s.data_primeiro_contato),
           f.[ID LANDING PAGE] = s.id_landing_page,
           f.[ORIGEM] = s.origem,
           f.[FLAG CONVERTIDO] =
                CASE WHEN UPPER(LTRIM(RTRIM(s.flag_convertido))) IN ('1','SIM','TRUE','S') THEN 1 ELSE 0 END,
           f.[ID VENDEDOR] = s.id_vendedor,
           f.[ID SDR] = s.id_sdr,
           f.[ID SR] = s.id_sr,
           f.[DATA GANHO] = TRY_CONVERT(DATETIME2, s.data_ganho),
           f.[SEGMENTO NEGOCIO] = s.segmento_negocio,
           f.[TIPO LEAD] = s.tipo_lead,
           f.[PERFIL COMPORTAMENTO LEAD] = s.perfil_comportamento_lead,
           f.[FLAG TEM EMPRESA] = s.flag_tem_empresa,
           f.[FLAG TEM GTIN] = s.flag_tem_gtin,
           f.[ESTOQUE MEDIO DECLARADO] = TRY_CONVERT(INT, s.estoque_medio_declarado),
           f.[TIPO NEGOCIO] = s.tipo_negocio,
           f.[TAMANHO CATALOGO DECLARADO] = TRY_CONVERT(INT, s.tamanho_catalogo_declarado),
           f.[RECEITA MENSAL DECLARADA] = TRY_CONVERT(DECIMAL(18,2), REPLACE(s.receita_mensal_declarada, ',', '.')),
           f.[RECEITA 180D POS GANHO] = TRY_CONVERT(DECIMAL(18,2), REPLACE(s.receita_180d_pos_ganho, ',', '.')),
           f.[PEDIDOS 180D POS GANHO] = TRY_CONVERT(INT, s.pedidos_180d_pos_ganho),
           f.[VENDEDOR] = s.nome_vendedor,
           f.[FLAG TEM EMPRESA SN] = s.flag_tem_empresa_sn,
           f.[FLAG TEM GTIN SN] = s.flag_tem_gtin_sn,
           f.[FLAG TEM EMPRESA BIT] =
                CASE WHEN UPPER(LTRIM(RTRIM(s.flag_tem_empresa_bit))) IN ('1','SIM','TRUE','S') THEN 1 ELSE 0 END,
           f.[FLAG TEM GTIN BIT] =
                CASE WHEN UPPER(LTRIM(RTRIM(s.flag_tem_gtin_bit))) IN ('1','SIM','TRUE','S') THEN 1 ELSE 0 END
    FROM dbo.fato_funil_marketing f
    INNER JOIN dbo.stg_fato_funil_marketing s
        ON f.[ID MQL] = s.id_mql;

    INSERT INTO dbo.fato_funil_marketing
    (
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
        s.id_mql,
        TRY_CONVERT(DATETIME2, s.data_primeiro_contato),
        s.id_landing_page,
        s.origem,
        CASE WHEN UPPER(LTRIM(RTRIM(s.flag_convertido))) IN ('1','SIM','TRUE','S') THEN 1 ELSE 0 END,
        s.id_vendedor,
        s.id_sdr,
        s.id_sr,
        TRY_CONVERT(DATETIME2, s.data_ganho),
        s.segmento_negocio,
        s.tipo_lead,
        s.perfil_comportamento_lead,
        s.flag_tem_empresa,
        s.flag_tem_gtin,
        TRY_CONVERT(INT, s.estoque_medio_declarado),
        s.tipo_negocio,
        TRY_CONVERT(INT, s.tamanho_catalogo_declarado),
        TRY_CONVERT(DECIMAL(18,2), REPLACE(s.receita_mensal_declarada, ',', '.')),
        TRY_CONVERT(DECIMAL(18,2), REPLACE(s.receita_180d_pos_ganho, ',', '.')),
        TRY_CONVERT(INT, s.pedidos_180d_pos_ganho),
        s.nome_vendedor,
        s.flag_tem_empresa_sn,
        s.flag_tem_gtin_sn,
        CASE WHEN UPPER(LTRIM(RTRIM(s.flag_tem_empresa_bit))) IN ('1','SIM','TRUE','S') THEN 1 ELSE 0 END,
        CASE WHEN UPPER(LTRIM(RTRIM(s.flag_tem_gtin_bit))) IN ('1','SIM','TRUE','S') THEN 1 ELSE 0 END
    FROM dbo.stg_fato_funil_marketing s
    WHERE NOT EXISTS
    (
        SELECT 1
        FROM dbo.fato_funil_marketing f
        WHERE f.[ID MQL] = s.id_mql
    );
END;
GO

--============================================================
-- CRIANDO PROCEDURE SP_LIMPA_STAGING
--============================================================

CREATE OR ALTER PROCEDURE dbo.sp_limpa_staging
AS
BEGIN
    SET NOCOUNT ON;

    TRUNCATE TABLE dbo.stg_dim_cliente_update;
    TRUNCATE TABLE dbo.stg_dim_vendedor_update;
    TRUNCATE TABLE dbo.stg_dim_produto_update;
    TRUNCATE TABLE dbo.stg_fato_vendas;
    TRUNCATE TABLE dbo.stg_fato_funil_marketing;
    TRUNCATE TABLE dbo.stg_base_churn_clientes;
END;
GO

--============================================================
--                      TESTANDO 
--============================================================

EXEC dbo.sp_carga_dim_produto;
SELECT TOP 10 * FROM dbo.dim_produto;

EXEC dbo.sp_carga_dim_vendedor;
SELECT TOP 10 * FROM dbo.dim_vendedor;

EXEC dbo.sp_carga_dim_cliente;
SELECT TOP 10 * FROM dbo.dim_cliente;

EXEC dbo.sp_carga_fato_vendas;
SELECT TOP 10 * FROM dbo.dim_cliente;

EXEC dbo.sp_carga_churn_clientes;
SELECT TOP 10 * FROM dbo.dim_cliente;

EXEC dbo.sp_carga_fato_funil_marketing;
SELECT TOP 10 * FROM dbo.dim_cliente;

--============================================================
-- CRIANDO PROCEDURE PIPELINE
--============================================================

USE Projeto_Business_Performance_360;
GO

CREATE OR ALTER PROCEDURE dbo.sp_pipeline_carga_completa
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        EXEC dbo.sp_carga_dim_cliente;
        EXEC dbo.sp_carga_dim_vendedor;
        EXEC dbo.sp_carga_dim_produto;
        EXEC dbo.sp_carga_fato_vendas;
        EXEC dbo.sp_carga_fato_funil_marketing;
        EXEC dbo.sp_carga_churn_clientes;
        EXEC dbo.sp_limpa_staging;

        PRINT 'Pipeline incremental executado com sucesso.';
    END TRY
    BEGIN CATCH
        PRINT 'Erro no pipeline: ' + ERROR_MESSAGE();
        THROW;
    END CATCH
END;
GO

SELECT 
    SCHEMA_NAME(schema_id) AS schema_name,
    name
FROM sys.procedures
WHERE name = 'sp_pipeline_carga_completa';

--============================================================
-- CRIANDO LOG DE EXECUÇÃO
--============================================================

CREATE TABLE dbo.log_pipeline
(
    id_log INT IDENTITY(1,1),
    data_execucao DATETIME DEFAULT GETDATE(),
    etapa NVARCHAR(100),
    status NVARCHAR(20),
    mensagem NVARCHAR(500)
);

--DENTRO DO PIPELINE
INSERT INTO dbo.log_pipeline (etapa, status)
VALUES ('INICIO PIPELINE', 'OK');

--DENTRO DO CATCH
INSERT INTO dbo.log_pipeline (etapa, status, mensagem)
VALUES ('ERRO PIPELINE', 'ERRO', ERROR_MESSAGE());

--============================================================
-- CRIANDO CONTROLE DE DUPLICIDADE
--============================================================

ALTER TABLE dbo.fato_vendas
ADD CONSTRAINT uq_fato_vendas UNIQUE (id_pedido, id_item_pedido);

ALTER TABLE dbo.fato_funil_marketing
ADD CONSTRAINT uq_funil UNIQUE ([ID MQL]);

--============================================================
-- CRIANDO COLUNA DE CONTROLE DATA_CARGA
--============================================================

-- FATO_VENDAS
ALTER TABLE dbo.fato_vendas
ADD data_carga DATETIME2 DEFAULT SYSDATETIME();

-- NA STAGING
ALTER TABLE dbo.stg_fato_vendas
ADD data_carga DATETIME2 DEFAULT SYSDATETIME();

SELECT 
    COLUMN_NAME,
    DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME IN ('fato_vendas', 'stg_fato_vendas')
  AND COLUMN_NAME = 'data_carga';


-- FUNIL_MARKETING
  ALTER TABLE dbo.fato_funil_marketing
ADD data_carga DATETIME2 DEFAULT SYSDATETIME();

-- NA STAGING
ALTER TABLE dbo.stg_fato_funil_marketing
ADD data_carga DATETIME2 DEFAULT SYSDATETIME();

--============================================================
-- CRIANDO FILTRO INCREMENTAL NA PROCEDURE (CTE)
--============================================================

-- FATO_VENDAS

CREATE OR ALTER PROCEDURE dbo.sp_carga_fato_vendas
AS
BEGIN
    SET NOCOUNT ON;

    DROP TABLE IF EXISTS #origem;

    SELECT *
    INTO #origem
    FROM dbo.stg_fato_vendas
    WHERE TRY_CONVERT(DATETIME2, data_hora_compra) >= DATEADD(DAY, -7,
    (
        SELECT ISNULL(MAX(data_hora_compra), '1900-01-01')
        FROM dbo.fato_vendas
    ));

    UPDATE fv
       SET fv.id_cliente = s.id_cliente,
           fv.id_cliente_unico = s.id_cliente_unico,
           fv.id_produto = s.id_produto,
           fv.id_vendedor = s.id_vendedor,
           fv.id_data_compra = TRY_CONVERT(DATE, s.id_data_compra),
           fv.status_pedido = s.status_pedido,
           fv.data_hora_compra = TRY_CONVERT(DATETIME2, s.data_hora_compra),
           fv.data_hora_aprovacao = TRY_CONVERT(DATETIME2, s.data_hora_aprovacao),
           fv.data_hora_envio_transportadora = TRY_CONVERT(DATETIME2, s.data_hora_envio_transportadora),
           fv.data_hora_entrega_cliente = TRY_CONVERT(DATETIME2, s.data_hora_entrega_cliente),
           fv.data_prevista_entrega = TRY_CONVERT(DATE, s.data_prevista_entrega),
           fv.qtd_itens = TRY_CONVERT(INT, s.qtd_itens),
           fv.valor_item = TRY_CONVERT(DECIMAL(18,2), REPLACE(s.valor_item, ',', '.')),
           fv.valor_frete = TRY_CONVERT(DECIMAL(18,2), REPLACE(s.valor_frete, ',', '.')),
           fv.valor_bruto_item = TRY_CONVERT(DECIMAL(18,2), REPLACE(s.valor_bruto_item, ',', '.')),
           fv.valor_pago_total = TRY_CONVERT(DECIMAL(18,2), REPLACE(s.valor_pago_total, ',', '.')),
           fv.qtde_pagamentos = TRY_CONVERT(INT, s.qtde_pagamentos),
           fv.qtd_parcelas = TRY_CONVERT(INT, s.qtd_parcelas),
           fv.nota_avaliacao = TRY_CONVERT(TINYINT, s.nota_avaliacao),
           fv.dias_ate_aprovacao = TRY_CONVERT(DECIMAL(18,2), REPLACE(s.dias_ate_aprovacao, ',', '.')),
           fv.dias_ate_entrega = TRY_CONVERT(DECIMAL(18,2), REPLACE(s.dias_ate_entrega, ',', '.')),
           fv.dias_transportadora = TRY_CONVERT(DECIMAL(18,2), REPLACE(s.dias_transportadora, ',', '.')),
           fv.flag_entrega_atrasada = CASE WHEN UPPER(LTRIM(RTRIM(s.flag_entrega_atrasada))) IN ('1','SIM','TRUE','S') THEN 1 ELSE 0 END,
           fv.nome_cliente = s.nome_cliente,
           fv.nome_vendedor = s.nome_vendedor,
           fv.categoria_produto = s.categoria_produto,
           fv.categoria = s.categoria,
           fv.nome_produto = s.nome_produto,
           fv.marca = s.marca,
           fv.tipo_produto = s.tipo_produto,
           fv.linha_produto = s.linha_produto
    FROM dbo.fato_vendas fv
    INNER JOIN #origem s
        ON fv.id_pedido = s.id_pedido
       AND fv.id_item_pedido = TRY_CONVERT(INT, s.id_item_pedido);

    INSERT INTO dbo.fato_vendas
    (
        id_pedido, id_item_pedido, id_cliente, id_cliente_unico, id_produto, id_vendedor,
        id_data_compra, status_pedido, data_hora_compra, data_hora_aprovacao,
        data_hora_envio_transportadora, data_hora_entrega_cliente, data_prevista_entrega,
        qtd_itens, valor_item, valor_frete, valor_bruto_item, valor_pago_total,
        qtde_pagamentos, qtd_parcelas, nota_avaliacao, dias_ate_aprovacao,
        dias_ate_entrega, dias_transportadora, flag_entrega_atrasada,
        nome_cliente, nome_vendedor, categoria_produto, categoria, nome_produto,
        marca, tipo_produto, linha_produto
    )
    SELECT
        s.id_pedido,
        TRY_CONVERT(INT, s.id_item_pedido),
        s.id_cliente,
        s.id_cliente_unico,
        s.id_produto,
        s.id_vendedor,
        TRY_CONVERT(DATE, s.id_data_compra),
        s.status_pedido,
        TRY_CONVERT(DATETIME2, s.data_hora_compra),
        TRY_CONVERT(DATETIME2, s.data_hora_aprovacao),
        TRY_CONVERT(DATETIME2, s.data_hora_envio_transportadora),
        TRY_CONVERT(DATETIME2, s.data_hora_entrega_cliente),
        TRY_CONVERT(DATE, s.data_prevista_entrega),
        TRY_CONVERT(INT, s.qtd_itens),
        TRY_CONVERT(DECIMAL(18,2), REPLACE(s.valor_item, ',', '.')),
        TRY_CONVERT(DECIMAL(18,2), REPLACE(s.valor_frete, ',', '.')),
        TRY_CONVERT(DECIMAL(18,2), REPLACE(s.valor_bruto_item, ',', '.')),
        TRY_CONVERT(DECIMAL(18,2), REPLACE(s.valor_pago_total, ',', '.')),
        TRY_CONVERT(INT, s.qtde_pagamentos),
        TRY_CONVERT(INT, s.qtd_parcelas),
        TRY_CONVERT(TINYINT, s.nota_avaliacao),
        TRY_CONVERT(DECIMAL(18,2), REPLACE(s.dias_ate_aprovacao, ',', '.')),
        TRY_CONVERT(DECIMAL(18,2), REPLACE(s.dias_ate_entrega, ',', '.')),
        TRY_CONVERT(DECIMAL(18,2), REPLACE(s.dias_transportadora, ',', '.')),
        CASE WHEN UPPER(LTRIM(RTRIM(s.flag_entrega_atrasada))) IN ('1','SIM','TRUE','S') THEN 1 ELSE 0 END,
        s.nome_cliente,
        s.nome_vendedor,
        s.categoria_produto,
        s.categoria,
        s.nome_produto,
        s.marca,
        s.tipo_produto,
        s.linha_produto
    FROM #origem s
    WHERE NOT EXISTS
    (
        SELECT 1
        FROM dbo.fato_vendas fv
        WHERE fv.id_pedido = s.id_pedido
          AND fv.id_item_pedido = TRY_CONVERT(INT, s.id_item_pedido)
    );
END;
GO

--============================================================
-- CRIANDO FILTRO INCREMENTAL NA PROCEDURE (CTE)
--============================================================

-------------- FUNIL_MARKETING

CREATE OR ALTER PROCEDURE dbo.sp_carga_fato_funil_marketing
AS
BEGIN
    SET NOCOUNT ON;

    DROP TABLE IF EXISTS #origem;

    SELECT *
    INTO #origem
    FROM dbo.stg_fato_funil_marketing
    WHERE TRY_CONVERT(DATETIME2, data_primeiro_contato) >= DATEADD(DAY, -7,
    (
        SELECT ISNULL(MAX([DATA PRIMEIRO CONTATO]), '1900-01-01')
        FROM dbo.fato_funil_marketing
    ));

    UPDATE f
       SET f.[DATA PRIMEIRO CONTATO] = TRY_CONVERT(DATETIME2, s.data_primeiro_contato),
           f.[ID LANDING PAGE] = s.id_landing_page,
           f.[ORIGEM] = s.origem,
           f.[FLAG CONVERTIDO] = CASE WHEN UPPER(LTRIM(RTRIM(s.flag_convertido))) IN ('1','SIM','TRUE','S') THEN 1 ELSE 0 END,
           f.[ID VENDEDOR] = s.id_vendedor,
           f.[ID SDR] = s.id_sdr,
           f.[ID SR] = s.id_sr,
           f.[DATA GANHO] = TRY_CONVERT(DATETIME2, s.data_ganho),
           f.[SEGMENTO NEGOCIO] = s.segmento_negocio,
           f.[TIPO LEAD] = s.tipo_lead,
           f.[PERFIL COMPORTAMENTO LEAD] = s.perfil_comportamento_lead,
           f.[FLAG TEM EMPRESA] = s.flag_tem_empresa,
           f.[FLAG TEM GTIN] = s.flag_tem_gtin
    FROM dbo.fato_funil_marketing f
    INNER JOIN #origem s
        ON f.[ID MQL] = s.id_mql;

    INSERT INTO dbo.fato_funil_marketing
    (
        [ID MQL], [DATA PRIMEIRO CONTATO], [ID LANDING PAGE], [ORIGEM],
        [FLAG CONVERTIDO], [ID VENDEDOR], [ID SDR], [ID SR],
        [DATA GANHO], [SEGMENTO NEGOCIO], [TIPO LEAD],
        [PERFIL COMPORTAMENTO LEAD], [FLAG TEM EMPRESA], [FLAG TEM GTIN]
    )
    SELECT
        s.id_mql,
        TRY_CONVERT(DATETIME2, s.data_primeiro_contato),
        s.id_landing_page,
        s.origem,
        CASE WHEN UPPER(LTRIM(RTRIM(s.flag_convertido))) IN ('1','SIM','TRUE','S') THEN 1 ELSE 0 END,
        s.id_vendedor,
        s.id_sdr,
        s.id_sr,
        TRY_CONVERT(DATETIME2, s.data_ganho),
        s.segmento_negocio,
        s.tipo_lead,
        s.perfil_comportamento_lead,
        s.flag_tem_empresa,
        s.flag_tem_gtin
    FROM #origem s
    WHERE NOT EXISTS
    (
        SELECT 1
        FROM dbo.fato_funil_marketing f
        WHERE f.[ID MQL] = s.id_mql
    );
END;
GO

-- TESTE

EXEC dbo.sp_carga_fato_vendas;
GO

EXEC dbo.sp_carga_fato_funil_marketing;
GO

-- VALIDANDO DUPLICIDADE

SELECT id_pedido, id_item_pedido, COUNT(*) AS qtd
FROM dbo.fato_vendas
GROUP BY id_pedido, id_item_pedido
HAVING COUNT(*) > 1;


SELECT [ID MQL], COUNT(*) AS qtd
FROM dbo.fato_funil_marketing
GROUP BY [ID MQL]
HAVING COUNT(*) > 1;


EXEC dbo.sp_pipeline_carga_completa;