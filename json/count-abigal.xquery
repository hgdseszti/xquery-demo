xquery version "3.1";

import module namespace kd-utilities = "http://kingdiamond.util" at "../utilities/init.xquery";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace array = "http://www.w3.org/2005/xpath-functions/array";

declare option output:method "json";
declare option output:indent "yes";

declare variable $releases := kd-utilities:get-releases();

declare variable $dates := 
    array {
        for $release in $releases?*
        let $date := xs:integer(fn:substring(if ($release?date != "") then $release?date else "0001", 1,4))
        where $release?title = "Abigail" and $date le 1999
        return $date
    };

array:size($dates)