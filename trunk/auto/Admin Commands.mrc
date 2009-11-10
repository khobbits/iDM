on $*:TEXT:/^[!.]admin$/Si:#idm.staff: {
  if ($db.get(admins,position,$address($nick,3)) && $me == iDM) {
    notice $nick $s1(Admin commands:) $s2(!part chan, !chans, !clear, !active, !join bot chan, !(give/take)item nick, !rehash, !amsg, $&
      !(show/rem)dm nick, ![set]pass nick password, !idle, !define/increase/decrease account item amount!rename oldnick newnick !suspend nick $&
      !unsuspend nick) $s1(Support commands:) $s2(![c/r](ignore) host, ![c/r]cbl chan, !warn chan !viewitems)
  }
}

on $*:TEXT:/^[!.]Bot-ON$/Si:#idm.staff: {
  if ($db.get(admins,position,$address($nick,3))) {
    if ($me == iDM[OFF]) { nick iDM }
  }
}

on $*:TEXT:/^[!.]addsupport .*/Si:#idm.staff: {
  tokenize 32 $remove($1-,$chr(36),$chr(37))
  if ($db.get(admins,position,$address($nick,3)) == admins && $me == iDM) {
    if (!$address($2,3)) { notice $nick Sorry but i couldnt find the host of $2.  Syntax: !addsupport <nick> | halt }
    msg $chan $s2($2) has been added to the support staff list with $address($2,3)
    db.set admins support $address($2,3) true
  }
}

on $*:TEXT:/^[!.](r|c)?(i(gnore|list)|bl(ist)?) .*/Si:#idm.staff,#idm.support: {
  tokenize 32 $remove($1-,$chr(36),$chr(37))
  if (!$db.get(admins,position,$address($nick,3))) {
    if (?c* !iswm $1 || $nick isreg $chan || $nick !ison $chan) {
      halt
    }
  }
  if (ignore isin $1 || ilist isin $1) {
    var %table ilist
    if (?i* iswm $1) {
      if ((@ isin $2 && *!* !isin $2) || (!$3)) { 
        if ($me == iDM) notice $nick Syntax !ignore (nick) (reason) - Use !suspend to disable an account.
        halt 
      }
      ignore $2 2
    } 
    else {      
      if (@ !isin $2) tokenize 32 $1 $address($2,2) ( $+ $2 $+ ) $3-
      if (?r* iswm $1) ignore -r $2 
    }
  }
  elseif (bl isin $1) {
    var %table blist
    if (?bl* iswm $1) {
      if ((#* !iswm $2) || (!$3)) { 
        if ($me == iDM) notice $nick Syntax !bl (channel) (reason)
        halt 
      }
      if ($chan($2).status) {
        part $2 This channel has been blacklisted
      }
    }
  }
  if ($me == iDM) {
    if (!$2) { notice $nick Syntax !(c|r)(ignore|bl) (channel|username|host) | halt }
    if (?c* iswm $1) {
      db.hget checkban %table $2 who time reason
      var %who $hget(checkban,who)
      var %time $hget(checkban,time)
      var %reason $hget(checkban,reason)
      if (%reason) {
        notice $nick $logo(BANNED) Admin $s2(%who) banned $s2($2) at $s2(%time) for $s2(%reason)
      }
      else {
        notice $nick $logo(BANNED) User $s2($2) is $s2(not) banned.
      }
    }
    elseif (?r* iswm $1) {
      db.remove %table $2
      notice $nick $2 removed from %table
    }
    else {
      db.set %table who $2 $nick
      db.set %table reason $2 $3-
      notice $nick $2 added to %table
    }
  }
}

on $*:TEXT:/^[!.]part .*/Si:#: {
  if ($db.get(admins,position,$address($nick,3)) == admins) {
    if ($left($2,1) == $chr(35)) && ($me ison $2) {
      part $2 Part requested by $position($nick) $nick $+ . $iif($3,$+($chr(91),$3-,$chr(93)))
      notice $nick I have parted $2
    }
  }
}

