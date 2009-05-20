on *:TEXT:*:#: {
  if (# == #iDM || # == #iDM.Staff) && ($me != iDM) { halt }
  if ($left($1,1) isin !@) && (($right($1,-1) == commands) || ($right($1,-1) == dmcommands)) {
    $iif($left($1,1) == !,notice $nick,msg #) $logo(COMMANDS) Starters $s2($chr(91)) $+ $s1(!dm) $+ , $s1(!stake) $+ , $s1(!enddm) $+ , $s1(!money) $+ , $s1(!top) $+ , $s1(!status) $+ , $s1(!buy) $+ , $s1(!sell) $+ , $s1(!store) $+ $s2($chr(93)) Attacks $s2($chr(91)) $+ $s1(!whip) $+ , $s1(!dds) $+ , $s1(!gmaul) $+ , $s1(!guth) $+ , $s1(!cbow) $+ , $s1(!dbow) $+ , $s1(!dh) $+ , $s1(!bgs) $+ , $s1(!sgs) $+ , $s1(!ags) $+ , $s1(!zgs) $+ , $s1(!ice) $+ , $s1(!blood) $+ , $s1(!surf) $+ , $s1(!dclaws) $+ , $s1(!dscim) $+ , $s1(!dmace) $+ , $s1(!dlong) $+ , $s1(!dhally) $+ , $s1(!specpot) $+ $s2($chr(93)) 
    $iif($left($1,1) == !,notice $nick,msg #) $logo(COMMANDS) PvP Attacks $s2($chr(91)) $+ $s1(!vspear) $+ , $s1(!statius) $+ , $s1(!vlong) $+ , $s1(mjavelin) $+ $s2($chr(93)) Clues $s2($chr(91)) $+ $s1(!dmclue) $+ , $s1(!solve) $+ $s2($chr(93)) Clan $s2($chr(91)) $+ $s1(!startclan) $+ , $s1(!addmem) $+ , $s1(!delmem) $+ , $s1(!joinclan) $+ , $s1(!dmclan) $+ , $s1(!leave) $+ , $s1(!share on/off) $+ $s2($chr(93)) Misc $s2($chr(91)) $+ $s1(!on [all,-h/l]) $+ , $s1(!off [-h/l]) $+ $s2($chr(93)) 
  }
}
