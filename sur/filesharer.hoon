/-  resource
|%
+$  file
  $:  name=@t
      id=@                 :: unique id (hash?) of file
      file-pointer=pointer
      file-type=(unit mark)
      file-tags=(list @tas)
  ==
+$  pointer
  $%  [%url url-pointer=@t]
      [%clay clay-pointer=wire]
      [%ipfs ipfs-pointer=@t]
  ==
+$  whitelist
  $:  users=(set ship)
      groups=(set resource:resource)
  ==
+$  source
  $:  =ship
      content=(set file)
  ==
+$  action
  $%  [%add-user =ship]
      [%remove-user =ship]
      [%add-group group=resource:resource]
      [%remove-group group=resource:resource]
      [%add-file =file]
      [%remove-file name=@t]
      [%remove-source =ship]  :: for testing, remove 
      [%list-tag-files tag=@tas]
      [%subscribe host=@p tag=@tas]
      [%leave host=@p tag=@tas]
  ==
+$  server-update
  $%  [%add-file =file]
      [%remove-file =file]
      [%add-source =source]
      [%remove-source =ship]
  ==
--
