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
      enddmcatch quit $nick $1-
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
    enddmcatch kick $knick $nick $chan $1-
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
  var %action = quit $network ( $+ $3- $+ )
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
  msg @#idm.staff $logo(ENDDM) Penalty - $2 %action
  return 1

  :fail
  msg @#idm.support $logo(ENDDM) Nopenalty - $2 %action
  return 0
}
