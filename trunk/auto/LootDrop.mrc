alias dead {
  if ($hget($1,stake)) {
    db.set user money $3 + $hget($1,stake)
    db.set user money $2 - $hget($1,stake)
    .timer 1 1 msgsafe $1 $logo(KO) $s1($3) has defeated $s1($2) and receives $s2($price($hget($1,stake))) $+ .
    cancel $1
    db.set user wins $3 + 1
    db.set user losses $2 + 1
    set -u10 %wait. [ $+ [ $1 ] ] on
    .timer 1 10 msgsafe $1 $logo(DM) Ready.
    halt
  }
  var %drops $rundrops($1, $3, $2)
  var %combined $gettok(%drops,1,32)
  var %items $gettok(%drops,2-,32)
  var %winnerclan = $hget($3,clan)
  var %looserclan = $hget($2,clan)

  cancel $1
  db.set user wins $3 + 1
  db.set user losses $2 + 1

  if ((%winnerclan != %looserclan) && (%looserclan)) { trackclan LOSE %looserclan }
  if ((%winnerclan != %looserclan) && (%winnerclan)) {
    var %nummember = $numtok($clanmembers(%winnerclan),32)
    var %sharedrop = $floor($calc(%combined / %nummember))
    trackclan WIN %winnerclan %combined
    if ($db.get(clantracker,share,%winnerclan)) {
      var %sql.winnerclan = $db.safe(%winnerclan)
      var %sql = UPDATE user SET money = money + %sharedrop WHERE clan = %sql.winnerclan
      db.exec %sql
      .timer 1 1 msgsafe $1 $logo(KO) $iif(%nummember == 1,The clan,The %nummember clan members in) $qt($s1(%winnerclan)) $iif(%nummember != 1,each) received $s2($price(%sharedrop)) in gp. $s1($chr(91)) $+ %items $+ $s1($chr(93))
      unset %sharedrop
    }
    else {
      db.set user money $3 + %combined
      .timer 1 1 msgsafe $1 $logo(KO) $s1($3) has received $s1($chr(91)) $+ $s2($price(%combined)) $+ $s1($chr(93))in loot. $s1($chr(91)) $+ %items $+ $s1($chr(93))
    }
  }
  else {
    db.set user money $3 + %combined
    .timer 1 1 msgsafe $1 $logo(KO) $s1($3) has received $s1($chr(91)) $+ $s2($price(%combined)) $+ $s1($chr(93))in loot. $s1($chr(91)) $+ %items $+ $s1($chr(93))
  }
  set -u10 %wait. [ $+ [ $1 ] ] on | .timer 1 10 msgsafe $1 $logo(DM) Ready.
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
  if ($db.get(equip_item,clue,$nick) == 0) { $iif($left($1,1) == @,msgsafe #,notice $nick) $logo(CLUE) You do not have a Clue Scroll. | halt }
  $iif($left($1,1) == @,msgsafe #,notice $nick) $logo(CLUE) $qt($gettok($read(clue.txt,$db.get(equip_item,clue,$nick)),1,58)) To solve the clue, simply type !solve answer. Check http://r.idm-bot.com/guide for help.
}
on $*:TEXT:/^[!@.]solve/Si:#: {
  if (# == #idm || # == #idm.Staff) && ($me != iDM) { halt }
  if ($db.get(equip_item,clue,$nick) == 0) { notice $nick $logo(CLUE) You do not have a Clue Scroll. | halt }
  if ($istok($gettok($read(clue.txt,$db.get(equip_item,clue,$nick)),2,58),$2,33) != $true) || (!$2) { notice $nick $logo(CLUE) Sorry, that answer is incorrect. Check http://r.idm-bot.com/guide for help | halt }
  var %a = $r(1,$lines(clueloot.txt)),%b = $r(1,$lines(clueloot.txt)),%c = $r(1,$lines(clueloot.txt))
  var %clue1 $gettok($read(clueloot.txt,%a),1,58)
  var %clue2 $gettok($read(clueloot.txt,%b),1,58)
  var %clue3 $gettok($read(clueloot.txt,%c),1,58)
  var %cprice1 $gettok($read(clueloot.txt,%a),2,58)
  var %cprice2 $gettok($read(clueloot.txt,%b),2,58)
  var %cprice3 $gettok($read(clueloot.txt,%c),2,58)
  var %combined $calc(%cprice1 + %cprice2 + %cprice3)
  notice $nick $logo(CLUE) Congratulations, that is correct! Reward: $s1($chr(91)) $+ $s2($price(%combined)) $+ $s1($chr(93)) in loot. $s1($chr(91)) $+ %clue1 $+ , $+ %clue2 $+ , $+ %clue3 $+ $s1($chr(93))
  db.set user money $nick + %combined
  db.set equip_item clue $nick 0
}

alias gendrops {
  ; $1 User
  ; $2 Otheruser

  var %start $ticks, %price 0, %drops :, %windiff 0, %chance $rand(10,950)
  if ($db.get(equip_item,wealth,$1) != 0) var %chance $calc(%chance * 1.1)
  var %oldchance %chance

  var %winner $db.get(user,wins,$1), %looser $db.get(user,wins,$2)
  if ($2) var %windiff $calc(1 + (%looser - %winner) / ((%looser + %winner + 100) * 5)))
  if (%windiff > 1) var %chance $calc(%chance * %windiff)
  var %sql SELECT * FROM drops WHERE chance <= ? AND disabled = '0' ORDER BY rand() LIMIT $iif($rand(1,10) == 1,4,3)
  var %res $mysql_query(%db, %sql, %chance)
  while ($mysql_fetch_row(%res, >row)) {
    var %drops %drops $+ $hget(>row, item) $+ . $+ $hget(>row, price) $+ :
  }
  mysql_free %res
  return %chance %drops
}

alias rundrops {
  ; $1 $chan
  ; $2 User
  ; $3 Otheruser
  var %drops $gendrops($2,$3), %disprice 0, %display, %wealth 0, %i 1
  var %chance $gettok(%drops,1,32)
  var %drops $gettok(%drops,2-,32)
  if ($db.get(equip_item,wealth,$2) != 0) var %wealth 1

  while (%i <= $numtok(%drops,58) ) {
    var %item $gettok($gettok(%drops,%i,58),1,46)
    var %price $gettok($gettok(%drops,%i,58),2,46)
    var %colour 0
    if (%price == 0) {
      var %colour 07
      if (%item == Vesta's longsword) { db.set equip_pvp vlong $2 + 5 | var %colour 03 }
      elseif (%item == Vesta's spear) { db.set equip_pvp vspear $2 + 5 | var %colour 03 }
      elseif (%item == Statius's Warhammer) { db.set equip_pvp statius $2 + 5 | var %colour 03 }
      elseif (%item == Morrigan's Javelin) { db.set equip_pvp mjavelin $2 + 5 | var %colour 03 }
      elseif (specpot isin %item) { db.set equip_item specpot $2 + 1 | var %colour 03 }
      elseif (godsword isin %item) { db.set equip_item $replace($gettok(%item,1,32),saradomin,sgs,zamorak,zgs,bandos,bgs,armadyl,ags) $2 + 1 }
      elseif (claws isin %item) { db.set equip_item dclaws $2 + 1 }
      elseif (mudkip isin %item) { db.set equip_item mudkip $2 + 1 }
      elseif (mage's isin %item) { db.set equip_armour mbook $2 + 1 }
      elseif (accumulator isin %item) { db.set equip_armour accumulator $2 + 1 }
      elseif (Clue isin %item) { db.set equip_item clue $2 $r(1,$lines(clue.txt)) }
      elseif (Elysian isin %item) { db.set equip_armour elshield $2 + 1 }
      elseif (Snow isin %item) { db.set equip_item snow $2 + 1 }
      else {
        putlog DROP ERROR: Drop not found matching: %item
      }
    }
    else { var %disprice $calc(%disprice + %price) }
    var %sql = INSERT INTO loot_item (`item`, `count`) VALUES ( $db.safe(%item) , '1' ) ON DUPLICATE KEY UPDATE count = count+1
    db.exec %sql
    var %display %display $iif(%colour, $+ %colour) $+ %item $+ $iif(%colour,) $+ $chr(44)
    inc %i
  }

  var %sql = INSERT INTO loot_player (`chan`, `cash`, `bot`, `date`, `count`) VALUES ( $db.safe($1) , ' $+ %disprice $+ ' , ' $+ $tag $+ ' , CURDATE(), '1' ) ON DUPLICATE KEY UPDATE cash = cash + %disprice , count = count+1
  db.exec %sql

  return %disprice $left(%display,-1)
}
