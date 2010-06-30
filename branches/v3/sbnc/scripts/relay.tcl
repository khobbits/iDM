setctx idmcsupport
bind pubm - "*" idmhelp:chanrelay
bind ctcp - action idmhelp:chanrelay:act
bind join - "*" idmhelp:chanrelay:join
bind part - "*" idmhelp:chanrelay:part
bind sign - "*" idmhelp:chanrelay:quit
bind kick - "*" idmhelp:chanrelay:kick
putserv "join #idm.support,#idm.help"

proc idmhelp:chanrelay {nick userhost handle chan text} {
set nick [string tolower $nick]
set chan [string tolower $chan]
global nickwarn
	if {[string tolower $chan] == "#idm.help"} {
		set unwarn " "
		if {[info exists nickwarn($nick)]} {
			killutimer $nickwarn($nick)
			unset nickwarn($nick)
			set unwarn " \00307\[\00303Reset Warn\00307\]\003"
		}
		set ref [idmhelp:ref $nick $text]
		if {($ref == "1") || ([isop $nick $chan])} {
			putchan "+#idm.support" "\00307<\00303$nick\00307>\003 $text $unwarn"
		} else {
			foreach line [lindex $ref 1] {
				putchan "#idm.help" "\00307\[\00303AutoHelp\00307\]\003 $line"
			}
			putchan "+#idm.support" "\00307<\00303$nick\00307>\003 $text -$unwarn \00307\[\00303AutoHelp\00307\]\003 [lindex $ref 0]"
		}
	} elseif {[string tolower $chan] == "#idm.support"} {
		if {[string match -nocase {`*} $text] == 1} {
			putchan "#idm.help" "\00307<\00303$nick\00307>\003 [string trimleft $text {`}]"
		}
		if {[string match -nocase {!warn *} $text] == 1} {
			if {[onchan [lindex $text 1] "#idm.help"] == 1} {
				idmhelp:chanwarn [lindex $text 1] "#idm.help"
			} else {
				putmsg $nick "\00307\[\00303AutoHelp\00307\]\003 [lindex $text 1] is not on #iDM.Help"
			}
		}
	}
}

proc idmhelp:chanrelay:act {nick userhost handle chan keyword text} {
	if {[string tolower $chan] == "#idm.help"} {
		idmhelp:chanrelay $nick $userhost $handle $chan "* $text *"
	}
}

proc idmhelp:chanrelay:join {nick userhost handle chan} {
	if {[string tolower $chan] == "#idm.help"} {
		if {[string match -nocase {idm*} $nick] == 0} { 
			putchan "#idm.help" "\00307\[\00303AutoHelp\00307\]\003 Welcome to iDM's support channel.  Please ask your question and wait for a reply.  Idling in the channel is not permitted."
			idmhelp:chanrelay $nick $userhost $handle $chan "\00307Joined $chan - Use !warn $nick to warn"
			utimer 600 "idmhelp:joinchanwarn $nick $chan"
		} else {
			idmhelp:chanrelay $nick $userhost $handle $chan "\00307Joined $chan"
		}
	}
}

proc idmhelp:chanrelay:part {nick userhost handle chan text} {
	if {[string tolower $chan] == "#idm.help"} {
		idmhelp:chanrelay $nick $userhost $handle $chan "\00307Parted $chan - $text"
	}
}

proc idmhelp:chanrelay:quit {nick userhost handle chan text} {
	if {[string tolower $chan] == "#idm.help"} {
		idmhelp:chanrelay $nick $userhost $handle $chan "\00307Quit $chan - $text"
	}
}

proc idmhelp:chanrelay:kick {who whouserhost whohandle chan nick text} {
	if {[string tolower $chan] == "#idm.help"} {
		idmhelp:chanrelay $nick - - $chan "\00307kicked from $chan by $who - $text"
	}
}

proc idmhelp:joinchanwarn {nick chan} {
	if {([onchan $nick $chan] == 1) && ({[isop $nick $chan] == 0})} {
		utimer 600 "idmhelp:joinchanwarn $nick $chan"
		idmhelp:chanwarn $nick $chan
	}
}

