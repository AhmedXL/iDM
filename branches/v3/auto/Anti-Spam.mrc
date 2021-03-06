on $*:TEXT:/^[!@.]((end)?dm|stake|top|dmclue|solve|money|status|buy|sell|store|suggest|eat|vspear|vlong|statius|mjavelin|on|off|whip|dds|gmaul|guth|cbow|dbow|dh|[bsaz]gs|ice|blood|surf|d(claws|scim|mace|long|hally)|specpot|(start|add|join|dm)clan|leave|share)(\s\S+)?$/S:#:{
  if ($chan == #idm.staff) { halt }
  if (# == #idm) && ($me != iDM) { halt }
  $iif(%cmdspam. [ $+ [ $nick ] ],inc %cmdspam. [ $+ [ $nick ] ],inc -u4 %cmdspam. [ $+ [ $nick ] ])
  if (%cmdspam. [ $+ [ $nick ] ] >= 6) {
    msgsafe $secondchan $logo(SPAM) $s1(Command) spam detected by $s2($nick) in $s2($chan) $+ . Added to ignore for two minutes.
    notice $nick $logo(SPAM) You are now added to ignore for $s2(TWO minutes) due to spam.
    ignore -u120 $nick 3
    halt
  }
}

on *:TEXT:*:?:{
  if ($nick == -sbnc) { halt }
  close -m $nick
  $iif(%cmdspam. [ $+ [ $nick ] ],inc %cmdspam. [ $+ [ $nick ] ],inc -u4 %cmdspam. [ $+ [ $nick ] ])
  if (%cmdspam. [ $+ [ $nick ] ] >= 6) {
    msgsafe $secondchan $logo(SPAM) $s1(PM) spam detected by $s2($nick) $+ . Added to ignore for two minutes.
    notice $nick $logo(SPAM) You are now added to ignore for $s2(TWO minutes) due to spam.
    ignore -u120 $nick 3
    halt
  }
}

alias ignoresync {
  var %ti $ctime
  .ignore -r
  var %sql = SELECT * FROM `ilist`
  var %result = $db.query(%sql)
  while ($db.query_row_data(%result,user)) {
    var %user = $v1
    if (@ isin %user) { .ignore %user }
  }
  db.query_end %result

  var %sql = SELECT * FROM `admins` WHERE `rank` > '4'
  var %result = $db.query(%sql)
  while ($db.query_row_data(%result,user)) {
    var %user = $v1
    if (@ isin %user) { .ignore -x %user }
  }
  db.query_end %result
  if ($hget(>weapon)) { hfree >weapon }
  msgsafe $secondchan $logo(IgnoreSync) Ignore list synced with server, script took $calc($ctime - %ti) seconds to re-download server ignore list. (Also refreshed weapon cache.)
  var %botnum $right($matchtok($cmdline,-Auto,1,32),1)
  if (*-Startup* iswm $cmdline) { var %botnum 0 }
  if (%botnum == 0) { var %botnum 1 }
  inc %botnum
  putlog perform ignoresync.run %botnum
}

alias ignoresync.run {
  if ($cid != $scon(1)) { halt }
  var %botnum $right($matchtok($cmdline,-Auto,1,32),1)
  if (*-Startup* iswm $cmdline) { var %botnum 0 }
  if (%botnum == $null) { msgsafe #idm.staff $logo(Error) This bot doesn't have a instance number, it wasn't auto started, halting update. }
  if ($1 == %botnum) {
    msgsafe #idm.staff $logo(IgnoreSync) Running ignore sync script in 5 seconds.
    timer -m 1 5000 ignoresync
  }
}
