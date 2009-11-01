on $*:TEXT:/^[!@.](dm)?command(s)?$/Si:#: {
  if (# == #iDM || # == #iDM.Staff) && ($me != iDM) { halt }
  $iif($left($1,1) == @,msg #,notice $nick) $logo(COMMANDS) $&
    $s2(Account) $chr(91) $+ $s1(!money) $+ , $s1(!top/wtop/ltop N) $+ , $s1(!dmrank nick/N) $+ $chr(93) $&
    $s2(Clan) $chr(91) $+ $s1(!startclan name) $+ , $s1(!addmem/delmem nick) $+ , $s1(!joinclan name) $+ , $s1(!dmclan nick) $+ , $s1(!leave) $+ , $s1(!share on/off) $+ $chr(93) $&
    $s2(Shop) $chr(91) $+ $s1(!buy/sell item) $+ , $s1(!store) $+ $chr(93) $&
    $s2(Clue) $chr(91) $+ $s1(!dmclue) $+ , $s1(!solve answer) $+ $chr(93) $&
    $s2(Misc) $chr(91) $+ $s1(!on/off att) $+ , $s1(!max att) $+ , $s1(!hitchance att dmg) $+ $chr(93)
  $iif($left($1,1) == @,msg #,notice $nick) $logo(COMMANDS) $&
    $s2(Control) $chr(91) $+ $s1(!dm) $+ , $s1(!stake [amount]) $+ , $s1(!enddm) $+ , $s1(!status) $+ $chr(93) $&
    $s2(Attacks) $chr(91) $+ $s1(!ags) $+ , $s1(!bgs) $+ , $s1(!sgs) $+ , $s1(!zgs) $+ , $s1(!whip) $+ , $s1(!guth) $+ , $s1(!dscim) $+ , $s1(!dh) $+ , $s1(!dds) $+ , $s1(!dclaws) $+ , $s1(!dmace) $+ , $s1(!dlong) $+ , $s1(!dhally) $+ , $s1(!gmaul) $+ , $s1(!cbow) $+ , $s1(!onyx) $+ , $s1(!dbow) $+ , $s1(!ice) $+ , $s1(!blood) $+ , $s1(!smoke) $+ , $s1(!surf) $+ , $s1(!specpot) $+ $chr(93) $&
    $s2(PvP Attacks) $chr(91) $+ $s1(!vspear) $+ , $s1(!statius) $+ , $s1(!vlong) $+ , $s1(!mjavelin) $+ $chr(93))
}

on $*:TEXT:/^[!@.]suggest/Si:#: {
  if (# == #iDM || # == #iDM.Staff) && ($me != iDM) { halt }
  if (%sugg.spam [ $+ [ $nick ] ]) { halt }
  inc -u10 %sugg.spam [ $+ [ $nick ] ]
  notice $nick $LOGO(SUGGESTIONS FORUM) To suggest new content please goto: http://forum.idm-bot.com/viewforum.php?f=6
}

off $*:TEXT:/^[!@.]set/Si:#: {
  if (# == #iDM || # == #iDM.Staff) && ($me != iDM) { halt }
  tokenize 32 $remove($1-,$chr(36),$chr(37))
  if ($nick isop # || $db.get(admins,c1,$address($nick,3))) {
    if ($istok($setcommands,$2,32)) && ($3 == on) {
      if ($.readini(set.ini,#,$2)) {
        notice $nick $logo(ERROR) $qt($2) is already on.
        halt
      }
      else {
        notice $nick $logo(ERROR) $qt($2) has been enabled.
        writeini set.ini # $2 on
      }
    }
    if ($istok($setcommands,$2,32)) && ($3 == off) {
      if (!$.readini(set.ini,#,$2)) {
        notice $nick $logo(ERROR) $qt($2) is already off.
        halt
      }
      else {
        notice $nick $logo(ERROR) $qt($2) has been disabled.
        remini set.ini # $2
      }
    }
  }
}
alias setcommands {
  return automoney
}
