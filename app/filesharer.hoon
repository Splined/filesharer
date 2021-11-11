::  Backend for the 'filesharer agent'. Initial design intent is to share file links for between ships, not the files themselves.
::  State consists of a whitelist of users (ships) and groups, a list of shared files and associated data. A jug of subscriptions (ships) and their files was added after considering the impact on UX of retrieving this as needed.
::  This also meant that subscription was by file tag. This has been replaced by subscription to /update, which handles all information moved between ships.  Tag subs will be kept in case there is a front end use for them.
::  Todo: combine files.state and sources.state.  There's no reason these need to be seperate and combining would seem to meet percept A7 <https://urbit.org/blog/precepts>
/-  filesharer
/+  default-agent, dbug, resource, group
|% 
+$  versioned-state
    $%  state-0
    ==
::
+$  state-0  [%0 wl=whitelist:filesharer files=(list file:filesharer) sources=(jug ship file:filesharer)] 
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
    ?>  =(our src):bowl
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
  ?:  =(path /updates)
  =/  data=source:filesharer  [our.bowl (silt files.state)]
  =/  =cage  [%filesharer-server-update !>([%add-source data])]
  :_  this
    ~[[%give %fact ~ cage]] 
  ?~  (find path tag-list)
    ~&  >>  "no files with tag {<path>}"
    (on-watch:def path)
  ~&  >>  "got files subscription to {<path>} from {<src.bowl>}"
  `this
::  ==
++  on-leave  on-leave:def
++  on-peek
  |=  =path
  ^-  (unit (unit cage))
  |^  ?+  path  (on-peek:def path)
        [%x %files ~]
      ``noun+!>((turn files.state |=(a=file:filesharer name.a)))
        [%x %files @tas ~]
      ``noun+!>((skim-tag [files.state i.t.t.path]))
        [%x %test ~]
      ``noun+!>(?~(files.state ~ i.files.state))
      ==
++  skim-tag
    |=  [a=(list file:filesharer) b=@tas]
    =|  file-names=(list @t)
    ^-  (list @t)
    |-
    ?~  a 
      file-names
    ?:  (lien file-tags.i.a |=(a=@tas =(a b)))
      $(file-names (snoc file-names name.i.a), a t.a)
    $(a t.a)
  --
++  on-agent
  |=  [=wire =sign:agent:gall]
  ^-  (quip card _this)
  ?+  wire  (on-agent:def wire sign)
    [%updates ~]
    ?+  -.sign  (on-agent:def wire sign)
        %kick
      ~&  >>>  "kicked from {<wire>} on {<src.bowl>}"
      `this
  ::
        %fact
      ?+  p.cage.sign  (on-agent:def wire sign)
          %filesharer-server-update
::      =+  !<(=source:filesharer q.cage.sign)
        =/  resp  !<(=server-update:filesharer q.cage.sign)
        :: change this to ?- after implementing all options
        ?-  -.resp
            %add-source
          =/  data=source:filesharer  +.resp
          =/  files=(list file.filesharer)  ~(tap in content.data)
          =/  s  `(jug ship file.filesharer)`(~(gas ju sources.state) (turn files |=(=file.filesharer [ship.data file])))
          [~ this(sources s)]
            %remove-source
          =/  data  +.resp
          =/  s  `(jug ship file.filesharer)`(~(del by sources) data)
          [~ this(sources s)]
            %add-file
          =/  data=file:filesharer  +.resp
          =/  s  `(jug ship file.filesharer)`(~(put ju sources) src.bowl data)
          [~ this(sources s)]
            %remove-file
          =/  data=file:filesharer  +.resp
          =/  s  `(jug ship file.filesharer)`(~(del ju sources) src.bowl data)
          [~ this(sources s)]
        ==
      ==  
    ==
  ==
++  on-fail   on-fail:def
--
::  start helper core
|_  bowl=bowl:gall
++  handle-action
  |=  =action:filesharer
  ^-  (quip card _state)
  ?-  -.action
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
    =/  =cage  [%filesharer-server-update !>([%add-file file.action])]
    :_  state
::  tried to combine this with below %give but errored out. Can there be two seperate %give cards sent at once?
::  [%give %fact paths [%filesharer-file !>(file.action)]]
      ~[[%give %fact ~[/updates] cage]]
    ::
      %remove-file
    |^
    =/  index=(unit @ud)  (find-file-index name.action)
    ~&  >>  +.action
    ?~  index
      ~&  >  "no file by that name"  [~ state]
    =/  data=file:filesharer  (snag u.index files.state)
    ::  check and clean up subs
    =/  ftags=(list @tas)  file-tags:(snag u.index files.state)
    =/  paths=(list path)  (turn ftags |=(a=@tas [a ~]))
    =.  files.state  (oust [u.index 1] files.state)
    =/  tag-list=(list @tas)  (nub (flatten (turn files.state |=(a=file:filesharer file-tags.a))))
    =/  kicks=card  (generate-kicks ftags tag-list)
    :: for updating client state
    =/  =cage  [%filesharer-server-update !>([%remove-file data])]
    :_  state
::  tried to combine this with below %give. Can there be two seperate %give cards sent at once?
::      ~[[%give %fact paths [%noun !>(+.action)]] kicks] 
      ~[[%give %fact ~[/updates] cage]]
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
      %remove-source
    =/  s  `(jug ship file.filesharer)`(~(del by sources) ship.action)
    [~ state(sources s)]
    ::
      %list-tag-files
    |^  
      ~&  >>  (skim files.state check-tags)
    `state
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
    ?.  =(tag.action %updates)
      :_  state
        ~[[%pass `path`[tag.action ~] %agent [host.action %filesharer] %leave ~]]
    =/  s  `(jug ship file.filesharer)`(~(del by sources) host.action)
    :_   state(sources s)
      ~[[%pass `path`[tag.action ~] %agent [host.action %filesharer] %leave ~]]
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
++  scry-for
  |*  [=mold =path]
  .^  mold
    %gx
    (scot %p our.bowl)
    %filesharer
    (scot %da now.bowl)
    (weld path /noun)
    ==
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
