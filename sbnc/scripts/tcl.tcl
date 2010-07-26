################################################################################
###### Author: Khobbits ( #tcl on irc.swiftirc.net | tcl@khobbits.co.uk ) ######
################################################################################

# 'TCL bot' script v2

internalbind command tclbot:admin

proc tclbot:admin {client parameters} {
	set command [lindex $parameters 0]
	if {[string equal -nocase $command "help"]} {
		if {[getbncuser $client admin]} {
			set help "tclbot <command> <param>
				Commands:
				add <username> - defines user as tclbot
				del <username> - undefines user as tclbot
				hostadd <username> <handle> <nick!ident@host> - adds a hostmask to the allow list
				hostdel <username> <handle> - removes a hostmask from the allow list
				show <username> - Displays current settings"

			bncaddcommand "tclbot" "BotAdmin" "Allows the admin of the TCLBots" $help
		}
	}
	if {![getbncuser $client admin]} { return }
	if {[string equal -nocase $command "tclbot"]} { tclbot:command $client $parameters }
}

proc tclbot:command {client parameters} {

	if { [string equal -nocase "tclbot" [lindex $parameters 0]] && [getbncuser $client admin] } {
		catch {tclbot [lindex $parameters 1] [join [lrange $parameters 2 end]]} result
		if {$result == ""} { set result "Null!" }
		foreach sline [split $result \n] {
			bncreply "$sline"
		}
		haltoutput
	}
	return
}

proc tclbot {command args} {
	set args [join $args]
	set ctx [getctx]

	set p1 [lindex $args 0]
	set p2 [lindex $args 1]
	set p3 [lindex $args 2]

	set result ""
	switch -- $command {
		add {
			if {[lindex $args 0] == ""} {
				set result "Syntax: tclbot add <username> - See /sbnc help tclbot for more information"
			} else {
				setbncuser $p1 tag tclbot 1
				setbncuser $p1 tag tclbot.trig "-"
				setbncuser $p1 tag tclbot.trigq "="
				setctx $p1
				bind pub n [getbncuser $p1 tag tclbot.trig] khtcl
				bind pub n [getbncuser $p1 tag tclbot.trigq] khtclq
				set result 1
			}
		}
		del {
			if {[lindex $args 0] == ""} {
				set result "Syntax: tclbot del <username> - See /sbnc help tclbot for more information"
			} else {
				setbncuser $p1 tag tclbot 0
				setbncuser $p1 tag tclbot.trig "-"
				setbncuser $p1 tag tclbot.trigq "="
				set result 1
			}
		}
		hostadd {
			if {[lindex $args 2] == ""} {
				set result "Syntax: tclbot hostadd <username> <handle> <nick!ident@host> - See /sbnc help tclbot for more information"
			} else {
				setctx $p1
				catch "deluser $p2" result
				catch "adduser $p2 $p3" result
				catch "chattr $p2 +n" result2
				tclbot.save $p1
			}
		}
		hostdel {
			if {[lindex $args 1] == ""} {
				set result "Syntax: tclbot hostdel <username> <handle> - See /sbnc help tclbot for more information p1: $p1 p2: $p2"
			} else {
				setctx $p1
				catch "deluser $p2" result
				tclbot.save $p1
			}
		}
		show {
			if {[lindex $args 0] == ""} {
				set result "Syntax: qbot show <username> - See /sbnc help qbot for more information"
			} else {
				set result "
				TCLBot settings for $p1\:
				Enabled: [getbncuser $p1 tag tclbot]
				Trigger: [getbncuser $p1 tag tclbot.trig]
				Quiet Trigger: [getbncuser $p1 tag tclbot.trigq]
				Hosts:"
				setctx $p1
				foreach user [userlist] {
					append result \n "$user - [join [getuser $user hosts]]"
				}
			}
		}
		default {
			set result "Syntax: tclbot <command> \[values/params\]
			/sbnc help tclbot for more information and a list of valid commands."
		}
	}
	setctx $ctx
	return "TCLBot $command - $result"
}

proc tclbot.save {user} {
	setctx $user
	set userlist ""
	foreach userl [userlist] {
		lappend userlist "$userl [getuser $userl hosts]"
	}
	setbncuser $user tag tclbot.hosts $userlist
	return 1
}

proc tclbot.load {user} {
	setctx $user
	set userlist [getbncuser $user tag tclbot.hosts]
	foreach usermask $userlist {
		catch "deluser [lindex $usermask 0]" result
		catch "adduser [lindex $usermask 0] [join [lindex $usermask 1]]" result
		catch "chattr [lindex $usermask 0] +n" result
	}
	return 1
}

foreach user [bncuserlist] {
	if {[getbncuser $user tag tclbot] == 1} {
		setctx $user
		bind pub n [getbncuser $user tag tclbot.trig] khtcl
		bind pub n [getbncuser $user tag tclbot.trigq] khtclq
		tclbot.load $user
	}
}

set khctx admin
setctx admin

proc khtcl {nick host hand chan arg} {
	set khctx [getctx]
	if { [getbncuser $khctx tag tclbot] != "1" } { return }
	catch {eval $arg} result
	setctx $khctx
	if {$result == ""} { set result "<null>" }
	foreach sline [split $result \n] {
		putserv "PRIVMSG $chan :( $arg ) = $sline"
	}
}

proc khtclq {nick host hand chan arg} {
	if { [getbncuser [getctx] tag tclbot] != "1" } { return }
	catch {eval $arg} result
}

package require mysqltcl
proc mysqlq {query} {
  set dbname "idm_bot"
  set dbuser "idm"
  set dbpasswd {Sp4rh4wk`Gh0$t`}
  set db [::mysql::connect -user $dbuser -password $dbpasswd -db $dbname]
  set result [::mysql::sel $db $query -list]
  return $result
}


setctx admin

putserv "privmsg #idm.staff Loaded BNC Script tcl.tcl"