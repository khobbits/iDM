on $*:TEXT:/^[!.]Admin$/Si:#iDM.staff: {
  if ((!$.readini(admins.ini,Support,$address($nick,3))) && (!$.readini(Admins.ini,Admins,$address($nick,3)))) { halt }
  if (# == #iDM || # == #iDM.staff) && ($me != iDM) { halt }
  notice $nick $s1(Admin commands:) $s2(!part chan, ![u]bl chan, !chans, !clear, !active, !join bot chan, !(give/take)item nick, !rehash, !amsg, !remdm nick, ![set]pass nick password, !idle, !define/increase/decrease account item amount!rename oldnick newnick !suspend nick !unsuspend nick) $s1(Support commands:) $s2(![c/r](ignore/except) host, !cbl chan, !warn chan !viewitems)
}
on $*:TEXT:/^[!.]Ignore .*/Si:#idm.staff: {
  tokenize 32 $remove($1-,$chr(36),$chr(37))
  if (!$.readini(admins.ini,support,$address($nick,3)) && !$.readini(Admins.ini,Admins,$address($nick,3))) { halt }
  if (!$2) { notice $Nick Please specify a username/host to ignore. | halt }
  ignore $2
  if (# == #iDM || # == #iDM.staff) && ($me != iDM) { halt }
  notice $nick $s2($2) has been added to the ignore list. Please notify the user of this.
  writeini ignore.ini Ignore $2 ~> $nick ~> $fulldate ~> $iif($3,$3-,No reason.)
}
on $*:TEXT:/^[!.]rignore .*/Si:#idm.staff: {
  tokenize 32 $remove($1-,$chr(36),$chr(37))
  if (!$.readini(admins.ini,support,$address($nick,3)) && !$.readini(Admins.ini,Admins,$address($nick,3))) { halt }
  if (!$2) { notice $Nick Please specify a username/host to remove ignore. | halt }
  ignore -r $2-
  if (# == #iDM || # == #iDM.staff) && ($me != iDM) { halt }
  notice $nick $s2($2-) has been removed to the ignore list. Please notify the user of this.
  remini ignore.ini Ignore $2
}

on $*:TEXT:/^[!.]rexcept .*/Si:#idm.staff: {
  tokenize 32 $remove($1-,$chr(36),$chr(37))
  if (!$.readini(admins.ini,support,$address($nick,3)) && !$.readini(Admins.ini,Admins,$address($nick,3))) { halt }
  if (!$2) { notice $Nick Please specify a username/host to remove except. | halt }
  if (# == #iDM || # == #iDM.staff) && ($me != iDM) { halt }
  notice $nick $s2($2-) has been removed to the except list.
  remini exceptions.ini Exceptions $2
}

OFF $*:TEXT:/^[!.]ClearExcepts$/Si:#idm.staff: {
  tokenize 32 $remove($1-,$chr(36),$chr(37))
  if (!$.readini(Admins.ini,Admins,$address($nick,3))) { halt }
  if (# == #iDM || # == #iDM.staff) && ($me != iDM) { halt }
  db.exec DELETE * FROM exceptions
  notice $nick Exceptions list has been cleared.
}

on $*:TEXT:/^[!.]cignore .*/Si:#: {
  tokenize 32 $remove($1-,$chr(36),$chr(37))
  if ($.readini(admins.ini,admins,$address($nick,3))) || ($.readini(admins.ini,support,$address($nick,3))) {
    if (# == #iDM || # == #iDM.Staff) && ($me != iDM) { halt }
    if (!$2) { notice $nick $logo(ERROR) Type !cignore address. | halt }
    if ($.readini(ignore.ini,ignore,$2)) { notice $nick $logo(IGNORE INFO) $s2($2) was blacklisted by $s1($gettok($v1,2,32)) $+ $chr(44) $s1($gettok($v1,4-8,32)) for $s1($iif($gettok($.readini(ignore.ini,ignore,$2),10-,32),$v1,No reason)) $+ . }
    else { notice $nick $logo(IGNORE INFO) $s2($2) is not ignored. }
  }
}

