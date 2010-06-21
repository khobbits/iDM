on $*:TEXT:/^[!.]admin$/Si:#idm.staff: {
  if ($db.get(admins,rank,$address($nick,3)) >= 3 && $me == iDM) {
    notice $nick $s1(Admin commands:) $s2(!addsupport nick, !join bot chan, !rehash, !ignoresync, !amsg, $&
      !(show/rem)dm nick, !define/increase/decrease account item amount !rename oldnick newnick !addsupport nick !cookie nick adjust $&
      ) $s1(Support commands:) $s2(!chans, !active, !part chan, !(r)suspend nick !(r)ignore nick/host, !(r)blist chan, !viewitems !(give/take)item nick !whois chan !globes)  $s1(Helper commands:) $s2(!cignore nick/host, !csuspend nick, !cblist chan, !info nick)
  }
}

on $*:TEXT:/^[!.]autoidm/Si:#: {
  if ($db.get(admins,rank,$address($nick,3)) == 4) {
    if ($2 == on) { db.set settings setting $chan timeout | notice $nick $logo(AutoIDM) Disabled Timeout }
    elseif ($2 == off) { db.remove settings $chan setting timeout | notice $nick $logo(AutoIDM) Enabled Timeout }
    else {  
      .timer $+ $chan off
      autoidm.start $chan
    }
  }
}

on $*:TEXT:/^[!.]addsupport .*/Si:#idm.staff,#idm.support: {
  tokenize 32 $remove($1-,$chr(36),$chr(37))
  if ($db.get(admins,rank,$address($nick,3)) == 4 && $me == iDM) {
    who $chan
    if (!$address($2,3)) { notice $nick Sorry but i couldnt find the host of $2.  Syntax: !addsupport <nick> | halt }
    msg $chan $s2($2) has been added to the support staff list with $address($2,3)
    db.set admins name $address($2,3) support
    db.set admins title $address($2,3) Bot Support
    db.set admins rank $address($2,3) 3
    db.set admins item $address($2,3) Supporter
  }
}

on $*:TEXT:/^[!.]addhelper .*/Si:#idm.staff,#idm.support: {
  tokenize 32 $remove($1-,$chr(36),$chr(37))
  if ($db.get(admins,rank,$address($nick,3)) == 4 && $me == iDM) {
    if (!$address($2,3)) { notice $nick Sorry but i couldnt find the host of $2.  Syntax: !addhelper <nick> | halt }
    msg $chan $s2($2) has been added to the helper staff list with $address($2,3)
    db.set admins title $address($2,3) Bot Helper
    db.set admins rank $address($2,3) 2
  }
}

on $*:TEXT:/^[!.]addvip .*/Si:#idm.staff,#idm.support: {
  tokenize 32 $remove($1-,$chr(36),$chr(37))
  if ($db.get(admins,rank,$address($nick,3)) == 4 && $me == iDM) {
    if (!$address($2,3)) { notice $nick Sorry but i couldnt find the host of $2.  Syntax: !addvip <nick> | halt }
    msg $chan $s2($2) has been added to the vip list with $address($2,3)
    db.set admins rank $address($2,3) 1
  }
}

on $*:TEXT:/^[!.]part .*/Si:#: {
  if ($db.get(admins,rank,$address($nick,3)) >= 3) {
    if ($left($2,1) == $chr(35)) && ($me ison $2) {
      part $2 Part requested by Bot Staff - $nick $+ . $iif($3,$+($chr(91),$3-,$chr(93)))
      notice $nick I have parted $2
    }
  }
}

on $*:TEXT:/^[!.]chans$/Si:#idm.staff: {
  if ($db.get(admins,rank,$address($nick,3)) >= 3) {
    notice $nick I am on $chan(0) channels $+ $iif($chan(0) > 1,: $chans)
  }
}
alias chans {
  var %b,%a 1
  while (%a <= $chan(0)) {
    if ($me isop $chan(%a)) var %b %b $+(@,$chan(%a))
    if ($me ishop $chan(%a)) var %b %b $+($chr(37),$chan(%a))
    if ($me isvoice $chan(%a)) var %b %b $+(+,$chan(%a))
    if ($me isreg $chan(%a)) var %b %b $chan(%a)
    inc %a
  }
  $iif($isid,return,echo -a) %b
}

