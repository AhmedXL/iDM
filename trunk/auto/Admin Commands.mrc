on $*:TEXT:/^[!.]admin$/Si:#idm.staff: {
  if ($db.get(admins,position,$address($nick,3)) && $me == iDM) {
    notice $nick $s1(Admin commands:) $s2(!part chan, !addsupport nick !chans, !active, !join bot chan, !rehash, !ignoresync, !amsg, $&
      !(show/rem)dm nick, !define/increase/decrease account item amount !rename oldnick newnick $&
      ) $s1(Support commands:) !(r)suspend nick $s2(!(r)ignore nick/host, !(r)blist chan, !viewitems !(give/take)item nick !whois chan)  $s1(Helper commands:) $s2(!cignore nick/host, !csuspend nick, !cblist chan, !info nick)
  }
}

on $*:TEXT:/^[!.]Bot-ON$/Si:#idm.staff: {
  if ($db.get(admins,position,$address($nick,3))) {
    if ($me == iDM[OFF]) { nick iDM }
  }
}

on $*:TEXT:/^[!.]addsupport .*/Si:#idm.staff: {
  tokenize 32 $remove($1-,$chr(36),$chr(37))
  if ($db.get(admins,position,$address($nick,3)) == admins && $me == iDM) {
    if (!$address($2,3)) { notice $nick Sorry but i couldnt find the host of $2.  Syntax: !addsupport <nick> | halt }
    msg $chan $s2($2) has been added to the support staff list with $address($2,3)
    db.set admins support $address($2,3) true
  }
}

on $*:TEXT:/^[!.](r|c)?(bl(ist)?) .*/Si:#idm.staff,#idm.support: {
  tokenize 32 $remove($1-,$chr(36),$chr(37))
  if (!$db.get(admins,position,$address($nick,3))) { if (?c* !iswm $1 || $nick isreg $chan || $nick !ison $chan) { halt }  }
  if ((#* !iswm $2) || (!$2)) { notice $nick Syntax !(c|r)bl <channel> [reason] | halt }
  if ((?bl* iswm $1) && ($3)) { if ($chan($2).status) { part $2 This channel has been blacklisted } }
  if ($me == iDM) {
    if (!$2) { notice $nick Syntax !(c|r)bl <channel> | halt }
    if (?c* iswm $1) || (?r* iswm $1) {
      db.hget checkban blist $2 who time reason
      if ($hget(checkban,reason)) { notice $nick $logo(BANNED) Admin $s2($hget(checkban,who)) banned $s2($2) at $s2($hget(checkban,time)) for $s2($v1) }
      else { notice $nick $logo(BANNED) Channel $s2($2) is $s2(not) banned. | halt }
      if (?r* iswm $1) {
        db.remove blist $2
        notice $nick $logo(BANNED) Channel $2 has been removed from blist
      }
    }
    else {
      if (!$3) { notice $nick Syntax !bl <channel> <reason> | halt }
      db.set blist who $2 $nick
      db.set blist reason $2 $3-
      notice $nick $logo(BANNED) Channel $2 has been added to blist
    }
  }
}

on $*:TEXT:/^[!.](r|c)?(i(gnore|list)) .*/Si:#idm.staff,#idm.support: {
  if ($me != iDM) { halt }
  if (!$db.get(admins,position,$address($nick,3))) { if (?c* !iswm $1 || $nick isreg $chan || $nick !ison $chan) { halt } }
  putlog perform banman $nick $chan $1 $iif($2-,$2-,$nick)
}
alias banman {
  var %nick $1 | var %chan $2 | tokenize 32 $remove($3-,$chr(36),$chr(37))
  if (((((@ isin $2) && (*!*@ !isin $2)) || (!$3)) && (?i* iswm $1)) || ($chr(35) isin $2)) {
    if ($me == idm) { notice %nick $logo(BANNED) 4Syntax Error: !ignore <nick> <reason> (or !ignore *!*@<host> <reason>) - Use !suspend to disable an account. }
    halt
  }
  elseif (@ !isin $2) {
    if ($address($2,2)) { tokenize 32 $1 $v1 $iif($3,$2 - $3-) }
    else {
      if ($me == idm) { hostcallback %nick $2 putlog perform banman %nick %chan $1 ~host~ $iif($3,$2 - $3-) }
      halt
    }
  }
  else { tokenize 32 $1 $2 $3- }
  if ($me == iDM) {
    if (!$2) { notice %nick $logo(BANNED) 4Syntax Error: !(c|r)ignore <nickname> (or !(c|r)ignore <host>) | halt }
    if (?c* iswm $1) || (?r* iswm $1) {
      db.hget checkban ilist $2 who time reason
      if ($hget(checkban,reason)) { notice %nick $logo(BANNED) Admin $s2($hget(checkban,who)) banned $s2($2) at $s2($hget(checkban,time)) for $s2($v1) }
      else { notice %nick $logo(BANNED) User $s2($2) is $s2(not) banned. | halt }
      if (?r* iswm $1) {
        db.remove ilist $2
        notice %nick $logo(BANNED) User $2 has been removed from ignore
      }
    }
    else {
      db.set ilist who $2 %nick
      db.set ilist reason $2 $3-
      notice %nick $logo(BANNED) User $2 has been added to ignore
    }
  }
  if (?i* iswm $1) { ignore $2 }
  elseif (?r* iswm $1) { ignore -r $2 }
}
alias hostcallback {
  if ($1 != 0) { notice $1 Warning: Could not find hostname cached, attempting hostname lookup for $2 $+ , please wait. }
  set %userhost. [ $+ [ $2 ] ] $3-
  userhost $2
}
raw 302:*: {
  if (%userhost. [ $+ [ $gettok($2,1,61) ] ]) {
    unset %userhost. [ $+ [ $gettok($2,1,61)] ]
    $replace($v1,~host~,*!*@ $+ $gettok($2,2,64))
  }
}

