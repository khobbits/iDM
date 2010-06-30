# shroudBNC - an object-oriented framework for IRC
# Copyright (C) 2005 Gunnar Beutner
#
# Modified By Worrum
#
# * added password restriction
# * added /sbnc vhostwho command, to give userstatistic per vhost
# * fixed vhosts with limit 0 (private) being visible to admins
# * fixed vhosts/vhost selecting looking at the _actual_ connection
#   which are in use, and not just given with /sbnc set (and thus not actually used yet)
# * fixed proper _free_ vhost selection on usercreate (it doesnt pick 0 limit, or passworded
#   anymore) if all vhosts are full, vhost '0' is set, disallowing the user to connect.
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

internalbind command vhost:command
internalbind usrcreate vhost:newuser

# Give regular user access to any vhost being not 0 in limit password is default set to root (changable through /sbnc vhostoverride)
if {[bncgetglobaltag vhost.override] == ""} {
	bncsetglobaltag vhost.override "root"
}


proc vhost:host2ip {host} {
	set vhosts [bncgetglobaltag vhosts]

	if {[lsearch -exact [info procs] "vhost_hack:getadditionalvhosts"] != -1} {
		set vhosts [concat $vhosts [vhost_hack:getadditionalvhosts]]
	}

	foreach vhost $vhosts {
		if {[string equal -nocase [lindex $vhost 2] $host]} {
			return [lindex $vhost 0]
		}
	}

	return $host
}

proc vhost:ip2host {ip} {
	set vhosts [bncgetglobaltag vhosts]
	set ip [vhost:expandipv6 $ip]
	if {[lsearch -exact [info procs] "vhost_hack:getadditionalvhosts"] != -1} {
		set vhosts [concat $vhosts [vhost_hack:getadditionalvhosts]]
	}

	foreach vhost $vhosts {
		if {[string equal -nocase [lindex $vhost 0] $ip]} {
			return [lindex $vhost 2]
		}
	}

	return $host
}

proc vhost:countvhost {ip} {
	set count 0

	set ip [vhost:host2ip $ip]

	foreach user [bncuserlist] {
		if {![getbncuser $user hasserver]} {
			if {[string equal -nocase [getbncuser $user vhost] $ip]} {
				incr count
			}
		} else  {
			if {[string equal -nocase [vhost:expandipv6 [getbncuser $user localip]] $ip]} {
				incr count
			}
		}
	}

	return $count
}

proc vhost:vhostusers {ip} {
	set count ""
	set listcount ""
	set ip [vhost:host2ip $ip]

	foreach user [lsort [bncuserlist]] {
		if {![getbncuser $user hasserver]} {
			if {[string equal -nocase [getbncuser $user vhost] $ip]} {
				lappend count $user
			}
		} else  {
			if {[string equal -nocase [vhost:expandipv6 [getbncuser $user localip]] $ip]} {
				lappend count $user
			}
		}
		if {([llength $count] == 10)} {
			lappend listcount $count
			set count ""
		}
	}
	if {([llength $count] > 0)} {
		lappend listcount $count
	}
	if {$listcount == ""} { set listcount "None"	}
	return $listcount
}

proc vhost:expandipv6 {ip} {
	if {[string match *:* $ip] == 0} { return $ip }
	set newip ""
	set ip [string map {{::} {:ZZZZ:}} $ip]
	foreach x [split $ip {:}] {
		lappend newip [string range "0000$x" end-3 end]
	}
	set newip [join $newip {:}]
	set i 0
	while {[llength [split $newip {:}]] < 8} {
		incr i
		if {$i > 10} { return 0 }
		set newip [string map {{:ZZZZ:} {:ZZZZ:ZZZZ:}} $newip]
	}
	return [string map {{Z} {0}} $newip]
}

