;#fix alias the security/errors on these commands (or maybe try and regex them together?)

on $*:TEXT:/^[!@.]delmem(ber)?.*/Si:*: {
  tokenize 32 $remove($1-,$chr(36),$chr(37))
  if (# == #idm || # == #idm.Staff) && ($me != iDM) { halt }
  if (!$islogged($nick,$address,3)) {
    notice $nick You have to login before you can use this command. (To check your auth type: /msg $me id)
    halt
  }
  var %clanname = $getclanname($nick)
  if (!%clanname) { notice $nick You need to make a clan before you can kick any members. !startclan name of clan. | halt }
  if (!$2) { notice $nick $logo(ERROR) Type !delmem member. | halt }
  if ($2 == $nick) { notice $nick $logo(ERROR) You can't kick yourself silly! Type: !leave to part your clan / cancel it. | halt }
  if ($db.get(user,money,$2) < 1) { notice $nick $logo(ERROR) $remove($2,$chr(36),$chr(37)) doesn't seem to have ever used iDM. | halt }
  if ($isclanowner($nick) == 0) { notice $nick You have to be the clan owner to do this. | halt }
  if (%clanname != $getclanname($2)) { notice $nick $logo(ERROR) $s1($2) isn't in your clan. | halt }
  notice $nick $logo(CLANS) $s1($2) has been kicked from your clan.
  $iif($address($2,2),notice $2,ms send $2) You have been kicked from your iDM clan by $nick $+ .
  delclanmember $2
}

on $*:TEXT:/^[!@.]addmem(ber)?.*/Si:*: {
  tokenize 32 $remove($1-,$chr(36),$chr(37))
  if (# == #idm || # == #idm.Staff) && ($me != iDM) { halt }
  if (!$islogged($nick,$address,3)) {
    notice $nick You have to login before you can use this command. (To check your auth type: /msg $me id)
    halt
  }
  var %clanname = $getclanname($nick)
  if (!%clanname) { notice $nick You need to make a clan before you can start adding members. !startclan name of clan. | halt }
  if (!$2) { notice $nick $logo(ERROR) Type !addclan new member. | halt }
  if ($db.get(user,money,$2) < 1) { notice $nick $logo(ERROR) $remove($2,$chr(36),$chr(37)) doesn't seem to have ever used iDM. | halt }
  if ($getclanname($2)) { notice $nick $logo(ERROR) $remove($2,$chr(36),$chr(37)) is already part of a clan ( $+ $v1 $+ ). | halt }
  if ($isclanowner($nick) == 0) { notice $nick You have to be the clan owner to do this. | halt }
  set %invite [ $+ [ $2 ] ] %clanname
  notice $nick $logo(CLAN) $2 has been sent a request to join $s2(%clanname) $+ .
  $iif($address($2,2),notice $2,ms send $2) You've been asked to join $s1(%clanname) $+ $chr(44) requested by $nick $+ . Type !joinclan %clanname to accept.
}

on $*:TEXT:/^[!@.]joinclan.*/Si:*: {
  tokenize 32 $remove($1-,$chr(36),$chr(37))
  if (# == #idm || # == #idm.Staff) && ($me != iDM) { halt }
  if (!$islogged($nick,$address,3)) {
    notice $nick You have to login before you can use this command. (To check your auth type: /msg $me id)
    halt
  }
  if ($getclanname($nick)) { notice $nick You're already in a clan ( $+ $v1 $+ ). | halt }
  if (!$2) { notice $nick $logo(ERROR) Type !joinclan clan to join. | halt }
  if (%invite [ $+ [ $nick ] ] != $2 && $2 != Team-B) { notice $nick $logo(ERROR) You don't have an invite to join this clan. | halt }
  addclanmember $2 $nick
  notice $nick $logo(CLAN) You've joined $s2($2) $+ .
  unset %invite [ $+ [ $nick ] ]
}

on $*:TEXT:/^[!@.](start|create)clan.*/Si:*: {
  tokenize 32 $remove($1-,$chr(36),$chr(37))
  if (# == #idm || # == #idm.Staff) && ($me != iDM) { halt }
  if (!$islogged($nick,$address,3)) {
    notice $nick You have to login before you can use this command. (To check your auth type: /msg $me id)
    halt
  }
  if (!$2) { notice $nick $logo(ERROR) Type !startclan clan name. | halt }
  if ($clanmembers($2)) { notice $nick $logo(ERROR) Clan name $qt($remove($2,$chr(36),$chr(37))) already taken. | halt }
  if ($getclanname($nick)) { notice $nick You're already in a clan ( $+ $v1 $+ ). | halt }
  createclan $remove($2,$chr(36),$chr(37)) $nick
  notice $nick $logo(CLAN) Your clan $qt($remove($2,$chr(36),$chr(37))) has been created. To add users to it, type !addmem newmember.
}

on $*:TEXT:/^[!@.]leaveclan/Si:*: {
  tokenize 32 $remove($1-,$chr(36),$chr(37))
  if (# == #idm || # == #idm.Staff) && ($me != iDM) { halt }
  if (!$islogged($nick,$address,3)) {
    notice $nick You have to login before you can use this command. (To check your auth type: /msg $me id)
    halt
  }
  var %clanname = $getclanname($nick)
  if (!%clanname) { notice $nick You're not in a clan. !startclan name of clan. | halt }
  if ($isclanowner($nick) == 1) { notice $nick $logo(CLAN) Your clan has been deleted. | deleteclan %clanname | halt }
  notice $nick $logo(CLAN) You've left your clan $s2(%clanname) $+ .
  delclanmember $nick
}

on $*:TEXT:/^[!@.](loot|clan|coin|drop)?share (on|off)/Si:*: {
  tokenize 32 $remove($1-,$chr(36),$chr(37))
  if (# == #idm || # == #idm.Staff) && ($me != iDM) { halt }
  if (!$islogged($nick,$address,3)) {
    notice $nick You have to login before you can use this command. (To check your auth type: /msg $me id)
    halt
  }
  var %clanname = $getclanname($nick)
  if (!%clanname) {  notice $nick You're not in a clan. !startclan name of clan. | halt }
  if ($isclanowner($nick) == 0) { notice $nick You're not the owner of $s2(%clanname) $+ . | halt }
  if ($2 == on) { notice $nick $logo(CLAN) The drop share option for your clan has been enabled.
    db.set clantracker share %clanname 1
  }
  if ($2 == off) { notice $nick $logo(CLAN) The drop share option for your clan has been disabled.
    db.set clantracker share %clanname 0
  }
}

on $*:TEXT:/^[!@.]dmclan/Si:#: {
  if (# == #idm || # == #idm.Staff) && ($me != iDM) { halt }
  if (!$2) { var %nick = $nick }
  else { var %nick = $2 }
  var %clan = $getclanname(%nick)
  if ((!%clan) && ($clanmembers($2))) { var %clan = $2 }
  if (%clan) {
    $iif($left($1,1) == @,msg #,notice $nick) $logo(CLAN) $claninfo(%clan) $clanstats(%clan) $s1(Profile) $+ : $s2(http://idm-bot.com/c/ $+ $webstrip(%clan,1)) 
    halt
  }
  notice $nick $logo(ERROR) %nick is not in a clan and there is no clan named %nick $+ .
}

alias claninfo {
  var %ci $clanmembers($1)
  var %tc $numtok(%ci,32)
  return There $iif(%tc > 1,are,is) $s1(%tc) member $+ $iif(%tc > 1,s) of the clan $s2($1) $+ . $iif(%tc < 10,Members: %ci) (Lootshare: $iif($db.get(clantracker,share,$1),$s1(on),$s2(off)) $+ )
}

alias clanstats {
  var %wins $db.get(clantracker,wins,$1)
  var %losses $db.get(clantracker,losses,$1)
  var %ratio $s1(W/L Ratio) $+ :  $s2($round($calc(%wins / %losses),2)) ( $+ $s2($+($round($calc(%wins / $calc(%wins + %losses) *100),1),$chr(37)))) $+ )
  return $s1(Wins) $+ : $iif(%wins,$s2($v1),$s2(0)) $s1(Losses) $+ : $iif(%losses,$s2($v1),$s2(0)) %ratio $s1(Money) $+ : $iif($db.get(clantracker,money,$1),$s2($price($v1)),$s2($price(0)))
}

alias createclan {
  ; $1 = Clanname
  ; $2 = Ownername
  if ($2) {
    db.set clantracker owner $webstrip($1) $2
    addclanmember $webstrip($1) $2
  }
}

alias deleteclan {
  ; $1 = Clanname
  if ($1) {
    db.remove clantracker $1
    db.clear user clan $1
  }
}

alias addclanmember {
  ; $1 = Clanname
  ; $2 = Membername
  if ($2) db.set user clan $2 $1
}

alias delclanmember {
  ; $1 = Membername
  if ($1) db.set user clan $1 0
}

alias getclanname {
  ; $1 = Membername
  if ($1) return $db.get(user,clan,$1)
}

alias clanmembers {
  ; $1 = Clanname
  if ($1) {
    var $members
    var %sql = SELECT * FROM `user` WHERE clan = $db.safe($1)
    var %result = $db.query(%sql)
    while ($db.query_row_data(%result,user)) {
      var %members = %members $v1
    }
    db.query_end %result
    return %members
  }
}

alias isclanowner {
  ; $1 = Membername
  ; $2 = [optional] Clanname
  if ($2) {
    if ($db.get(clantracker,owner,$2) == $1) return 1
    return 0
  }
  elseif ($1) {
    if ($db.get(user,clan,$1)) {
      if ($db.get(clantracker,owner,$v1) == $1) return 1
    }
    return 0
  }
}
