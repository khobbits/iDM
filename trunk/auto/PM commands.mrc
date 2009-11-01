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
