on *:TEXT:?*commands:#: {
  if (# == #iDM || # == #iDM.Staff) && ($me != iDM) { halt }
  if ($left($1,1) isin !@) && (($right($1,-1) == commands) || ($right($1,-1) == dmcommands)) {
    $iif($left($1,1) == !,notice $nick,msg #) $logo(COMMANDS) Starters $s2($chr(91)) $+ $s1(!dm) $+ , $s1(!stake) $+ , $s1(!enddm) $+ , $s1(!money) $+ , $s1(!top) $+ , $s1(!status) $+ , $s1(!buy) $+ , $s1(!sell) $+ , $s1(!store) $+ $s2($chr(93)) Attacks $s2($chr(91)) $+ $s1(!whip) $+ , $s1(!dds) $+ , $s1(!gmaul) $+ , $s1(!guth) $+ , $s1(!cbow) $+ , $s1(!dbow) $+ , $s1(!dh) $+ , $s1(!bgs) $+ , $s1(!sgs) $+ , $s1(!ags) $+ , $s1(!zgs) $+ , $s1(!ice) $+ , $s1(!blood) $+ , $s1(!smoke) $+ , $s1(!surf) $+ , $s1(!dclaws) $+ , $s1(!dscim) $+ , $s1(!dmace) $+ , $s1(!dlong) $+ , $s1(!dhally) $+ , $s1(!specpot) $+ $s2($chr(93)) 
    $iif($left($1,1) == !,notice $nick,msg #) $logo(COMMANDS) PvP Attacks $s2($chr(91)) $+ $s1(!vspear) $+ , $s1(!statius) $+ , $s1(!vlong) $+ , $s1(mjavelin) $+ $s2($chr(93)) Clues $s2($chr(91)) $+ $s1(!dmclue) $+ , $s1(!solve) $+ $s2($chr(93)) Clan $s2($chr(91)) $+ $s1(!startclan) $+ , $s1(!addmem) $+ , $s1(!delmem) $+ , $s1(!joinclan) $+ , $s1(!dmclan) $+ , $s1(!leave) $+ , $s1(!share on/off) $+ $s2($chr(93)) Misc $s2($chr(91)) $+ $s1(!on attack) $+ , $s1(!off attack) $+ $s2($chr(93)) 
  }
}

on *:TEXT:!suggest:#: {
  if (# == #iDM || # == #iDM.Staff) && ($me != iDM) { halt }
  if (%sugg.spam [ $+ [ $nick ] ]) { halt }
  inc -u10 %sugg.spam [ $+ [ $nick ] ]
  notice $nick $LOGO(SUGGESTIONS FORUM) To suggest new content please goto: http://forum.idm-bot.com/viewforum.php?f=6
} 


off *:TEXT:!set*:#: {
  if (# == #iDM || # == #iDM.Staff) && ($me != iDM) { halt }
  tokenize 32 $remove($1-,$chr(36),$chr(37))
  if ($nick isop #) || ($.readini(admins.ini,admins,$address($nick,3)) || $.readini(admins.ini,support,$address($nick,3))) {
    if ($istok($setcommands,$2,32)) && ($3 == on) {
      if ($.readini(set.ini,#,$2)) { 
        notice $nick $logo(ERROR) $qt($2) is already on.
        halt
      }
      else {
        notice $nick $logo(ERROR) $qt($2) has been enabled.
        writeini -n set.ini # $2 on
      }
    }
    if ($istok($setcommands,$2,32)) && ($3 == off) {
      if (!$.readini(set.ini,#,$2)) { 
        notice $nick $logo(ERROR) $qt($2) is already off.
        halt
      }
      else {
        notice $nick $logo(ERROR) $qt($2) has been disabled.
        remini -n set.ini # $2
      }
    }
  }
}
alias setcommands {
  return automoney
}