on $*:TEXT:/^[!.]chans$/Si:#idm.staff,#idm.support: {
  if ($db.get(admins,position,$address($nick,3)) == admins) {
    notice $nick I am on $chan(0) channels $+ $iif($chan(0) > 1,: $chans)
  }
}

alias chans {
  unset %b
  var %a 1
  while (%a <= $chan(0)) {
    if ($me isop $chan(%a)) var %b %b $+(@,$chan(%a))
    if ($me ishop $chan(%a)) var %b %b $+($chr(37),$chan(%a))
    if ($me isvoice $chan(%a)) var %b %b $+(+,$chan(%a))
    if ($me isreg $chan(%a)) var %b %b $chan(%a)
    inc %a
  }
  $iif($isid,return,echo -a) %b
}

on $*:TEXT:/^[!.]active$/Si:*: {
  if ($db.get(admins,position,$address($nick,3)) == admins) {
    notice $nick $var(%dmon*,0) active DM $+ $iif($var(%dmon*,0) != 1,s) - $actives
  }
}

alias actives {
  var %a 1
  while (%a <= $chan(0)) {
    if (%dmon [ $+ [ $chan(%a) ] ]) && (($chan(%a) == #idm) || ($chan(%a) == #idm.Staff)) && ($me != iDM) { inc %a }
    if (%dmon [ $+ [ $chan(%a) ] ]) { var %b. [ $+ [ $me ] ] %b. [ $+ [ $me ] ] $chan(%a) }
    inc %a
  }
  if (%b. [ $+ [ $me ] ]) { return %b. [ $+ [ $me ] ] }
  if (!%b. [ $+ [ $me ] ]) { return I'm not hosting any DMs. }
}

on $*:TEXT:/^[!.]join .*/Si:*: {
  if ($db.get(admins,position,$address($nick,3)) == admins) {
    if ($left($3,1) != $chr(35)) { halt }
    if (!$3) { notice $nick To use the join command, type !join botname channel. | halt }
    if ($2 == $me) { 
      set %forcedj. [ $+ [ $3 ] ] true
      join $3
      .timer 1 1 msg $3 $logo(JOIN) I was requested to join this channel by $position($nick) $nick $+ . $chr(91) $+ Bot tag - $s1($bottag) $+ $chr(93)
    }
  }
}

on $*:TEXT:/^[!.](un)?suspend.*/Si:#idm.staff,#idm.support: {
  if ($me != iDM) { return }
  if ($db.get(admins,position,$address($nick,3)) == admins) {
    if (!$2) { notice $nick To use the unsuspend command, type !(un)suspend nick. | halt }
    if (?un* iswm $1) {
      if ($suspendnick($2,0,$nick)) { notice $nick Restored account $2 to its original status. }
      else { notice $nick Couldn't find account $2 }
    }
    else {
      if ($suspendnick($2,1,$nick)) { notice $nick Removed account $2 from the top scores. }
      else { notice $nick Couldn't find account $2 }
    }
  }
}

on $*:TEXT:/^[!.]rename.*/Si:#idm.staff: {
  if ($me != iDM) { return }
  if ($db.get(admins,position,$address($nick,3)) == admins) {
    if (!$3) { notice $nick To use the rename command, type !rename oldnick newnick. | halt }
    if ($renamenick($2,$3,$nick)) { notice $nick Renamed account $2 to $3 }
    else { notice $nick Renaming account $2 failed as $3 already exists (if this is an error you could try using !delete on one of the accounts)  }
  }
}

on $*:TEXT:/^[!.]delete.*/Si:#idm.staff: {
  if ($me != iDM) { return }
  if ($db.get(admins,position,$address($nick,3)) == admins) {
    if (!$2) { notice $nick To use the delete command, type !delete nick | halt }
    if ($3 != $md5($2)) { notice $nick To confirm deletion type !delete $2 $md5($2) | halt }
    if ($deletenick($2,$nick)) { notice $nick Deleted account $2 }
    else { notice $nick Couldn't find account $2 }
  }
}

alias renamenick {
  if ($3) { var %target = notice $3 $logo(RENAME) }
  else { var %target = echo -s RENAME $1 to $2 - }
  db.exec UPDATE `user` SET user = $db.safe($2) WHERE user = $db.safe($1)
  if ($mysql_affected_rows(%db) === -1) { return 0 }
  var %target = %target Updated Rows: $mysql_affected_rows(%db) user;
  db.exec UPDATE `equip_item` SET user = $db.safe($2) WHERE user = $db.safe($1)
  var %target = %target $mysql_affected_rows(%db) equip_item;
  db.exec UPDATE `equip_pvp` SET user = $db.safe($2) WHERE user = $db.safe($1)
  var %target = %target $mysql_affected_rows(%db) equip_pvp;
  db.exec UPDATE `equip_armour` SET user = $db.safe($2) WHERE user = $db.safe($1)
  var %target = %target $mysql_affected_rows(%db) equip_armour;
  db.exec UPDATE `equip_staff` SET user = $db.safe($2) WHERE user = $db.safe($1)
  var %target = %target $mysql_affected_rows(%db) equip_staff;
  db.exec UPDATE `clan` SET c2 = $db.safe($2) WHERE c2 = $db.safe($1)
  %target $mysql_affected_rows(%db) clans.
  return 1
}

alias suspendnick {
  db.exec UPDATE `user` SET banned = $db.safe($2) WHERE user = $db.safe($1)
  if ($mysql_affected_rows(%db) === -1) { return 0 }
  return 1
}

alias deletenick {
  if ($len($1) < 1) { return }
  if ($2) { var %target = notice $2 $logo(DELETE) }
  else { var %target = echo -s DELETE $1 - }
  db.exec DELETE FROM `user` WHERE user = $db.safe($1)
  if ($mysql_affected_rows(%db) === -1) { return 0 }
  var %target = %target Deleted Rows: $mysql_affected_rows(%db) user;
  db.exec DELETE FROM `equip_item` WHERE user = $db.safe($1)
  var %target = %target $mysql_affected_rows(%db) equip_item;
  db.exec DELETE FROM `equip_pvp` WHERE user = $db.safe($1)
  var %target = %target $mysql_affected_rows(%db) equip_pvp;
  db.exec DELETE FROM `equip_armour` WHERE user = $db.safe($1)
  var %target = %target $mysql_affected_rows(%db) equip_armour;
  db.exec DELETE FROM `equip_staff` WHERE user = $db.safe($1)
  var %target = %target $mysql_affected_rows(%db) equip_staff;
  db.exec DELETE FROM `clan` WHERE c2 = $db.safe($1)
  %target $mysql_affected_rows(%db) clans.
  return 1
}

on $*:TEXT:/^[!@.]ViewItems$/Si:#idm.Staff,#idm.support: {
  if ($db.get(admins,position,$address($nick,3)) && $me == iDM) {
    var %sql SELECT sum(belong) as belong,sum(allegra) as allegra,sum(beau) as beau,sum(snake) as snake,sum(kh) as kh,sum(if(support = '0',0,1)) as support FROM `equip_staff`
    var %result = $db.query(%sql)
    if ($db.query_row(%result,equip) === $null) { echo -s Error fetching Staff items totals. - %sql }
    db.query_end %result
    notice $nick $logo(Special Items) Belong Blade: $s2($hget(equip,belong)) Allergy Pills: $s2($hget(equip,allegra)) $&
      Beaumerang: $s2($hget(equip,beau)) One Eyed Trouser Snake: $s2($hget(equip,snake)) KHonfound Ring: $s2($hget(equip,kh)) $&
      The Supporter: $s2($hget(equip,support))
  }
}

on $*:TEXT:/^[!@.]GiveItem .*/Si:#idm.Staff,#idm.support: {
  if ($db.get(admins,position,$address($nick,3)) && $me == iDM) {
    if (!$2) { notice You need to include a name you want to give your item too. }
    else {
      if ($nick == Belongtome || $nick == Belong|AFK || $nick == Felix) {
        if ($db.get(equip_staff,belong,$2) == 1) { notice $nick $logo(ERROR) $nick $2 already has your item | halt }
        db.set equip_staff belong $2 1
      }
      elseif ($nick == Allegra || $nick == Strychnine) {
        if ($db.get(equip_staff,allegra,$2) == 1) { notice $nick $logo(ERROR) $nick $2 already has your item | halt }
        db.set equip_staff allegra $2 1
      }
      elseif ($nick == Beau) {
        if ($db.get(equip_staff,beau,$2) == 1) { notice $nick $logo(ERROR) $nick $2 already has your item | halt }
        db.set equip_staff beau $2 1
      }
      elseif ($nick == [PCN]Sct_Snake || $nick == [PCN]Snake`Sleep) {
        if ($db.get(equip_staff,snake,$2) == 1) { notice $nick $logo(ERROR) $nick $2 already has your item | halt }
        db.set equip_staff snake $2 1
      }
      elseif ($nick == KHobbits) {
        if ($db.get(equip_staff,kh,$2) == 1) { notice $nick $logo(ERROR) $nick $2 already has your item | halt }
        db.set equip_staff kh $2 1
      }
      elseif ($nick == _Ace_ || $nick == Lucas| || $nick == Lucas|H1t_V3r4c || $nick == Shinn_Gundam || $nick == Ghost_Rider) {
        if ($db.get(equip_staff,support,$2) == 1) { notice $nick $logo(ERROR) $nick $2 already has your item | halt }
        db.set equip_staff support $2 $nick
      }
      else { return }
      notice $nick $logo(Give-Item) Gave your item to $s2($2)
    }
  }
}

On $*:TEXT:/^[!@.]TakeItem .*/Si:#idm.Staff,#idm.support: {
  if ($db.get(admins,position,$address($nick,3)) && $me == iDM) {
    if (!$2) { notice You need to include a name you want to give your item too. }
    else {
      if ($nick == Belongtome || $nick == Belong|AFK || $nick == Felix) {
        if ($db.get(equip_staff,belong,$2) == 0) { notice $nick $logo(ERROR) $nick $2 doesn't have your item | halt }
        db.set equip_staff belong $2 0
      }
      elseif ($nick == Allegra || $nick == Strychnine) {
        if ($db.get(equip_staff,allegra,$2) == 0) { notice $nick $logo(ERROR) $nick $2 doesn't have your item | halt }
        db.set equip_staff allegra $2 0
      }
      elseif ($nick == Beau) {
        if ($db.get(equip_staff,beaumerang,$2) == 0) { notice $nick $logo(ERROR) $nick $2 doesn't have your item | halt }
        db.set equip_staff beau $2 0
      }
      elseif ($nick == [PCN]Sct_Snake || $nick == [PCN]Snake`Sleep) {
        if ($db.get(equip_staff,snake,$2) == 0) { notice $nick $logo(ERROR) $nick $2 doesn't have your item | halt }
        db.set equip_staff snake $2 0
      }
      elseif ($nick == KHobbits) {
        if ($db.get(equip_staff,kh,$2) == 0) { notice $nick $logo(ERROR) $nick $2 doesn't have your item | halt }
        db.set equip_staff kh $2 0
      }
      elseif ($nick == _Ace_ || $nick == Lucas| || $nick == Lucas|H1t_V3r4c || $nick == Shinn_Gundam || $nick == Ghost_Rider) {
        if ($db.get(equip_staff,support,$2) == 0) { notice $nick $logo(ERROR) $nick $2 doesn't have your item | halt }
        db.set equip_staff support $2 0
      }
      else { return }
      notice $nick $logo(Take-Item) Took your item from $s2($2)
    }
  }
}

On $*:TEXT:/^[!@.]((de|in)crease|define).*/Si:#idm.Staff: {
  if ($db.get(admins,position,$address($nick,3)) == admins && $me == iDM) {
    if (!$4) { goto error }
    if ($1 == !increase) { var %sign + }
    elseif ($1 == !decrease) { var %sign - }
    elseif ($1 == !define) { var %sign = }
    else { goto error }
    if ($4 !isnum) { goto error }
    if ($storematch($3) != 0) {
      var %table = $gettok($v1,3,32)
      var %item = $gettok($v1,2,32)
    }
    elseif ($ispvp($3)) {
      var %table = equip_pvp
      var %item = $3
    }
    elseif ($3 == money) {
      var %table = user
      var %item = money
    }
    elseif ($3 == wins) {
      var %table = user
      var %item = wins
    }
    elseif ($3 == losses) {
      var %table = user
      var %item = losses
    }
    else { notice $nick Couldnt find item matching $3 $+ . Valid: money/wins/losses/vlong/vspear/statius/mjavelin + !store items. | halt }
    if (%sign == =) { db.set %table %item $2 $4 }
    else { db.set %table %item $2 %sign $4 }
    msg $chan $logo(ACCOUNT) User $2 has been updated. %item = $db.get(%table, %item, $2)
    return
    :error
    notice $nick Syntax !define/increase/decrease <account> <item> <amount>
  }
}

on $*:TEXT:/^[!.]rehash$/Si:#idm.staff: {
  if ($db.get(admins,position,$address($nick,3)) == admins) {
    if ($cid != $scon(1)) { halt }
    var %rand $rand(5000,120000)
    privmsg $chan $s1(Reloading Scripts) Running update script in $floor($calc(%rand /1000)) seconds.
    timer -m 1 %rand rehash
  }
}

on *:TEXT:!amsg*:#idm.staff: {
  if ($db.get(admins,position,$address($nick,3)) == admins) {
    if (!$2) { notice $nick Syntax: !amsg 03message | halt }
    if ($+(*,$nick,*) iswm $2-) { notice $nick $logo(ERROR) Please dont add your name in the amsg since it adds your name to the amsg automatically. | halt }
    if ($me == iDM) { amsg $logo(AMSG) $2- 07[03 $+ $nick $+ 07] | halt }
    var %x = 1
    while ($chan(%x)) {
      if ($chan(%x) != #idm && $chan(%x) != #idm.Staff) {
        msg $chan(%x) $logo(AMSG) $2- 07[03 $+ $nick $+ 07]
      }
      inc %x
    }
  }
}

on *:TEXT:!whois*:#: {
  if ($db.get(admins,position,$address($nick,3)) == admins) {
    if (!$2) { Notice $nick Please specify a channel | halt }
    if (%p1 [ $+ [ $2 ] ]) && (%p2 [ $+ [ $2 ] ]) && ($Me ison $2) { notice $nick $logo(STATUS) DM'ers: Player1: $s1($address(%p1 [ $+ [ $2 ] ],2)) and Player2: $s1($address(%p2 [ $+ [ $2 ] ],2)) $+ . }
    else { halt }
  }
}

on $*:TEXT:/^[!.`](rem|rmv|no)dm/Si:#: {
  if ($db.get(admins,position,$address($nick,3))) {
    if (!$db.get(user,indm,$2)) && (!%dming [ $+ [ $2 ] ]) { notice $nick $logo(ERROR) $s1($2) is not DMing at the moment. | halt }
    unset %dming [ $+ [ $2 ] ]
    db.set user indm $2 0
    notice $nick $logo(REM-DM) $s1($2) is no longer DMing.
  }
}

on $*:TEXT:/^[!.`](show|say)dm/Si:#: {
  if ($db.get(admins,position,$address($nick,3))) {
    notice $nick $logo(Show DM) $s1($2) is $iif(%dming [ $+ [ $2 ] ],3currently,not) DMing on $me at the moment according to var.
    if ($me == iDM) { notice $nick $logo(Show DM) $s1($2) is $iif($db.get(user,indm,$2),3currently,not) DMing at the moment according to ini. }
  }
}

on $*:TEXT:/^[!@.]Info .*/Si:#idm.Staff,#idm.Support: {
  if ($db.get(admins,position,$address($nick,3)) == admins && $me == iDM) {
    $iif($left($1,1) == @,msg #,notice $nick) $logo(Acc-Info) User: $s2($2) Money: $s2($iif($db.get(user,money,$2),$price($v1),0)) W/L: $s2($iif($db.get(user,wins,$2),$bytes($v1,db),0)) $+ / $+ $s2($iif($db.get(user,losses,$2),$bytes($v1,db),0)) Registered?: $iif($db.get(user,pass,$2),9YES,4NO) Logged-In?: $iif($db.get(user,login,$2),9YES,4NO)
  }
}
