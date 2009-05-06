on *:TEXT:!dm:#: {
  if (# == #iDM.Support) { halt }
  if (# == #iDM || # == #iDM.Staff) && ($me != iDM) { halt }
  if ($allupdate) { notice $nick $logo(ERROR) DMing is currently disabled, as we're performing an update. | halt }
  if ($regex($nick,/^Unknown[0-9]{5}$/Si)) { notice $Nick You currently have a nick that isn't allowed to use iDM please change it before DMing. | halt }
  if (%wait. [ $+ [ $chan ] ]) { halt }
  if (%dm.spam [ $+ [ $nick ] ]) { halt }
  if (%p1 [ $+ [ $chan ] ]) && ($nick == %p1 [ $+ [ $chan ] ]) { halt }
  if (%stake [ $+ [ $chan ] ]) { notice $Nick There is currently a stake, please type !stake to accept the challenge. | halt }
  if ($readini(status.ini,currentdm,$nick)) { notice $nick You're already in a DM.. | halt }
  if (%p2 [ $+ [ $chan ] ]) && (!%dm.spam [ $+ [ $nick ] ]) { notice $nick $logo(DM) People are already DMing in this channel. | inc -u10 %dm.spam [ $+ [ $nick ] ] | halt }
  if (!%p1 [ $+ [ $chan ] ]) { msg # $logo(DM) $s1($nick) $winloss($nick) has requested a DM! You have $s2(20 seconds) to accept. | .timer $+ # 1 20 enddm # | set %dming [ $+ [ $nick ] ] on | writeini -n status.ini currentdm $nick true | set %p1 [ $+ [ $chan ] ] $nick | set %dmon [ $+ [ $chan ] ] on | halt }
  if (%p1 [ $+ [ $chan ] ]) && (!%p2 [ $+ [ $chan ] ]) { .timer $+ # off | set %address1 [ $+ [ $chan ] ] $address($nick,4) | set %dming [ $+ [ $nick ] ] on | writeini -n status.ini currentdm $nick true | set %turn [ $+ [ $chan ] ] $r(1,2) | set %p2 [ $+ [ $chan ] ] $nick | set %hp1 [ $+ [ $chan ] ] 99 | set %hp2 [ $+ [ $chan ] ] 99 | set %sp1 [ $+ [ $chan ] ] 4 | set %sp2 [ $+ [ $chan ] ] 4 | set %food1 [ $+ [ $chan ] ] 10 | set %food2 [ $+ [ $chan ] ] 10 | msg $chan $logo(DM) $s1($nick) $winloss($nick) has accepted $s1(%p1 [ $+ [ $chan ] ]) $+ 's $winloss(%p1 [ $+ [ $chan ] ]) DM. $s1($iif(%turn [ $+ [ $chan ] ] == 1,%p1 [ $+ [ $chan ] ],$nick)) gets the first move. }
  if ($address(%p1 [ $+ [ $chan ] ],2) == $address(%p2 [ $+ [ $chan ] ],2)) {  
    if (!$readini(exceptions.ini,exceptions,$address(%p1 [ $+ [ $chan ] ],2)) && !$readini(exceptions.ini,exceptions,$address(%p2 [ $+ [ $chan ] ],2))) {
      if (%p1 [ $+ [ $chan ] ] isin %p2 [ $+ [ $chan ] ] || %p2 [ $+ [ $chan ] ] isin %p1 [ $+ [ $chan ] ]) {
        msg # $logo(Warning) I have detected that you are self DMing. I suggest you end this DM or risk the channel being blacklisted and banned from iDM.
        msg #idm.staff $logo(Clones) $s1(%p1 [ $+ [ $chan ] ]) $+($s2([),$cloneStats(%p1 [ $+ [ $chan ] ]),$s2(])) and $s1(%p2 [ $+ [ $chan ] ]) $+($s2([),$cloneStats(%p2 [ $+ [ $chan ] ]),$s2(])) $s2([) $+ $remove($address(%p1 [ $+ [ $chan ] ],2),%p1 [ $+ [ $chan ] ] $+ ! $+ $chr(126)) $+ $s2(]) in $s1($chan) [Warned]
        halt
      }
      elseif ($strip($cloneStats(%p1 [ $+ [ $chan ] ])) == 0gp/0W/0L || $strip($cloneStats(%p2 [ $+ [ $chan ] ])) == 0gp/0W/0L) {
        msg # $logo(Warning) I have detected that you are self DMing. I suggest you end this DM or risk the channel being blacklisted and banned from iDM.
        msg #idm.staff $logo(Clones) $s1(%p1 [ $+ [ $chan ] ]) $+($s2([),$cloneStats(%p1 [ $+ [ $chan ] ]),$s2(])) and $s1(%p2 [ $+ [ $chan ] ]) $+($s2([),$cloneStats(%p2 [ $+ [ $chan ] ]),$s2(])) $s2([) $+ $remove($address(%p1 [ $+ [ $chan ] ],2),%p1 [ $+ [ $chan ] ] $+ ! $+ $chr(126)) $+ $s2(]) in $s1($chan) [Warned]
        halt
      }
      else {
        msg #idm.staff $logo(Clones) $s1(%p1 [ $+ [ $chan ] ]) $+($s2([),$cloneStats(%p1 [ $+ [ $chan ] ]),$s2(])) and $s1(%p2 [ $+ [ $chan ] ]) $+($s2([),$cloneStats(%p2 [ $+ [ $chan ] ]),$s2(])) $s2([) $+ $remove($address(%p1 [ $+ [ $chan ] ],2),%p1 [ $+ [ $chan ] ] $+ ! $+ $chr(126)) $+ $s2(]) in $s1($chan)
        halt
      }
    }
  }
}

alias winloss {
  if ($1) {
    return $s2($chr(91)) $+ Wins $s1($iif($readini(Wins.ini,Wins,$1),$bytes($v1,bd),0)) Losses $s1($iif($readini(Losses.ini,Losses,$1),$bytes($v1,bd),0)) $+ $s2($chr(93))
  }
  return
}

alias cloneStats {
  return $price($iif($readini(Money.ini,Money,$1),$v1,0))) $+ $s2(/) $+ $iif($readini(Wins.ini,Wins,$1),$v1 $+ W,0W) $+ $s2(/) $+ $iif($readini(Losses.ini,Losses,$1),$v1 $+ L,0L))
}


alias cancel {
  if ($1) && ($chr(35) isin $1) {
    $iif(%p1 [ $+ [ $1 ] ],remini status.ini currentdm %p1 [ $+ [ $1 ] ])
    $iif(%p2 [ $+ [ $1 ] ],remini status.ini currentdm %p2 [ $+ [ $1 ] ])
    unset %veng [ $+ [ %p2 [ $+ [ $1 ] ] ] ]
    unset %veng [ $+ [ %p1 [ $+ [ $1 ] ] ] ]
    unset %stun [ $+ [ %p2 [ $+ [ $1 ] ] ] ]
    unset %stun [ $+ [ %p1 [ $+ [ $1 ] ] ] ]
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
on *:TEXT:!enddm:#: {
  if (# == #iDM || # == #iDM.Staff) && ($me != iDM) { halt }
  if (%stake [ $+ [ $chan ] ]) { 
    if ($readini(Admins.ini,Admins,$nick)) || ($readini(Admins.ini,Admins,$address($nick,3))) {
      if (!%p1 [ $+ [ $chan ] ]) { notice $nick There is no DM. | halt }
      cancel #
      msg # $logo(DM) The DM has been canceled by an admin.
      halt
    }
    else { notice $nick You are currently in a stake, you cannot forfeit! | halt }
  }
  if ($readini(Admins.ini,Admins,$nick)) || ($readini(Admins.ini,Admins,$address($nick,3))) {
    if (!%p1 [ $+ [ $chan ] ]) { notice $nick There is no DM. | halt }
    cancel #
    msg # $logo(DM) The DM has been canceled by an admin.
    halt
  }
  if ($nick == %p1 [ $+ [ $chan ] ]) || ($nick == %p2 [ $+ [ $chan ] ]) {
    cancel #
    msg # $logo(DM) The DM has been canceled.
    halt
  }
}

alias hpbar { 
  if ($left($1,1) == $chr(45)) {
    tokenize 32 0
  }
  if ($1 > 99) {
    tokenize 32 99
  }
  return $+($str($+(09,$chr(44),09,.),$floor($calc( $1 /5))),$str($+(04,$chr(44),04,.),$floor($calc((99- $1 ) /5)))) $+ 
}
on *:TEXT:?status:#: {
  if (# == #iDM || # == #iDM.Staff) && ($me != iDM) { halt }
  if ($left($1,1) isin !@) {
    if (!%p2 [ $+ [ $chan ] ]) { halt }
    $iif($left($1,1) == !,notice $nick,msg #) $status($chan)
  }
}
alias status {
  return $logo(STATUS) Turn: $iif(%turn [ $+ [ $1 ] ] == 1,$s1(%p1 [ $+ [ $1 ] ]) $+ 's,$s1(%p2 [ $+ [ $1 ] ]) $+ 's) HP: $s1(%p1 [ $+ [ $1 ] ]) $s2(%hp1 [ $+ [ $1 ] ]) $s1(%p2 [ $+ [ $1 ] ]) $s2(%hp2 [ $+ [ $1 ] ]) Special Bar: $s1(%p1 [ $+ [ $1 ] ]) $s2($iif(%sp1 [ $+ [ $chan ] ] < 1,0,$gettok(25 50 75 100,%sp1 [ $+ [ $chan ] ],32))) $+ $s2($chr(37)) $s1(%p2 [ $+ [ $1 ] ]) $s2($iif(%sp2 [ $+ [ $chan ] ] < 1,0,$gettok(25 50 75 100,%sp2 [ $+ [ $chan ] ],32))) $+ $s2($chr(37))
}

alias blockmultidm {
  if ($istok(iDM[BU] IDM[FU] IDM[SN],$me,32)) { .ctcp iDM blockmultidm $1- | .ctcp IDM[PK] blockmultidm $1- }
  elseif ($istok(iDM iDM[LL] iDM[US],$me,32)) { .ctcp iDM[BU] blockmultidm $1- | .ctcp IDM[PK] blockmultidm $1- }
  elseif ($istok(IDM[PK] IDM[BA] IDM[AL],$me,32)) { .ctcp iDM[BU] blockmultidm $1- | .ctcp IDM blockmultidm $1- }
}

CTCP *:*blockmultidm*:?: {
  if ($istok(iDM[BU] IDM[FU] IDM[SN] iDM iDM[LL] iDM[US] IDM[PK] IDM[BA] IDM[AL],$nick,32)) {
    if ($3) { unset %dming [ $+ [ $2 ] ] | unset %dming [ $+ [ $3 ] ] }
    else { set %dming [ $+ [ $2 ] ] on }
  }
}