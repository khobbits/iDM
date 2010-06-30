alias clanconvert {
createini clan
  var %sql = insert into 'clan' (c1, c2, c3) SELECT cl.c3, cl.c2, 'owner' FROM 'clans' cl JOIN (SELECT * FROM 'personalclan' where c3 like '%:owner') pc ON cl.c2 = pc.c2
  db.exec %sql
  var %sql = insert into 'clan' (c1, c2, c3) SELECT cl.c3, cl.c2, 'member' FROM 'clans' cl JOIN (SELECT * FROM 'personalclan' where c3 not like '%:owner') pc ON cl.c2 = pc.c2
  db.exec %sql
  var %sql = insert into 'clantracker' (c2, c1, c3) SELECT Distinct(cl.c3), 'share', '1' FROM "clans" cl JOIN (SELECT * FROM 'clannames' where c2 = 'share') pc ON cl.c3 = pc.c1
  db.exec %sql
}