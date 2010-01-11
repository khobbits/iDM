on $*:TEXT:/^[!@.]part/Si:#: {
  if (# == #idm) || (# == #idm.Staff) { halt }
  if ($2 == $me) {
    if ($nick isop # || $nick ishop #) || ($db.get(admins,position,$address($nick,3))) {
      if (%part.spam [ $+ [ # ] ]) { halt }
      part # Part requested by $nick $+ .
      set -u10 %part.spam [ $+ [ # ] ] on
      msgsafe #idm.staff $logo(PART) I have parted: $chan $+ . Requested by $iif($nick,$v1,N/A) $+ .
      cancel #
    }
  }
}

on *:PART:#: {
  if ($nick(#,0) < 5) && (!$istok(#idm #idm.staff #idm.help #idm.support #tank #istake,#,32)) {
    part # Parting channel. Need 5 or more people to have iDM.
  }
  if ($nick == $me) && (!%rjoinch. [ $+ [ $me ] ]) {
    cancel #
  }
  if ($hget($nick)) && ($hget($chan)) {
    if $hget($chan,p2)) && ($hget($chan,p1) == $nick) && ($hget($chan,stake)) {
      db.set user money $nick - $ceil($calc($+(%,stake,#) / 2) )
      msgsafe # $logo(DM) The stake has been canceled, because one of the players parted. $s1($nick) has lost $s2($price($ceil($calc($+(%,stake,#) / 2) ))) $+ .
      cancel #
      .timer $+ # off
    }
    if ($hget($chan,p2) == $nick) && ($hget($chan,stake)) {
      db.set user money %p2 [ $+ [ $chan  ] ] - $ceil($calc($+(%,stake,#) / 2))
      msgsafe # $logo(DM) The stake has been canceled, because one of the players parted. $s1($nick) has lost $s2($price($ceil($calc($+(%,stake,#) / 2) ))) $+ .
      cancel #
      .timer $+ # off
    }
    if ($nick == $hget($chan,p1)) || ($nick == $hget($chan,p2)) {
      msgsafe # $logo(DM) The DM has been canceled, because one of the players parted.
      if ($enddmcatch(part,$nick,$chan,$1-) == 1) {
        var %oldmoney = $hget($nick,money)
        if (%oldmoney > 100) {
          var %newmoney = $ceil($calc(%oldmoney * 0.02))
          notice $nick You left the channel during a dm, you lose $s2($price(%newmoney)) cash
          write penalty.txt $timestamp $nick parted channel $chan during a dm oldcash %oldmoney penalty %newmoney
          db.set user money $nick - %newmoney
        }
        db.set user losses $nick + 1
      }
      cancel #
      .timer $+ # off
    }
  }
}

on *:QUIT: {
  var %a 1
  if ($hget($nick)) {
    while (%a <= $chan(0)) {
      if ($nick == $hget($chan(%a),p1)) || ($nick == $hget($chan(%a),p2)) {
        msgsafe $chan(%a) $logo(DM) The DM has been canceled, because one of the players quit.
        if (%turn [ $+ [ $chan(%a) ] ]) {
          if ($enddmcatch(quit,$nick,$chan(%a),$1-) == 1) {
            var %oldmoney = $db.get($nick,money)
            if (%oldmoney > 100) {
              var %newmoney = $ceil($calc(%oldmoney * 0.01))
              write penalty.txt $timestamp $nick quit during a dm oldcash %oldmoney penalty %newmoney
              db.set user money $nick - %newmoney
            }
            db.set user losses $nick + 1
          }
        }
        cancel $chan(%a)
        .timer $+ $chan(%a) off
      }
      inc %a
    }
  }
}
on *:NICK: {
  var %a = 1
  if ($hget($nick)) {
    while (%a <= $chan(0)) {
      if ($hget($chan(%a),stake) && (($nick == $hget($chan(%a),p1)) || ($nick == $hget($chan(%a),p2))) {
        db.set user money $nick - $ceil($calc($hget($chan(%a),stake)) / 2))
        msgsafe $chan(%a) $logo(DM) The stake has been canceled, because one of the players changed their nick. $s1($nick) has lost $s2($price($ceil($calc($hget($chan(%a),stake)) / 2))) $+ .
        cancel $chan(%a)
        .timer $+ $chan(%a) off
        halt
      }
      if ($nick == $hget($chan(%a),p1)) {
        db.set user indm $nick 0
        db.set user indm $newnick 1
        hadd $chan(%a) p1 $newnick
      }
      if ($nick == $hget($chan(%a),p2)) {
        db.set user indm $nick 0
        db.set user indm $newnick 1
        hadd $chan(%a) p2 $newnick    
      }
      inc %a
    }
  }
}
on *:KICK:#: {
  if ($nick(#,0) < 6) && ($knick != $me) { part # Parting channel. Need 5 or more people to have iDM. }
  if ($hget($knick)) && ($hget($chan)) {
    if ($knick == $hget($chan,p1)) || ($knick == $hget($chan,p2)) {
      msgsafe # $logo(DM) The DM has been ended because one of the players was kicked!
      if ($enddmcatch(kick,$knick,$nick,$chan,$1-) == 1) {
        var %oldmoney = $db.get($knick,money)
        if (%oldmoney > 100) {
          var %newmoney = $ceil($calc(%oldmoney * 0.01))
          notice $nick You left the channel during a dm, you lose $s2($price(%newmoney)) cash
          write penalty.txt $timestamp $knick got kicked during a dm by $nick oldcash %oldmoney penalty %newmoney
          db.set user money $knick - %newmoney
        }
        db.set user losses $nick + 1
      }
      cancel #
      .timer $+ # off
      halt
    }
  }
  if ($knick == $me) {
    .timer 1 15 waskicked #
    if (. !isin $nick) { msgsafe #idm.staff $logo(KICK) I have been kicked from: $chan by $nick $+ . Reason: $1- }
    elseif (shroudbnc !isin $nick) { join # | msgsafe #idm.staff $logo(REJOINING) I was kicked from $chan by $nick - $1- }
  }
}

alias waskicked {
  if ($me !ison $1) {
    cancel $1
    .timer $+ $1 off
  }
}

alias enddmcatch {
  goto $1

  :part
  var %action = parted $3 with reason " $+ $iif($4-,$4-,N/A) $+ "
  goto pass

  :quit
  var %action = quit $network & $3 ( $+ $4- $+ )
  if ($4 == Quit:) {
    goto pass
  }
  else {
    goto qfail
  }
  :kick
  var %action = was kicked from $4 by $3 for " $+ $5- $+ "
  if ($3 == $2) {
    goto pass
  }
  else {
    goto fail
  }

  :error
  reseterror
  goto fail

  #####

  :pass
  msgsafe #idm.staff $logo(ENDDM) $2 %action *
  return 1

  :fail
  msgsafe #idm.staff $logo(ENDDM) $2 %action
  return 0

  :qfail
  return 0
}
