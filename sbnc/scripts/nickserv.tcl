# Title: nickserv.tcl
# Author: El_Rico
#
# Modified by Khobbits
#
# Version:
#		4b - Changes to help lines
#		  - Changes to default behaviour
#		4 - Cosmetic changes to unset
#		  - Added the "/sbnc nickserv identify" command
#		  - Fixed a bug that rendered nickserv.tcl useless on freenode (reported by b52)
#		3 - Changed bind structure to enhance performance
#		  - Minimal changes to "set" output to prevent confusion about settings
#		2 - Fixed typo
#		  - Added pattern to server bind
#		1 - initial release
# License: GPL 2 (http://www.gnu.org/licenses/gpl.html)
# Contact: El_Rico in #sbnc on irc.quakenet.org
# Purpose: Adding NickServ interacting capabilities to sBNC
# Getting started: load the script in sBNC and type "/sbnc nickserv" in your IRC client

internalbind command nickserv:command
internalbind svrlogon nickserv:logon

foreach user [bncuserlist] {
	if { [getbncuser $user tag nickserv.password] != "" && [getbncuser $user tag nickserv.reply] != "" && [getbncuser $user tag nickserv.warning] != "" } {
		internalbind server nickserv:server NOTICE $user
		internalbind server nickserv:server PRIVMSG $user
	}
}


