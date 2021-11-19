(:~
: This query returns an XML document which represents the discography of King Diamond
:
: @author Racs Tamás
:)

xquery version "3.1";

import module namespace kd-utilities = "http://kingdiamond.util" at "../utilities/init.xquery";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

declare namespace array = "http://www.w3.org/2005/xpath-functions/array";
declare namespace map = "http://www.w3.org/2005/xpath-functions/map";
declare namespace validate = "http://basex.org/modules/validate";

declare option output:method "xml";
declare option output:indent "yes";

(:~
: Private function used for merging the available media of a release.
:
: $param $media array containing the available media for the release
: @param $index used for indexing the $media array
: @return an array of song objects
:)
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
                             }},
                             
$resultDocument :=
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
                            let $duration := if (fn:exists($song?length)) then $song?length else 0.0
                            return 
                                <song name="{$song?title}" duration="{fn:round(xs:double($duration) div 1000 div 60,2)}" />
                        }
                    </songs>
                </album>
        }
    </albums>
</discography>         ,    
$validationMessage := validate:xsd-report($resultDocument, "simple_discography.xsd")
return 
    if (fn:contains($validationMessage, "invalid"))
    then $validationMessage
    else $resultDocument