(:~
: This query returns an XML document which describes the used packaging formats of each release countries.
: The query also determines how many times a packaging format was used per country. 
: Only releases with front covers are taken into calculations.
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

declare variable $releases := kd-utilities:get-releases();


let $result := 
        array {
            for $release allowing empty in $releases?*
            where $release?cover-art-archive?front = true()
            group by $country := $release?country,
                     $package := $release?packaging
            order by $country, $package
            return map {
                "countryCode" : $country,
                "packaging" : if (fn:boolean($package)) then $package else "Unknown",
                "numberOfReleases": count($release)               
            } 
        
        },
$resultDocument :=
<countryCodes>
    {
        for $entry in $result?*
        group by $countryCode := $entry?countryCode        
        let $count := fn:count($entry?packaging)
        return 
            <countryCode value="{$countryCode}" uniq-packagings="{$count}">
                {
                    for $p at $index in $entry?packaging
                    return
                        <packaging name="{$p}" release-count="{$entry?numberOfReleases[$index]}"/>
                }
            </countryCode>
    }
</countryCodes>,
$validationMessage := validate:xsd-report($resultDocument, "countrycode_with_packaging.xsd")
return
    if (fn:contains($validationMessage, "invalid"))
    then $validationMessage
    else $resultDocument
    