on $*:TEXT:/^[!.@]active$/Si:#iDM.Staff: {
  if ($db.get(admins,rank,$address($nick,3)) >= 3) {
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
    if (%b) { $iif($left($1,1) == @,msg # $logo(Active) $+ $iif($me != iDM,$chr(160)),notice $nick $logo(Active $+ $iif($me == iDM, Hub))) %c active DM -=- %b }
    else { $iif($left($1,1) == @,msg # $logo(Active) $+ $iif($me != iDM,$chr(160)),notice $nick $logo(Active $+ $iif($me == iDM, Hub))) %c active DM -=- I'm not hosting any DMs. }
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

on $*:TEXT:/^[!.]join .*/Si:#idm.staff: {
  if ($db.get(admins,rank,$address($nick,3)) == 4) {
    if ($left($3,1) != $chr(35)) { halt }
    if (!$3) { notice $nick To use the join command, type !join botname channel. | halt }
    if ($2 == $me) {
      set %forcedj. [ $+ [ $3 ] ] true
      join $3
      .timer 1 1 msg $3 $logo(JOIN) I was requested to join this channel by $position($nick) $nick $+ . $chr(91) $+ Bot tag - $s1($bottag) $+ $chr(93)
    }
  }
}

on $*:TEXT:/^[!.]rehash$/Si:#idm.staff: {
  if ($me != iDM) { return }
  if ($db.get(admins,rank,$address($nick,3)) == 4) {
    rehash.run 0
  }
}

on $*:TEXT:/^[!.]ignoresync$/Si:#idm.staff: {
  if ($me != iDM) { return }
  if ($db.get(admins,rank,$address($nick,3)) == 4) {
    ignoresync.run 0
  }
}

on *:TEXT:!amsg*:#idm.staff: {
  if ($db.get(admins,rank,$address($nick,3)) == 4) {
    if (!$2) { notice $nick Syntax: !amsg 03message | halt }
    if ($+(*,$nick,*) iswm $2-) { notice $nick $logo(ERROR) Please dont add your name in the amsg since it adds your name to the amsg automatically. | halt }
    if ($me == iDM) { amsg $logo(AMSG) $2- 07[03 $+ $nick $+ 07] | halt }
    var %x = 1
    while ($chan(%x)) {
      if ($chan(%x) != #idm && $chan(%x) != #idm.Staff) {
        msgsafe $chan(%x) $logo(AMSG) $2- 07[03 $+ $nick $+ 07]
      }
      inc %x
    }
  }
}

on *:TEXT:!whois*:#iDM.Staff,#iDM.Support: {
  if ($db.get(admins,rank,$address($nick,3)) >= 3) {
    if (!$2) { if ($me == idm ) { notice $nick Please specify a channel } | halt }
    if ($me ison $2) {
      if ($hget($2,p1)) && ($hget($2,p2)) { notice $nick $logo(STATUS) DM'ers: Player1: $s1($address($hget($2,p1),0)) and Player2: $s1($address($hget($2,p2),0)) $+ . }
      else { notice $nick $logo(STATUS) There is no dm in $2 $+ . }
    }
  }
}

on *:TEXT:!globes:#: {
  if ($db.get(admins,rank,$address($nick,3)) >= 2) {
    if ($me == idm) { 
      var %i 0
      var %sql = SELECT * FROM `equip_item` WHERE snow >= 1
      var %result = $db.query(%sql)
      var %i = $db.query_num_rows(%result)
      db.query_end %result
      msg $chan $logo(Snow Globes) %i have been dropped.
    }
  }
}

