# shroudBNC - an object-oriented framework for IRC
# Copyright (C) 2005 Gunnar Beutner
# Script by Worrum
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

internalbind usrcreate sbnc:defaultsettings
internalbind command defaultsettings:command

set ::defaultoptions [lsort [list server port serverpass realname awaynick away awaymessage delayjoin password appendts quitasaway automodes dropmodes ipv6 timezone lean ssl channelsort]]


proc sbnc:defaultsettings {username} {
	foreach setting $::defaultoptions {
		if {!([bncgetglobaltag $setting] == "")} {
			setbncuser $username $setting [bncgetglobaltag $setting]
		}
	}
}

proc defaultsettings:command {client parameters} {
	if {[getbncuser $client admin]} {
		if {[string equal -nocase [lindex $parameters 0] "defaultsettings"] && ([llength $parameters] <= 1)} {
			bncreply "Default settings are:"
			foreach setting $::defaultoptions {
				if {[bncgetglobaltag $setting] == ""} {
					bncreply "$setting: (not set)"
				} elseif  {[bncgetglobaltag $setting] == 0} {
					bncreply "$setting: No"
				} elseif {[bncgetglobaltag $setting] == 1} {
					bncreply "$setting: Yes"
				} else  {
				bncreply "$setting: [bncgetglobaltag $setting]"
				}
			}
			bncreply "-- End of DEFAULTSETTINGS."
			bncreply "Syntax: DEFAULTSETTINGS <set/unset> <setting> <value>"
			haltoutput
			return
		}
		if {[string equal -nocase [lindex $parameters 0] "defaultsettings"] && [string equal -nocase [lindex $parameters 1] "set"]} {
			set setting [lindex $parameters 2]
			set value [lrange $parameters 3 end]
			if {[lsearch -exact $::defaultoptions $setting] == -1} {
				bncreply "Unknown setting."
				haltoutput
			} else  {
				if {$value == "on" || $value == "yes"} {
					set value 1
				} elseif {$value == "off" || $value == "no"} {
					set value 0
				}
				bncsetglobaltag $setting $value
				bncreply "Done."
				haltoutput
			}
			return
		}
		if {[string equal -nocase [lindex $parameters 0] "defaultsettings"] && [string equal -nocase [lindex $parameters 1] "unset"]} {
			set setting [lindex $parameters 2]
			if {[lsearch -exact $::defaultoptions $setting] == -1} {
				bncreply "Unknown setting."
				haltoutput
			} else  {
				bncsetglobaltag $setting ""
				bncreply "Done."
				haltoutput
			}
			return
		}
		if {[string equal -nocase [lindex $parameters 0] "help"]} {
			bncaddcommand defaultsettings KHAdmin "sets default usersettings for when a user is created." "Syntax: DEFAULTSETTINGS <set/unset> <setting> <value> \nSets default usersettings which wil be set on usercreation."
			return
		}
		if {[string equal -nocase [lindex $parameters 0] "defaultsettings"]} {
		bncreply "Syntax: DEFAULTSETTINGS <set/unset> <setting> <value>"
		haltoutput
		}
	}
}
