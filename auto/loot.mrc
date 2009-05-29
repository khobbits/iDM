alias dead {
  if (%stake [ $+ [ $1 ] ]) { 
    writeini -n money.ini money $3 $calc($.readini(money.ini,money,$3) + %stake [ $+ [ $1 ] ] ) 
    writeini -n money.ini money $2 $calc($.readini(money.ini,money,$2) - %stake [ $+ [ $1 ] ] ) 
    .timer 1 1 msg $1 $logo(KO) $s1($3) has defeated $s1($2) and receives $s2($price(%stake [ $+ [ $chan ] ])) $+ .
    unset %stake* [ $+ [ $1 ] ] 
    cancel $1 
    set -u10 %wait. [ $+ [ $1 ] ] on | .timer 1 10 msg $1 $logo(DM) Ready.
    writeini -n Totalwins.ini Totalwins Totalwins $calc($.readini(Totalwins.ini,Totalwins,Totalwins) + 1)
    writeini -n Wins.ini Wins $3 $calc($.readini(Wins.ini,Wins,$3) + 1)
    writeini -n Losses.ini Losses $2 $calc($.readini(Losses.ini,Losses,$2) + 1)
    halt 
  }
  cancel $1
  set -u10 %wait. [ $+ [ $1 ] ] on | .timer 1 10 msg $1 $logo(DM) Ready.
  writeini -n Totalwins.ini Totalwins Totalwins $calc($.readini(Totalwins.ini,Totalwins,Totalwins) + 1)
  writeini -n Wins.ini Wins $3 $calc($.readini(Wins.ini,Wins,$3) + 1)
  writeini -n Losses.ini Losses $2 $calc($.readini(Losses.ini,Losses,$2) + 1)
  if ($gettok($.readini(Personalclan.ini,Person,$2),1,58)) && ($.readini(Clannames.ini,$gettok($.readini(Personalclan.ini,Person,$2),1,58),share) == on) { trackclan LOSE $gettok($.readini(Personalclan.ini,Person,$2),1,58) }
  var %drop1 $r(1,$lines(loot.txt)),%drop2 $r(1,$lines(loot.txt)),%drop3 $r(1,$lines(loot.txt))
  var %rare $r(1,$iif($.readini(Equipment.ini,Wealth,$3),15,30))
  set %item1 $gettok($read(loot.txt,%drop1),1,58)
  set %item2 $gettok($read(loot.txt,%drop2),1,58)
  set %item3 $gettok($read(loot.txt,%drop3),1,58)
  set %price1 $gettok($read(loot.txt,%drop1),2,58)
  set %price2 $gettok($read(loot.txt,%drop2),2,58)
  set %price3 $gettok($read(loot.txt,%drop3),2,58)
  if (%item1 == Vesta's longsword || %item2 == Vesta's longsword || %item3 == Vesta's longsword) { writeini -n PvP.ini VLong $3 $calc($.readini(PvP.ini,VLong,$3) +5) }
  if (%item1 == Vesta's spear || %item2 == Vesta's spear || %item3 == Vesta's spear) { writeini -n PvP.ini VSpear $3 $calc($.readini(PvP.ini,VSpear,$3) +5) }
  if (%item1 == Statius's Warhammer || %item2 == Statius's Warhammer || %item3 == Statius's Warhammer) { writeini -n PvP.ini statius $3 $calc($.readini(PvP.ini,statius,$3) +5) }
  if (%item1 == Morrigan's Javelin || %item2 == Morrigan's Javelin || %item3 == Morrigan's Javelin) { writeini -n PvP.ini MJavelin $3 $calc($.readini(PvP.ini,MJavelin,$3) +5) }
  if (specpot isin %item1) { writeini -n equipment.ini specpot $3 $calc($.readini(equipment.ini,specpot,$3) + 1) }
  if (specpot isin %item2) { writeini -n equipment.ini specpot $3 $calc($.readini(equipment.ini,specpot,$3) + 1) }
  if (specpot isin %item3) { writeini -n equipment.ini specpot $3 $calc($.readini(equipment.ini,specpot,$3) + 1) }
  if (%rare == 1) {
    var %raredrop $r(1,$lines(rares.txt))
    set %rareitem $gettok($read(rares.txt,%raredrop),1,58)
    set %rareprice $gettok($read(rares.txt,%raredrop),2,58)
  }
  if (godsword isin %rareitem) { unset %rareprice | writeini -n equipment.ini $replace($gettok(%rareitem,1,32),saradomin,sgs,zamorak,zgs,bandos,bgs,armadyl,ags) $3 $calc($.readini(equipment.ini,$replace($gettok(%rareitem,1,32),saradomin,sgs,zamorak,zgs,bandos,bgs,armadyl,ags),$3) + 1) }
  if (claws isin %rareitem) { unset %rareprice | writeini -n equipment.ini dclaws $3 $calc($.readini(equipment.ini,dclaws,$3) +1) }
  if (mudkip isin %rareitem) { unset %rareprice | writeini -n equipment.ini Mudkip $3 $calc($.readini(equipment.ini,mudkip,$3) +1) }
  if (Clue isin %rareitem) { 
    if ($.readini(equipment.ini,clue,$3)) { unset %rareitem }
    else {
      set %clue $r(1,$lines(clue.txt))
      unset %rareprice
      writeini -n equipment.ini clue $3 %clue
    }
  }
  if (mage's isin %rareitem) { unset %rareprice | writeini -n equipment.ini mbook $3 $calc($.readini(equipment.ini,mbook,$3) +1) }
  if (accumulator isin %rareitem) { unset %rareprice | writeini -n equipment.ini accumulator $3 $calc($.readini(equipment.ini,accumulator,$3) +1) }
  set %combined $calc(%price1 + %price2 + %price3 + %rareprice)
  if ($gettok($.readini(personalclan.ini,person,$2),1,58) != $gettok($.readini(personalclan.ini,person,$3),1,58)) {
    if ($.readini(Clannames.ini,$gettok($.readini(Personalclan.ini,Person,$3),1,58),share) == on) && ($.ini(Clannames.ini,$gettok($.readini(Personalclan.ini,Person,$3),1,58),0) > 2) { var %a 1,%d 0 | while ($.ini(Clannames.ini,$gettok($.readini(Personalclan.ini,Person,$3),1,58),%a)) { inc %d | inc %a } | sharedrop $calc(%d -1) $gettok($.readini(Personalclan.ini,Person,$3),1,58) %combined $1 $3 $replace(%item1,$chr(32),$chr(95)) $replace(%item2,$chr(32),$chr(95)) $replace(%item3,$chr(32),$chr(95)) $replace(%rareitem,$chr(32),$chr(95)) | unset %item*
      unset %price*
      unset %rare*
      unset %drop*
      unset %combined 
      halt 
    }
  }
  if ($.readini(events.ini, event,double) != $null) { 
    set %combined2 $calc( %combined *2) | writeini -n Money.ini Money $3 $calc($.readini(Money.ini,Money,$3) + %combined2) | .timer 1 1 msg $1 $logo(KO) $s1($3) has received $s1($chr(91)) $+ $s2($price(%combined)) $+ $s1($chr(93))in loot. $s1($chr(91)) $+ %item1 $+ , $+ %item2 $+ , $+ %item3 $+ $iif(%rare == 1,$+ $chr(44) $+ %rareitem) $+ $s1($chr(93)) 7**2x Loot** Amount won: $s1($chr(91)) $+ $s2($price(%combined2)) $+ $s1($chr(93)) | unset %combined2
  } 
  elseif ($.readini(events.ini, event,triple) != $null) { 
    set %combined2 $calc( %combined *3) | writeini -n Money.ini Money $3 $calc($.readini(Money.ini,Money,$3) + %combined2) | .timer 1 1 msg $1 $logo(KO) $s1($3) has received $s1($chr(91)) $+ $s2($price(%combined)) $+ $s1($chr(93))in loot. $s1($chr(91)) $+ %item1 $+ , $+ %item2 $+ , $+ %item3 $+ $iif(%rare == 1,$+ $chr(44) $+ %rareitem) $+ $s1($chr(93)) 7**3x Loot** Amount won: $s1($chr(91)) $+ $s2($price(%combined2)) $+ $s1($chr(93)) | unset %combined2
  } 
  else {
    writeini -n Money.ini Money $3 $calc($.readini(Money.ini,Money,$3) + %combined) | .timer 1 1 msg $1 $logo(KO) $s1($3) has received $s1($chr(91)) $+ $s2($price(%combined)) $+ $s1($chr(93))in loot. $s1($chr(91)) $+ %item1 $+ , $+ %item2 $+ , $+ %item3 $+ $iif(%rare == 1,$+ $chr(44) $+ %rareitem) $+ $s1($chr(93)) 
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

alias sharedrop {
  set %sharedrop $floor($calc($3 / $1))
  var %a 1
  while ($.ini(clannames.ini,$2,%a)) {
    if ($.ini(clannames.ini,$2,%a) != share) {
      if ($.readini(events.ini,event,double)) { var %sharedrop $calc(%sharedrop *2) }
      if ($.readini(events.ini,event,triple)) { var %sharedrop $calc(%sharedrop *3) }
      writeini -n money.ini money $.ini(clannames.ini,$2,%a) $calc($.readini(money.ini,money,$.ini(clannames.ini,$2,%a)) + %sharedrop)
    }
    inc %a
  }
  trackclan WIN $gettok($.readini(Personalclan.ini,Person,$5),1,58) %sharedrop
  msg $4 $logo(KO) The team members of $qt($s1($gettok($.readini(Personalclan.ini,Person,$5),1,58))) each received $s2($price(%sharedrop)) in gp. [ $+ $replace($6,$chr(95),$chr(32)) $+ , $+ $replace($7,$chr(95),$chr(32)) $+ , $+ $replace($8,$chr(95),$chr(32)) $+ $iif($9,$chr(44) $+ $replace($9,$chr(95),$chr(32))) $+ ]
  unset %sharedrop
}


alias trackclan {
  if (!$2) { halt }
  if ($1 == win) {
    writeini -n Clantracker.ini Wins $2 $calc($.readini(clantracker.ini,wins,$2) +1)
    writeini -n Clantracker.ini Money $2 $calc($.readini(clantracker.ini,money,$2) + $3)
  }
  if ($1 == lose) {
    writeini -n Clantracker.ini Losses $2 $calc($.readini(clantracker.ini,losses,$2) + 1)
  }
}