on $*:TEXT:/^[!.]part .*/Si:#: {
  if ($db.get(admins,position,$address($nick,3)) == admins) {
    if ($left($2,1) == $chr(35)) && ($me ison $2) {
      part $2 Part requested by $position($nick) $nick $+ . $iif($3,$+($chr(91),$3-,$chr(93)))
      notice $nick I have parted $2
    }
  }
}

on $*:TEXT:/^[!.]chans$/Si:#idm.staff,#idm.support: {
  if ($db.get(admins,position,$address($nick,3)) == admins) {
    notice $nick I am on $chan(0) channels $+ $iif($chan(0) > 1,: $chans)
  }
}
alias chans {
  var %b,%a 1
  while (%a <= $chan(0)) {
    if ($me isop $chan(%a)) var %b %b $+(@,$chan(%a))
    if ($me ishop $chan(%a)) var %b %b $+($chr(37),$chan(%a))
    if ($me isvoice $chan(%a)) var %b %b $+(+,$chan(%a))
    if ($me isreg $chan(%a)) var %b %b $chan(%a)
    inc %a
  }
  $iif($isid,return,echo -a) %b
}

on $*:TEXT:/^[!.@]active$/Si:*: {
  if ($db.get(admins,position,$address($nick,3)) == admins) {
    var %a 1
    while (%a <= $chan(0)) {
      if (%dmon [ $+ [ $chan(%a) ] ]) && (($chan(%a) == #idm) || ($chan(%a) == #idm.Staff)) && ($me != iDM) { inc %a }
      if (%dmon [ $+ [ $chan(%a) ] ]) { var %b %b $chan(%a) }
      inc %a
    }
    if (%b) { $iif($left($1,1) == @,msg #,notice $nick) $var(%dmon*,0) active DM $+ $iif($var(%dmon*,0) != 1,s) - %b }
    else { $iif($left($1,1) == @,msg #,notice $nick) $var(%dmon*,0) active DM $+ $iif($var(%dmon*,0) != 1,s) - I'm not hosting any DMs. }
  }
}

on $*:TEXT:/^[!.]join .*/Si:*: {
  if ($db.get(admins,position,$address($nick,3)) == admins) {
    if ($left($3,1) != $chr(35)) { halt }
    if (!$3) { notice $nick To use the join command, type !join botname channel. | halt }
    if ($2 == $me) {
      set %forcedj. [ $+ [ $3 ] ] true
      join $3
      .timer 1 1 msg $3 $logo(JOIN) I was requested to join this channel by $position($nick) $nick $+ . $chr(91) $+ Bot tag - $s1($bottag) $+ $chr(93)
    }
  }
}

on $*:TEXT:/^[!.](r|c)?suspend.*/Si:#idm.staff,#idm.support: {
  if ($me != iDM) { return }
  if ($db.get(admins,position,$address($nick,3))) {
    if (!$2) { notice $nick Syntax: !(un)suspend <nick> [reason]. | halt }
    if ((?c* iswm $1) || (?r* iswm $1)) {
      db.hget checkban ilist $2 who time reason
      if ($hget(checkban,reason)) { notice $nick $logo(BANNED) Admin $s2($hget(checkban,who)) suspended $s2($2) at $s2($hget(checkban,time)) for $s2($v1) }
      elseif (!$db.get(user,banned,$2)) { notice $nick $logo(BANNED) User $s2($2) is $s2(not) suspended. | halt }

      if (?r* iswm $1) {
        db.exec UPDATE `user` SET banned = 0 WHERE user = $db.safe($2)
        if ($mysql_affected_rows(%db) !== -1) {
          notice $nick Restored account $2 to its original status.

          }
        else { notice $nick Couldn't find account $2 }
      }
    }
    else {
      if (!$3) { notice $nick You need to supply a reason when suspending.  Syntax: !(un)suspend <nick> [reason]. | halt }

      db.exec UPDATE `user` SET banned = 1 WHERE user = $db.safe($2)
      if ($mysql_affected_rows(%db) !== -1) {
        db.set ilist who $2 %nick
        db.set ilist reason $2 $3-
        notice $nick Removed account $2 from the top scores.
        }
      else { notice $nick Couldn't find account $2 }
    }
  }
}

on $*:TEXT:/^[!.]rename.*/Si:#idm.staff: {
  if ($me != iDM) { return }
  if ($db.get(admins,position,$address($nick,3)) == admins) {
    if (!$3) { notice $nick To use the rename command, type !rename oldnick newnick. | halt }
    if ($renamenick($2,$3,$nick)) { notice $nick Renamed account $2 to $3 }
    else { notice $nick Renaming account $2 failed as $3 already exists (if this is an error you could try using !delete on one of the accounts)  }
  }
}

on $*:TEXT:/^[!.]delete.*/Si:#idm.staff: {
  if ($me != iDM) { return }
  if ($db.get(admins,position,$address($nick,3)) == admins) {
    if (!$2) { notice $nick To use the delete command, type !delete nick | halt }
    if ($3 != $md5($2)) { notice $nick To confirm deletion type !delete $2 $md5($2) | halt }
    if ($deletenick($2,$nick)) { notice $nick Deleted account $2 }
    else { notice $nick Couldn't find account $2 }
  }
}

alias renamenick {
  if ($3) { var %target = notice $3 $logo(RENAME) }
  else { var %target = echo -s RENAME $1 to $2 - }
  db.exec UPDATE `user` SET user = $db.safe($2) WHERE user = $db.safe($1)
  if ($mysql_affected_rows(%db) === -1) { return 0 }
  var %target = %target Updated Rows: $mysql_affected_rows(%db) user;
  db.exec UPDATE `equip_item` SET user = $db.safe($2) WHERE user = $db.safe($1)
  var %target = %target $mysql_affected_rows(%db) equip_item;
  db.exec UPDATE `equip_pvp` SET user = $db.safe($2) WHERE user = $db.safe($1)
  var %target = %target $mysql_affected_rows(%db) equip_pvp;
  db.exec UPDATE `equip_armour` SET user = $db.safe($2) WHERE user = $db.safe($1)
  var %target = %target $mysql_affected_rows(%db) equip_armour;
  db.exec UPDATE `equip_staff` SET user = $db.safe($2) WHERE user = $db.safe($1)
  var %target = %target $mysql_affected_rows(%db) equip_staff;
  db.exec UPDATE `clantracker` SET owner = $db.safe($2) WHERE owner = $db.safe($1)
  %target $mysql_affected_rows(%db) clans.
  return 1
}

alias deletenick {
  if ($len($1) < 1) { return }
  if ($2) { var %target = notice $2 $logo(DELETE) }
  else { var %target = echo -s DELETE $1 - }
  db.exec DELETE FROM `user` WHERE user = $db.safe($1)
  if ($mysql_affected_rows(%db) === -1) { return 0 }
  var %target = %target Deleted Rows: $mysql_affected_rows(%db) user;
  db.exec DELETE FROM `equip_item` WHERE user = $db.safe($1)
  var %target = %target $mysql_affected_rows(%db) equip_item;
  db.exec DELETE FROM `equip_pvp` WHERE user = $db.safe($1)
  var %target = %target $mysql_affected_rows(%db) equip_pvp;
  db.exec DELETE FROM `equip_armour` WHERE user = $db.safe($1)
  var %target = %target $mysql_affected_rows(%db) equip_armour;
  db.exec DELETE FROM `equip_staff` WHERE user = $db.safe($1)
  var %target = %target $mysql_affected_rows(%db) equip_staff.
  if ($isclanowner($1)) {
    deleteclan $getclanname($1)
    var %target = %target Also deleted one clan.
  }
  return 1
}

On $*:TEXT:/^[!@.]((de|in)crease|define).*/Si:#idm.Staff: {
  if ($db.get(admins,position,$address($nick,3)) == admins && $me == iDM) {
    if (!$4 || $4 !isnum) { goto error }
    if (?increase iswm $1) { var %sign + }
    elseif (?decrease iswm $1) { var %sign - }
    elseif (?define iswm $1) { var %sign = }
    else { goto error }
    var %table = user
    if ($storematch($3) != 0) {
      var %table = $gettok($v1,3,32)
      var %item = $gettok($v1,2,32)
    }
    elseif ($ispvp($3)) {
      var %table = equip_pvp
      var %item = $3
    }
    elseif ($3 == money) || ($3 == wins) || ($3 == losses) {
      var %item = $3
    }
    else { notice $nick Couldnt find item matching $3 $+ . Valid: money/wins/losses/vlong/vspear/statius/mjavelin + !store items. | halt }
    if (%sign == =) { db.set %table %item $2 $4 }
    else { db.set %table %item $2 %sign $4 }
    msg $chan $logo(ACCOUNT) User $2 has been updated. %item = $db.get(%table, %item, $2)
    return
    :error
    notice $nick Syntax !define/increase/decrease <account> <item> <amount>
  }
}

on $*:TEXT:/^[!.]rehash$/Si:#idm.staff: {
  if ($me != iDM) { return }
  if ($db.get(admins,position,$address($nick,3)) == admins) {
    rehash.run 0
  }
}

on $*:TEXT:/^[!.]ignoresync$/Si:#idm.staff: {
  if ($me != iDM) { return }
  if ($db.get(admins,position,$address($nick,3)) == admins) {
    ignoresync.run 0
  }
}

on *:TEXT:!amsg*:#idm.staff: {
  if ($db.get(admins,position,$address($nick,3)) == admins) {
    if (!$2) { notice $nick Syntax: !amsg 03message | halt }
    if ($+(*,$nick,*) iswm $2-) { notice $nick $logo(ERROR) Please dont add your name in the amsg since it adds your name to the amsg automatically. | halt }
    if ($me == iDM) { amsg $logo(AMSG) $2- 07[03 $+ $nick $+ 07] | halt }
    var %x = 1
    while ($chan(%x)) {
      if ($chan(%x) != #idm && $chan(%x) != #idm.Staff) {
        msg $chan(%x) $logo(AMSG) $2- 07[03 $+ $nick $+ 07]
      }
      inc %x
    }
  }
}

on *:TEXT:!whois*:#: {
  if ($db.get(admins,position,$address($nick,3))) {
    if (!$2) { if ($me == idm ) { notice $nick Please specify a channel } | halt }
    if ($me ison $2) {
      if (%p1 [ $+ [ $2 ] ]) && (%p2 [ $+ [ $2 ] ]) { notice $nick $logo(STATUS) DM'ers: Player1: $s1($address(%p1 [ $+ [ $2 ] ],0)) and Player2: $s1($address(%p2 [ $+ [ $2 ] ],0)) $+ . }
      else { notice $nick $logo(STATUS) There is no dm in $2 $+ . }
    }
  }
}

on $*:TEXT:/^[!.`](rem|rmv|no)dm/Si:#: {
  if ($db.get(admins,position,$address($nick,3))) {
    if (!$db.get(user,indm,$2)) { notice $nick $logo(ERROR) $s1($2) is not DMing at the moment. | halt }
    db.set user indm $2 0
    notice $nick $logo(REM-DM) $s1($2) is no longer DMing.
  }
}

on $*:TEXT:/^[!@.]info .*/Si:#idm.Staff,#idm.Support: {
  if ($me == iDM) {
    if (!$db.get(admins,position,$address($nick,3))) { if ($nick isreg $chan || $nick !ison $chan) { halt } }
    db.hget userinfo user $$2
    $iif($left($1,1) == @,msg #,notice $nick) $logo(Acc-Info) User: $s2($2) Money: $s2($iif($hget(userinfo,money),$price($v1),0)) W/L: $s2($iif($hget(userinfo,wins),$bytes($v1,db),0)) $+ / $+ $s2($iif($hget(userinfo,losses),$bytes($v1,db),0)) InDM?: $iif($hget(userinfo,indm),3YES,4NO) Excluded?: $iif($hget(userinfo,exclude),3YES,4NO) Logged-In?: $iif($hget(userinfo,login),03 $+ $gmt($v1,dd/mm HH:nn:ss) $+ ,4NO) Last Address?: $iif($hget(userinfo,address),3 $+ $v1 $+ ,4NONE)
    ignoreinfo $iif($2,$2 $2,$nick $nick) $iif($left($1,1) == @,msg #,notice $nick) $logo(Acc-Info)
  }
}
alias ignoreinfo {
  var %reply $3-
  tokenize 32 $1 $2
  if (@ !isin $2) {
    if ($address($2,2)) { tokenize 32 $1 $v1 }
    else { hostcallback 0 $1 ignoreinfo $1 ~host~ %reply | halt }
  }
  db.hget checkban ilist $2 who time reason
  if ($hget(checkban,reason)) { var %reply %reply $s1($2) $2(was banned) by $hget(checkban,who) for $hget(checkban,reason) - }
  elseif ($ignore($2)) { var %reply %reply $s1($2) $s2(is banned) on the bot but not in the db - }
  else { var %reply %reply $s1($2) is not ignored - }
  db.hget checkban ilist $1 who time reason
  if ($hget(checkban,reason)) { var %reply %reply $s1($1 $+ !*@*) $s2(was suspended) by $hget(checkban,who) for $hget(checkban,reason) }
  else { var %reply %reply $s1($1 $+ !*@*) is not suspended }
  %reply
}
