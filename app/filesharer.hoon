/-  filesharer
/+  default-agent, resource, group
|% 
+$  card  card:agent:gall
+$  subscriber  @p
+$  state-zero  [subs=(list @p)]
--
::
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
        %print-subs
      ~&  >>  &2.bowl  `this
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
  ?+     path  (on-watch:def path)
      [%subs ~]
      ~&  >>  "got subs subscription from {<src.bowl>}"  `this
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
      %add-sub
    =.  subs.state  (snoc subs.state sub.action)
::      `this
      :_  state
      ~[[%give %fact ~[/subs] [%atom !>(subs.state)]]] 
  ::
      %subscribe
    :: need to add =. to alter sub.state. then send fact?
    ::    :-  ~  state
    ?.  check-grps 
      ~|("not approved for subscription" !!)
    ~&  >  "accepted for subscription"
    :_  state
    ~[[%pass /subs/(scot %p host.action) %agent [host.action %filesharer] %watch /subs]]
    ::
      %leave
    :_  state
    ~[[%pass /subs/(scot %p host.action) %agent [host.action %filesharer] %leave ~]]
  ==
++  check-grps
  =/  my-grps  ~(scry-groups group bowl)
  =/  gs  ~(tap in my-grps)
  |-
  ?~  gs  %.n
  ?:  (~(is-member group bowl) src.bowl i.gs)
    %.y
  $(gs t.gs)
--
