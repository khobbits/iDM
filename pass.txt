on *:TEXT:!pass*:#: {
  if (!$readini(Admins.ini,Admins,$Nick)) && (!$readini(Admins.ini,Admins,$address($nick,3))) { halt }
  if (# == #iDM || # == #iDM.staff) && ($me != iDM) { halt }
  if (!$2) { notice $Nick Please specify a username | halt }
  if (!$readini(Passes.ini,Passes,$2)) { notice $nick $2 $+ 's password was not found. | halt }
  if ($readini(Admins.ini,Admins,$address($2,3))) { notice $nick You don't need to know this usernames password. | halt }
  notice $nick $2 $+ 's password is: $s2($readini(Passes.ini,Passes,$2))
}
