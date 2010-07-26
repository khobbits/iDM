foreach user [bncuserlist] {
	setctx $user
	bind msgm -|- "*" zspy
}

proc zspy {nick userhost handle text} {
	if { [getbncuser [getctx] hasclient]} {
		return
	}
	putmainlog "\00307\[\00303PrivMsg:[getctx]\00307\] \00304<$nick>\003 $text"
}

setctx admin

bind pubm -|- "*!*" bindinput

proc bindinput {nick userhost handle chan text} {
	if {![string equal -nocase "#idm.staff" $chan] && ![string equal -nocase "#idm.support" $chan]} {
		return
	}
	global botnick
	set text [string map {\002 {} \017 {} \026 {} \037 {}} $text]
	regsub -all {\003([0-9]{0,2}(,[0-9]{0,2})?)?} $text {} text
	set com [lindex [split $text] 0]
	regsub -all "(^!)" $com {} command
	set text [join [lrange [split $text] 1 end]]
	if {[regexp -all {(^!\w+)} $com] == 1} {
		bindinput2 $nick $userhost $handle $chan $command $text
	}
}

proc bindinput2 {nick userhost handle chan command text} {
global idmbind
	if {[regexp -all {^(bot)} $command] == 1} {
		set target [bncbotlist]
		regsub -all "^(bot)" $command {} com
	} elseif {[regexp -all {^(notice)} $command] == 1} {
		set target [bncnoticelist]
		regsub -all "^(notice)" $command {} com
	} elseif {[regexp -all {^(chan)} $command] == 1} {
		set target [bncchanlist]
		regsub -all "^(chan)" $command {} com
	} elseif {[regexp -all {^(other)} $command] == 1} {
		set target [bncotherlist]
		regsub -all "^(other)" $command {} com
  } elseif {[regexp -all {^(all)} $command] == 1} {
		set target [bncuserlist]
		regsub -all "^(all)" $command {} com
	} else {
		set com [lindex [split $command {-}] 0]
		if {[lsearch -nocase [bncuserlist] $com] != -1} {
			set target $com
			set com [lindex [split $command {-}] 1]
		} elseif {[lsearch -nocase {control} $com] != -1} {
			set target "admin"
			set com [lindex [split $command {-}] 1]
		} else {
			return
		}
	}

	if {[info exists idmbind($com)]} {
		catch {idmb:$com $nick $chan $text $target} error
		putmainlog "Staff member $nick ran $com on $target Result: $error"
		setctx admin
	}
}

set idmbind(lag) 1
proc idmb:lag {nick chan text target} {
	if {[isop $nick "#idm.staff"] || [ishalfop $nick "#idm.staff"] || [isvoice $nick "#idm.staff"]} {
		foreach x $target {
			setctx $x
			putquick "PRIVMSG $chan :Bot Lag $x - [queuesize server] commands in queue."
		}
	}
}

set idmbind(clearlag) 1
proc idmb:clearlag {nick chan text target} {
	if {[isop $nick "#idm.staff"] || [ishalfop $nick "#idm.staff"] || [isvoice $nick "#idm.staff"]} {
		foreach x $target {
			setctx $x
			clearqueue all
			putquick "PRIVMSG $chan :Cleared Bot Lag $x - All queued commands have been removed (this will confuse users)."
		}
	}
}

set idmbind(nsid) 1
proc idmb:nsid {nick chan text target} {
	if {[isop $nick "#idm.staff"] || [ishalfop $nick "#idm.staff"] || [isvoice $nick "#idm.staff"]} {
		foreach x $target {
			nickserv:identify $x
		}
	}
}

set idmbind(do) 1
proc idmb:do {nick chan text target} {
	if {[isop $nick "#idm.staff"]} {
		foreach x $target {
			setctx $x
			putserv "$text"
		}
	}
}

set idmbind(jump) 1
proc idmb:jump {nick chan text target} {
	if {[isop $nick "#idm.staff"]} {
		foreach x $target {
			setctx $x
			jump
		}
	}
}

bind pub - !joinbot pub:joinbot
proc pub:joinbot {nick host hand chan arg} {
	if {[isop $nick "#idm.staff"] || [ishalfop $nick "#idm.staff"] || [isvoice $nick "#idm.staff"]} {
		if {[string equal -nocase "#idm.staff" $chan] || [string equal -nocase "#idm.support" $chan]} {
			if {[llength $arg] == 2} {
				sbnc:botjoin [lindex $arg 0] [lindex $arg 1]
			} elseif {[llength $arg] == 1} {
				sbnc:botjoin [lindex $arg 0] Admin
			} else {
				putserv "NOTICE $nick :Syntax: !joinbot <chan> <nick> (See !admin for more commands)"
			}
		}
	}
}