proc vhost:getlimit {ip} {
	set vhosts [bncgetglobaltag vhosts]
	set ip [vhost:host2ip $ip]

	if {[lsearch -exact [info procs] "vhost_hack:getadditionalvhosts"] != -1} {
		set vhosts [concat $vhosts [vhost_hack:getadditionalvhosts]]
	}

	set res [lsearch -inline $vhosts "$ip *"]

	if {$res != ""} {
		return [lindex $res 1]
	} else {
		return -1
	}
}

proc vhost:getpassword {ip} {
	set vhosts [bncgetglobaltag vhosts]
	set ip [vhost:host2ip $ip]

	if {[lsearch -exact [info procs] "vhost_hack:getadditionalvhosts"] != -1} {
		set vhosts [concat $vhosts [vhost_hack:getadditionalvhosts]]
	}

	set res [lsearch -inline $vhosts "$ip *"]

	if {$res != ""} {
		return [lindex $res 3]
	} else {
		return 0
	}
}


proc vhost:isip {host} {
	return [regexp -nocase -- {^(^(([0-9A-F]{1,4}(((:[0-9A-F]{1,4}){5}::[0-9A-F]{1,4})|((:[0-9A-F]{1,4}){4}::[0-9A-F]{1,4}(:[0-9A-F]{1,4}){0,1})|((:[0-9A-F]{1,4}){3}::[0-9A-F]{1,4}(:[0-9A-F]{1,4}){0,2})|((:[0-9A-F]{1,4}){2}::[0-9A-F]{1,4}(:[0-9A-F]{1,4}){0,3})|(:[0-9A-F]{1,4}::[0-9A-F]{1,4}(:[0-9A-F]{1,4}){0,4})|(::[0-9A-F]{1,4}(:[0-9A-F]{1,4}){0,5})|(:[0-9A-F]{1,4}){7}))$|^(::[0-9A-F]{1,4}(:[0-9A-F]{1,4}){0,6})$)|^::$)|^((([0-9A-F]{1,4}(((:[0-9A-F]{1,4}){3}::([0-9A-F]{1,4}){1})|((:[0-9A-F]{1,4}){2}::[0-9A-F]{1,4}(:[0-9A-F]{1,4}){0,1})|((:[0-9A-F]{1,4}){1}::[0-9A-F]{1,4}(:[0-9A-F]{1,4}){0,2})|(::[0-9A-F]{1,4}(:[0-9A-F]{1,4}){0,3})|((:[0-9A-F]{1,4}){0,5})))|([:]{2}[0-9A-F]{1,4}(:[0-9A-F]{1,4}){0,4})):|(25[0-5]|2[0-4][0-9]|[0-1]?[0-9]{0,2})\.){3}(25[0-5]|2[0-4][0-9]|[0-1]?[0-9]{0,2})$$} $host]
}

