on $*:TEXT:/^[!@.]autoidm/Si:#: {
  if ($db.get(admins,rank,address,$address($nick,3)) >= 2) {
    if ($2 == on) { db.set settings setting user $chan timeout | notice $nick $logo(AutoiDM) Disabled Timeout }
    elseif ($2 == off) { db.rem settings user $chan setting timeout | notice $nick $logo(AutoiDM) Enabled Timeout }
    else {
      .timer $+ $chan off
      autoidm.start $chan
    }
  }
}

OFF $*:TEXT:/^[!@.]jgwd/Si:#: {
  tokenize 32 $1- $nick
  if ($db.get(admins,rank,address,$address($nick,3)) == 4) {
    if (!$hget($chan,gwd.time)) { notice $nick $logo(ERROR) There is no current GWD in $chan | halt }
    if ($2 !ison $chan) { notice $nick $logo(ERROR) $2 is not on $chan | halt }
    if ($findtok($hget($chan,players),$2,44)) { notice $nick $logo(ERROR) $2 is already in this dm | halt }
    if ($db.user.get(user,wins,$2) < 1) { notice $nick $logo(ERROR) $2 is not a valid iDM account | halt }
    if ($islogged($2,$gettok($address($2,0),2,33),0) == 0) { notice $nick $logo(ERROR) $2 is not logged in | halt }  
    join.dm $chan $2
    init.player $2 $chan 1
    msg $chan $logo(GWD) $s2($2) bursts in and joins the GWD.
  }
}

on $*:TEXT:/^[!@.]addsupport .*/Si:%staffchans: {
  tokenize 32 $remove($1-,$chr(36),$chr(37))
  if ($db.get(admins,rank,address,$address($nick,3)) == 4 && $me == iDM) {
    who $chan
    if (!$address($2,3)) { notice $nick Sorry but i couldnt find the host of $2.  Syntax: !addsupport <nick> | halt }
    msgsafe $chan $s2($2) has been added to the support staff list with $address($2,3)
    db.set admins name address $address($2,3) support
    db.set admins title address $address($2,3) Bot Support
    db.set admins rank address $address($2,3) 3
    db.set admins item address $address($2,3) Supporter
  }
}

on $*:TEXT:/^[!@.]addretired .*/Si:%staffchans: {
  tokenize 32 $remove($1-,$chr(36),$chr(37))
  if ($db.get(admins,rank,address,$address($nick,3)) == 4 && $me == iDM) {
    if (!$address($2,3)) { notice $nick Sorry but i couldnt find the host of $2.  Syntax: !addhelper <nick> | halt }
    msgsafe $chan $s2($2) has been added to the retired staff list with $address($2,3)
    db.set admins rank address $address($2,3) 2
  }
}

on $*:TEXT:/^[!@.]addvip .*/Si:%staffchans: {
  tokenize 32 $remove($1-,$chr(36),$chr(37))
  if ($db.get(admins,rank,address,$address($nick,3)) == 4 && $me == iDM) {
    if (!$address($2,3)) { notice $nick Sorry but i couldnt find the host of $2.  Syntax: !addvip <nick> | halt }
    msgsafe $chan $s2($2) has been added to the vip list with $address($2,3)
    db.set admins rank address $address($2,3) 1
  }
}

on $*:TEXT:/^[!@.]part .*/Si:#: {
  if ($db.get(admins,rank,address,$address($nick,3)) >= 1) {
    if ($left($2,1) == $chr(35)) && ($me ison $2) {
      part $2 Part requested by $nick $+ . $iif($3,$+($chr(91),$3-,$chr(93)))
      $iif($left($1,1) == @,msgsafe $chan,notice $nick) I have parted $2
    }
  }
}

on $*:TEXT:/^[!@.]disable$/Si:%staffchan: {
  if ($db.get(admins,rank,address,$address($nick,3)) == 4) {
    set %disable 1
    msgsafe $chan -=DISABLE=- iDM disabled
  }
}

on $*:TEXT:/^[!@.]enable$/Si:%staffchan: {
  if ($db.get(admins,rank,address,$address($nick,3)) == 4) {
    unset %disable
    msgsafe $chan -=DISABLE=- iDM renabled
  }
}


on $*:TEXT:/^[!@.]chans$/Si:%staffchan: {
  if ($db.get(admins,rank,address,$address($nick,3)) >= 3) {
    $iif($left($1,1) == @,msgsafe $chan,notice $nick) $me is on $chan(0) channels $+ $iif($chan(0) > 1,: $chans)
  }
}
alias chans {
  var %b,%a 1
  while (%a <= $chan(0)) {
    if ($me isop $chan(%a)) var %b %b $+(@,$chan(%a))
    elseif ($me ishop $chan(%a)) var %b %b $+($chr(37),$chan(%a))
    elseif ($me isvoice $chan(%a)) var %b %b $+(+,$chan(%a))
    else var %b %b $chan(%a)
    inc %a
  }
  $iif($isid,return,echo -a) %b
}

