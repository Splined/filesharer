/-  filesharer
/+  default-agent, dbug, resource, group
|% 
+$  card  card:agent:gall
::  make files a ++jar (i.e. ++map of ++list)?
::  would allow 'id' as key and lookup by id. e.g. (~(get ja files) id)
::  no ++del:ja or ++has:ja in docs. Do these exist?
+$  state-zero  [files=(list file:filesharer)]
::  +$  state-zero  [files=(jar @ file:filesharer)] 
--
::
%-  agent:dbug
=|  state=state-zero
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
        %print-state
      ~&  >>  state
      ~&  >>>  bowl  `this
      ::
        %print-grps
      =/  grps=(set resource:resource)  ~(scry-groups group bowl)
      ~&  >>  grps  `this
      ::
        %print-files
      ~&  >>  files.state  `this
      ::
        %list-tags
::      ~&  >>  ~(tap in (sy (turn files.state |=(a=file:filesharer file-tags.a))))  `this
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
++  on-save   on-save:def
++  on-load   on-load:def
++  on-watch
  |=  =path
  ^-  (quip card _this)
  ?.  check-grps:hc
    ~|("not approved for subscription" !!)
  ?+     path  (on-watch:def path)
  :: need to add =. to alter sub.state. then send fact?
  ::    :-  ~  state
    [%files ~]
::      ?>  check-grps
  ~&  >>  "got files subscription from {<src.bowl>}"  `this
  ==
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
    =.  files.state  (snoc files.state file.action)
      :_  state
      ~[[%give %fact ~[/files] [%atom !>(files.state)]]] 
::
      %remove-file
    =/  index=(unit @ud)  (find-file-index name.action)
    ?~  index
      ~&  >  "no file by that name"  [~ state]
    =.  files.state  (oust [u.index 1] files.state)
      :_  state
      ~[[%give %fact ~[/files] [%atom !>(files.state)]]] 
::
      %subscribe
    :_  state
    ~[[%pass /files/(scot %p host.action) %agent [host.action %filesharer] %watch /files]]
    ::
      %leave
    :_  state
    ~[[%pass /files/(scot %p host.action) %agent [host.action %filesharer] %leave ~]]
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
