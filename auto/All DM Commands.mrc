on $*:TEXT:/^[!.]/Si:#: { 
  if (# == #iDM || # == #iDM.Staff) && ($me != iDM) { halt }
  if ($right($1,-1) == specpot) { 
    if ($nick == %p1 [ $+ [ $chan ] ] && %turn [ $+ [ $chan ] ] == 1) || ($nick == %p2 [ $+ [ $chan ] ] && %turn [ $+ [ $chan ] ] == 2) || (($.readini(gwd.ini,#,$nick)) && (%turn [ $+ [ $chan ] ] == 1)) {
      if (!$.readini(login.ini,login,$nick)) { 
        notice $nick You have to login before you can use this command. ( $+ $s2(/msg $me $iif($.readini(Passes.ini,Passes,$nick),ident,reg) pass) $+ ) (Don't use your RuneScape password) 
        halt 
      }
      if (!$.readini(Equipment.ini,specpot,$nick)) { notice $nick You don't have any specpots. | halt }
      if ($($+(%,sp,$player($nick,#),#),2) == 4) { notice $nick You already have a full special bar. | halt }
      set $+(%,sp,$player($nick,#),#) 4
      updateini equipment.ini specpot $nick -1
      msg # $logo(DM) $s1($nick) drinks their specpot and now has 100% special.
      unset %laststyle [ $+ [ # ] ]
      set %turn [ $+ [ # ] ] $iif($player($nick,#) == 1,2,1)
      halt
    } 
  }
  if ($attack($right($1,-1))) {
    if ($nick == %p1 [ $+ [ $chan ] ] && %turn [ $+ [ $chan ] ] == 1) || ($nick == %p2 [ $+ [ $chan ] ] && %turn [ $+ [ $chan ] ] == 2) || (($.readini(gwd.ini,#,$nick)) && (%turn [ $+ [ $chan ] ] == 1)) {
      if ($calc($specused($right($1,-1)) /25) > $($+(%,sp,$player($nick,#),#),2)) { 
        notice $nick $logo(ERROR) You need $s1($specused($right($1,-1)) $+ $chr(37)) spec to use this weapon.
        halt
      }
      if ($.readini(OnOff.ini,#,$right($1,-1))) { 
        notice $nick $logo(ERROR) This command has been disabled for this channel.
        halt 
      }
      if (%frozen [ $+ [ $nick ] ] == on) && ($max(m,$right($1,-1))) { 
        notice $nick You're frozen and can't use melee.
        halt 
      }
      if ($.ini(pvp.ini,$right($1,-1))) {
        if (!$.readini(pvp.ini,$right($1,-1),$nick)) {
          notice $nick You don't have this weapon.
          halt
        }
        if (!$.readini(login.ini,login,$nick)) { 
          notice $nick You have to login before you can use this command. ( $+ $s2(/msg $me $iif($.readini(Passes.ini,Passes,$nick),id,reg) pass) $+ ) (Don't use your RuneScape password) 
          halt 
        }
      }
      if ($.ini(equipment.ini,$replace($right($1,-1),surf,mudkip))) {
        if (!$.readini(equipment.ini,$replace($right($1,-1),surf,mudkip),$nick)) {
          notice $nick You have to unlock this weapon before you can use it.
          halt
        }
      }
      set -u25 %enddm [ $+ [ $chan ] ] 0
      if ($.readini(gwd.ini,#,$nick)) && (%turn [ $+ [ $chan ] ] == 1) {
        damage $nick %gwd [ $+ [ $chan ] ] $right($1,-1) #
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
  if ($4 == #iDM.Staff) { echo -a #iDM.Staff - %hp2 [ $+ [ #idm.staff ] ] - $1- }
  if ($.ini(pvp.ini,$3)) {
    if ($.readini(PvP.ini,$3,$1) < 1) { remini -n PvP.ini $1 $3 }
    elseif ($v1 >= 1) { updateini PvP.ini $3 $1 -1 }
  }
  if ($3 != dh) { 
    var %hit [ $+ [ $4 ] ] $hit($3,$1,$2,$4) 
  }
  elseif ($3 == dh) {
    if ($($+(%,hp,$player($1,$4),$4),2) < 10) { var %hit [ $+ [ $4 ] ] $hit(d_h9,$1,$2,$4) }
    else var %hit [ $+ [ $4 ] ] $hit(d_h10,$1,$2,$4)
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
    if (%hit [ $+ [ $4 ] ] >= 1) {
      set $+(%,frozen,$2) on 
      notice $2 You have been frozen and can't use melee!
    }
  }
  if ($gettok($healer($3),1,32)) {
    var %heal [ $+ [ $4 ] ] $r(1,$v1)
  }
  if (%heal [ $+ [ $4 ] ] == 1) {
    $iif($calc($floor($($+(%,hp,$player($1,$4),$4),2)) + $floor($calc($($+(%,hit,$4),2) / $gettok($healer($3),2,32)))) > 99,set $+(%,hp,$player($1,$4),$4) 99,inc $+(%,hp,$player($1,$4),$4) $floor($calc($($+(%,hit,$4),2) / $gettok($healer($3),2,32))))
  }
  if ($.readini(sitems.ini,belong,$1)) && ($r(1,100) <= 3) { 
    var %sitem.belong [ $+ [ $4 ] ] on
  }
  if ($poisoner($3)) { 
    var %pois.chance [ $+ [ $4 ] ] $r(1,$v1) 
    if (%pois.chance [ $+ [ $4 ] ] == 1) || ($.readini(sitems.ini,snake,$1)) && (!$($+(%,pois,$player($2,$4),$4),2)) { 
      if (%hit [ $+ [ $4 ] ] >= 1) {
        set $+(%,pois,$player($2,$4),$4) 6
      }
    }
  }
  if ($($+(%,pois,$player($2,$4),$4),2) >= 1) && ($($+(%,hp,$player($2,$4),$4),2) >= 1) {
    var %extra [ $+ [ $4 ] ] $iif($($+(%,hp,$player($2,$4),$4),2) < $($+(%,pois,$player($2,$4),$4),2),$($v1,2),$($+(%,pois,$player($2,$4),$4),2))
    dec $+(%,pois,$player($2,$4),$4)
    dec $+(%,hp,$player($2,$4),$4) %extra [ $+ [ $4 ] ]
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
  goto displaymsg
  :displaymsg
  if ($3 == vlong) { 
    msg $4 $logo(DM) $s1($1) slashes their Vesta's longsword at $s1($replace($2,$chr(58),$chr(32))) $+ $chr(44) hitting $s2(%hit [ $+ [ $4 ] ]) $+ $iif(%extra [ $+ [ $4 ] ], $chr(32) - 03 $+ $v1 $+  $+) $+ . HP $+($chr(91),$s2($iif($($+(%,hp,$player($2,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($2,$4),$4),2),$iif($($+(%,gwd,$4),2),gwd,hp))
  }
  if ($3 == vspear) {
    msg $4 $logo(DM) $s1($1) 12freezes $s1($replace($2,$chr(58),$chr(32))) using a Vesta's spear, and hits $s2(%hit [ $+ [ $chan ] ]) $+ $iif(%extra [ $+ [ $4 ] ], $chr(32) - 03 $+ $v1 $+  $+) $+ . HP $+($chr(91),$s2($iif($($+(%,hp,$player($2,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($2,$4),$4),2),$iif($($+(%,gwd,$4),2),gwd,hp))
  }
  if ($3 == statius) {
    msg $4 $logo(DM) $s1($1) critically injures $s1($replace($2,$chr(58),$chr(32))) with a Statius's warhammer, hitting $s2(%hit [ $+ [ $4 ] ]) $+ $iif(%extra [ $+ [ $4 ] ], $chr(32) - 03 $+ $v1 $+  $+) $+ . HP $+($chr(91),$s2($iif($($+(%,hp,$player($2,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($2,$4),$4),2),$iif($($+(%,gwd,$4),2),gwd,hp))
  }
  if ($3 == mjavelin) {
    msg $4 $logo(DM) $s1($1) throws a Morrigan's javelin at $s1($replace($2,$chr(58),$chr(32))) hitting $s2(%hit [ $+ [ $4 ] ]) $+ $iif(%extra [ $+ [ $4 ] ], $chr(32) - 03 $+ $v1 $+  $+) $+ . HP $+($chr(91),$s2($iif($($+(%,hp,$player($2,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($2,$4),$4),2),$iif($($+(%,gwd,$4),2),gwd,hp))
  }
  if ($3 == sgs) {
    msg $4 $logo(DM) $s1($1) crushes their godsword down on $s1($replace($2,$chr(58),$chr(32))) and hit $s2(%hit [ $+ [ $4 ] ]) $+ $iif(%extra [ $+ [ $4 ] ], $chr(32) - 03 $+ $v1 $+  $+) $+ . HP $s1($replace($2,$chr(58),$chr(32))) $+($chr(91),$s2($iif($($+(%,hp,$player($2,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($2,$4),$4),2),$iif($($+(%,gwd,$4),2),gwd,hp)) $iif(%heal [ $+ [ $4 ] ] == 1,- HP $s1($1) $+($chr(91),$s2($iif($($+(%,hp,$player($1,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($1,$4),$4),2)))
  }
  if ($3 == ags) {
    msg $4 $logo(DM) $s1($1) spins around and slashes at $s1($replace($2,$chr(58),$chr(32))) with an Armadyl godsword, speccing $s2(%hit [ $+ [ $4 ] ]) $+ $iif(%extra [ $+ [ $4 ] ], $chr(32) - 03 $+ $v1 $+  $+) $+ . HP $+($chr(91),$s2($iif($($+(%,hp,$player($2,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($2,$4),$4),2),$iif($($+(%,gwd,$4),2),gwd,hp))
  }
  if ($3 == zgs) {
    msg $4 $logo(DM) $s1($1) attempts to freeze $s1($replace($2,$chr(58),$chr(32))) $iif(%freeze [ $+ [ $4 ] ] == 1,and successfully 12FROZE them,but failed to) $+ $chr(44) hitting $s2(%hit [ $+ [ $4 ] ]) $+ $iif(%extra [ $+ [ $4 ] ], $chr(32) - 03 $+ $v1 $+  $+) $+ . HP $+($chr(91),$s2($iif($($+(%,hp,$player($2,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($2,$4),$4),2),$iif($($+(%,gwd,$4),2),gwd,hp))
  }
  if ($3 == bgs) {
    msg $4 $logo(DM) $s1($1) crushes their godsword down on $s1($replace($2,$chr(58),$chr(32))) and hit $s2(%hit [ $+ [ $4 ] ]) $+ $iif(%extra [ $+ [ $4 ] ], $chr(32) - 03 $+ $v1 $+  $+) $+ . HP $+($chr(91),$s2($iif($($+(%,hp,$player($2,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($2,$4),$4),2),$iif($($+(%,gwd,$4),2),gwd,hp))
  }
  if ($3 == guth) {
    msg $4 $logo(DM) $s1($1) $iif(%heal [ $+ [ $4 ] ] == 1,09HEALS on,fails to heal on) $s1($replace($2,$chr(58),$chr(32))) $iif(%heal [ $+ [ $4 ] ] == 1,and hits,but hits) $s2(%hit [ $+ [ $4 ] ]) $+ $iif(%extra [ $+ [ $4 ] ], $chr(32) - 03 $+ $v1 $+  $+) $+ . HP $s1($replace($2,$chr(58),$chr(32))) $+($chr(91),$s2($iif($($+(%,hp,$player($2,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($2,$4),$4),2),$iif($($+(%,gwd,$4),2),gwd,hp)) $iif(%heal [ $+ [ $4 ] ] == 1,- HP $s1($1) $+($chr(91),$s2($iif($($+(%,hp,$player($1,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($1,$4),$4),2)))
  }
  if ($3 == blood) {
    msg $4 $logo(DM) $s1($1) casts 05blood barrage on $s1($replace($2,$chr(58),$chr(32))) $iif(%hit [ $+ [ $4 ] ] == 0, and splashed $+ $iif(%extra [ $+ [ $4 ] ],$chr(32) 03 $+ $v1 $+) $+ .,hitting $s2(%hit [ $+ [ $4 ] ]) $+ $iif(%extra [ $+ [ $4 ] ], $chr(32) - 03 $+ $v1 $+  $+) $+ .) HP $s1($replace($2,$chr(58),$chr(32))) $+($chr(91),$s2($iif($($+(%,hp,$player($2,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($2,$4),$4),2),$iif($($+(%,gwd,$4),2),gwd,hp)) $iif(%heal [ $+ [ $4 ] ] == 1,- HP $s1($1) $+($chr(91),$s2($iif($($+(%,hp,$player($1,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($1,$4),$4),2)))
  }
  if ($3 == ice) {
    msg $4 $logo(DM) $s1($1) casts 12ice barrage on $s1($replace($2,$chr(58),$chr(32))) $iif(%freeze [ $+ [ $4 ] ] == 1,(12FROZEN)) $iif(%hit [ $+ [ $4 ] ] == 0, and splashed $+ $iif(%extra [ $+ [ $4 ] ],$chr(32) 03 $+ $v1 $+) $+ .,surrounding them in an ice cube $+ $chr(44) hitting $s2(%hit [ $+ [ $4 ] ]) $+ $iif(%extra [ $+ [ $4 ] ], $chr(32) - 03 $+ $v1 $+  $+) $+ .) HP $+($chr(91),$s2($iif($($+(%,hp,$player($2,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($2,$4),$4),2),$iif($($+(%,gwd,$4),2),gwd,hp))
  }
  if ($3 == smoke) {
    msg $4 $logo(DM) $s1($1) casts 14smoke barrage on $s1($replace($2,$chr(58),$chr(32))) $iif(%hit [ $+ [ $4 ] ] == 0, and splashed $+ $iif(%extra [ $+ [ $4 ] ],$chr(32) 03 $+ $v1 $+) $+ .,hitting $s2(%hit [ $+ [ $4 ] ]) $+ $iif(%extra [ $+ [ $4 ] ], $chr(32) - 03 $+ $v1 $+  $+) $+ .) HP $+($chr(91),$s2($iif($($+(%,hp,$player($2,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($2,$4),$4),2),$iif($($+(%,gwd,$4),2),gwd,hp))
  }
  if ($3 == cbow) {
    msg $4 $logo(DM) $s1($1) $iif(%cbowspec [ $+ [ $1 ] ],5UNLEASHES a dragon bolt special on,shoots a dragon bolt at) $s1($replace($2,$chr(58),$chr(32))) with a rune c'bow, hitting $s2(%hit [ $+ [ $4 ] ]) $+ $iif(%extra [ $+ [ $4 ] ], $chr(32) - 03 $+ $v1 $+  $+) $+ . HP $+($chr(91),$s2($iif($($+(%,hp,$player($2,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($2,$4),$4),2),$iif($($+(%,gwd,$4),2),gwd,hp))
    unset %cbowspec [ $+ [ $1 ] ]
  }
  if ($3 == dbow) {
    msg $4 $logo(DM) $s1($1) fires two dragon arrows towards $s1($replace($2,$chr(58),$chr(32))) $+ , speccing  $s2($gettok(%hit [ $+ [ $4 ] ],1,32)) - $s2($gettok(%hit [ $+ [ $4 ] ],2,32)) $+ $iif(%extra [ $+ [ $4 ] ], $chr(32) - 03 $+ $v1 $+  $+) $+ . HP $+($chr(91),$s2($iif($($+(%,hp,$player($2,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($2,$4),$4),2),$iif($($+(%,gwd,$4),2),gwd,hp))
  }
  if ($3 == whip) {
    msg $4 $logo(DM) $s1($1) slashes $s1($replace($2,$chr(58),$chr(32))) with their abyssal whip, hitting $s2(%hit [ $+ [ $4 ] ]) $+ $iif(%extra [ $+ [ $4 ] ], $chr(32) - 03 $+ $v1 $+  $+) $+ . HP $+($chr(91),$s2($iif($($+(%,hp,$player($2,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($2,$4),$4),2),$iif($($+(%,gwd,$4),2),gwd,hp))
  }
  if ($3 == dds) {
    msg $4 $logo(DM) $s1($1) stabs $s1($replace($2,$chr(58),$chr(32))) with a dragon dagger, hitting $s2($gettok(%hit [ $+ [ $4 ] ],1,32)) - $s2($gettok(%hit [ $+ [ $4 ] ],2,32)) $+ $iif(%extra [ $+ [ $4 ] ], $chr(32) - 03 $+ $v1 $+  $+) $+ . HP $+($chr(91),$s2($iif($($+(%,hp,$player($2,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($2,$4),$4),2),$iif($($+(%,gwd,$4),2),gwd,hp))
  }
  if ($3 == dclaws) {
    msg $4 $logo(DM) $s1($1) scratches $s1($replace($2,$chr(58),$chr(32))) with their dragon claws, hitting $s2($gettok(%hit [ $+ [ $4 ] ],1,32)) - $s2($gettok(%hit [ $+ [ $4 ] ],2,32)) - $s2($gettok(%hit [ $+ [ $4 ] ],3,32)) - $s2($gettok(%hit [ $+ [ $4 ] ],4,32)) $+ $iif(%extra [ $+ [ $4 ] ], $chr(32) - 03 $+ $v1 $+  $+) $+ . HP $+($chr(91),$s2($iif($($+(%,hp,$player($2,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($2,$4),$4),2),$iif($($+(%,gwd,$4),2),gwd,hp))
  }
  if ($3 == surf) {
    msg $4 $logo(DM) $s1($1) summons their mudkip, surfing at $s1($replace($2,$chr(58),$chr(32))) $+ , hitting $s2(%hit [ $+ [ $4 ] ]) $+ $iif(%extra [ $+ [ $4 ] ], $chr(32) - 03 $+ $v1 $+  $+) $+ . HP $+($chr(91),$s2($iif($($+(%,hp,$player($2,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($2,$4),$4),2),$iif($($+(%,gwd,$4),2),gwd,hp))
  }
  if ($3 == gmaul) {
    msg $4 $logo(DM) $s1($1) whacks $s1($replace($2,$chr(58),$chr(32))) with their granite maul, speccing $s2($gettok(%hit [ $+ [ $4 ] ],1,32)) - $s2($gettok(%hit [ $+ [ $4 ] ],2,32)) - $s2($gettok(%hit [ $+ [ $4 ] ],3,32)) $+ $iif(%extra [ $+ [ $4 ] ], $chr(32) - 03 $+ $v1 $+  $+) $+ . HP $+($chr(91),$s2($iif($($+(%,hp,$player($2,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($2,$4),$4),2),$iif($($+(%,gwd,$4),2),gwd,hp))
  }
  if ($3 == dh) {
    msg $4 $logo(DM) $s1($1) crushes $s1($replace($2,$chr(58),$chr(32))) with their great axe, and hit $s2(%hit [ $+ [ $4 ] ]) $+ $iif(%extra [ $+ [ $4 ] ], $chr(32) - 03 $+ $v1 $+  $+) $+ . HP $+($chr(91),$s2($iif($($+(%,hp,$player($2,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($2,$4),$4),2),$iif($($+(%,gwd,$4),2),gwd,hp))
  }
  if ($3 == dscim) {
    msg $4 $logo(DM) $s1($1) slices $s1($replace($2,$chr(58),$chr(32))) with their dragon scimitar, hitting $s2(%hit [ $+ [ $4 ] ]) $+ $iif(%extra [ $+ [ $4 ] ], $chr(32) - 03 $+ $v1 $+  $+) $+ . HP $+($chr(91),$s2($iif($($+(%,hp,$player($2,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($2,$4),$4),2),$iif($($+(%,gwd,$4),2),gwd,hp))
  }
  if ($3 == dlong) {
    msg $4 $logo(DM) $s1($1) stabs $s1($replace($2,$chr(58),$chr(32))) with a dragon longsword, hitting $s2(%hit [ $+ [ $4 ] ]) $+ $iif(%extra [ $+ [ $4 ] ], $chr(32) - 03 $+ $v1 $+  $+) $+ . HP $+($chr(91),$s2($iif($($+(%,hp,$player($2,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($2,$4),$4),2),$iif($($+(%,gwd,$4),2),gwd,hp))
  }
  if ($3 == dmace) {
    msg $4 $logo(DM) $s1($1) crushes $s1($replace($2,$chr(58),$chr(32))) with a dragon mace, hitting $s2(%hit [ $+ [ $4 ] ]) $+ $iif(%extra [ $+ [ $4 ] ], $chr(32) - 03 $+ $v1 $+  $+) $+ . HP $+($chr(91),$s2($iif($($+(%,hp,$player($2,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($2,$4),$4),2),$iif($($+(%,gwd,$4),2),gwd,hp))
  }
  if ($3 == dhally) {
    msg $4 $logo(DM) $s1($1) slashes $s1($replace($2,$chr(58),$chr(32))) with their dragon halberd, hitting $s2($gettok(%hit [ $+ [ $4 ] ],1,32)) - $s2($gettok(%hit [ $+ [ $4 ] ],2,32)) $+ $iif(%extra [ $+ [ $4 ] ], $chr(32) - 03 $+ $v1 $+  $+) $+ . HP $+($chr(91),$s2($iif($($+(%,hp,$player($2,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($2,$4),$4),2),$iif($($+(%,gwd,$4),2),gwd,hp))
  }
  if ($3 == onyx) {
    msg $4 $logo(DM) $s1($1) shoots $s1($replace($2,$chr(58),$chr(32))) with an onyx bolt, $iif(%heal [ $+ [ $4 ] ] == 1,09HEALING,hitting) a $s2(%hit [ $+ [ $4 ] ]) $+ $iif(%extra [ $+ [ $4 ] ], $chr(32) - 03 $+ $v1 $+  $+) $+ . HP $s1($replace($2,$chr(58),$chr(32))) $+($chr(91),$s2($iif($($+(%,hp,$player($2,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($2,$4),$4),2),$iif($($+(%,gwd,$4),2),gwd,hp)) $iif(%heal [ $+ [ $4 ] ] == 1,- HP $s1($1) $+($chr(91),$s2($iif($($+(%,hp,$player($1,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($1,$4),$4),2)))
  }
  if ($3 == gwd) {
    msg $4 $logo(GWD) $s1($replace($1,$chr(58),$chr(32))) brutally attacks $s1($2) $+ , hitting $s2(%hit [ $+ [ $4 ] ]) $+ . HP $+($chr(91),$s2($iif($($+(%,hp,$player($2,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($2,$4),$4),2),hp)
  }
  if ($specused($3)) { 
    dec $+(%,sp,$player($1,$4),$4) $calc($specused($3) /25) 
    notice $1 Specbar: $iif($($+(%,sp,$player($1,$4),$4),2) < 1,0,$gettok(25 50 75 100,$($+(%,sp,$player($1,$4),$4),2),32)) $+ $chr(37)
  }
  if (%sitem.belong [ $+ [ $4 ] ] == on) && ($($+(%,hp,$player($2,$4),$4),2) >= 1) {
    var %extra [ $+ [ $4 ] ] $iif($($+(%,hp,$player($2,$4),$4),2) < 10,$($v1,2),10)
    dec $+(%,hp,$player($2,$4),$4) %extra [ $+ [ $4 ] ]
    msg $4 $logo(DM) $s1($1) whips out their Bêlong Blade and deals $s2(%extra [ $+ [ $4 ] ]) extra damage. HP $+($chr(91),$s2($iif($($+(%,hp,$player($2,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($2,$4),$4),2),$iif($($+(%,gwd,$4),2),gwd,hp))
  }
  if ($.readini(sitems.ini,kh,$2)) && ($r(1,100) <= 3) && ($($+(%,hp,$player($2,$4),$4),2) >= 1) {
    inc $+(%,hp,$player($2,$4),$4) $calc($replace(%hit [ $+ [ $4 ] ],$chr(32),$chr(43)))
    msg $4 $logo(DM) KHobbits uses his KHonfound Ring to let $s1($2) avoid the attack. HP $+($chr(91),$s2($iif($($+(%,hp,$player($2,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($2,$4),$4),2),$iif($($+(%,gwd,$4),2),gwd,hp))
    set %turn [ $+ [ $4 ] ] $iif($player($1,$4) == 1,2,1)
  }
  if ($.readini(sitems.ini,allegra,$2)) && ($r(1,100) <= 3) && ($($+(%,hp,$player($2,$4),$4),2) >= 1) {
    var %allegra.heal [ $+ [ $4 ] ] $iif($($+(%,hp,$player($2,$4),$4),2) >= 89,$calc(99- $($+(%,hp,$player($2,$4),$4),2)),10)
    inc $+(%,hp,$player($2,$4),$4) %allegra.heal [ $+ [ $4 ] ]
    msg $4 $logo(DM) Allêgra gives $s1($2) Allergy pills, healing $s2(%allegra.heal [ $+ [ $4 ] ]) HP. HP $+($chr(91),$s2($iif($($+(%,hp,$player($2,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($2,$4),$4),2),$iif($($+(%,gwd,$4),2),gwd,hp))
  }
  if ($($+(%,hp,$player($2,$4),$4),2) < 1) { 
    if ($.readini(sitems.ini,beau,$2)) && ($r(1,100) <= 6) { 
      set $+(%,hp,$player($2,$4),$4) 1
      msg $4 $logo(DM) $s1($2) $+ 's Bêaumerang brings them back to life, barely. HP $+($chr(91),$s2($iif($($+(%,hp,$player($2,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($2,$4),$4),2),$iif($($+(%,gwd,$4),2),gwd,hp))
      set %turn [ $+ [ $4 ] ] $iif($player($1,$4) == 1,2,1)
      halt
    }
    if ($istok($bosses,$2,32)) {
      gwdloot $4 $1 $2
      halt
    }
    if ($.readini(gwd.ini,$4,$2)) {
      gwdko $4 $2
      halt
    }
    dead $4 $2 $1
    halt 
  }
  set %turn [ $+ [ $4 ] ] $iif($player($1,$4) == 1,2,1)
}
alias gwdloot {
  updateini wins.ini $2 +1
  var %loot A Godsword..
  msg $1 $logo(GWD) $s1($2) has defeated $s1($replace($3,$chr(58),$chr(32))) and recieved $+(03[,07 $+ %loot,,$chr(44),07Big bones,,03]) $+ .
  cancel $1
}
alias bosses {
  return Commander:Zilyana Kree'arra General:Graardor K'ril:Tsutsaroth
}
alias gwdko {
  remini gwd.ini $1 $2
  msg $1 $logo(GWD) $s1($2) has died.
  cancel $1
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
  if ($accuracy($1,$4) == 0) {
    var %acc $r(1,100)
  }
  elseif ($accuracy($1,$4) == -1) {
    var %acc $r(1,$r(75,90))
  }
  elseif ($accuracy($1,$4) == 1) {
    var %acc $r($r(10,25),100)
  }
  var %atk $calc($iif($.readini(Equipment.ini,Firecape,$2),5,0) + $iif($.readini(Equipment.ini,bgloves,$2),3,0))
  var %def $iif($.readini(Equipment.ini,elshield,$3),$calc($r(85,99) / 100),1)
  var %ratk $calc($iif($.readini(Equipment.ini,void,$2),5,0) + $iif($.readini(Equipment.ini,accumulator,$2),5,0))
  var %matk $calc($iif($.readini(Equipment.ini,void-mage,$2),5,0) + $iif($.readini(Equipment.ini,mbook,$2),5,0))
  goto $1
  :whip
  if (%acc isnum 1-4) return 0
  if (%acc isnum 5-25) return $r(0,25)
  if (%acc isnum 26-100) return $floor($calc($r(11,$calc($gettok($gettok($max(m,$1),1,32),1,45) + $(,%atk))) * $(,%def)))
  :dds
  if (%acc isnum 1-4) return 0 0
  if (%acc isnum 5-30) return $r(0,20) $r(0,20)
  if (%acc isnum 31-100) return $floor($calc($r(11,$calc($gettok($gettok($max(m,$1),1,32),1,45) + $(,%atk))) * $(,%def))) $floor($calc($r(11,$calc($gettok($gettok($max(m,$1),1,32),1,45) + $(,%atk))) * $(,%def)))
  :ags
  if (%acc isnum 1-2) return 0
  if (%acc isnum 3-20) return $r(1,20)
  if (%acc isnum 21-100) return $floor($calc($r(21,$calc($gettok($gettok($max(m,$1),1,32),1,45) + $(,%atk))) * $(,%def)))
  :cbow
  if (%acc isnum 1-15) return $r(0,10)
  if (%acc isnum 16-30) return $r(11,20)
  if (%acc isnum 31-100) {
    if (%acc isnum 98-100) && ($.readini(Equipment.ini,void,$2) || $.readini(Equipment.ini,accumulator,$2)) { set %cbowspec [ $+ [ $2 ] ] 1 | return $r(60,69) | halt }
    return $floor($calc($r(21,$calc($gettok($gettok($max(r,$1),1,32),1,45) + $(,%ratk))) * $(,%def)))
  }
  :dbow
  if (%acc isnum 1-8) return 8 8
  if (%acc isnum 9-49) return $r(9,20) $r(9,20)
  if (%acc isnum 50-100) return $floor($calc($r(20,$calc($gettok($gettok($max(r,$1),1,32),1,45) + $(,%ratk))) * $(,%def))) $floor($calc($r(20,$calc($gettok($gettok($max(r,$1),1,32),1,45) + $(,%ratk))) * $(,%def)))
  :bgs
  if (%acc isnum 1-5) return 0
  if (%acc isnum 6-35) return $r(1,35)
  if (%acc isnum 36-100) return $floor($calc($r(36,$calc($gettok($gettok($max(m,$1),1,32),1,45) + $(,%atk))) * $(,%def)))
  :sgs
  if (%acc isnum 1-6) return 0
  if (%acc isnum 7-23) return $r(1,20)
  if (%acc isnum 24-100) return $floor($calc($r(16,$calc($gettok($gettok($max(m,$1),1,32),1,45) + $(,%atk))) * $(,%def)))
  :gmaul
  if (%acc isnum 1-3) return $r(0,8) $r(0,8) $r(0,8)
  if (%acc isnum 4-25) return $r(1,15) $r(1,15) $r(1,15)
  if (%acc isnum 26-100) return $floor($calc($r(13,$calc($gettok($gettok($max(m,$1),1,32),1,45) + $ceil($calc($(,%atk) / 2)))) * $(,%def))) $floor($calc($r(13,$calc($gettok($gettok($max(m,$1),1,32),1,45) + $ceil($calc($(,%atk) / 2)))) * $(,%def))) $floor($calc($r(13,$calc($gettok($gettok($max(m,$1),1,32),1,45) + $ceil($calc($(,%atk) / 2)))) * $(,%def)))
  :guth
  if (%acc isnum 1-5) return 0
  if (%acc isnum 6-13) return $r(1,20)
  if (%acc isnum 14-100) return $floor($calc($r(11,$calc($gettok($gettok($max(m,$1),1,32),1,45) + $(,%atk))) * $(,%def)))
  :ice
  if (%acc isnum 1-3) return 0
  if (%acc isnum 4-30) return $r(1,15)
  if (%acc isnum 31-100) return $r(16,$calc($gettok($gettok($max(ma,$1),1,32),1,45) + $(,%matk)))
  :zgs
  if (%acc isnum 1-5) return 0
  if (%acc isnum 6-30) return $r(1,22)
  if (%acc isnum 31-100) return $floor($calc($r(23,$calc($gettok($gettok($max(m,$1),1,32),1,45) + $(,%atk))) * $(,%def)))
  :blood
  if (%acc isnum 1-3) return 0
  if (%acc isnum 4-25) return $r(1,15)
  if (%acc isnum 26-100) return $r(16,$calc($gettok($gettok($max(ma,$1),1,32),1,45) + $(,%matk)))
  :smoke
  if (%acc isnum 1-2) return $r(0,5)
  if (%acc isnum 3-26) return $r(1,15)
  if (%acc isnum 27-100) return $r(16,$calc($gettok($gettok($max(ma,$1),1,32),1,45) + $(,%matk)))
  :surf
  if (%acc isnum 1-20) return $r(0,10)
  if (%acc isnum 21-30) return $r(11,15)
  if (%acc isnum 31-100) return $r(16,$gettok($gettok($max(m,$1),1,32),1,45))
  :dclaws
  var %dclaws $r(10,24) $floor($calc($r(24,$calc($gettok($gettok($max(m,$1),1,32),1,45) + $(,%atk))) * $(,%def)))
  var %dclaws2 $ceil($calc($gettok(%dclaws,1,32) / 2)) $ceil($calc($gettok(%dclaws,2,32) / 2))
  var %dclaws3 $ceil($calc($gettok(%dclaws2,1,32) / 2)) $ceil($calc($gettok(%dclaws2,2,32) / 2))
  var %dclaws4 $ceil($calc($gettok(%dclaws3,1,32) / 2)) $ceil($calc($gettok(%dclaws3,2,32) / 2))
  if (%acc isnum 1-7) return 0 0 $r(0,$r(15,20)) $r(0,$r(15,20))
  if (%acc isnum 8-50) return $gettok(%dclaws,1,32) $gettok(%dclaws2,1,32) $gettok(%dclaws3,1,32) $gettok(%dclaws4,1,32)
  if (%acc isnum 51-100) return $gettok(%dclaws,2,32) $gettok(%dclaws2,2,32) $gettok(%dclaws3,2,32) $gettok(%dclaws4,2,32)
  :dmace
  if (%acc isnum 1-4) return 0
  if (%acc isnum 5-60) return $r(5,25)
  if (%acc isnum 61-100) return $floor($calc($r(26,$calc($gettok($gettok($max(m,$1),1,32),1,45) + $(,%atk))) * $(,%def)))
  :dscim
  if (%acc isnum 1-4) return 0
  if (%acc isnum 5-30) return $r(5,25)
  if (%acc isnum 31-100) return $floor($calc($r(26,$calc($gettok($gettok($max(m,$1),1,32),1,45) + $(,%atk))) * $(,%def)))
  :dlong
  if (%acc isnum 1-4) return 0
  if (%acc isnum 5-30) return $r(5,25)
  if (%acc isnum 31-100) return $floor($calc($r(26,$calc($gettok($gettok($max(m,$1),1,32),1,45) + $(,%atk))) * $(,%def)))
  :dhally
  if (%acc isnum 1-5) return 0 0
  if (%acc isnum 6-49) return $r(5,20) $r(5,20)
  if (%acc isnum 50-100) return $floor($calc($r(20,$calc($gettok($gettok($max(m,$1),1,32),1,45) + $(,%atk))) * $(,%def))) $floor($calc($r(20,$calc($gettok($gettok($max(m,$1),1,32),1,45) + $(,%atk))) * $(,%def)))
  :d_h9
  return $floor($calc($r(1,$calc($gettok($gettok($gettok($max(m,dh),1,32),1,45),2,47) + $(,%atk))) * $(,%def)))
  :d_h10
  return $floor($calc($r(1,$calc($gettok($gettok($gettok($max(m,dh),1,32),1,45),1,47) + $(,%atk))) * $(,%def)))
  :vlong
  if (%acc isnum 1-2) return $r(0,10)
  if (%acc isnum 3-25) return $r(10,35)
  if (%acc isnum 26-100) return $floor($calc($r(30,$calc($gettok($gettok($max(m,$1),1,32),1,45) + $(,%atk)))))
  :statius
  if (%acc isnum 1-4) return $r(0,15)
  if (%acc isnum 5-25) return $r(15,35)
  if (%acc isnum 26-100) return $floor($calc($r(30,$calc($gettok($gettok($max(m,$1),1,32),1,45) + $(,%atk))) * $(,%def)))
  :vspear
  if (%acc isnum 1-3) return $r(0,10)
  if (%acc isnum 4-20) return $r(11,35)
  if (%acc isnum 21-100) return $floor($calc($r(35,$calc($gettok($gettok($max(m,$1),1,32),1,45) + $(,%atk))) * $(,%def)))
  :mjavelin
  if (%acc isnum 1-4) return $r(0,7)
  if (%acc isnum 5-38) return $r(8,25)
  if (%acc isnum 39-100) return $floor($calc($r(25,$calc($gettok($gettok($max(r,$1),1,32),1,45) + $(,%ratk))) * $(,%def)))
  :onyx
  if (%acc isnum 1-5) return $r(0,10)
  if (%acc isnum 6-33) return $r(10,30)
  if (%acc isnum 34-100) return $floor($calc($r(25,$calc($gettok($gettok($max(r,$1),1,32),1,45) + $(,%ratk))) * $(,%def)))
  :gwd
  return $r(0,50)
}
