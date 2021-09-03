/-  filesharer
/+  default-agent, dbug, resource, group
|% 
+$  versioned-state
    $%  state-0
    ==
::
+$  state-0  [files=(list file:filesharer)]
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
  ~&  >  '%filesharer recompiled successfully'
  `this(state !<(versioned-state old-state))
++  on-watch
  |=  =path
  ^-  (quip card _this)
  =/  tag-list=(list @tas)  (nub:hc (flatten:hc (turn files.state |=(a=file:filesharer file-tags.a))))
  ?.  check-grps:hc
    ~|("not approved for subscription" !!)
  ?~  (find path tag-list)
    (on-watch:def path)
::  {<i.path>} gives find-fork error. How should I access the name of the wire?
::  ~&  >>  "got files subscription to {<i.path>} from {<src.bowl>}"  `this
  ~&  >>  "got files subscription to i.path from {<src.bowl>}"  `this
::  ==
++  on-leave  on-leave:def
++  on-peek   on-peek:def
++  on-agent  on-agent:def
++  on-fail   on-fail:def
--
::  start helper core
|_  bowl=bowl:gall
++  handle-action
  |=  =action:filesharer
  ^-  (quip card _state)
  ?-    -.action
      %add-file
    =/  paths=(list path)  (turn file-tags.file.action |=(a=@tas [a ~]))
    ~&  >>  paths
    =.  files.state  (snoc files.state file.action)
      :_  state
      ~[[%give %fact paths [%filesharer-file !>(file.action)]]] 
    ::
      %remove-file
    =/  index=(unit @ud)  (find-file-index name.action)
    ?~  index
      ~&  >  "no file by that name"  [~ state]
    =.  files.state  (oust [u.index 1] files.state)
      :_  state
      ~[[%give %fact ~[/files] [%t !>(+.action)]]] 
    ::
        %list-tag-files
      |^  
      ~&  >>  (skim files.state check-tags)
    :_  state
    ~
      ::  compare each tag in a file to the tag from poke
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
    ~&  >>  tag.action
    :_  state
    ~[[%pass /(scot %tas tag.action)/(scot %p host.action) %agent [host.action %filesharer] %watch /(scot %tas tag.action)]]
    ::
      %leave
    :_  state
    ~[[%pass /(scot %tas tag.action)/(scot %p host.action) %agent [host.action %filesharer] %leave ~]]
  ==
++  check-grps
  =/  my-grps  ~(scry-groups group bowl)
  =/  gs  ~(tap in my-grps)
::  ~&  >  "in check-grps arm"
  |-
  ?~  gs  %.n
  ?:  (~(is-member group bowl) src.bowl i.gs)
    %.y
  $(gs t.gs)
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
