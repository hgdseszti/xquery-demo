(:~
: This module is used for merging the releases of King Diamond taken from the database of MusicBrainZ Web API.
:
: @author Racs Tamás
:)

xquery version "3.1" encoding "utf-8";

module namespace kd-utilities = "http://kingdiamond.util";
 
declare namespace array = "http://www.w3.org/2005/xpath-functions/array";
declare namespace file = "http://expath.org/ns/file";

declare variable $kd-utilities:dataDir := "../data/";

(:~
: Returns an array containing all the releases of King Diamond
:
: @return array of release objects
:)
declare function kd-utilities:get-releases() as array(*)
{
    kd-utilities:get-all()
};

(:~
: Private function used for merging the releases of King Diamond
:
: @return array of release objects
:)
declare %private function kd-utilities:get-all() as array(*) 
{    
   array:join(
    for $json in file:children(file:resolve-path($kd-utilities:dataDir))
        return fn:json-doc($json)?releases
    )
    
};