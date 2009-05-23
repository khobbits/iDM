on *:PART:#: {
  if ($nick == %p1 [ $+ [ $chan ] ]) && (%stake [ $+ [ $chan ] ]) && (%turn [ $+ [ $chan ] ]) {
    writeini -n money.ini money %p1 [ $+ [ $chan  ] ] $calc($readini(money.ini,money,%p1 [ $+ [ $chan ] ]) - $ceil($calc($+(%,stake,#) / 2) ))
    msg # $logo(DM) The stake has been canceled, because one of the players parted. $s1($nick) has lost $s2($price($ceil($calc($+(%,stake,#) / 2) ))) $+ .
    cancel #
    .timer $+ # off
  }
  if ($nick == %p2 [ $+ [ $chan ] ]) && (%stake [ $+ [ $chan ] ]) && (%turn [ $+ [ $chan ] ]) {
    writeini -n money.ini money %p2 [ $+ [ $chan  ] ] $calc($readini(money.ini,money,%p2 [ $+ [ $chan ] ]) - $ceil($calc($+(%,stake,#) / 2) ))
    msg # $logo(DM) The stake has been canceled, because one of the players parted. $s1($nick) has lost $s2($price($ceil($calc($+(%,stake,#) / 2) ))) $+ .
    cancel #
    .timer $+ # off
  }
  if ($nick == %p1 [ $+ [ $chan ] ]) || ($nick == %p2 [ $+ [ $chan ] ]) {
    msg # $logo(DM) The DM has been canceled, because one of the players parted.
    enddmcatch part $nick $chan $1-

    if ($enddmcatch(part,$nick,$chan,$1-) == 1) {
      var %oldmoney = $readini(money.ini,money,$nick)
      if (%oldmoney > 100) {
        var %newmoney = $ceil($calc(%oldmoney - (%oldmoney * 0.02)))
        notice $nick You left the channel during a dm, you loose $s2($price($calc(%oldmoney - %newmoney))) cash
        write penalty.txt $nick parted channel $chan during a dm oldcash %oldmoney newcash %newmoney
        writeini -n money.ini money $nick %newmoney
      }
    }

    cancel #
    .timer $+ # off
  }
}
on *:QUIT: {
  if ($readini(login.ini,login,$nick)) { remini login.ini login $nick }
  var %a 1
  while (%a <= $chan(0)) {
    if ($nick == %p1 [ $+ [ $chan(%a) ] ]) || ($nick == %p2 [ $+ [ $chan(%a) ] ]) {
      msg $chan(%a) $logo(DM) The DM has been canceled, because one of the players quit.
      if ($enddmcatch(quit,$nick,$chan(%a),$1-) == 1) {
        var %oldmoney = $readini(money.ini,money,$nick)
        if (%oldmoney > 100) {

          var %newmoney = $ceil($calc(%oldmoney - (%oldmoney * 0.02)))
          write penalty.txt $nick quit during a dm oldcash %oldmoney newcash %newmoney
          writeini -n money.ini money $nick %newmoney
        }
      }
      cancel $chan(%a)
      .timer $+ $chan(%a) off
    }
    inc %a
  }
}
on *:NICK: {
  if (!%dming [ $+ [ $nick ] ]) { halt }
  var %a = 1
  while (%a <= $chan(0)) {
    if (%stake [ $+ [ $chan(%a) ] ]) && (($nick == %p1 [ $+ [ $chan(%a) ] ]) || ($nick == %p2 [ $+ [ $chan(%a) ] ])) { msg $chan(%a) $logo(STAKE) The stake has been canceled because a player changed their nick. | cancel $chan(%a) | .timer $+ $chan(%a) off | halt }
    if ($nick == %p1 [ $+ [ $chan(%a) ] ]) {
      remini status.ini currentdm $nick
      writeini -n status.ini currentdm $newnick true
      unset %dming [ $+ [ $nick ] ]
      remini login.ini login $nick
      set %p1 [ $+ [ $chan(%a) ] ] $newnick | set %dming [ $+ [ $newnick ] ] on
    }
    if ($nick == %p2 [ $+ [ $chan(%a) ] ]) {
      remini status.ini currentdm $nick
      writeini -n status.ini currentdm $newnick true
      unset %dming [ $+ [ $nick ] ]
      remini login.ini login $nick
      set %p2 [ $+ [ $chan(%a) ] ] $newnick | set %dming [ $+ [ $newnick ] ] on
    }
    inc %a
  }
}
on *:KICK:#: {
  if ($nick(#,0) < 6) && ($knick != $me) { part # Parting channel. Need 5 or more people to have iDM. }
  if ($knick == %p1 [ $+ [ $chan ] ]) || ($knick == %p2 [ $+ [ $chan ] ]) {
    msg # $logo(DM) The DM has been ended because one of the players was kicked!
    if ($enddmcatch(kick,$knick,$nick,$chan,$1-) == 1) {
      var %oldmoney = $readini(money.ini,money,$knick)
      if (%oldmoney > 100) {
        var %newmoney = $ceil($calc(%oldmoney - (%oldmoney * 0.02)))
        notice $nick You left the channel during a dm, you loose $s2($price($calc(%oldmoney - %newmoney))) cash
        write penalty.txt $knick got kicked during a dm by $nick oldcash %oldmoney newcash %newmoney
        writeini -n money.ini money $knick %newmoney
      }
    }
    cancel # 
    .timer $+ # off 
    halt 
  }
  if ($knick == $me) && (. !isin $nick) { cancel # | .timer $+ # off | msg #idm.staff $logo(KICK) I have been kicked from: $chan by $nick $+ . Reason: $1- }
}

alias enddmcatch {
  goto $1

  :part
  var %action = parted $3 for $4-
  goto pass

  :quit
  var %action = quit $network & $3 ( $+ $4- $+ )
  if ($3 == Quit:) {
    goto pass
  } 
  else {
    goto fail
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
  return 1

  :fail
  msg #idm.staff $logo(ENDDM) $2 %action
  return 0
}
