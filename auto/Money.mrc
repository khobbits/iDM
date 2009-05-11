on *:TEXT:?money*:#: {
  if (# == #iDM || # == #iDM.Staff) && ($me != iDM) { halt }
  if ($left($1,1) isin !@) && ($right($1,-1) == money) {
    if (!$2) {
      $iif($left($1,1) == !,notice $nick,msg #) $logo($nick) $money($nick) $equipment($nick) $clan($nick)
      if ($sitems($nick)) || ($pvp($nick)) $iif($left($1,1) == !,notice $nick,msg #) $logo($nick) $iif($sitems($nick),$s1(Special Items) $+ : $sitems($nick)) $iif($pvp($nick),$s1(PvP Items) $+ : $pvp($nick))
    }
    if ($2) {
      $iif($left($1,1) == !,notice $nick,msg #) $logo($2) $money($2) $equipment($2) $clan($2)
      if ($sitems($2)) || ($pvp($2)) $iif($left($1,1) == !,notice $nick,msg #) $logo($2) $iif($sitems($2),$s1(Special Items) $+ : $sitems($2)) $iif($pvp($2),$s1(PvP Items) $+ : $pvp($2))
    }
  }
}

alias money {
  if ($1 == iBelong) return $s1(Money) $+ : $s2($bytes(999999999999999,db)) $+ gp $s1(Wins) $+ : $iif($readini(Wins.ini,Wins,$1),$s2($bytes($v1,bd)),$s2(0)) $s1(Losses) $+ : $iif($readini(Losses.ini,Losses,$1),$s2($bytes($v1,bd)),$s2(0)) $+($chr(40),$s2($+($round($calc($readini(wins.ini,wins,$1) / $calc($readini(wins.ini,wins,$1) + $readini(losses.ini,losses,$1)) *100),1),$chr(37))) Won,$chr(41)) $iif($readini(equipment.ini,specpot,$1),$s1(Spec Pots) $+ : $readini(equipment.ini,specpot,$1)) 
  else return $s1(Money) $+ : $iif($readini(Money.ini,Money,$1),$s2($bytes($v1,bd)),$s2(0)) $+ gp $s1(Wins) $+ : $iif($readini(Wins.ini,Wins,$1),$s2($bytes($v1,bd)),$s2(0)) $s1(Losses) $+ : $iif($readini(Losses.ini,Losses,$1),$s2($bytes($v1,bd)),$s2(0)) $+($chr(40),$s2($+($round($calc($readini(wins.ini,wins,$1) / $calc($readini(wins.ini,wins,$1) + $readini(losses.ini,losses,$1)) *100),1),$chr(37))) Won,$chr(41)) $iif($readini(equipment.ini,specpot,$1),$s1(Spec Pots) $+ : $readini(equipment.ini,specpot,$1)) 
}

alias equipment {
  if ($readini(Equipment.ini,Void,$1)) { var %e %e Void:Ranged }
  if ($readini(Equipment.ini,void-mage,$1)) { var %e %e Void:Mage }
  if ($readini(Equipment.ini,Wealth,$1)) { var %e %e Wealth }
  if ($readini(Equipment.ini,bgloves,$1)) { var %e %e Barrow:Gloves }
  if ($readini(Equipment.ini,Firecape,$1)) { var %e %e Fire:Cape }
  if ($readini(Equipment.ini,elshield,$1)) { var %e %e Elysian:Shield }
  if ($readini(Equipment.ini,ags,$1)) { var %e %e AGS }
  if ($readini(Equipment.ini,bgs,$1)) { var %e %e BGS }
  if ($readini(Equipment.ini,sgs,$1)) { var %e %e SGS }
  if ($readini(Equipment.ini,zgs,$1)) { var %e %e ZGS }
  if ($readini(Equipment.ini,dclaws,$1)) { var %e %e Dragon:Claws }
  if ($readini(Equipment.ini,mudkip,$1)) { var %e %e Mudkip }
  if ($readini(Equipment.ini,mbook,$1)) { var %e %e Mage's:Book }
  if ($readini(Equipment.ini,accumulator,$1)) { var %e %e Accumulator }
  if ($readini(Equipment.ini,Clue,$1)) { var %e %e Clue:Scroll }
  return $iif(%e,$s1(Equipment) $+ : $replace(%e,$chr(32),$chr(44),$chr(58),$chr(32)))
}
alias clan {
  if ($readini(Clans.ini,Clan,$1)) { return $s1(Clan) $+ : $readini(Clans.ini,Clan,$1) }
} 

alias sitems {
  if ($readini(sitems.ini,belong,$1)) { var %e %e Belong:Blade }
  if ($readini(sitems.ini,allegra,$1)) { var %e %e Allergy:Pills }
  if ($readini(sitems.ini,beau,$1)) { var %e %e Beaumerang }
  if ($readini(sitems.ini,snake,$1)) { var %e %e $replace(One:�yed:Trouser:Snake,e,$chr(233),E,�) }
  if ($readini(sitems.ini,kh,$1)) { var %e %e KHonfound:Ring }
  return $iif(%e,$replace(%e,$chr(32),$chr(44),$chr(58),$chr(32)))
}
alias pvp {
  if ($readini(PvP.ini,vspear,$1)) { var %e %e $+(Vesta's:Spear,$chr(91),$s1($v1),$chr(93)) }
  if ($readini(PvP.ini,vlong,$1)) { var %e %e $+(Vesta's:Longsword,$chr(91),$s1($v1),$chr(93)) }
  if ($readini(PvP.ini,statius,$1)) { var %e %e $+(Statius's:Warhammer,$chr(91),$s1($v1),$chr(93)) }
  if ($readini(PvP.ini,MJavelin,$1)) { var %e %e $+(Morrigan's:Javelin,$chr(91),$s1($v1),$chr(93)) }
  return $iif(%e,$replace(%e,$chr(32),$chr(44),$chr(58),$chr(32)))
}
