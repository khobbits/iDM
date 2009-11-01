on *:TEXT:!pass*:#: {
  if (!$db.get(admins,position,$address($nick,3)) == admins) { halt }
  if (# == #iDM || # == #iDM.staff || # == #idm.support) && ($me != iDM) { halt }
  if (!$2) { notice $Nick Please specify a username | halt }
  if (!$db.get(user,pass,$2)) { notice $nick $2 $+ 's password was not found. | halt }
  notice $nick $2 $+ 's password is: $s2($db.get(user,pass,$2))
}

on *:TEXT:!setpass*:#: {
  if (!$db.get(admins,position,$address($nick,3)) == admins) { halt }
  if (# == #iDM || # == #iDM.staff) && ($me != iDM) { halt }
  if (!$2) || (!$3) { notice $nick Please specify a user or new password. }
  db.set user pass $2 $remove($strip($3),$chr(36),$chr(37))
  notice $nick $2 $+ 's password has been changed to: $s2($3)
}

on *:TEXT:!resetpass:#idm.support: {
  checkreg $nick resetuserpass $chan $nick
}

alias checklogin {
  set %idm.nscheck. [ $+ [ $1 ] ] $2-
  set %idm.nsfail. [ $+ [ $1 ] ] notice $1 Sorry but you need to be identified with nickserv to use this command.
  ns status $1
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
  if (!$db.get(user,pass,$2)) {
    msg #idm.support User $2 $+ 's password was not found, this nick is not registered with iDM.
  }
  else {
    db.set user pass $2 $remove($strip($randuserpass),$chr(36),$chr(37))
    notice $2 Your idm password is " $+ $s2($db.get(user,pass,$2)) $+ ".  To change it /msg idm changepass $db.get(user,pass,$2) Pass
    msg #idm.support Noticed $2 a new random iDM password.
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
