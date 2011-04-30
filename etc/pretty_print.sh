#! /bin/bash

sed 's/nil nil nil nil/[{},{},{},{}]/g' | sed 's/ =/:/g' | sed 's/} {/}, {/g' | sed 's/, /,\
/g' | sed -E 's/\{([^}])/{\
\1/g' | sed -E 's/([[:digit:]])\}/\1\
}/g' | sed 's/]}/]\
}/g' | sed 's/nil/{},/g'