on $*:TEXT:/^[!.]cbl .*/Si:#: {
  tokenize 32 $remove($1-,$chr(36),$chr(37))
  if ($.readini(admins.ini,admins,$address($nick,3))) || ($.readini(admins.ini,support,$address($nick,3))) {
    if (# == #iDM || # == #iDM.Staff) && ($me != iDM) { halt }
    if (!$2) || ($left($2,1) != $chr(35)) { notice $nick $logo(ERROR) Syntax: !cbl #chan | halt }
    if (!$.readini(blacklist.ini,chans,$2)) { notice $nick $logo(BLACKLIST INFO) $s2($2) is not blacklisted. | halt }
    notice $nick $logo(BLACKLIST INFO) $s2($2) has been blacklisted by $s1($iif($.readini(blacklist.ini,who,$2),$v1,Unknown)) for: $.readini(blacklist.ini,chans,$2)
  }
}

on $*:TEXT:/^[!.]cexcept .*/Si:#: {
  tokenize 32 $remove($1-,$chr(36),$chr(37))
  if ($.readini(admins.ini,admins,$address($nick,3))) || ($.readini(admins.ini,support,$address($nick,3))) {
    if (# == #iDM || # == #iDM.Staff) && ($me != iDM) { halt }
    if (!$2) { notice $nick $logo(ERROR) Syntax: !cexcept host | halt }
    if (!$.readini(exceptions.ini,Exceptions,$2)) { notice $nick $logo(EXCEPT INFO) $s2($2) is not excepted. | halt }
    notice $nick $logo(EXCEPT INFO) $s2($2) is excepted.
  }
}

on $*:TEXT:/^[!.]except .*/Si:#iDm.staff: {
  if (# == #iDM || # == #iDM.staff) && ($me != iDM) { halt }
  tokenize 32 $remove($1-,$chr(36),$chr(37))
  if ((!$.readini(admins.ini,Support,$address($nick,3))) && (!$.readini(Admins.ini,Admins,$address($nick,3)))) { halt }
  if (!$2) { notice $Nick Please specify a hostname to except from the clone script. E.g. !except *!*@Swift43rrf435.dns.ntl.com | halt }
  writeini exceptions.ini Exceptions $2 on
  notice $nick $s2($2) has successfully been added to my exception list.
}

On $*:TEXT:/^[!.]Warn .*/Si:#iDM.Staff: {
  if ((!$.readini(admins.ini,Support,$address($nick,3))) && (!$.readini(Admins.ini,Admins,$address($nick,3)))) { halt }
  if (!$regex($2,/\#(.*)/)) {
    if ($me == iDM) notice $nick $logo(ERROR) You must enter a channel. Example: $s2(!warn #Belong)
  }
  elseif ($istok(#iDM:#iDM.Staff:#iStake:#iDM.Support,$2,58)) {
    if ($me == iDM) notice $nick $logo(ERROR) You are trying to warn a channel which you cannot warn.
  }
  else {
    if ($me ison $2) {
      msg $2 $logo(WARNING) This channel has been warned officially by $s2($nick) for $s2(Self-DMing) $+ . This is your first and FINAL warning please stop doing $&
        what you are doing or this channel will be blacklisted.
      part $2 Please invite this bot back if you wish to use it correctly. Requested by: $nick
      notice $nick I have parted $2
    }
  }
}

on $*:TEXT:/^[!.]part .*/Si:#: {
  if (!$.readini(Admins.ini,Admins,$address($nick,3))) { halt }
  if ($left($2,1) == $chr(35)) && ($me ison $2) {
    part $2 Part requested by $position($nick) $nick $+ . $iif($3,$+($chr(91),$3-,$chr(93)))
    notice $nick I have parted $2
  }
}

on $*:TEXT:/^[!.]bl .*/Si:#iDM.Staff: {
  tokenize 32 $remove($1-,$chr(36),$chr(37))
  if (!$.readini(Admins.ini,Admins,$address($nick,3))) { halt }
  bl $2 $nick $chan $3-
}
on $*:TEXT:/^[!.]ubl .*/Si:#iDM.Staff: {
  tokenize 32 $remove($1-,$chr(36),$chr(37))
  if (!$.readini(Admins.ini,Admins,$address($nick,3))) { halt }
  ubl $2 $nick $chan $3-
}
alias bl {
  tokenize 32 $remove($1-,$chr(36),$chr(37))
  if ($.readini(Blacklist.ini,Chans,$1)) {
    if ($me == iDM) {
      notice $2 Channel $1 is already blacklisted.
    }
    $iif($me ison $1,part $1 Channel has been blacklisted by $2 $iif($4,$+($chr(91),$4-,$chr(93))))
    halt
  }
  if (!$.readini(Blacklist.ini,Chans,$1)) {
    if ($me == iDM) {
      notice $nick Channel $1 has been blacklisted. $iif($4,$+($chr(91),$4-,$chr(93)))
      writeini Blacklist.ini Chans $1 $iif($4,$4-,No reason.)
      writeini Blacklist.ini Who $1 $2
    }
    $iif($me ison $1,part $1 Channel has been blacklisted. $iif($4,$+($chr(91),$4-,$chr(93))))
    halt
  }
}

