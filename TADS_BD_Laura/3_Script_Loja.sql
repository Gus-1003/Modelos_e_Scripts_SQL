CREATE DATABASE loja;

USE loja; 

CREATE TABLE tb_produtos
(
	idProduto INT AUTO_INCREMENT PRIMARY KEY,
	descricaoProduto VARCHAR(255),
    precoProduto DECIMAL(10,2),
	estoqueProduto	INT NOT NULL DEFAULT 0
);

INSERT INTO tb_produtos VALUES 
(null, 'Mouse', 10, 50),
(null, 'Teclado', 60, 40),
(null, 'Monitor', 400, 15);

SELECT * FROM tb_produtos;

CREATE TABLE tb_itensvenda
(
	venda INT NOT NULL,
	dataVenda TIMESTAMP DEFAULT current_timestamp,
    idProduto INT NOT NULL,
	qtdProduto INT NOT NULL,
    PRIMARY KEY (venda, idProduto),
    FOREIGN KEY (idProduto) REFERENCES tb_produtos (idProduto)
);

/*
Ao inserir e remover registro da tabela tb_itensvenda, o estoque do produto referenciado deve ser alterado na tabela tb_produtos.
Para isso, serão criados dois triggers: um AFTER INSERT para dar baixa no estoque e 
um AFTER DELETE para fazer a devolução da quantidade do produto.
*/

DELIMITER $

CREATE TRIGGER Tgr_ItensVenda_Insert AFTER INSERT
ON tb_itensvenda
FOR EACH ROW
BEGIN
	UPDATE tb_produtos SET estoqueProduto = estoqueProduto - NEW.qtdProduto
WHERE tb_produtos.idProduto = NEW.idProduto; /*new faz referência ao produto da tb_itemvenda*/
END$

CREATE TRIGGER Tgr_ItensVenda_Delete AFTER DELETE
ON tb_itensvenda
FOR EACH ROW
BEGIN
	UPDATE tb_produtos SET estoqueProduto = estoqueProduto + OLD.qtdProduto
WHERE tb_produtos.idProduto = OLD.idProduto;
END$

DELIMITER ;

/*No primeiro gatilho, foi utilizado o registro NEW para obter as informações da linha que está sendo inserida na tabela. 
O mesmo é feito no segundo gatilho, onde se obtém os dados que estão sendo apagados da tabela através do registro OLD.*/


INSERT INTO tb_itensvenda VALUES 
(1, null, 1, 3),
(1, null, 2, 2),
(1, null, 3, 1);

select * from tb_itensvenda;

select * from tb_produtos;

DELETE FROM tb_itensvenda WHERE venda = 1 AND idProduto = 1;

SHOW TRIGGERS;

#DROP TRIGGER Tgr_ItensVenda_Insert;

