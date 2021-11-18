(:~
: This query returns the number of releases of King Diamond by counting the received objects from MusicBrainZ Web API
:
: @author Racs Tamás
:)
xquery version "3.1";

import module namespace kd-utilities = "http://kingdiamond.util" at "../utilities/init.xquery";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace array = "http://www.w3.org/2005/xpath-functions/array";

declare option output:method "json";
declare option output:indent "yes";

let $data := kd-utilities:get-releases()
return count(fn:distinct-values(array {for $index in 1 to array:size($data) return array:get($data,$index)?id}))