proc nickserv:command { client params } {
	if { [string equal -nocase [lindex $params 0] "help"] } {
		bncaddcommand nickserv KHUser "enables the nickserv auto-ident system" "For more help with this command type /sbnc nickserv help"
	} elseif { [string equal -nocase [lindex $params 0] "nickserv"] } {
		if { [llength $params] < 2 } {
			bncreply "You can use this command to identify on server logon, on NickServ warning and auto-ghosting."
			bncreply "To get more detailed help and usage instructions use /sbnc nickserv help"
			haltoutput
		} elseif { [string equal -nocase [lindex $params 1] "set"] } {
			if { [llength $params] < 3 } {
				bncreply "nickserv.tcl settings:"
				if { [getbncuser $client tag nickserv.nick] == "" } {
					bncreply "nick: not set."
					haltoutput
				} else {
					bncreply "nick: [getbncuser $client tag nickserv.nick]"
					haltoutput
				}
				if { [getbncuser $client tag nickserv.password] == "" } {
					bncreply "password: not set."
					haltoutput
				} else {
					bncreply "password: set."
					haltoutput
				}
				if { [getbncuser $client delayjoin] == 0 } {
					bncreply "delayjoin: off"
					haltoutput
				} else {
					bncreply "delayjoin: on"
					haltoutput
				}
				if { [getbncuser $client tag nickserv.reply] == "" } {
					bncreply "reply: not set."
					haltoutput
				} else {
					bncreply "reply: [getbncuser $client tag nickserv.reply]"
					haltoutput
				}
				if { [getbncuser $client tag nickserv.warning] == "" } {
					bncreply "warning: not set."
					haltoutput
				} else {
					bncreply "warning: [getbncuser $client tag nickserv.warning]"
					haltoutput
				}
				if { [getbncuser $client tag nickserv.onconnect] == "" } {
					bncreply "onconnect: not set."
					haltoutput
				} else {
					bncreply "onconnect: [getbncuser $client tag nickserv.onconnect]"
					haltoutput
				}
			} elseif { [llength $params] < 4 } {
				if { [string equal -nocase [lindex $params 2] "nick"] } {
					bncreply "No value given, to unset this setting use /sbnc nickserv unset nick"
					haltoutput
				} elseif { [string equal -nocase [lindex $params 2] "password"] } {
					bncreply "No value given, to unset this setting use /sbnc nickserv unset password"
					haltoutput
				} elseif { [string equal -nocase [lindex $params 2] "delayjoin"] } {
					bncreply "No value given, to unset this setting use /sbnc nickserv unset delayjoin"
					haltoutput
				} elseif { [string equal -nocase [lindex $params 2] "reply"] } {
					bncreply "No value given, to unset this setting use /sbnc nickserv unset reply"
					haltoutput
				} elseif { [string equal -nocase [lindex $params 2] "warning"] } {
					bncreply "No value given, to unset this setting use /sbnc nickserv unset warning"
					haltoutput
				} elseif { [string equal -nocase [lindex $params 2] "onconnect"] } {
					bncreply "No value given, to unset this setting use /sbnc nickserv unset onconnect"
					haltoutput
				} else {
					bncreply "Unknown setting."
					haltoutput
				}
			} elseif { [string equal -nocase [lindex $params 2] "nick"] } {
				setbncuser $client tag nickserv.nick [lindex $params 3]
				bncreply "Done."
				haltoutput
			} elseif { [string equal -nocase [lindex $params 2] "password"] } {
				setbncuser $client tag nickserv.password [lindex $params 3]
				if { [getbncuser $client tag nickserv.reply] == "" } {
					setbncuser $client tag nickserv.reply "ns"
					setbncuser $client delayjoin 1
				}
				if { [getbncuser $client tag nickserv.reply] != "" && [getbncuser $client tag nickserv.warning] != "" } {
					internalbind server nickserv:server NOTICE $client
					internalbind server nickserv:server PRIVMSG $client
				}
				bncreply "Done."
				haltoutput
			} elseif { [string equal -nocase [lindex $params 2] "delayjoin"] } {
				if { [string equal -nocase [lindex $params 3] "on"] } {
					setbncuser $client delayjoin 1
					bncreply "Done."
					haltoutput
				} elseif { [lindex $params 3] == 1 } {
					setbncuser $client delayjoin 1
					bncreply "Done."
					haltoutput
				} elseif { [string equal -nocase [lindex $params 3] "off"] } {
					setbncuser $client delayjoin 0
					bncreply "Done."
					haltoutput
				} elseif { [lindex $params 3] == 0 } {
					setbncuser $client delayjoin 0
					bncreply "Done."
					haltoutput
				} else {
					bncreply "Invalid value. Vaild values are on/off or 1/0."
					haltoutput
				}
			} elseif { [string equal -nocase [lindex $params 2] "reply"] } {
				set reply [lrange $params 3 end]
				setbncuser $client tag nickserv.reply $reply
				if { [getbncuser $client tag nickserv.password] != "" && [getbncuser $client tag nickserv.warning] != "" } {
					internalbind server nickserv:server NOTICE $client
					internalbind server nickserv:server PRIVMSG $client
				}
				bncreply "Done."
				haltoutput
			} elseif { [string equal -nocase [lindex $params 2] "warning"] } {
				set warning [lrange $params 3 end]
				setbncuser $client tag nickserv.warning $warning
				if { [getbncuser $client tag nickserv.password] != "" && [getbncuser $client tag nickserv.reply] != "" } {
					internalbind server nickserv:server NOTICE $client
					internalbind server nickserv:server PRIVMSG $client
				}
				bncreply "Done."
				haltoutput
			} elseif { [string equal -nocase [lindex $params 2] "onconnect"] } {
				if {[llength [split [lindex $params 3] {|}]] > 6} {
					bncreply "You can give up to 6 commands to perform on connect, commands should be seperated by '|'."
					bncreply "Remember you can join multiple channels in one command using /join #chan1,#chan2,#chan3"
				} else {
					setbncuser $client tag nickserv.onconnect [join [lrange "$params" 3 end]]
					bncreply "Check syntax your syntax for errors, errors will be supressed."
					bncreply "Set on connect to: [join [lrange "$params" 3 end]]"
				}
				haltoutput
			} else {
				bncreply "Unknown setting."
				haltoutput
			}
		} elseif { [string equal -nocase [lindex $params 1] "unset"] } {
			if { [string equal -nocase [lindex $params 2] "nick"] } {
				setbncuser $client tag nickserv.nick ""
				bncreply "Done."
				haltoutput
			} elseif { [string equal -nocase [lindex $params 2] "password"] } {
				setbncuser $client tag nickserv.password ""
				internalunbind server nickserv:server NOTICE $client
				internalunbind server nickserv:server PRIVMSG $client
				bncreply "Done."
				haltoutput
			} elseif { [string equal -nocase [lindex $params 2] "delayjoin"] } {
				setbncuser $client delayjoin 0
				bncreply "Delayjoin can not be unset, disabling it instead."
				haltoutput
			} elseif { [string equal -nocase [lindex $params 2] "reply"] } {
				setbncuser $client tag nickserv.reply ""
				internalunbind server nickserv:server NOTICE $client
				internalunbind server nickserv:server PRIVMSG $client
				bncreply "Done."
				haltoutput
			} elseif { [string equal -nocase [lindex $params 2] "warning"] } {
				setbncuser $client tag nickserv.warning ""
				internalunbind server nickserv:server NOTICE $client
				internalunbind server nickserv:server PRIVMSG $client
				bncreply "Done."
				haltoutput
			} elseif { [string equal -nocase [lindex $params 2] "onconnect"] } {
				setbncuser $client tag nickserv.onconnect ""
				bncreply "Done."
				haltoutput
			} else {
				bncreply "Unknown setting."
				haltoutput
			}
		} elseif { [string equal -nocase [lindex $params 1] "identify"] } {
			nickserv:identify $client
			bncreply "Done."
			haltoutput
		} elseif { [string equal -nocase [lindex $params 1] "perform"] } {
			nickserv:onconnect $client
			bncreply "Done."
			haltoutput
		} elseif { [string equal -nocase [lindex $params 1] "help"] } {
			if { [string equal -nocase [lindex $params 2] "set"] } {
				bncreply "To set or change a setting use /sbnc nickserv set <setting> <value>"
				bncreply "The following settings are available: nick, password, delayjoin, reply and warning."
				bncreply "-"
				bncreply "The \"password\" setting defines your NickServ password. Please note that the password is stored in plain text!"
				bncreply "The \"password\" settings is required, if not set, all nickserv.tcl functions will be disabled."
				bncreply "-"
				bncreply "The \"reply\" setting defines how the bnc will interact with NickServ."
				bncreply "Examples: if you interact with NickServ via \"/msg NickServ\" set \"reply\" to \"PRIVMSG NICKSERV\","
				bncreply "if you are using \"/msg NickServ@services.net.tld\" set \"reply\" to \"PRIVMSG NickServ@services.net.tld\","
				bncreply "if you are using \"/NickServ\" or \"/NS\" set \"reply\" to \"NickServ\" or \"NS\" respectively."
				bncreply "The \"reply\" settings is required, if not set, all nickserv.tcl functions will be disabled."
				bncreply "-"
				bncreply "The \"delayjoin\" setting defines whether delayjoin is enabled or not."
				bncreply "If enabled sBNC will wait 5 seconds before it joins your channels, to create a wider timeframe for identification and auto-ghosting."
				bncreply "Vaild values are \"on\", \"off\", \"1\" and \"0\"."
				bncreply "-"
				bncreply "To enable the auto-ghost feature you need to define a nickname, if \"nick\" is set the feature will be a enabled."
				bncreply "If that nick is already in use when sBNC logs onto the server, the bnc will attempt to ghostkill that nick and retake it."
				bncreply "-"
				bncreply "The BNC can run other commands on connection, these commands will be sent after the first nickserv id attempt"
				bncreply "Set the \"onconnect\" setting to the commands you wish to run, seperated by \"|\". There should be no more than 6."
				bncreply "Keep in mind commands should use raw IRC syntax eg: privmsg chanserv :invite #channel | join #channel"
				bncreply "-"
				bncreply "To allow the system to automatically reply whenever prompted by nickserv you need to state which phrase to respond too."
				bncreply "The \"warning\" setting defines how NickServ warns you that the nick you are using is registered."
				bncreply "If the ns notice begins with something like \"This nickname is registered and protected.  If it is your\""
				bncreply "you can use that phrase as the trigger \"/sbnc nickserv set warning This nickname is registered and protected.  If it is your\""
				bncreply "If \"warning\" is not set, the identify on NickServ warning feature is disabled."
				haltoutput
			} elseif { [string equal -nocase [lindex $params 2] "unset"] } {
				bncreply "To unset a setting use /sbnc nickserv unset <setting>"
				bncreply "Vaild settings are: nick, password, reply, onconnect and warning."
				bncreply "Due to sBNC restrictions delayjoin can not be unset, it can only be disabled."
				haltoutput
			} elseif { [string equal -nocase [lindex $params 2] "disable"] } {
				bncreply "To disable all nickserv.tcl functionality for this account unset either \"password\", \"reply\" or both."
				bncreply "To disable the auto-ghost feature unset \"nick\"."
				bncreply "To disable the identify on NickServ warning feature unset \"warning\"."
				haltoutput
			} elseif { [string equal -nocase [lindex $params 2] "identify"] } {
				bncreply "To manually identify, or to test your \"reply\" and \"password\" settings, use /sbnc nickserv identify"
				haltoutput
			} elseif { [string equal -nocase [lindex $params 2] "onconnect"] } {
				bncreply "The BNC can commands on connection, these commands will be sent after the first nickserv id attempt"
				bncreply "Set the \"onconnect\" setting to the commands you wish to run."
				bncreply "Commands should be seperated by \"|\", using raw IRC syntax. You can't set more than 6 commands."
				bncreply "Remember you can join multiple channels in one command using /join #chan1,#chan2,#chan3"
				bncreply "Example: /sbnc nickserv set onconnect :cs invite #chan1 | join #chan1,#chan2 | privmsg IRCbot :!defname $client"
				bncreply "To test the commands you can run them using: /sbnc nickserv perform"
				haltoutput
			} elseif { [llength $params] < 3 } {
				bncreply "To enable auto identifying on join you will need to set your nickserv password"
				bncreply "/sbnc nickserv set password <ns pass>"
				bncreply "Detailed help is available with the following commands:"
				bncreply "/sbnc nickserv help set (description of the set command and settings)"
				bncreply "/sbnc nickserv help unset (description of the unset command)"
				bncreply "/sbnc nickserv help disable (how to disable this function)"
				bncreply "/sbnc nickserv help identify (description of the identify command)"
				bncreply "/sbnc nickserv help onconnect (description of how to set commands on connect)"
				haltoutput
			} else {
				bncreply "No help available on that topic."
				haltoutput
			}
		}
	}
}

