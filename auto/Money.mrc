on $*:TEXT:/^[!@.]money/Si:#: { 
  if (# == #iDM || # == #iDM.Staff) && ($me != iDM) { halt }
  if (!$2) {
    $iif($left($1,1) == @,msg #,notice $nick) $logo($nick) $money($nick) $equipment($nick) $clan($nick)
    if ($sitems($nick)) || ($pvp($nick)) $iif($left($1,1) == @,msg #,notice $nick) $logo($nick) $iif($sitems($nick),$s1(Special Items) $+ : $sitems($nick)) $iif($pvp($nick),$s1(PvP Items) $+ : $pvp($nick))
  }
  if ($2) {
    $iif($left($1,1) == @,msg #,notice $nick) $logo($2) $money($2) $equipment($2) $clan($2)
    if ($sitems($2)) || ($pvp($2)) $iif($left($1,1) == @,msg #,notice $nick) $logo($2) $iif($sitems($2),$s1(Special Items) $+ : $sitems($2)) $iif($pvp($2),$s1(PvP Items) $+ : $pvp($2))
  }
}

alias money {
  var %money = $.readini(Money.ini,Money,$1)
  var %rank = $rank(money,$1)
  var %wins = $.readini(Wins.ini,Wins,$1)
  var %losses = $.readini(Losses.ini,Losses,$1)
  var %ratio = $+($round($calc(%wins / $calc(%wins + %losses) *100),1),$chr(37))
  if ($1 == Otto) { 
    %money = 999999999999
    %rank = 1st
  }
  return $s1(Money) $+ : $iif(%money,$s2($bytes($v1,bd)) $+ gp ( $+ %rank $+ ),$s2(0) $+ gp) $iif($maxstake(%money),$s1(Max Stake) $+ : $s2($price($maxstake(%money)))) $s1(Wins) $+ : $iif(%wins,$s2($bytes($v1,bd)),$s2(0)) $s1(Losses) $+ : $iif(%losses,$s2($bytes($v1,bd)),$s2(0)) $+($chr(40),$s2(%ratio) Won,$chr(41)) $iif($.readini(equipment.ini,specpot,$1),$s1(Spec Pots) $+ : $v1) 
}

alias equipment {
  if ($.readini(Equipment.ini,Void,$1)) { var %e %e Void:Ranged $+ $iif($v1 > 1,$+($chr(40),$v1,$chr(41))) }
  if ($.readini(Equipment.ini,void-mage,$1)) { var %e %e Void:Mage $+ $iif($v1 > 1,$+($chr(40),$v1,$chr(41))) }
  if ($.readini(Equipment.ini,Wealth,$1)) { var %e %e Wealth $+ $iif($v1 > 1,$+($chr(40),$v1,$chr(41))) }
  if ($.readini(Equipment.ini,bgloves,$1)) { var %e %e Barrow:Gloves $+ $iif($v1 > 1,$+($chr(40),$v1,$chr(41))) }
  if ($.readini(Equipment.ini,Firecape,$1)) { var %e %e Fire:Cape $+ $iif($v1 > 1,$+($chr(40),$v1,$chr(41))) }
  if ($.readini(Equipment.ini,elshield,$1)) { var %e %e Elysian:Shield $+ $iif($v1 > 1,$+($chr(40),$v1,$chr(41))) }
  if ($.readini(Equipment.ini,ags,$1)) { var %e %e AGS $+ $iif($v1 > 1,$+($chr(40),$v1,$chr(41))) }
  if ($.readini(Equipment.ini,bgs,$1)) { var %e %e BGS $+ $iif($v1 > 1,$+($chr(40),$v1,$chr(41))) }
  if ($.readini(Equipment.ini,sgs,$1)) { var %e %e SGS $+ $iif($v1 > 1,$+($chr(40),$v1,$chr(41))) }
  if ($.readini(Equipment.ini,zgs,$1)) { var %e %e ZGS $+ $iif($v1 > 1,$+($chr(40),$v1,$chr(41))) }
  if ($.readini(Equipment.ini,dclaws,$1)) { var %e %e Dragon:Claws $+ $iif($v1 > 1,$+($chr(40),$v1,$chr(41))) }
  if ($.readini(Equipment.ini,mudkip,$1)) { var %e %e Mudkip $+ $iif($v1 > 1,$+($chr(40),$v1,$chr(41))) }
  if ($.readini(Equipment.ini,mbook,$1)) { var %e %e Mage's:Book $+ $iif($v1 > 1,$+($chr(40),$v1,$chr(41))) }
  if ($.readini(Equipment.ini,accumulator,$1)) { var %e %e Accumulator $+ $iif($v1 > 1,$+($chr(40),$v1,$chr(41))) }
  if ($.readini(Equipment.ini,Clue,$1)) { var %e %e Clue:Scroll }
  return $iif(%e,$s1(Equipment) $+ : $replace(%e,$chr(32),$chr(44),$chr(58),$chr(32)))
}
alias clan {
  if ($getclanname($1)) { return $s1(Clan) $+ : $v1 }
}

alias sitems {
  if ($.readini(sitems.ini,belong,$1)) { var %e %e Bêlong:Blade }
  if ($.readini(sitems.ini,allegra,$1)) { var %e %e Allergy:Pills }
  if ($.readini(sitems.ini,beau,$1)) { var %e %e Beaumerang }
  if ($.readini(sitems.ini,snake,$1)) { var %e %e $replace(One:Éyed:Trouser:Snake,e,$chr(233),E,É) }
  if ($.readini(sitems.ini,kh,$1)) { var %e %e KHonfound:Ring }
  if ($.readini(sitems.ini,support,$1)) { var %e %e The:Supporter }
  return $iif(%e,$replace(%e,$chr(32),$chr(44),$chr(58),$chr(32)))
}
alias pvp {
  if ($.readini(PvP.ini,vspear,$1)) { var %e %e $+(Vesta's:Spear,$chr(91),$s1($v1),$chr(93)) }
  if ($.readini(PvP.ini,vlong,$1)) { var %e %e $+(Vesta's:Longsword,$chr(91),$s1($v1),$chr(93)) }
  if ($.readini(PvP.ini,statius,$1)) { var %e %e $+(Statius's:Warhammer,$chr(91),$s1($v1),$chr(93)) }
  if ($.readini(PvP.ini,MJavelin,$1)) { var %e %e $+(Morrigan's:Javelin,$chr(91),$s1($v1),$chr(93)) }
  return $iif(%e,$replace(%e,$chr(32),$chr(44),$chr(58),$chr(32)))
}
