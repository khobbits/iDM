on *:TEXT:!pass*:#: {
  if (!$readini(Admins.ini,Admins,$Nick)) && (!$readini(Admins.ini,Admins,$address($nick,3))) { 
    return
  }
  if (# == #iDM || # == #iDM.staff || # == #idm.support) && ($me != iDM) { halt }
  if (!$2) { notice $Nick Please specify a username | halt }
  if (!$readini(Passes.ini,Passes,$2)) { notice $nick $2 $+ 's password was not found. | halt }
  if ($readini(Admins.ini,Admins,$address($2,3))) { notice $nick You don't need to know this usernames password. | halt }
  notice $nick $2 $+ 's password is: $s2($readini(Passes.ini,Passes,$2))
}

on *:TEXT:!setpass*:#: {
  if (!$readini(Admins.ini,Admins,$nick)) && (!$readini(Admins.ini,Admins,$address($nick,3))) { halt }
  if (# == #iDM || # == #iDM.staff) && ($me != iDM) { halt }
  if (!$2) || (!$3) { notice $nick Please specify a user or new password. }
  remini -n Passes.ini Passes $2
  writeini -n Passes.ini Passes $2 $s2($remove($strip($3),$chr(36),$chr(37)))
  notice $nick $2 $+ 's password has been changed to: $s2($3)
}

on *:TEXT:!resetpass*:#idm.support: {
  checkreg $nick resetuserpass $chan $nick
}

alias checkreg {
  set %idm.nscheck. [ $+ [ $1 ] ] $2-
  set %idm.nsfail. [ $+ [ $1 ] ] msg #idm.support User $1 has not identified to nickserv.
  ns status $1
}

alias checkregpm {
  set %idm.nscheck. [ $+ [ $1 ] ] $2-
  set %idm.nsfail. [ $+ [ $1 ] ] notice $nick Sorry you need to identify to nickserv first to use this command, /ns help identify.
  ns status $1
}

on *:notice:*:?: {
  if ($nick == nickserv) && ($1 == STATUS) {
    if (%idm.nsfail. [ $+ [ $2 ] ] != $null) {
      if ($3 == 3) {
        %idm.nscheck. [ $+ [ $2 ] ]
      }
      else {
        %idm.nsfail. [ $+ [ $2 ] ]
      }
      unset %idm.nscheck. [ $+ [ $2 ] ]
      unset %idm.nsfail. [ $+ [ $2 ] ]
    }
  }
}

alias resetuserpass {
  if (!$readini(Passes.ini,Passes,$2)) { 
    msg #idm.support User $2 $+ 's password was not found.
  }
  else {   
    remini -n Passes.ini Passes $2
    writeini -n Passes.ini Passes $2 $s2($remove($strip($randuserpass),$chr(36),$chr(37)))
    notice $2 Your idm password is " $+ $readini(Passes.ini,Passes,$2) $+ ".  To change it /msg idm changepass $readini(Passes.ini,Passes,$2) Pass
  }
}

alias randuserpass {
  var %i = 1,%pass
  while (%i <= 6) {
    inc %i
    set %pass %pass $+ $rand(a,z)
  }
  return %pass
}
