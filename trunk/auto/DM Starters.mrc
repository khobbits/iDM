on $*:TEXT:/^[!@.]dm\b/Si:#: {
  if (# == #idm.Support) && ($nick !isop $chan) { halt }
  if (# == #idm.help) && ($nick !isop $chan) { halt }
  if (# == #idm || # == #idm.Staff) && ($me != iDM) { halt }
  if (%dm.spam [ $+ [ $nick ] ]) { halt }
  if (%wait. [ $+ [ $chan ] ]) { halt }
  if ($allupdate) { notice $nick $logo(ERROR) DMing is currently disabled, as we're performing an update. | halt }
  if ($regex($nick,/^Unknown[0-9]{5}$/Si)) { notice $Nick You currently have a nick that isn't allowed to use iDM please change it before DMing. | halt }
  if ($isbanned($nick)) { putlog $logo(Banned) $nick tried to dm on $chan | halt }
  if (%p1 [ $+ [ $chan ] ]) && ($nick == %p1 [ $+ [ $chan ] ]) { halt }
  if (%p2 [ $+ [ $chan ] ]) && ($nick == %p2 [ $+ [ $chan ] ]) { halt }
  if (!$islogged($nick,$address,3)) {
    notice $nick You have to login before you can use this command. (To check your auth type: /msg $me id)
    halt
  }
  if (%stake [ $+ [ $chan ] ]) { notice $Nick There is currently a stake, please type !stake to accept the challenge. | halt }
  if ($db.get(user,indm,$nick)) { notice $nick You're already in a DM.. | inc -u6 %dm.spam [ $+ [ $nick ] ] | halt }
  if (%p2 [ $+ [ $chan ] ]) && (!%dm.spam [ $+ [ $nick ] ]) { notice $nick $logo(DM) People are already DMing in this channel. | inc -u8 %dm.spam [ $+ [ $nick ] ] | halt }
  if (!%p1 [ $+ [ $chan ] ]) { msgsafe # $logo(DM) $s1($nick) $winloss($nick) has requested a DM! You have $s2(20 seconds) to accept.
    .timer $+ # 1 20 enddm #
    db.set user indm $nick 1
    set %p1 [ $+ [ $chan ] ] $nick
    set %dmon [ $+ [ $chan ] ] on
    halt
  }
  if (%p1 [ $+ [ $chan ] ]) && (!%p2 [ $+ [ $chan ] ]) {
    if ($address(%p1 [ $+ [ $chan ] ],2) == $address($nick,2)) && ($len($address($nick,2)) > 3 && $len($address(%p1 [ $+ [ $chan ] ],2)) > 3) {
      msgsafe # $logo(ERROR) We no longer allow two players on the same hostmask to DM each other.  You are free to DM others. If you have recieved this error as a mistake please drop by #idm.Support.
      inc -u5 %dm.spam [ $+ [ $nick ] ]
      halt
    }
    .timer $+ # off
    db.set user indm $nick 1
    set %turn [ $+ [ $chan ] ] $r(1,2) | set %p2 [ $+ [ $chan ] ] $nick | set %hp1 [ $+ [ $chan ] ] 99 | set %hp2 [ $+ [ $chan ] ] 99 | set %sp1 [ $+ [ $chan ] ] 4 | set %sp2 [ $+ [ $chan ] ] 4
    set -u25 %enddm [ $+ [ $chan ] ] 0
    var %winloss $winloss($nick,%p1 [ $+ [ $chan ] ],$chan)
    var %winlossp1 $gettok(%winloss,1,45)
    var %winlossp2 $gettok(%winloss,2,45)
    msgsafe $chan $logo(DM) $s1($nick) %winlossp1 has accepted $s1(%p1 [ $+ [ $chan ] ]) $+ 's %winlossp2 DM. $s1($iif(%turn [ $+ [ $chan ] ] == 1,%p1 [ $+ [ $chan ] ],$nick)) gets the first move.
  }
}

alias winloss {
  if ($2) {
    var %p1win $db.get(user,wins,$1)
    var %p2win $db.get(user,wins,$2)
    var %p1loss $db.get(user,losses,$1)
    var %p2loss $db.get(user,losses,$2)
    var %p1 $s2($chr(91)) $+ Wins $s1($iif(%p1win,$bytes($v1,bd),0)) Losses $s1($iif(%p1loss,$bytes($v1,bd),0)) $+ $s2($chr(93))
    var %p2 $s2($chr(91)) $+ Wins $s1($iif(%p2win,$bytes($v1,bd),0)) Losses $s1($iif(%p2loss,$bytes($v1,bd),0)) $+ $s2($chr(93))
    if ((($calc(%p1win + %p1loss) > 80) && (($calc(%p1win / %p1loss) > 4) || ($calc(%p1win / %p1loss) < 0.22))) || (($calc(%p2win + %p2loss) > 80) && (($calc(%p2win / %p2loss) > 4) || ($calc(%p2win / %p2loss) < 0.22)))) {
      msg #idm.staff $logo(4RATIO) $3 = $1 %p1 ( $+ $calc(%p1win / %p1loss) $+ ) - $2 %p2 ( $+ $calc(%p2win / %p2loss) $+ )
    }
    return $+(%p1,-,%p2)
  }
  elseif ($1) {
    var %p1win $db.get(user,wins,$1)
    var %p1loss $db.get(user,losses,$1)
    var %p1 $s2($chr(91)) $+ Wins $s1($iif(%p1win,$bytes($v1,bd),0)) Losses $s1($iif(%p1loss,$bytes($v1,bd),0)) $+ $s2($chr(93)) 
    return %p1
  }
}

alias cancel {
  if ($1) && ($chr(35) isin $1) {
    $iif(%p1 [ $+ [ $1 ] ],db.set user indm %p1 [ $+ [ $1 ] ] 0)
    $iif(%p2 [ $+ [ $1 ] ],db.set user indm %p2 [ $+ [ $1 ] ] 0)
    unset %veng [ $+ [ %p2 [ $+ [ $1 ] ] ] ]
    unset %veng [ $+ [ %p1 [ $+ [ $1 ] ] ] ]
    unset %stake* [ $+ [ $1 ] ]
    unset %frozen [ $+ [ %p1 [ $+ [ $1 ] ] ] ]
    unset %frozen [ $+ [ %p2 [ $+ [ $1 ] ] ] ]
    unset $+(%*,$1)
    .timer $+ $1 off
  }
}
alias enddm {
  if (%p2 [ $+ [ $2 ] ]) { halt }
  msgsafe $1 $logo(DM) Nobody has accepted $s1(%p1 [ $+ [ $1 ] ]) $+ 's DM request, and the DM has ended.
  cancel $1
}
on $*:TEXT:/^[!@.]enddm/Si:#: {
  if (# == #idm || # == #idm.Staff) && ($me != iDM) { halt }
  if (%stake [ $+ [ $chan ] ]) {
    if ($db.get(admins,position,$address($nick,3))) {
      if (!%p1 [ $+ [ $chan ] ]) { notice $nick There is no DM. | halt }
      cancel $chan
      msgsafe $chan $logo(DM) The DM has been canceled by staff.
      halt
    }
    else { notice $nick This is a stake, you cannot end stakes! | halt }
  }
  if ($db.get(admins,position,$address($nick,3))) {
    if (!%p1 [ $+ [ $chan ] ]) { notice $nick There is no DM. | halt }
    cancel $chan
    msgsafe $chan $logo(DM) The DM has been canceled by an admin.

  }
  elseif (($nick == %p2 [ $+ [ $chan ] ]) && (%turn [ $+ [ $chan ] ] == 1)) {
    var %othernick = %p1 [ $+ [ $chan ] ]
    if (%enddm [ $+ [ $chan ] ] == 0) {
      notice $nick Please wait at least 30 seconds after the last move before ending a dm.
      halt
    }
    notice $nick $+ , $+ %othernick The DM will end in 40 seconds if %othernick does not make a move or !enddm. If the dm times out %othernick will lose $price($ceil($calc($db.get(user,money,%othernick) * 0.005)))
    set %enddm [ $+ [ $chan ] ] %othernick
    timer 1 20 delaycancelw $chan %othernick
    timer 1 40 delaycancel $chan %othernick

  }
  elseif (($nick == %p1 [ $+ [ $chan ] ]) && (%turn [ $+ [ $chan ] ] == 2)) {
    var %othernick = %p2 [ $+ [ $chan ] ]
    if (%enddm [ $+ [ $chan ] ] == 0) {
      notice $nick Please wait at least 30 seconds after the last move before ending a dm.
      halt
    }
    notice $nick $+ , $+ %othernick The DM will end in 40 seconds if %othernick does not make a move or !enddm. If the dm times out %othernick will lose $price($ceil($calc($db.get(user,money,%othernick) * 0.005)))
    set %enddm [ $+ [ $chan ] ] %othernick
    timer 1 20 delaycancelw $chan %othernick
    timer 1 40 delaycancel $chan %othernick
  }
  elseif (($nick == %p1 [ $+ [ $chan ] ]) || ($nick == %p2 [ $+ [ $chan ] ])) {
    if (%enddm [ $+ [ $chan ] ] == 1) {
      cancel $chan
      msgsafe $chan $logo(DM) The DM was ended on agreement.
    }
    elseif (%turn [ $+ [ $chan ] ]) {
      notice $nick You can only end the dm on the other players turn.
    }
    else {
      cancel $chan
      msgsafe $chan $logo(DM) The DM has been canceled.
    }
  }
}

alias delaycancel {
  if (%enddm [ $+ [ $1 ] ] == $2) {
    cancel $1
    msgsafe $1 $logo(DM) The DM has ended due to timeout.
    var %oldmoney = $db.get(user,money,$2)
    if (%oldmoney > 100) {
      var %newmoney = $ceil($calc(%oldmoney - (%oldmoney * 0.005)))
      notice $2 You got kicked out of a dm, you lose $s2($price($calc(%oldmoney - %newmoney))) cash.
      write penalty.txt $timestamp $2 got !enddm'd on $1 oldcash %oldmoney newcash %newmoney
      db.set user money $2 %newmoney
    }
  }
}

alias delaycancelw {
  if (%enddm [ $+ [ $1 ] ] == $2) {
    msgsafe $1 $logo(DM) The DM will end in 20s if $2 does not make a move.
  }
}

on $*:TEXT:/^[!@.]status/Si:#: {
  if (# == #idm || # == #idm.Staff) && ($me != iDM) { halt }
  if (%p2 [ $+ [ $chan ] ]) {
    $iif($left($1,1) == @,msgsafe #,notice $nick) $status($chan)
  }
  elseif (%p1 [ $+ [ $chan ] ]) {
    $iif($left($1,1) == @,msgsafe #,notice $nick) $logo(STATUS) %p1 [ $+ [ $chan ] ] is waiting for someone to DM in $lower($chan) $+ .
  }
  else {
    $iif($left($1,1) == @,msgsafe #,notice $nick) $logo(STATUS) There is no DM in $lower($chan) $+ .
  }
}
alias status {
  ;return $logo(STATUS) Turn: $iif(%turn [ $+ [ $1 ] ] == 1,$s1(%p1 [ $+ [ $1 ] ]) $+ 's,$s1(%p2 [ $+ [ $1 ] ]) $+ 's) HP: $s1(%p1 [ $+ [ $1 ] ]) $s2(%hp1 [ $+ [ $1 ] ]) $iif(%pois1 [ $+ [ $1 ] ] >= 1,$+($chr(40),Pois $s2($v1),$chr(41))) $s1(%p2 [ $+ [ $1 ] ]) $s2(%hp2 [ $+ [ $1 ] ]) $iif(%pois2 [ $+ [ $1 ] ] >= 1,$+($chr(40),Pois $s2($v1),$chr(41))) Special Bar: $s1(%p1 [ $+ [ $1 ] ]) $s2($iif(%sp1 [ $+ [ $chan ] ] < 1,0,$gettok(25 50 75 100,%sp1 [ $+ [ $chan ] ],32))) $+ $s2($chr(37)) $s1(%p2 [ $+ [ $1 ] ]) $s2($iif(%sp2 [ $+ [ $chan ] ] < 1,0,$gettok(25 50 75 100,%sp2 [ $+ [ $chan ] ],32))) $+ $s2($chr(37))
  return $logo(STATUS) Turn: $iif(%turn [ $+ [ $1 ] ] == 1,$s1(%p1 [ $+ [ $1 ] ]) $+ 's,$s1(%p2 [ $+ [ $1 ] ]) $+ 's) HP: $s1(%p1 [ $+ [ $1 ] ]) $s2(%hp1 [ $+ [ $1 ] ]) $iif(%pois1 [ $+ [ $1 ] ] >= 1,$+($chr(40),Pois $s2($v1),$chr(41))) $iif(%frozen [ $+ [ %p1 [ $+ [ $1 ] ] ] ],$+($chr(40),12Frozen,$chr(41))) $s1(%p2 [ $+ [ $1 ] ]) $s2(%hp2 [ $+ [ $1 ] ]) $iif(%pois2 [ $+ [ $1 ] ] >= 1,$+($chr(40),Pois $s2($v1),$chr(41))) $iif(%frozen [ $+ [ %p2 [ $+ [ $1 ] ] ] ],$+($chr(40),12Frozen,$chr(41))) Special Bar: $s1(%p1 [ $+ [ $1 ] ]) $s2($iif(%sp1 [ $+ [ $chan ] ] < 1,0,$gettok(25 50 75 100,%sp1 [ $+ [ $chan ] ],32))) $+ $s2($chr(37)) $s1(%p2 [ $+ [ $1 ] ]) $s2($iif(%sp2 [ $+ [ $chan ] ] < 1,0,$gettok(25 50 75 100,%sp2 [ $+ [ $chan ] ],32))) $+ $s2($chr(37))
}
