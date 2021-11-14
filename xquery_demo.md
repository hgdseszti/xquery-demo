# XQuery beadandó
## Téma: **MusicBrainz API**
### Válaszott zeneszerző:  **King Diamond**

## Tartalomjegyzék
1. [Tartalom](#tartalom)
2. [Fájlrendszer](#fájlrendszer)
3. [Feladatok](#feladatok)

 
## Tartalom:   
* 3 atomi érték visszadása (JSON)
* 4 lekérdezés, ami standalone `XML` dokumentumot ad vissza, az XML-eket validálni kell
* 2 lekérdezés, ami `JSON`-t ad vissza
* 1 lekérdezés, ami önálló `HTML5` dokumentumot állít elő

## Fájlrendszer  
`. = $pwd`   
* ./xquery_demo.md -- a dolgozat megoldásokkal és kimenetekkel
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

**::FIGYELEM::** Az egyes XQuery lekérdezések futtatásához lépjünk a szkriptet tartalmazó mappába majd hívjuk meg a szkriptet a `basex` programmal.   
Például:  
```bash
pwd #/d/Development/xquery-demo
cd atomic
basex songs_tpl.xquery 
```

1. **Feladat:**  A _MusicBrainz API_ szerint King Diamond összes hivatalos albumának összesen 94 kiadása van. Igazoljuk ezt egy XQuery lekérdezéssel!</br>
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

2. **Feladat:** Készítsünk egy JSON tömböt, amely tartalmazza King Diamond _The Spider's Lullaby_ albumának egyik kiadásában szereplő zeneszámainak címét! </br>
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
3. **Feladat:** Hányszor adták ki az _Abigal_ albumot 1999 előtt?</br>
Típus: **JSON**
```xquery
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
```
**Válasz kiemnet**
```json
8
```

4. **Feladat:** Állítsuk elő azt a JSON dokumentumot, ami tartalmazza a kiadókat. A kiadókhoz adjuk meg a kiadott albumok címét, illetve kiadási dátumát. Rendezzük a kiadókon belül az albumokat kiadási dátumok szerint növekvő sorrendben!</br>
Típus: **JSON**
```xquery
xquery version "3.1";

import module namespace kd-utilities = "http://kingdiamond.util" at "../utilities/init.xquery";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace array = "http://www.w3.org/2005/xpath-functions/array";
declare namespace map = "http://www.w3.org/2005/xpath-functions/map";

declare option output:method "json";
declare option output:indent "yes";

declare variable $releases := kd-utilities:get-releases();
declare variable $labels := array:join(for $release in $releases?* return $release?label-info);

declare %private function local:array-contains($arr as array(*),$index as xs:integer, $item as xs:string) as xs:boolean
{
    if (array:size($arr) + 1 = $index)
    then false()
    else
       if (array:get($arr,$index)?label?name = $item)
       then true()
       else local:array-contains($arr, $index + 1, $item)
};

map:entry("publishers", array:join(
    let $labels := fn:distinct-values(for $label in $labels?* return $label?label?name)
    for $label in $labels
    order by $label
        return array { map {
            "publisher": $label,
            "releases": array {             
                for $release in $releases?*
                where local:array-contains($release?label-info, 1, $label)    
                order by $release?date
                return map {
                    "album-title" : $release?title,
                    "release-date": $release?date
                }
              }
             }}
           ))
```
**Válasz kiemnet**
```json
{
  "publishers": [
    {
      "releases": [
        {
          "release-date": "1989-10-05",
          "album-title": "Conspiracy"
        },
        {
          "release-date": "1990-10-21",
          "album-title": "Fatal Portrait"
        },
        {
          "release-date": "1990-10-21",
          "album-title": "Abigail"
        },
        {
          "release-date": "1990-12-16",
          "album-title": "The Eye"
        },
        {
          "release-date": "1992",
          "album-title": "In Concert 1987: Abigail"
        },
        {
          "release-date": "1993-01-21",
          "album-title": "A Dangerous Meeting"
        }
      ],
      "publisher": "Far East Metal Syndicate"
    },
    {
      "releases": [
        {
          "release-date": "1995-05-29",
          "album-title": "The Spider’s Lullabye"
        },
        {
          "release-date": "1996-09-20",
          "album-title": "The Graveyard"
        },
        {
          "release-date": "1998-02-23",
          "album-title": "Voodoo"
        },
        {
          "release-date": "2000-05-29",
          "album-title": "House of God"
        },
        {
          "release-date": "2001",
          "album-title": "Nightmares in the Nineties"
        },
        {
          "release-date": "2003",
          "album-title": "The Puppet Master"
        },
        {
          "release-date": "2003-10-20",
          "album-title": "The Puppet Master"
        },
        {
          "release-date": "2004-09-27",
          "album-title": "Deadly Lullabyes “Live”"
        },
        {
          "release-date": "2007",
          "album-title": "Give Me Your Soul… Please"
        },
        {
          "release-date": "2007-06-29",
          "album-title": "Give Me Your Soul… Please"
        },
        {
          "release-date": "2009-11-03",
          "album-title": "The Spider’s Lullabye"
        },
        {
          "release-date": "2009-11-03",
          "album-title": "The Graveyard"
        },
        {
          "release-date": "2009-11-16",
          "album-title": "Voodoo"
        },
        {
          "release-date": "2009-11-16",
          "album-title": "House of God"
        }
      ],
      "publisher": "Massacre Records"
    },
    {
      "releases": [
        {
          "release-date": "1995-08-25",
          "album-title": "The Spider’s Lullabye"
        }
      ],
      "publisher": "Mercury Records"
    },
    {
      "releases": [
        {
          "release-date": "1995-06-15",
          "album-title": "The Spider’s Lullabye"
        },
        {
          "release-date": "1995-08-25",
          "album-title": "The Spider’s Lullabye"
        },
        {
          "release-date": "1996",
          "album-title": "The Graveyard"
        },
        {
          "release-date": "1998",
          "album-title": "Voodoo"
        },
        {
          "release-date": "1998",
          "album-title": "Voodoo"
        },
        {
          "release-date": "2000",
          "album-title": "House of God"
        },
        {
          "release-date": "2000-06-20",
          "album-title": "House of God"
        },
        {
          "release-date": "2002",
          "album-title": "Abigail II: The Revenge"
        },
        {
          "release-date": "2002",
          "album-title": "Abigail II: The Revenge"
        },
        {
          "release-date": "2003-10-21",
          "album-title": "The Puppet Master"
        },
        {
          "release-date": "2007-06-26",
          "album-title": "Give Me Your Soul… Please"
        },
        {
          "release-date": "2009",
          "album-title": "The Spider’s Lullabye"
        },
        {
          "release-date": "2009",
          "album-title": "Voodoo"
        },
        {
          "release-date": "2014-11-11",
          "album-title": "Dreams of Horror"
        },
        {
          "release-date": "2015",
          "album-title": "The Spider's Lullabye"
        },
        {
          "release-date": "2015",
          "album-title": "The Spider's Lullabye"
        },
        {
          "release-date": "2015-05-04",
          "album-title": "In Concert 1987: Abigail"
        },
        {
          "release-date": "2017-12-01",
          "album-title": "In Concert 1987: Abigail (Live)"
        },
        {
          "release-date": "2018",
          "album-title": "“Them”"
        },
        {
          "release-date": "2018-05-18",
          "album-title": "Abigail"
        },
        {
          "release-date": "2018-05-18",
          "album-title": "“Them”"
        },
        {
          "release-date": "2018-05-18",
          "album-title": "Fatal Portrait"
        },
        {
          "release-date": "2019-01-25",
          "album-title": "Songs for the Dead Live"
        },
        {
          "release-date": "2019-01-25",
          "album-title": "Songs for the Dead: Live at the Fillmore in Philadelphia"
        },
        {
          "release-date": "2019-01-25",
          "album-title": "Songs for the Dead: Live at Graspop Metal Meeting"
        },
        {
          "release-date": "2019-01-25",
          "album-title": "Songs for the Dead: Live"
        },
        {
          "release-date": "2019-01-25",
          "album-title": "Songs for the Dead Live"
        },
        {
          "release-date": "2020-04-24",
          "album-title": "Abigail"
        },
        {
          "release-date": "2020-05-01",
          "album-title": "Conspiracy"
        },
        {
          "release-date": "2020-05-01",
          "album-title": "\"Them\""
        },
        {
          "release-date": "2020-05-15",
          "album-title": "The Eye"
        },
        {
          "release-date": "2020-05-15",
          "album-title": "“Them”"
        }
      ],
      "publisher": "Metal Blade Records"
    },
    {
      "releases": [
        {
          "release-date": "2015",
          "album-title": "Voodoo"
        }
      ],
      "publisher": "Metal Blade Records GmbH"
    },
    {
      "releases": [
        {
          "release-date": "2017-12-01",
          "album-title": "Conspiracy"
        }
      ],
      "publisher": "Metal Blade Records Inc."
    },
    {
      "releases": [
        {
          "release-date": "1995-06-15",
          "album-title": "The Spider’s Lullabye"
        },
        {
          "release-date": "1996",
          "album-title": "The Graveyard"
        },
        {
          "release-date": "1998",
          "album-title": "Voodoo"
        }
      ],
      "publisher": "Priority Records"
    },
    {
      "releases": [
        {
          "release-date": "1986",
          "album-title": "Fatal Portrait"
        },
        {
          "release-date": "1987",
          "album-title": "Abigail"
        },
        {
          "release-date": "1988",
          "album-title": "“Them”"
        }
      ],
      "publisher": "Roadracer Records"
    },
    {
      "releases": [
        {
          "release-date": "1986",
          "album-title": "Fatal Portrait"
        },
        {
          "release-date": "1986",
          "album-title": "Fatal Portrait"
        },
        {
          "release-date": "1986",
          "album-title": "Fatal Portrait"
        },
        {
          "release-date": "1987",
          "album-title": "Abigail"
        },
        {
          "release-date": "1987",
          "album-title": "Abigail"
        },
        {
          "release-date": "1988",
          "album-title": "“Them”"
        },
        {
          "release-date": "1988-07-18",
          "album-title": "\"Them\""
        },
        {
          "release-date": "1989",
          "album-title": "Conspiracy"
        },
        {
          "release-date": "1989",
          "album-title": "Conspiracy"
        },
        {
          "release-date": "1990",
          "album-title": "The Eye"
        },
        {
          "release-date": "1990",
          "album-title": "The Eye"
        },
        {
          "release-date": "1992",
          "album-title": "A Dangerous Meeting"
        },
        {
          "release-date": "1997",
          "album-title": "In Concert 1987: Abigail"
        },
        {
          "release-date": "1997",
          "album-title": "Abigail"
        },
        {
          "release-date": "1997",
          "album-title": "Conspiracy"
        },
        {
          "release-date": "1997",
          "album-title": "“Them”"
        },
        {
          "release-date": "1997",
          "album-title": "Fatal Portrait"
        },
        {
          "release-date": "1997",
          "album-title": "Abigail"
        },
        {
          "release-date": "1997",
          "album-title": "Abigail"
        },
        {
          "release-date": "1997",
          "album-title": "The Eye"
        },
        {
          "release-date": "1997-11-11",
          "album-title": "The Eye"
        },
        {
          "release-date": "1997-11-11",
          "album-title": "Abigail"
        },
        {
          "release-date": "1997-11-11",
          "album-title": "\"Them\""
        },
        {
          "release-date": "2003",
          "album-title": "Abigail"
        },
        {
          "release-date": "2003",
          "album-title": "Fatal Portrait"
        },
        {
          "release-date": "2003-09",
          "album-title": "The Best Of"
        },
        {
          "release-date": "2003-09-08",
          "album-title": "Two From the Vault: Fatal Portrait \/ Abigail"
        },
        {
          "release-date": "2004-01-27",
          "album-title": "Two From the Vault: “Them” \/ Conspiracy"
        },
        {
          "release-date": "2005-09-27",
          "album-title": "Abigail"
        },
        {
          "release-date": "2008-04-23",
          "album-title": "“Them”"
        },
        {
          "release-date": "2008-04-23",
          "album-title": "Abigail"
        },
        {
          "release-date": "2013-03-18",
          "album-title": "The Complete Roadrunner Collection 1986–1990"
        }
      ],
      "publisher": "Roadrunner Records"
    },
    {
      "releases": [
        {
          "release-date": "2002",
          "album-title": "Abigail II: The Revenge"
        }
      ],
      "publisher": "Фоно"
    }
  ]
}
```

5. **Feladat:**  </br>
Készítsük el azt a JSON dokumentumot, amit tartalmazza a 3 legnépszerűbb országot, ahol a legtöbb kiadás történt. Az országok mellé adjuk meg, hogy hány kiadással rendelkeznek, illetve melyik album a legnépszerűbb az adott országban és azt hányszor adták ki az adott országban!  
Típus: **JSON**  
```xquery
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
```
**Válasz kiemnet**
```json
{
  "response": [
    {
      "numberOfReleases": 89,
      "country": "United States",
      "mostPopularAlbum": {
        "count": 14,
        "title": "Abigail"
      }
    },
    {
      "numberOfReleases": 59,
      "country": "Europe",
      "mostPopularAlbum": {
        "count": 14,
        "title": "Abigail"
      }
    },
    {
      "numberOfReleases": 56,
      "country": "Germany",
      "mostPopularAlbum": {
        "count": 8,
        "title": "Conspiracy"
      }
    }
  ]
}
```

6. **Feladat:** Készítsük el _King Diamond_ diszkográfiájának XML reprezentációját! A diszkográfia albumonként tartalmazza a szerzőt, címét, zenedarabjainak címét és játékidejét percben, a hanghordozó típusát, illetve a kiadási évét. Ha egy albumnnak több kiadása is van, akkor a legelső kiadását tegyük a diszkográfiába! </br>
Típus: **XML**
```xquery
```
**Válasz kiemnet**
```xml

```

7. **Feladat:** </br>
Típus:  **XML**
```xquery
```
**Válasz kiemnet**
```xml

```

8. **Feladat:** </br>
Típus: **XML**
```xquery
```
**Válasz kiemnet**
```xml

```

9. **Feladat:** </br>
Típus: **XML**
```xquery
```
**Válasz kiemnet**
```xml

```

10. **Feladat:** </br>
Típus: **HTML5**
```xquery
```
**Válasz kiemnet**
```html5

```