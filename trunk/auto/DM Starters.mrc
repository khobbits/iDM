on $*:TEXT:/^[!@.]dm\b/Si:#: {
  if (# == #iDM.Support) { halt }
  if (# == #iDM || # == #iDM.Staff) && ($me != iDM) { halt }
  if (%dm.spam [ $+ [ $nick ] ]) { halt }
  if (%dming [ $+ [ $nick ] ] == on) { halt }
  if (%wait. [ $+ [ $chan ] ]) { halt }
  if ($allupdate) { notice $nick $logo(ERROR) DMing is currently disabled, as we're performing an update. | halt }
  if ($regex($nick,/^Unknown[0-9]{5}$/Si)) { notice $Nick You currently have a nick that isn't allowed to use iDM please change it before DMing. | halt }
  if ($isbanned($nick)) { halt }
  if (%p1 [ $+ [ $chan ] ]) && ($nick == %p1 [ $+ [ $chan ] ]) { halt }
  if (!$islogged($nick,3)) {
    notice $nick You have to login before you can use this command. (To check your auth type: /msg $me id)
    halt
  }
  if (%stake [ $+ [ $chan ] ]) { notice $Nick There is currently a stake, please type !stake to accept the challenge. | halt }
  if ($.readini(status.ini,currentdm,$nick)) { notice $nick You're already in a DM.. | inc -u6 %dm.spam [ $+ [ $nick ] ] | halt }
  if (%p2 [ $+ [ $chan ] ]) && (!%dm.spam [ $+ [ $nick ] ]) { notice $nick $logo(DM) People are already DMing in this channel. | inc -u8 %dm.spam [ $+ [ $nick ] ] | halt }
  if (!%p1 [ $+ [ $chan ] ]) { msg # $logo(DM) $s1($nick) $winloss($nick) has requested a DM! You have $s2(20 seconds) to accept.
    .timer $+ # 1 20 enddm #
    set %dming [ $+ [ $nick ] ] on
    writeini status.ini currentdm $nick true
    set %p1 [ $+ [ $chan ] ] $nick
    set %dmon [ $+ [ $chan ] ] on
    halt
  }
  if (%p1 [ $+ [ $chan ] ]) && (!%p2 [ $+ [ $chan ] ]) {
    if ($address(%p1 [ $+ [ $chan ] ],2) == $address($nick,2)) && ($len($address($nick,2)) > 3 && $len($address(%p1 [ $+ [ $chan ] ],2)) > 3) {
      msg # $logo(ERROR) We no longer allow two players on the same hostmask to DM each other.  You are free to DM others. If you have recieved this error as a mistake please drop by #iDM.Support.
      inc -u5 %dm.spam [ $+ [ $nick ] ]
      halt
    }
    .timer $+ # off
    set %dming [ $+ [ $nick ] ] on
    writeini status.ini currentdm $nick true
    set %turn [ $+ [ $chan ] ] $r(1,2) | set %p2 [ $+ [ $chan ] ] $nick | set %hp1 [ $+ [ $chan ] ] 99 | set %hp2 [ $+ [ $chan ] ] 99 | set %sp1 [ $+ [ $chan ] ] 4 | set %sp2 [ $+ [ $chan ] ] 4
    set -u25 %enddm [ $+ [ $chan ] ] 0
    msg $chan $logo(DM) $s1($nick) $winloss($nick) has accepted $s1(%p1 [ $+ [ $chan ] ]) $+ 's $winloss(%p1 [ $+ [ $chan ] ]) DM. $s1($iif(%turn [ $+ [ $chan ] ] == 1,%p1 [ $+ [ $chan ] ],$nick)) gets the first move.
  }
}

alias winloss {
  if ($1) {
    return $s2($chr(91)) $+ Wins $s1($iif($db.get(user,wins,$1),$bytes($v1,bd),0)) Losses $s1($iif($db.get(user,losses,$1),$bytes($v1,bd),0)) $+ $s2($chr(93))
  }
  return
}

alias cancel {
  if ($1) && ($chr(35) isin $1) {
    $iif(%p1 [ $+ [ $1 ] ],remini status.ini currentdm %p1 [ $+ [ $1 ] ])
    $iif(%p2 [ $+ [ $1 ] ],remini status.ini currentdm %p2 [ $+ [ $1 ] ])
    unset %veng [ $+ [ %p2 [ $+ [ $1 ] ] ] ]
    unset %veng [ $+ [ %p1 [ $+ [ $1 ] ] ] ]
    unset %dming [ $+ [ %p1 [ $+ [ $1 ] ] ] ]
    unset %dming [ $+ [ %p2 [ $+ [ $1 ] ] ] ]
    unset %stake* [ $+ [ $1 ] ]
    unset %frozen [ $+ [ %p1 [ $+ [ $1 ] ] ] ]
    unset %frozen [ $+ [ %p2 [ $+ [ $1 ] ] ] ]
    unset $+(%*,$1)
    .timer $+ $1 off
  }
}
alias enddm {
  if (%p2 [ $+ [ $2 ] ]) { halt }
  msg $1 $logo(DM) Nobody has accepted $s1(%p1 [ $+ [ $1 ] ]) $+ 's DM request, and the DM has ended.
  cancel $1
}
on $*:TEXT:/^[!@.]enddm/Si:#: {
  if (# == #iDM || # == #iDM.Staff) && ($me != iDM) { halt }
  if (%stake [ $+ [ $chan ] ]) {
    if ($db.get(admins,position,$address($nick,3))) {
      if (!%p1 [ $+ [ $chan ] ]) { notice $nick There is no DM. | halt }
      cancel $chan
      msg $chan $logo(DM) The DM has been canceled by an admin.
      halt
    }
    else { notice $nick This is a stake, you cannot end stakes! | halt }
  }
  if ($db.get(admins,position,$address($nick,3))) {
    if (!%p1 [ $+ [ $chan ] ]) { notice $nick There is no DM. | halt }
    cancel $chan
    msg $chan $logo(DM) The DM has been canceled by an admin.

  }
  elseif (($nick == %p2 [ $+ [ $chan ] ]) && (%turn [ $+ [ $chan ] ] == 1)) {
    var %othernick = %p1 [ $+ [ $chan ] ]
    if (%enddm [ $+ [ $chan ] ] == 0) {
      notice $nick Please wait at least 30 seconds after the last move before ending a dm.
      halt
    }
    notice $nick $+ , $+ %othernick The DM will end in 40 seconds if %othernick does not make a move or !enddm. If the dm times out %othernick will lose $price($ceil($calc($db.get(user,money,%othernick) * 0.005)))
    set %enddm [ $+ [ $chan ] ] 1
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
    set %enddm [ $+ [ $chan ] ] 1
    timer 1 20 delaycancelw $chan %othernick
    timer 1 40 delaycancel $chan %othernick
  }
  elseif (($nick == %p1 [ $+ [ $chan ] ]) || ($nick == %p2 [ $+ [ $chan ] ])) {
    if (%enddm [ $+ [ $chan ] ] == 1) {
      cancel $chan
      msg $chan $logo(DM) The DM was ended on agreement.
    }
    elseif (%turn [ $+ [ $chan ] ]) {
      notice $nick You can only end the dm on the other players turn.
    }
    else {
      cancel $chan
      msg $chan $logo(DM) The DM has been canceled.
    }
  }
}

alias delaycancel {
  if (%enddm [ $+ [ $1 ] ] == 1) {
    cancel $1
    msg $1 $logo(DM) The DM has ended due to timeout.
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
  if (%enddm [ $+ [ $1 ] ] == 1) {
    msg $1 $logo(DM) The DM will end in 20s if $2 does not make a move.
  }
}

alias hpbar {
  if ($istok($npcs,$2,32)) {
    if (-* iswm $1) {
      tokenize 32 0
    }
    if ($1 > 400) {
      tokenize 32 400
    }
    return $+($str($+(09,$chr(44),09,.),$floor($calc( $1 /20))),$str($+(04,$chr(44),04,.),$ceil($calc((400- $1 ) /20)))) $+ 
  }
  if (-* iswm $1) {
    tokenize 32 0
  }
  if ($1 > 99) {
    tokenize 32 99
  }
  return $+($str($+(09,$chr(44),09,.),$floor($calc( $1 /5))),$str($+(04,$chr(44),04,.),$floor($calc((99- $1 ) /5)))) $+ 
}
on $*:TEXT:/^[!@.]status/Si:#: {
  if (# == #iDM || # == #iDM.Staff) && ($me != iDM) { halt }
  if (%p2 [ $+ [ $chan ] ]) {
    $iif($left($1,1) == @,msg #,notice $nick) $status($chan)
  }
  elseif (%p1 [ $+ [ $chan ] ]) {
    $iif($left($1,1) == @,msg #,notice $nick) $logo(STATUS) %p1 [ $+ [ $chan ] ] is waiting for someone to DM in $chan $+ .
  }
  else {
    $iif($left($1,1) == @,msg #,notice $nick) $logo(STATUS) There is no DM in $chan $+ .
  }
}
alias status {
  return $logo(STATUS) Turn: $iif(%turn [ $+ [ $1 ] ] == 1,$s1(%p1 [ $+ [ $1 ] ]) $+ 's,$s1(%p2 [ $+ [ $1 ] ]) $+ 's) HP: $s1(%p1 [ $+ [ $1 ] ]) $s2(%hp1 [ $+ [ $1 ] ]) $iif(%pois1 [ $+ [ $1 ] ] >= 1,$+($chr(40),Pois $s2($v1),$chr(41))) $s1(%p2 [ $+ [ $1 ] ]) $s2(%hp2 [ $+ [ $1 ] ]) $iif(%pois2 [ $+ [ $1 ] ] >= 1,$+($chr(40),Pois $s2($v1),$chr(41))) Special Bar: $s1(%p1 [ $+ [ $1 ] ]) $s2($iif(%sp1 [ $+ [ $chan ] ] < 1,0,$gettok(25 50 75 100,%sp1 [ $+ [ $chan ] ],32))) $+ $s2($chr(37)) $s1(%p2 [ $+ [ $1 ] ]) $s2($iif(%sp2 [ $+ [ $chan ] ] < 1,0,$gettok(25 50 75 100,%sp2 [ $+ [ $chan ] ],32))) $+ $s2($chr(37))
}
