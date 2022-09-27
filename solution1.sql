create table `groups`
(
    id   int         not null primary key,
    name varchar(50) not null
);

create table users
(
    id                 int         not null primary key,
    group_id           int         not null,
    invited_by_user_id int         not null,
    name               varchar(50) not null,
    posts_qty          int         not null,
    constraint fk_users_group_id
        foreign key (group_id) references `groups` (id)
            on update cascade on delete cascade
);

insert into `groups`
    (id, name)
values (1, 'Группа 1'),
       (2, 'Группа 2');

insert into users
    (id, group_id, invited_by_user_id, name, posts_qty)
values (1, 1, 0, 'Пользователь 1', 0),
       (2, 1, 1, 'Пользователь 2', 2),
       (3, 1, 2, 'Пользователь 3', 5),
       (4, 2, 3, 'Пользователь 4', 7),
       (5, 2, 4, 'Пользователь 5', 1);


# 1. Выборки пользователей, у которых количество постов больше, чем у пользователя их пригласившего.
select invited.*, inviter.posts_qty
from users as invited
         join users as inviter on inviter.id = invited.invited_by_user_id
where inviter.posts_qty < invited.posts_qty;

# 2. Выборки пользователей, имеющих максимальное количество постов в своей группе.
select *
from users,
     (select grouped.group_id, max(grouped.posts_qty) as max_posts_qty
      from users as grouped
      group by grouped.group_id) as t
where users.group_id = t.group_id
  and users.posts_qty = t.max_posts_qty;

# 3. Выборки групп, количество пользователей в которых превышает 10000.
select `groups`.id, `groups`.name, count(users.id) as users_qty
from `groups`
         join users on `groups`.id = users.group_id
group by `groups`.id
having users_qty > 10000;

# 4. Выборки пользователей, у которых пригласивший их пользователь из другой группы.
select invited.*, inviter.group_id
from users as invited
         join users as inviter on invited.invited_by_user_id = inviter.id
where invited.group_id != inviter.group_id;

# 5. Выборки групп с максимальным количеством постов у пользователей.
select `groups`.*, posts_qty
from `groups`,
     (select grouped.group_id, sum(grouped.posts_qty) as posts_qty
      from users as grouped
      group by grouped.group_id) as group_posts
where `groups`.id = group_posts.group_id
  and group_posts.posts_qty = (select max(max_posts.posts_qty)
                               from (select sum(posts_qty) as posts_qty
                                     from users
                                     group by users.group_id) as max_posts);