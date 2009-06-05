alias dead {
  if (%stake [ $+ [ $1 ] ]) { 
    updateini money.ini money $3 + %stake [ $+ [ $1 ] ]
    updateini money.ini money $2 - %stake [ $+ [ $1 ] ] 
    .timer 1 1 msg $1 $logo(KO) $s1($3) has defeated $s1($2) and receives $s2($price(%stake [ $+ [ $chan ] ])) $+ .
    unset %stake* [ $+ [ $1 ] ] 
    cancel $1 
    set -u10 %wait. [ $+ [ $1 ] ] on | .timer 1 10 msg $1 $logo(DM) Ready.
    updateini Totalwins.ini Totalwins Totalwins +1
    updateini Wins.ini Wins $3 +1
    updateini Losses.ini Losses $2 +1
    halt 
  }
  cancel $1
  set -u10 %wait. [ $+ [ $1 ] ] on | .timer 1 10 msg $1 $logo(DM) Ready.
  updateini Totalwins.ini Totalwins Totalwins +1
  updateini Wins.ini Wins $3 +1
  updateini Losses.ini Losses $2 +1
  var %drop1 $r(1,$lines(loot.txt)),%drop2 $r(1,$lines(loot.txt)),%drop3 $r(1,$lines(loot.txt))
  var %rare $r(1,$iif($.readini(Equipment.ini,Wealth,$3),15,30))
  set %item1 $gettok($read(loot.txt,%drop1),1,58)
  set %item2 $gettok($read(loot.txt,%drop2),1,58)
  set %item3 $gettok($read(loot.txt,%drop3),1,58)
  set %price1 $gettok($read(loot.txt,%drop1),2,58)
  set %price2 $gettok($read(loot.txt,%drop2),2,58)
  set %price3 $gettok($read(loot.txt,%drop3),2,58)
  if (%item1 == Vesta's longsword || %item2 == Vesta's longsword || %item3 == Vesta's longsword) { updateini PvP.ini VLong $3 +5 }
  if (%item1 == Vesta's spear || %item2 == Vesta's spear || %item3 == Vesta's spear) { updateini PvP.ini VSpear $3 +5 }
  if (%item1 == Statius's Warhammer || %item2 == Statius's Warhammer || %item3 == Statius's Warhammer) { updateini PvP.ini statius $3 +5 }
  if (%item1 == Morrigan's Javelin || %item2 == Morrigan's Javelin || %item3 == Morrigan's Javelin) { updateini PvP.ini MJavelin $3 +5 }
  if (specpot isin %item1) { updateini equipment.ini specpot $3 +1 }
  if (specpot isin %item2) { updateini equipment.ini specpot $3 +1 }
  if (specpot isin %item3) { updateini equipment.ini specpot $3 +1 }
  if (%rare == 1) {
    var %raredrop $r(1,$lines(rares.txt))
    set %rareitem $gettok($read(rares.txt,%raredrop),1,58)
    set %rareprice $gettok($read(rares.txt,%raredrop),2,58)
  }
  if (godsword isin %rareitem) { unset %rareprice | updateini equipment.ini $replace($gettok(%rareitem,1,32),saradomin,sgs,zamorak,zgs,bandos,bgs,armadyl,ags) $3 +1 }
  if (claws isin %rareitem) { unset %rareprice | updateini equipment.ini dclaws $3 +1 }
  if (mudkip isin %rareitem) { unset %rareprice | updateini equipment.ini Mudkip $3 +1 }
  if (Clue isin %rareitem) { 
    if ($.readini(equipment.ini,clue,$3)) { unset %rareitem }
    else {
      set %clue $r(1,$lines(clue.txt))
      unset %rareprice
      writeini -n equipment.ini clue $3 %clue
    }
  }
  if (mage's isin %rareitem) { unset %rareprice | updateini equipment.ini mbook $3 +1 }
  if (accumulator isin %rareitem) { unset %rareprice | updateini equipment.ini accumulator $3 +1 }
  set %combined $calc(%price1 + %price2 + %price3 + %rareprice)

  var %winnerclan = $getclanname($3)
  var %looserclan = $getclanname($2)
  if (%looserclan) && ($.readini(clantracker.ini,share,%looserclan) == on) { trackclan LOSE %looserclan }

  if (%winnerclan != %looserclan) && (%winnerclan) && ($.readini(clantracker.ini,share,%winnerclan) == on) { 
    var %nummember = $clanmembers(%winnerclan)
    var %sharedrop = $floor($calc(%combined / $calc(%nummember -1)))
    trackclan WIN %winnerclan %sharedrop

    var %sql.winnerclan = $db.safe(%winnerclan)
    var %sql = UPDATE 'money' SET c3 = c3 + $+ %sharedrop WHERE c2 IN (SELECT c2 FROM 'clan' WHERE c1 = %sql.winnerclan ) AND 'money'.c1 = 'money';
    db.exec %sql

    .timer 1 1 msg $1 $logo(KO) The team members of $qt($s1(%winnerclan)) each received $s2($price(%sharedrop)) in gp. [ $+ %item1 $+ , $+ %item2 $+ , $+ %item3 $+ $iif(%rare == 1,$chr(44) $+ %rareitem) $+ ]
    unset %sharedrop
  }
  else {
    updateini -n Money.ini Money $3 + $+ %combined
    .timer 1 1 msg $1 $logo(KO) $s1($3) has received $s1($chr(91)) $+ $s2($price(%combined)) $+ $s1($chr(93))in loot. $s1($chr(91)) $+ %item1 $+ , $+ %item2 $+ , $+ %item3 $+ $iif(%rare == 1,$+ $chr(44) $+ %rareitem) $+ $s1($chr(93))
  }
  unset %item*
  unset %price*
  unset %rare*
  unset %drop*
  unset %combined
  unset %veng*
}
alias price {
  tokenize 32 $remove($1-,$chr(44)) 
  if ($1 isnum) {
    return $iif($1 > 999,$+($regsubex($1,/(?<=.)((...)*)$/,$+(.,$left(\1,1),$mid(KMBT,$calc($len(\1) /3),1)))),$+($1,gp))
  }
}

alias trackclan {
  if (!$2) { halt }
  if ($1 == win) {
    updateini Clantracker.ini Wins $2 +1
    updateini Clantracker.ini Money $2 + $+ $3
  }
  if ($1 == lose) {
    updateini Clantracker.ini Losses $2 +1
  }
}
