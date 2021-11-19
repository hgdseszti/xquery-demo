xquery version "3.1";

import module namespace kd-utilities = "http://kingdiamond.util" at "../utilities/init.xquery";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace array = "http://www.w3.org/2005/xpath-functions/array";
declare namespace validate = "http://basex.org/modules/validate";

declare namespace http = "http://expath.org/ns/http-client";

declare variable $releases := kd-utilities:get-releases();

http:send-request(<http:request method='head'/>,'http://coverartarchive.org/release/10aec700-aea3-4b8f-a74a-70fa5b8a8078/front')