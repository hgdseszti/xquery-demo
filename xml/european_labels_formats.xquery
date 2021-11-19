(:~
: This query returns an XML document containing the names of all labels that have released in Europe.
: The query also determines the media formats prefered by each label in Europe included where they're first used and when. 
:
: @author Racs Tamás
:)

xquery version "3.1";

import module namespace kd-utilities = "http://kingdiamond.util" at "../utilities/init.xquery";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace array = "http://www.w3.org/2005/xpath-functions/array";
declare namespace validate = "http://basex.org/modules/validate";

declare option output:method "xml";
declare option output:indent "yes";

(:~
: Private function used for interfacing with restcountries.com. The function retrieves all European countries recorded in their database.
: 
: @return a JSON array of country objects
:)
declare %private function local:get-countries() as array(*)
{
   array {
    for $country in fn:json-doc("https://restcountries.com/v3.1/region/europe")?*
    where $country?independent = true()
    return $country?cca2
   }
};

declare variable $releases := kd-utilities:get-releases();
declare variable $europeanCountryCodes := local:get-countries();

let $labels := fn:distinct-values(for $labelInfo in array:join(for $release in $releases?* return $release?label-info)?* return $labelInfo?label?name),
    $labelsWithMediaFormats := array {
        for $label in $labels
        return map {
            "label" :$label,
            "formats": array {
                for $r in $releases?*
                where $label = array{for $l in $r?label-info?* return $l?label?name}
                    for $media in $r?media?*
                    return map {
                        "format" : $media?format
                    }
            }
        }},
    $mergedLabelsWithFormats := array {
        for $label in $labelsWithMediaFormats?*
            return map {
                "label" : $label?label,
                "formats" : array {
                    for $f in $label?formats?*
                    group by $formatName := $f?format
                    let $c := count($f)
                    order by $c descending
                    return map {
                        "format": $formatName,
                        "used" : $c,
                        "firstUsedAt": 
                            array:get(array { for $release in $releases?*
                                                where $f?format = array { for $m in $release?media?* return $m?format } 
                                                    and $label?label = array { for $l in $release?label-info?* return $l?label?name } 
                                                order by $release?date ascending
                                                return map {
                                                    "album" : $release?title,
                                                    "releaseDate" : $release?date
                                                }}, 1)
                    }
            }}
            },
    $resultDocument :=         
        <labels>
            {
                for $info in $mergedLabelsWithFormats?*
                return 
                <label name="{$info?label}">
                    {   
                        for $format in $info?formats?*
                        return
                        <format name="{$format?format}" used="{$format?used}" firstAlbum="{$format?firstUsedAt?album}" firstUsage="{$format?firstUsedAt?releaseDate}"/>
                    }
                </label>
            }
        </labels>,
   $validationMessage := validate:xsd-report($resultDocument, "european_labels_formats.xsd")
   return
   if (fn:contains($validationMessage, "invalid"))
   then $validationMessage
   else $resultDocument