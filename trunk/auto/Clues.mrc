on $*:TEXT:/^[!@.]dmclue/Si:#: { 
  if (# == #iDM || # == #iDM.Staff) && ($me != iDM) { halt }
  if ($db.get(equip_item,clue,$nick) === 0) { $iif($left($1,1) == @,msg #,notice $nick) $logo(CLUE) You do not have a Clue Scroll. | halt }
  $iif($left($1,1) == @,msg #,notice $nick) $logo(CLUE) $qt($gettok($read(clue.txt,$db.get(equip_item,clue,$nick)),1,58)) To solve the clue, simply type !solve answer. Join #iDM or #iDM.Support for help.
}
on $*:TEXT:/^[!@.]solve/Si:#: { 
  if (# == #iDM || # == #iDM.Staff) && ($me != iDM) { halt }
  if ($db.get(equip_item,clue,$nick) === 0) { notice $nick $logo(CLUE) You do not have a Clue Scroll. | halt }
  if ($istok($gettok($read(clue.txt,$db.get(equip_item,clue,$nick)),2,58),$2,33) != $true) || (!$2) { notice $nick $logo(CLUE) Sorry, that answer is incorrect. Join #iDM or #iDM.Support for assistance. | halt }
  var %a = $r(1,$lines(clueloot.txt)),%b = $r(1,$lines(clueloot.txt)),%c = $r(1,$lines(clueloot.txt))
  set %clue1 $gettok($read(clueloot.txt,%a),1,58)
  set %clue2 $gettok($read(clueloot.txt,%b),1,58)
  set %clue3 $gettok($read(clueloot.txt,%c),1,58)
  set %cprice1 $gettok($read(clueloot.txt,%a),2,58)
  set %cprice2 $gettok($read(clueloot.txt,%b),2,58)
  set %cprice3 $gettok($read(clueloot.txt,%c),2,58)
  var %combined $calc(%cprice1 + %cprice2 + %cprice3)
  notice $nick $logo(CLUE) Congratulations, that is correct! Reward: $s1($chr(91)) $+ $s2($price(%combined)) $+ $s1($chr(93)) in loot. $s1($chr(91)) $+ %clue1 $+ , $+ %clue2 $+ , $+ %clue3 $+ $s1($chr(93)) 
  db.set user money $nick + %combined
  db.set equip_item clue 0
  unset %clue* %cprice*
}
