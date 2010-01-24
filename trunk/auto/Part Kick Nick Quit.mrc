on $*:TEXT:/^[!@.]part/Si:#: {
        if (# == #idm) || (# == #idm.Staff) { return }
        if ($2 != $me) { return }
        if ($nick isop # || $nick ishop #) || ($db.get(admins,position,$address($nick,3))) {
                if (%part.spam [ $+ [ # ] ]) { return }
                part # Part requested by $nick $+ .
                set -u10 %part.spam [ $+ [ # ] ] on
                msgsafe #idm.staff $logo(PART) I have parted: $chan $+ . Requested by $iif($nick,$v1,N/A) $+ .
                cancel #
        }
}

on *:PART:#: {
        if ($nick(#,0) < 5) && (!$istok(#idm #idm.staff #idm.help #idm.support #tank #istake,#,32)) {
                cancel #
                part # Parting channel. Need 5 or more people to have iDM.
        }
        if ($nick == $me) && (!%rjoinch. [ $+ [ $me ] ]) {
                cancel #
        }
        if ($hget($chan) && $hget($nick))  {
                if ($enddmcheck($chan,$knick,part,$1,$2-)) { return }
        }
}

on *:QUIT: {
        if (!$hget($nick)) { return }
        var %a 1
        while (%a <= $chan(0)) {
                if ($enddmcheck($chan(%a),$nick,quit,$1,$2-)) { return }
                inc %a
        }
}

on *:KICK:#: {
        if ($nick(#,0) < 6) && ($knick != $me) { part # Parting channel. Need 5 or more people to have iDM. }
        if ($hget($knick)) && ($hget($chan)) {
                if ($enddmcheck($chan,$knick,kick,$nick,$1-)) { return }
        }
        if ($knick == $me) {
                .timer 1 15 waskicked #
                if (. !isin $nick) { msgsafe #idm.staff $logo(KICK) I have been kicked from: $chan by $nick $+ . Reason: $1- }
                elseif (shroudbnc !isin $nick) { join # | msgsafe #idm.staff $logo(REJOINING) I was kicked from $chan by $nick - $1- }
        }
}

on *:NICK: {
        var %a = 1
        if ($hget($nick)) {
                while (%a <= $chan(0)) {
                        if ($hget($chan(%a),stake)) && (($nick == $hget($chan(%a),p1)) || ($nick == $hget($chan(%a),p2))) {
                                db.set user money $nick - $ceil($calc($hget($chan(%a),stake)) / 2))
                                msgsafe $chan(%a) $logo(DM) The stake has been canceled, because one of the players changed their nick. $s1($nick) has lost $s2($price($ceil($calc($hget($chan(%a),stake)) / 2))) $+ .
                                cancel $chan(%a)
                                .timer $+ $chan(%a) off
                                halt
                        }
                        elseif (($nick == $hget($chan(%a),p1)) || ($nick == $hget($chan(%a),p2))) {
                                msgsafe $chan(%a) $logo(DM) The DM has been canceled, because one of the players changed their nick. Penalties will be enforced soon.
                                cancel $chan(%a)
                                .timer $+ $chan(%a) off
                                halt
                        }

                        ; if ($nick == $hget($chan(%a),p1)) {
                                ;  db.set user indm $nick 0
                                ;  db.set user indm $newnick 1
                                ;  hadd $chan(%a) p1 $newnick
                                ;}
                        ; if ($nick == $hget($chan(%a),p2)) {
                                ;  db.set user indm $nick 0
                                ;  db.set user indm $newnick 1
                                ;  hadd $chan(%a) p2 $newnick
                                ;}
                        inc %a
                }
        }
}


alias waskicked {
        if ($me !ison $1) {
                cancel $1
                .timer $+ $1 off
        }
}

alias enddmcatch {
        ; $1 = event
        ; $2 = nick
        ; $3 = chan
        ; $4 = string/offender
        ; $5- = string
        goto $1
        :part
        var %action = parted $3 with reason " $+ $iif($4-,$4-,N/A) $+ "
        goto pass
        :quit
        var %action = quit $network & $3 ( $+ $4- $+ )
        if ($4 == Quit:) { goto pass }
        else { goto qfail  }
        :kick
        var %action = was kicked from $3 by $4 for " $+ $5- $+ "
        if ($3 == $4) { goto pass }
        else { goto fail }
        :error
        reseterror
        goto fail
        :pass
        msgsafe #idm.staff $logo(ENDDM) $2 %action *
        return 1
        :fail
        msgsafe #idm.staff $logo(ENDDM) $2 %action
        return 0
        :qfail
        return 0
}

alias enddmcheck {
        ; $1 = chan
        ; $2 = nick
        ; $3 = event
        ; $4- = string
        if ($hget($1,p2)) && ($hget($1,stake)) && (($hget($1,p1) == $2) || ($hget($1,p2) == $2)) {
                db.set user money $2 - $ceil($calc($hget($1,stake) / 2) )
                msgsafe $1 $logo(DM) The stake has been canceled, because one of the players parted. $s1($2) has lost $s2($price($ceil($calc($hget($1,stake) / 2) ))) $+ .
                cancel $1
                .timer $+ $1 off
                return 1
        }
        elseif ($2 == $hget($1,p1)) || ($2 == $hget($1,p2)) {
                msgsafe $1 $logo(DM) The DM has been canceled, because one of the players parted.
                if ($enddmcatch($3,$2,$1,$4,$5-) == 1) && ($hget($1,p2)) {
                        var %oldmoney = $hget($2,money)
                        if (%oldmoney > 100) {
                                var %newmoney = $ceil($calc(%oldmoney * 0.02))
                                notice $2 You left the channel during a dm, you lose $s2($price(%newmoney)) cash
                                write penalty.txt $timestamp $2 $3 channel $1 during a dm oldcash %oldmoney penalty %newmoney
                                db.set user money $2 - %newmoney
                        }
                        db.set user losses $2 + 1
                }
                cancel $1
                .timer $+ $1 off
                return 1
        }
        return 0
}


