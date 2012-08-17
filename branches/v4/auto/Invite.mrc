ON *:INVITE:#: {
  if ($me == iDM && !$isbanned($nick)) {
    db.hash >blist blist $lower($chan) user
    if ($update) notice $nick $logo(ERROR) iDM is currently disabled, please try again shortly.
    elseif ($regex($chan,/^#[a-zA-Z0-9_\-\.]*$/) == 0 || $len($chan) <= 1) {
      notice $nick $logo(ERROR) Sorry but we do not support your channel at this time.
      msgsafe $staffchan $logo(ERROR) Invite FAILED. The channel $s1($3) has an invalid character in their channel name.
    }
    elseif ($hget(>blist,reason)) notice $2 $logo(BANNED) Channel has been blacklisted. Reason: $hget(>blist,reason) By: $hget(>blist,who)
    else invitebot $chan $nick
  }
}  

alias invitebot {
  if ($hget(>invite,$2)) notice $2 $logo(ERROR) You have invited iDM less then 60 seconds ago please wait another $hget(>invite,$2).unset seconds.
  elseif ($hget(>invite,$1)) notice $2 $logo(ERROR) You have invited iDM less then 60 seconds ago please wait another $hget(>invite,$1).unset seconds.
  else {
    sbnc joinbot $1 $2
    hadd -mu60 >invite $1 1
    hadd -mu60 >invite $2 1
  }
}

CTCP *:*join*:?: {
  if ($nick == iDM) {
    if ($me !ison $2) {
      hadd -mu60 $+(>,$2) invite 1
      hadd -mu60 $+(>,$2) nick $3
      .list $2
      join $2
    }
  }
}

raw 323:*:{ /window -h "Channels list" }

; Checks to see if it's unable to join a channel
; Linked Channel
raw 470:*: {
  if ($inv($3,invite) == 1) {
    notice $inv($3,nick) $logo(ERROR) Your channel currently links to $s1(17) $+. If you wish to have me in your channel please remove the link and re-invite me.
    msgsafe $staffchan $logo(ERROR) Invite FAILED. The channel $s1($3) has linked up with $s(17). Parting...
    if ($me ison $17) part $17 I was linked into here from $3 $+ . If this wasn't a mistake please reinvite me to this channel.
    db.set blist who user $3 AUTO
    db.set blist reason user $3 Channel $3 linked to $17
    hfree $+(>,$3)
  }
}

; Limited channel
raw 471:*: { 
  if ($inv($2,invite) == 1) {
    notice $inv($2,nick) $logo(ERROR) Your channel is currently at it's maximum users. Please increase the limit or remove someone and re-invite me.
    msgsafe $staffchan $logo(ERROR) Invite FAILED. The channel $s1($2) is at the maximum of users.
    hfree $+(>,$2)
  }
}

; Invite only
raw 473:*: { 
  if ($inv($2,invite) == 1) {
    notice $inv($2,nick) $logo(ERROR) You channel is currently invite only. Please remove allow invites and re-invite me.
    msgsafe $staffchan $logo(ERROR) Invite FAILED. The channel $s1($2) is set to invite only.
    hfree $+(>,$2)
  }
}

; Banned
raw 474:*: { 
  if ($inv($2,invite) == 1) {
    notice $inv($2,nick) $logo(ERROR) I am currently banned from your channel. Please remove my ban and re-invite me.
    msgsafe $staffchan $logo(ERROR) Invite FAILED. The channel $s1($2) has me banned.
    hfree $+(>,$2)
  }
}

; Key
raw 475:*: { 
  if ($inv($2,invite) == 1) {
    notice $inv($2,nick) $logo(ERROR) You currently have a key on the channel and I am unable to join. Please remove the key and re-invite me.
    msgsafe $staffchan $logo(ERROR) Invite FAILED. The channel $s1($2) currently has a key set.
    hfree $+(>,$2)
  }
}

