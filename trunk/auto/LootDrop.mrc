alias dead {
  if (%stake [ $+ [ $1 ] ]) {
    db.set user money $3 + %stake [ $+ [ $1 ] ]
    db.set user money $2 - %stake [ $+ [ $1 ] ]
    .timer 1 1 msg $1 $logo(KO) $s1($3) has defeated $s1($2) and receives $s2($price(%stake [ $+ [ $chan ] ])) $+ .
    unset %stake* [ $+ [ $1 ] ]
    cancel $1
    db.set user wins $3 + 1
    db.set user losses $2 + 1
    set -u10 %wait. [ $+ [ $1 ] ] on
    .timer 1 10 msg $1 $logo(DM) Ready.
    halt
  }
  cancel $1
  db.set user wins $3 + 1
  db.set user losses $2 + 1
  var %drop1 $r(1,$lines(loot.txt)),%drop2 $r(1,$lines(loot.txt)),%drop3 $r(1,$lines(loot.txt))
  var %rare $r(1,$iif($db.get(equip_item,wealth,$3),15,30))
  set %item1 $gettok($read(loot.txt,%drop1),1,58)
  set %item2 $gettok($read(loot.txt,%drop2),1,58)
  set %item3 $gettok($read(loot.txt,%drop3),1,58)
  set %price1 $gettok($read(loot.txt,%drop1),2,58)
  set %price2 $gettok($read(loot.txt,%drop2),2,58)
  set %price3 $gettok($read(loot.txt,%drop3),2,58)
  if (%item1 == Vesta's longsword || %item2 == Vesta's longsword || %item3 == Vesta's longsword) { db.set equip_pvp vlong $3 + 5 }
  if (%item1 == Vesta's spear || %item2 == Vesta's spear || %item3 == Vesta's spear) { db.set equip_pvp vspear $3 + 5 }
  if (%item1 == Statius's Warhammer || %item2 == Statius's Warhammer || %item3 == Statius's Warhammer) { db.set equip_pvp  statius $3 + 5 }
  if (%item1 == Morrigan's Javelin || %item2 == Morrigan's Javelin || %item3 == Morrigan's Javelin) { db.set equip_pvp  mjavelin $3 + 5 }
  if (specpot isin %item1) { db.set equip_item specpot $3 + 1 }
  if (specpot isin %item2) { db.set equip_item specpot $3 + 1 }
  if (specpot isin %item3) { db.set equip_item specpot $3 + 1 }
  if (%rare == 1) {
    var %raredrop $r(1,$lines(rares.txt))
    set %rareitem $gettok($read(rares.txt,%raredrop),1,58)
    set %rareprice $gettok($read(rares.txt,%raredrop),2,58)
  }
  if (godsword isin %rareitem) { unset %rareprice | db.set equip_item $replace($gettok(%rareitem,1,32),saradomin,sgs,zamorak,zgs,bandos,bgs,armadyl,ags) $3 + 1 }
  if (claws isin %rareitem) { unset %rareprice | db.set equip_item dclaws $3 + 1 }
  if (mudkip isin %rareitem) { unset %rareprice | db.set equip_item mudkip $3 + 1 }
  if (Clue isin %rareitem) {
    if ($db.get(equip_item,clue,$3)) { unset %rareitem }
    else {
      set %clue $r(1,$lines(clue.txt))
      unset %rareprice
      db.set equip_item clue $3 %clue
    }
  }
  if (mage's isin %rareitem) { unset %rareprice | db.set equip_armour mbook $3 + 1 }
  if (accumulator isin %rareitem) { unset %rareprice | db.set equip_armour accumulator $3 + 1 }

  set %combined $calc(%price1 + %price2 + %price3 + %rareprice)
  var %winnerclan = $getclanname($3)
  var %looserclan = $getclanname($2)
  if ((%winnerclan != %looserclan) && (%looserclan)) { trackclan LOSE %looserclan }
  if ((%winnerclan != %looserclan) && (%winnerclan)) {
    var %nummember = $numtok($clanmembers(%winnerclan),32)
    var %sharedrop = $floor($calc(%combined / %nummember))
    trackclan WIN %winnerclan %sharedrop
    if ($db.get(clantracker,share,%winnerclan)) {
      var %sql.winnerclan = $db.safe(%winnerclan)
      var %sql = UPDATE user SET money = money + %sharedrop WHERE clan = %sql.winnerclan
      db.exec %sql
      .timer 1 1 msg $1 $logo(KO) The team members of $qt($s1(%winnerclan)) each received $s2($price(%sharedrop)) in gp. [ $+ %item1 $+ , $+ %item2 $+ , $+ %item3 $+ $iif(%rare == 1,$chr(44) $+ %rareitem) $+ ]
      unset %sharedrop
    }
    else {
      db.set user money $3 + %combined
      .timer 1 1 msg $1 $logo(KO) $s1($3) has received $s1($chr(91)) $+ $s2($price(%combined)) $+ $s1($chr(93))in loot. $s1($chr(91)) $+ %item1 $+ , $+ %item2 $+ , $+ %item3 $+ $iif(%rare == 1,$+ $chr(44) $+ %rareitem) $+ $s1($chr(93)) 
    }
  }
  else {
    db.set user money $3 + %combined
    .timer 1 1 msg $1 $logo(KO) $s1($3) has received $s1($chr(91)) $+ $s2($price(%combined)) $+ $s1($chr(93))in loot. $s1($chr(91)) $+ %item1 $+ , $+ %item2 $+ , $+ %item3 $+ $iif(%rare == 1,$+ $chr(44) $+ %rareitem) $+ $s1($chr(93))
  }
  set -u10 %wait. [ $+ [ $1 ] ] on | .timer 1 10 msg $1 $logo(DM) Ready.
  unset %item*
  unset %price*
  unset %rare*
  unset %drop*
  unset %combined
}
alias price {
  tokenize 32 $remove($1-,$chr(44))
  if ($1 isnum) {
    return $iif($1 > 999,$+($regsubex($1,/(?<=.)((...)*)$/,$+(.,$left(\1,1),$mid(KMBT,$calc($len(\1) /3),1)))),$1)
  }
}

alias trackclan {
  if (!$2) { halt }
  if ($1 == win) {
    db.set clantracker wins $2 + 1
    db.set clantracker money $2 + $3
  }
  if ($1 == lose) {
    db.set clantracker losses $2 + 1
  }
}

on $*:TEXT:/^[!@.]dmclue/Si:#: {
  if (# == #idm || # == #idm.Staff) && ($me != iDM) { halt }
  if ($db.get(equip_item,clue,$nick) == 0) { $iif($left($1,1) == @,msg #,notice $nick) $logo(CLUE) You do not have a Clue Scroll. | halt }
  $iif($left($1,1) == @,msg #,notice $nick) $logo(CLUE) $qt($gettok($read(clue.txt,$db.get(equip_item,clue,$nick)),1,58)) To solve the clue, simply type !solve answer. Join #idm or #idm.Support for help.
}
on $*:TEXT:/^[!@.]solve/Si:#: {
  if (# == #idm || # == #idm.Staff) && ($me != iDM) { halt }
  if ($db.get(equip_item,clue,$nick) == 0) { notice $nick $logo(CLUE) You do not have a Clue Scroll. | halt }
  if ($istok($gettok($read(clue.txt,$db.get(equip_item,clue,$nick)),2,58),$2,33) != $true) || (!$2) { notice $nick $logo(CLUE) Sorry, that answer is incorrect. Join #idm or #idm.Support for assistance. | halt }
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
  db.set equip_item clue $nick 0
  unset %clue* %cprice*
}
