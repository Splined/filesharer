/-  filesharer
/+  default-agent, dbug, resource, group
|% 
+$  versioned-state
    $%  state-0
    ==
::
+$  state-0  [%0 wl=whitelist:filesharer files=(list file:filesharer)] 
::
+$  card  card:agent:gall
--
::
%-  agent:dbug
=|  state-0
=*  state  -
^-  agent:gall
=<  
|_  =bowl:gall
+*  this  .
    def   ~(. (default-agent this %|) bowl)
    hc    ~(. +> bowl)
::
++  on-init
  ^-  (quip card _this)
  ~&  "filesharer compiled successfully!"
  [~ this]
++  on-poke  
  |=  [=mark =vase]
  ^-  (quip card _this)
  ?+    mark  (on-poke:def mark vase)
      %noun
    ?+    q.vase  (on-poke:def mark vase)
        %print-grps
      =/  grps=(set resource:resource)  ~(scry-groups group bowl)
      ~&  >>  grps  `this
      ::
        %list-tags
      ~&  >>  (nub:hc (flatten:hc (turn files.state |=(a=file:filesharer file-tags.a))))  `this
    ==
    ::
      %filesharer-action
      ~&  >>>  !<(action:filesharer vase)
      =^  cards  state
      (handle-action:hc !<(action:filesharer vase))
      [cards this]
  ==
++  on-arvo  on-arvo:def
++  on-save
  ^-  vase
    !>(state)
++  on-load
  |=  old-state=vase
  ^-  (quip card _this)
  ~&  [dap.bowl %load]
  =/  prev  !<(versioned-state old-state)
  ?-  -.prev
      %0
      ~&  >>>  '%0'
      `this(state prev)
  ::
  ==
++  on-watch
  |=  =path
  ^-  (quip card _this)
  =/  tag-list=(list @tas)  (nub:hc (flatten:hc (turn files.state |=(a=file:filesharer file-tags.a))))
  ?.  (check-wl:hc src.bowl)
    ~|("not approved for subscription" !!)
  ?~  (find path tag-list)
    ~&  >>  "no files with tag {<path>}"
    (on-watch:def path)
  ~&  >>  "got files subscription to {<path>} from {<src.bowl>}"  `this
::  ==
++  on-leave  on-leave:def
++  on-peek
  |=  pax=path
  ^-  (unit (unit cage))
  ?+    pax  (on-peek:def pax)
      [%x %files ~]
    ``noun+!>(files)
  ==
++  on-agent
  |=  [=wire =sign:agent:gall]
  ^-  (quip card _this)
::  ?+  wire  (on-agent:def wire sign)
  ~&  >>  wire
::  ?~  (find [-:wire]~ tag-list)
::    (on-agent:def wire sign)
  ?-    -.sign
      %poke-ack   (on-agent:def wire sign)
      %watch-ack  (on-agent:def wire sign)
      %kick
    ~&  >>>  "kicked from {<wire>} on {<src.bowl>}"
    `this
  ::
      %fact
      ~&  >>  sign
    `this
::  =^  cards  state
::    =*  vase  q.cage.sign
::  possibly use separate 'update-action' type
::    (handle-update:hc !<(action:filesharer q.cage.sign))
::    [cards this]
  ==
