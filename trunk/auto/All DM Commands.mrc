on $*:TEXT:/^[!.]/Si:#: {
  if (# == #iDM || # == #iDM.Staff) && ($me != iDM) { halt }
  if ($right($1,-1) == specpot) {
    if (($nick == %p1 [ $+ [ $chan ] ] && %turn [ $+ [ $chan ] ] == 1) || ($nick == %p2 [ $+ [ $chan ] ] && %turn [ $+ [ $chan ] ] == 2)) {
      if ($db.get(user,login,$nick) !> 1) {
        notice $nick You have to login before you can use this command. ( $+ $s2(/msg $me $iif($db.get(user,pass,$nick),ident,reg) pass) $+ ) (Don't use your RuneScape password)
        halt
      }
      if ($db.get(equip_item,specpot,$nick) == 0) { notice $nick You don't have any specpots. | halt }
      if ($($+(%,sp,$player($nick,#),#),2) == 4) { notice $nick You already have a full special bar. | halt }
      set $+(%,sp,$player($nick,#),#) 4
      db.set equip_item specpot $nick - 1
      msg # $logo(DM) $s1($nick) drinks their specpot and now has 100% special.
      unset %laststyle [ $+ [ # ] ]
      unset $+(%,frozen,$nick)
      set %turn [ $+ [ # ] ] $iif($player($nick,#) == 1,2,1)
      halt
    }
  }
  if ($attack($right($1,-1))) {
    if (($nick == %p1 [ $+ [ $chan ] ] && %turn [ $+ [ $chan ] ] == 1) || ($nick == %p2 [ $+ [ $chan ] ] && %turn [ $+ [ $chan ] ] == 2)) {
      if ($calc($specused($right($1,-1)) /25) > $($+(%,sp,$player($nick,#),#),2)) {
        notice $nick $logo(ERROR) You need $s1($specused($right($1,-1)) $+ $chr(37)) spec to use this weapon.
        halt
      }
      if ($.readini(onoff,$right($1,-1),#)) {
        notice $nick $logo(ERROR) This command has been disabled for this channel.
        halt
      }
      if (%frozen [ $+ [ $nick ] ] == on) && ($max(m,$right($1,-1))) {
        notice $nick You're frozen and can't use melee.
        halt
      }
      if ($ispvp($right($1,-1))) {
        if ($db.get(equip_pvp,$right($1,-1),$nick)) {
          notice $nick You don't have this weapon.
          halt
        }
        if ($db.get(user,login,$nick) !> 1) {
          notice $nick You have to login before you can use this command. ( $+ $s2(/msg $me $iif($db.get(user,pass,$nick),ident,reg) pass) $+ ) (Don't use your RuneScape password)
          halt
        }
      }
      if ($isweapon($replace($right($1,-1),surf,mudkip))) {
        if ($db.get(equip_item,$replace($right($1,-1),surf,mudkip),$nick) === 0) {
          notice $nick You have to unlock this weapon before you can use it.
          halt
        }
      }
      set -u25 %enddm [ $+ [ $chan ] ] 0
      damage $nick $iif($nick == %p1 [ $+ [ # ] ],%p2 [ $+ [ # ] ],$v2) $right($1,-1) #
    }
  }
}

alias damage_test {
  set -u60 %dmtest 1
  var %chan = #idm.staff

  set %p1 [ $+ [ %chan ] ] KHobbits
  set %p2 [ $+ [ %chan ] ] Shinn_Gundam
  set %hp1 [ $+ [ %chan ] ] 99
  set %hp2 [ $+ [ %chan ] ] 99

  damage KHobbits Shinn_Gundam $1 %chan
  cancel %chan
  set %dmtest 0
}


alias damage {
  ;1 is person attacking
  ;2 is other person
  ;3 is weapon
  ;4 is chan
  var %hp1 $($+(%,hp,$player($1,$4),$4),2)
  var %hp2 $($+(%,hp,$player($2,$4),$4),2)

  if ($4 == #iDM.Staff) { echo #iDM.Staff - %hp2 [ $+ [ #idm.staff ] ] - $1- }
  if ($ispvp($3)) {
    db.set equip_pvp $3 $1 - 1
  }
  if ($3 != dh) {
    var %hit $hit($3,$1,$2,$4)
  }
  elseif ($3 == dh) {
    if (%hp1 < 10) { var %hit $hit(d_h9,$1,$2,$4) }
    else var %hit $hit(d_h10,$1,$2,$4)
  }

  var %i = 1
  while (%i <= $numtok(%hit,32)) {
    var %hitdmg $gettok(%hit,%i,32)
    if (%hp2 == 0) {
      var %hit $puttok(%hit,KO,%i,32)
    }
    elseif (%hp2 <= %hitdmg) {
      var %hit $puttok(%hit,%hp2,%i,32)
      set %hp2 0
    }
    else {
      dec %hp2 %hitdmg
    }
    inc %i
  }

  unset $+(%,frozen,$1)
  if ($freezer($3)) {
    var %freeze $r(1,$v1)
  }
  if (%freeze == 1) {
    if (%hitdmg >= 1) {
      set $+(%,frozen,$2) on
      notice $2 You have been frozen and can't use melee!
    }
  }
  if ($gettok($healer($3),1,32)) {
    var %heal $r(1,$v1)
  }
  if (%heal == 1) {
    $iif($calc($floor(%hp1) + $floor($calc(%hit / $gettok($healer($3),2,32)))) > 99,set %hp1 99,inc %hp1 $floor($calc(%hit / $gettok($healer($3),2,32))))
  }
  if ($poisoner($3)) {
    var %pois.chance $r(1,$v1)
    if (%pois.chance == 1) || ($db.get(equip_staff,snake,$1)) && (!$($+(%,pois,$player($2,$4),$4),2)) {
      set $+(%,pois,$player($2,$4),$4) 6
    }
  }
  if ($($+(%,pois,$player($2,$4),$4),2) >= 1) && (%hp2 >= 1) {
    var %extra $iif(%hp2 < $($+(%,pois,$player($2,$4),$4),2),$v1,$v2)
    dec $+(%,pois,$player($2,$4),$4)
    dec %hp2 %extra
  }
  if ($max(m,$3)) {
    set %laststyle [ $+ [ $4 ] ] melee
  }
  elseif ($max(ma,$3)) {
    set %laststyle [ $+ [ $4 ] ] mage
  }
  elseif ($max(r,$3)) {
    set %laststyle [ $+ [ $4 ] ] range
  }
  ;;tokenize 32 $replace($1,Sara,Commander:Zilyana,Arma,Kree'arra,Bandos,General:Graardor,Zammy,K'ril:Tsutsaroth) $2-
  var %msg $logo(DM) $s1($1)
  if ($3 == vlong) {
    var %msg %msg slashes their Vesta's longsword at $s1($replace($2,$chr(58),$chr(32))) $+ $chr(44) hitting $s2(%hit)
  }
  elseif ($3 == cslap) {
    var %msg %msg uses mystical powers to summon a giant penis and slaps $s1($replace($2,$chr(58),$chr(32))) across the face and hits $s2(%hit)
  }
  elseif ($3 == vspear) {
    var %msg %msg 12freezes $s1($replace($2,$chr(58),$chr(32))) using a Vesta's spear, and hits $s2(%hit)
  }
  elseif ($3 == statius) {
    var %msg %msg critically injures $s1($replace($2,$chr(58),$chr(32))) with a Statius's warhammer, hitting $s2(%hit)
  }
  elseif ($3 == mjavelin) {
    var %msg %msg throws a Morrigan's javelin at $s1($replace($2,$chr(58),$chr(32))) hitting $s2(%hit)
  }
  elseif ($3 == sgs) {
    var %msg %msg crushes their godsword down on $s1($replace($2,$chr(58),$chr(32))) and hit $s2(%hit)
  }
  elseif ($3 == ags) {
    var %msg %msg spins around and slashes at $s1($replace($2,$chr(58),$chr(32))) with an Armadyl godsword, speccing $s2(%hit)
  }
  elseif ($3 == zgs) {
    var %msg %msg attempts to freeze $s1($replace($2,$chr(58),$chr(32))) $iif(%freeze == 1,and successfully 12FROZE them,but failed to) $+ $chr(44) hitting $s2(%hit)
  }
  elseif ($3 == bgs) {
    var %msg %msg crushes their godsword down on $s1($replace($2,$chr(58),$chr(32))) and hit $s2(%hit)
  }
  elseif ($3 == guth) {
    var %msg %msg $iif(%heal == 1,09HEALS on,fails to heal on) $s1($replace($2,$chr(58),$chr(32))) $iif(%heal == 1,and hits,but hits) $s2(%hit)
  }
  elseif ($3 == blood) {
    var %msg %msg casts 05blood barrage on $s1($replace($2,$chr(58),$chr(32))) $iif(%hit == 0, and splashed $+ $iif(!%extra,.),hitting $s2(%hit))
  }
  elseif ($3 == ice) {
    var %msg %msg casts 12ice barrage on $s1($replace($2,$chr(58),$chr(32))) $iif(%freeze == 1,(12FROZEN)) $iif(%hit == 0, and splashed $+ $iif(!%extra,.),surrounding them in an ice cube $+ $chr(44) hitting $s2(%hit))
  }
  elseif ($3 == smoke) {
    var %msg %msg casts 14smoke barrage on $s1($replace($2,$chr(58),$chr(32))) $iif(%hit == 0, and splashed $+ $iif(!%extra,.),hitting $s2(%hit))
  }
  elseif ($3 == cbow) {
    var %msg %msg $iif(%cbowspec [ $+ [ $1 ] ],5UNLEASHES a dragon bolt special on,shoots a dragon bolt at) $s1($replace($2,$chr(58),$chr(32))) with a rune c'bow, hitting $s2(%hit)
    unset %cbowspec [ $+ [ $1 ] ]
  }
  elseif ($3 == dbow) {
    var %msg %msg fires two dragon arrows towards $s1($replace($2,$chr(58),$chr(32))) $+ , speccing  $s2($gettok(%hit,1,32)) - $s2($gettok(%hit,2,32))
  }
  elseif ($3 == whip) {
    var %msg %msg slashes $s1($replace($2,$chr(58),$chr(32))) with their abyssal whip, hitting $s2(%hit)
  }
  elseif ($3 == dds) {
    var %msg %msg stabs $s1($replace($2,$chr(58),$chr(32))) with a dragon dagger, hitting $s2($gettok(%hit,1,32)) - $s2($gettok(%hit,2,32))
  }
  elseif ($3 == dclaws) {
    var %msg %msg scratches $s1($replace($2,$chr(58),$chr(32))) with their dragon claws, hitting $s2($gettok(%hit,1,32)) - $s2($gettok(%hit,2,32)) - $s2($gettok(%hit,3,32)) - $s2($gettok(%hit,4,32))
  }
  elseif ($3 == surf) {
    var %msg %msg summons their mudkip, surfing at $s1($replace($2,$chr(58),$chr(32))) $+ , hitting $s2(%hit)
  }
  elseif ($3 == gmaul) {
    var %msg %msg whacks $s1($replace($2,$chr(58),$chr(32))) with their granite maul, speccing $s2($gettok(%hit,1,32)) - $s2($gettok(%hit,2,32)) - $s2($gettok(%hit,3,32))
  }
  elseif ($3 == dh) {
    var %msg %msg crushes $s1($replace($2,$chr(58),$chr(32))) with their great axe, and hit $s2(%hit)
  }
  elseif ($3 == dscim) {
    var %msg %msg slices $s1($replace($2,$chr(58),$chr(32))) with their dragon scimitar, hitting $s2(%hit)
  }
  elseif ($3 == dlong) {
    var %msg %msg stabs $s1($replace($2,$chr(58),$chr(32))) with a dragon longsword, hitting $s2(%hit)
  }
  elseif ($3 == dmace) {
    var %msg %msg crushes $s1($replace($2,$chr(58),$chr(32))) with a dragon mace, hitting $s2(%hit)
  }
  elseif ($3 == dhally) {
    var %msg %msg slashes $s1($replace($2,$chr(58),$chr(32))) with their dragon halberd, hitting $s2($gettok(%hit,1,32)) - $s2($gettok(%hit,2,32))
  }
  elseif ($3 == onyx) {
    var %msg %msg shoots $s1($replace($2,$chr(58),$chr(32))) with an onyx bolt, $iif(%heal == 1,09HEALING and) hitting a $s2(%hit)
  }
  elseif ($3 == gwd) {
    msg $4 $logo(GWD) $s1($replace($1,$chr(58),$chr(32))) brutally attacks $s1($2) $+ , hitting $s2(%hit) $+ . HP $+($chr(91),$s2($iif(%hp2 < 1,0,$v1)),$chr(93)) $hpbar(%hp2,hp)
  }
  if (%extra) {
    var %msg %msg $+ $iif(%extra, $chr(32) - 03 $+ $v1 $+  $+) $+ .
  }
  else {
    var %msg %msg $+ .
  }
  if (%heal == 1) {
    var %msg %msg HP $s1($replace($2,$chr(58),$chr(32))) $+($chr(91),$s2(%hp2),$chr(93)) $hpbar(%hp2,$iif($($+(%,gwd,$4),2),gwd,hp)) - HP $s1($1) $+($chr(91),$s2(%hp1),$chr(93)) $hpbar(%hp1)
  }
  else {
    var %msg %msg HP $+($chr(91),$s2(%hp2),$chr(93)) $hpbar(%hp2,$iif($($+(%,gwd,$4),2),gwd,hp))
  }
  msg $4 %msg
  if ($specused($3)) {
    dec $+(%,sp,$player($1,$4),$4) $calc($specused($3) /25)
    notice $1 Specbar: $iif($($+(%,sp,$player($1,$4),$4),2) < 1,0,$gettok(25 50 75 100,$($+(%,sp,$player($1,$4),$4),2),32)) $+ $chr(37)
  }

  var %sql SELECT * FROM `equip_staff` WHERE user = $db.safe($2)
  var %result = $db.query(%sql)
  if ($db.query_row(%result,equipstaff) === $null) { echo -s Error fetching equipment - damage $1- }
  db.query_end %result

  if ($hget(equipstaff,belong)) && ($r(1,100) < 3) && (%hp2 >= 1) {
    var %extra $iif(%hp2 < 12,$($v1,2),12)
    dec %hp2 %extra
    msg $4 $logo(DM) $s1($1) whips out their Bêlong Blade and deals $s2(%extra) extra damage. HP $+($chr(91),$s2(%hp2),$chr(93)) $hpbar(%hp2,$iif($($+(%,gwd,$4),2),gwd,hp))
  }
  if ($hget(equipstaff,allegra)) && ($r(1,100) < 3) && (%hp2 >= 1) {
    var %extraup $iif(%hp2 >= 84,$calc(99- %hp2),15)
    inc %hp2 %extraup
    msg $4 $logo(DM) Allêgra gives $s1($2) Allergy pills, healing $s2(%extraup) HP. HP $+($chr(91),$s2(%hp2),$chr(93)) $hpbar(%hp2,$iif($($+(%,gwd,$4),2),gwd,hp))
  }
  if ($hget(equipstaff,kh)) && ($r(1,100) < 3) && (%hp2 >= 1) && (%extraup == $null) {
    var %extraup $calc($replace(%hit,$chr(32),$chr(43)))
    inc %hp2 %extraup
    msg $4 $logo(DM) KHobbits uses his KHonfound Ring to let $s1($2) avoid the damage. HP $+($chr(91),$s2(%hp2),$chr(93)) $hpbar(%hp2,$iif($($+(%,gwd,$4),2),gwd,hp))
    set %turn [ $+ [ $4 ] ] $iif($player($1,$4) == 1,2,1)
  }
  if ($hget(equipstaff,support)) && ($r(1,100) < 3) && (%hp2 >= 1) && (%extraup == $null) {
    var %temp.hit $calc($replace(%hit,$chr(32),$chr(43)))
    var %extraup $floor($calc(%temp.hit / 2))
    inc %hp2 %extraup
    msg $4 $logo(DM) $s1($2) uses THE SUPPORTER to help defend against $s1($1) $+ 's attacks. HP $+($chr(91),$s2(%hp2),$chr(93)) $hpbar(%hp2,$iif($($+(%,gwd,$4),2),gwd,hp))
  }
  if (%hp2 < 1) {
    if ($hget(equipstaff,beau)) && ($r(1,100) < 6) {
      set %hp2 1
      msg $4 $logo(DM) $s1($2) $+ 's Bêaumerang brings them back to life, barely. HP $+($chr(91),$s2($iif(%hp2 < 1,0,$v1)),$chr(93)) $hpbar(%hp2,$iif($($+(%,gwd,$4),2),gwd,hp))
    }
    elseif (%dmtest == 1) { halt }
    else {
      dead $4 $2 $1
      halt
    }
  }
  set $+(%,hp,$player($1,$4),$4) %hp1
  set $+(%,hp,$player($2,$4),$4) %hp2
  set %turn [ $+ [ $4 ] ] $iif($player($1,$4) == 1,2,1)
}
alias player {
  if ($1 == %p1 [ $+ [ $2 ] ]) { return 1 }
  if ($1 == %p2 [ $+ [ $2 ] ]) { return 2 }
}

alias accuracy {
  ;1 is Attack
  ;2 is Chan
  if ($istok(melee mage range,%laststyle [ $+ [ $2 ] ],32)) {
    if ($max(m,$1)) {
      if (%laststyle [ $+ [ $2 ] ] == melee) {
        return 0
      }
      elseif (%laststyle [ $+ [ $2 ] ] == mage) {
        return -1
      }
      elseif (%laststyle [ $+ [ $2 ] ] == range) {
        return 1
      }
    }
    elseif ($max(ma,$1)) {
      if (%laststyle [ $+ [ $2 ] ] == melee) {
        return 1
      }
      elseif (%laststyle [ $+ [ $2 ] ] == mage) {
        return 0
      }
      elseif (%laststyle [ $+ [ $2 ] ] == range) {
        return -1
      }
    }
    elseif ($max(r,$1)) {
      if (%laststyle [ $+ [ $2 ] ] == melee) {
        return -1
      }
      elseif (%laststyle [ $+ [ $2 ] ] == mage) {
        return 1
      }
      elseif (%laststyle [ $+ [ $2 ] ] == range) {
        return 0
      }
    }
  }
  return 0
}

alias hit {
  ;1 is Weapon
  ;2 is Attacker
  ;3 is Attackee
  ;4 is Chan
  if ($accuracy($1,$4) == -1) {
    var %acc $r(1,$r(75,90))
  }
  elseif ($accuracy($1,$4) == 1) {
    var %acc $r($r(10,25),100)
  }
  else {
    var %acc $r(1,100)
  }

  var %sql SELECT * FROM `equip_armour` WHERE user = $db.safe($2)
  var %result = $db.query(%sql)
  if ($db.query_row(%result,equiphit) === $null) { echo -s Error fetching equipment - hit %sql }
  db.query_end %result

  var %atk $calc($iif($hget(equiphit,firecape),5,0) + $iif($hget(equiphit,bgloves),3,0))
  var %def $iif($db.get(equip_armour,elshield),$calc($r(85,99) / 100),1)
  var %ratk $calc($iif($hget(equiphit,void),5,0) + $iif($hget(equiphit,accumulator),5,0))
  var %matk $calc($iif($hget(equiphit,void-mage),5,0) + $iif($hget(equiphit,mbook),5,0) + $iif($hget(equiphit,godcape),5,0))

  goto $1
  :whip
  return $hitdmg(m,whip,%acc,1,%atk,%def)
  :dds
  return $hitdmg(m,dds,%acc,2,%atk,%def)
  :ags
  return $hitdmg(m,ags,%acc,1,%atk,%def)
  :cbow
  if (%acc isnum 98-100) && ($hget(equiphit,void) || $hget(equiphit,accumulator)) { set %cbowspec [ $+ [ $2 ] ] 1 | return $r(50,65) }
  return $hitdmg(r,cbow,%acc,1,%ratk,%def)
  :dbow
  return $hitdmg(r,dbow,%acc,2,%ratk,%def)
  :bgs
  return $hitdmg(m,bgs,%acc,1,%atk,%def)
  :sgs
  return $hitdmg(m,sgs,%acc,1,%atk,%def)
  :gmaul
  return $hitdmg(m,gmaul,%acc,3,%atk,%def)
  :guth
  return $hitdmg(m,guth,%acc,1,%atk,%def)
  :ice
  return $hitdmg(ma,ice,%acc,1,%matk,%def)
  :zgs
  return $hitdmg(m,zgs,%acc,1,%atk,%def)
  :blood
  return $hitdmg(ma,blood,%acc,1,%matk,%def)
  :smoke
  return $hitdmg(ma,smoke,%acc,1,%matk,%def)
  :surf
  return $hitdmg(m,surf,%acc,1,0,1)
  :dclaws
  var %dclaws $hitdmg(m,dclaws,%acc,1,%atk,%def)
  return %dclaws $ceil($calc(%dclaws * 0.5)) $ceil($calc(%dclaws * 0.25)) $ceil($calc(%dclaws * 0.125))
  :dmace
  return $hitdmg(m,dmace,%acc,1,%atk,%def)
  :dscim
  return $hitdmg(m,dscim,%acc,1,%atk,%def)
  :dlong
  return $hitdmg(m,dlong,%acc,1,%atk,%def)
  :dhally
  return $hitdmg(m,dhally,%acc,2,%atk,%def)
  :d_h9
  return $hitdmg(m,dh9,%acc,1,%atk,%def)
  :d_h10
  return $hitdmg(m,dh,%acc,1,%atk,%def)
  :vlong
  return $hitdmg(m,vlong,%acc,1,%atk,1)
  :statius
  return $hitdmg(m,statius,%acc,1,%atk,1)
  :vspear
  return $hitdmg(m,vspear,%acc,1,%atk,%def)
  :mjavelin
  return $hitdmg(r,mjavelin,%acc,1,%ratk,%def)
  :onyx
  return $hitdmg(r,onyx,%acc,1,%ratk,%def)
  :gwd
  return $r(0,50)
}

alias hitdmg {
  ; $1 = r/ma/m
  ; $2 = attack
  ; $3 = accuracy
  ; $4 = number of hits
  ; $5 = attack bonus
  ; $6 = defense bonus
  if ($6) {
    var %acclimit $dmg($1,$2)
    if ($3 <= $gettok(%acclimit,1,32)) {
      var %ndmg $dmg($1,$2,1)
    }
    elseif ($3 <= $gettok(%acclimit,2,32)) {
      var %ndmg $dmg($1,$2,2)
    }
    else {
      var %ndmg $dmg($1,$2,3)
    }
    var %i = 0
    while (%i < $4) {
      inc %i
      var %dmg = $rand($gettok(%ndmg,1,44),$calc($gettok(%ndmg,2,44) + $5)))
      var %dmg = $ceil($calc(%dmg * $6))
      var %return = %return %dmg
    }
    return %return
  }
  return
}