proc nickserv:logon { client } {
	global botnick
	if { [getbncuser $client tag nickserv.password] == "" } {
		return
	} elseif { [getbncuser $client tag nickserv.reply] == "" } {
		return
	} else {
		setctx $client
		if { $botnick != [getbncuser $client tag nickserv.nick] && [getbncuser $client tag nickserv.nick] != "" } {
			putserv "[getbncuser $client tag nickserv.reply] :ghost [getbncuser $client tag nickserv.nick] [getbncuser $client tag nickserv.password]"
			utimer 2 "nickserv:ghost {$client}"
		} else {
			nickserv:identify $client
			utimer 2 "nickserv:onconnect {$client}"
		}
	}
}

proc nickserv:ghost { client } {
	setctx $client
	putserv "NICK [getbncuser $client tag nickserv.nick]"
	utimer 2 "nickserv:identify {$client}"
	utimer 4 "nickserv:onconnect {$client}"
}

proc nickserv:onconnect { client } {
	setctx $client
	foreach command [split [getbncuser $client tag nickserv.onconnect] {|}] {
		bncreply "Sending command to server: [string trim $command]"
		putserv "[string trim $command]"
	}
}


proc nickserv:server { client params } {
	if { [string match -nocase *[join [getbncuser $client tag nickserv.warning] " "]* [join $params " "]] } {
		nickserv:identify $client
	} else {
		return
	}
}

proc nickserv:identify { client } {
	setctx $client
	putserv "[getbncuser $client tag nickserv.reply] :identify [getbncuser $client tag nickserv.password]"
}