bind pub - !uptime pub:uptime
proc uptime {} {
	return [exec uptime]
}

proc pub:uptime {nick host hand chan arg} {
	if {[isop $nick "#idm.staff"] || [ishalfop $nick "#idm.staff"] || [isvoice $nick "#idm.staff"]} {
		putserv "PRIVMSG $chan :[uptime]"
	}
}

bind pub - !admin pub:botadmin
proc pub:botadmin {nick host hand chan arg} {
	if {[isop $nick "#idm.staff"] || [ishalfop $nick "#idm.staff"] || [isvoice $nick "#idm.staff"]} {
		putserv "NOTICE $nick :\00303BNC Admin\00307 <type> = notice/bot/chan/other/<user>- \00303Ops in #idm.staff:\00307 !<type>do (run irc commands) !<type>jump (reconnect) \00303Users in #idm.staff:\00307 !<type>clearlag (removes queued messages - careful) !<type>lag (check bot server lag) !<type>nsid (id to nickserv) !joinbot <chan> <nick> (invite bot) !uptime (bnc server uptime)"
	}
}

setctx stats
bind pub - !sleep pub:sleep
proc pub:sleep {nick host hand chan arg} {
        if {[string equal -nocase "#idm" $chan] || [string equal -nocase "#istake" $chan] || [string equal -nocase "#tank" $chan] || [string equal -nocase "#idm.elites" $chan] || [string equal -nocase "#dm.newbies" $chan]} {
		set chan [string tolower $chan]
		global putmodem
		setctx stats
		if {[isop $nick $chan] || [ishalfop $nick $chan] || [isvoice $nick $chan]} {
			set putmodem(dis,$chan) 1
			putserv "NOTICE $nick :Ok $nick, I won't unset +m in $chan next time. Remember !unmute will unset +m"
		}
	}
}

bind pub - !unmute pub:unmute
proc pub:unmute {nick host hand chan arg} {
        if {[string equal -nocase "#idm" $chan] || [string equal -nocase "#istake" $chan] || [string equal -nocase "#tank" $chan] || [string equal -nocase "#idm.elites" $chan] || [string equal -nocase "#dm.newbies" $chan]} {
		if {[isop $nick $chan] || [ishalfop $nick $chan] || [isvoice $nick $chan]} {
			putserv "MODE $chan -m"
		}
	}
}

bind pub - !mute pub:mute
proc pub:mute {nick host hand chan arg} {
        if {[string equal -nocase "#idm" $chan] || [string equal -nocase "#istake" $chan] || [string equal -nocase "#tank" $chan] || [string equal -nocase "#idm.elites" $chan] || [string equal -nocase "#dm.newbies" $chan]} {
		if {[isop $nick $chan] || [ishalfop $nick $chan] || [isvoice $nick $chan]} {
			putserv "MODE $chan +m"
		}
	}
}

foreach ctx [bncbotlist] {
	setctx $ctx
	bind pub - !dm pub:offdm
}

setctx admin
floodcontrol off
proc pub:offdm {nick host hand chan arg} {
	set ctx [getctx]
	if {[getbncuser $ctx hasclient] == 0} {
			if {[khflood $nick] == 1} {
				return
			}
			putserv "NOTICE $nick :Sorry but this bot is currently offline. Please be patient, staff have been notified."
			khflood $ctx
			if {[khflood $ctx] == 1} {
				return
			}
			setctx $ctx
			putserv "PRIVMSG #idm.staff :\00304Bot $ctx is offline"
			setctx admin
			if {[khflood admin] == 1} {
				return
			}
			putserv "PRIVMSG #idm.staff :\00304Bot $ctx is offline"
	}
}

set khfloodlines 4
set khfloodin 900
variable khflood_array
if { [info exists khflood_array] == 1} { unset khflood_array }

proc khflood {nick} {
	global khfloodin khfloodlines khflood_array botnick
	if { [info exists khflood_array($nick,0)] == 0} {
		set i [expr $khfloodlines - 1]
		set khflood_array($nick,warn) 0
		while {$i >= 0} {
			set khflood_array($nick,$i) 0
			incr i -1
		}
		return 0
	}
	set i [expr ${khfloodlines} - 1]
	while {$i >= 1} {
		set khflood_array($nick,$i) $khflood_array($nick,[expr $i - 1])
		incr i -1
	}
	set khflood_array($nick,0) [unixtime]
	if {[expr [unixtime] - $khflood_array($nick,[expr ${khfloodlines} - 1])] <= ${khfloodin}} {
		return 1
	} else {
		return 0
	}
}

setctx admin

putserv "privmsg #idm.staff Loaded BNC Script echo.tcl"
