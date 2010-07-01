on *:TEXT:reg*:?: {
  tokenize 32 $remove($1-,$chr(36),$chr(37))
  if ($db.get(user,pass,$nick)) { notice $nick You're already registered. To login, ( $+ /msg $me ident password $+ ) | halt }
  if (!$2) { notice $nick To register.. ( $+ /msg $me reg pass $+ ) (Don't use your RuneScape pass) | halt }
  if ($len($2) < 4) { notice $nick Please choose a password of over 4 characters. | halt }
  if ($2 == pass) { notice $nick You can't use this as your password, try something more secure. | halt }
  notice $nick You have just registered on iDM. To login type /msg idm identify $s2($remove($strip($2),$chr(36),$chr(37))) $+ .
  db.set user pass $nick $remove($strip($2),$chr(36),$chr(37))
  db.set user login $nick $ctime
}

on *:TEXT:changepass*:?: {
  tokenize 32 $remove($1-,$chr(36),$chr(37))
  if (!$db.get(user,pass,$nick)) { notice $nick You have to register first. To register, ( $+ /msg $me reg password $+ ) (Don't use your RuneScape password) | halt }
  if (!$3) { notice $nick To change your password.. ( $+ /msg $me changepass oldpass pass $+ ) (Don't use your RuneScape password) | halt }
  if ($len($3) < 4) { notice $nick Please choose a password of over 4 characters. | halt }
  if ($3 == pass) { notice $nick You can't use this as your password, try something more secure. | halt }
  if ($2 != $db.get(user,pass,$nick)) { notice $nick Your old password was incorrect. | halt }
  checkregpm $nick changeuserpass $nick $2 $3
}

alias changeuserpass {
  notice $1 You have changed your password. Your new password is $s2($remove($strip($3),$chr(36),$chr(37))) $+ .
  db.set user pass $1 $remove($strip($3),$chr(36),$chr(37))
  db.set user login $1 $ctime
}

on *:TEXT:id*:?: {
  if (!$db.get(user,pass,$nick)) { notice $nick You have to register first. To register, ( $+ /msg $me reg password $+ ) (Don't use your RuneScape password) | halt }
  if ($2 != $db.get(user,pass,$nick)) {
    notice $nick That password is incorrect. | halt
  }
  db.set user login $nick $ctime
  notice $nick Password accepted, you are now logged in.
}

on *:TEXT:logout*:?: {
  if (!$db.get(user,pass,$nick)) { notice $nick You have to register first. To register, ( $+ /msg $me reg password $+ ) | halt }
  db.set user login $nick 0
  unset %login. [ $+ [ $nick ] ]
  notice $nick You are now logged out.
}

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
