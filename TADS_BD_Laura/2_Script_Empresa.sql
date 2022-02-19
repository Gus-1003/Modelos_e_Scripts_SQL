DROP DATABASE empresa;

CREATE DATABASE empresa;
#se tiver vários bancos nessa conexão, use o comando USE para definir qual vai usar
USE empresa; #usar esse BD

###definição das tabelas do banco
CREATE TABLE tb_pessoas(
	idpessoa int primary key auto_increment,
    nomepessoa varchar(255) not null,
    sexopessoa enum('F', 'M'),
    dtcadastropessoa timestamp not null default current_timestamp
);
DESCRIBE tb_pessoas;

CREATE TABLE tb_departamentos(
	iddepartamento int primary key auto_increment,
    nomedepartamento varchar(255) not null
);
DESCRIBE tb_departamentos;

CREATE TABLE tb_funcionarios(
	idfuncionario int primary key auto_increment,
    idpessoa int not null unique, #(1,1)
    iddepartamento int,
    salariofuncionario decimal(10,2) not null,
    dtadmissaofuncionario date not null,
    foreign key(idpessoa) references tb_pessoas (idpessoa)
		on update cascade on delete cascade,
	foreign key(iddepartamento) references tb_departamentos (iddepartamento)
		on delete set null
);
DESCRIBE tb_funcionarios;

#para referencias ciclicas
alter table tb_departamentos add idfuncionario int;
alter table tb_departamentos add 
foreign key (idfuncionario)  references tb_funcionarios(idfuncionario);
# https://dev.mysql.com/doc/refman/8.0/en/alter-table.html


CREATE TABLE tb_produtos(
	idproduto int primary key auto_increment,
	nomeproduto varchar(255),
    precoproduto double
);
DESCRIBE tb_produtos;

create table tb_pedidos (
	idpedido int auto_increment not null,
    idpessoa int not null,
    dtpedido datetime not null,
    vlpedido decimal(10,2),
    constraint pk_pedido primary key (idpedido),
    constraint fk_pedido_pessoa foreign key (idpessoa) references tb_pessoas (idpessoa)
);
describe tb_pedidos;

###inserção de dados
insert into tb_pessoas (nomepessoa, sexopessoa) values
('emmanuel', 'M'),
('vitoria', 'F'),
('jose', 'M'),
('livia maria', 'F');

insert into tb_pessoas values (5, 'laura emmanuella', 'F', '2021-12-8');

select * from tb_pessoas;

insert into tb_produtos(nomeproduto, precoproduto) values 
('mouse', 20.5),
('teclado', '100'),
('computador', '3000');

select * from tb_produtos;

insert into tb_departamentos(nomedepartamento) values
('vendas'),
('administrativo'),
('RH');

select * from tb_departamentos;

insert into tb_funcionarios(idpessoa,salariofuncionario, iddepartamento, dtadmissaofuncionario) values
(1, 1500, 1, '2021-11-30'),
(2, 1800, 1, '2021-11-30'),
(3, 3200, 2, '2021-01-01'),
(4, 2400, 3, '2022-01-01');
select * from tb_funcionarios;

update tb_departamentos set idfuncionario = 6 where nomedepartamento = 'vendas';
update tb_departamentos set idfuncionario = 7 where nomedepartamento = 'administrativo';
update tb_departamentos set idfuncionario = 8 where nomedepartamento = 'RH';

insert into tb_pedidos (idpessoa, dtpedido, vlpedido) values
(1, current_date(), 120),
(2, current_date(), 203),
(1, '2022-01-15', 59);

insert into tb_pedidos (idpessoa, dtpedido, vlpedido) values
(2, current_date(), 20),
(3, current_date(), 305);

select * from tb_pedidos;

###junções encadeada
select * from tb_pessoas;
select * from tb_funcionarios;

select * from tb_funcionarios 
inner join tb_pessoas using(idpessoa)#resultado desse primeiro join é executado com o próximo
inner join tb_departamentos using(iddepartamento); #No USING colocar a chave estrangeira que liga as tabelas

###Funções para manipulação de datas
#https://dev.mysql.com/doc/refman/8.0/en/date-and-time-functions.html

#date_add adiciona intervalos de tempo a uma data
update tb_funcionarios 
set dtadmissaofuncionario = date_add(dtadmissaofuncionario, interval 60 day) 
where idfuncionario = 5;
select * from tb_funcionarios;