on $*:TEXT:/^[!.`](rem|rmv|no)dm/Si:#idm.staff,#idm.support: {
  if ($db.get(admins,rank,$address($nick,3)) >= 3) {
    if (!$db.get(user,indm,$2)) { notice $nick $logo(ERROR) $s1($2) is not DMing at the moment. | halt }
    db.set user indm $2 0
    notice $nick $logo(REM-DM) $s1($2) is no longer DMing.
  }
}

on $*:TEXT:/^[!@.]info .*/Si:#idm.Staff,#idm.Support: {
  if ($me == iDM) {
    if ($db.get(admins,rank,$address($nick,3)) >= 2)  {
      db.hget >userinfo user $$2
      $iif($left($1,1) == @,msg #,notice $nick) $logo(Acc-Info) User: $s2($2) Money: $s2($iif($hget(>userinfo,money),$price($v1),0)) W/L: $s2($iif($hget(>userinfo,wins),$bytes($v1,db),0)) $+ / $+ $s2($iif($hget(>userinfo,losses),$bytes($v1,db),0)) InDM?: $iif($hget(>userinfo,indm),3YES,4NO) Excluded?: $iif($hget(>userinfo,exclude),3YES,4NO) Logged-In?: $iif($hget(>userinfo,login) > $calc($ctime - (60*240)),03,04) $+ $iif($hget(>userinfo,login),YES,NO) $gmt($hget(>userinfo,login),dd/mm HH:nn:ss) Last Address?: $iif($hget(>userinfo,address),3 $+ $v1 $+ ,4NONE)
      ignoreinfo $iif($2,$2 $2,$nick $nick) $iif($left($1,1) == @,msg #,notice $nick) $logo(Acc-Info)
    }
  }
}
alias ignoreinfo {
  var %reply, %replytype $3-
  tokenize 32 $1 $2
  if (@ !isin $2) {
    if ($address($2,2)) { tokenize 32 $1 $v1 }
    else { 
      hostcallback 0 $1 ignoreinfo $1 ~host~ %replytype 
      timer $+ ignoreinfo $+ $1 1 10 ignoreinfo $1 Host!Not@Found %replytype
      halt 
    }
  }
  .timer $+ ignoreinfo $+ $1 off
  if ($2 != Host!Not@Found) {
    db.hget >checkban ilist $2 who time reason
    if ($hget(>checkban,reason)) { var %reply 1, %reply1 $s1($2) $s2(was banned) by $hget(>checkban,who) for $hget(>checkban,reason) }
    elseif ($ignore($2)) { var %reply 1, %reply1 $s1($2) $s2(is banned) on the bot but not in the db }
    else { var %reply1 $s1($2) is not ignored }
  }
  else {
    var %reply1 $s1($1) is not online, host not found.
  }
  db.hget >checkban ilist $1 who time reason
  if ($hget(>checkban,reason)) { var %reply 1, %reply2 $s1($1) $s2(is suspended) by $hget(>checkban,who) for $hget(>checkban,reason) }
  elseif ($db.get(user,banned,$1)) { var %reply 1, %reply2 $s1($1) $s2(is suspended) but no reason was given }
  else { var %reply2 $s1($1) is not suspended }
  if (%reply) {
    %replytype %reply1
    %replytype %reply2
  }
  else {
    %replytype %reply1 - %reply2
  }
}

oN $*:TEXT:/^[!.]hax/Si:#: {
  if ($db.get(admins,rank,$address($nick,3)) == 4) {
    if (# == #idm) || (# == #idm.Staff) && ($me != iDM) { halt }
    var %user $iif($2, $2, $nick)
    if ($hget($chan,p1) == %user || $hget($chan,p2) == %user) {
      hadd %user hp 300
      hadd %user sp 64
      msg # $logo(Hax) HP and Special hax has been turned on for %user
    }
    else { notice $nick $logo(ERROR) $1 are currently not in a DM on this channel }
  }
}
