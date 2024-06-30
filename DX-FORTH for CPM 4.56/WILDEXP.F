\ Wildcard filename expander demo

empty forth definitions decimal  application

1 fload doslib   _wildexp

: test ( a u -- )
  0 findall abort" no files found"
  begin  +fname while  cr type  repeat ;

s" *.*" test