proc vhost:command {client parameters} {
	if {![getbncuser $client admin] && [string equal -nocase [lindex $parameters 0] "set"] && [string equal -nocase [lindex $parameters 1] "vhost"]} {
		if {[lsearch -exact [info commands] "lock:islocked"] != -1} {
			if {![string equal [lock:islocked [getctx] "vhost"] "0"]} { return }
		}
		if {[lrange $parameters 2 end] == ""} {
			bncreply "Syntax: set vhost <ip> \[<password>\]"
			haltoutput
			return
		}
		if {![vhost:isip [lindex $parameters 2]]} {
			bncreply "You have to specify a valid IP address."

			haltoutput
			return
		}
		set limit [vhost:getlimit [lindex $parameters 2]]

		if {$limit <= 0 } {
			bncreply "Sorry, you may not use this IP address/hostname."

			haltoutput
			return
		} elseif {[vhost:countvhost [lindex $parameters 2]] >= $limit} {
			bncreply "Sorry, the IP address [lindex $parameters 2] is already being used by [vhost:countvhost [lindex $parameters 2]] users. A maximum number of [vhost:getlimit [lindex $parameters 2]] users may use this IP address."

			haltoutput
			return
		}
		if {!([vhost:getpassword [lindex $parameters 2]] == "")} {
			if {([lindex $parameters 3] == "")} {
				haltoutput
				bncreply "This vhost requires a password, use set vhost <ip> <password>"
				return
			}
			if {!([vhost:getpassword [lindex $parameters 2]] == [lindex $parameters 3]) && !([bncgetglobaltag vhost.override] == [lindex $parameters 3])} {
				haltoutput
				bncreply "Sorry, the entered password is incorrect"
				return
			}
		}
	}

	set vhosts [bncgetglobaltag vhosts]

	if {[lsearch -exact [info procs] "vhost_hack:getadditionalvhosts"] != -1} {
		set vhosts [concat $vhosts [vhost_hack:getadditionalvhosts]]
	}

	if {[string equal -nocase [lindex $parameters 0] "vhosts"]} {
		foreach vhost $vhosts {
			if {[getbncuser $client admin]} {
				if {!([vhost:getpassword [lindex $vhost 0]] == "")} {
					bncreply "[lindex $vhost 0] ([lindex $vhost 2]) [vhost:countvhost [lindex $vhost 0]]/[vhost:getlimit [lindex $vhost 0]] connections \[password required: [vhost:getpassword [lindex $vhost 0]]\]"
				} else  {
					bncreply "[lindex $vhost 0] ([lindex $vhost 2]) [vhost:countvhost [lindex $vhost 0]]/[vhost:getlimit [lindex $vhost 0]] connections"
				}
			} elseif {[vhost:getlimit [lindex $vhost 0]] > 0} {
				if {[vhost:countvhost [lindex $vhost 0]] >= [vhost:getlimit [lindex $vhost 0]]} {
					set status "full"
				} else {
					set status "not full"
				}
				if {!([vhost:getpassword [lindex $vhost 0]] == "")} {
					lappend status "\[passworded\]"
				}
				bncreply "[lindex $vhost 0] ([lindex $vhost 2]) \[[join $status]\]"
			}
		}

		bncreply "-- End of VHOSTS."

		haltoutput
	}
	if {[string equal -nocase [lindex $parameters 0] "vhostwho"] && [getbncuser $client admin]} {
		if {[lindex $parameters 1] == ""} {
			foreach vhost $vhosts {
				if {[vhost:getlimit [lindex $vhost 0]] > -1} {
					bncreply "[lindex $vhost 0] ([lindex $vhost 2]) usage: ([vhost:countvhost [lindex $vhost 0]]/[vhost:getlimit [lindex $vhost 0]])"
					set userlist [vhost:vhostusers [lindex $vhost 0]]
					foreach group $userlist { bncreply "users: $group" }
				}
			}
			bncreply "-- End of VHOSTS."
			haltoutput
			return
		} else {
			set vhost [lindex $parameters 1]
			if {[vhost:getlimit $vhost] == "-1"} { bncreply "No such vhost." ; haltoutput ; return }
			set vhost [lsearch -inline $vhosts "$vhost *"]
			bncreply "[lindex $vhost 0] ([lindex $vhost 2]) usage: ([vhost:countvhost [lindex $vhost 0]]/[vhost:getlimit [lindex $vhost 0]])"
			set userlist [vhost:vhostusers [lindex $vhost 0]]
			foreach group $userlist { bncreply "users: $group" }
			haltoutput
		}
	}
	if {[getbncuser [getctx] admin] && [string equal -nocase [lindex $parameters 0] "addvhost"]} {
		set ip [lindex $parameters 1]
		set limit [lindex $parameters 2]
		set host [lindex $parameters 3]
		set password [lindex $parameters 4]

		if {$host == ""} {
			bncreply "Syntax: ADDVHOST <ip> <limit> <host> \[password\]"

			haltoutput
			return
		}

		if {![vhost:isip $ip]} {
			bncreply "You did not specify a valid IP address."

			haltoutput
			return
		}

		if {![string is integer $limit]} {
			bncreply "You did not specify a valid limit."

			haltoutput
			return
		}

		if {[catch [list vhost:addvhost $ip $limit $host $password] error]} {
			bncreply $error
		} else {
			bncreply "Done."
		}

		haltoutput
	}

	if {[getbncuser [getctx] admin] && [string equal -nocase [lindex $parameters 0] "changevhost"]} {
		set ip [lindex $parameters 1]
		set limit [lindex $parameters 2]
		set host [lindex $parameters 3]
		set password [lindex $parameters 4]

		if {$host == ""} {
			bncreply "Syntax: CHANGEVHOST <ip> <limit> <host> \[password\]"

			haltoutput
			return
		}

		if {![vhost:isip $ip]} {
			bncreply "You did not specify a valid IP address."

			haltoutput
			return
		}

		if {![string is integer $limit]} {
			bncreply "You did not specify a valid limit."

			haltoutput
			return
		}
		if {[catch [list vhost:delvhost $ip] error]} {
			bncreply $error
			haltoutput
			return
		}
		if {[catch [list vhost:addvhost $ip $limit $host $password] error]} {
			bncreply $error
		} else {
			bncreply "Done."
		}
		haltoutput
	}

	if {[getbncuser [getctx] admin] && [string equal -nocase [lindex $parameters 0] "delvhost"]} {
		set ip [vhost:host2ip [lindex $parameters 1]]

		if {$ip == ""} {
			bncreply "Syntax: DELVHOST <ip>"

			haltoutput
			return
		}

		if {[catch [list vhost:delvhost $ip] error]} {
			bncreply $error
		} else {
			bncreply "Done."
		}

		haltoutput
	}

	if {[getbncuser [getctx] admin] && [string equal -nocase [lindex $parameters 0] "vhostoverride"]} {
		if {[lindex $parameters 1] == ""} {
			bncreply "Syntax: VHOSTOVERRIDE <password>"
			bncreply "The current password is: [bncgetglobaltag vhost.override]"

			haltoutput
			return
		} else  {
			bncsetglobaltag vhost.override [lindex $parameters 1]
			bncreply "Done."
		}
		haltoutput
	}

	if {[string equal -nocase [lindex $parameters 0] "help"]} {
		if {[getbncuser [getctx] admin]} {
			bncaddcommand addvhost Vhost "adds a new vhost" "Syntax: addvhost ip limit host \[password\]\nAdds a new vhost."
			bncaddcommand delvhost Vhost "removes a vhost" "Syntax: delvhost ip\nRemoves a vhost."
			bncaddcommand vhostoverride Vhost "sets the vhost override password" "Syntax: vhostoverride password \nSets the vhost override password which allows regular users to use any passworded vhost, using this password."
			bncaddcommand vhostwho Vhost "list vhostusage" "Syntax: vhostwho \[vhost\]\n view the list, or select just a single ip/vhost"
			bncaddcommand changevhost Vhost "ability to change an existing vhost" "Syntax: changevhost ip limit host \[password\]\nChanges an existing vhost."
			bncaddcommand vhosts Vhost "lists all available vhosts" "Syntax: vhosts\nDisplays a list of all available virtual vhosts."
		} else {
			bncaddcommand vhosts User "lists all available vhosts" "Syntax: vhosts\nDisplays a list of all available virtual vhosts."
		}
	}
}