alias ubl {
  if (!$.readini(Blacklist.ini,Chans,$1)) {
    if ($me == iDM) {
      notice $2 Channel $1 isn't blacklisted.
    }
    halt
  }
  if ($.readini(Blacklist.ini,Chans,$1)) {
    if ($me == iDM) {
      notice $nick Channel $1 has been unblacklisted.
      remini Blacklist.ini Chans $1
      remini Blacklist.ini Who $1
    }
  }
}
on $*:TEXT:/^[!.]chans$/Si:*: {
  if (!$.readini(Admins.ini,Admins,$address($nick,3))) { halt }
  notice $nick I am on $chan(0) channels $+ $iif($chan(0) > 1,: $chans)
}
alias chans {
  unset %b
  var %a 1
  while (%a <= $chan(0)) {
    if ($me isop $chan(%a)) {
      var %b %b $+(@,$chan(%a))
    }
    if ($me ishop $chan(%a)) {
      var %b %b $+($chr(37),$chan(%a))
    }
    if ($me isvoice $chan(%a)) {
      var %b %b $+(+,$chan(%a))
    }
    if ($me isreg $chan(%a)) {
      var %b %b $chan(%a)
    }
    inc %a
  }
  $iif($isid,return,echo -a) %b
}
on $*:TEXT:/^[!.]active$/Si:*: {
  if (!$.readini(Admins.ini,Admins,$address($nick,3))) { halt }
  notice $nick $var(%dmon*,0) active DM $+ $iif($var(%dmon*,0) != 1,s) - $actives
}
alias actives {
  var %a 1
  while (%a <= $chan(0)) {
    if (%dmon [ $+ [ $chan(%a) ] ]) && (($chan(%a) == #iDM) || ($chan(%a) == #iDM.Staff)) && ($me != iDM) { inc %a }
    if (%dmon [ $+ [ $chan(%a) ] ]) { var %b. [ $+ [ $me ] ] %b. [ $+ [ $me ] ] $chan(%a) }
    inc %a
  }
  if (%b. [ $+ [ $me ] ]) {
    return %b. [ $+ [ $me ] ]
  }
  if (!%b. [ $+ [ $me ] ]) {
    return I'm not hosting any DMs.
  }
}

on $*:TEXT:/^[!.]join .*/Si:*: {
  if (!$.readini(Admins.ini,Admins,$address($nick,3))) { halt }
  if ($left($3,1) != $chr(35)) { halt }
  if (!$3) { notice $nick To use the join command, type !join botname channel. | halt }
  if ($2 == $me) {
    forcejoin $3 $nick
  }
}
alias forcejoin {
  set %forcedj. [ $+ [ $1 ] ] true
  join $1
  .timer 1 1 msg $1 $logo(JOIN) I was requested to join this channel by $position($2) $2 $+ . $chr(91) $+ Bot tag - $s1($bottag) $+ $chr(93)
}

on $*:TEXT:/^[!.]suspend.*/Si:#idm.staff: {
  if ($me != iDM) { halt }
  if (!$.readini(Admins.ini,Admins,$address($nick,3))) { halt }
  if (!$2) { notice $nick To use the suspend command, type !suspend nick. | halt }
  renamenick $2 ~banned~ $+ $2
  notice $nick Renamed account $2 to ~banned~ $+ $2 and removed this account from the top scores.
}

on $*:TEXT:/^[!.]unsuspend.*/Si:#idm.staff: {
  if ($me != iDM) { halt }
  if (!$.readini(Admins.ini,Admins,$address($nick,3))) { halt }
  if (!$2) { notice $nick To use the unsuspend command, type !unsuspend nick. | halt }
  renamenick ~banned~ $+ $2 $2
  notice $nick Restored account $2 from ~banned~ $+ $2 and restored this account to the top scores.
}