#datediff calcula a diferenca entre as datas
select datediff(current_date(), dtadmissaofuncionario) as 'Tempo de empresa (dias)' 
from tb_funcionarios 
where idfuncionario = 6;

select nomepessoa as 'Funcionário', 
datediff(current_date(), dtadmissaofuncionario) as 'Tempo de empresa (dias)' 
from tb_funcionarios inner join tb_pessoas using (idpessoa)
where idfuncionario = 6;

select nomepessoa as 'Funcionário', 
datediff(current_date(), dtadmissaofuncionario) as 'Tempo de empresa (dias)' 
from tb_funcionarios, tb_pessoas
where tb_funcionarios.idpessoa = tb_pessoas.idpessoa
and idfuncionario = 6;

### Funções de agregação
# https://dev.mysql.com/doc/refman/8.0/en/aggregate-functions.html
SELECT SUM(salariofuncionario) AS 'FOLHA DE PAGAMENTO', 
MAX(salariofuncionario) AS 'MAIOR SALÁRIO', 
MIN(salariofuncionario) AS 'MENOR SALÁRIO',
AVG(salariofuncionario) AS 'SALÁRIO MÉDIO'
FROM tb_funcionarios;

select * from tb_funcionarios;


###Agrupamento####
# https://dev.mysql.com/doc/refman/8.0/en/group-by-modifiers.html

SELECT iddepartamento as 'Departamento', 
COUNT(*) as 'Total de funcionários', 
ROUND(AVG(salariofuncionario),2) as 'Média salarial'
FROM tb_funcionarios
GROUP BY iddepartamento; #agrupa pelo id do departamento

SELECT 
	nomedepartamento as 'Departamento', 
	COUNT(*) as 'Total de funcionários', 
	ROUND(AVG(salariofuncionario),2) as 'Média salarial'
FROM 
	tb_funcionarios inner join tb_departamentos using (iddepartamento)
GROUP BY 
	iddepartamento;


select * from tb_pedidos;

select 
	nomepessoa as 'Cliente', 
	SUM(vlpedido) as 'Total',
	CONVERT(AVG(vlpedido), DEC(10,2)) as 'Média',
	MIN(vlpedido) as 'Mínimo',
	MAX(vlpedido) as 'Máximo' 
from 
	tb_pedidos inner join tb_pessoas using (idpessoa)
where 
	dtpedido <> current_date()
group by 
	idpessoa
having SUM(vlpedido)> 180 #soh pode usar having com group by
order by nomepessoa; # sempre eh a ultima clausula

select 
	nomepessoa as 'Cliente', 
	sum(vlpedido) as 'Total'
from 
	tb_pedidos inner join tb_pessoas using (idpessoa)
group by 
	idpessoa;


###Sub consulta
#https://dev.mysql.com/doc/refman/8.0/en/any-in-some-subqueries.html
select nomepessoa as 'Gerente', nomedepartamento as 'Departamento'
from tb_departamentos inner join tb_funcionarios using (idfuncionario) 
inner join tb_pessoas using (idpessoa);

select nomepessoa as 'Cliente'
from tb_pessoas inner join tb_pedidos using(idpessoa);

#Intersect
#Gerentes que tem pedidos
select 
	nomepessoa as 'Gerente', 
    nomedepartamento as 'Departamento'
from 
	tb_departamentos inner join tb_funcionarios using (idfuncionario) 
	inner join tb_pessoas using (idpessoa)
where nomepessoa in
(select nomepessoa from tb_pessoas inner join tb_pedidos using(idpessoa));

#Total de pedidos dos gerentes
select 
	nomepessoa as 'Gerente', 
	SUM(vlpedido) as 'Total' 
from 
	tb_pedidos inner join tb_pessoas using (idpessoa)
group by 
	idpessoa
having nomepessoa in 
(select nomepessoa 
from tb_departamentos inner join tb_funcionarios using(idfuncionario)
inner join tb_pessoas using(idpessoa));

SELECT 
	nomepessoa as 'Gerente', 
	nomedepartamento as 'Departamento', 
	vlpedido as 'Total Pedido'
FROM tb_departamentos
	INNER JOIN tb_funcionarios USING (idfuncionario)
	INNER JOIN tb_pessoas USING (idpessoa)
	INNER JOIN tb_pedidos USING (idpessoa);


#except
select nomepessoa as 'Gerente', nomedepartamento as 'Departamento'
from tb_departamentos inner join tb_funcionarios using (idfuncionario) 
inner join tb_pessoas using (idpessoa)
where nomepessoa not in
(select nomepessoa from tb_pessoas inner join tb_pedidos using(idpessoa));

