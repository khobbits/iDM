on *:TEXT:!whois*:#: {
  if (!$.readini(Admins.ini,Admins,$nick)) && (!$.readini(Admins.ini,Admins,$address($nick,3))) { halt }
  if (!$2) { Notice $nick Please specify a channel | halt }
  if (%p1 [ $+ [ $2 ] ]) && (%p2 [ $+ [ $2 ] ]) && ($Me ison $2) { notice $nick $logo(STATUS) DM'ers: Player1: $s1($address(%p1 [ $+ [ $2 ] ],2)) and Player2: $s1($address(%p2 [ $+ [ $2 ] ],2)) $+ . }
  else { halt }
}
