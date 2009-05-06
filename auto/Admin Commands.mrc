On $*:TEXT:/^[!.]Warn .*/Si:#iDM.Staff: {
  if ($readini(Admins.ini,Admins,$address($nick,3))) {
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
}



On $*:TEXT:/^[!@]ViewItems$/Si:#iDM.Staff: {
  if ($me != iDM) { halt }
  if (!$readini(Admins.ini,Admins,$nick)) && (!$readini(Admins.ini,Admins,$address($nick,3))) { halt }
  if (!$2) {
    notice $nick $logo(Special Items) Belong Blade: $s2($ini(sitems.ini,belong,0)) Strychnine Scimitar: $s2($ini(sitems.ini,allegra,0)) Beaumerang: $s2($ini(sitems.ini,beau,0)) One Eyed Trouser Snake: $s2($ini(sitems.ini,snake,0))
    ;notice $nick $logo(Special Items) To view all who owns an item type !viewitems admin name.
  }
}



On $*:TEXT:/^[!@]GiveItem .*/Si:#iDM.Staff: {
  if ($me != iDM) { halt }
  if (!$readini(Admins.ini,Admins,$nick)) && (!$readini(Admins.ini,Admins,$address($nick,3))) { halt }
  if (!$2) { 
    notice You need to include a name you want to give your item too.
  }
  else {
    if ($nick == Belongtome || $nick == Belong|AFK) {
      if ($readini(sitems.ini,belong,$2)) { notice $logo(ERROR) $nick $2 already has your item | halt } 
      writeini sitems.ini belong $2 true 
      notice $nick $logo(Give-Item) Gave your item to $s2($2)
    }
    elseif ($nick == Allegra || $nick == Strychnine) { 
      if ($readini(sitems.ini,allegra,$2)) { notice $logo(ERROR) $nick $2 already has your item | halt } 
      writeini sitems.ini allegra $2 true 
      notice $nick $logo(Give-Item) Gave your item to $s2($2)
    }
    elseif ($nick == Beau) { 
      if ($readini(sitems.ini,beau,$2)) { notice $logo(ERROR) $nick $2 already has your item | halt } 
      writeini sitems.ini beau $2 true 
      notice $nick $logo(Give-Item) Gave your item to $s2($2)
    }
    elseif ($nick == [PCN]Sct_Snake || $nick == [PCN]Snake`Sleep) { 
      if ($readini(sitems.ini,snake,$2)) { notice $logo(ERROR) $nick $2 already has your item | halt } 
      writeini sitems.ini snake $2 true 
      notice $nick $logo(Give-Item) Gave your item to $s2($2)
    }
    elseif ($nick == KHobbits) { 
      if ($readini(sitems.ini,kh,$2)) { notice $logo(ERROR) $nick $2 already has your item | halt } 
      writeini sitems.ini kh $2 true 
      notice $nick $logo(Give-Item) Gave your item to $s2($2)
    }
  }
}

On $*:TEXT:/^[!@]TakeItem .*/Si:#iDM.Staff: {
  if ($me != iDM) { halt }
  if (!$readini(Admins.ini,Admins,$nick)) && (!$readini(Admins.ini,Admins,$address($nick,3))) { halt }
  if (!$2) { 
    notice You need to include a name you want to give your item too.
  }
  else {
    if ($nick == Belongtome || $nick == Belong|AFK) { 
      if (!$readini(sitems.ini,belong,$2)) { notice $logo(ERROR) $nick $2 doesn't have your item | halt } 
      remini sitems.ini belong $2
      notice $nick $logo(Take-Item) Took your item from $s2($2)
    }
    elseif ($nick == Allegra || $nick == Strychnine) { 
      if (!$readini(sitems.ini,allegra,$2)) { notice $logo(ERROR) $nick $2 doesn't have your item | halt } 
      remini sitems.ini allegra $2
      notice $nick $logo(Take-Item) Took your item from $s2($2)
    }
    elseif ($nick == Beau) { 
      if (!$readini(sitems.ini,beaumerang,$2)) { notice $logo(ERROR) $nick $2 doesn't have your item | halt } 
      remini sitems.ini beau $2
      notice $nick $logo(Take-Item) Took your item from $s2($2)
    }
    elseif ($nick == [PCN]Sct_Snake || $nick == [PCN]Snake`Sleep) { 
      if (!$readini(sitems.ini,snake,$2)) { notice $logo(ERROR) $nick $2 doesn't have your item | halt } 
      remini sitems.ini snake $2 
      notice $nick $logo(Take-Item) Took your item from $s2($2)
    }
    elseif ($nick == KHobbits) { 
      if (!$readini(sitems.ini,kh,$2)) { notice $logo(ERROR) $nick $2 doesn't have your item | halt } 
      remini sitems.ini kh $2 
      notice $nick $logo(Take-Item) Took your item from $s2($2)
    }
  }
}

on *:TEXT:!rehash:#iDM.staff: {
  if (!$readini(Admins.ini,Admins,$nick)) && (!$readini(Admins.ini,Admins,$address($nick,3))) { halt }
  if ($cid != $scon(1)) { halt }
  timer 1 1 privmsg $chan $s1(Reloading Scripts:) Done
  rehash
  
}

