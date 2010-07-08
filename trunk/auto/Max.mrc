alias max {
  ; $1 = attack
  if ($1 == $null) { putlog Syntax Error: attack (1) - $db.safe($1-) | halt }
  var %dbhits = $dmg($1,hits)
  var %dbdmg = $dmg($1, 3h)
  var %dbbonus = $dmg($1, atkbonus)

  if ($dmg($1,type) == range) {
    ;Normal Archer Ring _or_Accumulator Both
    return $dmg.ratio(%dbhits,%dbdmg,0,%dbbonus) $dmg.ratio(%dbhits,%dbdmg,4,%dbbonus) $dmg.ratio(%dbhits,%dbdmg,8,%dbbonus)
  }
  elseif ($dmg($1,type) == magic) {
    ;Normal Voidmage_or_MagesBook_or_GodCape Two_Bonuses Three_Bonuses
    return $dmg.ratio(%dbhits,%dbdmg,0,%dbbonus) $dmg.ratio(%dbhits,%dbdmg,4,%dbbonus) $dmg.ratio(%dbhits,%dbdmg,8,%dbbonus)
  }
  else {
    ;Normal Barrowgloves Firecape Both
    return $dmg.ratio(%dbhits,%dbdmg,0,%dbbonus) $dmg.ratio(%dbhits,%dbdmg,4,%dbbonus) $dmg.ratio(%dbhits,%dbdmg,8,%dbbonus)
  }
}

alias dmg.ratio {
  ; $1 = hit pattern - 1-1-1
  ; $2 = max hit
  ; $3 = attack bonus
  ; $4 = bonus toggle
  if ($4 == $null) { putlog Syntax Error: dmg.ratio (4) - $db.safe($1-) | halt }
  var %hits
  var %i = 0
  while (%i < $numtok($1,45)) {
    inc %i
    var %hits $iif(%hits,%hits $+ -) $+ $ceil($calc(($2 + ($3 * $4)) / $gettok($1,%i,45)))
  }
  return %hits
}

alias hitdmg {
  ; $1 = attack
  ; $2 = accuracy
  ; $3 = hit pattern
  ; $4 = attack bonus
  ; $5 = defense bonus
  if ($5 == $null) { putlog Syntax Error: hitdmg (5) - $db.safe($1-) | halt }
  if ($1 == dh_9) { var %ndmg 3 }
  elseif ($1 == dh_10) { var %ndmg 1 }
  elseif ($2 <= $dmg($1,0l)) { var %ndmg 1 }
  elseif ($2 <= $dmg($1,0h)) { var %ndmg 2 }
  else { var %ndmg 3 }
  var %i = 0
  while (%i < $numtok($3,45)) {
    inc %i
    if ($gettok($3,%i,45) == 1) {
      var %dmg = $rand($dmg($1,%ndmg $+ l),$calc($dmg($1,%ndmg $+ h) + $4)))
      var %dmg = $ceil($calc(%dmg * $5))
      var %return = %return %dmg
    }
    else {
      var %sdmg = $ceil($calc(%dmg * (1 / $gettok($3,%i,45))))
      var %return = %return %sdmg
    }
  }
  return %return
}