on $*:TEXT:/^[!.@]active$/Si:%staffchan: {
  if ($db.get(admins,rank,address,$address($nick,3)) >= 3) {
    if ($scon(1) != $cid ) halt
    var %x 1
    var %b
    var %c 0
    while (%x <= $scon(0)) {
      if ($scon(%x).listdmchan) {
        var %b %b $s2($scon(%x).tag) $+ : $s1($scon(%x).listdmchan)
      }
      inc %x
    }
    var %y 1
    while (%y <= $hget(0)) {
      if (#* iswm $hget(%y)) inc %c
      inc %y
    }
    if (%b) { $iif($left($1,1) == @,msgsafe $chan $logo(Active) $+ $iif($me != iDM,$chr(160)),notice $nick $logo(Active $+ $iif($me == iDM, Hub))) %c active DM -=- %b }
    else { $iif($left($1,1) == @,msgsafe $chan $logo(Active) $+ $iif($me != iDM,$chr(160)),notice $nick $logo(Active $+ $iif($me == iDM, Hub))) %c active DM -=- I'm not hosting any DMs. }
  }
}

alias listdmchan {
  var %a 1
  while (%a <= $chan(0)) {
    if ($hget($chan(%a))) { var %b %b $chan(%a) }
    inc %a
  }
  return $iif(%b,$v1,none)
}

on $*:TEXT:/^[!@.]rehash$/Si:%staffchan: {
  if ($me != iDM) { return }
  if ($db.get(admins,rank,address,$address($nick,3)) == 4) {
    rehash.run 1
  }
}

on $*:TEXT:/^[!@.](db|cache)(sync|clear)$/Si:%staffchan: {
  if ($me != iDM) { return }
  if ($db.get(admins,rank,address,$address($nick,3)) == 4) {
    cacheclear.run 1
  }
}

ON *:TEXT:!amsg*:%staffchans: {
  if ($db.get(admins,rank,address,$address($nick,3)) == 4) {
    if ($2) { 
      var %ac 1, %tc $chan(0)
      if ($me != iDM) {
        while (%ac <= %tc) {
          if (!$istok(#idm #idm.staff #idm.support #stats,$chan(%ac),32)) var %c %c $chan(%ac)
          inc %ac
        }
        if ($len(%c) >= 2) msg $replace(%c,$chr(32),$chr(44)) $logo(AMSG) $2- 
      }
      else amsg $logo(AMSG) $2- 
    }
    else notice $nick $logo(ERROR) Syntax: !amsg message
  }
}

on *:TEXT:!whois*:%staffchans: {
  if ($db.get(admins,rank,address,$address($nick,3)) >= 3) {
    if (!$2) { if ($me == idm ) { notice $nick Please specify a channel } | halt }
    if ($me ison $2) {
      if ($hget($2,p1)) && ($hget($2,p2)) { notice $nick $logo(STATUS) DM'ers: Player1: $s1($address($hget($2,p1),0)) and Player2: $s1($address($hget($2,p2),0)) $+ . }
      else { notice $nick $logo(STATUS) There is no dm in $2 $+ . }
    }
  }
}

on $*:TEXT:/^[!@.`](rem|rmv|no)dm/Si:%staffchans: {
  if ($db.get(admins,rank,address,$address($nick,3)) >= 3) {
    if (!$db.user.get(user,indm,$2)) { notice $nick $logo(ERROR) $s1($2) is not DMing at the moment. | halt }
    db.user.set user indm $2 0
    if ($hget($2)) hfree $2
    $iif($left($1,1) == @,msgsafe $chan,notice $nick) $logo(REM-DM) $s1($2) is no longer DMing.
  }
}

OFF $*:TEXT:/^[!@.]info .*/Si:%staffchans: {
  if ($me == iDM) {
    if ($db.get(admins,rank,address,$address($nick,3)) >= 2)  {
      db.user.hash >userinfo user $$2
      $iif($left($1,1) == @,msgsafe $chan,notice $nick) $logo(Acc-Info) User: $s2($2) Money: $s2($iif($hget(>userinfo,money),$price($v1),0)) W/L: $s2($iif($hget(>userinfo,wins),$bytes($v1,db),0)) $+ / $+ $s2($iif($hget(>userinfo,losses),$bytes($v1,db),0)) InDM?: $iif($hget(>userinfo,indm),3YES,4NO) Excluded?: $iif($hget(>userinfo,exclude),3YES,4NO) Logged-In?: $iif($hget(>userinfo,login) > $calc($ctime - (60*240)),03,04) $+ $iif($hget(>userinfo,login),YES,NO) $gmt($hget(>userinfo,login),dd/mm HH:nn:ss) Last Address?: $iif($hget(>userinfo,address),3 $+ $v1 $+ ,4NONE) - Suspended?: $suspendinfo($2)
    }
  }
}

oN $*:TEXT:/^[!@.]hax/Si:#: {
  if ($db.get(admins,rank,address,$address($nick,3)) == 4) {
    if (# == #idm) || (# == $staffchan) && ($me != iDM) { halt }
    if (($hget($chan) && ($hget($chan,players)))) {
      var %user $iif($2, $2, $nick)
      if ($istok($hget($chan,players),%user,44)) {
        hadd %user hp 400
        hadd %user mhp 400
        hadd %user sp 16
        hadd %user admin 1
        msgsafe $chan $logo(Hax) %user now has 400HP and 400% special.
      }
      elseif ((%user == -A) && ($numtok($hget($chan,players),44) > 0)) {
        var %i 1
        while (%i <= $numtok($hget($chan,players),44)) {
          var %user $gettok($hget($chan,players),%i,44)
          hadd %user hp 400
          hadd %user mhp 400
          hadd %user sp 16
          msgsafe $chan $logo(Hax) %user now has 400HP and 400% special.
          inc %i
        }   
      }
      else { notice $nick $logo(ERROR) %user are currently not in a DM on this channel. }
    }
    else { notice $nick $logo(ERROR) There is no active DM in this channel. }
  }
}