proc vhost:findip {} {
	set vhosts [bncgetglobaltag vhosts]

	if {[lsearch -exact [info procs] "vhost_hack:getadditionalvhosts"] != -1} {
		set vhosts [concat $vhosts [vhost_hack:getadditionalvhosts]]
	}
	set min 0
	set minip 0

	foreach vhost $vhosts {
		if {([lindex $vhost 1] - [vhost:countvhost [lindex $vhost 0]] > $min) && ([vhost:getpassword [lindex $vhost 0]] == "")} {
			set min [expr [lindex $vhost 1] - [vhost:countvhost [lindex $vhost 0]]]
			set minip [lindex $vhost 0]
		}
	}
	return $minip
}

proc vhost:newuser {user} {
	setbncuser $user vhost [vhost:findip]
}

proc vhost:addvhost {ip limit host {password ""}} {
	if {[vhost:getlimit $ip] != -1} {
		return -code error "This vhost has already been added."
	} else {
		if {[string length $limit] == 0 || ![string is integer $limit] || ($limit <0)} {
			return -code error "You need to specify a valid limit."
		}

		if {[string length $ip] == 0} {
			return -code error "You need to specify a valid IP address."
		}

		if {[string length $host] == 0} {
			return -code error "You need to specify a valid hostname."
		}

		set vhosts [bncgetglobaltag vhosts]
		lappend vhosts [list $ip $limit $host $password]
		bncsetglobaltag vhosts $vhosts
	}
}