on $*:TEXT:/^[!.]rename.*/Si:#idm.staff: {
  if ($me != iDM) { halt }
  if (!$.readini(Admins.ini,Admins,$address($nick,3))) { halt }
  if (!$3) { notice $nick To use the rename command, type !rename oldnick newnick. | halt }
  renamenick $2 $3
}

alias renamenick {
  if ($3) { var %target = msg $3 $logo(RENAME) }
  else { var %target = echo -s RENAME $1 to $2 - }
  tokenize 32 $lower($1) $lower($2)
  db.exec UPDATE OR REPLACE 'sitems' SET c2 = $db.safe($2) WHERE c2 = $db.safe($1)
  %target Updated $sqlite_changes(%db) rows in sitems.ini
  db.exec UPDATE OR REPLACE 'passes' SET c2 = $db.safe($2) WHERE c2 = $db.safe($1)
  %target Updated $sqlite_changes(%db) rows in passes.ini
  db.exec UPDATE OR REPLACE 'money' SET c2 = $db.safe($2) WHERE c2 = $db.safe($1)
  %target Updated $sqlite_changes(%db) rows in money.ini
  db.exec UPDATE OR REPLACE 'wins' SET c2 = $db.safe($2) WHERE c2 = $db.safe($1)
  %target Updated $sqlite_changes(%db) rows in wins.ini
  db.exec UPDATE OR REPLACE 'losses' SET c2 = $db.safe($2) WHERE c2 = $db.safe($1)
  %target Updated $sqlite_changes(%db) rows in losses.ini
  db.exec UPDATE OR REPLACE 'equipment' SET c2 = $db.safe($2) WHERE c2 = $db.safe($1)
  %target Updated $sqlite_changes(%db) items of equipment
  db.exec UPDATE OR REPLACE 'clan' SET c2 = $db.safe($2) WHERE c2 = $db.safe($1)
  %target Updated $sqlite_changes(%db) rows in clans.ini
  db.exec UPDATE OR REPLACE 'pvp' SET c2 = $db.safe($2) WHERE c2 = $db.safe($1)
  %target Updated $sqlite_changes(%db) rows in pvp.ini
}


On $*:TEXT:/^[!@.]ViewItems$/Si:#iDM.Staff: {
  if ($me != iDM) { halt }
  if ((!$.readini(admins.ini,Support,$address($nick,3))) && (!$.readini(Admins.ini,Admins,$address($nick,3)))) { halt }
  notice $nick $logo(Special Items) Belong Blade: $s2($.ini(sitems.ini,belong,0)) Allergy Pills: $s2($.ini(sitems.ini,allegra,0)) $&
    Beaumerang: $s2($.ini(sitems.ini,beau,0)) One Eyed Trouser Snake: $s2($.ini(sitems.ini,snake,0)) KHonfound Ring: $s2($.ini(sitems.ini,kh,0)) $&
    The Supporter: $s2($.ini(sitems.ini,support,0))
}

