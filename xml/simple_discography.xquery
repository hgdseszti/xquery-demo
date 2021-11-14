xquery version "3.1";

import module namespace kd-utilities = "http://kingdiamond.util" at "../utilities/init.xquery";declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

declare namespace array = "http://www.w3.org/2005/xpath-functions/array";
declare namespace map = "http://www.w3.org/2005/xpath-functions/map";

declare option output:method "xml";
declare option output:indent "yes";

declare %private function local:mergeMedia($media as array(*), $index as xs:integer) as array(*)
{
    if (array:size($media) = $index)
    then array:get($media, $index)?tracks
    else array:join((array:get($media, $index)?tracks, local:mergeMedia($media, $index + 1))) 
};

declare variable $releases := kd-utilities:get-releases();

let $firstReleasesWithId :=  array { for $release in $releases?*
                             group by $albumTitle := fn:replace($release?title, '"+|“+|”+|’+|…+|–+', '')
                             let $releaseDate := fn:min(for $date in $release?date where $date != "" return array { xs:integer(fn:substring($date, 1,4)) })
                             return map {
                                    "name" : $albumTitle,
                                    "release-date" : $releaseDate,
                                    "id" : 
                                        array:get( array {
                                            for $rel in $releases?*
                                            where $rel?date != "" and xs:integer(fn:substring($rel?date,1,4)) = $releaseDate
                                            return $rel?id 
                                          }
                                        ,1)
                             }}
                             
return 
<discography>
    <albums count="{array:size($firstReleasesWithId)}">
        {
            for $album in $firstReleasesWithId?*
                for $r in $releases?*
                where $r?id = $album?id
                return 
                <album title="{$album?name}" release-date="{$album?release-date}">
                    <songs>
                        {
                            for $song in local:mergeMedia($r?media, 1)?*
                            return 
                                <song name="{$song?title}" duration="{fn:round(xs:double($song?length) div 1000 div 60,2)}" />
                        }
                    </songs>
                </album>
        }
    </albums>
</discography>                          
                                    