alias dmg.hload {
  if ($hget(>weapon)) { hfree >weapon }
  hmake >weapon 50
  var %sql SELECT * FROM weapon
  var %res $db.query(%sql)
  var %i 0
  while ($db.query_row(%res, >row)) {
    inc %i
    hadd >weapon $hget(>row, weapon) $+ .name $hget(>row, name)
    hadd >weapon $hget(>row, weapon) $+ .item $hget(>row, item)
    hadd >weapon $hget(>row, weapon) $+ .pvp $hget(>row, pvp)
    hadd >weapon $hget(>row, weapon) $+ .0l $gettok($hget(>row, range),1,44)
    hadd >weapon $hget(>row, weapon) $+ .0h $gettok($hget(>row, range),2,44)
    hadd >weapon $hget(>row, weapon) $+ .1l $gettok($hget(>row, low),1,44)
    hadd >weapon $hget(>row, weapon) $+ .1h $gettok($hget(>row, low),2,44)
    hadd >weapon $hget(>row, weapon) $+ .2l $gettok($hget(>row, mid),1,44)
    hadd >weapon $hget(>row, weapon) $+ .2h $gettok($hget(>row, mid),2,44)
    hadd >weapon $hget(>row, weapon) $+ .3l $gettok($hget(>row, high),1,44)
    hadd >weapon $hget(>row, weapon) $+ .3h $gettok($hget(>row, high),2,44)
    hadd >weapon $hget(>row, weapon) $+ .hits $hget(>row, hits)
    hadd >weapon $hget(>row, weapon) $+ .type $hget(>row, type)
    hadd >weapon $hget(>row, weapon) $+ .atkbonus $hget(>row, atkbonus)
    hadd >weapon $hget(>row, weapon) $+ .defbonus $hget(>row, defbonus)
    hadd >weapon $hget(>row, weapon) $+ .spec $hget(>row, spec)
    hadd >weapon $hget(>row, weapon) $+ .poison $hget(>row, poisonchance)
    hadd >weapon $hget(>row, weapon) $+ .poisonamount $hget(>row, poisonamount)
    hadd >weapon $hget(>row, weapon) $+ .freeze $hget(>row, freeze)
    hadd >weapon $hget(>row, weapon) $+ .heal $hget(>row, healchance)
    hadd >weapon $hget(>row, weapon) $+ .healamount $hget(>row, healamount)
    hadd >weapon $hget(>row, weapon) $+ .splash $hget(>row, splash)
    hadd >weapon $hget(>row, weapon) $+ .what $hget(>row, what)
    hadd >weapon $hget(>row, weapon) $+ .effect $hget(>row, effect)
    hadd >weapon list. $+ %i $hget(>row, weapon)
    var %list $iif(%list,%list $+ $chr(44)) $+ $hget(>row, weapon)
  }
  hadd >weapon list %list
  hadd >weapon list.0 %i
  mysql_free %res
}

alias dmg.hget {
  if (!$hget(>weapon)) { dmg.hload }
  tokenize 32 $1- 0
  return $hget(>weapon,$1 $+ . $+ $2)
}

alias dmg {
  ; $1 = attack
  ; ?$2? = value
  if ($1 == $null) { putlog Syntax Error: dmg (1) - $db.safe($1-) | halt }
  if (($prop) && ($2 isnum)) return $dmg.hget($dmg.hget($gettok($1,1,95),$2),$prop)
  if ($2 != $null) return $dmg.hget($gettok($1,1,95),$2)
  if (($1 != $null) && ($1 != list)) return $iif($dmg.hget($gettok($1,1,95),name),1,0)
  return $hget(>weapon,list)

}

alias attackname { return $dmg($1,name) }
alias specused { return $calc($dmg($1,spec) * 25) }
alias poisoner { return $dmg($1,poison) $dmg($1,poisonamount) }
alias freezer { return $dmg($1,freeze) }
alias healer { return $dmg($1,heal) $dmg($1,healamount) }
alias splasher { return $dmg($1,splash) }
alias action { return $dmg($1,what) }
alias effect { return $dmg($1,effect) }
alias attack { return $iif($dmg($1,name),$true,$false) }
alias ispvp { return $iif($dmg($1,pvp),$true,$false) }
alias isweapon {
  var %wep $dmg($1,item)
  return $iif(%wep,%wep,$false)
}