select * from tb_pessoas;
select * from tb_funcionarios;

###Union
select nomepessoa 
from tb_funcionarios inner join tb_pessoas using(idpessoa) 
where iddepartamento = 1
union
select nomepessoa 
from tb_funcionarios inner join tb_pessoas using(idpessoa)
where salariofuncionario < 2000;

#union para fazer full outer join
#UNION: UNE OS RETORNOS DOS 2 SELECTS
#RESTRIÇÃO DO UNION: AS COLUNAS DOS 2 SELECTS DEVEM SER IGUAIS
select * from tb_pessoas left join tb_funcionarios using(idpessoa)
union
select * from tb_pessoas rigth join tb_funcionarios using(idpessoa);

###VIEWS
create view v_pedidostotais as
select 
	nomepessoa as 'Cliente', 
	SUM(vlpedido) as 'Total',
	CONVERT(AVG(vlpedido), DEC(10,2)) as 'Média',
	MIN(vlpedido) as 'Mínimo',
	MAX(vlpedido) as 'Máximo' 
from 
	tb_pedidos inner join tb_pessoas using (idpessoa)
group by 
	idpessoa
having SUM(vlpedido)> 180
order by nomepessoa;

select * from v_pedidostotais;

select * from tb_pedidos;
select * from tb_pessoas;

insert into tb_pedidos (idpessoa, dtpedido, vlpedido) values
(4, current_date(), 30),
(4, current_date(), 155);

insert into tb_pedidos (idpessoa, dtpedido, vlpedido) values
(5, current_date(), 230);

select * from v_pedidostotais  where Mínimo >= 30;

#drop view v_pedidostotais;

SELECT * from tb_pessoas;
describe tb_pessoas;

###PROCEDURES

#se colocar ; dentro da procedure, o mysql encerra a procedure
#como temos que fazer comandos que tem ; precisamos mudar o delimitador 
delimiter $$
create procedure sp_pessoa_save(
	#parametros que a procedure vai receber
    nome varchar(255), sexo enum('F', 'M'), dtcadastro timestamp
)
begin
	insert into tb_pessoas (nomepessoa, sexopessoa, dtcadastropessoa) values (nome, sexo, dtcadastro);
    select * from tb_pessoas where idpessoa = last_insert_id();#ultimo id inserido
end $$
delimiter ; #volta ao normal com ;

#para usar a procedure usa a clausula CALL
call sp_pessoa_save('Massaharu', 'M', '2020-10-01');

#stores procedures avancadas

delimiter $$

create procedure sp_funcionario_save(
pdesnome varchar(255),
psexo enum('F', 'M'),
pvlsalario dec(10,2),
pdtadmissao date
)

begin
	declare vidpessoa int;
    start transaction;
    if not exists(select idpessoa from tb_pessoas where nomepessoa = pdesnome) then
		insert into tb_pessoas (nomepessoa, sexopessoa) values(pdesnome, psexo);
        set vidpessoa = last_insert_id();
	else
		select 'Pessoa já cadastrada' as Resultado;
        rollback;
	end if;
    
    if not exists(select idpessoa from tb_funcionarios where idpessoa = vidpessoa) then
		insert into tb_funcionarios (idpessoa, salariofuncionario, dtadmissaofuncionario) values
        (vidpessoa, pvlsalario, pdtadmissao);
	else
		select 'Funcionário já cadastrado' as Resultado;
        rollback;
	end if;
    commit;
    select 'Dados cadastrados com sucesso' as Resultado;

end $$

delimiter ;

call sp_funcionario_save('teste', 'F', 50000, current_date());

select * from tb_pessoas inner join tb_funcionarios using (idpessoa);

drop procedure sp_funcionario_save;

##Function
/*
A diferença entre procedure e funtion eh que a function retorna algo
*/

delimiter $$

create function fn_imposto_renda(
pvlsalario dec(10,2)
)returns dec(10,2)
begin
	declare vimposto dec(10,2);
    set vimposto = case
		when pvlsalario <=1000 then 0
        when pvlsalario <=2000 then (pvlsalario * 0.05)
        when pvlsalario >2000 then (pvlsalario * 0.1)
	end;
    return vimposto; 
end $$

delimiter ;
 #usando a function no select 
select *, fn_imposto_renda(salariofuncionario) as Imposto
from tb_funcionarios inner join tb_pessoas using (idpessoa);