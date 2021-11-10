# XQuery beadandó
## Téma: **MusicBrainz API**
### Válaszott zeneszerző:  **King Diamond**

## Tartalomjegyzék
1. [Tartalom](#tartalom)
2. [Fájlrendszer](#fájlrendszer)
3. [Feladatok](#feladatok)


10 feladaton keresztül bemutatni az XQuery lehetőségeit.  
## Tartalom:   
* 3 atomi érték visszadása
* 4 lekérdezés, ami standalone `XML` dokumentumot ad vissza, az XML-eket validálni kell
* 2 lekérdezés, ami `JSON`-t ad vissza
* 1 lekérdezés, ami önálló `HTML5` dokumentumot állít elő

## Fájlrendszer  
`. = $pwd`   
* ./xquery_demo.md -- a dolgozat megoldással
* ./make & ./make.bat -- dolgozat szkriptjeinek lefuttatása
* ./xml -- mappa az xml-s feladatok számára
* ./json --  mappa az json-s feladatok számára
* ./html5 --  mappa az html5 feladat számára
* ./html5/css -- Sass kimenet
* ./html5/scss -- scss források
* ./utilities -- másodlagos segédlekérdezések


## Feladatok:

A feladatok megoldásához előadóként _King Diamond_-ot választottam.  
A feladatok megoldása a MusicBrainzAPI alapján történt, illetve a webszolgáltatáshoz/webszolgáltatóhoz kapcsolodó Cover Art Archive alapján történt.  
[CovertArtArchive and MusicBrainzAPI info](https://musicbrainz.org/doc/Cover_Art)

Használt URI: [URI](https://musicbrainz.org/ws/2/release/?artist=00565b31-14a3-4913-bd22-385eb40dd13c&type=album&status=official&inc=labels+recordings&fmt=json&limit=50)

1. **Feladat:**  A _MusicBrainz API_ szerint King Diamond összes hivatalos albunának összesen 94 kiadása van. Igazoljuk ezt egy XQuery lekérdezéssel!</br>
Típus: **JSON**
```xquery
xquery version "3.1";

import module namespace kd-utilities = "http://kingdiamond.util" at "../utilities/init.xquery";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace array = "http://www.w3.org/2005/xpath-functions/array";

declare option output:method "json";
declare option output:indent "yes";

let $data := kd-utilities:get-releases()
return count(fn:distinct-values(array {for $index in 1 to array:size($data) return array:get($data,$index)?id}))
```
**Válasz kiemnet**
```json
94
```

2. **Feladat:** Készítsünk egy JSON tömböt, amely tartalmazza King Diamond _The Spider's Lullaby_ albumának egyik kiadásában szereplő zeneszámainak nevét! </br>
Típus: **JSON**
```xquery
xquery version "3.1";

import module namespace kd-utilities = "http://kingdiamond.util" at "../utilities/init.xquery";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace array = "http://www.w3.org/2005/xpath-functions/array";

declare option output:method "json";
declare option output:indent "yes";

declare variable $releases := kd-utilities:get-releases();

declare %private function local:mergeCDs($media as array(*), $index as xs:integer) as array(*)
{
    if (array:size($media) = $index)
    then array:get($media, $index)?tracks
    else array:join((array:get($media, $index)?tracks, local:mergeCDs($media, $index + 1))) 
};

let $spiders-lullaby := for $release in $releases?*
                        where $release?title = "The Spider's Lullabye" 
                        return  $release

let $mergedCDs := local:mergeCDs($spiders-lullaby[1]?media, 1)
          
return array {          
    for $songId in 1 to array:size($mergedCDs)
    return  array:get($mergedCDs, $songId)?title }       
```
**Válasz kiemnet**
```json
[
  "From the Other Side",
  "Killer",
  "The Poltergeist",
  "Dreams",
  "Moonlight",
  "Six Feet Under",
  "The Spider's Lullabye",
  "Eastmann's Cure",
  "Room 17",
  "To the Morgue",
  "Moonlight (demo)",
  "From the Other Side (demo)",
  "The Spider's Lullabye (demo)",
  "Dreams (demo)"
]
```
3. **Feladat:** Hányszor adták ki az _Abigal_ albumott 1999 előtt?</br>
Típus: ATOM
```xquery

```
**Válasz kiemnet**
```json

```

4. **Felada:**t </br>
Típus: JSON
```xquery
```
**Válasz kiemnet**
```json

```

5. Feladat </br>
Típus: JSON
```xquery
```
**Válasz kiemnet**
```json

```

6. Feladat </br>
Típus: XML
```xquery
```
**Válasz kiemnet**
```json

```

7. Feladat </br>
Típus: XML
```xquery
```
**Válasz kiemnet**
```json

```

8. Feladat </br>
Típus: XML
```xquery
```
**Válasz kiemnet**
```json

```

9. Feladat </br>
Típus: XML
```xquery
```
**Válasz kiemnet**
```json

```

10. Feladat </br>
Típus: HTML5
```xquery
```
**Válasz kiemnet**
```json

```