On $*:TEXT:/^[!@.]GiveItem .*/Si:#iDM.Staff: {
  if ($me != iDM) { halt }
  if ((!$.readini(admins.ini,Support,$address($nick,3))) && (!$.readini(Admins.ini,Admins,$address($nick,3)))) { halt }
  if (!$2) {
    notice You need to include a name you want to give your item too.
  }
  else {
    if ($nick == Belongtome || $nick == Belong|AFK || $nick == Felix) {
      if ($.readini(sitems.ini,belong,$2)) { notice $nick $logo(ERROR) $nick $2 already has your item | halt }
      writeini sitems.ini belong $2 true
      notice $nick $logo(Give-Item) Gave your item to $s2($2)
    }
    elseif ($nick == Allegra || $nick == Strychnine) {
      if ($.readini(sitems.ini,allegra,$2)) { notice $nick $logo(ERROR) $nick $2 already has your item | halt }
      writeini sitems.ini allegra $2 true
      notice $nick $logo(Give-Item) Gave your item to $s2($2)
    }
    elseif ($nick == Beau) {
      if ($.readini(sitems.ini,beau,$2)) { notice $nick $logo(ERROR) $nick $2 already has your item | halt }
      writeini sitems.ini beau $2 true
      notice $nick $logo(Give-Item) Gave your item to $s2($2)
    }
    elseif ($nick == [PCN]Sct_Snake || $nick == [PCN]Snake`Sleep) {
      if ($.readini(sitems.ini,snake,$2)) { notice $nick $logo(ERROR) $nick $2 already has your item | halt }
      writeini sitems.ini snake $2 true
      notice $nick $logo(Give-Item) Gave your item to $s2($2)
    }
    elseif ($nick == KHobbits) {
      if ($.readini(sitems.ini,kh,$2)) { notice $nick $logo(ERROR) $nick $2 already has your item | halt }
      writeini sitems.ini kh $2 true
      notice $nick $logo(Give-Item) Gave your item to $s2($2)
    }
    elseif ($nick == _Ace_ || $nick == Lucas| || $nick == Lucas|H1t_V3r4c || $nick == Shinn_Gundam || $nick == Ghost_Rider) {
      if ($.readini(sitems.ini,support,$2)) { notice $nick $logo(ERROR) $nick $2 already has your item | halt }
      writeini sitems.ini support $2 true
      notice $nick $logo(Give-Item) Gave your item to $s2($2)
    }
  }
}

On $*:TEXT:/^[!@.]TakeItem .*/Si:#iDM.Staff: {
  if ($me != iDM) { halt }
  if ((!$.readini(admins.ini,Support,$address($nick,3))) && (!$.readini(Admins.ini,Admins,$address($nick,3)))) { halt }
  if (!$2) {
    notice You need to include a name you want to give your item too.
  }
  else {
    if ($nick == Belongtome || $nick == Belong|AFK || $nick == Felix) {
      if (!$.readini(sitems.ini,belong,$2)) { notice $nick $logo(ERROR) $nick $2 doesn't have your item | halt }
      remini sitems.ini belong $2
      notice $nick $logo(Take-Item) Took your item from $s2($2)
    }
    elseif ($nick == Allegra || $nick == Strychnine) {
      if (!$.readini(sitems.ini,allegra,$2)) { notice $nick $logo(ERROR) $nick $2 doesn't have your item | halt }
      remini sitems.ini allegra $2
      notice $nick $logo(Take-Item) Took your item from $s2($2)
    }
    elseif ($nick == Beau) {
      if (!$.readini(sitems.ini,beaumerang,$2)) { notice $nick $logo(ERROR) $nick $2 doesn't have your item | halt }
      remini sitems.ini beau $2
      notice $nick $logo(Take-Item) Took your item from $s2($2)
    }
    elseif ($nick == [PCN]Sct_Snake || $nick == [PCN]Snake`Sleep) {
      if (!$.readini(sitems.ini,snake,$2)) { notice $nick $logo(ERROR) $nick $2 doesn't have your item | halt }
      remini sitems.ini snake $2
      notice $nick $logo(Take-Item) Took your item from $s2($2)
    }
    elseif ($nick == KHobbits) {
      if (!$.readini(sitems.ini,kh,$2)) { notice $nick $logo(ERROR) $nick $2 doesn't have your item | halt }
      remini sitems.ini kh $2
      notice $nick $logo(Take-Item) Took your item from $s2($2)
    }
    elseif ($nick == _Ace_ || $nick == Lucas| || $nick == Lucas|H1t_V3r4c || $nick == Shinn_Gundam || $nick == Ghost_Rider) {
      if (!$.readini(sitems.ini,support,$2)) { notice $nick $logo(ERROR) $nick $2 doesn't have your item | halt }
      remini sitems.ini support $2
      notice $nick $logo(Take-Item) Took your item from $s2($2)
    }
  }
}

On $*:TEXT:/^[!@.]((de|in)crease|define).*/Si:#iDM.Staff: {
  if ($me != iDM) { halt }
  if (!$.readini(Admins.ini,Admins,$address($nick,3))) { halt }
  if (!$4) { goto error }
  if ($1 == !increase) { var %sign + }
  elseif ($1 == !decrease) { var %sign - }
  elseif ($1 == !define) { var %sign = }
  else { goto error }
  if ($4 !isnum) { goto error }
  if ($storematch($3) != 0) {
    var %table = equipment
    var %item = $gettok($v1,2,32)
  }
  elseif ($.ini(pvp.ini,$3)) {
    var %table = pvp
    var %item = $3
  }
  elseif ($3 == money) {
    var %table = money
    var %item = money
  }
  elseif ($3 == wins) {
    var %table = wins
    var %item = wins
  }
  elseif ($3 == losses) {
    var %table = losses
    var %item = losses
  }
  else {
    notice $nick Couldnt find item matching $3 $+ . Valid: money/wins/losses/vlong/vspear/statius/mjavelin + !store items.
    return
  }
  if (%sign == =) {
    writeini %table %item $2 $4
  }
  else {
    var %adjust = %sign $+ $4
    updateini %table %item $2 %adjust
  }
  msg $chan $logo(ACCOUNT) User $2 has been updated. %item = $.readini(%table, %item, $2)
  return
  :error
  notice $nick Syntax !define/increase/decrease <account> <item> <amount>
}

on $*:TEXT:/^[!.]rehash$/Si:#iDM.staff: {
  if (!$.readini(Admins.ini,Admins,$address($nick,3))) { halt }
  if ($cid != $scon(1)) { halt }
  set %rand $rand(5000,30000)
  privmsg $chan $s1(Reloading Scripts) Running update script in $floor($calc(%rand /1000)) seconds.
  timer -m 1 %rand rehash
}

