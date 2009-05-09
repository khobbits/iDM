on *:INVITE:#: {
  if ($me != iDM) { halt }
  if (%invig. [ $+ [ # ] ]) { halt }
  if (%loottimer) { msg $nick Invite is disabled because GE database is updating. Please wait several minutes. | halt }
  if (%inv.spam [ $+ [ $nick ] ]) { halt }
  if ($readini(Blacklist.ini,Chans,#)) && (!%inv.spam [ $+ [ $nick ] ]) {
    notice $nick Channel has been blacklisted. (Reason: $readini(Blacklist.ini,Chans,#) $iif($readini(blacklist.ini,Who,#),By: $v1) $+ )
    inc -u10 %inv.spam [ $+ [ $nick ] ]
    halt
  }
  notice $nick $logo(BOT) Searching for an open bot...(If a bot doesn't join in the next minute, join #iDM.Support)
  ;notice $nick $logo(Disabled) We have found a bug in our invite system so we had to disable it. Please wait till we bring it back online.

  if ($port == 12000) {
    var %a 0
    sbnc joinbot $chan $nick
  }
  else { 
    var %a $r(2,$botsonline)
  }
  if (%a == 1) {
    if ($me ison #) { halt }
    set %raw322 [ $+ [ # ] ] $nick | $+(.timerlist,#) 1 0.5 .list # | $+(.timerinvalidnick,#) 1 1 modesp # | set -u5 %raw47345 [ $+ [ # ] ] $nick
    halt
  }
  if (%a == 2) {
    ctcp iDM[US] join # $nick
  }
  if (%a == 3) {
    ctcp iDM[LL] join # $nick
  }
  if (%a == 4) {
    ctcp iDM[BA] join # $nick
  }
  if (%a == 5) {
    ctcp iDM[PK] join # $nick
  }
  if (%a == 6) {
    ctcp iDM[AL] join # $nick
  }
  if (%a == 7) {
    ctcp iDM[SN] join # $nick
  }
  if (%a == 8) {
    ctcp iDM[FU] join # $nick
  }
  if (%a == 9) {
    ctcp iDM[BU] join # $nick
  }
  if (%a == 10) {
    ctcp iDM[BE] join # $nick
  }
  if (%a == 11) {
    ctcp iDM[LA] join # $nick
  }
  if (%a == 12) {
    ctcp iDM[EU] join # $nick
  }
}

alias botsonline {
  if ($me !ison #idm.staff) { return 1 }
  var %a 1,%b 0
  while ($nick(#idm.staff,%a)) {
    if ($istok($botnames,$nick(#idm.staff,%a),46)) {
      inc %b
    }
    inc %a
  }
  return %b
}
CTCP *:*join*:?: {
  if ($nick == iDM) {
    if ($me ison $2) { halt }
    set %raw322 [ $+ [ $2 ] ] $3 | $+(.timerlist,$2) 1 0.5 .list $2 | $+(.timerinvalidnick,$2) 1 4 modesp $2 | set -u5 %raw47345 [ $+ [ $2 ] ] $3
  }
}
alias modesp {
  if (!%raw322 [ $+ [ $1 ] ]) || ($numtok(%raw322 [ $+ [ $1 ] ],32) == 2) { Halt }
join $1 | set %raw322 [ $+ [ $1 ] ] %raw322 [ $+ [ $1 ] ] on on }
on *:JOIN:#:{
  if (%blockinvspam) { halt }
  if (%raw322 [ $+ [ # ] ]) && ($numtok(%raw322 [ $+ [ # ] ],32) == 2) { unset %raw322 [ $+ [ # ] ] | halt }
  if (%forcedj. [ $+ [ # ] ]) { unset %forcedj. [ $+ [ # ] ] | halt }
  if ($nick == $me) { 
    $+(.timerlimit5,#) 1 1 limit5 # $deltok(%raw322 [ $+ [ # ] ],2-3,32)
    halt
  } 
  if ($nick(#,0) < 5) { msg # Parting channel. Need 5 or more people to have iDM.
    part #
  }
}
alias limit5 {
  if ($nick($1,0) < 5) { msg $1 $logo(ERROR) $1 only has $nick($1,0) $iif($nick($1,0) == 1,person.,people.) 5 or more is needed to have iDM join. | part $1 | unset %raw322 [ $+ [ $1 ] ] | Halt }
  if (!$1) || (!$2) { halt }
  msg $1 $entrymsg($1,$2) | idmstaff invite $1 $2 | unset %raw322 [ $+ [ $1 ] ]
}

raw 322:*:{
  if ($numtok(%raw322 [ $+ [ $2 ] ],32) == 1) {
    if ($3 < 5) { msg %raw322 [ $+ [ $2 ] ] $logo(ERROR) $2 only has $3 people. 5 or more is needed to have iDM join. | unset %raw322 [ $+ [ $2 ] ] | Halt }
    $+(.timerinvalidnick,$2) off
    set %raw322 [ $+ [ $2 ] ] %raw322 [ $+ [ $2 ] ] on
    join $2 
  idmstaff invite $2 $gettok(%raw322 [ $+ [ $2 ] ],1,32) | $+(.timer,$2) 1 1 msg $2 $entrymsg($2,$gettok(%raw322 [ $+ [ $2 ] ],1,32)) }
}
raw 323:*:{ /window -h "Channels list" }
raw 474:*: { if (%raw47345 [ $+ [ $2 ] ]) {
    msg %raw47345 [ $+ [ $2 ] ] $logo(ERROR) I'm currently banned from $2 so im unable to join. | unset %raw47345 [ $+ [ $2 ] ]
  }
}
raw 475:*: { if (%raw47345 [ $+ [ $2 ] ]) {
    msg %raw47345 [ $+ [ $2 ] ] $logo(ERROR) $2 has mode +k enabled so im unable to join. Please type: /mode $2 -k and re-invite me | unset %raw47345 [ $+ [ $2 ] ]
  }
}
alias idmstaff {
  if ($1 == invite) { msg $secondchan $logo(INVITE) $s1($3) invited me into $s2($2) }
}
alias entrymsg {
  return $logo(INVITE) Thanks for inviting iDM $chr(91) $+ Bot tag - $s1($bottag) $+ $chr(93) into $s2($1) $+ $iif($2,$chr(44) $s1($2) $+ .,.) An op must type !part $me to make me leave. Forums 12http://forum.idm-bot.com/ Rules 12http://r.idm-bot.com/rules $botnews
}
alias botnews {
  return News: Admin special items released. Dds has 1/3 chance of poisoning (lasts whole DM.) Ssword, d2h, anchor, and dspear removed.
}
alias bottag {
  if (!$1) {
    if ($me == iDM) { return iDM | halt }
    else { return $remove($me,idm[,$chr(93)) | halt }
  }
  if ($1) {
    if ($1 == iDM) { return iDM | halt }
    else { return $remove($1,idm[,$chr(93)) | halt }
  }
}
