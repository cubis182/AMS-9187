xquery version "4.0";

(:NOTE THAT, FOR THE BASEX IMPLEMENTATION, SET WRITEBACK true IS NECESSARY FOR THIS TO WORK:)

import module namespace functx = "http://www.functx.com" at "http://www.xqueryfunctions.com/xq/functx-1.0.1-doc.xq";
(:In case it is being weird, get functx from:
C:/Program Files (x86)/BaseX/src/functx_lib.xqm
Website is:
s:)

let $dir := "C:/Users/T470s/Documents/2023-Fall-Semester/AMS 9187/"

return file:write(($dir || "pleiades-xml2.xml"), json:doc(($dir || "Pleiades/JSON (comprehensive)/Modified/pleiades-places2.json"), map{'format':'attributes'}))

(:fn:json-to-xml(file:read-text("C:/Users/T470s/Documents/2023-Fall-Semester/AMS 9187/Pleiades/JSON (comprehensive)/Modified/pleiades-places1.json")):)