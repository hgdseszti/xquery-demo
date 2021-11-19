(:~
: This query returns an HTML5 document describing the discography of King Diamond
:
: @author Racs Tamás
:)

xquery version "3.1";

import module namespace kd-utilities = "http://kingdiamond.util" at "../utilities/init.xquery";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace array = "http://www.w3.org/2005/xpath-functions/array";
declare namespace validate = "http://basex.org/modules/validate";

declare option output:method "html";
declare option output:html-version "5.0";
declare option output:indent "yes";

(:~
: Private function used to get front covers for the albums in the discography.
:
: @param $id mbid of the release
: @return an URI to the album cover
:)
declare %private function local:get-front-album-cover($id as xs:string) as xs:string
{
    fn:concat('https://coverartarchive.org/release/',$id,'/front')    
};

(:~
: Returns the flags of the countries where the given album was released.
: 
: @param $albumTitle the parameter of the search
: @return all the flags concatenated
:)
declare %private function local:get-release-country-flags($albumTitle as xs:string) as xs:string
{
    let $countryCodes := fn:distinct-values(
        for $r in $releases?*
        where fn:replace($r?title, '"+|“+|”+|’+|…+|–+', '') = $albumTitle
        return $r?country
       ),
       $mergedCodes := fn:substring(fn:fold-left($countryCodes, "", fn:concat(?,",",?)), 1)
    
    return fn:substring(fn:fold-left(fn:distinct-values(
    
        for $country in fn:json-doc(fn:concat("https://restcountries.com/v3.1/alpha?codes=", $mergedCodes))?*
        return $country?flag
    
    ),"", fn:concat(?," ",?)),1)
};
(:~
: Tjis function determines the first release-date of a given album.

: @param $title the album title
: @return the date where $title was first released
:)
declare %private function local:get-first-release-date($title as xs:string) as xs:string
{
    (for $r in $releases?*
    where $r?date != "" and $title = fn:replace($r?title, '"+|“+|”+|’+|…+|–+', '')
    order by $r?date
    return $r?date)[1]
};

declare variable $releases := kd-utilities:get-releases();
declare variable $webpageTitle := "King Diamond's Discography";
declare variable $stylesheet := "./css/discography.css";

let $albumTitles := array {fn:distinct-values(for $r in $releases?* return fn:replace($r?title, '"+|“+|”+|’+|…+|–+', ''))}, 
    $preDiscography := array {
        for $title in $albumTitles?*
        let $firstInstance := 
                    
                    (for $r in $releases?*
                    where $r?cover-art-archive?front and fn:replace($r?title, '"+|“+|”+|’+|…+|–+', '') = $title and fn:exists($r?date)
                    order by $r?date
                    return $r)[1],
            $rDate := local:get-first-release-date($title)
        order by $rDate           
        return 
        if (fn:exists($firstInstance?id))
        then map {
            "title" : fn:replace($firstInstance?title, '"+|“+|”+|’+|…+|–+', ''),
            "release-date": $rDate,
            "id": $firstInstance?id,
            "tracks": array:join(for $m in $firstInstance?media?* return $m?tracks)
        }
        else ()},
    $resultDocument := document {
    <html>
        <head>
            <title>{$webpageTitle}</title>
            <link rel="stylesheet" href="{$stylesheet}"/>
        </head>
        <body>
            <div class="wrapper">
                {
                    for $album at $idx in $preDiscography?*
                    order by $album?release-date
                    return
                        <div class="album-{$idx}">
                            <div class="coverContainer">
                                <img src="{local:get-front-album-cover($album?id)}" alt="Cover Of {$album?title}" class="album-cover-{$idx}"/>
                            </div>                           
                            <div class="tracksContainer">
                                 <div class="flagContainer">
                                     <p>
                                          {local:get-release-country-flags($album?title)} 
                                     </p>
                                 </div>
                                <table class="album">
                                    <thead>
                                        <tr class="albumHeader">
                                            <th colspan="3">{fn:concat($album?title, ' (', $album?release-date, ')')}</th>
                                        </tr>
                                    </thead>
                                    <tbody class="albumBody">
                                    {
                                        for $track at $i in $album?tracks?*
                                        let $trackLengthInSeconds := $track?length div 1000,
                                            $trackLengthMinutePartial := fn:string(fn:round($trackLengthInSeconds div 60)),
                                            $trackLengthSecondsPartial := fn:string(fn:round($trackLengthInSeconds mod 60)),
                                            $trackLengthInMinutes := fn:concat(
                                                if (fn:string-length($trackLengthMinutePartial) < 2) then fn:concat("0", $trackLengthMinutePartial) else $trackLengthMinutePartial,
                                                ':',
                                                if (fn:string-length($trackLengthSecondsPartial) < 2) then fn:concat("0", $trackLengthSecondsPartial) else $trackLengthSecondsPartial)
                                        return
                                            <tr class="track-{$i}">
                                                <td>{$i}</td>
                                                <td class="track-title">{$track?title}</td>
                                                <td class="track-length">{$trackLengthInMinutes}</td>
                                            </tr>
                                    }
                                    </tbody>
                                </table>
                            </div>
                        </div>
                }
            </div>
        </body>
    </html>}
   return $resultDocument