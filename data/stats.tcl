proc csvRowSplit {row} {
 set result {}
 foreach {_ unquoted quoted} [regexp -all -inline -expanded {,((?:[^,\"]|"")*)|,\"((?:[^\"]|"")*)\"} ,$row] {
  if {$quoted ne {}} {
   lappend result [string map {\"\" \"} $quoted]
  } else {
   lappend result [string map {\"\" \"} $unquoted]
  }
 }
 return $result
}

set pts {"Blocked Shot" "Faceoff" "Giveaway" "Hit" "Missed Shot" "Penalty" "Shot" "Takeaway" "Goal"}

set fp [open game.csv]
gets $fp line
while {[gets $fp line] >= 0} {
 set e [csvRowSplit $line]
 set g_id [lindex $e 0]
 set g_h [lindex $e 5]
 set g_a [lindex $e 6]
 set G($g_id) [list $g_h $g_a]
}
close $fp

set fp [open game_plays.csv]
gets $fp line
set label [split $line ","]
set r_idx 0
while {[gets $fp line] >= 0} {
 set e [csvRowSplit $line]
 puts -nonewline $r_idx\r; incr r_idx
 if {[llength $e] != [llength $label]} {error "$e"}
 set g_id [lindex $e 1]
 lassign $G($g_id) t_h t_a
 set pt [lindex $e 5]; set pti [lsearch $pts $pt]; set ptt [lindex $e 3]
 set periodID "[lindex $e 1]_[lindex $e 9]"
 if {![info exists periodFeats($periodID)]} {set periodFeats($periodID) {0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0}}
 if {$pti != -1} {
  set pti [expr $pti * 2]
  if {$ptt == $t_a} {incr pti}
  set tmp [lindex $periodFeats($periodID) $pti]
  lset periodFeats($periodID) $pti [expr {$tmp + 1}]
  #puts "\n$pt\t$pti\t$periodID\t$ptt\t$tmp\n$G($g_id)\n$periodFeats($periodID)"
 }
}
puts "\nProcessed game_plays.csv"

parray periodFeats

set fo [open periodStats.txt w+]
puts $fo "periodID, period initial goal differential, blocked shots away, blocked shots home, faceoff away, faceoff home, giveaway away, giveaway home, hit away, hit home, missed shot away, missed shot home, penalty away, penalty home, shot away, shot home, takeaway away, takeaway home, period final goal differential"
foreach p [lsort [array names periodFeats]] {
 set fgd [expr [lindex $periodFeats($p) 17] - [lindex $periodFeats($p) 16]]
 regexp {^([0-9]+)_([123])} $p blah pid pn
 if {$pn == 0} {set igd 0} else {
  set iga 0; set igh 0
  while {$pn > 1} {
   incr pn -1
   incr iga [lindex $periodFeats(${pid}_${pn}) 16]
   incr igh [lindex $periodFeats(${pid}_${pn}) 17]
  }
  set igd [expr $igh - $iga]
 }
 puts $fo "$p,$igd,[regsub -all " " [join [lrange $periodFeats($p) 0 15]] ","],$fgd"
}
close $fo