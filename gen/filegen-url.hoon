::  used to create and format info for add-file poke
/-  *filesharer
:-  %say
|=  [* [name=@t url=@t ft=@tas tags=(list @tas) ~] ~]
::  |=  [name=@t url=@t ft=@tas tags=(list @tas)]
:-  %filesharer-action
::^-  file
=/  poi=pointer  [%url url]
::  =/  id=@  (mug name)
:-  %add-file
:*  name
  (mug name)
  poi
  (some ft)
  (limo tags)
==
