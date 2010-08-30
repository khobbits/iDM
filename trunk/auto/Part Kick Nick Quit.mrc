on $*:TEXT:/^[!@.]part/Si:#: {
  if (# == #idm) || (# == #idm.Staff) { return }
  if ($2 != $me) { return }
  if ($db.get(admins,rank,$address($nick,3)) >= 2) {
    if (%part.spam [ $+ [ # ] ]) { return }
    part # Part requested by $nick $+ .
    set -u60 %part.spam [ $+ [ # ] ] on
    msgsafe #idm.staff $logo(PART) I have parted: $chan $+ . Requested by $iif($nick,$v1,N/A) $+ .
    cancel #
  }
  else {
    notice $nick $logo(PART) If you don't want me, just kick me!
  }
}

on *:PART:#: {
  if ($nick(#,0) < 5) && (!$no-part(#)) {
    cancel #
    part # Parting channel. Need 5 or more people to have iDM.
  }
  if ($nick == $me) && (!%rjoinch. [ $+ [ $me ] ]) { cancel # }
  if ($istok($hget($chan,players),$nick,44))  {
    if ($enddmcheck($chan,$nick,part,$1,$2-)) { return }
  }
}

on *:QUIT: {
  if ($nick(#,0) < 5) && (!$no-part(#)) {
    cancel #
    part # Parting channel. Need 5 or more people to have iDM.
  }
  var %a 1
  while (%a <= $chan(0)) {
    if ($istok($hget($chan(%a),players),$nick,44))  {
      if ($enddmcheck($chan(%a),$nick,quit,$1,$2-)) { return }
    }
    inc %a
  }
}

on *:KICK:#: {
  if ($nick(#,0) < 5) && (!$no-part(#) && ($knick != $me)) {
    cancel #
    part # Parting channel. Need 5 or more people to have iDM.
  }
  if ($istok($hget($chan,players),$knick,44)) {
    if ($enddmcheck($chan,$knick,kick,$nick,$1-)) { return }
  }
  if ($knick == $me) {
    if (. !isin $nick) {
      cancel #
      msgsafe #idm.staff $logo(KICK) I have been kicked from: $chan by $nick $+ . Reason: $1- 
    }
    elseif (shroudbnc !isin $nick) { 
      .timer 1 10 waskicked #
      join # 
      msgsafe #idm.staff $logo(REJOINING) I was kicked from $chan by $nick - $1-
    }
  }
}

on *:NICK: {
  var %a 1
  while (%a <= $chan(0)) {
    if ($istok($hget($chan(%a),players),$nick,44))  {
      hadd $chan(%a) players $reptok($hget($chan(%a),players),$nick,$newnick,0,44)
      if ($hget($nick)) {
        hsave $nick renamenick.hash
        hmake $newnick $hget($nick).size
        hfree $nick
        db.set user indm $nick 0
        hload $newnick renamenick.hash
        db.set user indm $newnick 1
      }
      if ($enddmcheck($chan(%a),$newnick,nick,$nick,$1-)) { return }
    }
    inc %a
  }
}

alias waskicked {
  if ($me !ison $1) {
    $iif($hget($chan,gwd.npc),gwdcancel #,cancel #) 
    .timer $+ $1 off
  }
}

alias enddmcatch {
  ; $1 = event
  ; $2 = nick
  ; $3 = chan
  ; $4 = string/offender
  ; $5- = string
  if ($numtok($hget($3,players),44) > 1) {
    goto $1
    :part
    var %action = parted $3 with reason " $+ $iif($4-,$4-,N/A) $+ "
    goto pass
    :quit
    var %action = quit $network & $3 ( $+ $4- $+ )
    if ($4 == Quit:) { goto pass }
    else { goto qfail  }
    :kick
    var %action = was kicked from $3 by $4 for " $+ $5- $+ "
    if ($2 == $4) { goto pass }
    else { goto fail }
    :nick
    var %action = changed nickname in $3 from $4
    goto pass
    :error
    reseterror
    goto fail
    :pass
    msgsafe #idm.staff $logo(ENDDM) $2 %action *
    return 1
    :fail
    msgsafe #idm.staff $logo(ENDDM) $2 %action
    return 0
    :qfail
    return 0
  }
}

alias enddmcheck {
  ; $1 = chan
  ; $2 = nick
  ; $3 = event
  ; $4- = string
  if ($istok($hget($1,players),$2,44)) {
    ; Is it a GWD?
    if ($hget($1,gwd.npc)) {
      var %user $autoidm.acc(<gwd> $+ $1)
      hadd $1 gwd.alive $remtok($hget($1,gwd.alive),$2,44)
      ; Is there other players alive?
      if ($numtok($hget($1,players),44) > 1) {
        msgsafe $1 $logo(GWD) $s1($2) their GWD raid has come to an end because they left.
        userlog loss $hget($2,account) %user
        db.set user losses $hget($2,account) + 1
        pcancel $1 $2
        ; Match continues without the player
        return 1
      }
      msgsafe $1 $logo(GWD) The GWD has been canceled, because the last players left.
      enddmcatch $3 $2 $1 $4 $5-
    }
    else {
      if ($hget($1,p2)) var %user $hget($iif($nick == $hget($1,p1),$hget($1,p2),$hget($1,p1)),account)
      ; Is it a stake?
      if ($hget($1,stake)) {
        db.set user money $hget($2,account) - $ceil($calc($hget($1,stake) / 2) )
        msgsafe $1 $logo(DM) The stake has been canceled, because one of the players parted. $s1($hget($2,account)) has lost $s2($price($ceil($calc($hget($1,stake) / 2) ))) $+ .
        notice $2 You left the channel during a stake, you loose $s2($price($ceil($calc($hget($1,stake) / 2) ))) $+ .
      }
      else {
        msgsafe $1 $logo(DM) The DM has been canceled, because one of the players left.
        var %oldmoney = $hget($2,money)
        if ($enddmcatch($3,$2,$1,$4,$5-) == 1) && (%user) && (%oldmoney > 100) {
          var %newmoney = $ceil($calc(%oldmoney * 0.02))
          notice $2 You left the channel during a dm, you lose $s2($price(%newmoney)) cash
          userlog penalty $hget($2,account) %newmoney
          db.set user money $hget($2,account) - %newmoney
        }
      }
      ; Actions for all 1v1 dm.
    }
    ; Actions for all matches.
    if (%user) {
      userlog loss $hget($2,account) %user
      userlog win %user $hget($2,account)
      db.set user wins %user + 1
      db.set user losses $hget($2,account) + 1
    }
    cancel $1
    .timer $+ $1 off
    return 1
  }
  return 0
}
