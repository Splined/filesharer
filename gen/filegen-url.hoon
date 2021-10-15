::  used to create and format info for add-file poke
/-  *filesharer
:-  %say
|=  [* [name=@t url=@t ft=@tas tags=(list @tas) ~] ~]
:-  %filesharer-action
=/  poi=pointer  [%url url]
:-  %add-file
:*  name
  (mug name)
  poi
  (some ft)
  tags 
==
