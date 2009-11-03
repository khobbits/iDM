on $*:TEXT:/^[!@.]money/Si:#: { 
  if (# == #iDM || # == #iDM.Staff) && ($me != iDM) { halt }
  if (!$2) {
    $iif($left($1,1) == @,msg #,notice $nick) $logo($nick) $+ $isbanned($nick) $money($nick) $equipment($nick) $clan($nick)
    if ($sitems($nick)) || ($pvp($nick)) $iif($left($1,1) == @,msg #,notice $nick) $logo($nick) $+ $isbanned($nick) $iif($sitems($nick),$s1(Special Items) $+ : $sitems($nick)) $iif($pvp($nick),$s1(PvP Items) $+ : $pvp($nick))
  }
  if ($2) {
    $iif($left($1,1) == @,msg #,notice $nick) $logo($2) $+ $isbanned($2) $money($2) $equipment($2) $clan($2)
    if ($sitems($2)) || ($pvp($2)) $iif($left($1,1) == @,msg #,notice $nick) $logo($2) $+ $isbanned($2) $iif($sitems($2),$s1(Special Items) $+ : $sitems($2)) $iif($pvp($2),$s1(PvP Items) $+ : $pvp($2))
  }
}

alias money {
  var %money = $db.get(user,money,$1)
  var %rank = $rank(money,$1)
  var %wins = $db.get(user,wins,$1)
  var %losses = $db.get(user,losses,$1)
  var %ratio = $+($round($calc(%wins / $calc(%wins + %losses) *100),1),$chr(37))

  return $s1(Money) $+ : $iif(%money,$s2($bytes($v1,bd)) $+ gp ( $+ %rank $+ ),$s2(0) $+ gp) $iif($maxstake(%money),$s1(Max Stake) $+ : $s2($price($maxstake(%money)))) $s1(Wins) $+ : $iif(%wins,$s2($bytes($v1,bd)),$s2(0)) $s1(Losses) $+ : $iif(%losses,$s2($bytes($v1,bd)),$s2(0)) $+($chr(40),$s2(%ratio) Won,$chr(41)) $iif($db.get(equip_item,specpot,$1),$s1(Spec Pots) $+ : $v1) 
}

alias equipment {
  var %sql SELECT * FROM `equip_item` WHERE user = $db.safe($1)
  var %result = $db.query(%sql)
  if ($db.query_row(%result,equipit) === $null) { echo -s Error fetching equipment - equipment %sql }
  db.query_end %result

  var %sql SELECT * FROM `equip_armour` WHERE user = $db.safe($1)
  var %result = $db.query(%sql)
  if ($db.query_row(%result,equipar) === $null) { echo -s Error fetching equipment - equipment %sql }
  db.query_end %result

  if ($hget(equipit,ags)) { var %e %e AGS $+ $iif($v1 > 1,$+($chr(40),$v1,$chr(41))) }
  if ($hget(equipit,bgs)) { var %e %e BGS $+ $iif($v1 > 1,$+($chr(40),$v1,$chr(41))) }
  if ($hget(equipit,sgs)) { var %e %e SGS $+ $iif($v1 > 1,$+($chr(40),$v1,$chr(41))) }
  if ($hget(equipit,zgs)) { var %e %e ZGS $+ $iif($v1 > 1,$+($chr(40),$v1,$chr(41))) }
  if ($hget(equipit,dclaws)) { var %e %e Dragon:Claws $+ $iif($v1 > 1,$+($chr(40),$v1,$chr(41))) }
  if ($hget(equipit,mudkip)) { var %e %e Mudkip $+ $iif($v1 > 1,$+($chr(40),$v1,$chr(41))) }

  if ($hget(equipar,accumulator)) { var %e %e Accumulator $+ $iif($v1 > 1,$+($chr(40),$v1,$chr(41))) }
  if ($hget(equipar,void)) { var %e %e Void:Ranged $+ $iif($v1 > 1,$+($chr(40),$v1,$chr(41))) }
  if ($hget(equipar,void-mage)) { var %e %e Void:Mage $+ $iif($v1 > 1,$+($chr(40),$v1,$chr(41))) }
  if ($hget(equipar,mbook)) { var %e %e Mage's:Book $+ $iif($v1 > 1,$+($chr(40),$v1,$chr(41))) }
  if ($hget(equipar,godcape)) { var %e %e God:Cape $+ $iif($v1 > 1,$+($chr(40),$v1,$chr(41))) }
  if ($hget(equipar,bgloves)) { var %e %e Barrow:Gloves $+ $iif($v1 > 1,$+($chr(40),$v1,$chr(41))) }
  if ($hget(equipar,firecape)) { var %e %e Fire:Cape $+ $iif($v1 > 1,$+($chr(40),$v1,$chr(41))) }
  if ($hget(equipar,elshield)) { var %e %e Elysian:Shield $+ $iif($v1 > 1,$+($chr(40),$v1,$chr(41))) }

  if ($hget(equipit,wealth)) { var %e %e Wealth $+ $iif($v1 > 1,$+($chr(40),$v1,$chr(41))) }
  if ($hget(equipit,clue)) { var %e %e Clue:Scroll }
  return $iif(%e,$s1(Equipment) $+ : $replace(%e,$chr(32),$chr(44),$chr(58),$chr(32)))
}
alias clan {
  if ($getclanname($1)) { return $s1(Clan) $+ : $v1 }
}

alias sitems {
  var %sql SELECT * FROM `equip_staff` WHERE user = $db.safe($1)
  var %result = $db.query(%sql)
  if ($db.query_row(%result,equips) === $null) { echo -s Error fetching equipment - sitems %sql }
  db.query_end %result

  if ($hget(equips,belong)) { var %e %e Bêlong:Blade }
  if ($hget(equips,allegra)) { var %e %e Allergy:Pills }
  if ($hget(equips,beau)) { var %e %e Bêaumerang }
  if ($hget(equips,snake)) { var %e %e $replace(One:Éyed:Trouser:Snake,e,$chr(233),E,É) }
  if ($hget(equips,kh)) { var %e %e KHonfound:Ring }
  if ($hget(equips,support)) { var %e %e The:Supporter }
  return $iif(%e,$replace(%e,$chr(32),$chr(44),$chr(58),$chr(32)))
}
alias pvp {
  var %sql SELECT * FROM `equip_pvp` WHERE user = $db.safe($1)
  var %result = $db.query(%sql)
  if ($db.query_row(%result,equipp) === $null) { echo -s Error fetching equipment - pvp %sql }
  db.query_end %result

  if ($hget(equipp,vspear)) { var %e %e $+(Vesta's:Spear,$chr(91),$s1($v1),$chr(93)) }
  if ($hget(equipp,vlong)) { var %e %e $+(Vesta's:Longsword,$chr(91),$s1($v1),$chr(93)) }
  if ($hget(equipp,statius)) { var %e %e $+(Statius's:Warhammer,$chr(91),$s1($v1),$chr(93)) }
  if ($hget(equipp,MJavelin)) { var %e %e $+(Morrigan's:Javelin,$chr(91),$s1($v1),$chr(93)) }
  return $iif(%e,$replace(%e,$chr(32),$chr(44),$chr(58),$chr(32)))
}
