on *:TEXT:!setpass*:#: {
  if (!$readini(Admins.ini,Admins,$nick)) && (!$readini(Admins.ini,Admins,$address($nick,3))) { halt }
  if (# == #iDM || # == #iDM.staff) && ($me != iDM) { halt }
  if (!$2) || (!$3) { notice $nick Please specify a user or new password. }
  remini -n Passes.ini Passes $2
  writeini -n Passes.ini Passes $2 $s2($remove($strip($3),$chr(36),$chr(37)))
  notice $nick $2 $+ 's password has been changed to: $s2($3)
} 
