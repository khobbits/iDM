on $*:TEXT:/^[!@]clue/Si:#: { 
  if (# == #iDM || # == #iDM.Staff) && ($me != iDM) { halt }
  if (!$readini(equipment.ini,clue,$nick)) { $iif($left($1,1) == @,msg #,notice $nick) $logo(CLUE) You do not have a Clue Scroll. | halt }
  $iif($left($1,1) == @,msg #,notice $nick) $logo(CLUE) $qt($readini(equipment.ini,clue,$nick)) To solve the clue, simply type !solve answer. Join #iDM or #iDM.Support for help.
}
on *:text:!solve*:#: {
  if (# == #iDM || # == #iDM.Staff) && ($me != iDM) { halt }
  if (!$readini(equipment.ini,clue,$nick)) { notice $nick $logo(CLUE) You do not have a Clue Scroll. | halt }
  if ($2 != $gettok($read(clue.txt,w,$readini(equipment.ini,clue,$nick) $+ *),2,58)) { notice $nick $logo(CLUE) Sorry, that answer is incorrect. Join #iDM or #iDM.Support for assistance. | halt }
  set %clue1 $gettok($read(clueloot.txt,$r(1,$lines(clueloot.txt))),1,58)
  set %clue2 $gettok($read(clueloot.txt,$r(1,$lines(clueloot.txt))),1,58)
  set %clue3 $gettok($read(clueloot.txt,$r(1,$lines(clueloot.txt))),1,58)
  set %cprice1 $gettok($read(clueloot.txt,w, %clue1 $+ *),2,58)
  set %cprice2 $gettok($read(clueloot.txt,w, %clue2 $+ *),2,58)
  set %cprice3 $gettok($read(clueloot.txt,w, %clue3 $+ *),2,58)
  set %combined $calc(%cprice1 + %cprice2 + %cprice3)
  notice $nick $logo(CLUE) Congratulations, that is correct! Reward: $s1($chr(91)) $+ $s2($price(%combined)) $+ $s1($chr(93)) in loot. $s1($chr(91)) $+ %clue1 $+ , $+ %clue2 $+ , $+ %clue3 $+ $s1($chr(93)) 
  writeini -n money.ini money $nick $calc($readini(money.ini,money,$nick) + %combined )
  remini -n equipment.ini clue $nick
  unset %clue* %cprice*
}