proc idmhelp:chanwarn {nick chan} {
	global nickwarn
	if {([onchan $nick $chan] == 1) && ([isop $nick $chan] == 0)} {
		if {[string match -nocase {idm*} $nick] == 1} { return }
		if {[info exists nickwarn([string tolower $nick])] == 0} {
			putchan $chan "\00307\[\00303AutoHelp\00307\]\003 Idling in this channel is not permitted.  If you have no other problems $nick please leave. /part $chan"
			putchan "+#idm.support" "\00307\[\00303AutoHelp\00307\] Warned $nick in $chan"
			set nickwarn([string tolower $nick]) [utimer 60 "idmhelp:chankick {[string tolower $nick]} {$chan}"]
		}
	}
}

proc idmhelp:chankick {nick chan} {
	if {[onchan $nick $chan] == 1} {
		newchanban $chan $nick IDLE {Idling is not permitted.  Please come back if you have another problem.} 1 sticky
	}
}

proc idmhelp:ref {nick text} {
	set desc {}
	set msg {}
	if { ([string match -nocase {*clue*} $text] == 1) || ([string match -nocase {*scroll*} $text] == 1) } {
		set desc {Clue help}
		set msg {
		{To view your clue: !dmclue}
		{To solve a clue: !solve answer}
		{If you need help with a clue scroll visit http://r.idm-bot.com/clues for help.}
		}
	 } elseif { ([string match -nocase {*appeal*} $text] == 1) || ([string match -nocase {*ignore*} $text] == 1)  || ([string match -nocase {*ban*} $text] == 1) } {
		set desc {appeal a ban}
		set msg {
		{If you need to Appeal a ban or ignore -> http://r.idm-bot.com/bl}
		{If you are waiting on an appeal DO NOT bug the one who blacklisted your channel/ignored you. This will only increase waiting time.}
		}
	} elseif { ([string match -nocase {*rule*} $text] == 1) || ([string match -nocase {*guidelines*} $text] == 1) } {
		set desc {idm rules}
		set msg {
		{To view the iDM rules visit: http://r.idm-bot.com/rules}
		}
	} elseif { ([string match -nocase {*ident*} $text] == 1) || ([string match -nocase {*login*} $text] == 1) } {
		set desc {how to identify}
		set msg {
		{To identify with iDM, you must be identify to NickServ first.  To force identify type: /msg iDM id}
		}
	} elseif { ([string match -nocase {*register*} $text] == 1) || ([string match -nocase {*nickserv*} $text] == 1) } {
		set desc {register with nickserv}
		set msg {
		{To use iDM you need to have a nickserv account, you can make a nickserv account using: /nickserv register}
		{Before you can dm on iDM you need to be identifed with nickserv, you identify using: /nickserv identify <password>}
		}
	} elseif { ([string match -nocase {*ident*} $text] == 1) || ([string match -nocase {*login*} $text] == 1) } {
		set desc {how to identify}
		set msg {
		{To invite iDM to your channel you need 4+ users, to invite type: /invite iDM #channel}
		}
	} elseif { ([string match -nocase {*command*} $text] == 1) || ([string match -nocase {*comand*} $text] == 1) } {
		set desc {!dmcommands}
		set msg {
		{To get a list of commands you can use, type !dmcommands in the channel.  iDM[Stats] commands are only available in certain channels.}
		}
	} elseif { ([string match -nocase {*clan*} $text] == 1) || ([string match -nocase {*team*} $text] == 1) } {
		set desc {clan help}
		set msg {
		{To join a clan (You need invite from the owner): !joinclan name}
		{To start a new clan: !startclan name}
		{You need to be the owner to add or remove members.  To Add: !addmem <name> To Remove: !delmem <name>}
		{To leave a clan (If your the owner it will delete the clan): !leaveclan}
		}
	} else {
		putmainlog "omg nomatch"
		return "1"
	}
	putmainlog "matched"
	return [list $desc $msg]
}

setctx admin

putserv "privmsg #idm.staff Loaded BNC Script relay.tcl"