++  on-fail   on-fail:def
--
::  start helper core
|_  bowl=bowl:gall
++  handle-action
  |=  =action:filesharer
  ^-  (quip card _state)
  ?-    -.action
      %add-user
    =.  users.wl.state  (~(put in users.wl.state) ship.action)
      `state
    ::
      %remove-user
    =.  users.wl.state  (~(del in users.wl.state) ship.action)
    ?:  (check-wl ship.action)
      `state
    :_  state
      ~[[%give %kick ~ `ship.action]]
    ::
      %add-group
::    `state(groups.wl.state (~(uni in groups.wl.state) group.action))
    =.  groups.wl.state  (~(uni in groups.wl.state) (silt ~[group.action]))
      `state
    ::
      %remove-group
    |^
    =/  users=(list ship)  ~(tap in (~(members group bowl) group.action))
    =.  groups.wl.state  (~(del in groups.wl.state) group.action)
    =/  kicked=(list ship)  (skip users check-wl)
    =/  kicks=(list card)  (generate-kicks kicked)
    :_  state
      kicks
    ++  generate-kicks
      |=  users=(list ship)
      =|  kicks=(list card)  
      |-  ^-  (list card)
      ?~  users
        kicks
      %=  $
        kicks  (snoc kicks [%give %kick ~ `i.users])
        users  t.users
      ==
    --
    ::
      %add-file
    =/  paths=(list path)  (turn file-tags.file.action |=(a=@tas [a ~]))
    ~&  >>  paths
    =.  files.state  (snoc files.state file.action)
      :_  state
      ~[[%give %fact paths [%filesharer-file !>(file.action)]]] 
    ::
      %remove-file
    |^
    =/  index=(unit @ud)  (find-file-index name.action)
    ~&  >>  +.action
    ?~  index
      ~&  >  "no file by that name"  [~ state]
    =/  ftags=(list @tas)  file-tags:(snag u.index files.state)
    =/  paths=(list path)  (turn ftags |=(a=@tas [a ~]))
    =.  files.state  (oust [u.index 1] files.state)
    =/  tag-list=(list @tas)  (nub (flatten (turn files.state |=(a=file:filesharer file-tags.a))))
    =/  kicks=card  (generate-kicks ftags tag-list)
    :_  state
      ~[[%give %fact paths [%noun !>(+.action)]] kicks] 
    ::    
    ++  generate-kicks
      |=  [ft=(list @tas) tl=(list @tas)]
      =|  paths=(list path)
      |-  ^-  card
      ?~  ft
        [%give %kick paths ~]
      ?:  (check-tag i.ft tl)
        $(ft t.ft)
      $(paths (snoc paths `path`~[i.ft]), ft t.ft)
    ::  compare each tag in new state to the tag from file and return ? whether present.
    ++  check-tag
      |=  [ft=@tas tl=(list @tas)]
      ^-  ?
      (lien tl |=(a=@tas =(a ft)))
    --
    ::
      %list-tag-files
    |^  
      ~&  >>  (skim files.state check-tags)
    :_  state
    ~
    ::  compare each tag in a file to the tag from poke and return ? whether present.
    ++  check-tags
      |=  =file:filesharer
      =/  tags=(list @tas)  file-tags.file
      |-  ^-  ?
      ?~  tags  %.n
      ?:  =(i.tags tag.action)
        %.y
      $(tags t.tags)
      --
    ::
      %subscribe
    ~&  >  `path`[tag.action ~]
    :_  state
    ~[[%pass `path`[tag.action ~] %agent [host.action %filesharer] %watch `path`[tag.action ~]]]
    ::
      %leave
    :_  state
    ~[[%pass `path`[tag.action ~] %agent [host.action %filesharer] %leave ~]]
::      %peek-files
::    :_  state
::    .^(list file) %gx /[(scot %p our.bowl)]/[app]/[(scot %da now.bowl)]/files/noun
  ==
:: Is ship in the whitelist or a member of a group in the whitelist?
++  check-wl
  |=  =ship
  ?:  |((check-grps ship) (check-usr ship))
    %.y
  %.n
++  check-grps
  |=  =ship
::  =/  my-grps  ~(scry-groups group bowl)
  =/  gs  ~(tap in groups.wl)
::  ~&  >  "in check-grps arm"
  |-
  ?~  gs  %.n
  ?:  (~(is-member group bowl) ship i.gs)
    %.y
  $(gs t.gs)
++  check-usr
  |=  =ship
  =/  us  ~(tap in users.wl)
  ?~  us  %.n
  ?~  (find ~[ship] us)
    %.n
  %.y
++  find-file-index
  |=  filename=@t
  ^-  (unit @ud)
  =/  id  (mug filename)
  =/  id-list  (turn files.state |=(a=file:filesharer id.a))  
  (find ~[id] id-list)
::  flattens a list of lists
::  original list, new list
++  flatten
  |=  olist=(list (list @tas))
  =|  nlist=(list @tas)
  |-  ^-  (list @tas)
  ?~  olist
    nlist
  $(olist t.olist, nlist (weld i.olist nlist))
::  remove duplicate tags from list
::  original list, new list, temp list
++  nub
  |=  olist=(list @tas)
  =|  nlist=(list @tas)
  |-  ^-  (list @tas)
  ?~  olist
    nlist
  =/  tlist=(list @tas)  nlist
  |-  ^-  (list @tas)
  ?~  tlist
    ^$(olist t.olist, nlist (snoc nlist i.olist))
  ?:  =(i.olist i.tlist)
    ^$(olist t.olist)
  $(tlist t.tlist)
--
