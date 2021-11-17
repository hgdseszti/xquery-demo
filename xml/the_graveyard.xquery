xquery version "3.1";

import module namespace kd-utilities = "http://kingdiamond.util" at "../utilities/init.xquery";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace array = "http://www.w3.org/2005/xpath-functions/array";
declare namespace validate = "http://basex.org/modules/validate";

declare option output:method "xml";
declare option output:indent "yes";

declare function local:get-countries() as array(*)
{
   fn:json-doc("https://restcountries.com/v3.1/all")       
};

declare function local:get-distance-from-hungary($cca3Borders as array(*), $depth as xs:integer) as xs:integer
{
    if ($depth ge 10 or array:size($cca3Borders) eq 0)
    then 
        if (array:size($cca3Borders) eq 0) then 999 else -1000
    else 
        let $neighbour :=  array { $cca3Borders[. = "HUN"] } 
        return if (array:size($neighbour) > 0)
               then 1
               else 
                     array {
                         for $cca3 in $cca3Borders
                         let $nextNeighbours := array {
                            for $next in $europeanCountries?*
                            where $next?cca3 = $cca3
                            return $next?neighbours }
                            
                         return 1 + local:get-distance-from-hungary($nextNeighbours, $depth + 1)
                     }                 
};

declare variable $releases := kd-utilities:get-releases();
declare variable $graveyard := "The Graveyard";
declare variable $countries := local:get-countries();
declare variable $europeanCountries :=  array {
        for $country in $countries?*
        where $country?region = "Europe" and $country?independent = true()
        return map {
            "country": $country?cca2,
            "cca3" : $country?cca3,
            "name" : $country?name?common,
            "neighbours": if (fn:exists($country?borders)) then $country?borders else array:join(())
        }
    };

let $releaseEuropeanCountries := 
    array {
        for $release in $releases?*,
            $country in $europeanCountries?*
        (: XE stands for Europe!:)
        where ($release?country = $country?country or $release?country = "XE") and fn:contains($release?title, $graveyard)
        group by $cca2 := $release?country,
                 $name := $country?name
        let $distance := local:get-distance-from-hungary(array{ fn:distinct-values($country?neighbours) }, 0)
        order by fn:abs($distance)
        return map {
            "country" : $cca2,
            "name" : $name,
            "distanceFromHungary" : $distance
        }
    },
    $resultDocument := 
    <europe>        
        {
         comment {
                "if distanceFromHungary = 999 means that we found a non european neighbour -> stopping search\n"                         
            }        
        }
        {
         comment {
             "if distanceFromHungary has a negative value that means we found ourselves in an infiinite neighbour loop, we cannot reach Hungary form here"
         }
        }
        {                   
            for $country in $releaseEuropeanCountries?*
            return             
            <country name="{$country?name}" cca2="{$country?country}" distanceFromHungary="{$country?distanceFromHungary}">
                {
                    if ($country?distanceFromHungary = fn:min(for $d in $releaseEuropeanCountries?* return fn:abs($d?distanceFromHungary)))
                    then attribute closest{
                        true()
                    }
                    else ()
                }
            </country>
        }
    </europe>,
    $validationMessage := validate:xsd-report($resultDocument, "the_graveyard.xsd")
    return
    if (fn:contains($validationMessage, "invalid"))
    then $validationMessage
    else $resultDocument