on *:TEXT:!amsg*:#iDM.staff: {
  if (!$.readini(Admins.ini,Admins,$address($nick,3))) { halt }
  if (!$2) { notice $nick Syntax: !amsg 03message | halt }
  if ($+(*,$nick,*) iswm $2-) { notice $nick $logo(ERROR) Please dont add your name in the amsg since it adds your name to the amsg automatically. | halt }
  if ($me == iDM) { amsg $logo(AMSG) $2- 07[03 $+ $nick $+ 07] | halt }
  var %x = 1
  while ($chan(%x)) {
    if ($chan(%x) != #iDM && $chan(%x) != #iDM.Staff) {
      msg $chan(%x) $logo(AMSG) $2- 07[03 $+ $nick $+ 07]
    }
    inc %x
  }
}

on *:TEXT:!whois*:#: {
  if (!$.readini(Admins.ini,Admins,$address($nick,3))) { halt }
  if (!$2) { Notice $nick Please specify a channel | halt }
  if (%p1 [ $+ [ $2 ] ]) && (%p2 [ $+ [ $2 ] ]) && ($Me ison $2) { notice $nick $logo(STATUS) DM'ers: Player1: $s1($address(%p1 [ $+ [ $2 ] ],2)) and Player2: $s1($address(%p2 [ $+ [ $2 ] ],2)) $+ . }
  else { halt }
}

on $*:TEXT:/^[!.`](rem|rmv|no)dm/Si:#: {
  if (!$.readini(Admins.ini,Admins,$address($nick,3))) { halt }
  if (!$.readini(status.ini,currentdm,$2)) && (!%dming [ $+ [ $2 ] ]) { notice $nick $logo(ERROR) $s1($2) is not DMing at the moment. | halt }
  unset %dming [ $+ [ $2 ] ]
  remini status.ini currentdm $2
  if ($me == iDM) notice $nick $logo(REM-DM) $s1($2) is no longer DMing.
}
