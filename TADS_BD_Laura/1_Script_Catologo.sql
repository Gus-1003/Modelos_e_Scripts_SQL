
############DEFINIÇÃO DO BANCO####################
CREATE DATABASE catalogoCD;

USE catalogoCD;

CREATE TABLE gravadora(
codigoGravadora int primary key auto_increment,
nomeGravadora varchar(255),
enderecoGravadora text,
telefoneGravadora varchar(20)
);

CREATE TABLE CD(
codigoCD int primary key auto_increment,
codigoGravadora int,
nomeCD varchar(255),
precoCD double CHECK (precoCD >0),
tempoTotal time,
FOREIGN KEY (codigoGravadora) REFERENCES gravadora (codigoGravadora)
);


CREATE TABLE musica(
codigoMusica int primary key auto_increment,
nomeMusica varchar(255),
duracaoMusica time
);

CREATE TABLE itemCD(
codigoCD int,
codigoMusica int,
numeroFaixa int,
PRIMARY KEY (codigoCD, codigoMusica),
FOREIGN KEY (codigoCD) REFERENCES CD (codigoCD),
FOREIGN KEY (codigoMusica) REFERENCES musica (codigoMusica)
);

CREATE TABLE autor(
codigoAutor int primary key auto_increment,
nomeAutor varchar(255)
);

CREATE TABLE musicaAutor(
codigoMusica int,
codigoAutor int,
PRIMARY KEY (codigoMusica, codigoAutor),
FOREIGN KEY (codigoMusica) REFERENCES musica (codigoMusica),
FOREIGN KEY (codigoAutor) REFERENCES autor (codigoAutor)
);


########MANIPULANDO REGISTROS NO BANCO###############
INSERT INTO gravadora (nomeGravadora, enderecoGravadora, telefoneGravadora) values
('EMI', 'Rio de Janeiro', '(21)9999-8877'),
('sony', 'Rio de Janeiro', '9997-7766'),
('universal', 'São Paulo', '2222-3333');

INSERT INTO gravadora VALUES (4, 'gravadorateste', 'natal' , '2223333');

DELETE FROM gravadora WHERE nomeGravadora LIKE '%teste';

DESCRIBE gravadora;

INSERT INTO CD (codigoGravadora, nomeCD, precoCD, tempoTotal) values
(1, 'Mais do Mesmo', 20.5, '00:30:05'),
(1, 'Legião Urbana', 30, '00:40:15'),
(2, '10.000 destinos', 22, '01:00:02');

INSERT INTO CD (nomeCD, precoCD, tempoTotal) values
('O Exercício das pequenas coisas', 35.5, '00:20:05');

INSERT INTO musica (nomeMusica, duracaoMusica) VALUES
('Que país é esse', '00:02:00'),
('Somos quem podemos ser', '00:03:02'),
('Será', '00:02:31'),
('A dança', '00:04:02'),
('Geração coca-cola', '00:02:22'),
('Ainda é cedo', '00:03:57'),
('A montanha', '00:04:28'),
('Infinita Highway', '00:06:07');

INSERT INTO itemCD VALUES 
(1, 3, 1), (1, 6, 2), (1, 5, 3),(2, 1, 1), (2,4,2), (2, 3, 3), (3, 2, 1), (3, 7, 2), (3, 8, 3);

UPDATE CD SET precoCD = precoCD*1.05 WHERE codigoGravadora = 2;

UPDATE gravadora SET enderecoGravadora = 'Rio de Janeiro' WHERE codigoGravadora = 1;

######VISUALIZANDO REGISTROS##########

SELECT * FROM CD;

SELECT * FROM gravadora;

SELECT * FROM musica;

SELECT nomeMusica AS 'Melhores Músicas' FROM Musica;

SELECT nomeGravadora AS 'Gravadora', telefoneGravadora AS 'Telefone' FROM GRAVADORA;

SELECT * FROM CD LIMIT 2;

SELECT nomeCD FROM CD WHERE precoCD BETWEEN 10 AND 30;

SELECT * FROM musica WHERE nomeMusica LIKE '%país%';

####DUAS TABELAS####
SELECT nomeCD, nomeGravadora FROM CD, gravadora; #FARÁ UM PRODUTO CARTESIANO COM AS TABELAS

SELECT nomeCD, nomeGravadora FROM CD, gravadora 
WHERE CD.codigoGravadora = gravadora.codigoGravadora;

SELECT nomeCD, nomeGravadora FROM CD, gravadora 
WHERE CD.codigoGravadora = gravadora.codigoGravadora AND CD.codigoGravadora = 1;

###TRÊS TABELAS####
SELECT nomeMusica, nomeCD, numeroFaixa FROM musica, cd, itemCD
WHERE itemCD.codigoCD = CD.codigoCD AND itemCD.codigoMusica = musica.codigoMusica
ORDER BY nomeCD, numeroFaixa;


####JOINS#####

#PARA COMPARAR
SELECT * 
FROM gravadora, CD
WHERE gravadora.codigoGravadora = CD.codigoGravadora; 

SELECT * 
FROM gravadora a, CD b #PODE USAR UM ALIAS NOS NOMES DAS TABELAS
WHERE a.codigoGravadora = b.codigoGravadora;  #PARA USAR AQUI

#FAZ A MESMA COISA,SÓ QUE USANDO O COMANDO INNER JOIN
SELECT * 
FROM gravadora a
INNER JOIN CD b
ON a.codigoGravadora = b.codigoGravadora; 

#no mysql pode usar using
SELECT * 
FROM gravadora a
INNER JOIN CD b
USING (codigoGravadora); 

SELECT * 
FROM gravadora a
LEFT JOIN CD b
ON a.codigoGravadora = b.codigoGravadora; 

SELECT * 
FROM gravadora a
RIGHT JOIN CD b
ON a.codigoGravadora = b.codigoGravadora; 

###JOIN COM 3 TABELAS####
SELECT nomeMusica, nomeCD, numeroFaixa 
FROM musica LEFT JOIN (cd, itemCD)
ON (itemCD.codigoCD = CD.codigoCD AND itemCD.codigoMusica = musica.codigoMusica)
ORDER BY nomeCD, numeroFaixa;


