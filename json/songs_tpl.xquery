(:~
: This query returns the names of songs recorded in The Spider's Lullabye album.
:
: @author Racs Tamás
:)

xquery version "3.1";

import module namespace kd-utilities = "http://kingdiamond.util" at "../utilities/init.xquery";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace array = "http://www.w3.org/2005/xpath-functions/array";

declare option output:method "json";
declare option output:indent "yes";

declare variable $releases := kd-utilities:get-releases();

(:~
: Private function used for merging the available media of a release.
:
: $param $media array containing the available media for the release
: @param $index used for indexing the $media array
: @return a JSON array of song objects
:)
declare %private function local:mergeCDs($media as array(*), $index as xs:integer) as array(*)
{
    if (array:size($media) = $index)
    then array:get($media, $index)?tracks
    else array:join((array:get($media, $index)?tracks, local:mergeCDs($media, $index + 1))) 
};

let $spiders-lullaby := for $release in $releases?*
                        where $release?title = "The Spider's Lullabye" 
                        return  $release

let $mergedCDs := local:mergeCDs($spiders-lullaby[1]?media, 1)
          
return array {          
    for $songId in 1 to array:size($mergedCDs)
    return  array:get($mergedCDs, $songId)?title }       