on $*:TEXT:/^[!@.]max/Si:#: {
  if (# == #idm) || (# == #idm.Staff) && ($me != iDM) { halt }
  if ($isbanned($nick)) { halt }
  if ($update) { notice $nick $logo(ERROR) IDM is currently disabled, please try again shortly | halt }
  if (!$2) { $iif($left($1,1) == @,msgsafe #,notice $nick) Please specify the weapon to look up. Syntax: !max whip | halt }
  if (!$attack($2)) {
    notice $nick $logo(ERROR) $s1($2) is not a recognized attack.
    halt
  }
  if (!$max($2)) notice $nick $logo(ERROR) $s1($2) is not a recognized attack.
  var %msg $iif($left($1,1) == @,msgsafe #,notice $nick) $logo(MAX) $upper($2) $iif($specused($2),$+($chr(32),$chr(40),$s1($v1 $+ $chr(37)),$chr(41)))
  var %msg %msg $+ $iif($2 == dh,$+($chr(32),$chr(40),10+ HP/9 or less HP,$chr(41))) $+ : $dmg.breakdown($2,1)

  if ($dmg($2,atkbonus) == 0) { var %msg %msg (No attack bonuses) }
  elseif ($dmg($2,type) == range) { var %msg %msg $chr(124) Archer Ring or Accumulator $dmg.breakdown($2,2) $chr(124) Two bonuses $dmg.breakdown($2,3) }
  elseif ($dmg($2,type) == magic) { var %msg %msg $chr(124) Mage Book or God Cape $dmg.breakdown($2,2) $chr(124) Two bonuses $dmg.breakdown($2,3) }
  elseif ($dmg($2,type) == melee) { var %msg %msg $chr(124) Barrow gloves or Fire cape $dmg.breakdown($2,2) $chr(124) Two bonuses $dmg.breakdown($2,3) }
  %msg $iif($effect($2),$+($chr(40),$v1,$chr(41)))
}

alias dmg.breakdown { return $s2($gettok($max($1),$2,32)) $iif($totalhit($1,$2),$+($chr(40),$s2($v1),$chr(41))) }

alias totalhit {
  if (- isin $max($1)) { return $calc($gettok($gettok($v2,$2,32),1,45) + $gettok($gettok($v2,$2,32),2,45) + $gettok($gettok($v2,$2,32),3,45) + $gettok($gettok($v2,$2,32),4,45)) }
  return $false
}

on $*:TEXT:/^[!@.]hitchance/Si:#: {
  if (# == #idm) || (# == #idm.Staff) && ($me != iDM) { halt }
  if ($isbanned($nick)) { halt }
  if ($update) { notice $nick $logo(ERROR) IDM is currently disabled, please try again shortly | halt }
  if (!$3) { $iif($left($1,1) == @,msgsafe #,notice $nick) Syntax: !hitchance <weapon> <damage> | halt }
  if (!$attack($2) && $2 != dh9) { notice $nick $logo(ERROR) $s1($2) is not a recognized attack. | halt }

  db.hget >hitchance equip_armour $nick
  var %atk = $atkbonus($2,>hitchance), %hits = $dmg($2,hits), %targets = 1, %i = 1, %l = 0
  while (%i < $numtok(%hits,45)) {
    inc %i
    if ($gettok(%hits,%i,45) == 1) { inc %targets 1 }
    else { inc %targets $calc(1 / $gettok(%hits,%i,45)))) }
  }
  var %target = $ceil( $calc($3 / %targets) ), %lowtop = $dmg($2, 1h), %midtop = $dmg($2, 2h), %hightop = $dmg($2, 3h), %lowchance = 0, %midchance = 0, %highchance = 0
  var %lowbchance = $calc(($dmg($2,0l)) /100), %midbchance = $calc(($dmg($2,0h) - $dmg($2,0l)) /100), %highbchance = $calc((100 - $dmg($2,0h)) /100)
  while (%l < 2) {
    if (%target <= %lowtop) { var %lowchance = $calc(((%lowtop - %target +1) / (%lowtop - $dmg($2, 1l) +1 )) * %lowbchance) }
    if (%target <= $dmg($2, 1l)) { var %lowchance = %lowbchance }
    if (%target <= %midtop) { var %midchance = $calc(((%midtop - %target +1) / (%midtop - $dmg($2, 2l) +1 )) * %midbchance) }
    if (%target <= $dmg($2, 2l)) { var %midchance = %midbchance }
    if (%target <= %hightop) { var %highchance = $calc(((%hightop - %target +1) / (%hightop - $dmg($2, 3l) +1 )) * %highbchance) }
    if (%target <= $dmg($2, 3l)) { var %highchance = %highbchance }
    if (%l = 0) var %hitchance0 $floor($calc(( %lowchance + %midchance + %highchance ) * 100))
    if (%l = 1) var %hitchance1 $floor($calc(( %lowchance + %midchance + %highchance ) * 100))
    inc %lowtop %atk
    inc %midtop %atk
    inc %hightop %atk
    inc %l
  }
  $iif($left($1,1) == @,msgsafe #,notice $nick) $logo(HITCHANCE) $2 has $s2(%hitchance1 $+ %) chance of hitting $s1($3 $+ +) with your item bonus ( $+ %hitchance0 $+ % without).  Use !max $2 for attack details.
}