ON *:JOIN:#: {
  if ($nick == $me && $inv($chan,invite) == 1) {
    who $chan
    if (u isincs $chan($chan).mode) part $chan Please remove +u from the channel modes and re-invite me.
    else .timer 1 1 /limit5 $chan
  }
  else {
    if ($nick != $me) {
      if ($nick($chan,0) < 5 && !$no-part($chan)) {
        cancel $chan
        part $chan The minimum amount of users for me to stay in this channel is 5. Current count: $nick($chan,0)
      }
      else {
        if ($chan == $supportchan) {
          db.user.hash >userinfo user $nick
          msg $supportchan $logo(Acc-Info) User: $s2($nick) Money: $s2($iif($hget(>userinfo,money),$price($v1),0)) W/L: $s2($iif($hget(>userinfo,wins),$bytes($v1,db),0)) $+ / $+ $s2($iif($hget(>userinfo,losses),$bytes($v1,db),0)) Excluded?: $iif($hget(>userinfo,exclude),3YES,4NO) Suspended?: $iif($hget(>userinfo,banned),4YES,3NO)
          if ($hget(>userinfo,banned)) {
            db.user.hash >checkban ilist $nick
            msg $supportchan $logo(BANNED) $s2($hget(>checkban,who)) suspended $s2($nick) at $s2($hget(>checkban,time)) for $s2($hget(>checkban,reason))
          }
        }
        showtitle $nick $chan
        if ($hget(#)) && ($hget(#,p2)) { notice $nick $status(#) }
        if ($hget(#,gwd.time)) { notice $nick $logo(GWD-STATUS) $status($chan) }
      } 
    }
  }
}

alias limit5 { 
  if ($me ison $1) {   
    if (!$no-part($1) && $nick($1,0) < 5) {
      msgsafe $staffchan $logo(ERROR) Invite FAILED. The channel $s1($1) does not have 5+ users.
      part $1 The minimum amount of users for me to stay in this channel is 5.
    }
    else {
      msgsafe $1 $logo(INVITE) Hello! I am $s1($me) $+ , a RuneScape DMing bot. I was invited by $s1($inv($1,nick)) $+ . Our main channel is $s1(#iDM) $+ . $&
        You can get support by visiting $s1(http://idm-bot.com/help) or visiting $s1(#iDM.Support) $+ . Current news: $botnews
      msgsafe $staffchan $logo(INVITE) $s1($inv($1,nick)) invited me into $s2($1)
    }
    hfree $+(>,$1)
  }
}

ON $*:TEXT:/^[!@.]title$/Si:#: {
  if (!$isbanned($nick)) {
    showtitle-short $nick $chan
  }
}

alias showtitle {
  if (# == #iDM || # == $staffchan) && ($me != iDM) { halt } 
  if ($db.user.get(user,banned,$nick) == 0) {
    db.hash >staff admins $lower($address($1,3)) address
    var %dmrank $ranks(money,$1)
    if ($hget(>staff,rank) == 4) {
      msgsafe $2 $logo(ADMIN) $s1($iif($hget(>staff,title),$v1,Administrator)) - $s2($1) has entered the channel.
    }
    elseif ($hget(>staff,rank) == 3) {
      msgsafe $2 $logo(SUPPORT) $s1($iif($hget(>staff,title),$v1,Support Staff)) - $s2($1) has entered the channel.
    }
    elseif ($hget(>staff,rank) == 2) {
      msgsafe $2 $logo(VIP) $s1($iif($hget(>staff,title),$v1,VIP)) - $s2($1) has entered the channel. $iif(%dmrank <= 12, $+($chr(91),Rank: %dmrank,$chr(93)))
    }
    elseif ($hget(>staff,rank) == 1) {
      msgsafe $2 $logo(VIP) $s1($iif($hget(>staff,title),$v1,VIP)) - $s2($1) has entered the channel. $iif(%dmrank <= 12, $+($chr(91),Rank: %dmrank,$chr(93)))
    }
    elseif ((%dmrank <= 12)) {
      msgsafe $2 $logo(TOP12) $s2($1) is ranked $s1($ord(%dmrank)) in the top 12.
    }
  }
}

alias showtitle-short {   
  if (# == #iDM || # == $staffchan) && ($me != iDM) { halt }
  if ($db.user.get(user,banned,$nick) == 0) {
    var %dmrank $ranks(money,$1)
    db.hash >staff admins $lower($address($1,3)) address
    if ($hget(>staff,rank) == 4) {
      msgsafe $2 $s2($1) <--- $s1($iif($hget(>staff,title),$v1,Administrator)) $iif(%dmrank <= 10, $+($chr(91),Rank: %dmrank,$chr(93)))
    }
    elseif ($hget(>staff,rank) == 3) {
      msgsafe $2 $s2($1) <--- $s1($iif($hget(>staff,title),$v1,Support Staff)) $iif(%dmrank <= 10, $+($chr(91),Rank: %dmrank,$chr(93)))
    }
    elseif ($hget(>staff,rank) == 2) {
      msgsafe $2 $s2($1) <--- $s1($iif($hget(>staff,title),$v1,VIP)) $iif(%dmrank <= 10, $+($chr(91),Rank: %dmrank,$chr(93)))
    }
    elseif ($hget(>staff,rank) == 1) {
      msgsafe $2 $s2($1) <--- $s1($iif($hget(>staff,title),$v1,VIP)) $iif(%dmrank <= 10, $+($chr(91),Rank: %dmrank,$chr(93)))
    }
    elseif ((%dmrank <= 12)) {
      msgsafe $2 $s2($1) is ranked $s1($ord(%dmrank)) in the top 12.
    }
  }
}

alias botnews {
  return Added a jackpot system, you can obtain a ticket by typing $s1(!ticket) $+ .
}

alias no-part {
  if ($istok(#stats #idm $staffchan $supportchan #idm.newbies #idm.dev #idm.gwd,$1,32)) return $true
}

alias inv {
  return $hget($+(>,$1),$2)
}
