xquery version "3.1" encoding "utf-8";

module namespace kd-utilities = "http://kingdiamond.util";
 
declare namespace array = "http://www.w3.org/2005/xpath-functions/array";
declare namespace file = "http://expath.org/ns/file";

declare variable $kd-utilities:dataDir := "../data/";

declare function kd-utilities:get-data() as array(*)
{
    kd-utilities:get-all()
};
declare %private function kd-utilities:get-all() as array(*) 
{    
   array:join(
    for $json in file:children(file:resolve-path($kd-utilities:dataDir))
        return fn:json-doc($json)?releases
    )
    
};