on *:TEXT:!admin:#iDM.staff: {
  if (!$readini(Admins.ini,Admins,$nick)) && (!$readini(Admins.ini,Admins,$address($nick,3))) { halt }
  if (# == #iDM || # == #iDM.staff) && ($me != iDM) { halt }
  notice $nick $s1(Admin commands:) $s2(!part #, !bl #, !ubl #, !cbl #, !chans, !active, !amsg, !join bot #, !msg #, !pass nick, !setpass nick password, !ignore host, !rignore host, !cignore host, !listbl, !except host, !remdm nick, !partall, !idle, !giveitem nick, !takeitem nick, !viewitems)
}
on *:TEXT:!except*:#iDm.staff: {
  if (!$readini(Admins.ini,Admins,$nick)) && (!$readini(Admins.ini,Admins,$address($nick,3))) { halt }
  if (!$2) { notice $Nick Please specify a hostname to except from the clone script. E.g. !except *!*@Swift43rrf435.dns.ntl.com | halt }
  if (# == #iDM || # == #iDM.staff) && ($me != iDM) { halt }
  writeini exceptions.ini Exceptions $2- on
  notice $nick $s2($2) has successfully been added to my exception list.
}
on *:TEXT:!ignore*:#idm.staff: {
  if (!$readini(Admins.ini,Admins,$nick)) && (!$readini(Admins.ini,Admins,$address($nick,3))) { halt }
  if (!$2) { notice $Nick Please specify a username/host to ignore. | halt }
  ignore $2-
  if (# == #iDM || # == #iDM.staff) && ($me != iDM) { halt }
  notice $nick $s2($2-) has been added to the ignore list. Please notify the user of this.
  writeini -n ignore.ini Ignore $2- ~> $nick ~> $fulldate
}
on *:TEXT:!rignore*:#idm.staff: {
  if (!$readini(Admins.ini,Admins,$nick)) && (!$readini(Admins.ini,Admins,$address($nick,3))) { halt }
  if (!$2) { notice $Nick Please specify a username/host to ignore. | halt }
  ignore -r $2-
  if (# == #iDM || # == #iDM.staff) && ($me != iDM) { halt }
  notice $nick $s2($2-) has been removed to the ignore list. Please notify the user of this.
  remini -n ignore.ini Ignore $2- ~> $nick ~> $fulldate
}
alias position {
  if ($readini(Positions.ini,Positions,$nick)) {
    return $v1
    halt
  }
  if ($readini(Positions.ini,Positions,$address($nick,3))) {
    return $v1
    halt
  }
  return Bot admin
}
on *:JOIN:#: {
  if (# == #iDM || # == #iDM.Staff) && ($me != iDM) { halt }
  if ($readini(Admins.ini,Admins,$address($nick,3))) || ($readini(admins.ini,support,$address($nick,3))) { 
    msg # $logo($iif($readini(admins.ini,support,$address($nick,3)),SUPPORT,ADMIN)) $iif($readini(admins.ini,support,$address($nick,3)),Bot support,$position($nick)) $nick has joined the channel.
  }
  if ($nick == $me) {
    if (# == #iDm || # == #iDM.staff) { halt }
    .timer 1 1 scanbots $chan
  }
}
alias botnames {
  return iDM.iDM[US].iDM[LL].iDM[BA].iDM[PK].iDM[AL].iDM[BU].iDM[FU].iDM[SN].iDM[BE].iDM[LA].iDM[EU]
}
on *:TEXT:!part*:#: {
  if (!$readini(Admins.ini,Admins,$nick)) && (!$readini(Admins.ini,Admins,$address($nick,3))) { halt }
  if ($left($2,1) == $chr(35)) && ($me ison $2) {
    part $2 Part requested by $position($nick) $nick $+ . $iif($3,$+($chr(91),$3-,$chr(93))) 
    notice $nick I have parted $2
  }
}
on *:TEXT:!cignore*:#: { 
  tokenize 32 $remove($1-,$chr(36),$chr(37))
  if ($readini(admins.ini,admins,$address($nick,3))) || ($readini(admins.ini,support,$address($nick,3))) {
    if (# == #iDM || # == #iDM.Staff) && ($me != iDM) { halt }
    if (!$2) { notice $nick $logo(ERROR) Type !cignore address. | halt }
    if ($readini(ignore.ini,ignore,$2)) { notice $nick $logo(IGNORE INFO) $s2($2) was blacklisted by $s1($gettok($v1,2,32)) $+ $chr(44) $s1($gettok($v1,4-,32)) $+ . }
    else { notice $nick $logo(IGNORE INFO) $s2($2) is not ignored. }
  }
}
on *:TEXT:!cbl*:#: {
  tokenize 32 $remove($1-,$chr(36),$chr(37))
  if ($readini(admins.ini,admins,$address($nick,3))) || ($readini(admins.ini,support,$address($nick,3))) {
    if (# == #iDM || # == #iDM.Staff) && ($me != iDM) { halt }
    if (!$2) || ($left($2,1) != $chr(35)) { notice $nick $logo(ERROR) Syntax: !cbl #chan | halt }
    if (!$readini(blacklist.ini,chans,$2)) { notice $nick $logo(BLACKLIST INFO) $s2($2) is not blacklisted. | halt } 
    notice $nick $logo(BLACKLIST INFO) $s2($2) has been blacklisted by $s1($iif($readini(blacklist.ini,who,$2),$v1,Unknown)) for: $readini(blacklist.ini,chans,$2)
  }
}

on *:TEXT:!*bl*:#iDM.Staff: {
  tokenize 32 $remove($1-,$chr(36),$chr(37))
  if (!$readini(Admins.ini,Admins,$nick)) && (!$readini(Admins.ini,Admins,$address($nick,3))) { halt }
  if ($left($2,1) == $chr(35)) && (($1 == !bl) || ($1 == !ubl)) {
    $right($1,-1) $2 $nick $chan $3-
  }
}
alias bl {
  tokenize 32 $remove($1-,$chr(36),$chr(37))
  if ($readini(Blacklist.ini,Chans,$1)) {
    if ($me == iDM) {
      notice $2 Channel $1 is already blacklisted.
    }
    $iif($me ison $1,part $1 Channel has been blacklisted by $2 $iif($4,$+($chr(91),$4-,$chr(93))))
    halt
  }
  if (!$readini(Blacklist.ini,Chans,$1)) {
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
  if (!$readini(Blacklist.ini,Chans,$1)) {
    if ($me == iDM) {
      notice $2 Channel $1 isn't blacklisted.
    }
    halt
  }
  if ($readini(Blacklist.ini,Chans,$1)) {
    if ($me == iDM) {
      notice $nick Channel $1 has been unblacklisted.
      remini Blacklist.ini Chans $1
      remini Blacklist.ini Who $1
    }
  }
}
on *:TEXT:!chans*:*: {
  if (!$readini(Admins.ini,Admins,$nick)) && (!$readini(Admins.ini,Admins,$address($nick,3))) { halt }
  notice $nick I am on $chan(0) channels $+ $iif($chan(0) > 1,: $chans)
}
on *:TEXT:!clear*:*: {
  if (!$readini(Admins.ini,Admins,$Nick)) && (!$readini(Admins.ini,Admins,$address($nick,3))) { halt }
  if (%dmon [ $+ [ $chan ] ]) { halt }
  var %a $comchan($me,0),%c
  while (%a) { 
    if ($nick($comchan($me,%a),0)  < 4) { 
      PART $comchan($me,%a) Clear users command used by $nick
      var %c %c $comchan($me,%a)
    }
    dec %a  
  }
  if (%c) notice $Nick I have parted: %c
  else {
    if ($comchan($me,0) > 5) { notice $nick I have parted no chans. }
  }
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
on *:TEXT:!active*:*: {
  if (!$readini(Admins.ini,Admins,$nick)) && (!$readini(Admins.ini,Admins,$address($nick,3))) { halt }
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
on *:TEXT:!join*:*: {
  if (!$readini(Admins.ini,Admins,$nick)) && (!$readini(Admins.ini,Admins,$address($nick,3))) { halt }
  if ($left($3,1) != $chr(35)) { halt }
  if (!$3) { notice $nick To use the join command, type !join botname channel. | halt }
  if ($2 == $me) && ($left($3,1) == $chr(35)) {
    forcejoin $3 $nick
  }
}
alias forcejoin {
  set %forcedj. [ $+ [ $1 ] ] true
  join $1
  .timer 1 1 msg $1 $logo(JOIN) I was requested to join this channel by $position($2) $2 $+ . $chr(91) $+ Bot tag - $s1($bottag) $+ $chr(93)
}
on *:TEXT:?read*:#: {
  if ($left($1,1) isin !@) {
    if (# == #iDM || # == #iDM.Staff) && ($me != iDM) { halt }
    if (!$readini(Admins.ini,Admins,$nick)) && (!$readini(Admins.ini,Admins,$address($nick,3))) { halt }
    if (!$read(suggestions.txt)) { notice $nick There are currently no suggestions | halt }
    $iif($left($1,1) == @,msg #,notice $nick) $iif(!$2, $suggestions, $suggestions($2))
  }
}
alias suggestions {
  if (!$1) {
    unset %b
    var %a 1
    while ($read(suggestions.txt,%a)) {
      set %b %b %a $+ .) $gettok($read(suggestions.txt,%a),7-,32)
      inc %a
    }
    return $logo(SUGGESTIONS) %b
    unset %b
  }
  else {
    if ($1 == @last) return $logo(SUGGESTIONS) $read(suggestions.txt,$lines(suggestions.txt))
    elseif ($1 == @count) return $logo(SUGGESTIONS) Suggestions: $lines(suggestions.txt)
    else return $logo(SUGGESTIONS) $read(suggestions.txt,$1)
  }
}

on $*:TEXT:/^[!.`](rem|rmv|no)dm/Si:#: {
  if ($istok(#idm #idm.staff,#,32)) && ($me != iDM) { halt }
  if (!$readini(Admins.ini,Admins,$nick)) && (!$readini(Admins.ini,Admins,$address($nick,3))) { halt }
  if (!$readini(status.ini,currentdm,$2)) { notice $nick $logo(ERROR) $s1($2) is not DMing at the moment. | halt }
  remini status.ini currentdm $2
  notice $nick $logo(REM-DM) $s1($2) is no longer DMing.
}