proc vhost:delvhost {ip} {
	set vhosts [bncgetglobaltag vhosts]
	set ip [vhost:host2ip $ip]
	set i 0
	set found 0

	while {$i < [llength $vhosts]} {
		set vhost [lindex $vhosts $i]

		if {[string equal -nocase $ip [lindex $vhost 0]]} {
			set vhosts [lreplace $vhosts $i $i]
			set found 1
			break
		}

		incr i
	}

	if {$found} {
		bncsetglobaltag vhosts $vhosts
	} else {
		return -code error "There is no such vhost."
	}
}

# iface commands
# +user
# getfreeip
# setvalue vhost
# getvhosts
# +admin
# addvhost ip limit host
# delvhost ip

proc iface-vhost:getfreeip {} {
	return [itype_string [vhost:findip]]
}

if {[info commands "registerifacecmd"] != ""} {
	registerifacecmd "vhost" "getfreeip" "iface-vhost:getfreeip"
}

proc iface-vhost:setvalue {setting value} {
	if {[iface:isoverride]} { return "" }

	if {[lsearch -exact [info commands] "lock:islocked"] != -1} {
		if {![string equal [lock:islocked [getctx] "vhost"] "0"]} { return "" }
	}

	if {![getbncuser [getctx] admin] && [string equal -nocase $setting "vhost"]} {
		set limit [vhost:getlimit $value]
		if {$limit == 0} { return -code error "You may not use this virtual host." }

		set count [vhost:countvhost $value]
		if {$count >= $limit} { return -code error "Sorry, the virtual host $ip is already being used by $count users. Please use another virtual host." }

		setbncuser [getctx] vhost $value
	}

	return ""
}

if {[info commands "registerifacecmd"] != ""} {
	registerifacecmd "vhost" "setvalue" "iface-vhost:setvalue"
}

proc iface-vhost:getvhosts {} {
	set result [itype_list_create]

	if {[lsearch -exact [info procs] "vhost_hack:getadditionalvhosts"] != -1} {
		set vhosts [concat $vhosts [vhost_hack:getadditionalvhosts]]

		foreach vhost $vhosts {
			set vhost_itype [itype_list_strings $vhost]
			itype_list_insert result $vhost_itype
		}
	}

	set vhosts [bncgetglobaltag vhosts]

	foreach vhost $vhosts {
		set vhost_itype [itype_list_strings_args [lindex $vhost 0] [vhost:countvhost [lindex $vhost 0]] [lindex $vhost 1] [lindex $vhost 2]]
		itype_list_insert result $vhost_itype
	}

	itype_list_end $result

	return $result
}

if {[info commands "registerifacecmd"] != ""} {
	registerifacecmd "vhost" "getvhosts" "iface-vhost:getvhosts"
}

proc iface-vhost:addvhost {ip limit host} {
	vhost:addvhost $ip $limit $host

	return ""
}

if {[info commands "registerifacecmd"] != ""} {
	registerifacecmd "vhost" "addvhost" "iface-vhost:addvhost" "access:admin"
}

proc iface-vhost:delvhost {ip} {
	vhost:delvhost $ip

	return ""
}

if {[info commands "registerifacecmd"] != ""} {
	registerifacecmd "vhost" "delvhost" "iface-vhost:delvhost" "access:admin"
}
