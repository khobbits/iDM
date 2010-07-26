internalbind attach sbnc:noticeattach
internalbind client sbnc:noticemirror
internalbind command sbnc:noticecom
internalbind server sbnc:botmirror


proc sbnc:jumpnext {} {
  foreach x [bncuserlist] {
		if {[string length [getbncuser $x server]] > 1} {
		  if {[getbncuser $x hasserver] == 0} {
        setctx $x
        jump
        putmainlog "Jumping $x"
        return 1
      }
    }
  }
  return 0
}

proc sbnc:jumpend {} {
  if {[sbnc:jumpnext] != 0} {
    utimer 1 sbnc:jumpend
  } else {
    putmainlog "No more users to jump"
    utimer 120 sbnc:jumpend
  }
}

proc sbnc:jumpcontinue {} {
 	if {[getbncuser admin hasserver] == 0} {
	  foreach x [bncuserlist] {
  	   if ($x != "admin") {
  	     setctx $x
         bncdisconnect "iDM Restart"
       }
    }
	 	utimer 10 sbnc:jumpcontrol
	 	putmainlog "Waiting another 10s for admin to connect"
	} else {
    setctx admin
    putserv "privmsg #idm.staff :Reconnecting bots in 15s"
    utimer 10 sbnc:jumpend
    putmainlog "Queued Bot Jump"
  }
}

proc sbnc:jumpcontrol {} {
	if {[getbncuser admin hasserver] == 0} {
		setctx admin
		jump
 	  utimer 10 sbnc:jumpcontinue
 	  putmainlog "Queued admin connect check"
 	} else {
    putmainlog "Admin already connected, halting init scripts."
  }
 	
}


if {([getbncuser admin hasserver] == 0) || ([getbncuser idmHub hasserver] == 0) || ([getbncuser idmnHub hasserver] == 0)} {
  foreach x [bncuserlist] {
       setctx $x
       bncdisconnect "iDM Restart"
  }
  putmainlog "Triggering iDM Restart: tcl rehash with core bots offline"
}


putmainlog "Starting iDM Init Check"
utimer 5 sbnc:jumpcontrol


