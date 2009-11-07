;#fix try and remove all $.ini
;#fix alias the security/errors on these commands (or maybe try and regex them together?)

on $*:TEXT:/^[!@.]delmem .*/Si:*: {
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
on $*:TEXT:/^[!@.]addmem .*/Si:*: {
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
on $*:TEXT:/^[!@.]joinclan .*/Si:*: {
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
on $*:TEXT:/^[!@.]startclan .*/Si:*: {
  tokenize 32 $remove($1-,$chr(36),$chr(37))
  if (# == #idm || # == #idm.Staff) && ($me != iDM) { halt }
  if (!$islogged($nick,$address,3)) {
    notice $nick You have to login before you can use this command. (To check your auth type: /msg $me id)
    halt
  }
  if (!$2) { notice $nick $logo(ERROR) Type !startclan clan name. | halt }
  if ($.ini(Clan.ini,$remove($2,$chr(36),$chr(37)),0)) { notice $nick $logo(ERROR) Clan name $qt($remove($2,$chr(36),$chr(37))) already taken. | halt }
  if ($getclanname($nick)) { notice $nick You're already in a clan ( $+ $v1 $+ ). | halt }
  createclan $remove($2,$chr(36),$chr(37)) $nick
  notice $nick $logo(CLAN) Your clan $qt($remove($2,$chr(36),$chr(37))) has been created. To add users to it, type !addmem newmember.
}
on $*:TEXT:/^[!@.]leave$/Si:*: {
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
on $*:TEXT:/^[!@.]share (on|off)/Si:*: {
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
  if (%clan) {
    $iif($left($1,1) == @,msg #,notice $nick)  $logo(CLAN) $claninfo(%clan) $clanstats(%clan)
    halt
  }
  notice $nick $logo(ERROR) %nick is not in a clan. | halt
}

alias claninfo {
  var $ci,%tc = 0
  var %sql = SELECT * FROM `clan` WHERE c1 = $db.safe($1)
  var %result = $db.query(%sql)
  while ($db.query_row_data(%result,c2)) {
    var %ci = %ci $v1
    inc %tc
  }
  db.query_end %result
  return There $iif(%tc > 1,are,is) $s1(%tc) member $+ $iif(%tc > 1,s) of the clan $s2($1) $+ . $iif(%tc < 10,Members: %ci) (Lootshare: $iif($db.get(clantracker,share,$1),$s1(on),$s2(off)) $+ )
}

alias clanstats {
  return $s1(Wins) $+ : $iif($db.get(clantracker,wins,$1),$s2($v1),$s2(0)) $s1(Losses) $+ : $iif($db.get(clantracker,losses,$1),$s2($v1),$s2(0)) $s1(Money) $+ : $iif($db.get(clantracker,money,$1),$s2($price($v1)),$s2($price(0)))
}

; ============ 'Clan' Table Layout ============
; +--------------+--------------+--------------+
; |      c1      |      c2      |      c3      |
; +--------------+--------------+--------------+
; |  <clanname>  |  <nick>      |  owner       |
; |  <clanname>  |  <nick>      |  member      |
; |  <clanname>  |  <nick>      |  member      |
; +--------------+--------------+--------------+
;
; ======================== 'Clantracker' Table Layout ========================
; +--------------+--------------+--------------+---------------+--------------+
; |  user        |   wins       |   losses     |   money       |   share      |
; +--------------+--------------+--------------+---------------+--------------+
; | <clanname>   |  <num>       |  <num>       |  <num>        |  1           |
; | <clanname>   |  <num>       |  <num>       |  <num>        |  0           |
; | <clanname>   |  <num>       |  <num>       |  <num>        |  1           |
; +--------------+--------------+--------------+---------------+--------------+

alias createclan {
  ; $1 = Clanname
  ; $2 = Ownername
  if ($2) {
    writeini clan.ini $1 $2 owner
  }
}

alias deleteclan {
  ; $1 = Clanname
  if ($1) {
    var %sql = DELETE FROM clan WHERE c1 = $db.safe($1)
    db.exec %sql
  }
}

alias addclanmember {
  ; $1 = Clanname
  ; $2 = Membername
  if ($2) {
    writeini clan.ini $1 $2 member
  }
}

alias delclanmember {
  ; $1 = Membername
  if ($1) {
    var %sql = DELETE FROM clan WHERE c2 = $db.safe($1)
    db.exec %sql
  }
}

alias getclanname {
  ; $1 = Membername
  if ($1) {
    var %sql = SELECT * FROM `clan` WHERE c2 = $db.safe($1)
    return $db.select(%sql, c1)
  }
}

alias clanmembers {
  ; $1 = Clanname
  if ($1) {
    var %members = $.ini(Clan.ini,$1,0)
    return %members
  }
}

alias isclanowner {
  ; $1 = Membername
  ; $2 = [optional] Clanname
  if ($2) {
    var %sql = SELECT * FROM `clan` WHERE c2 = $db.safe($1) AND c1 = $db.safe($2)
    if ($db.select(%sql, c3) == owner) {
      return 1
    }
    return 0
  }
  elseif ($1) {
    var %sql = SELECT * FROM `clan` WHERE c2 = $db.safe($1)
    if ($db.select(%sql, c3) == owner) {
      return 1
    }
    return 0
  }
}
