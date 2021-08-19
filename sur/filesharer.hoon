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
+$  action
  $%  [%add-file =file]
      [%remove-file name=@t]
      [%list-tag-files tag=@tas]
      [%subscribe host=@p]
      [%leave host=@p]
  ==
--
