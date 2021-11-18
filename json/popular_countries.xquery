(:~
: This query returns the top 3 countries where most of the releases happened. The most popular album with its release count is also associated with the countries in the result JSON.
:
: @author Racs Tamás
:)

xquery version "3.1";

import module namespace kd-utilities = "http://kingdiamond.util" at "../utilities/init.xquery";declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

declare namespace array = "http://www.w3.org/2005/xpath-functions/array";
declare namespace map = "http://www.w3.org/2005/xpath-functions/map";

declare option output:method "json";
declare option output:indent "yes";

declare variable $releases := kd-utilities:get-releases();

let $countries := fn:distinct-values(
    for $release in $releases?*
    return 
            for $country in $release?release-events?*
            return $country?area?name
),

    $countriesWithAlbums := map {  
        "data" : array:sort(array {
          for $c in $countries
          return map {
              "country" : $c,
              "albums" : array:sort(array { for $release in $releases?*
                          for $event in $release?release-events?*
                              group by $title := $release?title
                              return 
                                  if ($event?area?name = $c or ($event?area?name = "[Worldwide]" and not($c != "[Worldwide]")))                        
                                  then map {
                                      "album" : $title,
                                      "count": count($release)
                                  }
                                  else ()
          }, fn:default-collation(), function($item) {-$item?count} )}}, fn:default-collation(), function($item) {$item?country})
}        ,

    $mostPopularReleaseCountries := map {
        "countries" : array:subarray(array:sort(array {
            for $c in $countriesWithAlbums?data?*
            return map {
                "country" : $c?country,
                "numberOfReleases" : fn:sum(
                        for $album in $c?albums?*
                        return $album?count
                    )
            }
        }, fn:default-collation(), function($item) {-$item?numberOfReleases}), 1, 3)    
    },
    
    $resultDocument := map {
        "response" : array {
            for $c in $mostPopularReleaseCountries?countries?*
            return map {
                "country": $c?country,
                "numberOfReleases": $c?numberOfReleases,
                "mostPopularAlbum" :
                    for $cc in $countriesWithAlbums?data?*
                    where $cc?country = $c?country
                    return array:get(array {
                        for $album in $cc?albums?*
                        return map {
                            "title": $album?album,
                            "count": $album?count
                        }
                     }, 1)
            }
        }
    }


return $resultDocument