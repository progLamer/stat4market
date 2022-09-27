В связи с тем, что MySQL для изменения схемы блокирует таблицу, создает новую схему, копирует данные, 
а потом подменяет таблицу. Невозможно просто выполнить запрос на изменение большой таблицы 
и не заблокировать полностью эту таблицу на долго.

Для решения задачи изменения схемы можно, либо изобретать велосипед, либо пользоваться готовыми инструментами.

### Вариант 1 ###
Воспользоваться [Percona Toolkit](https://docs.percona.com/percona-toolkit/pt-online-schema-change.html)

`pt-online-schema-change --alter "add column1 int, add column2 int, add column3 int, rename column column_old to column_new, add index index1 (column1), add index index2 (column2)" D=big_db,t=big_table`

### Вариант 2 ###
Сделать master-slave репликацию. На slave изменить схему. Заменить master на slave.

DDL:
```
alter table big_table
    add column1 int,
    add column2 int,
    add column3 int,
    rename column column_old to column_new,
    add index index1 (column1),
    add index index2 (column2);
```

### Вариант 3 ###
- создание новой таблицы из старой и изменение схемы:
```
create table new_table like big_table;

alter table new_table
add column1 int,
add column2 int,
add column3 int,
rename column column_old to column_new,
add index index1 (column1),
add index index2 (column2);
```
- создание триггеров для обновления данных в новой таблице при их изменении в старой:
```
delimiter ;;

create trigger big_table_after_delete after DELETE ON big_table for each row
begin
  delete from new_table where id=OLD.id;
end;;

create trigger big_table_after_insert after insert on big_table for each row
begin
  insert into new_table (id, ..., column1, column2, column3, column_new) values (NEW.id, ..., 0, 0, 0, column_old);
end;;

create trigger big_table_after_update after UPDATE ON users for each row
begin
  if (OLD.id != NEW.id) then
    delete from new_table where id=OLD.id;
  end if;
  insert into new_table (id, ..., column1, column2, column3, column_new) values (NEW.id, ..., 0, 0, 0, column_old)
  on duplicate key update ..., column_new = column_old;
end;;

delimiter ;
```
- порционное копирование данных из старой таблицы в новую, где количество копируемых за раз строк надо подбирать так, 
чтобы индексы не перестраивались слишком часто и не слишком долго, а смещение каждый новый запрос увеличивалось на 
количество копируемых строк:
```
insert ingnore into new_table (id, ..., column1, column2, column3, column_new) 
select id, ..., 0, 0, 0, column_old from big_table limit 10000 offset ...
```
- подменяем таблицы:
```
rename table big_table TO old_table, new_table TO big_table;
```