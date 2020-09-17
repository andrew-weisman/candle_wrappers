namespace eval myextension {
    proc makestatement { x } {
	set doubled [ expr $x * 2 ]
	set hname [info hostname]
	after 5000
	return "$doubled on $hname"
    }
}

package provide myextension 1.0
package require Tcl 8.0
