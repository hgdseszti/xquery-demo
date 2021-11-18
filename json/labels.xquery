(:~
: This query returns each label associated with King Diamond with the albums they published with their release dates included.
:
: @author Racs Tamás
:)

xquery version "3.1";

import module namespace kd-utilities = "http://kingdiamond.util" at "../utilities/init.xquery";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace array = "http://www.w3.org/2005/xpath-functions/array";
declare namespace map = "http://www.w3.org/2005/xpath-functions/map";

declare option output:method "json";
declare option output:indent "yes";

declare variable $releases := kd-utilities:get-releases();
declare variable $labels := array:join(for $release in $releases?* return $release?label-info);

(:~
: Private function used for searching for an element inside an array.
:
: @param $arr the context of the search
: @param $index the current depth of the search
: @param $item the element we're searching for in $arr
: @return true() if $item is found inside $arr
          false() otherwise
:)
declare %private function local:array-contains($arr as array(*),$index as xs:integer, $item as xs:string) as xs:boolean
{
    if (array:size($arr) + 1 = $index)
    then false()
    else
       if (array:get($arr,$index)?label?name = $item)
       then true()
       else local:array-contains($arr, $index + 1, $item)
};

map:entry("publishers", array:join(
    let $labels := fn:distinct-values(for $label in $labels?* return $label?label?name)
    for $label in $labels
    order by $label
        return array { map {
            "publisher": $label,
            "releases": array {             
                for $release in $releases?*
                where local:array-contains($release?label-info, 1, $label)    
                order by $release?date
                return map {
                    "album-title" : $release?title,
                    "release-date": $release?date
                }
              }
             }}
           ))

