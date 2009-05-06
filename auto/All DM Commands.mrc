on *:TEXT:!*:#iDM.Staff: {
  if (# == #iDM || # == #iDM.Staff) && ($me != iDM) { halt }
  if ($attack($right($1,-1))) { 
    if ($nick == %p1 [ $+ [ $chan ] ] && %turn [ $+ [ $chan ] ] == 1) || ($nick == %p2 [ $+ [ $chan ] ] && %turn [ $+ [ $chan ] ] == 2) {
      if ($calc($specused($right($1,-1)) /25) > $($+(%,sp,$player($nick,#),#),2)) { 
        echo -a $calc($specused($right($1,-1)) /25) > $($+(%,sp,$player($nick,#),#),2))
        notice $nick $logo(ERROR) You need $s1($specused($right($1,-1)) $+ $chr(37)) spec to use this weapon.
        halt
      }
      if ($readini(OnOff.ini,#,$right($1,-1))) { notice $nick $logo(ERROR) This command has been disabled for this channel. | halt }
      if (%stun [ $+ [ $nick ] ]) { 
        msg # $logo(DM) $s1($nick) is stunned and unable to attack. HP $+($chr(91),$s2($iif(%hp $+ $iif($nick == %p1 [ $+ [ # ] ],1,2) [ $+ [ $chan ] ] < 1,0,$v1)),$chr(93)) $hpbar(%hp $+ $iif($nick == %p1 [ $+ [ # ] ],1,2) [ $+ [ $chan ] ]) 
        set %turn [ $+ [ $chan ] ] $iif($nick == %p1 [ $+ [ # ] ],2,1)
        unset %stun [ $+ [ $nick ] ]  
        halt 
      }
      if (%frozen [ $+ [ $nick ] ] == on) && ($max(m,$right($1,-1))) { 
        notice $nick You're frozen and can't use melee.
        halt 
      }
      if ($ini(pvp.ini,$right($1,-1))) {
        if (!$readini(pvp.ini,$right($1,-1),$nick)) {
          notice $nick You don't have this weapon.
          halt
        }
      }
      if ($ini(equipment.ini,$right($1,-1))) {
        if (!$readini(equipment.ini,$right($1,-1),$nick)) {
          notice $nick You have to unlock this weapon before you can use it.
          halt
        }
      }
      damage $nick $iif($nick == %p1 [ $+ [ # ] ],%p2 [ $+ [ # ] ],$v2) $right($1,-1) #
    }
  }
}
alias damage {
  ;1 is person attacking
  ;2 is other person
  ;3 is weapon
  ;4 is chan
  if ($ini(pvp.ini,$3)) {
    if ($readini(PvP.ini,$3,$1) < 1) { remini -n PvP.ini $1 $3 }
    elseif ($readini(PvP.ini,$3,$1) >= 1) { writeini -n PvP.ini $3 $1 $calc($readini(PvP.ini,$3,$1) -1) }
  }
  if ($3 != dh) { 
    var %hit [ $+ [ $4 ] ] $hit($3,$1,$2) 
  }
  elseif ($3 == dh) {
    if ($($+(%,hp,$player($1,$4),$4),2) < 10) { var %hit [ $+ [ $4 ] ] $hit(d_h9,$1,$2) }
    else var %hit [ $+ [ $4 ] ] $hit(d_h10,$1,$2)
  }
  if (!$gettok(%hit [ $+ [ $4 ] ],2,32)) && ($($+(%,hp,$player($2,$4),$4),2) < %hit [ $+ [ $4 ] ]) {
    var %hit [ $+ [ $4 ] ] $($+(%,hp,$player($2,$4),$4),2)
    set $+(%,hp,$player($2,$4),$4) 0
  }
  else {
    dec $+(%,hp,$player($2,$4),$4) $calc($replace(%hit [ $+ [ $4 ] ],$chr(32),$chr(43)))
  }
  unset $+(%,frozen,$1)
  if ($freezer($3)) { 
    var %freeze [ $+ [ $4 ] ] $r(1,$v1) 
  }
  if (%freeze [ $+ [ $4 ] ] == 1) { 
    set $+(%,frozen,$2) on 
    notice $2 You have been frozen and can't use melee!
  }
  if ($gettok($healer($3),1,32)) {
    var %heal [ $+ [ $4 ] ] $r(1,$v1)
  }
  if (%heal [ $+ [ $4 ] ] == 1) {
    $iif($calc($floor($($+(%,hp,$player($1,$4),$4),2)) + $floor($calc($($+(%,hit,$4),2) / $gettok($healer($3),2,32)))) > 99,set $+(%,hp,$player($1,$4),$4) 99,inc $+(%,hp,$player($1,$4),$4) $floor($calc($($+(%,hit,$4),2) / $gettok($healer($3),2,32))))
  }
  if ($readini(sitems.ini,belong,$1)) && ($r(1,30) == 1) { 
    var %sitem.belong [ $+ [ $4 ] ] on
  }
  if ($3 == dds) {
    if ($readini(sitems.ini,snake,$1)) && (!$($+(%,pois,$player($2,$4),$4),2)) {
      set $+(%,pois,$player($2,$4),$4) on
      echo -a $+(%,pois,$player($2,$4),$4) - $($+(%,pois,$player($2,$4),$4),2)
    }
    elseif (!$readini(sitems.ini,snake,$1)) && (!$($+(%,pois,$player($2,$4),$4),2)) && ($r(1,3) == 1) {
      set $+(%,pois,$player($2,$4),$4) on
    }
  }
  goto displaymsg
  :displaymsg
  if ($3 == vlong) { 
    msg $4 $logo(DM) $s1($1) slashes their Vesta's longsword at $s1($2) $+ $chr(44) hitting $s2(%hit [ $+ [ $4 ] ]) $+ . HP $+($chr(91),$s2($iif($($+(%,hp,$player($2,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($2,$4),$4)))
  }
  if ($3 == vspear) {
    msg $4 $logo(DM) $s1($1) 12freezes $s1($2) using a Vesta's spear, and hits $s2(%hit [ $+ [ $chan ] ]) $+ . HP $+($chr(91),$s2($iif($($+(%,hp,$player($2,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($2,$4),$4)))
  }
  if ($3 == statius) {
    msg $4 $logo(DM) $s1($1) critically hits $s1($2) with a Statius's warhammer, hitting $s2(%hit [ $+ [ $4 ] ]) $+ . HP $+($chr(91),$s2($iif($($+(%,hp,$player($2,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($2,$4),$4)))
  }
  if ($3 == mjavelin) {
    msg $4 $logo(DM) $s1($1) throws a Morrigan's javelin at $s1($2) hitting $s2(%hit [ $+ [ $4 ] ]) $+ . HP $+($chr(91),$s2($iif($($+(%,hp,$player($2,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($2,$4),$4)))
  }
  if ($3 == sgs) {
    msg $4 $logo(DM) $s1($1) crushes their godsword down on $s1($2) and hit $s2(%hit [ $+ [ $4 ] ]) $+ . HP $s2($2) $+($chr(91),$s2($iif($($+(%,hp,$player($2,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($2,$4),$4))) - HP $s2($1) $+($chr(91),$s2($iif($($+(%,hp,$player($1,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($1,$4),$4)))
  }
  if ($3 == ags) {
    msg $4 $logo(DM) $s1($1) spins around and slashes at $s1($2) with an Armadyl godsword, speccing $s2(%hit [ $+ [ $4 ] ]) $+ . HP $+($chr(91),$s2($iif($($+(%,hp,$player($2,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($2,$4),$4)))
  }
  if ($3 == zgs) {
    msg $4 $logo(DM) $s1($1) attempts to freeze $s1($2) $iif(%freeze [ $+ [ $4 ] ] == 1,and successfully 12FROZE them,but failed to) $+ $chr(44) hitting $s2(%hit [ $+ [ $4 ] ]) $+ . HP $+($chr(91),$s2($iif($($+(%,hp,$player($2,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($2,$4),$4)))
  }
  if ($3 == bgs) {
    msg $4 $logo(DM) $s1($1) crushes their godsword down on $s1($2) and hit $s2(%hit [ $+ [ $4 ] ]) $+ . HP $+($chr(91),$s2($iif($($+(%,hp,$player($2,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($2,$4),$4)))
  }
  if ($3 == guth) {
    msg $4 $logo(DM) $s1($1) $iif(%heal [ $+ [ $4 ] ] == 1,09HEALS on,fails to heal on) $s1($2) $iif(%heal [ $+ [ $4 ] ] == 1,and hits,but hits) $s2(%hit [ $+ [ $4 ] ]) $+ . HP $s2($2) $+($chr(91),$s2($iif($($+(%,hp,$player($2,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($2,$4),$4))) - HP $s2($1) $+($chr(91),$s2($iif($($+(%,hp,$player($1,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($1,$4),$4)))
  }
  if ($3 == blood) {
    msg $4 $logo(DM) $s1($1) casts blood barrage on $s1($2) $iif(%hit [ $+ [ $4 ] ] == 0, and splashed.,hitting $s2(%hit [ $+ [ $4 ] ]) $+ .) HP $s2($2) $+($chr(91),$s2($iif($($+(%,hp,$player($2,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($2,$4),$4))) - HP $s2($1) $+($chr(91),$s2($iif($($+(%,hp,$player($1,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($1,$4),$4)))
  }
  if ($3 == ice) {
    msg $4 $logo(DM) $s1($1) casts ice barrage on $s1($2) $iif(%freeze [ $+ [ $4 ] ] == 1,(12FROZEN)) $iif(%hit [ $+ [ $4 ] ] == 0, and splashed.,surrounding them in an ice cube $+ $chr(44) hitting $s2(%hit [ $+ [ $4 ] ]) $+ .) HP $+($chr(91),$s2($iif($($+(%,hp,$player($2,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($2,$4),$4)))
  }
  if ($3 == cbow) {
    msg $4 $logo(DM) $s1($1) $iif(%cbowspec [ $+ [ $1 ] ],5UNLEASHES a dragon bolt special on,shoots a dragon bolt at) $s1($2) with a rune c'bow, hitting $s2(%hit [ $+ [ $4 ] ]) $+ . HP $+($chr(91),$s2($iif($($+(%,hp,$player($2,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($2,$4),$4)))
    unset %cbowspec [ $+ [ $1 ] ]
  }
  if ($3 == dbow) {
    msg $4 $logo(DM) $s1($1) fires two dragon arrows towards $s1($2) $+ , speccing  $s2($gettok(%hit [ $+ [ $4 ] ],1,32)) - $s2($gettok(%hit [ $+ [ $4 ] ],2,32)) $+ . HP $+($chr(91),$s2($iif($($+(%,hp,$player($2,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($2,$4),$4)))
  }
  if ($3 == whip) {
    msg $4 $logo(DM) $s1($1) slashes $s1($2) with their abyssal whip, hitting $s2(%hit [ $+ [ $4 ] ]) $+ . HP $+($chr(91),$s2($iif($($+(%,hp,$player($2,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($2,$4),$4)))
  }
  if ($3 == dds) {
    msg $4 $logo(DM) $s1($1) stabs $s1($2) with a dragon dagger, hitting $s2($gettok(%hit [ $+ [ $4 ] ],1,32)) - $s2($gettok(%hit [ $+ [ $4 ] ],2,32)) $+ . HP $+($chr(91),$s2($iif($($+(%,hp,$player($2,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($2,$4),$4)))
  }
  if ($3 == dclaws) {
    msg $4 $logo(DM) $s1($1) scratches $s1($2) with their dragon claws, hitting $s2($gettok(%hit [ $+ [ $4 ] ],1,32)) - $s2($gettok(%hit [ $+ [ $4 ] ],2,32)) - $s2($gettok(%hit [ $+ [ $4 ] ],3,32)) - $s2($gettok(%hit [ $+ [ $4 ] ],4,32)) $+ . HP $+($chr(91),$s2($iif($($+(%,hp,$player($2,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($2,$4),$4)))
  }
  if ($3 == surf) {
    msg $4 $logo(DM) $s1($1) summons their mudkip, surfing at $s1($2) $+ , hitting $s2(%hit [ $+ [ $4 ] ]) $+ . HP $+($chr(91),$s2($iif($($+(%,hp,$player($2,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($2,$4),$4)))
  }
  if ($3 == gmaul) {
    msg $4 $logo(DM) $s1($1) whacks $s1($2) with their granite maul, speccing $s2($gettok(%hit [ $+ [ $4 ] ],1,32)) - $s2($gettok(%hit [ $+ [ $4 ] ],2,32)) - $s2($gettok(%hit [ $+ [ $4 ] ],3,32)) $+ . HP $+($chr(91),$s2($iif($($+(%,hp,$player($2,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($2,$4),$4)))
  }
  if ($3 == dh) {
    msg $4 $logo(DM) $s1($1) crushes $s1($2) with their great axe, and hit $s2(%hit [ $+ [ $4 ] ]) $+ . HP $+($chr(91),$s2($iif($($+(%,hp,$player($2,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($2,$4),$4)))
  }
  if ($3 == dspear || $3 == dhally || $3 == anchor || $3 == ssword) {
    ;remove this when $attack has been updated
    halt
  }
  if ($specused($3)) { 
    dec $+(%,sp,$player($1,$4),$4) $calc($specused($3) /25) 
    notice $1 Specbar: $iif($($+(%,sp,$player($1,$4),$4),2) < 1,0,$gettok(25 50 75 100,$($+(%,sp,$player($1,$4),$4),2),32)) $+ $chr(37)
  }
  if ($($+(%,pois,$player($2,$4),$4),2)) && ($($+(%,hp,$player($2,$4),$4),2) >= 1) {
    var %extra [ $+ [ $4 ] ] $iif($($+(%,hp,$player($2,$4),$4),2) < 6,$($v1,2),6)
    dec $+(%,hp,$player($2,$4),$4) %extra [ $+ [ $4 ] ]
    msg $4 $logo(DM) $s1($2) is 03poisoned, and lost $s2(%extra [ $+ [ $4 ] ]) HP. HP $+($chr(91),$s2($iif($($+(%,hp,$player($2,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($2,$4),$4)))
  }
  if (%sitem.belong [ $+ [ $4 ] ] == on) && ($($+(%,hp,$player($2,$4),$4),2) >= 1) {
    var %extra [ $+ [ $4 ] ] $iif($($+(%,hp,$player($2,$4),$4),2) < 10,$($v1,2),10)
    dec $+(%,hp,$player($2,$4),$4) %extra [ $+ [ $4 ] ]
    msg $4 $logo(DM) $s1($1) whips out their Bêlong Blade and deals $s2(%extra [ $+ [ $4 ] ]) extra damage. HP $+($chr(91),$s2($iif($($+(%,hp,$player($2,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($2,$4),$4)))
  }
  if ($readini(sitems.ini,kh,$2)) && ($r(1,30) == 1) {
    inc $+(%,hp,$player($2,$4),$4) $calc($replace(%hit [ $+ [ $4 ] ],$chr(32),$chr(43)))
    msg $4 $logo(DM) KHobbits uses his KHonfound Ring to let $s1($2) avoid the attack. HP $+($chr(91),$s2($iif($($+(%,hp,$player($2,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($2,$4),$4)))
    set %turn [ $+ [ $4 ] ] $iif($player($1,$4) == 1,2,1)
  }
  if ($readini(sitems.ini,allegra,$2)) && ($r(1,30) == 1) && ($($+(%,hp,$player($2,$4),$4),2) >= 1) {
    var %allegra.heal [ $+ [ $4 ] ] $iif($($+(%,hp,$player($2,$4),$4),2) >= 89,$calc(99- $($+(%,hp,$player($2,$4),$4),2)),10)
    inc $+(%,hp,$player($2,$4),$4) %allegra.heal [ $+ [ $4 ] ]
    msg $4 $logo(DM) Allêgra gives $s1($2) Allergy pills, healing $s2(%allegra.heal [ $+ [ $4 ] ]) HP. HP $+($chr(91),$s2($iif($($+(%,hp,$player($2,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($2,$4),$4)))
  }
  if ($($+(%,hp,$player($2,$4),$4),2) < 1) { 
    if ($readini(sitems.ini,beau,$2)) && ($r(1,15) == 1) { 
      set $+(%,hp,$player($2,$4),$4) 1
      msg $4 $logo(DM) $s1($2) $+ 's Bêaumerang brings them back to life, barely. HP $+($chr(91),$s2($iif($($+(%,hp,$player($2,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($2,$4),$4)))
      set %turn [ $+ [ $4 ] ] $iif($player($1,$4) == 1,2,1)
      halt
    }
    dead $4 $2 $1
    halt 
  }
  set %turn [ $+ [ $4 ] ] $iif($player($1,$4) == 1,2,1)
}
alias player {
  if ($1 == %p1 [ $+ [ $2 ] ]) { return 1 }
  if ($1 == %p2 [ $+ [ $2 ] ]) { return 2 }
}
on *:TEXT:!eat:#: {
  if (# == #iDM || # == #iDM.Staff) && ($me != iDM) { halt }
  if ($nick == %p1 [ $+ [ $chan ] ]) && (%turn [ $+ [ $chan ] ] == 1) {
    notice $nick $logo(ERROR) Eat has been $s2(disabled)
  }
  if ($nick == %p2 [ $+ [ $chan ] ]) && (%turn [ $+ [ $chan ] ] == 2) {
    notice $nick $logo(ERROR) Eat has been $s2(disabled)
  }
}

on *:TEXT:!whip:#: {
  if (# == #iDM || # == #iDM.Staff) && ($me != iDM) { halt }
  if ($nick == %p1 [ $+ [ $chan ] ]) && (%turn [ $+ [ $chan ] ] == 1) {
    if ($readini(OnOff.ini,#,$right($1,-1))) { notice $nick $logo(ERROR) This command has been disabled for this channel. | halt }
    if (%stun [ $+ [ $nick ] ]) { msg # $logo(DM) $s1($nick) is stunned and unable to attack. HP $+($chr(91),$s2($iif(%hp1 [ $+ [ $chan ] ] < 1,0,$v1)),$chr(93)) $hpbar(%hp1 [ $+ [ $chan ] ]) | set %turn [ $+ [ $chan ] ] 2 | unset %stun [ $+ [ $nick ] ]  | halt }
    if (%frozen [ $+ [ $nick ] ] == on) { notice $nick You're frozen and can't use melee. | halt }
    var %whiphit [ $+ [ $chan ] ] $hit(whip,%p1 [ $+ [ $chan ] ],%p2 [ $+ [ $chan ] ])
    if (%hp2 [ $+ [ $chan ] ] < %whiphit [ $+ [ $chan ] ]) { set %whiphit [ $+ [ $chan ] ] %hp2 [ $+ [ $chan ] ] }
    dec %hp2 [ $+ [ $chan ] ] %whiphit [ $+ [ $chan ] ]
    unset %frozen [ $+ [ %p1 [ $+ [ $chan ] ] ] ] | unset %frozen [ $+ [ %p2 [ $+ [ $chan ] ] ] ]
    msg # $logo(DM) $s1($nick) slashes $s1(%p2 [ $+ [ $chan ] ]) with their abyssal whip, hitting $s2(%whiphit [ $+ [ $chan ] ]) $+ . HP $+($chr(91),$s2($iif(%hp2 [ $+ [ $chan ] ] < 1,0,$v1)),$chr(93)) $hpbar(%hp2 [ $+ [ $chan ] ])
    set %turn [ $+ [ $chan ] ] 2
    if (%hp2 [ $+ [ $chan ] ] < 1) { dead # %p2 [ $+ [ $chan ] ] $nick | halt }
    if (%veng [ $+ [ %p2 [ $+ [ $chan ] ] ] ]) { veng %p2 [ $+ [ $chan ] ] $nick $chan % [ $+ [ $remove($1,$chr(33)) ] ] [ $+ [ hit ] ] [ $+ [ $chan ] ] }
  }
  if ($nick == %p2 [ $+ [ $chan ] ]) && (%turn [ $+ [ $chan ] ] == 2) {
    if ($readini(OnOff.ini,#,$right($1,-1))) { notice $nick $logo(ERROR) This command has been disabled for this channel. | halt }
    if (%stun [ $+ [ $nick ] ]) { msg # $logo(DM) $s1($nick) is stunned and unable to attack. HP $+($chr(91),$s2($iif(%hp2 [ $+ [ $chan ] ] < 1,0,$v1)),$chr(93)) $hpbar(%hp2 [ $+ [ $chan ] ]) | set %turn [ $+ [ $chan ] ] 1 | unset %stun [ $+ [ $nick ] ]  | halt }
    if (%frozen [ $+ [ $nick ] ] == on) { notice $nick You're frozen and can't use melee. | halt }
    var %whiphit [ $+ [ $chan ] ] $hit(whip,%p2 [ $+ [ $chan ] ],%p1 [ $+ [ $chan ] ])
    if (%hp1 [ $+ [ $chan ] ] < %whiphit [ $+ [ $chan ] ]) { set %whiphit [ $+ [ $chan ] ] %hp1 [ $+ [ $chan ] ] }
    dec %hp1 [ $+ [ $chan ] ] %whiphit [ $+ [ $chan ] ]
    unset %frozen [ $+ [ %p1 [ $+ [ $chan ] ] ] ] | unset %frozen [ $+ [ %p2 [ $+ [ $chan ] ] ] ]
    msg # $logo(DM) $s1($nick) slashes $s1(%p1 [ $+ [ $chan ] ]) with their abyssal whip, hitting $s2(%whiphit [ $+ [ $chan ] ]) $+ . HP $+($chr(91),$s2($iif(%hp1 [ $+ [ $chan ] ] < 1,0,$v1)),$chr(93)) $hpbar(%hp1 [ $+ [ $chan ] ])
    set %turn [ $+ [ $chan ] ] 1
    if (%hp1 [ $+ [ $chan ] ] < 1) { dead # %p1 [ $+ [ $chan ] ] $nick | halt }
    if (%veng [ $+ [ %p1 [ $+ [ $chan ] ] ] ]) { veng %p1 [ $+ [ $chan ] ] $nick $chan % [ $+ [ $remove($1,$chr(33)) ] ] [ $+ [ hit ] ] [ $+ [ $chan ] ] }
  }
}
on *:TEXT:!dds:#: {
  if (# == #iDM || # == #iDM.Staff) && ($me != iDM) { halt }
  if ($nick == %p1 [ $+ [ $chan ] ]) && (%turn [ $+ [ $chan ] ] == 1) {
    if ($readini(OnOff.ini,#,$right($1,-1))) { notice $nick $logo(ERROR) This command has been disabled for this channel. | halt }
    if (%stun [ $+ [ $nick ] ]) { msg # $logo(DM) $s1($nick) is stunned and unable to attack. HP $+($chr(91),$s2($iif(%hp1 [ $+ [ $chan ] ] < 1,0,$v1)),$chr(93)) $hpbar(%hp1 [ $+ [ $chan ] ]) | set %turn [ $+ [ $chan ] ] 2 | unset %stun [ $+ [ $nick ] ]  | halt }
    if (%frozen [ $+ [ $nick ] ] == on) { notice $nick You're frozen and can't use melee. | halt }
    if (%sp1 [ $+ [ $chan ] ] < 1) { notice $nick You need 25% special to do this. | halt }
    dec %sp1 [ $+ [ $chan ] ]
    var %ddshit [ $+ [ $chan ] ] $hit(dds,%p1 [ $+ [ $chan ] ],%p2 [ $+ [ $chan ] ])
    if (%hp2 [ $+ [ $chan ] ] < $calc($gettok(%ddshit [ $+ [ $chan ] ],1,32) + $gettok(%ddshit [ $+ [ $chan ] ],2,32))) { set %hp2 [ $+ [ $chan ] ] 0 }
    if (%hp2 [ $+ [ $chan ] ] >= 1) { dec %hp2 [ $+ [ $chan ] ] $gettok(%ddshit [ $+ [ $chan ] ],1,32) | dec %hp2 [ $+ [ $chan ] ] $gettok(%ddshit [ $+ [ $chan ] ],2,32) }
    unset %frozen [ $+ [ %p1 [ $+ [ $chan ] ] ] ] | unset %frozen [ $+ [ %p2 [ $+ [ $chan ] ] ] ]
    msg # $logo(DM) $s1($nick) stabs $s1(%p2 [ $+ [ $chan ] ]) with a dragon dagger, hitting $s2($gettok(%ddshit [ $+ [ $chan ] ],1,32)) - $s2($gettok(%ddshit [ $+ [ $chan ] ],2,32)) $+ . HP $+($chr(91),$s2($iif(%hp2 [ $+ [ $chan ] ] < 1,0,$v1)),$chr(93)) $hpbar(%hp2 [ $+ [ $chan ] ])
    notice $nick Specbar: $iif(%sp1 [ $+ [ $chan ] ] < 1,0,$gettok(25 50 75 100,%sp1 [ $+ [ $chan ] ],32)) $+ $chr(37)
    set %turn [ $+ [ $chan ] ] 2
    if (%hp2 [ $+ [ $chan ] ] < 1) { dead # %p2 [ $+ [ $chan ] ] $nick | halt }
    if (%veng [ $+ [ %p2 [ $+ [ $chan ] ] ] ]) { veng %p2 [ $+ [ $chan ] ] $nick $chan % [ $+ [ $remove($1,$chr(33)) ] ] [ $+ [ hit ] ] [ $+ [ $chan ] ] }
  }
  if ($nick == %p2 [ $+ [ $chan ] ]) && (%turn [ $+ [ $chan ] ] == 2) {
    if ($readini(OnOff.ini,#,$right($1,-1))) { notice $nick $logo(ERROR) This command has been disabled for this channel. | halt }
    if (%stun [ $+ [ $nick ] ]) { msg # $logo(DM) $s1($nick) is stunned and unable to attack. HP $+($chr(91),$s2($iif(%hp2 [ $+ [ $chan ] ] < 1,0,$v1)),$chr(93)) $hpbar(%hp2 [ $+ [ $chan ] ]) | set %turn [ $+ [ $chan ] ] 1 | unset %stun [ $+ [ $nick ] ]  | halt }
    if (%frozen [ $+ [ $nick ] ] == on) { notice $nick You're frozen and can't use melee. | halt }
    if (%sp2 [ $+ [ $chan ] ] < 1) { notice $nick You need 25% special to do this. | halt }
    dec %sp2 [ $+ [ $chan ] ]
    var %ddshit [ $+ [ $chan ] ] $hit(dds,%p2 [ $+ [ $chan ] ],%p1 [ $+ [ $chan ] ])
    if (%hp1 [ $+ [ $chan ] ] < $calc($gettok(%ddshit [ $+ [ $chan ] ],1,32) + $gettok(%ddshit [ $+ [ $chan ] ],2,32))) { set %hp1 [ $+ [ $chan ] ] 0 }
    if (%hp1 [ $+ [ $chan ] ] >= 1) { dec %hp1 [ $+ [ $chan ] ] $gettok(%ddshit [ $+ [ $chan ] ],1,32) | dec %hp1 [ $+ [ $chan ] ] $gettok(%ddshit [ $+ [ $chan ] ],2,32) }
    unset %frozen [ $+ [ %p1 [ $+ [ $chan ] ] ] ] | unset %frozen [ $+ [ %p2 [ $+ [ $chan ] ] ] ]
    msg # $logo(DM) $s1($nick) stabs $s1(%p1 [ $+ [ $chan ] ]) with a dragon dagger, speccing $s2($gettok(%ddshit [ $+ [ $chan ] ],1,32)) - $s2($gettok(%ddshit [ $+ [ $chan ] ],2,32)) $+ . HP $+($chr(91),$s2($iif(%hp1 [ $+ [ $chan ] ] < 1,0,$v1)),$chr(93)) $hpbar(%hp1 [ $+ [ $chan ] ])
    notice $nick Specbar: $iif(%sp2 [ $+ [ $chan ] ] < 1,0,$gettok(25 50 75 100,%sp2 [ $+ [ $chan ] ],32)) $+ $chr(37)
    set %turn [ $+ [ $chan ] ] 1
    if (%hp1 [ $+ [ $chan ] ] < 1) { dead # %p1 [ $+ [ $chan ] ] $nick | halt }
    if (%veng [ $+ [ %p1 [ $+ [ $chan ] ] ] ]) { veng %p1 [ $+ [ $chan ] ] $nick $chan % [ $+ [ $remove($1,$chr(33)) ] ] [ $+ [ hit ] ] [ $+ [ $chan ] ] }
  }
}
on *:TEXT:!ags:#: {
  if (# == #iDM || # == #iDM.Staff) && ($me != iDM) { halt }
  if ($nick == %p1 [ $+ [ $chan ] ]) && (%turn [ $+ [ $chan ] ] == 1) {
    if (!$readini(Equipment.ini,ags,$nick)) { notice $nick You have to buy this weapon before you can use it. !buy $remove($1,!) $+ . | halt }
    if ($readini(OnOff.ini,#,$right($1,-1))) { notice $nick $logo(ERROR) This command has been disabled for this channel. | halt }
    if (%stun [ $+ [ $nick ] ]) { msg # $logo(DM) $s1($nick) is stunned and unable to attack. HP $+($chr(91),$s2($iif(%hp1 [ $+ [ $chan ] ] < 1,0,$v1)),$chr(93)) $hpbar(%hp1 [ $+ [ $chan ] ]) | set %turn [ $+ [ $chan ] ] 2 | unset %stun [ $+ [ $nick ] ]  | halt }
    if (%frozen [ $+ [ $nick ] ] == on) { notice $nick You're frozen and can't use melee. | halt }
    if (%sp1 [ $+ [ $chan ] ] < 2) { notice $nick You need 50% special to do this. | halt }
    dec %sp1 [ $+ [ $chan ] ] 2
    var %agshit [ $+ [ $chan ] ] $hit(ags,%p1 [ $+ [ $chan ] ],%p2 [ $+ [ $chan ] ])
    if (%hp2 [ $+ [ $chan ] ] < %agshit [ $+ [ $chan ] ]) {  set %agshit [ $+ [ $chan ] ] %hp2 [ $+ [ $chan ] ] | set %hp2 [ $+ [ $chan ] ] 0 }
    if (%hp2 [ $+ [ $chan ] ] >= 1) { dec %hp2 [ $+ [ $chan ] ] %agshit [ $+ [ $chan ] ] }
    unset %frozen [ $+ [ %p1 [ $+ [ $chan ] ] ] ] | unset %frozen [ $+ [ %p2 [ $+ [ $chan ] ] ] ]
    msg # $logo(DM) $s1($nick) spins around and slashes at $s1(%p2 [ $+ [ $chan ] ]) with an Armadyl godsword, speccing $s2(%agshit [ $+ [ $chan ] ]) $+ . HP $+($chr(91),$s2($iif(%hp2 [ $+ [ $chan ] ] < 1,0,$v1)),$chr(93)) $hpbar(%hp2 [ $+ [ $chan ] ])
    notice $nick Specbar: $iif(%sp1 [ $+ [ $chan ] ] < 1,0,$gettok(25 50 75 100,%sp1 [ $+ [ $chan ] ],32)) $+ $chr(37)
    set %turn [ $+ [ $chan ] ] 2
    if (%hp2 [ $+ [ $chan ] ] < 1) { dead # %p2 [ $+ [ $chan ] ] $nick | halt }
    if (%veng [ $+ [ %p2 [ $+ [ $chan ] ] ] ]) { veng %p2 [ $+ [ $chan ] ] $nick $chan % [ $+ [ $remove($1,$chr(33)) ] ] [ $+ [ hit ] ] [ $+ [ $chan ] ] }
  }
  if ($nick == %p2 [ $+ [ $chan ] ]) && (%turn [ $+ [ $chan ] ] == 2) {
    if (!$readini(Equipment.ini,ags,$nick)) { notice $nick You have to buy this weapon before you can use it. !buy $remove($1,!) $+ . | halt }
    if ($readini(OnOff.ini,#,$right($1,-1))) { notice $nick $logo(ERROR) This command has been disabled for this channel. | halt }
    if (%stun [ $+ [ $nick ] ]) { msg # $logo(DM) $s1($nick) is stunned and unable to attack. HP $+($chr(91),$s2($iif(%hp2 [ $+ [ $chan ] ] < 1,0,$v1)),$chr(93)) $hpbar(%hp2 [ $+ [ $chan ] ]) | set %turn [ $+ [ $chan ] ] 1 | unset %stun [ $+ [ $nick ] ]  | halt }
    if (%frozen [ $+ [ $nick ] ] == on) { notice $nick You're frozen and can't use melee. | halt }
    if (%sp2 [ $+ [ $chan ] ] < 2) { notice $nick You need 50% special to do this. | halt }
    dec %sp2 [ $+ [ $chan ] ] 2
    var %agshit [ $+ [ $chan ] ] $hit(ags,%p2 [ $+ [ $chan ] ],%p1 [ $+ [ $chan ] ])
    if (%hp1 [ $+ [ $chan ] ] < %agshit [ $+ [ $chan ] ]) {  set %agshit [ $+ [ $chan ] ] %hp1 [ $+ [ $chan ] ] | set %hp1 [ $+ [ $chan ] ] 0 }
    if (%hp1 [ $+ [ $chan ] ] >= 1) { dec %hp1 [ $+ [ $chan ] ] %agshit [ $+ [ $chan ] ] }
    unset %frozen [ $+ [ %p1 [ $+ [ $chan ] ] ] ] | unset %frozen [ $+ [ %p2 [ $+ [ $chan ] ] ] ]
    msg # $logo(DM) $s1($nick) spins around and slashes at $s1(%p1 [ $+ [ $chan ] ]) with an Armadyl godsword, speccing $s2(%agshit [ $+ [ $chan ] ]) $+ . HP $+($chr(91),$s2($iif(%hp1 [ $+ [ $chan ] ] < 1,0,$v1)),$chr(93)) $hpbar(%hp1 [ $+ [ $chan ] ])
    notice $nick Specbar: $iif(%sp2 [ $+ [ $chan ] ] < 1,0,$gettok(25 50 75 100,%sp2 [ $+ [ $chan ] ],32)) $+ $chr(37)
    set %turn [ $+ [ $chan ] ] 1
    if (%hp1 [ $+ [ $chan ] ] < 1) { dead # %p1 [ $+ [ $chan ] ] $nick | halt }
    if (%veng [ $+ [ %p1 [ $+ [ $chan ] ] ] ]) { veng %p1 [ $+ [ $chan ] ] $nick $chan % [ $+ [ $remove($1,$chr(33)) ] ] [ $+ [ hit ] ] [ $+ [ $chan ] ] }
  }
}
on *:TEXT:!cbow:#: {
  if (# == #iDM || # == #iDM.Staff) && ($me != iDM) { halt }
  if ($nick == %p1 [ $+ [ $chan ] ]) && (%turn [ $+ [ $chan ] ] == 1) {
    if ($readini(OnOff.ini,#,$right($1,-1))) { notice $nick $logo(ERROR) This command has been disabled for this channel. | halt }
    var %cbowhit [ $+ [ $chan ] ] $hit(cbow,%p1 [ $+ [ $chan ] ],%p2 [ $+ [ $chan ] ])
    if (%hp2 [ $+ [ $chan ] ] < %cbowhit [ $+ [ $chan ] ]) { set %cbowhit [ $+ [ $chan ] ] %hp2 [ $+ [ $chan ] ] }
    dec %hp2 [ $+ [ $chan ] ] %cbowhit [ $+ [ $chan ] ]
    unset %frozen [ $+ [ %p1 [ $+ [ $chan ] ] ] ] | unset %frozen [ $+ [ %p2 [ $+ [ $chan ] ] ] ]
    msg # $logo(DM) $s1($nick) $iif(%cbowspec [ $+ [ $nick ] ],5UNLEASHES a dragon bolt special on,shoots a dragon bolt at) $s1(%p2 [ $+ [ $chan ] ]) with a rune c'bow, hitting $s2(%cbowhit [ $+ [ $chan ] ]) $+ . HP $+($chr(91),$s2($iif(%hp2 [ $+ [ $chan ] ] < 1,0,$v1)),$chr(93)) $hpbar(%hp2 [ $+ [ $chan ] ])
    unset %cbowspec [ $+ [ $nick ] ]
    set %turn [ $+ [ $chan ] ] 2
    if (%hp2 [ $+ [ $chan ] ] < 1) { dead # %p2 [ $+ [ $chan ] ] $nick | halt }
    if (%veng [ $+ [ %p2 [ $+ [ $chan ] ] ] ]) { veng %p2 [ $+ [ $chan ] ] $nick $chan % [ $+ [ $remove($1,$chr(33)) ] ] [ $+ [ hit ] ] [ $+ [ $chan ] ] }
  }
  if ($nick == %p2 [ $+ [ $chan ] ]) && (%turn [ $+ [ $chan ] ] == 2) {
    if ($readini(OnOff.ini,#,$right($1,-1))) { notice $nick $logo(ERROR) This command has been disabled for this channel. | halt }
    var %cbowhit [ $+ [ $chan ] ] $hit(cbow,%p2 [ $+ [ $chan ] ],%p1 [ $+ [ $chan ] ])
    if (%hp1 [ $+ [ $chan ] ] < %cbowhit [ $+ [ $chan ] ]) { set %cbowhit [ $+ [ $chan ] ] %hp1 [ $+ [ $chan ] ] }
    dec %hp1 [ $+ [ $chan ] ] %cbowhit [ $+ [ $chan ] ]
    unset %frozen [ $+ [ %p1 [ $+ [ $chan ] ] ] ] | unset %frozen [ $+ [ %p2 [ $+ [ $chan ] ] ] ]
    msg # $logo(DM) $s1($nick) $iif(%cbowspec [ $+ [ $nick ] ],5UNLEASHES a dragon bolt special on,shoots a dragon bolt at) $s1(%p1 [ $+ [ $chan ] ]) with a rune c'bow, hitting $s2(%cbowhit [ $+ [ $chan ] ]) $+ . HP $+($chr(91),$s2($iif(%hp1 [ $+ [ $chan ] ] < 1,0,$v1)),$chr(93)) $hpbar(%hp1 [ $+ [ $chan ] ])
    unset %cbowspec [ $+ [ $nick ] ]
    set %turn [ $+ [ $chan ] ] 1
    if (%hp1 [ $+ [ $chan ] ] < 1) { dead # %p1 [ $+ [ $chan ] ] $nick | halt }
    if (%veng [ $+ [ %p1 [ $+ [ $chan ] ] ] ]) { veng %p1 [ $+ [ $chan ] ] $nick $chan % [ $+ [ $remove($1,$chr(33)) ] ] [ $+ [ hit ] ] [ $+ [ $chan ] ] }
  }
}
on *:TEXT:!dbow:#: {
  if (# == #iDM || # == #iDM.Staff) && ($me != iDM) { halt }
  if ($nick == %p1 [ $+ [ $chan ] ]) && (%turn [ $+ [ $chan ] ] == 1) {
    if ($readini(OnOff.ini,#,$right($1,-1))) { notice $nick $logo(ERROR) This command has been disabled for this channel. | halt }
    if (%sp1 [ $+ [ $chan ] ] < 3) { notice $nick You need 75% special to do this. | halt }
    dec %sp1 [ $+ [ $chan ] ] 3
    var %dbowhit [ $+ [ $chan ] ] $hit(dbow,%p1 [ $+ [ $chan ] ],%p2 [ $+ [ $chan ] ])
    if (%hp2 [ $+ [ $chan ] ] < $calc($gettok(%dbowhit [ $+ [ $chan ] ],1,32) + $gettok(%dbowhit [ $+ [ $chan ] ],2,32))) { set %hp2 [ $+ [ $chan ] ] 0 }
    if (%hp2 [ $+ [ $chan ] ] >= 1) { dec %hp2 [ $+ [ $chan ] ] $gettok(%dbowhit [ $+ [ $chan ] ],1,32) | dec %hp2 [ $+ [ $chan ] ] $gettok(%dbowhit [ $+ [ $chan ] ],2,32) }
    unset %frozen [ $+ [ %p1 [ $+ [ $chan ] ] ] ] | unset %frozen [ $+ [ %p2 [ $+ [ $chan ] ] ] ]
    msg # $logo(DM) $s1($nick) fires two dragon arrows towards $s1(%p2 [ $+ [ $chan ] ]) $+ , speccing  $s2($gettok(%dbowhit [ $+ [ $chan ] ],1,32)) - $s2($gettok(%dbowhit [ $+ [ $chan ] ],2,32)) $+ . HP $+($chr(91),$s2($iif(%hp2 [ $+ [ $chan ] ] < 1,0,$v1)),$chr(93)) $hpbar(%hp2 [ $+ [ $chan ] ])
    notice $nick Specbar: $iif(%sp1 [ $+ [ $chan ] ] < 1,0,$gettok(25 50 75 100,%sp1 [ $+ [ $chan ] ],32)) $+ $chr(37)
    set %turn [ $+ [ $chan ] ] 2
    if (%hp2 [ $+ [ $chan ] ] < 1) { dead # %p2 [ $+ [ $chan ] ] $nick | halt }
    if (%veng [ $+ [ %p2 [ $+ [ $chan ] ] ] ]) { veng %p2 [ $+ [ $chan ] ] $nick $chan % [ $+ [ $remove($1,$chr(33)) ] ] [ $+ [ hit ] ] [ $+ [ $chan ] ] }
  }
  if ($nick == %p2 [ $+ [ $chan ] ]) && (%turn [ $+ [ $chan ] ] == 2) {
    if ($readini(OnOff.ini,#,$right($1,-1))) { notice $nick $logo(ERROR) This command has been disabled for this channel. | halt }
    if (%sp2 [ $+ [ $chan ] ] < 3) { notice $nick You need 75% special to do this. | halt }
    dec %sp2 [ $+ [ $chan ] ] 3
    var %dbowhit [ $+ [ $chan ] ] $hit(dbow,%p2 [ $+ [ $chan ] ],%p1 [ $+ [ $chan ] ])
    if (%hp1 [ $+ [ $chan ] ] < $calc($gettok(%dbowhit [ $+ [ $chan ] ],1,32) + $gettok(%dbowhit [ $+ [ $chan ] ],2,32))) { set %hp1 [ $+ [ $chan ] ] 0 }
    if (%hp1 [ $+ [ $chan ] ] >= 1) { dec %hp1 [ $+ [ $chan ] ] $gettok(%dbowhit [ $+ [ $chan ] ],1,32) | dec %hp1 [ $+ [ $chan ] ] $gettok(%dbowhit [ $+ [ $chan ] ],2,32) }
    unset %frozen [ $+ [ %p1 [ $+ [ $chan ] ] ] ] | unset %frozen [ $+ [ %p2 [ $+ [ $chan ] ] ] ]
    msg # $logo(DM) $s1($nick) fires two dragon arrows towards $s1(%p1 [ $+ [ $chan ] ]) $+ , speccing $s2($gettok(%dbowhit [ $+ [ $chan ] ],1,32)) - $s2($gettok(%dbowhit [ $+ [ $chan ] ],2,32)) $+ . HP $+($chr(91),$s2($iif(%hp1 [ $+ [ $chan ] ] < 1,0,$v1)),$chr(93)) $hpbar(%hp1 [ $+ [ $chan ] ])
    notice $nick Specbar: $iif(%sp2 [ $+ [ $chan ] ] < 1,0,$gettok(25 50 75 100,%sp2 [ $+ [ $chan ] ],32)) $+ $chr(37)
    set %turn [ $+ [ $chan ] ] 1
    if (%hp1 [ $+ [ $chan ] ] < 1) { dead # %p1 [ $+ [ $chan ] ] $nick | halt }
    if (%veng [ $+ [ %p1 [ $+ [ $chan ] ] ] ]) { veng %p1 [ $+ [ $chan ] ] $nick $chan % [ $+ [ $remove($1,$chr(33)) ] ] [ $+ [ hit ] ] [ $+ [ $chan ] ] }
  }
}
on *:TEXT:!dh:#: {
  if (# == #iDM || # == #iDM.Staff) && ($me != iDM) { halt }
  if ($nick == %p1 [ $+ [ $chan ] ]) && (%turn [ $+ [ $chan ] ] == 1) {
    if ($readini(OnOff.ini,#,$right($1,-1))) { notice $nick $logo(ERROR) This command has been disabled for this channel. | halt }
    if (%stun [ $+ [ $nick ] ]) { msg # $logo(DM) $s1($nick) is stunned and unable to attack. HP $+($chr(91),$s2($iif(%hp1 [ $+ [ $chan ] ] < 1,0,$v1)),$chr(93)) $hpbar(%hp1 [ $+ [ $chan ] ]) | set %turn [ $+ [ $chan ] ] 2 | unset %stun [ $+ [ $nick ] ]  | halt }
    if (%frozen [ $+ [ $nick ] ] == on) { notice $nick You're frozen and can't use melee. | halt }
    var %dharokhit [ $+ [ $chan ] ] $hit($iif(%hp1 [ $+ [ $chan ] ] <= 9,d_h9,d_h10),%p1 [ $+ [ $chan ] ],%p2 [ $+ [ $chan ] ]) 
    if (%hp2 [ $+ [ $chan ] ] < %dharokhit [ $+ [ $chan ] ]) { set %dharokhit [ $+ [ $chan ] ] %hp2 [ $+ [ $chan ] ] }
    dec %hp2 [ $+ [ $chan ] ] %dharokhit [ $+ [ $chan ] ]
    unset %frozen [ $+ [ %p1 [ $+ [ $chan ] ] ] ] | unset %frozen [ $+ [ %p2 [ $+ [ $chan ] ] ] ]
    msg # $logo(DM) $s1($nick) crushes $s1(%p2 [ $+ [ $chan ] ]) with their great axe, and hit $s2(%dharokhit [ $+ [ $chan ] ]) $+ . HP $+($chr(91),$s2($iif(%hp2 [ $+ [ $chan ] ] < 1,0,$v1)),$chr(93)) $hpbar(%hp2 [ $+ [ $chan ] ])
    set %turn [ $+ [ $chan ] ] 2
    if (%hp2 [ $+ [ $chan ] ] < 1) { dead # %p2 [ $+ [ $chan ] ] $nick | halt }
    if (%veng [ $+ [ %p2 [ $+ [ $chan ] ] ] ]) { veng %p2 [ $+ [ $chan ] ] $nick $chan % [ $+ [ $remove($1,$chr(33)) ] ] [ $+ [ hit ] ] [ $+ [ $chan ] ] }
  }
  if ($nick == %p2 [ $+ [ $chan ] ]) && (%turn [ $+ [ $chan ] ] == 2) {
    if ($readini(OnOff.ini,#,$right($1,-1))) { notice $nick $logo(ERROR) This command has been disabled for this channel. | halt }
    if (%stun [ $+ [ $nick ] ]) { msg # $logo(DM) $s1($nick) is stunned and unable to attack. HP $+($chr(91),$s2($iif(%hp2 [ $+ [ $chan ] ] < 1,0,$v1)),$chr(93)) $hpbar(%hp2 [ $+ [ $chan ] ]) | set %turn [ $+ [ $chan ] ] 1 | unset %stun [ $+ [ $nick ] ]  | halt }
    if (%frozen [ $+ [ $nick ] ] == on) { notice $nick You're frozen and can't use melee. | halt }
    var %dharokhit [ $+ [ $chan ] ] $hit($iif(%hp1 [ $+ [ $chan ] ] <= 9,d_h9,d_h10),%p2 [ $+ [ $chan ] ],%p1 [ $+ [ $chan ] ]) 
    if (%hp1 [ $+ [ $chan ] ] < %dharokhit [ $+ [ $chan ] ]) { set %dharokhit [ $+ [ $chan ] ] %hp1 [ $+ [ $chan ] ] }
    dec %hp1 [ $+ [ $chan ] ] %dharokhit [ $+ [ $chan ] ]
    unset %frozen [ $+ [ %p1 [ $+ [ $chan ] ] ] ] | unset %frozen [ $+ [ %p2 [ $+ [ $chan ] ] ] ]
    msg # $logo(DM) $s1($nick) crushes $s1(%p1 [ $+ [ $chan ] ]) with their great axe, and hit $s2(%dharokhit [ $+ [ $chan ] ]) $+ . HP $+($chr(91),$s2($iif(%hp1 [ $+ [ $chan ] ] < 1,0,$v1)),$chr(93)) $hpbar(%hp1 [ $+ [ $chan ] ])
    set %turn [ $+ [ $chan ] ] 1
    if (%hp1 [ $+ [ $chan ] ] < 1) { dead # %p1 [ $+ [ $chan ] ] $nick | halt }
    if (%veng [ $+ [ %p1 [ $+ [ $chan ] ] ] ]) { veng %p1 [ $+ [ $chan ] ] $nick $chan % [ $+ [ $remove($1,$chr(33)) ] ] [ $+ [ hit ] ] [ $+ [ $chan ] ] }
  }
}
on *:TEXT:!bgs:#: {
  if (# == #iDM || # == #iDM.Staff) && ($me != iDM) { halt }
  if ($nick == %p1 [ $+ [ $chan ] ]) && (%turn [ $+ [ $chan ] ] == 1) {
    if (!$readini(Equipment.ini,bgs,$nick)) { notice $nick You have to buy this weapon before you can use it. !buy $remove($1,!) $+ . | halt }
    if ($readini(OnOff.ini,#,$right($1,-1))) { notice $nick $logo(ERROR) This command has been disabled for this channel. | halt }
    if (%stun [ $+ [ $nick ] ]) { msg # $logo(DM) $s1($nick) is stunned and unable to attack. HP $+($chr(91),$s2($iif(%hp1 [ $+ [ $chan ] ] < 1,0,$v1)),$chr(93)) $hpbar(%hp1 [ $+ [ $chan ] ]) | set %turn [ $+ [ $chan ] ] 2 | unset %stun [ $+ [ $nick ] ]  | halt }
    if (%frozen [ $+ [ $nick ] ] == on) { notice $nick You're frozen and can't use melee. | halt }
    if (%sp1 [ $+ [ $chan ] ] < 4) { notice $nick You need 100% special to do this. | halt }
    dec %sp1 [ $+ [ $chan ] ] 4
    var %bgshit [ $+ [ $chan ] ] $hit(bgs,%p1 [ $+ [ $chan ] ],%p2 [ $+ [ $chan ] ]) 
    if (%hp2 [ $+ [ $chan ] ] < %bgshit [ $+ [ $chan ] ]) {  set %bgshit [ $+ [ $chan ] ] %hp2 [ $+ [ $chan ] ] | set %hp2 [ $+ [ $chan ] ] 0 }
    if (%hp2 [ $+ [ $chan ] ] >= 1) { dec %hp2 [ $+ [ $chan ] ] %bgshit [ $+ [ $chan ] ] }
    unset %frozen [ $+ [ %p1 [ $+ [ $chan ] ] ] ] | unset %frozen [ $+ [ %p2 [ $+ [ $chan ] ] ] ]
    msg # $logo(DM) $s1($nick) crushes their godsword down on $s1(%p2 [ $+ [ $chan ] ]) and hit $s2(%bgshit [ $+ [ $chan ] ]) $+ . HP $+($chr(91),$s2($iif(%hp2 [ $+ [ $chan ] ] < 1,0,$v1)),$chr(93)) $hpbar(%hp2 [ $+ [ $chan ] ])
    notice $nick Specbar: $iif(%sp1 [ $+ [ $chan ] ] < 1,0,$gettok(25 50 75 100,%sp1 [ $+ [ $chan ] ],32)) $+ $chr(37)
    set %turn [ $+ [ $chan ] ] 2
    if (%hp2 [ $+ [ $chan ] ] < 1) { dead # %p2 [ $+ [ $chan ] ] $nick | halt }
    if (%veng [ $+ [ %p2 [ $+ [ $chan ] ] ] ]) { veng %p2 [ $+ [ $chan ] ] $nick $chan % [ $+ [ $remove($1,$chr(33)) ] ] [ $+ [ hit ] ] [ $+ [ $chan ] ] }
  }
  if ($nick == %p2 [ $+ [ $chan ] ]) && (%turn [ $+ [ $chan ] ] == 2) {
    if (!$readini(Equipment.ini,bgs,$nick)) { notice $nick You have to buy this weapon before you can use it. !buy $remove($1,!) $+ . | halt }
    if ($readini(OnOff.ini,#,$right($1,-1))) { notice $nick $logo(ERROR) This command has been disabled for this channel. | halt }
    if (%stun [ $+ [ $nick ] ]) { msg # $logo(DM) $s1($nick) is stunned and unable to attack. HP $+($chr(91),$s2($iif(%hp2 [ $+ [ $chan ] ] < 1,0,$v1)),$chr(93)) $hpbar(%hp2 [ $+ [ $chan ] ]) | set %turn [ $+ [ $chan ] ] 1 | unset %stun [ $+ [ $nick ] ]  | halt }
    if (%frozen [ $+ [ $nick ] ] == on) { notice $nick You're frozen and can't use melee. | halt }
    if (%sp2 [ $+ [ $chan ] ] < 4) { notice $nick You need 100% special to do this. | halt }
    dec %sp2 [ $+ [ $chan ] ] 4
    var %bgshit [ $+ [ $chan ] ] $hit(bgs,%p2 [ $+ [ $chan ] ],%p1 [ $+ [ $chan ] ]) 
    if (%hp1 [ $+ [ $chan ] ] < %bgshit [ $+ [ $chan ] ]) { set %bgshit [ $+ [ $chan ] ] %hp1 [ $+ [ $chan ] ] | set %hp1 [ $+ [ $chan ] ] 0 }
    if (%hp1 [ $+ [ $chan ] ] >= 1) { dec %hp1 [ $+ [ $chan ] ] %bgshit [ $+ [ $chan ] ] }
    unset %frozen [ $+ [ %p1 [ $+ [ $chan ] ] ] ] | unset %frozen [ $+ [ %p2 [ $+ [ $chan ] ] ] ]
    msg # $logo(DM) $s1($nick) crushes their godsword down on $s1(%p1 [ $+ [ $chan ] ]) and hit $s2(%bgshit [ $+ [ $chan ] ]) $+ . HP $+($chr(91),$s2($iif(%hp1 [ $+ [ $chan ] ] < 1,0,$v1)),$chr(93)) $hpbar(%hp1 [ $+ [ $chan ] ])
    notice $nick Specbar: $iif(%sp2 [ $+ [ $chan ] ] < 1,0,$gettok(25 50 75 100,%sp2 [ $+ [ $chan ] ],32)) $+ $chr(37)
    set %turn [ $+ [ $chan ] ] 1
    if (%hp1 [ $+ [ $chan ] ] < 1) { dead # %p1 [ $+ [ $chan ] ] $nick | halt }
    if (%veng [ $+ [ %p1 [ $+ [ $chan ] ] ] ]) { veng %p1 [ $+ [ $chan ] ] $nick $chan % [ $+ [ $remove($1,$chr(33)) ] ] [ $+ [ hit ] ] [ $+ [ $chan ] ] }
  }
}
on *:TEXT:!sgs:#: {
  if (# == #iDM || # == #iDM.Staff) && ($me != iDM) { halt }
  if ($nick == %p1 [ $+ [ $chan ] ]) && (%turn [ $+ [ $chan ] ] == 1) {
    if (!$readini(Equipment.ini,sgs,$nick)) { notice $nick You have to buy this weapon before you can use it. !buy $remove($1,!) $+ . | halt }
    if ($readini(OnOff.ini,#,$right($1,-1))) { notice $nick $logo(ERROR) This command has been disabled for this channel. | halt }
    if (%stun [ $+ [ $nick ] ]) { msg # $logo(DM) $s1($nick) is stunned and unable to attack. HP $+($chr(91),$s2($iif(%hp1 [ $+ [ $chan ] ] < 1,0,$v1)),$chr(93)) $hpbar(%hp1 [ $+ [ $chan ] ]) | set %turn [ $+ [ $chan ] ] 2 | unset %stun [ $+ [ $nick ] ]  | halt }
    if (%frozen [ $+ [ $nick ] ] == on) { notice $nick You're frozen and can't use melee. | halt }
    if (%sp1 [ $+ [ $chan ] ] < 2) { notice $nick You need 50% special to do this. | halt }
    dec %sp1 [ $+ [ $chan ] ] 2
    var %sgshit [ $+ [ $chan ] ] $hit(sgs,%p1 [ $+ [ $chan ] ],%p2 [ $+ [ $chan ] ]) 
    if (%hp2 [ $+ [ $chan ] ] < %sgshit [ $+ [ $chan ] ]) {  set %sgshit [ $+ [ $chan ] ] %hp2 [ $+ [ $chan ] ] | set %hp2 [ $+ [ $chan ] ] 0 }
    if (%hp2 [ $+ [ $chan ] ] >= 1) { dec %hp2 [ $+ [ $chan ] ] %sgshit [ $+ [ $chan ] ] }
    if ($calc($+(%,hp1,#) + $floor($calc($+(%,sgshit,#) /2))) > 99) { set %hp1 [ $+ [ $chan ] ] 99 }
    if ($calc($+(%,hp1,#) + $floor($calc($+(%,sgshit,#) /2))) <= 99) { inc %hp1 [ $+ [ $chan ] ] $floor($calc($+(%,sgshit,#) /2))) }
    unset %frozen [ $+ [ %p1 [ $+ [ $chan ] ] ] ] | unset %frozen [ $+ [ %p2 [ $+ [ $chan ] ] ] ]
    msg # $logo(DM) $s1($nick) crushes their godsword down on $s1(%p2 [ $+ [ $chan ] ]) and hit $s2(%sgshit [ $+ [ $chan ] ]) $+ . HP $s1(%p2 [ $+ [ $chan ] ]) $+($chr(91),$s2($iif(%hp2 [ $+ [ $chan ] ] < 1,0,$v1)),$chr(93)) $hpbar(%hp2 [ $+ [ $chan ] ]) - HP $s1($nick) $+($chr(91),$s2($iif(%hp1 [ $+ [ $chan ] ] < 1,0,$v1)),$chr(93)) $hpbar(%hp1 [ $+ [ $chan ] ])
    notice $nick Specbar: $iif(%sp1 [ $+ [ $chan ] ] < 1,0,$gettok(25 50 75 100,%sp1 [ $+ [ $chan ] ],32)) $+ $chr(37)
    set %turn [ $+ [ $chan ] ] 2
    if (%hp2 [ $+ [ $chan ] ] < 1) { dead # %p2 [ $+ [ $chan ] ] $nick | halt }
    if (%veng [ $+ [ %p2 [ $+ [ $chan ] ] ] ]) { veng %p2 [ $+ [ $chan ] ] $nick $chan % [ $+ [ $remove($1,$chr(33)) ] ] [ $+ [ hit ] ] [ $+ [ $chan ] ] }
  }
  if ($nick == %p2 [ $+ [ $chan ] ]) && (%turn [ $+ [ $chan ] ] == 2) {
    if (!$readini(Equipment.ini,sgs,$nick)) { notice $nick You have to buy this weapon before you can use it. !buy $remove($1,!) $+ . | halt }
    if ($readini(OnOff.ini,#,$right($1,-1))) { notice $nick $logo(ERROR) This command has been disabled for this channel. | halt }
    if (%stun [ $+ [ $nick ] ]) { msg # $logo(DM) $s1($nick) is stunned and unable to attack. HP $+($chr(91),$s2($iif(%hp2 [ $+ [ $chan ] ] < 1,0,$v1)),$chr(93)) $hpbar(%hp2 [ $+ [ $chan ] ]) | set %turn [ $+ [ $chan ] ] 1 | unset %stun [ $+ [ $nick ] ]  | halt }
    if (%frozen [ $+ [ $nick ] ] == on) { notice $nick You're frozen and can't use melee. | halt }
    if (%sp2 [ $+ [ $chan ] ] < 2) { notice $nick You need 50% special to do this. | halt }
    dec %sp2 [ $+ [ $chan ] ] 2
    var %sgshit [ $+ [ $chan ] ] $hit(sgs,%p2 [ $+ [ $chan ] ],%p1 [ $+ [ $chan ] ]) 
    if (%hp1 [ $+ [ $chan ] ] < %sgshit [ $+ [ $chan ] ]) {  set %sgshit [ $+ [ $chan ] ] %hp1 [ $+ [ $chan ] ] | set %hp1 [ $+ [ $chan ] ] 0 }
    if (%hp1 [ $+ [ $chan ] ] >= 1) { dec %hp1 [ $+ [ $chan ] ] %sgshit [ $+ [ $chan ] ] }
    if ($calc($+(%,hp2,#) + $floor($calc($+(%,sgshit,#) /2))) > 99) { set %hp2 [ $+ [ $chan ] ] 99 }
    if ($calc($+(%,hp2,#) + $floor($calc($+(%,sgshit,#) /2))) <= 99) { inc %hp2 [ $+ [ $chan ] ] $floor($calc($+(%,sgshit,#) /2))) }
    unset %frozen [ $+ [ %p1 [ $+ [ $chan ] ] ] ] | unset %frozen [ $+ [ %p2 [ $+ [ $chan ] ] ] ]
    msg # $logo(DM) $s1($nick) crushes their godsword down on $s1(%p1 [ $+ [ $chan ] ]) and hit $s2(%sgshit [ $+ [ $chan ] ]) $+ . HP $s1(%p1 [ $+ [ $chan ] ]) $+($chr(91),$s2($iif(%hp1 [ $+ [ $chan ] ] < 1,0,$v1)),$chr(93)) $hpbar(%hp1 [ $+ [ $chan ] ]) - HP $s1($nick) $+($chr(91),$s2($iif(%hp2 [ $+ [ $chan ] ] < 1,0,$v1)),$chr(93)) $hpbar(%hp2 [ $+ [ $chan ] ])
    notice $nick Specbar: $iif(%sp2 [ $+ [ $chan ] ] < 1,0,$gettok(25 50 75 100,%sp2 [ $+ [ $chan ] ],32)) $+ $chr(37)
    set %turn [ $+ [ $chan ] ] 1
    if (%hp1 [ $+ [ $chan ] ] < 1) { dead # %p1 [ $+ [ $chan ] ] $nick | halt }
    if (%veng [ $+ [ %p1 [ $+ [ $chan ] ] ] ]) { veng %p1 [ $+ [ $chan ] ] $nick $chan % [ $+ [ $remove($1,$chr(33)) ] ] [ $+ [ hit ] ] [ $+ [ $chan ] ] }
  }
}
on *:TEXT:!gmaul:#: {
  if (# == #iDM || # == #iDM.Staff) && ($me != iDM) { halt }
  if ($nick == %p1 [ $+ [ $chan ] ]) && (%turn [ $+ [ $chan ] ] == 1) {
    if ($readini(OnOff.ini,#,$right($1,-1))) { notice $nick $logo(ERROR) This command has been disabled for this channel. | halt }
    if (%stun [ $+ [ $nick ] ]) { msg # $logo(DM) $s1($nick) is stunned and unable to attack. HP $+($chr(91),$s2($iif(%hp1 [ $+ [ $chan ] ] < 1,0,$v1)),$chr(93)) $hpbar(%hp1 [ $+ [ $chan ] ]) | set %turn [ $+ [ $chan ] ] 2 | unset %stun [ $+ [ $nick ] ]  | halt }
    if (%frozen [ $+ [ $nick ] ] == on) { notice $nick You're frozen and can't use melee. | halt }
    if (%sp1 [ $+ [ $chan ] ] < 4) { notice $nick You need 100% special to do this. | halt }
    dec %sp1 [ $+ [ $chan ] ] 4
    var %gmaul [ $+ [ $chan ] ] $hit(gmaul,%p1 [ $+ [ $chan ] ],%p2 [ $+ [ $chan ] ]) 
    var %gmaulhit [ $+ [ $chan ] ] $gettok(%gmaul [ $+ [ $chan ] ],1,32), %gmaulhit2 [ $+ [ $chan ] ] $gettok(%gmaul [ $+ [ $chan ] ],2,32), %gmaulhit3 [ $+ [ $chan ] ] $gettok(%gmaul [ $+ [ $chan ] ],3,32)
    if (%hp2 [ $+ [ $chan ] ] < $calc($+(%,gmaulhit,#) + $+(%,gmaulhit2,#) + $+(%,gmaulhit3,#))) { set %hp2 [ $+ [ $chan ] ] 0 }
    if (%hp2 [ $+ [ $chan ] ] >= 1) { dec %hp2 [ $+ [ $chan ] ] %gmaulhit [ $+ [ $chan ] ] | dec %hp2 [ $+ [ $chan ] ] %gmaulhit2 [ $+ [ $chan ] ] | dec %hp2 [ $+ [ $chan ] ] %gmaulhit3 [ $+ [ $chan ] ] }
    unset %frozen [ $+ [ %p1 [ $+ [ $chan ] ] ] ] | unset %frozen [ $+ [ %p2 [ $+ [ $chan ] ] ] ]
    msg # $logo(DM) $s1($nick) whacks $s1(%p2 [ $+ [ $chan ] ]) with their granite maul, speccing $s2(%gmaulhit [ $+ [ $chan ] ]) - $s2(%gmaulhit2 [ $+ [ $chan ] ]) - $s2(%gmaulhit3 [ $+ [ $chan ] ]) $+ . HP $+($chr(91),$s2($iif(%hp2 [ $+ [ $chan ] ] < 1,0,$v1)),$chr(93)) $hpbar(%hp2 [ $+ [ $chan ] ])
    notice $nick Specbar: $iif(%sp1 [ $+ [ $chan ] ] < 1,0,$gettok(25 50 75 100,%sp1 [ $+ [ $chan ] ],32)) $+ $chr(37)
    set %turn [ $+ [ $chan ] ] 2
    if (%hp2 [ $+ [ $chan ] ] < 1) { dead # %p2 [ $+ [ $chan ] ] $nick | halt }
    if (%veng [ $+ [ %p2 [ $+ [ $chan ] ] ] ]) { veng %p2 [ $+ [ $chan ] ] $nick $chan % [ $+ [ $remove($1,$chr(33)) ] ] [ $+ [ hit ] ] [ $+ [ $chan ] ] }
  }
  if ($nick == %p2 [ $+ [ $chan ] ]) && (%turn [ $+ [ $chan ] ] == 2) {
    if ($readini(OnOff.ini,#,$right($1,-1))) { notice $nick $logo(ERROR) This command has been disabled for this channel. | halt }
    if (%stun [ $+ [ $nick ] ]) { msg # $logo(DM) $s1($nick) is stunned and unable to attack. HP $+($chr(91),$s2($iif(%hp2 [ $+ [ $chan ] ] < 1,0,$v1)),$chr(93)) $hpbar(%hp2 [ $+ [ $chan ] ]) | set %turn [ $+ [ $chan ] ] 1 | unset %stun [ $+ [ $nick ] ]  | halt }
    if (%frozen [ $+ [ $nick ] ] == on) { notice $nick You're frozen and can't use melee. | halt }
    if (%sp2 [ $+ [ $chan ] ] < 4) { notice $nick You need 100% special to do this. | halt }
    dec %sp2 [ $+ [ $chan ] ] 4
    var %gmaul [ $+ [ $chan ] ] $hit(gmaul,%p2 [ $+ [ $chan ] ],%p1 [ $+ [ $chan ] ]) 
    var %gmaulhit [ $+ [ $chan ] ] $gettok(%gmaul [ $+ [ $chan ] ],1,32), %gmaulhit2 [ $+ [ $chan ] ] $gettok(%gmaul [ $+ [ $chan ] ],2,32), %gmaulhit3 [ $+ [ $chan ] ] $gettok(%gmaul [ $+ [ $chan ] ],3,32)
    if (%hp1 [ $+ [ $chan ] ] < $calc($+(%,gmaulhit,#) + $+(%,gmaulhit2,#) + $+(%,gmaulhit3,#))) { set %hp1 [ $+ [ $chan ] ] 0 }
    if (%hp1 [ $+ [ $chan ] ] >= 1) { dec %hp1 [ $+ [ $chan ] ] %gmaulhit [ $+ [ $chan ] ] | dec %hp1 [ $+ [ $chan ] ] %gmaulhit2 [ $+ [ $chan ] ] | dec %hp1 [ $+ [ $chan ] ] %gmaulhit3 [ $+ [ $chan ] ] }
    unset %frozen [ $+ [ %p1 [ $+ [ $chan ] ] ] ] | unset %frozen [ $+ [ %p2 [ $+ [ $chan ] ] ] ]
    msg # $logo(DM) $s1($nick) whacks $s1(%p1 [ $+ [ $chan ] ]) with their granite maul, speccing $s2(%gmaulhit [ $+ [ $chan ] ]) - $s2(%gmaulhit2 [ $+ [ $chan ] ]) - $s2(%gmaulhit3 [ $+ [ $chan ] ]) $+ . HP $+($chr(91),$s2($iif(%hp1 [ $+ [ $chan ] ] < 1,0,$v1)),$chr(93)) $hpbar(%hp1 [ $+ [ $chan ] ])
    notice $nick Specbar: $iif(%sp2 [ $+ [ $chan ] ] < 1,0,$gettok(25 50 75 100,%sp2 [ $+ [ $chan ] ],32)) $+ $chr(37)
    set %turn [ $+ [ $chan ] ] 1
    if (%hp1 [ $+ [ $chan ] ] < 1) { dead # %p1 [ $+ [ $chan ] ] $nick | halt }
    if (%veng [ $+ [ %p1 [ $+ [ $chan ] ] ] ]) { veng %p1 [ $+ [ $chan ] ] $nick $chan % [ $+ [ $remove($1,$chr(33)) ] ] [ $+ [ hit ] ] [ $+ [ $chan ] ] }
  }
}
on *:TEXT:!guth:#: {
  if (# == #iDM || # == #iDM.Staff) && ($me != iDM) { halt }
  if ($nick == %p1 [ $+ [ $chan ] ]) && (%turn [ $+ [ $chan ] ] == 1) {
    if ($readini(OnOff.ini,#,$right($1,-1))) { notice $nick $logo(ERROR) This command has been disabled for this channel. | halt }
    if (%stun [ $+ [ $nick ] ]) { msg # $logo(DM) $s1($nick) is stunned and unable to attack. HP $+($chr(91),$s2($iif(%hp1 [ $+ [ $chan ] ] < 1,0,$v1)),$chr(93)) $hpbar(%hp1 [ $+ [ $chan ] ]) | set %turn [ $+ [ $chan ] ] 2 | unset %stun [ $+ [ $nick ] ]  | halt }
    if (%frozen [ $+ [ $nick ] ] == on) { notice $nick You're frozen and can't use melee. | halt }
    set %heal [ $+ [ $chan ] ] $r(1,3)
    var %guthhit [ $+ [ $chan ] ] $hit(guth,%p1 [ $+ [ $chan ] ],%p2 [ $+ [ $chan ] ])
    if (%hp2 [ $+ [ $chan ] ] < %guthhit [ $+ [ $chan ] ]) {  set %guthhit [ $+ [ $chan ] ] %hp2 [ $+ [ $chan ] ] | set %hp2 [ $+ [ $chan ] ] 0 | unset %heal [ $+ [ $chan ] ] }
    if (%hp2 [ $+ [ $chan ] ] >= 1) { dec %hp2 [ $+ [ $chan ] ] %guthhit [ $+ [ $chan ] ] }
    if ($calc($+(%,hp1,#) + $+(%,guthhit,#)) > 99) && (%heal [ $+ [ $chan ] ] == 1) { set %hp1 [ $+ [ $chan ] ] 99 }
    if ($calc($+(%,hp1,#) + $+(%,guthhit,#)) <= 99) && (%heal [ $+ [ $chan ] ] == 1) { inc %hp1 [ $+ [ $chan ] ] %guthhit [ $+ [ $chan ] ] }
    unset %frozen [ $+ [ %p1 [ $+ [ $chan ] ] ] ] | unset %frozen [ $+ [ %p2 [ $+ [ $chan ] ] ] ]
    msg # $logo(DM) $s1($nick) $iif(%heal [ $+ [ $chan ] ] == 1,09HEALS on,fails to heal on) $s1(%p2 [ $+ [ $chan ] ]) $iif(%heal [ $+ [ $chan ] ] == 1,and hits,but hits) $s2(%guthhit [ $+ [ $chan ] ]) $+ . HP $s1(%p2 [ $+ [ $chan ] ]) $+($chr(91),$s2($iif(%hp2 [ $+ [ $chan ] ] < 1,0,$v1)),$chr(93)) $hpbar(%hp2 [ $+ [ $chan ] ]) $iif(%heal [ $+ [ $chan ] ] == 1,- HP $s1($nick) $+($chr(91),$s2($iif(%hp1 [ $+ [ $chan ] ] < 1,0,$v1)),$chr(93)) $hpbar(%hp1 [ $+ [ $chan ] ]))
    set %turn [ $+ [ $chan ] ] 2
    unset %heal [ $+ [ $chan ] ]
    if (%hp2 [ $+ [ $chan ] ] < 1) { dead # %p2 [ $+ [ $chan ] ] $nick | halt }
    if (%veng [ $+ [ %p2 [ $+ [ $chan ] ] ] ]) { veng %p2 [ $+ [ $chan ] ] $nick $chan % [ $+ [ $remove($1,$chr(33)) ] ] [ $+ [ hit ] ] [ $+ [ $chan ] ] }
  }
  if ($nick == %p2 [ $+ [ $chan ] ]) && (%turn [ $+ [ $chan ] ] == 2) {
    if ($readini(OnOff.ini,#,$right($1,-1))) { notice $nick $logo(ERROR) This command has been disabled for this channel. | halt }
    if (%stun [ $+ [ $nick ] ]) { msg # $logo(DM) $s1($nick) is stunned and unable to attack. HP $+($chr(91),$s2($iif(%hp2 [ $+ [ $chan ] ] < 1,0,$v1)),$chr(93)) $hpbar(%hp2 [ $+ [ $chan ] ]) | set %turn [ $+ [ $chan ] ] 1 | unset %stun [ $+ [ $nick ] ]  | halt }
    if (%frozen [ $+ [ $nick ] ] == on) { notice $nick You're frozen and can't use melee. | halt }
    set %heal [ $+ [ $chan ] ] $r(1,3)
    var %guthhit [ $+ [ $chan ] ] $hit(guth,%p2 [ $+ [ $chan ] ],%p1 [ $+ [ $chan ] ])
    if (%hp1 [ $+ [ $chan ] ] < %guthhit [ $+ [ $chan ] ]) {  set %guthhit [ $+ [ $chan ] ] %hp1 [ $+ [ $chan ] ] | set %hp1 [ $+ [ $chan ] ] 0 | unset %heal [ $+ [ $chan ] ] }
    if (%hp1 [ $+ [ $chan ] ] >= 1) { dec %hp1 [ $+ [ $chan ] ] %guthhit [ $+ [ $chan ] ] }
    if ($calc($+(%,hp2,#) + $+(%,guthhit,#)) > 99) && (%heal [ $+ [ $chan ] ] == 1) { set %hp2 [ $+ [ $chan ] ] 99 }
    if ($calc($+(%,hp2,#) + $+(%,guthhit,#)) <= 99) && (%heal [ $+ [ $chan ] ] == 1) { inc %hp2 [ $+ [ $chan ] ] %guthhit [ $+ [ $chan ] ] }
    unset %frozen [ $+ [ %p1 [ $+ [ $chan ] ] ] ] | unset %frozen [ $+ [ %p2 [ $+ [ $chan ] ] ] ]
    msg # $logo(DM) $s1($nick) $iif(%heal [ $+ [ $chan ] ] == 1,09HEALS on,fails to heal on) $s1(%p1 [ $+ [ $chan ] ]) $iif(%heal [ $+ [ $chan ] ] == 1,and hits,but hits) $s2(%guthhit [ $+ [ $chan ] ]) $+ . HP $s1(%p1 [ $+ [ $chan ] ]) $+($chr(91),$s2($iif(%hp1 [ $+ [ $chan ] ] < 1,0,$v1)),$chr(93)) $hpbar(%hp1 [ $+ [ $chan ] ]) $iif(%heal [ $+ [ $chan ] ] == 1,- HP $s1($nick) $+($chr(91),$s2($iif(%hp2 [ $+ [ $chan ] ] < 1,0,$v1)),$chr(93)) $hpbar(%hp2 [ $+ [ $chan ] ]))
    set %turn [ $+ [ $chan ] ] 1
    unset %heal [ $+ [ $chan ] ]
    if (%hp1 [ $+ [ $chan ] ] < 1) { dead # %p1 [ $+ [ $chan ] ] $nick | halt }
    if (%veng [ $+ [ %p1 [ $+ [ $chan ] ] ] ]) { veng %p1 [ $+ [ $chan ] ] $nick $chan % [ $+ [ $remove($1,$chr(33)) ] ] [ $+ [ hit ] ] [ $+ [ $chan ] ] }
  }
}
on *:TEXT:!ice:#: {
  if (# == #iDM || # == #iDM.Staff) && ($me != iDM) { halt }
  if ($nick == %p1 [ $+ [ $chan ] ]) && (%turn [ $+ [ $chan ] ] == 1) {
    if ($readini(OnOff.ini,#,$right($1,-1))) { notice $nick $logo(ERROR) This command has been disabled for this channel. | halt }
    var %icehit [ $+ [ $chan ] ] $hit(ice,%p1 [ $+ [ $chan ] ],%p2 [ $+ [ $chan ] ])
    if (%hp2 [ $+ [ $chan ] ] < %icehit [ $+ [ $chan ] ]) { set %icehit [ $+ [ $chan ] ] %hp2 [ $+ [ $chan ] ] }
    dec %hp2 [ $+ [ $chan ] ] %icehit [ $+ [ $chan ] ]
    if (%icehit [ $+ [ $chan ] ] > 0) {
      var %freeze $r(1,4)
      if (%freeze == 1) { set %frozen [ $+ [ %p2 [ $+ [ $chan ] ] ] ] on | notice %p2 [ $+ [ $chan ] ] You've been frozen! }
    }
    if (%freeze != 1) { unset %frozen [ $+ [ %p1 [ $+ [ $chan ] ] ] ] | unset %frozen [ $+ [ %p2 [ $+ [ $chan ] ] ] ] }
    msg # $logo(DM) $s1($nick) casts ice barrage on $s1(%p2 [ $+ [ $chan ] ]) $iif(%freeze == 1,(12FROZEN)) $iif(%icehit [ $+ [ $chan ] ] == 0, and splashed.,surrounding them in an ice cube $+ $chr(44) hitting $s2(%icehit [ $+ [ $chan ] ]) $+ .) HP $+($chr(91),$s2($iif(%hp2 [ $+ [ $chan ] ] < 1,0,$v1)),$chr(93)) $hpbar(%hp2 [ $+ [ $chan ] ])
    set %turn [ $+ [ $chan ] ] 2
    if (%hp2 [ $+ [ $chan ] ] < 1) { dead # %p2 [ $+ [ $chan ] ] $nick | halt }
    if (%veng [ $+ [ %p2 [ $+ [ $chan ] ] ] ]) { veng %p2 [ $+ [ $chan ] ] $nick $chan % [ $+ [ $remove($1,$chr(33)) ] ] [ $+ [ hit ] ] [ $+ [ $chan ] ] }
  }
  if ($nick == %p2 [ $+ [ $chan ] ]) && (%turn [ $+ [ $chan ] ] == 2) {
    if ($readini(OnOff.ini,#,$right($1,-1))) { notice $nick $logo(ERROR) This command has been disabled for this channel. | halt }
    var %icehit [ $+ [ $chan ] ] $hit(ice,%p2 [ $+ [ $chan ] ],%p1 [ $+ [ $chan ] ])
    if (%hp1 [ $+ [ $chan ] ] < %icehit [ $+ [ $chan ] ]) { set %icehit [ $+ [ $chan ] ] %hp1 [ $+ [ $chan ] ] }
    dec %hp1 [ $+ [ $chan ] ] %icehit [ $+ [ $chan ] ]
    if (%icehit [ $+ [ $chan ] ] > 0) {
      var %freeze $r(1,4)
      if (%freeze == 1) { set %frozen [ $+ [ %p1 [ $+ [ $chan ] ] ] ] on | notice %p1 [ $+ [ $chan ] ] You've been frozen! }
    }
    if (%freeze != 1) { unset %frozen [ $+ [ %p1 [ $+ [ $chan ] ] ] ] | unset %frozen [ $+ [ %p2 [ $+ [ $chan ] ] ] ] }
    msg # $logo(DM) $s1($nick) casts ice barrage on $s1(%p1 [ $+ [ $chan ] ]) $iif(%freeze == 1,(12FROZEN)) $iif(%icehit [ $+ [ $chan ] ] == 0, and splashed.,surrounding them in an ice cube $+ $chr(44) hitting $s2(%icehit [ $+ [ $chan ] ]) $+ .) HP $+($chr(91),$s2($iif(%hp1 [ $+ [ $chan ] ] < 1,0,$v1)),$chr(93)) $hpbar(%hp1 [ $+ [ $chan ] ])
    set %turn [ $+ [ $chan ] ] 1
    if (%hp1 [ $+ [ $chan ] ] < 1) { dead # %p1 [ $+ [ $chan ] ] $nick | halt }
    if (%veng [ $+ [ %p1 [ $+ [ $chan ] ] ] ]) { veng %p1 [ $+ [ $chan ] ] $nick $chan % [ $+ [ $remove($1,$chr(33)) ] ] [ $+ [ hit ] ] [ $+ [ $chan ] ] }
  }
}
on *:TEXT:!zgs:#: {
  if (# == #iDM || # == #iDM.Staff) && ($me != iDM) { halt }
  if ($nick == %p1 [ $+ [ $chan ] ]) && (%turn [ $+ [ $chan ] ] == 1) {
    if (!$readini(Equipment.ini,zgs,$nick)) { notice $nick You have to buy this weapon before you can use it. !buy $remove($1,!) $+ . | halt }
    if ($readini(OnOff.ini,#,$right($1,-1))) { notice $nick $logo(ERROR) This command has been disabled for this channel. | halt }
    if (%stun [ $+ [ $nick ] ]) { msg # $logo(DM) $s1($nick) is stunned and unable to attack. HP $+($chr(91),$s2($iif(%hp1 [ $+ [ $chan ] ] < 1,0,$v1)),$chr(93)) $hpbar(%hp1 [ $+ [ $chan ] ]) | set %turn [ $+ [ $chan ] ] 2 | unset %stun [ $+ [ $nick ] ]  | halt }
    if (%frozen [ $+ [ $nick ] ] == on) { notice $nick You're frozen and can't use melee. | halt }
    if (%sp1 [ $+ [ $chan ] ] < 2) { notice $nick You need 50% special to do this. | halt }
    dec %sp1 [ $+ [ $chan ] ] 2
    var %zgshit [ $+ [ $chan ] ] $hit(zgs,%p1 [ $+ [ $chan ] ],%p2 [ $+ [ $chan ] ])
    if (%hp2 [ $+ [ $chan ] ] < %zgshit [ $+ [ $chan ] ]) { set %zgshit [ $+ [ $chan ] ] %hp2 [ $+ [ $chan ] ] }
    dec %hp2 [ $+ [ $chan ] ] %zgshit [ $+ [ $chan ] ]
    if (%zgshit [ $+ [ $chan ] ] > 0) {
      var %freeze $r(1,2)
      if (%freeze == 1) { set %frozen [ $+ [ %p2 [ $+ [ $chan ] ] ] ] on | notice %p2 [ $+ [ $chan ] ] You've been frozen! }
    }
    if (%freeze != 1) { unset %frozen [ $+ [ %p1 [ $+ [ $chan ] ] ] ] | unset %frozen [ $+ [ %p2 [ $+ [ $chan ] ] ] ] }
    msg # $logo(DM) $s1($nick) attempts to freeze $s1(%p2 [ $+ [ $chan ] ]) $iif(%freeze == 1,and successfully 12FROZE them,but failed to) $+ $chr(44) hitting $s2(%zgshit [ $+ [ $chan ] ]) $+ . HP $+($chr(91),$s2($iif(%hp2 [ $+ [ $chan ] ] < 1,0,$v1)),$chr(93)) $hpbar(%hp2 [ $+ [ $chan ] ])
    notice $nick Specbar: $iif(%sp1 [ $+ [ $chan ] ] < 1,0,$gettok(25 50 75 100,%sp1 [ $+ [ $chan ] ],32)) $+ $chr(37)
    set %turn [ $+ [ $chan ] ] 2
    if (%hp2 [ $+ [ $chan ] ] < 1) { dead # %p2 [ $+ [ $chan ] ] $nick | halt }
    if (%veng [ $+ [ %p2 [ $+ [ $chan ] ] ] ]) { veng %p2 [ $+ [ $chan ] ] $nick $chan % [ $+ [ $remove($1,$chr(33)) ] ] [ $+ [ hit ] ] [ $+ [ $chan ] ] }
  }
  if ($nick == %p2 [ $+ [ $chan ] ]) && (%turn [ $+ [ $chan ] ] == 2) {
    if (!$readini(Equipment.ini,zgs,$nick)) { notice $nick You have to buy this weapon before you can use it. !buy $remove($1,!) $+ . | halt }
    if ($readini(OnOff.ini,#,$right($1,-1))) { notice $nick $logo(ERROR) This command has been disabled for this channel. | halt }
    if (%stun [ $+ [ $nick ] ]) { msg # $logo(DM) $s1($nick) is stunned and unable to attack. HP $+($chr(91),$s2($iif(%hp2 [ $+ [ $chan ] ] < 1,0,$v1)),$chr(93)) $hpbar(%hp2 [ $+ [ $chan ] ]) | set %turn [ $+ [ $chan ] ] 1 | unset %stun [ $+ [ $nick ] ]  | halt }
    if (%frozen [ $+ [ $nick ] ] == on) { notice $nick You're frozen and can't use melee. | halt }
    if (%sp2 [ $+ [ $chan ] ] < 2) { notice $nick You need 50% special to do this. | halt }
    dec %sp2 [ $+ [ $chan ] ] 2
    var %zgshit [ $+ [ $chan ] ] $hit(zgs,%p2 [ $+ [ $chan ] ],%p1 [ $+ [ $chan ] ])
    if (%hp1 [ $+ [ $chan ] ] < %zgshit [ $+ [ $chan ] ]) { set %zgshit [ $+ [ $chan ] ] %hp1 [ $+ [ $chan ] ] }
    dec %hp1 [ $+ [ $chan ] ] %zgshit [ $+ [ $chan ] ]
    if (%zgshit [ $+ [ $chan ] ] > 0) {
      var %freeze $r(1,2)
      if (%freeze == 1) { set %frozen [ $+ [ %p1 [ $+ [ $chan ] ] ] ] on | notice %p1 [ $+ [ $chan ] ] You've been frozen! }
    }
    if (%freeze != 1) { unset %frozen [ $+ [ %p1 [ $+ [ $chan ] ] ] ] | unset %frozen [ $+ [ %p2 [ $+ [ $chan ] ] ] ] }
    msg # $logo(DM) $s1($nick) attempts to freeze $s1(%p1 [ $+ [ $chan ] ]) $iif(%freeze == 1,and successfully 12FROZE them,but failed to) $+ $chr(44) hitting $s2(%zgshit [ $+ [ $chan ] ]) $+ . HP $+($chr(91),$s2($iif(%hp1 [ $+ [ $chan ] ] < 1,0,$v1)),$chr(93)) $hpbar(%hp1 [ $+ [ $chan ] ])
    notice $nick Specbar: $iif(%sp2 [ $+ [ $chan ] ] < 1,0,$gettok(25 50 75 100,%sp2 [ $+ [ $chan ] ],32)) $+ $chr(37)
    set %turn [ $+ [ $chan ] ] 1
    if (%hp1 [ $+ [ $chan ] ] < 1) { dead # %p1 [ $+ [ $chan ] ] $nick | halt }
    if (%veng [ $+ [ %p1 [ $+ [ $chan ] ] ] ]) { veng %p1 [ $+ [ $chan ] ] $nick $chan % [ $+ [ $remove($1,$chr(33)) ] ] [ $+ [ hit ] ] [ $+ [ $chan ] ] }
  }
}
on *:TEXT:!specpot:#: {
  if (# == #iDM || # == #iDM.Staff) && ($me != iDM) { halt }
  if ($nick == %p1 [ $+ [ $chan ] ]) && (%turn [ $+ [ $chan ] ] == 1) {
    if (!$readini(Equipment.ini,specpot,$nick)) { notice $nick You don't have any specpots. | halt }
    if (%sp1 [ $+ [ $chan ] ] == 4) { notice $nick You already have a full special bar. | halt }
    set %sp1 [ $+ [ $chan ] ] 4
    msg # $logo(DM) $s1($nick) drinks their specpot and now has 100% special. 
    notice $nick Specbar: $iif(%sp1 [ $+ [ $chan ] ] < 1,0,$gettok(25 50 75 100,%sp1 [ $+ [ $chan ] ],32)) $+ $chr(37)
    writeini -n Equipment.ini Specpot $nick $calc($readini(Equipment.ini,Specpot,$nick) - 1)
    set %turn [ $+ [ $chan ] ] 2
  }
  if ($nick == %p2 [ $+ [ $chan ] ]) && (%turn [ $+ [ $chan ] ] == 2) {
    if (!$readini(Equipment.ini,specpot,$nick)) { notice $nick You don't have any specpots. | halt }
    if (%sp2 [ $+ [ $chan ] ] == 4) { notice $nick You already have a full special bar. | halt }
    set %sp2 [ $+ [ $chan ] ] 4
    msg # $logo(DM) $s1($nick) drinks their specpot and now has 100% special. 
    notice $nick Specbar: $iif(%sp2 [ $+ [ $chan ] ] < 1,0,$gettok(25 50 75 100,%sp2 [ $+ [ $chan ] ],32)) $+ $chr(37)
    writeini -n Equipment.ini Specpot $nick $calc($readini(Equipment.ini,Specpot,$nick) - 1)
    set %turn [ $+ [ $chan ] ] 1
  }
}
on *:TEXT:!blood:#: {
  if (# == #iDM || # == #iDM.Staff) && ($me != iDM) { halt }
  if ($nick == %p1 [ $+ [ $chan ] ]) && (%turn [ $+ [ $chan ] ] == 1) {
    if ($readini(OnOff.ini,#,$right($1,-1))) { notice $nick $logo(ERROR) This command has been disabled for this channel. | halt }
    var %bloodhit [ $+ [ $chan ] ] $hit(blood,%p1 [ $+ [ $chan ] ],%p2 [ $+ [ $chan ] ])
    if (%hp2 [ $+ [ $chan ] ] < %bloodhit [ $+ [ $chan ] ]) { set %bloodhit [ $+ [ $chan ] ] %hp2 [ $+ [ $chan ] ] }
    set %hp1 [ $+ [ $chan ] ] $calc( %hp1 [ $+ [ $chan ] ] + $ceil( $calc( %bloodhit [ $+ [ $chan ] ] / 4 )))
    dec %hp2 [ $+ [ $chan ] ] %bloodhit [ $+ [ $chan ] ]
    if (%hp1 [ $+ [ $chan ] ] > 99) { set %hp1 [ $+ [ $chan ] ] 99 }
    msg # $logo(DM) $s1($nick) casts blood barrage on $s1(%p2 [ $+ [ $chan ] ]) $iif(%bloodhit [ $+ [ $chan ] ] == 0, and splashed.,hitting $s2(%bloodhit [ $+ [ $chan ] ]) $+ .) HP $s1(%p2 [ $+ [ $chan ] ]) $+($chr(91),$s2($iif(%hp2 [ $+ [ $chan ] ] < 1,0,$v1)),$chr(93)) $hpbar(%hp2 [ $+ [ $chan ] ]) - HP $s1(%p1 [ $+ [ $chan ] ]) $+($chr(91),$s2($iif(%hp1 [ $+ [ $chan ] ] < 1,0,$v1)),$chr(93)) $hpbar(%hp1 [ $+ [ $chan ] ])
    set %turn [ $+ [ $chan ] ] 2
    if (%hp2 [ $+ [ $chan ] ] < 1) { dead # %p2 [ $+ [ $chan ] ] $nick | halt }
    if (%veng [ $+ [ %p2 [ $+ [ $chan ] ] ] ]) { veng %p2 [ $+ [ $chan ] ] $nick $chan % [ $+ [ $remove($1,$chr(33)) ] ] [ $+ [ hit ] ] [ $+ [ $chan ] ] }
  }
  if ($nick == %p2 [ $+ [ $chan ] ]) && (%turn [ $+ [ $chan ] ] == 2) {
    if ($readini(OnOff.ini,#,$right($1,-1))) { notice $nick $logo(ERROR) This command has been disabled for this channel. | halt }
    var %bloodhit [ $+ [ $chan ] ] $hit(blood,%p2 [ $+ [ $chan ] ],%p1 [ $+ [ $chan ] ])
    if (%hp1 [ $+ [ $chan ] ] < %bloodhit [ $+ [ $chan ] ]) { set %bloodhit [ $+ [ $chan ] ] %hp1 [ $+ [ $chan ] ] }
    set %hp2 [ $+ [ $chan ] ] $calc( %hp2 [ $+ [ $chan ] ] + $ceil( $calc( %bloodhit [ $+ [ $chan ] ] / 4 )))
    dec %hp1 [ $+ [ $chan ] ] %bloodhit [ $+ [ $chan ] ]
    if (%hp2 [ $+ [ $chan ] ] > 99) { set %hp2 [ $+ [ $chan ] ] 99 }
    msg # $logo(DM) $s1($nick) casts blood barrage on $s1(%p1 [ $+ [ $chan ] ]) $iif(%bloodhit [ $+ [ $chan ] ] == 0, and splashed.,hitting $s2(%bloodhit [ $+ [ $chan ] ]) $+ .) HP $s1(%p1 [ $+ [ $chan ] ]) $+($chr(91),$s2($iif(%hp1 [ $+ [ $chan ] ] < 1,0,$v1)),$chr(93)) $hpbar(%hp1 [ $+ [ $chan ] ]) - HP $s1(%p2 [ $+ [ $chan ] ]) $+($chr(91),$s2($iif(%hp2 [ $+ [ $chan ] ] < 1,0,$v1)),$chr(93)) $hpbar(%hp2 [ $+ [ $chan ] ]) 
    set %turn [ $+ [ $chan ] ] 1
    if (%hp1 [ $+ [ $chan ] ] < 1) { dead # %p1 [ $+ [ $chan ] ] $nick | halt }
    if (%veng [ $+ [ %p1 [ $+ [ $chan ] ] ] ]) { veng %p1 [ $+ [ $chan ] ] $nick $chan % [ $+ [ $remove($1,$chr(33)) ] ] [ $+ [ hit ] ] [ $+ [ $chan ] ] }
  }
}
on *:TEXT:!surf:#: {
  if (# == #iDM || # == #iDM.Staff) && ($me != iDM) { halt }
  if ($nick == %p1 [ $+ [ $chan ] ]) && (%turn [ $+ [ $chan ] ] == 1) {
    if (!$readini(equipment.ini,mudkip,$nick)) { notice $nick You have to buy this weapon before you can use it. !buy $remove($1,!) $+ . | halt }
    if ($readini(OnOff.ini,#,$right($1,-1))) { notice $nick $logo(ERROR) This command has been disabled for this channel. | halt }
    var %mudhit [ $+ [ $chan ] ] $hit(surf,%p1 [ $+ [ $chan ] ],%p2 [ $+ [ $chan ] ])
    if (%hp2 [ $+ [ $chan ] ] < %mudhit [ $+ [ $chan ] ]) { set %mudhit [ $+ [ $chan ] ] %hp2 [ $+ [ $chan ] ] }
    dec %hp2 [ $+ [ $chan ] ] %mudhit [ $+ [ $chan ] ]
    unset %frozen [ $+ [ %p1 [ $+ [ $chan ] ] ] ] | unset %frozen [ $+ [ %p2 [ $+ [ $chan ] ] ] ]
    msg # $logo(DM) $s1($nick) summons their mudkip, surfing at $s1(%p2 [ $+ [ $chan ] ]) $+ , hitting $s2(%mudhit [ $+ [ $chan ] ]) $+ . HP $+($chr(91),$s2($iif(%hp2 [ $+ [ $chan ] ] < 1,0,$v1)),$chr(93)) $hpbar(%hp2 [ $+ [ $chan ] ])
    set %turn [ $+ [ $chan ] ] 2
    if (%hp2 [ $+ [ $chan ] ] < 1) { dead # %p2 [ $+ [ $chan ] ] $nick | halt }
    if (%veng [ $+ [ %p2 [ $+ [ $chan ] ] ] ]) { veng %p2 [ $+ [ $chan ] ] $nick $chan % [ $+ [ $remove($1,$chr(33)) ] ] [ $+ [ hit ] ] [ $+ [ $chan ] ] }
  }
  if ($nick == %p2 [ $+ [ $chan ] ]) && (%turn [ $+ [ $chan ] ] == 2) {
    if (!$readini(equipment.ini,mudkip,$nick)) { notice $nick You have to buy this weapon before you can use it. !buy $remove($1,!) $+ . | halt }
    if ($readini(OnOff.ini,#,$right($1,-1))) { notice $nick $logo(ERROR) This command has been disabled for this channel. | halt }
    var %mudhit [ $+ [ $chan ] ] $hit(surf,%p2 [ $+ [ $chan ] ],%p1 [ $+ [ $chan ] ])
    if (%hp1 [ $+ [ $chan ] ] < %mudhit [ $+ [ $chan ] ]) { set %mudhit [ $+ [ $chan ] ] %hp1 [ $+ [ $chan ] ] }
    dec %hp1 [ $+ [ $chan ] ] %mudhit [ $+ [ $chan ] ]
    unset %frozen [ $+ [ %p1 [ $+ [ $chan ] ] ] ] | unset %frozen [ $+ [ %p2 [ $+ [ $chan ] ] ] ]
    msg # $logo(DM) $s1($nick) summons their mudkip, surfing at $s1(%p1 [ $+ [ $chan ] ]) $+ , hitting $s2(%mudhit [ $+ [ $chan ] ]) $+ . HP $+($chr(91),$s2($iif(%hp1 [ $+ [ $chan ] ] < 1,0,$v1)),$chr(93)) $hpbar(%hp1 [ $+ [ $chan ] ])
    set %turn [ $+ [ $chan ] ] 1
    if (%hp1 [ $+ [ $chan ] ] < 1) { dead # %p1 [ $+ [ $chan ] ] $nick | halt }
    if (%veng [ $+ [ %p1 [ $+ [ $chan ] ] ] ]) { veng %p1 [ $+ [ $chan ] ] $nick $chan % [ $+ [ $remove($1,$chr(33)) ] ] [ $+ [ hit ] ] [ $+ [ $chan ] ] }
  }
}
on *:TEXT:!dclaws:#: {
  if (# == #iDM || # == #iDM.Staff) && ($me != iDM) { halt }
  if ($nick == %p1 [ $+ [ $chan ] ]) && (%turn [ $+ [ $chan ] ] == 1) {
    if (!$readini(Equipment.ini,dclaws,$nick)) { notice $nick You have to buy this weapon before you can use it. !buy $remove($1,!) $+ . | halt }
    if ($readini(OnOff.ini,#,$right($1,-1))) { notice $nick $logo(ERROR) This command has been disabled for this channel. | halt }
    if (%stun [ $+ [ $nick ] ]) { msg # $logo(DM) $s1($nick) is stunned and unable to attack. HP $+($chr(91),$s2($iif(%hp1 [ $+ [ $chan ] ] < 1,0,$v1)),$chr(93)) $hpbar(%hp1 [ $+ [ $chan ] ]) | set %turn [ $+ [ $chan ] ] 2 | unset %stun [ $+ [ $nick ] ]  | halt }
    if (%frozen [ $+ [ $nick ] ] == on) { notice $nick You're frozen and can't use melee. | halt }
    if (%sp1 [ $+ [ $chan ] ] < 2) { notice $nick You need 50% special to do this. | halt }
    dec %sp1 [ $+ [ $chan ] ] 2
    var %dclaws [ $+ [ $chan ] ] $hit(dclaws,%p1 [ $+ [ $chan ] ],%p2 [ $+ [ $chan ] ]) 
    var %dclawshit [ $+ [ $chan ] ] $gettok(%dclaws [ $+ [ $chan ] ],1,32), %dclawshit2 [ $+ [ $chan ] ] $gettok(%dclaws [ $+ [ $chan ] ],2,32), %dclawshit3 [ $+ [ $chan ] ] $gettok(%dclaws [ $+ [ $chan ] ],3,32), %dclawshit4 [ $+ [ $chan ] ] $gettok(%dclaws [ $+ [ $chan ] ],4,32)
    if (%hp2 [ $+ [ $chan ] ] < $calc($+(%,dclawshit,#) + $+(%,dclawshit2,#) + $+(%,dclawshit3,#) + $+(%,dclawshit4,#))) { set %hp2 [ $+ [ $chan ] ] 0 }
    if (%hp2 [ $+ [ $chan ] ] >= 1) { dec %hp2 [ $+ [ $chan ] ] %dclawshit [ $+ [ $chan ] ] | dec %hp2 [ $+ [ $chan ] ] %dclawshit2 [ $+ [ $chan ] ] | dec %hp2 [ $+ [ $chan ] ] %dclawshit3 [ $+ [ $chan ] ] | dec %hp2 [ $+ [ $chan ] ] %dclawshit4 [ $+ [ $chan ] ] }
    unset %frozen [ $+ [ %p1 [ $+ [ $chan ] ] ] ] | unset %frozen [ $+ [ %p2 [ $+ [ $chan ] ] ] ]
    msg # $logo(DM) $s1($nick) scratches $s1(%p2 [ $+ [ $chan ] ]) with their dragon claws, hitting $s2(%dclawshit [ $+ [ $chan ] ]) - $s2(%dclawshit2 [ $+ [ $chan ] ]) - $s2(%dclawshit3 [ $+ [ $chan ] ]) - $s2(%dclawshit4 [ $+ [ $chan ] ]) $+ . HP $+($chr(91),$s2($iif(%hp2 [ $+ [ $chan ] ] < 1,0,$v1)),$chr(93)) $hpbar(%hp2 [ $+ [ $chan ] ])
    notice $nick Specbar: $iif(%sp1 [ $+ [ $chan ] ] < 1,0,$gettok(25 50 75 100,%sp1 [ $+ [ $chan ] ],32)) $+ $chr(37)
    set %turn [ $+ [ $chan ] ] 2
    if (%hp2 [ $+ [ $chan ] ] < 1) { dead # %p2 [ $+ [ $chan ] ] $nick | halt }
    if (%veng [ $+ [ %p2 [ $+ [ $chan ] ] ] ]) { veng %p2 [ $+ [ $chan ] ] $nick $chan % [ $+ [ $remove($1,$chr(33)) ] ] [ $+ [ hit ] ] [ $+ [ $chan ] ] }
  }
  if ($nick == %p2 [ $+ [ $chan ] ]) && (%turn [ $+ [ $chan ] ] == 2) {
    if (!$readini(Equipment.ini,dclaws,$nick)) { notice $nick You have to buy this weapon before you can use it. !buy $remove($1,!) $+ . | halt }
    if ($readini(OnOff.ini,#,$right($1,-1))) { notice $nick $logo(ERROR) This command has been disabled for this channel. | halt }
    if (%stun [ $+ [ $nick ] ]) { msg # $logo(DM) $s1($nick) is stunned and unable to attack. HP $+($chr(91),$s2($iif(%hp2 [ $+ [ $chan ] ] < 1,0,$v1)),$chr(93)) $hpbar(%hp2 [ $+ [ $chan ] ]) | set %turn [ $+ [ $chan ] ] 1 | unset %stun [ $+ [ $nick ] ]  | halt }
    if (%frozen [ $+ [ $nick ] ] == on) { notice $nick You're frozen and can't use melee. | halt }
    if (%sp2 [ $+ [ $chan ] ] < 2) { notice $nick You need 50% special to do this. | halt }
    dec %sp2 [ $+ [ $chan ] ] 2
    var %dclaws [ $+ [ $chan ] ] $hit(dclaws,%p2 [ $+ [ $chan ] ],%p1 [ $+ [ $chan ] ]) 
    var %dclawshit [ $+ [ $chan ] ] $gettok(%dclaws [ $+ [ $chan ] ],1,32), %dclawshit2 [ $+ [ $chan ] ] $gettok(%dclaws [ $+ [ $chan ] ],2,32), %dclawshit3 [ $+ [ $chan ] ] $gettok(%dclaws [ $+ [ $chan ] ],3,32), %dclawshit4 [ $+ [ $chan ] ] $gettok(%dclaws [ $+ [ $chan ] ],4,32)
    if (%hp1 [ $+ [ $chan ] ] < $calc($+(%,dclawshit,#) + $+(%,dclawshit2,#) + $+(%,dclawshit3,#) + $+(%,dclawshit4,#))) { set %hp2 [ $+ [ $chan ] ] 0 }
    if (%hp1 [ $+ [ $chan ] ] >= 1) { dec %hp1 [ $+ [ $chan ] ] %dclawshit [ $+ [ $chan ] ] | dec %hp1 [ $+ [ $chan ] ] %dclawshit2 [ $+ [ $chan ] ] | dec %hp1 [ $+ [ $chan ] ] %dclawshit3 [ $+ [ $chan ] ] | dec %hp1 [ $+ [ $chan ] ] %dclawshit4 [ $+ [ $chan ] ] }
    unset %frozen [ $+ [ %p1 [ $+ [ $chan ] ] ] ] | unset %frozen [ $+ [ %p2 [ $+ [ $chan ] ] ] ]
    msg # $logo(DM) $s1($nick) scratches $s1(%p1 [ $+ [ $chan ] ]) with their dragon claws, hitting $s2(%dclawshit [ $+ [ $chan ] ]) - $s2(%dclawshit2 [ $+ [ $chan ] ]) - $s2(%dclawshit3 [ $+ [ $chan ] ]) - $s2(%dclawshit4 [ $+ [ $chan ] ]) $+ . HP $+($chr(91),$s2($iif(%hp1 [ $+ [ $chan ] ] < 1,0,$v1)),$chr(93)) $hpbar(%hp1 [ $+ [ $chan ] ])
    notice $nick Specbar: $iif(%sp2 [ $+ [ $chan ] ] < 1,0,$gettok(25 50 75 100,%sp2 [ $+ [ $chan ] ],32)) $+ $chr(37)
    set %turn [ $+ [ $chan ] ] 1
    if (%hp1 [ $+ [ $chan ] ] < 1) { dead # %p1 [ $+ [ $chan ] ] $nick | halt }
    if (%veng [ $+ [ %p1 [ $+ [ $chan ] ] ] ]) { veng %p1 [ $+ [ $chan ] ] $nick $chan % [ $+ [ $remove($1,$chr(33)) ] ] [ $+ [ hit ] ] [ $+ [ $chan ] ] }
  }
}

on *:TEXT:!dmace:#: {
  if (# == #iDM || # == #iDM.Staff) && ($me != iDM) { halt }
  if ($nick == %p1 [ $+ [ $chan ] ]) && (%turn [ $+ [ $chan ] ] == 1) {
    if ($readini(OnOff.ini,#,$right($1,-1))) { notice $nick $logo(ERROR) This command has been disabled for this channel. | halt }
    if (%stun [ $+ [ $nick ] ]) { msg # $logo(DM) $s1($nick) is stunned and unable to attack. HP $+($chr(91),$s2($iif(%hp1 [ $+ [ $chan ] ] < 1,0,$v1)),$chr(93)) $hpbar(%hp1 [ $+ [ $chan ] ]) | set %turn [ $+ [ $chan ] ] 2 | unset %stun [ $+ [ $nick ] ]  | halt }
    if (%frozen [ $+ [ $nick ] ] == on) { notice $nick You're frozen and can't use melee. | halt }
    if (%sp1 [ $+ [ $chan ] ] < 2) { notice $nick You need 50% special to do that. | halt }
    var %dmacehit [ $+ [ $chan ] ] $hit(dmace,%p1 [ $+ [ $chan ] ],%p2 [ $+ [ $chan ] ]) 
    if (%hp2 [ $+ [ $chan ] ] < %dmacehit [ $+ [ $chan ] ]) { set %dmacehit [ $+ [ $chan ] ] %hp2 [ $+ [ $chan ] ] }
    dec %hp2 [ $+ [ $chan ] ] %dmacehit [ $+ [ $chan ] ]
    unset %frozen [ $+ [ %p1 [ $+ [ $chan ] ] ] ] | unset %frozen [ $+ [ %p2 [ $+ [ $chan ] ] ] ]
    msg # $logo(DM) $s1($nick) crushes $s1(%p2 [ $+ [ $chan ] ]) with their Dragon Mace, hitting $s2(%dmacehit [ $+ [ $chan ] ]) $+ . HP $+($chr(91),$s2($iif(%hp2 [ $+ [ $chan ] ] < 1,0,$v1)),$chr(93)) $hpbar(%hp2 [ $+ [ $chan ] ])
    dec %sp1 [ $+ [ $chan ] ] 2
    notice $nick Specbar: $iif(%sp1 [ $+ [ $chan ] ] < 1,0,$gettok(25 50 75 100,%sp1 [ $+ [ $chan ] ],32)) $+ $chr(37)
    set %turn [ $+ [ $chan ] ] 2
    if (%hp2 [ $+ [ $chan ] ] < 1) { dead # %p2 [ $+ [ $chan ] ] $nick | halt }
    if (%veng [ $+ [ %p2 [ $+ [ $chan ] ] ] ]) { veng %p2 [ $+ [ $chan ] ] $nick $chan % [ $+ [ $remove($1,$chr(33)) ] ] [ $+ [ hit ] ] [ $+ [ $chan ] ] }
  }
  if ($nick == %p2 [ $+ [ $chan ] ]) && (%turn [ $+ [ $chan ] ] == 2) {
    if ($readini(OnOff.ini,#,$right($1,-1))) { notice $nick $logo(ERROR) This command has been disabled for this channel. | halt }
    if (%stun [ $+ [ $nick ] ]) { msg # $logo(DM) $s1($nick) is stunned and unable to attack. HP $+($chr(91),$s2($iif(%hp2 [ $+ [ $chan ] ] < 1,0,$v1)),$chr(93)) $hpbar(%hp2 [ $+ [ $chan ] ]) | set %turn [ $+ [ $chan ] ] 1 | unset %stun [ $+ [ $nick ] ]  | halt }
    if (%frozen [ $+ [ $nick ] ] == on) { notice $nick You're frozen and can't use melee. | halt }
    if (%sp2 [ $+ [ $chan ] ] < 2) { notice $nick You need 50% special to do that. | halt }
    var %dmacehit [ $+ [ $chan ] ] $hit(dmace,%p2 [ $+ [ $chan ] ],%p1 [ $+ [ $chan ] ]) 
    if (%hp1 [ $+ [ $chan ] ] < %dmacehit [ $+ [ $chan ] ]) { set %dmacehit [ $+ [ $chan ] ] %hp1 [ $+ [ $chan ] ] }
    dec %hp1 [ $+ [ $chan ] ] %dmacehit [ $+ [ $chan ] ]
    unset %frozen [ $+ [ %p1 [ $+ [ $chan ] ] ] ] | unset %frozen [ $+ [ %p2 [ $+ [ $chan ] ] ] ]
    msg # $logo(DM) $s1($nick) crushes $s1(%p1 [ $+ [ $chan ] ]) with their Dragon Mace, hitting $s2(%dmacehit [ $+ [ $chan ] ]) $+ . HP $+($chr(91),$s2($iif(%hp1 [ $+ [ $chan ] ] < 1,0,$v1)),$chr(93)) $hpbar(%hp1 [ $+ [ $chan ] ])
    dec %sp2 [ $+ [ $chan ] ] 2
    notice $nick Specbar: $iif(%sp2 [ $+ [ $chan ] ] < 1,0,$gettok(25 50 75 100,%sp2 [ $+ [ $chan ] ],32)) $+ $chr(37)
    set %turn [ $+ [ $chan ] ] 1
    if (%hp1 [ $+ [ $chan ] ] < 1) { dead # %p1 [ $+ [ $chan ] ] $nick | halt }
    if (%veng [ $+ [ %p1 [ $+ [ $chan ] ] ] ]) { veng %p1 [ $+ [ $chan ] ] $nick $chan % [ $+ [ $remove($1,$chr(33)) ] ] [ $+ [ hit ] ] [ $+ [ $chan ] ] }
  }
}
on *:TEXT:!d2h:#: {
  if (# == #iDM || # == #iDM.Staff) && ($me != iDM) { halt }
  if ($nick == %p1 [ $+ [ $chan ] ]) && (%turn [ $+ [ $chan ] ] == 1) {
    if ($readini(OnOff.ini,#,$right($1,-1))) { notice $nick $logo(ERROR) This command has been disabled for this channel. | halt }
    if (%stun [ $+ [ $nick ] ]) { msg # $logo(DM) $s1($nick) is stunned and unable to attack. HP $+($chr(91),$s2($iif(%hp1 [ $+ [ $chan ] ] < 1,0,$v1)),$chr(93)) $hpbar(%hp1 [ $+ [ $chan ] ]) | set %turn [ $+ [ $chan ] ] 2 | unset %stun [ $+ [ $nick ] ]  | halt }
    if (%frozen [ $+ [ $nick ] ] == on) { notice $nick You're frozen and can't use melee. | halt }
    if (%sp1 [ $+ [ $chan ] ] < 3) { notice $nick You need 75% special to do that. | halt }
    var %d2hhit [ $+ [ $chan ] ] $hit(d2h,%p1 [ $+ [ $chan ] ],%p2 [ $+ [ $chan ] ]) 
    if (%hp2 [ $+ [ $chan ] ] < %d2hhit [ $+ [ $chan ] ]) { set %d2hhit [ $+ [ $chan ] ] %hp2 [ $+ [ $chan ] ] }
    dec %hp2 [ $+ [ $chan ] ] %d2hhit [ $+ [ $chan ] ]
    unset %frozen [ $+ [ %p1 [ $+ [ $chan ] ] ] ] | unset %frozen [ $+ [ %p2 [ $+ [ $chan ] ] ] ]
    msg # $logo(DM) $s1($nick) crushes $s1(%p2 [ $+ [ $chan ] ]) with their Dragon 2-Hander, hitting $s2(%d2hhit [ $+ [ $chan ] ]) $+ . HP $+($chr(91),$s2($iif(%hp2 [ $+ [ $chan ] ] < 1,0,$v1)),$chr(93)) $hpbar(%hp2 [ $+ [ $chan ] ])
    dec %sp1 [ $+ [ $chan ] ] 3
    notice $nick Specbar: $iif(%sp1 [ $+ [ $chan ] ] < 1,0,$gettok(25 50 75 100,%sp1 [ $+ [ $chan ] ],32)) $+ $chr(37)
    set %turn [ $+ [ $chan ] ] 2
    if (%hp2 [ $+ [ $chan ] ] < 1) { dead # %p2 [ $+ [ $chan ] ] $nick | halt }
    if (%veng [ $+ [ %p2 [ $+ [ $chan ] ] ] ]) { veng %p2 [ $+ [ $chan ] ] $nick $chan % [ $+ [ $remove($1,$chr(33)) ] ] [ $+ [ hit ] ] [ $+ [ $chan ] ] }
  }
  if ($nick == %p2 [ $+ [ $chan ] ]) && (%turn [ $+ [ $chan ] ] == 2) {
    if ($readini(OnOff.ini,#,$right($1,-1))) { notice $nick $logo(ERROR) This command has been disabled for this channel. | halt }
    if (%stun [ $+ [ $nick ] ]) { msg # $logo(DM) $s1($nick) is stunned and unable to attack. HP $+($chr(91),$s2($iif(%hp2 [ $+ [ $chan ] ] < 1,0,$v1)),$chr(93)) $hpbar(%hp2 [ $+ [ $chan ] ]) | set %turn [ $+ [ $chan ] ] 1 | unset %stun [ $+ [ $nick ] ]  | halt }
    if (%frozen [ $+ [ $nick ] ] == on) { notice $nick You're frozen and can't use melee. | halt }
    if (%sp2 [ $+ [ $chan ] ] < 3) { notice $nick You need 75% special to do that. | halt }
    var %d2hhit [ $+ [ $chan ] ] $hit(d2h,%p2 [ $+ [ $chan ] ],%p1 [ $+ [ $chan ] ]) 
    if (%hp1 [ $+ [ $chan ] ] < %d2hhit [ $+ [ $chan ] ]) { set %d2hhit[ $+ [ $chan ] ] %hp1 [ $+ [ $chan ] ] }
    dec %hp1 [ $+ [ $chan ] ] %d2hhit [ $+ [ $chan ] ]
    unset %frozen [ $+ [ %p1 [ $+ [ $chan ] ] ] ] | unset %frozen [ $+ [ %p2 [ $+ [ $chan ] ] ] ]
    msg # $logo(DM) $s1($nick) crushes $s1(%p1 [ $+ [ $chan ] ]) with their Dragon 2-Hander, hitting $s2(%d2hhit [ $+ [ $chan ] ]) $+ . HP $+($chr(91),$s2($iif(%hp1 [ $+ [ $chan ] ] < 1,0,$v1)),$chr(93)) $hpbar(%hp1 [ $+ [ $chan ] ])
    dec %sp2 [ $+ [ $chan ] ] 3
    notice $nick Specbar: $iif(%sp2 [ $+ [ $chan ] ] < 1,0,$gettok(25 50 75 100,%sp2 [ $+ [ $chan ] ],32)) $+ $chr(37)
    set %turn [ $+ [ $chan ] ] 1
    if (%hp1 [ $+ [ $chan ] ] < 1) { dead # %p1 [ $+ [ $chan ] ] $nick | halt }
    if (%veng [ $+ [ %p1 [ $+ [ $chan ] ] ] ]) { veng %p1 [ $+ [ $chan ] ] $nick $chan % [ $+ [ $remove($1,$chr(33)) ] ] [ $+ [ hit ] ] [ $+ [ $chan ] ] }
  }
}
on *:TEXT:!dscim:#: {
  if (# == #iDM || # == #iDM.Staff) && ($me != iDM) { halt }
  if ($nick == %p1 [ $+ [ $chan ] ]) && (%turn [ $+ [ $chan ] ] == 1) {
    if ($readini(OnOff.ini,#,$right($1,-1))) { notice $nick $logo(ERROR) This command has been disabled for this channel. | halt }
    if (%stun [ $+ [ $nick ] ]) { msg # $logo(DM) $s1($nick) is stunned and unable to attack. HP $+($chr(91),$s2($iif(%hp1 [ $+ [ $chan ] ] < 1,0,$v1)),$chr(93)) $hpbar(%hp1 [ $+ [ $chan ] ]) | set %turn [ $+ [ $chan ] ] 2 | unset %stun [ $+ [ $nick ] ]  | halt }
    if (%frozen [ $+ [ $nick ] ] == on) { notice $nick You're frozen and can't use melee. | halt }
    var %dscimhit [ $+ [ $chan ] ] $hit(dscim,%p1 [ $+ [ $chan ] ],%p2 [ $+ [ $chan ] ]) 
    if (%hp2 [ $+ [ $chan ] ] < %dscimhit [ $+ [ $chan ] ]) { set %dscimhit [ $+ [ $chan ] ] %hp2 [ $+ [ $chan ] ] }
    dec %hp2 [ $+ [ $chan ] ] %dscimhit [ $+ [ $chan ] ]
    unset %frozen [ $+ [ %p1 [ $+ [ $chan ] ] ] ] | unset %frozen [ $+ [ %p2 [ $+ [ $chan ] ] ] ]
    msg # $logo(DM) $s1($nick) slices $s1(%p2 [ $+ [ $chan ] ]) with their Dragon Scimitar, hitting $s2(%dscimhit [ $+ [ $chan ] ]) $+ . HP $+($chr(91),$s2($iif(%hp2 [ $+ [ $chan ] ] < 1,0,$v1)),$chr(93)) $hpbar(%hp2 [ $+ [ $chan ] ])
    set %turn [ $+ [ $chan ] ] 2
    if (%hp2 [ $+ [ $chan ] ] < 1) { dead # %p2 [ $+ [ $chan ] ] $nick | halt }
    if (%veng [ $+ [ %p2 [ $+ [ $chan ] ] ] ]) { veng %p2 [ $+ [ $chan ] ] $nick $chan % [ $+ [ $remove($1,$chr(33)) ] ] [ $+ [ hit ] ] [ $+ [ $chan ] ] }
  }
  if ($nick == %p2 [ $+ [ $chan ] ]) && (%turn [ $+ [ $chan ] ] == 2) {
    if ($readini(OnOff.ini,#,$right($1,-1))) { notice $nick $logo(ERROR) This command has been disabled for this channel. | halt }
    if (%stun [ $+ [ $nick ] ]) { msg # $logo(DM) $s1($nick) is stunned and unable to attack. HP $+($chr(91),$s2($iif(%hp2 [ $+ [ $chan ] ] < 1,0,$v1)),$chr(93)) $hpbar(%hp2 [ $+ [ $chan ] ]) | set %turn [ $+ [ $chan ] ] 1 | unset %stun [ $+ [ $nick ] ]  | halt }
    if (%frozen [ $+ [ $nick ] ] == on) { notice $nick You're frozen and can't use melee. | halt }
    var %dscimhit [ $+ [ $chan ] ] $hit(dscim,%p2 [ $+ [ $chan ] ],%p1 [ $+ [ $chan ] ]) 
    if (%hp1 [ $+ [ $chan ] ] < %dscimhit [ $+ [ $chan ] ]) { set %dscimhit [ $+ [ $chan ] ] %hp1 [ $+ [ $chan ] ] }
    dec %hp1 [ $+ [ $chan ] ] %dscimhit [ $+ [ $chan ] ]
    unset %frozen [ $+ [ %p1 [ $+ [ $chan ] ] ] ] | unset %frozen [ $+ [ %p2 [ $+ [ $chan ] ] ] ]
    msg # $logo(DM) $s1($nick) slices $s1(%p1 [ $+ [ $chan ] ]) with their Dragon Scimitar, hitting $s2(%dscimhit [ $+ [ $chan ] ]) $+ . HP $+($chr(91),$s2($iif(%hp1 [ $+ [ $chan ] ] < 1,0,$v1)),$chr(93)) $hpbar(%hp1 [ $+ [ $chan ] ])
    set %turn [ $+ [ $chan ] ] 1
    if (%hp1 [ $+ [ $chan ] ] < 1) { dead # %p1 [ $+ [ $chan ] ] $nick | halt }
    if (%veng [ $+ [ %p1 [ $+ [ $chan ] ] ] ]) { veng %p1 [ $+ [ $chan ] ] $nick $chan % [ $+ [ $remove($1,$chr(33)) ] ] [ $+ [ hit ] ] [ $+ [ $chan ] ] }
  }
}
on *:TEXT:!dspear:#: {
  if (# == #iDM || # == #iDM.Staff) && ($me != iDM) { halt }
  if ($nick == %p1 [ $+ [ $chan ] ]) && (%turn [ $+ [ $chan ] ] == 1) {
    if ($readini(OnOff.ini,#,$right($1,-1))) { notice $nick $logo(ERROR) This command has been disabled for this channel. | halt }
    if (%stun [ $+ [ $nick ] ]) { msg # $logo(DM) $s1($nick) is stunned and unable to attack. HP $+($chr(91),$s2($iif(%hp1 [ $+ [ $chan ] ] < 1,0,$v1)),$chr(93)) $hpbar(%hp1 [ $+ [ $chan ] ]) | set %turn [ $+ [ $chan ] ] 2 | unset %stun [ $+ [ $nick ] ]  | halt }
    unset %stun [ $+ [ %p2 [ $+ [ $chan ] ] ] ]
    if (%frozen [ $+ [ $nick ] ] == on) { notice $nick You're frozen and can't use melee. | halt }
    if (%sp1 [ $+ [ $chan ] ] < 2) { notice $nick You need 50% special to do that. | halt }
    var %dspearhit [ $+ [ $chan ] ] $hit(dspear,%p1 [ $+ [ $chan ] ],%p2 [ $+ [ $chan ] ]) 
    if (%hp2 [ $+ [ $chan ] ] < %dspearhit [ $+ [ $chan ] ]) { set %dspearhit [ $+ [ $chan ] ] %hp2 [ $+ [ $chan ] ] }
    dec %hp2 [ $+ [ $chan ] ] %dspearhit [ $+ [ $chan ] ]
    dec %sp1 [ $+ [ $chan ] ] 2
    set %stunran [ $+ [ $chan ] ] $rand(1,3)
    if (%stunran [ $+ [ $chan ] ] == 1) { set %stun [ $+ [ %p2 [ $+ [ $chan ] ] ] ] on }
    unset %frozen [ $+ [ %p1 [ $+ [ $chan ] ] ] ] | unset %frozen [ $+ [ %p2 [ $+ [ $chan ] ] ] ]
    msg # $logo(DM) $s1($nick) shoves $s1(%p2 [ $+ [ $chan ] ]) with their Dragon Spear $iif(%stunran [ $+ [ $chan ] ] == 1,(7STUNNED), $+ ), hitting $s2(%dspearhit [ $+ [ $chan ] ]) $+ . HP $+($chr(91),$s2($iif(%hp2 [ $+ [ $chan ] ] < 1,0,$v1)),$chr(93)) $hpbar(%hp2 [ $+ [ $chan ] ]) | unset %stunran [ $+ [ $chan ] ]
    notice $nick Specbar: $iif(%sp1 [ $+ [ $chan ] ] < 1,0,$gettok(25 50 75 100,%sp1 [ $+ [ $chan ] ],32)) $+ $chr(37)
    set %turn [ $+ [ $chan ] ] 2
    if (%hp2 [ $+ [ $chan ] ] < 1) { dead # %p2 [ $+ [ $chan ] ] $nick | halt }
    if (%veng [ $+ [ %p2 [ $+ [ $chan ] ] ] ]) { veng %p2 [ $+ [ $chan ] ] $nick $chan % [ $+ [ $remove($1,$chr(33)) ] ] [ $+ [ hit ] ] [ $+ [ $chan ] ] }
  }
  if ($nick == %p2 [ $+ [ $chan ] ]) && (%turn [ $+ [ $chan ] ] == 2) {
    if ($readini(OnOff.ini,#,$right($1,-1))) { notice $nick $logo(ERROR) This command has been disabled for this channel. | halt }
    if (%stun [ $+ [ $nick ] ]) { msg # $logo(DM) $s1($nick) is stunned and unable to attack. HP $+($chr(91),$s2($iif(%hp2 [ $+ [ $chan ] ] < 1,0,$v1)),$chr(93)) $hpbar(%hp2 [ $+ [ $chan ] ]) | set %turn [ $+ [ $chan ] ] 1 | unset %stun [ $+ [ $nick ] ] | halt }
    unset %stun [ $+ [ %p1 [ $+ [ $chan ] ] ] ]
    if (%frozen [ $+ [ $nick ] ] == on) { notice $nick You're frozen and can't use melee. | halt }
    if (%sp2 [ $+ [ $chan ] ] < 2) { notice $nick You need 50% special to do that. | halt }
    var %dspearhit [ $+ [ $chan ] ] $hit(dspear,%p2 [ $+ [ $chan ] ],%p1 [ $+ [ $chan ] ]) 
    if (%hp1 [ $+ [ $chan ] ] < %dspearhit [ $+ [ $chan ] ]) { set %dspearhit [ $+ [ $chan ] ] %hp1 [ $+ [ $chan ] ] }
    dec %hp1 [ $+ [ $chan ] ] %dspearhit [ $+ [ $chan ] ]
    set %stunran [ $+ [ $chan ] ] $rand(1,3)
    if (%stunran [ $+ [ $chan ] ] == 1) { set %stun [ $+ [ %p1 [ $+ [ $chan ] ] ] ] on }
    unset %frozen [ $+ [ %p1 [ $+ [ $chan ] ] ] ] | unset %frozen [ $+ [ %p2 [ $+ [ $chan ] ] ] ]
    msg # $logo(DM) $s1($nick) shoves $s1(%p1 [ $+ [ $chan ] ]) with their Dragon Spear $iif(%stunran [ $+ [ $chan ] ] == 1,(7STUNNED), $+ ), hitting $s2(%dspearhit [ $+ [ $chan ] ]) $+ . HP $+($chr(91),$s2($iif(%hp1 [ $+ [ $chan ] ] < 1,0,$v1)),$chr(93)) $hpbar(%hp1 [ $+ [ $chan ] ]) | unset %stunran [ $+ [ $chan ] ]
    dec %sp2 [ $+ [ $chan ] ] 2
    notice $nick Specbar: $iif(%sp2 [ $+ [ $chan ] ] < 1,0,$gettok(25 50 75 100,%sp2 [ $+ [ $chan ] ],32)) $+ $chr(37)
    set %turn [ $+ [ $chan ] ] 1
    if (%hp1 [ $+ [ $chan ] ] < 1) { dead # %p1 [ $+ [ $chan ] ] $nick | halt }
    if (%veng [ $+ [ %p1 [ $+ [ $chan ] ] ] ]) { veng %p1 [ $+ [ $chan ] ] $nick $chan % [ $+ [ $remove($1,$chr(33)) ] ] [ $+ [ hit ] ] [ $+ [ $chan ] ] }
  }
}
on *:TEXT:!dlong:#: {
  if (# == #iDM || # == #iDM.Staff) && ($me != iDM) { halt }
  if ($nick == %p1 [ $+ [ $chan ] ]) && (%turn [ $+ [ $chan ] ] == 1) {
    if ($readini(OnOff.ini,#,$right($1,-1))) { notice $nick $logo(ERROR) This command has been disabled for this channel. | halt }
    if (%stun [ $+ [ $nick ] ]) { msg # $logo(DM) $s1($nick) is stunned and unable to attack. HP $+($chr(91),$s2($iif(%hp1 [ $+ [ $chan ] ] < 1,0,$v1)),$chr(93)) $hpbar(%hp1 [ $+ [ $chan ] ]) | set %turn [ $+ [ $chan ] ] 2 | unset %stun [ $+ [ $nick ] ] | halt }
    if (%frozen [ $+ [ $nick ] ] == on) { notice $nick You're frozen and can't use melee. | halt }
    if (%sp1 [ $+ [ $chan ] ] < 1) { notice $nick You need 25% special to do that. | halt }
    var %dlonghit [ $+ [ $chan ] ] $hit(dlong,%p1 [ $+ [ $chan ] ],%p2 [ $+ [ $chan ] ]) 
    if (%hp2 [ $+ [ $chan ] ] < %dlonghit [ $+ [ $chan ] ]) { set %dlonghit [ $+ [ $chan ] ] %hp2 [ $+ [ $chan ] ] }
    dec %hp2 [ $+ [ $chan ] ] %dlonghit [ $+ [ $chan ] ]
    dec %sp1 [ $+ [ $chan ] ] 1
    unset %frozen [ $+ [ %p1 [ $+ [ $chan ] ] ] ] | unset %frozen [ $+ [ %p2 [ $+ [ $chan ] ] ] ]
    msg # $logo(DM) $s1($nick) stabs $s1(%p2 [ $+ [ $chan ] ]) with their Dragon Longsword, hitting $s2(%dlonghit [ $+ [ $chan ] ]) $+ . HP $+($chr(91),$s2($iif(%hp2 [ $+ [ $chan ] ] < 1,0,$v1)),$chr(93)) $hpbar(%hp2 [ $+ [ $chan ] ])
    notice $nick Specbar: $iif(%sp1 [ $+ [ $chan ] ] < 1,0,$gettok(25 50 75 100,%sp1 [ $+ [ $chan ] ],32)) $+ $chr(37)
    set %turn [ $+ [ $chan ] ] 2
    if (%hp2 [ $+ [ $chan ] ] < 1) { dead # %p2 [ $+ [ $chan ] ] $nick | halt }
    if (%veng [ $+ [ %p2 [ $+ [ $chan ] ] ] ]) { veng %p2 [ $+ [ $chan ] ] $nick $chan % [ $+ [ $remove($1,$chr(33)) ] ] [ $+ [ hit ] ] [ $+ [ $chan ] ] }
  }
  if ($nick == %p2 [ $+ [ $chan ] ]) && (%turn [ $+ [ $chan ] ] == 2) {
    if ($readini(OnOff.ini,#,$right($1,-1))) { notice $nick $logo(ERROR) This command has been disabled for this channel. | halt }
    if (%stun [ $+ [ $nick ] ]) { msg # $logo(DM) $s1($nick) is stunned and unable to attack. HP $+($chr(91),$s2($iif(%hp2 [ $+ [ $chan ] ] < 1,0,$v1)),$chr(93)) $hpbar(%hp2 [ $+ [ $chan ] ]) | set %turn [ $+ [ $chan ] ] 1 | unset %stun [ $+ [ $nick ] ] | halt }
    if (%frozen [ $+ [ $nick ] ] == on) { notice $nick You're frozen and can't use melee. | halt }
    if (%sp2 [ $+ [ $chan ] ] < 1) { notice $nick You need 25% special to do that. | halt }
    var %dlonghit [ $+ [ $chan ] ] $hit(dlong,%p2 [ $+ [ $chan ] ],%p1 [ $+ [ $chan ] ]) 
    if (%hp1 [ $+ [ $chan ] ] < %dlonghit [ $+ [ $chan ] ]) { set %dlonghit [ $+ [ $chan ] ] %hp1 [ $+ [ $chan ] ] }
    dec %hp1 [ $+ [ $chan ] ] %dlonghit [ $+ [ $chan ] ]
    unset %frozen [ $+ [ %p1 [ $+ [ $chan ] ] ] ] | unset %frozen [ $+ [ %p2 [ $+ [ $chan ] ] ] ]
    msg # $logo(DM) $s1($nick) stabs $s1(%p1 [ $+ [ $chan ] ]) with their Dragon Longsword, hitting $s2(%dlonghit [ $+ [ $chan ] ]) $+ . HP $+($chr(91),$s2($iif(%hp1 [ $+ [ $chan ] ] < 1,0,$v1)),$chr(93)) $hpbar(%hp1 [ $+ [ $chan ] ])
    dec %sp2 [ $+ [ $chan ] ] 1
    notice $nick Specbar: $iif(%sp2 [ $+ [ $chan ] ] < 1,0,$gettok(25 50 75 100,%sp2 [ $+ [ $chan ] ],32)) $+ $chr(37)
    set %turn [ $+ [ $chan ] ] 1
    if (%hp1 [ $+ [ $chan ] ] < 1) { dead # %p1 [ $+ [ $chan ] ] $nick | halt }
    if (%veng [ $+ [ %p1 [ $+ [ $chan ] ] ] ]) { veng %p1 [ $+ [ $chan ] ] $nick $chan % [ $+ [ $remove($1,$chr(33)) ] ] [ $+ [ hit ] ] [ $+ [ $chan ] ] }
  }
}
on *:TEXT:!dhally:#: {
  if (# == #iDM || # == #iDM.Staff) && ($me != iDM) { halt }
  if ($nick == %p1 [ $+ [ $chan ] ]) && (%turn [ $+ [ $chan ] ] == 1) {
    if ($readini(OnOff.ini,#,$right($1,-1))) { notice $nick $logo(ERROR) This command has been disabled for this channel. | halt }
    if (%stun [ $+ [ $nick ] ]) { msg # $logo(DM) $s1($nick) is stunned and unable to attack. HP $+($chr(91),$s2($iif(%hp1 [ $+ [ $chan ] ] < 1,0,$v1)),$chr(93)) $hpbar(%hp1 [ $+ [ $chan ] ]) | set %turn [ $+ [ $chan ] ] 2 | unset %stun [ $+ [ $nick ] ] | halt }
    if (%frozen [ $+ [ $nick ] ] == on) { notice $nick You're frozen and can't use melee. | halt }
    if (%sp1 [ $+ [ $chan ] ] < 3) { notice $nick You need 75% special to do that. | halt }
    var %dhally [ $+ [ $chan ] ] $hit(dhally,%p1 [ $+ [ $chan ] ],%p2 [ $+ [ $chan ] ])
    var %dhallyhit [ $+ [ $chan ] ] $gettok(%dhally [ $+ [ $chan ] ],1,32), %dhallyhit2 [ $+ [ $chan ] ] $gettok(%dhally [ $+ [ $chan ] ],2,32)
    if (%hp2 [ $+ [ $chan ] ] < %dhallyhit [ $+ [ $chan ] ]) { set %dhallyhit [ $+ [ $chan ] ] %hp2 [ $+ [ $chan ] ] | set %dhallyhit [ $+ [ $chan ] ] 0 }
    dec %hp2 [ $+ [ $chan ] ] $calc( %dhallyhit [ $+ [ $chan ] ] + %dhallyhit2 [ $+ [ $chan ] ] )
    unset %frozen [ $+ [ %p1 [ $+ [ $chan ] ] ] ] | unset %frozen [ $+ [ %p2 [ $+ [ $chan ] ] ] ]
    msg # $logo(DM) $s1($nick) slashes $s1(%p2 [ $+ [ $chan ] ]) with their Dragon Halberd, hitting $s2(%dhallyhit [ $+ [ $chan ] ]) - $s2(%dhallyhit2 [ $+ [ $chan ] ]) $+ . HP $+($chr(91),$s2($iif(%hp2 [ $+ [ $chan ] ] < 1,0,$v1)),$chr(93)) $hpbar(%hp2 [ $+ [ $chan ] ])
    dec %sp1 [ $+ [ $chan ] ] 3
    notice $nick Specbar: $iif(%sp1 [ $+ [ $chan ] ] < 1,0,$gettok(25 50 75 100,%sp1 [ $+ [ $chan ] ],32)) $+ $chr(37)
    set %turn [ $+ [ $chan ] ] 2
    if (%hp2 [ $+ [ $chan ] ] < 1) { dead # %p2 [ $+ [ $chan ] ] $nick | halt }
    if (%veng [ $+ [ %p2 [ $+ [ $chan ] ] ] ]) { veng %p2 [ $+ [ $chan ] ] $nick $chan % [ $+ [ $remove($1,$chr(33)) ] ] [ $+ [ hit ] ] [ $+ [ $chan ] ] }
  }
  if ($nick == %p2 [ $+ [ $chan ] ]) && (%turn [ $+ [ $chan ] ] == 2) {
    if ($readini(OnOff.ini,#,$right($1,-1))) { notice $nick $logo(ERROR) This command has been disabled for this channel. | halt }
    if (%stun [ $+ [ $nick ] ]) { msg # $logo(DM) $s1($nick) is stunned and unable to attack. HP $+($chr(91),$s2($iif(%hp2 [ $+ [ $chan ] ] < 1,0,$v1)),$chr(93)) $hpbar(%hp2 [ $+ [ $chan ] ]) | set %turn [ $+ [ $chan ] ] 1 | unset %stun [ $+ [ $nick ] ] | halt }
    if (%frozen [ $+ [ $nick ] ] == on) { notice $nick You're frozen and can't use melee. | halt }
    if (%sp2 [ $+ [ $chan ] ] < 3) { notice $nick You need 75% special to do that. | halt }
    var %dhally [ $+ [ $chan ] ] $hit(dhally,%p2 [ $+ [ $chan ] ],%p1 [ $+ [ $chan ] ])
    var %dhallyhit [ $+ [ $chan ] ] $gettok(%dhally [ $+ [ $chan ] ],1,32), %dhallyhit2 [ $+ [ $chan ] ] $gettok(%dhally [ $+ [ $chan ] ],2,32)
    if (%hp1 [ $+ [ $chan ] ] < %dhallyhit [ $+ [ $chan ] ]) { set %dhallyhit [ $+ [ $chan ] ] %hp1 [ $+ [ $chan ] ] | set %dhallyhit [ $+ [ $chan ] ] 0 }
    dec %hp1 [ $+ [ $chan ] ] $calc( %dhallyhit [ $+ [ $chan ] ] + %dhallyhit2 [ $+ [ $chan ] ] )
    unset %frozen [ $+ [ %p1 [ $+ [ $chan ] ] ] ] | unset %frozen [ $+ [ %p2 [ $+ [ $chan ] ] ] ]
    msg # $logo(DM) $s1($nick) slashes $s1(%p1 [ $+ [ $chan ] ]) with their Dragon Halberd, hitting $s2(%dhallyhit [ $+ [ $chan ] ]) - $s2(%dhallyhit2 [ $+ [ $chan ] ]) $+ . HP $+($chr(91),$s2($iif(%hp1 [ $+ [ $chan ] ] < 1,0,$v1)),$chr(93)) $hpbar(%hp1 [ $+ [ $chan ] ])
    dec %sp2 [ $+ [ $chan ] ] 3
    notice $nick Specbar: $iif(%sp2 [ $+ [ $chan ] ] < 1,0,$gettok(25 50 75 100,%sp2 [ $+ [ $chan ] ],32)) $+ $chr(37)
    set %turn [ $+ [ $chan ] ] 1
    if (%hp1 [ $+ [ $chan ] ] < 1) { dead # %p1 [ $+ [ $chan ] ] $nick | halt }
    if (%veng [ $+ [ %p1 [ $+ [ $chan ] ] ] ]) { veng %p1 [ $+ [ $chan ] ] $nick $chan % [ $+ [ $remove($1,$chr(33)) ] ] [ $+ [ hit ] ] [ $+ [ $chan ] ] }

  }
}

on *:TEXT:!ssword:#: {
  if (# == #iDM || # == #iDM.Staff) && ($me != iDM) { halt }
  if ($nick == %p1 [ $+ [ $chan ] ]) && (%turn [ $+ [ $chan ] ] == 1) {
    if ($readini(OnOff.ini,#,$right($1,-1))) { notice $nick $logo(ERROR) This command has been disabled for this channel. | halt }
    if (%stun [ $+ [ $nick ] ]) { msg # $logo(DM) $s1($nick) is stunned and unable to attack. HP $+($chr(91),$s2($iif(%hp1 [ $+ [ $chan ] ] < 1,0,$v1)),$chr(93)) $hpbar(%hp1 [ $+ [ $chan ] ]) | set %turn [ $+ [ $chan ] ] 2 | unset %stun [ $+ [ $nick ] ] | halt }
    if (%frozen [ $+ [ $nick ] ] == on) { notice $nick You're frozen and can't use melee. | halt }
    if (%sp1 [ $+ [ $chan ] ] < 4) { notice $nick You need 100% special to do this. | halt }
    var %sswordhit [ $+ [ $chan ] ] $hit(ssword,%p1 [ $+ [ $chan ] ],%p2 [ $+ [ $chan ] ])
    if (%hp2 [ $+ [ $chan ] ] < %sswordhit [ $+ [ $chan ] ]) { set %sswordhit [ $+ [ $chan ] ] %hp2 [ $+ [ $chan ] ] }
    set %sswordhit2r [ $+ [ $chan ] ] $rand(1,3)
    dec %sp1 [ $+ [ $chan ] ] 4
    if (%sswordhit2r [ $+ [ $chan ] ] == 3) { set %sswordhit2 [ $+ [ $chan ] ] $rand(5,16) | dec %hp2 [ $+ [ $chan ] ] %sswordhit2 [ $+ [ $chan ] ] }
    dec %hp2 [ $+ [ $chan ] ] %sswordhit [ $+ [ $chan ] ]
    unset %frozen [ $+ [ %p1 [ $+ [ $chan ] ] ] ] | unset %frozen [ $+ [ %p2 [ $+ [ $chan ] ] ] ]
    msg # $logo(DM) $s1($nick) smacks $s1(%p2 [ $+ [ $chan ] ]) with their Saradomin Sword, hitting $s2(%sswordhit [ $+ [ $chan ] ]) $iif(%sswordhit2r [ $+ [ $chan ] ] == 3 , (11Saradomin Lightning hits $s2(%sswordhit2 [ $+ [ $chan ] ]) $+ ) , $+ ). HP $+($chr(91),$s2($iif(%hp2 [ $+ [ $chan ] ] < 1,0,$v1)),$chr(93)) $hpbar(%hp2 [ $+ [ $chan ] ])
    set %turn [ $+ [ $chan ] ] 2
    unset %sswordhit2r [ $+ [ $chan ] ]
    notice $nick Specbar: $iif(%sp1 [ $+ [ $chan ] ] < 1,0,$gettok(25 50 75 100,%sp1 [ $+ [ $chan ] ],32)) $+ $chr(37)
    if (%hp2 [ $+ [ $chan ] ] < 1) { dead # %p2 [ $+ [ $chan ] ] $nick | halt }
    if (%veng [ $+ [ %p2 [ $+ [ $chan ] ] ] ]) { veng %p2 [ $+ [ $chan ] ] $nick $chan % [ $+ [ $remove($1,$chr(33)) ] ] [ $+ [ hit ] ] [ $+ [ $chan ] ] }
  }
  if ($nick == %p2 [ $+ [ $chan ] ]) && (%turn [ $+ [ $chan ] ] == 2) {
    if ($readini(OnOff.ini,#,$right($1,-1))) { notice $nick $logo(ERROR) This command has been disabled for this channel. | halt }
    if (%stun [ $+ [ $nick ] ]) { msg # $logo(DM) $s1($nick) is stunned and unable to attack. HP $+($chr(91),$s2($iif(%hp2 [ $+ [ $chan ] ] < 1,0,$v1)),$chr(93)) $hpbar(%hp2 [ $+ [ $chan ] ]) | set %turn [ $+ [ $chan ] ] 1 | unset %stun [ $+ [ $nick ] ] | halt }
    if (%frozen [ $+ [ $nick ] ] == on) { notice $nick You're frozen and can't use melee. | halt }
    if (%sp2 [ $+ [ $chan ] ] < 4) { notice $nick You need 100% special to do this. | halt }
    var %sswordhit [ $+ [ $chan ] ] $hit(ssword,%p2 [ $+ [ $chan ] ],%p1 [ $+ [ $chan ] ])
    if (%hp1 [ $+ [ $chan ] ] < %sswordhit [ $+ [ $chan ] ]) { set %sswordhit [ $+ [ $chan ] ] %hp1 [ $+ [ $chan ] ] }
    set %sswordhit2r [ $+ [ $chan ] ] $rand(1,3)
    dec %sp2 [ $+ [ $chan ] ] 4
    if (%sswordhit2r [ $+ [ $chan ] ] == 3) { set %sswordhit2 [ $+ [ $chan ] ] $rand(5,16) | dec %hp1 [ $+ [ $chan ] ] %sswordhit2 [ $+ [ $chan ] ] }
    dec %hp1 [ $+ [ $chan ] ] %sswordhit [ $+ [ $chan ] ]
    unset %frozen [ $+ [ %p1 [ $+ [ $chan ] ] ] ] | unset %frozen [ $+ [ %p2 [ $+ [ $chan ] ] ] ]
    msg # $logo(DM) $s1($nick) smacks $s1(%p1 [ $+ [ $chan ] ]) with their Saradomin Sword, hitting $s2(%sswordhit [ $+ [ $chan ] ]) $iif(%sswordhit2r [ $+ [ $chan ] ] == 3 , (11Saradomin Lightning hits $s2(%sswordhit2 [ $+ [ $chan ] ]) $+ ) , $+ ). HP $+($chr(91),$s2($iif(%hp1 [ $+ [ $chan ] ] < 1,0,$v1)),$chr(93)) $hpbar(%hp1 [ $+ [ $chan ] ])
    set %turn [ $+ [ $chan ] ] 1
    unset %sswordhit2r [ $+ [ $chan ] ]
    notice $nick Specbar: $iif(%sp2 [ $+ [ $chan ] ] < 1,0,$gettok(25 50 75 100,%sp2 [ $+ [ $chan ] ],32)) $+ $chr(37)
    if (%hp1 [ $+ [ $chan ] ] < 1) { dead # %p1 [ $+ [ $chan ] ] $nick | halt }
    if (%veng [ $+ [ %p1 [ $+ [ $chan ] ] ] ]) { veng %p1 [ $+ [ $chan ] ] $nick $chan % [ $+ [ $remove($1,$chr(33)) ] ] [ $+ [ hit ] ] [ $+ [ $chan ] ] }
  }
}
on *:TEXT:!anchor:#: {
  if (# == #iDM || # == #iDM.Staff) && ($me != iDM) { halt }
  if ($nick == %p1 [ $+ [ $chan ] ]) && (%turn [ $+ [ $chan ] ] == 1) {
    if ($readini(OnOff.ini,#,$right($1,-1))) { notice $nick $logo(ERROR) This command has been disabled for this channel. | halt }
    if (%frozen [ $+ [ $nick ] ] == on) { notice $nick You're frozen and can't use melee. | halt }
    if (%sp1 [ $+ [ $chan ] ] < 4) { notice $nick You need 100% special to do this. | halt }
    var %anchorhit [ $+ [ $chan ] ] $hit(anchor,%p1 [ $+ [ $chan ] ],%p2 [ $+ [ $chan ] ])
    if (%hp2 [ $+ [ $chan ] ] < %anchorhit [ $+ [ $chan ] ]) { set %anchorhit [ $+ [ $chan ] ] %hp2 [ $+ [ $chan ] ] }
    dec %hp2 [ $+ [ $chan ] ] %anchorhit [ $+ [ $chan ] ]
    dec %sp1 [ $+ [ $chan ] ] 4
    unset %frozen [ $+ [ %p1 [ $+ [ $chan ] ] ] ] | unset %frozen [ $+ [ %p2 [ $+ [ $chan ] ] ] ]
    msg # $logo(DM) $s1($nick) smashes their Anchor down on $s1(%p2 [ $+ [ $chan ] ]), hitting $s2(%anchorhit [ $+ [ $chan ] ]) $+ . HP $+($chr(91),$s2($iif(%hp2 [ $+ [ $chan ] ] < 1,0,$v1)),$chr(93)) $hpbar(%hp2 [ $+ [ $chan ] ])
    set %turn [ $+ [ $chan ] ] 2
    notice $nick Specbar: $iif(%sp1 [ $+ [ $chan ] ] < 1,0,$gettok(25 50 75 100,%sp1 [ $+ [ $chan ] ],32)) $+ $chr(37)
    if (%hp2 [ $+ [ $chan ] ] < 1) { dead # %p2 [ $+ [ $chan ] ] $nick | halt }
    if (%veng [ $+ [ %p2 [ $+ [ $chan ] ] ] ]) { veng %p2 [ $+ [ $chan ] ] $nick $chan % [ $+ [ $remove($1,$chr(33)) ] ] [ $+ [ hit ] ] [ $+ [ $chan ] ] }
  }
  if ($nick == %p2 [ $+ [ $chan ] ]) && (%turn [ $+ [ $chan ] ] == 2) {
    if ($readini(OnOff.ini,#,$right($1,-1))) { notice $nick $logo(ERROR) This command has been disabled for this channel. | halt }
    if (%frozen [ $+ [ $nick ] ] == on) { notice $nick You're frozen and can't use melee. | halt }
    if (%sp2 [ $+ [ $chan ] ] < 4) { notice $nick You need 100% special to do this. | halt }
    var %anchorhit [ $+ [ $chan ] ] $hit(anchor,%p2 [ $+ [ $chan ] ],%p1 [ $+ [ $chan ] ])
    if (%hp1 [ $+ [ $chan ] ] < %anchorhit [ $+ [ $chan ] ]) { set %anchorhit [ $+ [ $chan ] ] %hp1 [ $+ [ $chan ] ] }
    dec %hp1 [ $+ [ $chan ] ] %anchorhit [ $+ [ $chan ] ]
    dec %sp2 [ $+ [ $chan ] ] 4
    unset %frozen [ $+ [ %p1 [ $+ [ $chan ] ] ] ] | unset %frozen [ $+ [ %p2 [ $+ [ $chan ] ] ] ]
    msg # $logo(DM) $s1($nick) smashes their Anchor down on $s1(%p1 [ $+ [ $chan ] ]), hitting $s2(%anchorhit [ $+ [ $chan ] ]) $+ . HP $+($chr(91),$s2($iif(%hp1 [ $+ [ $chan ] ] < 1,0,$v1)),$chr(93)) $hpbar(%hp1 [ $+ [ $chan ] ])
    set %turn [ $+ [ $chan ] ] 1
    notice $nick Specbar: $iif(%sp2 [ $+ [ $chan ] ] < 1,0,$gettok(25 50 75 100,%sp2 [ $+ [ $chan ] ],32)) $+ $chr(37)
    if (%hp1 [ $+ [ $chan ] ] < 1) { dead # %p1 [ $+ [ $chan ] ] $nick | halt }
    if (%veng [ $+ [ %p1 [ $+ [ $chan ] ] ] ]) { veng %p1 [ $+ [ $chan ] ] $nick $chan % [ $+ [ $remove($1,$chr(33)) ] ] [ $+ [ hit ] ] [ $+ [ $chan ] ] }
  }
}
on *:TEXT:!vlong:#: {
  if (# == #iDM || # == #iDM.Staff) && ($me != iDM) { halt }
  if ($nick == %p1 [ $+ [ $chan ] ]) && (%turn [ $+ [ $chan ] ] == 1) {
    if (!$readini(PvP.ini,vlong,$nick)) { notice $nick You can only use this once you've received it as a drop. | halt }
    if ($readini(OnOff.ini,#,$right($1,-1))) { notice $nick $logo(ERROR) This command has been disabled for this channel. | halt }
    if (%stun [ $+ [ $nick ] ]) { msg # $logo(DM) $s1($nick) is stunned and unable to attack. HP $+($chr(91),$s2($iif(%hp1 [ $+ [ $chan ] ] < 1,0,$v1)),$chr(93)) $hpbar(%hp1 [ $+ [ $chan ] ]) | set %turn [ $+ [ $chan ] ] 2 | unset %stun [ $+ [ $nick ] ]  | halt }
    if (%frozen [ $+ [ $nick ] ] == on) { notice $nick You're frozen and can't use melee. | halt }
    if (%sp1 [ $+ [ $chan ] ] < 2) { notice $nick You need 50% special to do this. | halt }
    dec %sp1 [ $+ [ $chan ] ] 2
    if ($readini(PvP.ini,vlong,$nick) < 1) { remini -n PvP.ini vlong $nick }
    if ($readini(PvP.ini,vlong,$nick) >= 1) { writeini -n PvP.ini vlong $nick $calc($readini(PvP.ini,vlong,$nick) -1) }
    var %vlonghit [ $+ [ $chan ] ] $hit(vlong,%p1 [ $+ [ $chan ] ],%p2 [ $+ [ $chan ] ]) 
    if (%hp2 [ $+ [ $chan ] ] < %vlonghit [ $+ [ $chan ] ]) {  set %vlonghit [ $+ [ $chan ] ] %hp2 [ $+ [ $chan ] ] | set %hp2 [ $+ [ $chan ] ] 0 }
    if (%hp2 [ $+ [ $chan ] ] >= 1) { dec %hp2 [ $+ [ $chan ] ] %vlonghit [ $+ [ $chan ] ] }
    unset %frozen [ $+ [ %p1 [ $+ [ $chan ] ] ] ] | unset %frozen [ $+ [ %p2 [ $+ [ $chan ] ] ] ]
    msg # $logo(DM) $s1($nick) slashes their Vesta's longsword at $s1(%p2 [ $+ [ $chan ] ]) $+ $chr(44) hitting $s2(%vlonghit [ $+ [ $chan ] ]) $+ . HP $+($chr(91),$s2($iif(%hp2 [ $+ [ $chan ] ] < 1,0,$v1)),$chr(93)) $hpbar(%hp2 [ $+ [ $chan ] ])
    notice $nick Specbar: $iif(%sp1 [ $+ [ $chan ] ] < 1,0,$gettok(25 50 75 100,%sp1 [ $+ [ $chan ] ],32)) $+ $chr(37)
    set %turn [ $+ [ $chan ] ] 2
    if (%hp2 [ $+ [ $chan ] ] < 1) { dead # %p2 [ $+ [ $chan ] ] $nick | halt }
    if (%veng [ $+ [ %p2 [ $+ [ $chan ] ] ] ]) { veng %p2 [ $+ [ $chan ] ] $nick $chan % [ $+ [ $remove($1,$chr(33)) ] ] [ $+ [ hit ] ] [ $+ [ $chan ] ] }
  }
  if ($nick == %p2 [ $+ [ $chan ] ]) && (%turn [ $+ [ $chan ] ] == 2) {
    if (!$readini(PvP.ini,vlong,$nick)) { notice $nick You can only use this once you've received it as a drop. | halt }
    if ($readini(OnOff.ini,#,$right($1,-1))) { notice $nick $logo(ERROR) This command has been disabled for this channel. | halt }
    if (%stun [ $+ [ $nick ] ]) { msg # $logo(DM) $s1($nick) is stunned and unable to attack. HP $+($chr(91),$s2($iif(%hp2 [ $+ [ $chan ] ] < 1,0,$v1)),$chr(93)) $hpbar(%hp2 [ $+ [ $chan ] ]) | set %turn [ $+ [ $chan ] ] 1 | unset %stun [ $+ [ $nick ] ]  | halt }
    if (%frozen [ $+ [ $nick ] ] == on) { notice $nick You're frozen and can't use melee. | halt }
    if (%sp2 [ $+ [ $chan ] ] < 2) { notice $nick You need 50% special to do this. | halt }
    dec %sp2 [ $+ [ $chan ] ] 2
    if ($readini(PvP.ini,vlong,$nick) < 1) { remini -n PvP.ini vlong $nick }
    if ($readini(PvP.ini,vlong,$nick) >= 1) { writeini -n PvP.ini vlong $nick $calc($readini(PvP.ini,vlong,$nick) -1) }
    var %vlonghit [ $+ [ $chan ] ] $hit(vlong,%p2 [ $+ [ $chan ] ],%p1 [ $+ [ $chan ] ]) 
    if (%hp1 [ $+ [ $chan ] ] < %vlonghit [ $+ [ $chan ] ]) { set %vlonghit [ $+ [ $chan ] ] %hp1 [ $+ [ $chan ] ] | set %hp1 [ $+ [ $chan ] ] 0 }
    if (%hp1 [ $+ [ $chan ] ] >= 1) { dec %hp1 [ $+ [ $chan ] ] %vlonghit [ $+ [ $chan ] ] }
    unset %frozen [ $+ [ %p1 [ $+ [ $chan ] ] ] ] | unset %frozen [ $+ [ %p2 [ $+ [ $chan ] ] ] ]
    msg # $logo(DM) $s1($nick) slashes their Vesta's longsword at $s1(%p1 [ $+ [ $chan ] ]) $+ $chr(44) hitting $s2(%vlonghit [ $+ [ $chan ] ]) $+ . HP $+($chr(91),$s2($iif(%hp1 [ $+ [ $chan ] ] < 1,0,$v1)),$chr(93)) $hpbar(%hp1 [ $+ [ $chan ] ])
    notice $nick Specbar: $iif(%sp2 [ $+ [ $chan ] ] < 1,0,$gettok(25 50 75 100,%sp2 [ $+ [ $chan ] ],32)) $+ $chr(37)
    set %turn [ $+ [ $chan ] ] 1
    if (%hp1 [ $+ [ $chan ] ] < 1) { dead # %p1 [ $+ [ $chan ] ] $nick | halt }
    if (%veng [ $+ [ %p1 [ $+ [ $chan ] ] ] ]) { veng %p1 [ $+ [ $chan ] ] $nick $chan % [ $+ [ $remove($1,$chr(33)) ] ] [ $+ [ hit ] ] [ $+ [ $chan ] ] }
  }
}
on *:TEXT:!statius:#: {
  if (# == #iDM || # == #iDM.Staff) && ($me != iDM) { halt }
  if ($nick == %p1 [ $+ [ $chan ] ]) && (%turn [ $+ [ $chan ] ] == 1) {
    if (!$readini(PvP.ini,statius,$nick)) { notice $nick You can only use this once you've received it as a drop. | halt }
    if ($readini(OnOff.ini,#,$right($1,-1))) { notice $nick $logo(ERROR) This command has been disabled for this channel. | halt }
    if (%stun [ $+ [ $nick ] ]) { msg # $logo(DM) $s1($nick) is stunned and unable to attack. HP $+($chr(91),$s2($iif(%hp1 [ $+ [ $chan ] ] < 1,0,$v1)),$chr(93)) $hpbar(%hp1 [ $+ [ $chan ] ]) | set %turn [ $+ [ $chan ] ] 2 | unset %stun [ $+ [ $nick ] ]  | halt }
    if (%frozen [ $+ [ $nick ] ] == on) { notice $nick You're frozen and can't use melee. | halt }
    if (%sp1 [ $+ [ $chan ] ] < 4) { notice $nick You need 100% special to do this. | halt }
    dec %sp1 [ $+ [ $chan ] ] 4
    if ($readini(PvP.ini,statius,$nick) < 1) { remini -n PvP.ini statius $nick }
    if ($readini(PvP.ini,statius,$nick) >= 1) { writeini -n PvP.ini statius $nick $calc($readini(PvP.ini,statius,$nick) -1) }
    var %statiushit [ $+ [ $chan ] ] $hit(statius,%p1 [ $+ [ $chan ] ],%p2 [ $+ [ $chan ] ]) 
    if (%hp2 [ $+ [ $chan ] ] < %statiushit [ $+ [ $chan ] ]) {  set %statiushit [ $+ [ $chan ] ] %hp2 [ $+ [ $chan ] ] | set %hp2 [ $+ [ $chan ] ] 0 }
    if (%hp2 [ $+ [ $chan ] ] >= 1) { dec %hp2 [ $+ [ $chan ] ] %statiushit [ $+ [ $chan ] ] }
    unset %frozen [ $+ [ %p1 [ $+ [ $chan ] ] ] ] | unset %frozen [ $+ [ %p2 [ $+ [ $chan ] ] ] ]
    msg # $logo(DM) $s1($nick) pwns $s1(%p2 [ $+ [ $chan ] ]) with a Statius's warhammer, hitting $s2(%statiushit [ $+ [ $chan ] ]) $+ . HP $+($chr(91),$s2($iif(%hp2 [ $+ [ $chan ] ] < 1,0,$v1)),$chr(93)) $hpbar(%hp2 [ $+ [ $chan ] ])
    notice $nick Specbar: $iif(%sp1 [ $+ [ $chan ] ] < 1,0,$gettok(25 50 75 100,%sp1 [ $+ [ $chan ] ],32)) $+ $chr(37)
    set %turn [ $+ [ $chan ] ] 2
    if (%hp2 [ $+ [ $chan ] ] < 1) { dead # %p2 [ $+ [ $chan ] ] $nick | halt }
    if (%veng [ $+ [ %p2 [ $+ [ $chan ] ] ] ]) { veng %p2 [ $+ [ $chan ] ] $nick $chan % [ $+ [ $remove($1,$chr(33)) ] ] [ $+ [ hit ] ] [ $+ [ $chan ] ] }
  }
  if ($nick == %p2 [ $+ [ $chan ] ]) && (%turn [ $+ [ $chan ] ] == 2) {
    if (!$readini(PvP.ini,statius,$nick)) { notice $nick You can only use this once you've received it as a drop. | halt }
    if ($readini(OnOff.ini,#,$right($1,-1))) { notice $nick $logo(ERROR) This command has been disabled for this channel. | halt }
    if (%stun [ $+ [ $nick ] ]) { msg # $logo(DM) $s1($nick) is stunned and unable to attack. HP $+($chr(91),$s2($iif(%hp2 [ $+ [ $chan ] ] < 1,0,$v1)),$chr(93)) $hpbar(%hp2 [ $+ [ $chan ] ]) | set %turn [ $+ [ $chan ] ] 1 | unset %stun [ $+ [ $nick ] ]  | halt }
    if (%frozen [ $+ [ $nick ] ] == on) { notice $nick You're frozen and can't use melee. | halt }
    if (%sp2 [ $+ [ $chan ] ] < 4) { notice $nick You need 100% special to do this. | halt }
    dec %sp2 [ $+ [ $chan ] ] 4
    if ($readini(PvP.ini,statius,$nick) < 1) { remini -n PvP.ini statius $nick }
    if ($readini(PvP.ini,statius,$nick) >= 1) { writeini -n PvP.ini statius $nick $calc($readini(PvP.ini,statius,$nick) -1) }
    var %statiushit [ $+ [ $chan ] ] $hit(statius,%p2 [ $+ [ $chan ] ],%p1 [ $+ [ $chan ] ]) 
    if (%hp1 [ $+ [ $chan ] ] < %statiushit [ $+ [ $chan ] ]) { set %statiushit [ $+ [ $chan ] ] %hp1 [ $+ [ $chan ] ] | set %hp1 [ $+ [ $chan ] ] 0 }
    if (%hp1 [ $+ [ $chan ] ] >= 1) { dec %hp1 [ $+ [ $chan ] ] %statiushit [ $+ [ $chan ] ] }
    unset %frozen [ $+ [ %p1 [ $+ [ $chan ] ] ] ] | unset %frozen [ $+ [ %p2 [ $+ [ $chan ] ] ] ]
    msg # $logo(DM) $s1($nick) pwns $s1(%p1 [ $+ [ $chan ] ]) with a Statius's warhammer, hitting $s2(%statiushit [ $+ [ $chan ] ]) $+ . HP $+($chr(91),$s2($iif(%hp1 [ $+ [ $chan ] ] < 1,0,$v1)),$chr(93)) $hpbar(%hp1 [ $+ [ $chan ] ])
    notice $nick Specbar: $iif(%sp2 [ $+ [ $chan ] ] < 1,0,$gettok(25 50 75 100,%sp2 [ $+ [ $chan ] ],32)) $+ $chr(37)
    set %turn [ $+ [ $chan ] ] 1
    if (%hp1 [ $+ [ $chan ] ] < 1) { dead # %p1 [ $+ [ $chan ] ] $nick | halt }
    if (%veng [ $+ [ %p1 [ $+ [ $chan ] ] ] ]) { veng %p1 [ $+ [ $chan ] ] $nick $chan % [ $+ [ $remove($1,$chr(33)) ] ] [ $+ [ hit ] ] [ $+ [ $chan ] ] }
  }
}
on *:TEXT:!vspear:#: {
  if (# == #iDM || # == #iDM.Staff) && ($me != iDM) { halt }
  if ($nick == %p1 [ $+ [ $chan ] ]) && (%turn [ $+ [ $chan ] ] == 1) {
    if (!$readini(PvP.ini,vspear,$nick)) { notice $nick You can only use this once you've received it as a drop. | halt }
    if ($readini(OnOff.ini,#,$right($1,-1))) { notice $nick $logo(ERROR) This command has been disabled for this channel. | halt }
    if (%stun [ $+ [ $nick ] ]) { msg # $logo(DM) $s1($nick) is stunned and unable to attack. HP $+($chr(91),$s2($iif(%hp1 [ $+ [ $chan ] ] < 1,0,$v1)),$chr(93)) $hpbar(%hp1 [ $+ [ $chan ] ]) | set %turn [ $+ [ $chan ] ] 2 | unset %stun [ $+ [ $nick ] ]  | halt }
    if (%frozen [ $+ [ $nick ] ] == on) { notice $nick You're frozen and can't use melee. | halt }
    if (%sp1 [ $+ [ $chan ] ] < 2) { notice $nick You need 50% special to do this. | halt }
    dec %sp1 [ $+ [ $chan ] ] 2
    if ($readini(PvP.ini,vspear,$nick) < 1) { remini -n PvP.ini vspear $nick }
    if ($readini(PvP.ini,vspear,$nick) >= 1) { writeini -n PvP.ini vspear $nick $calc($readini(PvP.ini,vspear,$nick) -1) }
    var %vspearhit [ $+ [ $chan ] ] $hit(vspear,%p1 [ $+ [ $chan ] ],%p2 [ $+ [ $chan ] ]) 
    if (%hp2 [ $+ [ $chan ] ] < %vspearhit [ $+ [ $chan ] ]) {  set %vspearhit [ $+ [ $chan ] ] %hp2 [ $+ [ $chan ] ] | set %hp2 [ $+ [ $chan ] ] 0 }
    if (%hp2 [ $+ [ $chan ] ] >= 1) { dec %hp2 [ $+ [ $chan ] ] %vspearhit [ $+ [ $chan ] ] }
    unset %frozen [ $+ [ %p1 [ $+ [ $chan ] ] ] ]
    msg # $logo(DM) $s1($nick) 12freezes $s1(%p2 [ $+ [ $chan ] ]) using a Vesta's spear, and hits $s2(%vspearhit [ $+ [ $chan ] ]) $+ . HP $+($chr(91),$s2($iif(%hp2 [ $+ [ $chan ] ] < 1,0,$v1)),$chr(93)) $hpbar(%hp2 [ $+ [ $chan ] ])
    set %frozen [ $+ [ %p2 [ $+ [ $chan ] ] ] ] on | notice %p2 [ $+ [ $chan ] ] You're unable to use melee attacks.
    notice $nick Specbar: $iif(%sp1 [ $+ [ $chan ] ] < 1,0,$gettok(25 50 75 100,%sp1 [ $+ [ $chan ] ],32)) $+ $chr(37)
    set %turn [ $+ [ $chan ] ] 2
    if (%hp2 [ $+ [ $chan ] ] < 1) { dead # %p2 [ $+ [ $chan ] ] $nick | halt }
    if (%veng [ $+ [ %p2 [ $+ [ $chan ] ] ] ]) { veng %p2 [ $+ [ $chan ] ] $nick $chan % [ $+ [ $remove($1,$chr(33)) ] ] [ $+ [ hit ] ] [ $+ [ $chan ] ] }
  }
  if ($nick == %p2 [ $+ [ $chan ] ]) && (%turn [ $+ [ $chan ] ] == 2) {
    if (!$readini(PvP.ini,vspear,$nick)) { notice $nick You can only use this once you've received it as a drop. | halt }
    if ($readini(OnOff.ini,#,$right($1,-1))) { notice $nick $logo(ERROR) This command has been disabled for this channel. | halt }
    if (%stun [ $+ [ $nick ] ]) { msg # $logo(DM) $s1($nick) is stunned and unable to attack. HP $+($chr(91),$s2($iif(%hp2 [ $+ [ $chan ] ] < 1,0,$v1)),$chr(93)) $hpbar(%hp2 [ $+ [ $chan ] ]) | set %turn [ $+ [ $chan ] ] 1 | unset %stun [ $+ [ $nick ] ]  | halt }
    if (%frozen [ $+ [ $nick ] ] == on) { notice $nick You're unable to use melee for one turn. | halt }
    if (%sp2 [ $+ [ $chan ] ] < 2) { notice $nick You need 50% special to do this. | halt }
    dec %sp2 [ $+ [ $chan ] ] 2
    if ($readini(PvP.ini,vspear,$nick) < 1) { remini -n PvP.ini vspear $nick }
    if ($readini(PvP.ini,vspear,$nick) >= 1) { writeini -n PvP.ini vspear $nick $calc($readini(PvP.ini,vspear,$nick) -1) }
    var %vspearhit [ $+ [ $chan ] ] $hit(vspear,%p2 [ $+ [ $chan ] ],%p1 [ $+ [ $chan ] ]) 
    if (%hp1 [ $+ [ $chan ] ] < %vspearhit [ $+ [ $chan ] ]) { set %vspearhit [ $+ [ $chan ] ] %hp1 [ $+ [ $chan ] ] | set %hp1 [ $+ [ $chan ] ] 0 }
    if (%hp1 [ $+ [ $chan ] ] >= 1) { dec %hp1 [ $+ [ $chan ] ] %vspearhit [ $+ [ $chan ] ] }
    unset %frozen [ $+ [ %p2 [ $+ [ $chan ] ] ] ]
    msg # $logo(DM) $s1($nick) 12freezes $s1(%p1 [ $+ [ $chan ] ]) using a Vesta's spear, and hits $s2(%vspearhit [ $+ [ $chan ] ]) $+ . HP $+($chr(91),$s2($iif(%hp1 [ $+ [ $chan ] ] < 1,0,$v1)),$chr(93)) $hpbar(%hp1 [ $+ [ $chan ] ])
    set %frozen [ $+ [ %p1 [ $+ [ $chan ] ] ] ] on | notice %p1 [ $+ [ $chan ] ] You're unable to use melee attacks.
    notice $nick Specbar: $iif(%sp2 [ $+ [ $chan ] ] < 1,0,$gettok(25 50 75 100,%sp2 [ $+ [ $chan ] ],32)) $+ $chr(37)
    set %turn [ $+ [ $chan ] ] 1
    if (%hp1 [ $+ [ $chan ] ] < 1) { dead # %p1 [ $+ [ $chan ] ] $nick | halt }
    if (%veng [ $+ [ %p1 [ $+ [ $chan ] ] ] ]) { veng %p1 [ $+ [ $chan ] ] $nick $chan % [ $+ [ $remove($1,$chr(33)) ] ] [ $+ [ hit ] ] [ $+ [ $chan ] ] }
  }
}
on *:TEXT:!mjavelin:#: {
  if (# == #iDM || # == #iDM.Staff) && ($me != iDM) { halt }
  if ($nick == %p1 [ $+ [ $chan ] ]) && (%turn [ $+ [ $chan ] ] == 1) {
    if (!$readini(PvP.ini,MJavelin,$nick)) { notice $nick You can only use this once you've received it as a drop. | halt }
    if ($readini(OnOff.ini,#,$right($1,-1))) { notice $nick $logo(ERROR) This command has been disabled for this channel. | halt }
    if (%stun [ $+ [ $nick ] ]) { msg # $logo(DM) $s1($nick) is stunned and unable to attack. HP $+($chr(91),$s2($iif(%hp1 [ $+ [ $chan ] ] < 1,0,$v1)),$chr(93)) $hpbar(%hp1 [ $+ [ $chan ] ]) | set %turn [ $+ [ $chan ] ] 2 | unset %stun [ $+ [ $nick ] ]  | halt }
    if (%sp1 [ $+ [ $chan ] ] < 1) { notice $nick You need 25% special to do this. | halt }
    dec %sp1 [ $+ [ $chan ] ] 1
    if ($readini(PvP.ini,MJavelin,$nick) < 1) { remini -n PvP.ini MJavelin $nick }
    if ($readini(PvP.ini,MJavelin,$nick) >= 1) { writeini -n PvP.ini MJavelin $nick $calc($readini(PvP.ini,MJavelin,$nick) -1) }
    var %mjavelinhit [ $+ [ $chan ] ] $hit(MJavelin,%p1 [ $+ [ $chan ] ],%p2 [ $+ [ $chan ] ]) 
    if (%hp2 [ $+ [ $chan ] ] < %mjavelinhit [ $+ [ $chan ] ]) {  set %mjavelinhit [ $+ [ $chan ] ] %hp2 [ $+ [ $chan ] ] | set %hp2 [ $+ [ $chan ] ] 0 }
    if (%hp2 [ $+ [ $chan ] ] >= 1) { dec %hp2 [ $+ [ $chan ] ] %mjavelinhit [ $+ [ $chan ] ] }
    unset %frozen [ $+ [ %p1 [ $+ [ $chan ] ] ] ] | unset %frozen [ $+ [ %p2 [ $+ [ $chan ] ] ] ]
    msg # $logo(DM) $s1($nick) throws a Morrigan's javelin at $s1(%p2 [ $+ [ $chan ] ]) hitting $s2(%mjavelinhit [ $+ [ $chan ] ]) $+ . HP $+($chr(91),$s2($iif(%hp2 [ $+ [ $chan ] ] < 1,0,$v1)),$chr(93)) $hpbar(%hp2 [ $+ [ $chan ] ])
    notice $nick Specbar: $iif(%sp1 [ $+ [ $chan ] ] < 1,0,$gettok(25 50 75 100,%sp1 [ $+ [ $chan ] ],32)) $+ $chr(37)
    set %turn [ $+ [ $chan ] ] 2
    if (%hp2 [ $+ [ $chan ] ] < 1) { dead # %p2 [ $+ [ $chan ] ] $nick | halt }
    if (%veng [ $+ [ %p2 [ $+ [ $chan ] ] ] ]) { veng %p2 [ $+ [ $chan ] ] $nick $chan % [ $+ [ $remove($1,$chr(33)) ] ] [ $+ [ hit ] ] [ $+ [ $chan ] ] }
  }
  if ($nick == %p2 [ $+ [ $chan ] ]) && (%turn [ $+ [ $chan ] ] == 2) {
    if (!$readini(PvP.ini,MJavelin,$nick)) { notice $nick You can only use this once you've received it as a drop. | halt }
    if ($readini(OnOff.ini,#,$right($1,-1))) { notice $nick $logo(ERROR) This command has been disabled for this channel. | halt }
    if (%stun [ $+ [ $nick ] ]) { msg # $logo(DM) $s1($nick) is stunned and unable to attack. HP $+($chr(91),$s2($iif(%hp2 [ $+ [ $chan ] ] < 1,0,$v1)),$chr(93)) $hpbar(%hp2 [ $+ [ $chan ] ]) | set %turn [ $+ [ $chan ] ] 1 | unset %stun [ $+ [ $nick ] ]  | halt }
    if (%sp2 [ $+ [ $chan ] ] < 1) { notice $nick You need 25% special to do this. | halt }
    dec %sp2 [ $+ [ $chan ] ] 1
    if ($readini(PvP.ini,MJavelin,$nick) < 1) { remini -n PvP.ini MJavelin $nick }
    if ($readini(PvP.ini,MJavelin,$nick) >= 1) { writeini -n PvP.ini MJavelin $nick $calc($readini(PvP.ini,MJavelin,$nick) -1) }
    var %mjavelinhit [ $+ [ $chan ] ] $hit(MJavelin,%p2 [ $+ [ $chan ] ],%p1 [ $+ [ $chan ] ]) 
    if (%hp1 [ $+ [ $chan ] ] < %mjavelinhit [ $+ [ $chan ] ]) { set %mjavelinhit [ $+ [ $chan ] ] %hp1 [ $+ [ $chan ] ] | set %hp1 [ $+ [ $chan ] ] 0 }
    if (%hp1 [ $+ [ $chan ] ] >= 1) { dec %hp1 [ $+ [ $chan ] ] %mjavelinhit [ $+ [ $chan ] ] }
    unset %frozen [ $+ [ %p1 [ $+ [ $chan ] ] ] ] | unset %frozen [ $+ [ %p2 [ $+ [ $chan ] ] ] ]
    msg # $logo(DM) $s1($nick) throws a Morrigan's javelin at $s1(%p1 [ $+ [ $chan ] ]) hitting $s2(%mjavelinhit [ $+ [ $chan ] ]) $+ . HP $+($chr(91),$s2($iif(%hp1 [ $+ [ $chan ] ] < 1,0,$v1)),$chr(93)) $hpbar(%hp1 [ $+ [ $chan ] ])
    notice $nick Specbar: $iif(%sp2 [ $+ [ $chan ] ] < 1,0,$gettok(25 50 75 100,%sp2 [ $+ [ $chan ] ],32)) $+ $chr(37)
    set %turn [ $+ [ $chan ] ] 1
    if (%hp1 [ $+ [ $chan ] ] < 1) { dead # %p1 [ $+ [ $chan ] ] $nick | halt }
    if (%veng [ $+ [ %p1 [ $+ [ $chan ] ] ] ]) { veng %p1 [ $+ [ $chan ] ] $nick $chan % [ $+ [ $remove($1,$chr(33)) ] ] [ $+ [ hit ] ] [ $+ [ $chan ] ] }
  }
}
alias hit {
  var %acc [ $+ [ $2 ] ] $r(1,100)
  var %atk [ $+ [ $2 ] ] $calc($iif($readini(Equipment.ini,Firecape,$2),5,0) + $iif($readini(Equipment.ini,bgloves,$2),3,0))
  var %def [ $+ [ $2 ] ] $iif($readini(Equipment.ini,elshield,$3),$calc($r(85,99) / 100),1)
  var %ratk [ $+ [ $2 ] ] $calc($iif($readini(Equipment.ini,void,$2),5,0) + $iif($readini(Equipment.ini,accumulator,$2),5,0))
  var %matk [ $+ [ $2 ] ] $calc($iif($readini(Equipment.ini,void-mage,$2),5,0) + $iif($readini(Equipment.ini,mbook,$2),5,0))
  goto $1
  :whip
  if (%acc [ $+ [ $2 ] ] isnum 1-4) return 0
  if (%acc [ $+ [ $2 ] ] isnum 5-30) return $r(5,25)
  if (%acc [ $+ [ $2 ] ] isnum 31-100) return $floor($calc($r(11,$calc(35 + $(,%atk [ $+ [ $2 ] ]))) * $(,%def [ $+ [ $2 ] ])))
  :dds
  if (%acc [ $+ [ $2 ] ] isnum 1-4) return 0 0
  if (%acc [ $+ [ $2 ] ] isnum 5-30) return $r(5,20) $r(5,20)
  if (%acc [ $+ [ $2 ] ] isnum 31-100) return $floor($calc($r(11,$calc(20 + $(,%atk [ $+ [ $2 ] ]))) * $(,%def [ $+ [ $2 ] ]))) $floor($calc($r(11,$calc(20 + $(,%atk [ $+ [ $2 ] ]))) * $(,%def [ $+ [ $2 ] ])))
  :ags
  if (%acc [ $+ [ $2 ] ] isnum 1-10) return 0
  if (%acc [ $+ [ $2 ] ] isnum 11-30) return $r(15,20)
  if (%acc [ $+ [ $2 ] ] isnum 31-100) return $floor($calc($r(21,$calc(55 + $(,%atk [ $+ [ $2 ] ]))) * $(,%def [ $+ [ $2 ] ])))
  :cbow
  if (%acc [ $+ [ $2 ] ] isnum 1-15) return $r(0,10)
  if (%acc [ $+ [ $2 ] ] isnum 16-30) return $r(11,20)
  if (%acc [ $+ [ $2 ] ] isnum 31-100) {
    if (%acc [ $+ [ $2 ] ] isnum 98-100) && ($readini(Equipment.ini,void,$2) || $readini(Equipment.ini,accumulator,$2)) { set %cbowspec [ $+ [ $2 ] ] 1 | return $r(60,69) | halt }
    return $floor($calc($r(21,$calc(35 + $(,%ratk [ $+ [ $2 ] ]))) * $(,%def [ $+ [ $2 ] ])))
  }
  :dbow
  if (%acc [ $+ [ $2 ] ] isnum 1-6) return 8 8
  if (%acc [ $+ [ $2 ] ] isnum 7-30) return $r(9,20) $r(9,20)
  if (%acc [ $+ [ $2 ] ] isnum 31-100) return $floor($calc($r(21,$calc(35 + $(,%ratk [ $+ [ $2 ] ]))) * $(,%def [ $+ [ $2 ] ]))) $floor($calc($r(21,$calc(35 + $(,%ratk [ $+ [ $2 ] ]))) * $(,%def [ $+ [ $2 ] ])))
  :bgs
  if (%acc [ $+ [ $2 ] ] isnum 1-5) return 0
  if (%acc [ $+ [ $2 ] ] isnum 6-35) return $r(1,35)
  if (%acc [ $+ [ $2 ] ] isnum 36-100) return $floor($calc($r(36,$calc(75 + $(,%atk [ $+ [ $2 ] ]))) * $(,%def [ $+ [ $2 ] ])))
  :sgs
  if (%acc [ $+ [ $2 ] ] isnum 1-7) return 0
  if (%acc [ $+ [ $2 ] ] isnum 8-23) return $r(1,15)
  if (%acc [ $+ [ $2 ] ] isnum 24-100) return $floor($calc($r(16,$calc(50 + $(,%atk [ $+ [ $2 ] ]))) * $(,%def [ $+ [ $2 ] ])))
  :gmaul
  if (%acc [ $+ [ $2 ] ] isnum 1-3) return $r(0,7) $r(0,7) $r(0,7)
  if (%acc [ $+ [ $2 ] ] isnum 4-40) return $r(1,12) $r(1,12) $r(1,12)
  if (%acc [ $+ [ $2 ] ] isnum 41-100) return $floor($calc($r(13,$calc(30 + $ceil($calc($(,%atk [ $+ [ $2 ] ]) / 2)))) * $(,%def [ $+ [ $2 ] ]))) $floor($calc($r(13,$calc(30 + $ceil($calc($(,%atk [ $+ [ $2 ] ]) / 2)))) * $(,%def [ $+ [ $2 ] ]))) $floor($calc($r(13,$calc(30 + $ceil($calc($(,%atk [ $+ [ $2 ] ]) / 2)))) * $(,%def [ $+ [ $2 ] ])))
  :guth
  if (%acc [ $+ [ $2 ] ] isnum 1-9) return 0
  if (%acc [ $+ [ $2 ] ] isnum 10-13) return $r(1,10)
  if (%acc [ $+ [ $2 ] ] isnum 14-100) return $floor($calc($r(11,$calc(35 + $(,%atk [ $+ [ $2 ] ]))) * $(,%def [ $+ [ $2 ] ])))
  :ice
  if (%acc [ $+ [ $2 ] ] isnum 1-3) return 0
  if (%acc [ $+ [ $2 ] ] isnum 4-30) return $r(1,15)
  if (%acc [ $+ [ $2 ] ] isnum 31-100) return $r(16,$calc(30 + $(,%matk [ $+ [ $2 ] ])))
  :zgs
  if (%acc [ $+ [ $2 ] ] isnum 1-5) return 0
  if (%acc [ $+ [ $2 ] ] isnum 6-30) return $r(1,22)
  if (%acc [ $+ [ $2 ] ] isnum 31-100) return $floor($calc($r(23,$calc(50 + $(,%atk [ $+ [ $2 ] ]))) * $(,%def [ $+ [ $2 ] ])))
  :blood
  if (%acc [ $+ [ $2 ] ] isnum 1-3) return 0
  if (%acc [ $+ [ $2 ] ] isnum 4-30) return $r(1,15)
  if (%acc [ $+ [ $2 ] ] isnum 31-100) return $r(16,$calc(30 + $(,%matk [ $+ [ $2 ] ])))
  :surf
  if (%acc [ $+ [ $2 ] ] isnum 1-20) return $r(0,10)
  if (%acc [ $+ [ $2 ] ] isnum 21-30) return $r(11,15)
  if (%acc [ $+ [ $2 ] ] isnum 31-100) return $r(16,22)
  :dclaws
  var %dclaws $r(19,24) $floor($calc($r(20,$calc(24 + $(,%atk [ $+ [ $2 ] ]))) * $(,%def [ $+ [ $2 ] ])))
  var %dclaws2 $ceil($calc($gettok(%dclaws,1,32) / 2)) $ceil($calc($gettok(%dclaws,2,32) / 2))
  var %dclaws3 $ceil($calc($gettok(%dclaws2,1,32) / 2)) $ceil($calc($gettok(%dclaws2,2,32) / 2))
  var %dclaws4 $ceil($calc($gettok(%dclaws3,1,32) / 2)) $ceil($calc($gettok(%dclaws3,2,32) / 2))
  if (%acc [ $+ [ $2 ] ] isnum 1-3) return 0 0 0 0
  if (%acc [ $+ [ $2 ] ] isnum 4-70) return $gettok(%dclaws,1,32) $gettok(%dclaws2,1,32) $gettok(%dclaws3,1,32) $gettok(%dclaws4,1,32)
  if (%acc [ $+ [ $2 ] ] isnum 71-100) return $gettok(%dclaws,2,32) $gettok(%dclaws2,2,32) $gettok(%dclaws3,2,32) $gettok(%dclaws4,2,32)
  :dmace
  if (%acc [ $+ [ $2 ] ] isnum 1-4) return 0
  if (%acc [ $+ [ $2 ] ] isnum 5-60) return $r(5,25)
  if (%acc [ $+ [ $2 ] ] isnum 61-100) return $floor($calc($r(26,$calc(45 + $(,%atk [ $+ [ $2 ] ]))) * $(,%def [ $+ [ $2 ] ])))
  :d2h
  if (%acc [ $+ [ $2 ] ] isnum 1-4) return 0
  if (%acc [ $+ [ $2 ] ] isnum 5-30) return $r(5,30)
  if (%acc [ $+ [ $2 ] ] isnum 31-100) return $floor($calc($r(31,$calc(35 + $(,%atk [ $+ [ $2 ] ]))) * $(,%def [ $+ [ $2 ] ])))
  :dscim
  if (%acc [ $+ [ $2 ] ] isnum 1-4) return 0
  if (%acc [ $+ [ $2 ] ] isnum 5-30) return $r(5,25)
  if (%acc [ $+ [ $2 ] ] isnum 31-100) return $floor($calc($r(26,$calc(30 + $(,%atk [ $+ [ $2 ] ]))) * $(,%def [ $+ [ $2 ] ])))
  :dspear
  if (%acc [ $+ [ $2 ] ] isnum 1-4) return 0
  if (%acc [ $+ [ $2 ] ] isnum 5-30) return $r(5,15)
  if (%acc [ $+ [ $2 ] ] isnum 31-100) return $floor($calc($r(16,$calc(20 + $(,%atk [ $+ [ $2 ] ]))) * $(,%def [ $+ [ $2 ] ])))
  :dlong
  if (%acc [ $+ [ $2 ] ] isnum 1-4) return 0
  if (%acc [ $+ [ $2 ] ] isnum 5-30) return $r(5,25)
  if (%acc [ $+ [ $2 ] ] isnum 31-100) return $floor($calc($r(26,$calc(35 + $(,%atk [ $+ [ $2 ] ]))) * $(,%def [ $+ [ $2 ] ])))
  :dhally
  if (%acc [ $+ [ $2 ] ] isnum 1-4) return 0 0
  if (%acc [ $+ [ $2 ] ] isnum 5-30) return $r(5,25) $r(5,25)
  if (%acc [ $+ [ $2 ] ] isnum 31-100) return $floor($calc($r(26,$calc(35 + $(,%atk [ $+ [ $2 ] ]))) * $(,%def [ $+ [ $2 ] ]))) $floor($calc($r(26,$calc(35 + %atk [ $+ [ $2 ] ])) * $(,%def [ $+ [ $2 ] ])))
  :ssword
  if (%acc [ $+ [ $2 ] ] isnum 1-4) return 0
  if (%acc [ $+ [ $2 ] ] isnum 5-30) return $r(5,25)
  if (%acc [ $+ [ $2 ] ] isnum 31-100) return $floor($calc($r(26,$calc(35 + $(,%atk [ $+ [ $2 ] ]))) * $(,%def [ $+ [ $2 ] ])))
  :anchor
  if (%acc [ $+ [ $2 ] ] isnum 1-4) return 0
  if (%acc [ $+ [ $2 ] ] isnum 5-30) return $r(5,25)
  if (%acc [ $+ [ $2 ] ] isnum 31-100) return $floor($calc($r(26,$calc(55 + $(,%atk [ $+ [ $2 ] ]))) * $(,%def [ $+ [ $2 ] ])))
  :d_h9
  return $floor($calc($r(0,$calc(75 + $(,%atk [ $+ [ $2 ] ]))) * $(,%def [ $+ [ $2 ] ])))
  :d_h10
  return $floor($calc($r(0,$calc(40 + $(,%atk [ $+ [ $2 ] ]))) * $(,%def [ $+ [ $2 ] ])))
  :vlong
  if (%acc [ $+ [ $2 ] ] isnum 1-2) return $r(0,10)
  if (%acc [ $+ [ $2 ] ] isnum 3-25) return $r(10,35)
  if (%acc [ $+ [ $2 ] ] isnum 26-100) return $floor($calc($r(30,$calc(50 + $(,%atk [ $+ [ $2 ] ])))))
  :statius
  if (%acc [ $+ [ $2 ] ] isnum 1-4) return $r(0,15)
  if (%acc [ $+ [ $2 ] ] isnum 5-25) return $r(15,35)
  if (%acc [ $+ [ $2 ] ] isnum 26-100) return $floor($calc($r(30,$calc(65 + $(,%atk [ $+ [ $2 ] ]))) * $(,%def [ $+ [ $2 ] ])))
  :vspear
  if (%acc [ $+ [ $2 ] ] isnum 1-3) return $r(0,10)
  if (%acc [ $+ [ $2 ] ] isnum 4-20) return $r(11,35)
  if (%acc [ $+ [ $2 ] ] isnum 21-100) return $floor($calc($r(35,$calc(45 + $(,%atk [ $+ [ $2 ] ]))) * $(,%def [ $+ [ $2 ] ])))
  :mjavelin
  if (%acc [ $+ [ $2 ] ] isnum 1-4) return $r(0,7)
  if (%acc [ $+ [ $2 ] ] isnum 5-38) return $r(8,25)
  if (%acc [ $+ [ $2 ] ] isnum 39-100) return $floor($calc($r(25,$calc(40 + $(,%ratk [ $+ [ $2 ] ]))) * $(,%def [ $+ [ $2 ] ])))
}
