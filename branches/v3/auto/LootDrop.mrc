alias dead {
  ; $1 = chan
  ; $2 = looser
  ; $3 = winner
  if ($3 == $null) { putlog Syntax Error: dead (3) - $db.safe($1-) | halt }
  if ($hget($1,stake)) {
    db.set user money $3 + $hget($1,stake)
    db.set user money $2 - $hget($1,stake)
    .timer 1 1 msgsafe $1 $logo(KO) $s1($3) has defeated $s1($2) and receives $s2($price($hget($1,stake))) $+ .
    db.set user wins $3 + 1

    var %stake $hget($1,stake)
    userlog winstake $3 %stake
    userlog losestake $2 %stake
    userlog win $3 $2
    userlog loss $2 $3

    db.set user losses $2 + 1
    set -u10 %wait. [ $+ [ $1 ] ] on
    .timer 1 10 msgsafe $1 $logo(DM) Ready.
    cancel $1
    halt
  }
  if ($hget($1,g0)) {
    userlog win $3 $2
    userlog loss $2 $3

    var %drops $rundrops($1, $3, $2)
    var %combined $gettok(%drops,1,32)
    var %items $gettok(%drops,2-,32)
    var %g $numtok($hget($1,gwd.alive),44)
    var %sharedrop $floor($calc(%combined / %g))

    db.set user losses $2 + 1
    userlog drop $3 %sharedrop gp

    var %a = $hget($1,gwd.alive), %b = 1 
    while (%b <= $gettok(%a,0,44)) { 
      db.set user money $gettok(%a,%b,44) + %sharedrop
      db.set user wins $gettok(%a,%b,44) + 1
      inc %b 
    }

    msgsafe $1 $logo(KO) $iif(%g == 1,The Solo Team of $s1($gettok($hget($1,gwd.alive),1,44)),The %g surviving team members) $iif(%g != 1,each) received $s2($price(%sharedrop)) in gp. $+($s1([),%items,$s1(])) $+($s1([),Time: $s2($duration($calc($ctime - $hget($1,gwdtime)))),$s1(]))
    gwdcancel $1
    set -u10 %wait. [ $+ [ $1 ] ] on 
    .timer 1 10 msgsafe $1 $logo(GWD) Ready.
    halt
  }
  userlog win $3 $2
  userlog loss $2 $3
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
    var %nummember = $clannumbers(%winnerclan)
    var %sharedrop = $floor($calc(%combined / %nummember))
    userlog drop $3 %sharedrop gp
    trackclan WIN %winnerclan %combined
    if ($db.get(clantracker,share,%winnerclan)) {
      var %sql.winnerclan = $db.safe(%winnerclan)
      var %sql = UPDATE user SET money = money + %sharedrop WHERE clan = %sql.winnerclan
      db.exec %sql
      msgsafe $1 $logo(KO) $iif(%nummember == 1,The clan,The %nummember clan members in) $qt($s1(%winnerclan)) $iif(%nummember != 1,each) received $s2($price(%sharedrop)) in gp. $s1($chr(91)) $+ %items $+ $s1($chr(93))
      unset %sharedrop
    }
    else {
      userlog drop $3 %combined gp
      db.set user money $3 + %combined
      msgsafe $1 $logo(KO) $s1($3) has received $s1($chr(91)) $+ $s2($price(%combined)) $+ $s1($chr(93))in loot. $s1($chr(91)) $+ %items $+ $s1($chr(93))
    }
  }
  else {
    userlog drop $3 %combined gp
    db.set user money $3 + %combined
    msgsafe $1 $logo(KO) $s1($3) has received $s1($chr(91)) $+ $s2($price(%combined)) $+ $s1($chr(93))in loot. $s1($chr(91)) $+ %items $+ $s1($chr(93))
  }
  set -u10 %wait. [ $+ [ $1 ] ] on 
  .timer 1 10 msgsafe $1 $logo(DM) Ready.
}
alias price {
  tokenize 32 $remove($1-,$chr(44))
  if ($1 isnum) {
    return $iif($1 > 999,$+($regsubex($1,/(?<=.)((...)*)$/,$+(.,$left(\1,1),$mid(KMBT,$calc($len(\1) /3),1)))),$1 GP)
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
  if ($isbanned($nick)) { halt }
  var %clueid $db.get(equip_item,clue,$nick)
  if (%clueid == 0) { $iif($left($1,1) == @,msgsafe #,notice $nick) $logo(CLUE) You do not have a Clue Scroll. | halt }
  $iif($left($1,1) == @,msgsafe #,notice $nick) $logo(CLUE) $qt($db.get(clues,question,%clueid)) To solve the clue, simply type !solve answer. Check http://r.idm-bot.com/guide for help.
}

ON $*:TEXT:/^[!@.]solve/Si:#: {
  if (# == #idm || # == #idm.Staff) && ($me != iDM) { halt }
  if ($isbanned($nick)) { halt }
  var %clueno $db.get(equip_item,clue,$nick)
  if (%clueno == 0) { notice $nick $logo(CLUE) You do not have a Clue Scroll. | halt }
  if ($hget($nick)) { notice $nick $logo(ERROR) Please wait till you are out of the DM before you solve your clue. | halt }
  if ((!$2) || ($istok($db.get(clues,answers,%clueno),$2,33) != $true)) { notice $nick $logo(CLUE) Sorry, that answer is incorrect. Check http://r.idm-bot.com/guide for help | halt }
  var %combined 0, %chance $r(100,1000)
  var %sql SELECT * FROM drops WHERE chance <= $db.safe(%chance) AND type != 'd' AND disabled = '0' ORDER BY rand() LIMIT 3
  var %res $db.query(%sql)
  while ($db.query_row(%res, >clue)) {
    var %items $hget(>clue, item) $+ $chr(44) $+ %items
    inc %combined $hget(>clue, price)
  }

  if (%item == Cutlass of Corruption) { db.set equip_item corr $nick + 1 }

  db.query_end %res
  notice $nick $logo(CLUE) Congratulations, that is correct! Reward: $s1($chr(91)) $+ $s2($price(%combined)) $+ $s1($chr(93)) in loot. $s1($chr(91)) $+ $left(%items,-1) $+ $s1($chr(93))
  db.set user money $nick + %combined
  db.set equip_item clue $nick 0
  userlog clue $nick %combined
}

alias gendrops {
  ; $1 User
  ; $2 Otheruser
  if ($2 == $null) { putlog Syntax Error: gendrops (2) - $db.safe($1-) | halt }
  var %start $ticks, %price 0, %drops :, %windiff 0, %chance $rand(10,910)
  if ($db.get(equip_item,wealth,$1) != 0) var %chance $calc(%chance * 1.1)
  var %oldchance %chance

  var %winner $db.get(user,wins,$1), %looser $db.get(user,wins,$2)
  if ($2) var %windiff $calc(1 + (%looser - %winner) / ((%looser + %winner + 100) * 6)))
  if (%windiff > 1) var %chance $calc(%chance * %windiff)
  var %sql SELECT * FROM drops WHERE chance <= $db.safe(%chance) AND disabled = '0' AND type != 'c' ORDER BY rand() LIMIT $iif($rand(1,10) == 1,4,3)
  var %res $db.query(%sql)
  while ($db.query_row(%res, >row)) {
    var %drops %drops $+ $hget(>row, item) $+ . $+ $hget(>row, price) $+ :
  }
  db.query_end %res
  return %chance %drops
}

alias rundrops {
  ; $1 $chan
  ; $2 User
  ; $3 Otheruser
  if ($3 == $null) { putlog Syntax Error: rundrops (3) - $db.safe($1-) | halt }
  var %drops $gendrops($2,$3), %disprice 0, %display, %wealth 0, %i 1
  var %chance $gettok(%drops,1,32)
  var %drops $gettok(%drops,2-,32)
  if ($db.get(equip_item,wealth,$2) != 0) var %wealth 1

  while (%i <= $numtok(%drops,58) ) {
    var %item $gettok($gettok(%drops,%i,58),1,46)
    var %price $gettok($gettok(%drops,%i,58),2,46)
    var %colour 0

    if ((%price == 0 || %price > 5000000) && %item != Nothing) {
      userlog drop $2 %item
    }

    if ((%price == 0 || %price == 1) && %item != Nothing) {
      var %colour 07
      if (%item == Vesta's longsword) { db.set equip_pvp vlong $2 + 5 | var %colour 03 }
      elseif (%item == Vesta's spear) { db.set equip_pvp vspear $2 + 5 | var %colour 03 }
      elseif (%item == Statius's Warhammer) { db.set equip_pvp statius $2 + 5 | var %colour 03 }
      elseif (%item == Morrigan's Javelin) { db.set equip_pvp mjavelin $2 + 5 | var %colour 03 }
      elseif (specpot isin %item) { db.set equip_item specpot $2 + 1 | var %colour 03 }
      elseif (godsword isin %item) { db.set equip_item $replace($gettok(%item,1,32),saradomin,sgs,zamorak,zgs,bandos,bgs,armadyl,ags) $2 + 1 | db.set achievements $replace($gettok(%item,1,32),saradomin,sgs,zamorak,zgs,bandos,bgs,armadyl,ags) $2 1 }
      elseif (claws isin %item) { db.set equip_item dclaws $2 + 1 | db.set achievements dclaws $2 1 }
      elseif (mudkip isin %item) { db.set equip_item mudkip $2 + 1 | db.set achievements mudkip $2 1 }
      elseif (idmnewbie == $2) { noop }
      elseif (mage's isin %item) { db.set equip_armour mbook $2 + 1 | db.set achievements mbook $2 1  }
      elseif (accumulator isin %item) { db.set equip_armour accumulator $2 + 1 | db.set achievements accumulator $2 1 }
      elseif (Clue isin %item) { db.set equip_item clue $2 $r(2,$db.get(clues,answers,1)) }
      elseif (Elysian isin %item) { db.set equip_armour elshield $2 + 1 | db.set achievements elshield $2 1 }
      elseif (Snow isin %item) { db.set equip_item snow $2 + 1 | db.set achievements sdrop $2 1 }
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
