on *:TEXT:reg*:?: {
  tokenize 32 $remove($1-,$chr(36),$chr(37))
  if ($readini(Passes.ini,Passes,$nick)) { notice $nick You're already registered. To login, ( $+ /msg $me id pass $+ ) | halt }
  if (!$2) { notice $nick To register.. ( $+ /msg $me reg pass $+ ) (Don't use your RuneScape password) | halt }
  if ($len($2) < 4) { notice $nick Please choose a password of over 4 characters. | halt }
  if ($2 == pass) { notice $nick You can't use this as your password, try something more secure. | halt }
  notice $nick You have registered your nickname. Your password is $s2($remove($strip($2),$chr(36),$chr(37))) $+ .
  writeini -n Passes.ini Passes $nick $s2($remove($strip($2),$chr(36),$chr(37)))
  writeini login.ini Login $nick true
}
on *:TEXT:id*:?: {
  if (!$readini(Passes.ini,Passes,$nick)) { notice $nick You have to register first. To register, ( $+ /msg $me reg pass $+ ) (Don't use your RuneScape password) | halt }
  if ($2 != $readini(Passes.ini,Passes,$nick)) { notice $nick That password is incorrect. | halt }
  if ($readini(login.ini,login,$nick)) { notice $nick You're already logged in. | halt }
  writeini login.ini Login $nick true
  notice $nick Password accepted, you are now logged in.
}
on *:TEXT:logout*:?: {
  if (!$readini(Passes.ini,Passes,$nick)) { notice $nick You have to register first. To register, ( $+ /msg $me reg pass $+ ) | halt }
  if (!$readini(login.ini,login,$nick)) { notice $nick You're not logged in.. To login, ( $+ /msg $me id pass $+ ) | halt }
  remini login.ini Login $nick
  unset %login. [ $+ [ $nick ] ]
  notice $nick You are now logged out.
}
