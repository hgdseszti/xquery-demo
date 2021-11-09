xquery version "3.1" encoding "utf-8";

module namespace kd-utilities = "http://kingdiamond.util";
 
declare namespace array = "http://www.w3.org/2005/xpath-functions/array";
declare namespace prof  = "http://basex.org/modules/prof";

declare variable $kd-utilities:apiUri := "https://musicbrainz.org/ws/2/release/?artist=00565b31-14a3-4913-bd22-385eb40dd13c&amp;type=album&amp;status=official&amp;inc=labels+recordings&amp;fmt=json&amp;limit=50";

declare function kd-utilities:get-data() as array(*)
{
    kd-utilities:get-all()
};
declare %private function kd-utilities:get-all() as array(*) 
{    
    let $page := fn:json-doc($kd-utilities:apiUri)
    
    let $readNumberOfReleases := array:size($page?releases),
        $leftover := xs:integer(($page?release-count - $readNumberOfReleases))
    
    return
     if ($leftover = 0)
     then $page?releases
     else array:join(($page?releases, kd-utilities:get-all(fn:concat($kd-utilities:apiUri, "&amp;offset=", $readNumberOfReleases), $leftover)))
};

declare %private function kd-utilities:get-all($uri as xs:string, $amount as xs:integer) as array(*)
{

    let $h := prof:sleep(1000)
    let $page := fn:json-doc($uri)
    
    let $readNumberOfReleases := array:size($page?releases),
        $leftover := xs:integer($amount - $readNumberOfReleases)
        
    return 
     if ($leftover = 0)
     then $page?releases
     else array:join(($page?releases, kd-utilities:get-all(fn:concat($kd-utilities:apiUri, "&amp;offset=", $readNumberOfReleases), $leftover)))

};