proc sbnc:noticemirror {client parameters} {
	global botnick botname server putmodem lastmsg
	set cmd [lindex $parameters 0]
	set chan [string tolower [lindex $parameters 1]]
	set serv [lindex [split $server ":"] 0]
	set haltoutput 0

	if {[string equal -nocase "notice" $cmd]} {
		if {[getbncuser $client tag noticemirror] != ""} {
			set otherctx [getbncuser $client tag noticemirror]

			haltoutput
			if {[llength $parameters] < 3} {
				putclient ":$serv 461 $botnick NOTICE :Not enough parameters"
			} else {
				setctx $otherctx
				if {[queuesize all] > 0} {
					sbnc:lowestnotice
				}
				putserv "NOTICE $chan :[lindex $parameters 2]"
			}
		}
		return 
	} elseif {[string equal -nocase "privmsg" $cmd]} {
		if {[llength $parameters] > 2} {
			if {[string equal -nocase "#idm.staff" $chan] || [string equal -nocase "@#idm.support" $chan]} {
				if {[string first {[} [stripcodes c [lindex $parameters 2]]] != -1} {
					haltoutput
					setctx admin
					putserv "privmsg $chan :\00307\[\00303[string range $client 3 end]|[string range [lindex $parameters 2] 4 end]"
					setctx $client
				}
			} elseif {[string first {[KO]} [stripcodes c [lindex $parameters 2]]] != -1} {
				if {[string equal -nocase "#idm" $chan] || [string equal -nocase "#istake" $chan] || [string equal -nocase "#tank" $chan] || [string equal -nocase "#idm.elites" $chan] || [string equal -nocase "#dm.newbies" $chan] || [string equal -nocase "#we.dm" $chan]} {
					setctx stats
					set putmodem($chan) 1
					putquick "MODE $chan +m"
					setctx $client
				}
			} elseif {[string equal -nocase "#idm" $chan] || [string equal -nocase "#istake" $chan] || [string equal -nocase "#tank" $chan] || [string equal -nocase "#idm.elites" $chan] || [string equal -nocase "#dm.newbies" $chan] || [string equal -nocase "#we.dm" $chan]} {
				if {(([string first {[DM] Ready.} [stripcodes c [lindex $parameters 2]]] != -1) || ([string first {[GWD] Ready.} [stripcodes c [lindex $parameters 2]]] != -1)) && ([info exists putmodem($chan)] == 1)} {
					setctx stats
					if {[info exists putmodem(dis,$chan)]} {
						unset putmodem(dis,$chan)
					} else {
						haltoutput
						putmodem:unsetcheck $client $chan
						return 0
					}
					unset putmodem($chan)
					setctx $client
				}
			}
		}
	}
	set chan [split $chan ,]
	foreach ichan $chan {
		set lastmsg($ichan) [unixtime]
		if {[getbncuser $client tag chanmirror.$ichan] != ""} {
			set haltoutput 1
			putserv "[lindex $parameters 0] $ichan [sbnc:botswitch $client $ichan [join [lrange $parameters 2 end]]]"
			setctx $client
			set lsearch [lsearch $chan $ichan]
			if {$lsearch != -1} {
				set chan [lreplace $chan $lsearch $lsearch]
			}
		}
	}
	if {$haltoutput == 1} {
		haltoutput
		if {[llength $chan] > 0} {
			set output "$cmd [join $chan ,] [join [lrange $parameters 2 end]]"
			putserv $output
		}
	}
}

proc putmodem:unsetcheck {client chan} {
	setctx $client
	if {[queuesize server] >= 6} {
		putmainlog "LAG CHECK: $client has [queuesize server] commands in queue."
		utimer 8 "putmodem:unset $client $chan"
	} elseif {[queuesize server] >= 4} {
		utimer 6 "putmodem:unset $client $chan"
	} elseif {[queuesize server] >= 2} {
		utimer 4 "putmodem:unset $client $chan"
	} else {
		putmodem:unset $client $chan
	}
}

proc putmodem:unset {client chan} {
	if {[getbncuser $client tag chanmirror.$chan] != ""} {
		setctx [getbncuser $client tag chanmirror.$chan]
	} else {
		setctx $client
	}
	putserv "MODE $chan -m"

}

proc sbnc:botmirror {client parameters} {
	if {[getbncuser $client tag chanmirror] != ""} {
		set tokens [expr {[llength $parameters] -1}]
		set text ":[join [lrange $parameters 0 [expr {$tokens -1}]]] :[lindex $parameters $tokens]"
		putclient [sbnc:botswitchback $client $text]
	}
}

proc sbnc:botswitchback {client string} {
	global botnick
	set currnick $botnick
	setctx [getbncuser $client tag chanmirror]
	return [string map "$currnick $botnick" $string]
}

proc sbnc:botswitch {client chan string} {
	global botnick
	set currnick $botnick
	setctx [getbncuser $client tag chanmirror.$chan]
	return [string map "$currnick $botnick" $string]
}

proc sbnc:noticecom {client parameters} {
	set command [lindex $parameters 0]
	if {[string equal -nocase $command "help"]} {
			set help "Syntax: botmirror <username/:>"
			bncaddcommand "botmirror" "BotAdmin" "Allows a different bnc user to take over sending notices" $help
			set help "Syntax: botchanmirror <chan> <username/:>"
			bncaddcommand "botchanmirror" "BotAdmin" "Allows a different bnc user to take over sending messages to a channel" $help
			bncaddcommand "addbot" "BotAdmin" "Add's a bot and its clone" "Syntax: addbot <acc1> <acc2> <pass1> <vhost>"
			bncaddcommand "joinbot" "BotAdmin" "Join's the bot with the least load" "Syntax: joinbot <chan>"
	}
	if {[string equal -nocase $command "joinbot"]} {
		if {[llength $parameters] != 3} {
			bncreply "Syntax: /sbnc joinbot <chan> <nick>"
		} else {
			sbnc:botjoin [lindex $parameters 1] [lindex $parameters 2]
		}
		haltoutput
		return
	}
	if {[string equal -nocase $command "botmirror"]} {
		bncreply "Syntax: /sbnc botmirror <username/:>"
		if {[llength $parameters] == 2} {
			setbncuser $client tag noticemirror [lindex $parameters 1]
		}
		if {[getbncuser $client tag noticemirror] == ""} {
			set newclient $client
		} else {
			set newclient [getbncuser $client tag noticemirror]
		}
		bncreply "User $client will send notices through $newclient"
		haltoutput
		return
	}
	if {[string equal -nocase $command "botchanmirror"]} {
		set chan [string tolower [lindex $parameters 1]]
		haltoutput
		bncreply "Syntax: /sbnc botchanmirror <chan> <username/none>"
		if {[llength $parameters] == 1} {
				bncreply "The following channels have active relay bots:"
			foreach x [split [getbncuser $client tag chanmirrors] ,] {
				bncreply "$x - [getbncuser $client tag chanmirror.$x]"
			}
			return
		}
		if {[llength $parameters] == 3} {
			if {[lindex $parameters 2] == "none"} {
				if {[getbncuser $client tag chanmirror.$chan] != ""} {
					catch {	setbncuser [getbncuser $client tag chanmirror.$chan] tag chanmirror "" } resultdie
					setbncuser $client tag chanmirror.$chan ""
				}
				bncreply "Unsetting $chan from relay bot"
			} else {
				catch {	setbncuser [lindex $parameters 2] tag chanmirror $client } result
				if { $result == 1 } {
					set chanmirrors [split [getbncuser $client tag chanmirrors] ,]
					if {[getbncuser $client tag chanmirror.$chan] == ""} {
						setbncuser $client tag chanmirrors "[join [lappend chanmirrors $chan] ,]"
					} else {
						catch {	setbncuser [getbncuser $client tag chanmirror.$chan] tag chanmirror "" } resultdie
					}
					setbncuser $client tag chanmirror.$chan [lindex $parameters 2]
				} else {
					bncreply "Error: $result"
				}
			}
		}
		set newchanmirrors ""
		foreach x [split [getbncuser $client tag chanmirrors] ,] {
			if {[getbncuser $client tag chanmirror.$x] != "" && [string tolower [getbncuser [getbncuser $client tag chanmirror.$x] tag chanmirror]] == [string tolower $client]} {
				lappend newchanmirrors $x
			}
		}
		setbncuser $client tag chanmirrors [join $newchanmirrors ,]
		if {[getbncuser $client tag chanmirror.$chan] == ""} {
			set newclient $client
		} else {
			set newclient [getbncuser $client tag chanmirror.$chan]
		}
		bncreply "User $client will send messages to $chan through $newclient"
		return
	}
	if {[string equal -nocase $command "addbot"]} {
		if { [getbncuser $client admin] == 0 } { return }
		if {[llength $parameters] != 4} {
			bncreply "Syntax: /sbnc addbot <tag> <pass1> <vhost>"
		} else {
			set buser "idm[lindex $parameters 1]"
			set bnick "iDM\[[lindex $parameters 1]\]"
			set buser2 "idmn[lindex $parameters 1]"
			set bnick2 "iDM\[[lindex $parameters 1]-Notice\]"

			catch {addbncuser $buser [lindex $parameters 2]} result
			if {$result == 1} { bncreply "Added user $buser" } else { bncreply "$result" }
			catch {setbncuser $buser vhost [lindex $parameters 3]} result
			if {$result == 1} { bncreply "Set user $buser vhost to [lindex $parameters 3]" } else { bncreply "$result" }
			catch {setbncuser $buser awaynick $bnick} result
			if {$result == 1} { bncreply "Set user $buser nickname to $bnick" } else { bncreply "$result" }
			catch {addbncuser $buser2 [lindex $parameters 2]} result
			if {$result == 1} { bncreply "Added user $buser2" } else { bncreply "$result" }
			catch {setbncuser $buser2 vhost [lindex $parameters 3]} result
			if {$result == 1} { bncreply "Set user $buser2 vhost to [lindex $parameters 3]" } else { bncreply "$result" }
			catch {setbncuser $buser2 awaynick $bnick2} result
			if {$result == 1} { bncreply "Set user $buser2 nickname to $bnick2" } else { bncreply "$result" }
			catch {setbncuser $buser tag noticemirror $buser2} result
			if {$result == 1} { bncreply "Set up notice mirror on user $buser to $buser2" } else { bncreply "$result" }
		}
		haltoutput
		return
	}

}

proc sbnc:noticeattach {client} {
	global botnick botname
	set chans [split [getbncuser $client tag chanmirrors] ,]
	foreach chan $chans {
			setctx [getbncuser $client tag chanmirror.$chan]
			putserv "join $chan"
			putserv "names $chan"
			setctx $client
			putclient ":$botnick JOIN $chan"
	}
}

proc sbnc:lowestnotice {} {
	set queuesize ""
	lappend queuesize "admin 100"
	foreach x [bncnoticelist] {
		setctx $x
		lappend queuesize "$x [queuesize all]"
	}
	setctx [lindex  [lindex [lsort -integer -index 1 $queuesize] 0] 0]
}


proc botload {} {
set load ""
set load2 ""
	set ctx [getctx]
	foreach x [bncuserlist] {
		if {([getbncuser $x hasclient] == 1) && ([string first "idmHub" $x] == -1) && ([string first "idmn" $x] == -1) && ([string first "idmc" $x] == -1) && ([string first "idm" $x] != -1)} {
			setctx $x
			set chancount [llength [channels]]
			if {[queuesize server] < 2} {
				lappend load "[string range $x 3 end] $chancount"
			} else {
				lappend load2 "[string range $x 3 end] $chancount"
				if { [queuesize server] > 30 && [getbncuser $x tag warntime] < [unixtime]} {
					putmainlog "\00307\[\00303LAG\00307\]\00304 Bot $x has [queuesize server] lines in queue"
					setctx admin;
					puthelp "privmsg #idm.staff \00307\[\00303LAG\00307\]\00304 Bot $x has over 30 lines in queue - !botlag - !$x-clearlag (may help but not fix)"
					setbncuser $x tag warntime [expr {[unixtime] + 120}]
				}
			}
		}
	}
	setctx $ctx
	if {$load2 != "" && $load != ""} {
		return "[lsort -integer -index 1 $load] {- -} [lsort -integer -index 1 $load2]"
	} elseif {$load == ""} {
		return "[lsort -integer -index 1 $load2]"
	} elseif {$load2 == ""} {
		return "[lsort -integer -index 1 $load]"
	} else {
		return "{- -}"
	}
}

proc bload {} {
	setctx admin
	putserv "privmsg #Idm.staff :Botload: [join [string toupper [botload]]]"
}

proc sbnc:botjoin {chan who} {
			foreach bot [bncidmlist] {
				setctx $bot
				if {[botonchan $chan] == 1} {
					sbnc:lowestnotice
					putserv "notice $who \00307\[\00303Invite\00307\]\003 Sorry you already have an iDM bot, if $bot isn't there and this is a mistake, contact #idm.Support for help."
					return
				}
			}
			setctx admin
			set botload [botload]
			set botpicked [lindex [lindex $botload 0] 0]
			if {$botpicked == "-"} {
				putserv "privmsg #idm.staff :\00307\[\00303Load\00307\]\00304 All bots are offline \00304>\00303 $who\00304:\00303$chan"
				return
			}
			putserv "privmsg #idm.staff :\00307\[\00303Load\00307\]\003 [string map -nocase "$botpicked \00303$botpicked\003" [join [string toupper $botload]]] \00303>\00303 $who\00304:\00303$chan"
			catch {setctx "idm$botpicked";
			putserv "notice $who \00307\[\00303Invite\00307\]\003 Attempting to join $chan, if I don't appear within a minute, contact #idm.Support for help.";
			putclient ":idm!hub@idm-bot.com PRIVMSG [getcurrentnick] :\001JOIN $chan $who";
			} result
			setctx admin
			if {$result != 1} { putserv "privmsg #idm.staff :\00307\[\00303Invite Fail\00307\]\003 $result" }
			antiidle
}

proc sudo {args} {
	foreach x [bncuserlist] {
		if {([string first "idm" $x] != -1)} {
			setctx $x; putserv "[join $args]"
		}
	}
}

proc bncnoticelist {} {
	set ctx [getctx]
	foreach x [bncuserlist] {
		if {([string first "idmn" $x] != -1)} {
			lappend list "$x"
		}
	}
	return $list
}

proc bncchanlist {} {
	set ctx [getctx]
	foreach x [bncuserlist] {
		if {([string first "idmc" $x] != -1)} {
			lappend list "$x"
		}
	}
	return $list
}

proc bncbotlist {} {
	set ctx [getctx]
	foreach x [bncuserlist] {
		if {([string first "idmc" $x] == -1) && ([string first "idmn" $x] == -1) && ([string first "idm" $x] != -1)} {
			lappend list "$x"
		}
	}
	return $list
}

proc bncidmlist {} {
	set ctx [getctx]
	foreach x [bncuserlist] {
		if {([string first "idmn" $x] == -1) && ([string first "idm" $x] != -1)} {
			lappend list "$x"
		}
	}
	return $list
}

proc bncotherlist {} {
	set ctx [getctx]
	foreach x [bncuserlist] {
		if {([string first "belong" $x] == -1) && ([string first "alle" $x] == -1) && ([string first "kh" $x] == -1) && ([string first "idm" $x] == -1)} {
			lappend list "$x"
		}
	}
	return $list
}

proc antiidle {} {
	global lastmsg
	set idletime 30
	set idletimeout [expr {$idletime * 60}]
	foreach bot [bncbotlist] {
		setctx $bot
		set chans ""
		set channels [split [getbncuser $bot channels] {,}]
		foreach chan $channels {
			set lchan [string tolower $chan]
			if {[string equal -nocase "#idm.staff" $chan] || [string equal -nocase "#idm.support" $chan]
				|| [string equal -nocase "#idm" $chan] || [string equal -nocase "#istake" $chan] } {
				continue
			}
			if {[info exists lastmsg($lchan)] == 1} {
				if {$idletimeout < [expr {[unixtime] - $lastmsg($lchan)}]} {
					putserv "part $chan :This bot has been idling over $idletime mins. Parting channel."
					append chans " $chan"
					set lastmsg($lchan) [unixtime]
				}
			} else {
				set lastmsg($lchan) [unixtime]
			}
		}
		if {$chans != ""} {
			setctx admin
			putserv "privmsg #idm.staff \00307\[\00303[string range $bot 3 end]|Idle\00307\]\003 Parting$chans"
		}

	}
}

setctx admin

putserv "privmsg #idm.staff Loaded BNC Script notice.tcl"
