xquery version "3.1";

import module namespace kd-utilities = "http://kingdiamond.util" at "../utilities/init.xquery";

let $data := kd-utilities:get-data()
return $data

