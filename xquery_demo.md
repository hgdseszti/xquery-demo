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

6. **Feladat:** Készítsük el _King Diamond_ diszkográfiájának XML reprezentációját! A diszkográfia albumonként tartalmazza a címét, zenedarabjainak címét és játékidejét percben, a hanghordozó típusát, illetve a kiadási évét. Ha egy albumnnak több kiadása is van, akkor a legelső kiadását tegyük a diszkográfiába! </br>
Típus: **XML**
```xquery
```
**Válasz kiemnet**
```xml
<discography>
  <albums count="27">
    <album title="In Concert 1987: Abigail" release-date="1991">
      <songs>
        <song name="Funeral" duration="1.94"/>
        <song name="Arrival" duration="5.79"/>
        <song name="Come to the Sabbath" duration="5.72"/>
        <song name="The Family Ghost" duration="4.42"/>
        <song name="The 7th Day of July 1777" duration="4.44"/>
        <song name="The Portrait" duration="4.78"/>
        <song name="Guitar Solo (Andy)" duration="3.32"/>
        <song name="The Possession" duration="4.14"/>
        <song name="Abigail" duration="4.46"/>
        <song name="Drum Solo" duration="3.43"/>
        <song name="The Candle" duration="6.02"/>
        <song name="No Presents for Christmas" duration="4.36"/>
      </songs>
    </album>
    <album title="The Graveyard" release-date="1996">
      <songs>
        <song name="The Graveyard" duration="1.37"/>
        <song name="Black Hill Sanitarium" duration="4.47"/>
        <song name="Waiting" duration="4.44"/>
        <song name="Heads on the Wall" duration="6.34"/>
        <song name="Whispers" duration="0.52"/>
        <song name="I’m Not a Stranger" duration="4.06"/>
        <song name="Digging Graves" duration="6.93"/>
        <song name="Meet Me at Midnight" duration="4.78"/>
        <song name="Sleep Tight Little Baby" duration="5.64"/>
        <song name="Daddy" duration="3.37"/>
        <song name="Trick or Treat" duration="5.16"/>
        <song name="Up From the Grave" duration="3.31"/>
        <song name="I Am" duration="5.85"/>
        <song name="Lucy Forever" duration="4.95"/>
      </songs>
    </album>
    <album title="The Eye" release-date="1990">
      <songs>
        <song name="Eye of the Witch" duration="3.8"/>
        <song name="The Trial (Chambre Ardente)" duration="5.22"/>
        <song name="Burn" duration="3.71"/>
        <song name="Two Little Girls" duration="2.68"/>
        <song name="Into the Convent" duration="4.8"/>
        <song name="Father Picard" duration="3.33"/>
        <song name="Behind These Walls" duration="3.75"/>
        <song name="The Meetings" duration="4.53"/>
        <song name="Insanity" duration="3.01"/>
        <song name="1642 Imprisonment" duration="3.52"/>
        <song name="The Curse" duration="5.73"/>
      </songs>
    </album>
    <album title="Abigail" release-date="1987">
      <songs>
        <song name="Funeral" duration="1.51"/>
        <song name="Arrival" duration="5.44"/>
        <song name="A Mansion in Darkness" duration="4.57"/>
        <song name="The Family Ghost" duration="4.1"/>
        <song name="The 7th Day of July 1777" duration="4.84"/>
        <song name="Omens" duration="3.94"/>
        <song name="The Possession" duration="3.44"/>
        <song name="Abigail" duration="4.84"/>
        <song name="Black Horsemen" duration="7.66"/>
      </songs>
    </album>
    <album title="Conspiracy" release-date="1989">
      <songs>
        <song name="At the Graves" duration="8.93"/>
        <song name="Sleepless Nights" duration="5.02"/>
        <song name="Lies" duration="4.32"/>
        <song name="A Visit From the Dead" duration="6.18"/>
        <song name="The Wedding Dream" duration="6"/>
        <song name="“Amon” Belongs to “Them”" duration="3.82"/>
        <song name="Something Weird" duration="2.05"/>
        <song name="Victimized" duration="5.32"/>
        <song name="Let It Be Done" duration="1.18"/>
        <song name="Cremation" duration="4.15"/>
      </songs>
    </album>
    <album title="Fatal Portrait" release-date="1986">
      <songs>
        <song name="The Candle" duration="6.67"/>
        <song name="The Jonah" duration="5.27"/>
        <song name="The Portrait" duration="5.13"/>
        <song name="Dressed in White" duration="3.14"/>
        <song name="Charon" duration="4.27"/>
        <song name="Lurking in the Dark" duration="3.58"/>
        <song name="Halloween" duration="4.23"/>
        <song name="Voices From the Past" duration="1.52"/>
        <song name="Haunted" duration="3.89"/>
        <song name="The Lake" duration="4.22"/>
      </songs>
    </album>
    <album title="The Spiders Lullabye" release-date="1995">
      <songs>
        <song name="From the Other Side" duration="3.83"/>
        <song name="Killer" duration="4.3"/>
        <song name="The Poltergeist" duration="4.5"/>
        <song name="Dreams" duration="4.65"/>
        <song name="Moonlight" duration="4.53"/>
        <song name="Six Feet Under" duration="4.03"/>
        <song name="The Spider’s Lullabye" duration="3.67"/>
        <song name="Eastmann’s Cure" duration="4.53"/>
        <song name="Room 17" duration="8.3"/>
        <song name="To the Morgue" duration="4.95"/>
      </songs>
    </album>
    <album title="Voodoo" release-date="1998">
      <songs>
        <song name="Louisiana Darkness" duration="1.72"/>
        <song name="&quot;LOA&quot; House" duration="5.55"/>
        <song name="Life After Death" duration="5.68"/>
        <song name="Voodoo" duration="4.57"/>
        <song name="A Secret" duration="4.07"/>
        <song name="Salem" duration="5.3"/>
        <song name="One Down Two to Go" duration="3.76"/>
        <song name="Sending of Dead" duration="5.67"/>
        <song name="Sarah's Night" duration="3.37"/>
        <song name="The Exorcist" duration="4.87"/>
        <song name="Unclean Spirits" duration="1.83"/>
        <song name="Cross of Baron Samedi" duration="4.49"/>
        <song name="If They Only Knew" duration="0.54"/>
        <song name="Aftermath" duration="10.54"/>
      </songs>
    </album>
    <album title="Them" release-date="1988">
      <songs>
        <song name="Out From the Asylum" duration="1.8"/>
        <song name="Welcome Home" duration="4.58"/>
        <song name="The Invisible Guests" duration="5.05"/>
        <song name="Tea" duration="5.22"/>
        <song name="Mother's Getting Weaker" duration="4"/>
        <song name="Bye, Bye, Missy" duration="5.1"/>
        <song name="A Broken Spell" duration="4.12"/>
        <song name="The Accusation Chair" duration="4.33"/>
        <song name="&quot;Them&quot;" duration="1.92"/>
        <song name="Twilight Symphony" duration="4.13"/>
        <song name="Coming Home" duration="1.18"/>
      </songs>
    </album>
    <album title="A Dangerous Meeting" release-date="1992">
      <songs>
        <song name="Funeral" duration="1.94"/>
        <song name="Arrival" duration="5.79"/>
        <song name="Come to the Sabbath" duration="5.72"/>
        <song name="The Family Ghost" duration="4.42"/>
        <song name="The 7th Day of July 1777" duration="4.44"/>
        <song name="The Portrait" duration="4.78"/>
        <song name="Guitar Solo (Andy)" duration="3.32"/>
        <song name="The Possession" duration="4.14"/>
        <song name="Abigail" duration="4.46"/>
        <song name="Drum Solo" duration="3.43"/>
        <song name="The Candle" duration="6.02"/>
        <song name="No Presents for Christmas" duration="4.36"/>
      </songs>
    </album>
    <album title="The Complete Roadrunner Collection 19861990" release-date="2013">
      <songs>
        <song name="The Candle" duration="6.7"/>
        <song name="The Jonah" duration="5.3"/>
        <song name="The Portrait" duration="5.15"/>
        <song name="Dressed in White" duration="3.17"/>
        <song name="Charon" duration="4.28"/>
        <song name="Lurking in the Dark" duration="3.6"/>
        <song name="Halloween" duration="4.25"/>
        <song name="Voices From the Past" duration="1.53"/>
        <song name="Haunted" duration="3.88"/>
        <song name="Funeral" duration="1.53"/>
        <song name="Arrival" duration="5.47"/>
        <song name="A Mansion in Darkness" duration="4.57"/>
        <song name="The Family Ghost" duration="4.08"/>
        <song name="The 7th Day of July 1777" duration="4.87"/>
        <song name="Omens" duration="3.97"/>
        <song name="The Possession" duration="3.47"/>
        <song name="Abigail" duration="4.87"/>
        <song name="Black Horsemen" duration="7.63"/>
        <song name="Out From the Asylum" duration="1.73"/>
        <song name="Welcome Home" duration="4.62"/>
        <song name="The Invisible Guests" duration="5.07"/>
        <song name="Tea" duration="5.25"/>
        <song name="Mother’s Getting Weaker" duration="4.03"/>
        <song name="Bye, Bye Missy" duration="5.13"/>
        <song name="A Broken Spell" duration="4.13"/>
        <song name="The Accusation Chair" duration="4.35"/>
        <song name="“Them”" duration="1.95"/>
        <song name="Twilight Symphony" duration="4.15"/>
        <song name="Coming Home" duration="1.17"/>
        <song name="At the Graves" duration="8.95"/>
        <song name="Sleepless Nights" duration="5.1"/>
        <song name="Lies" duration="4.4"/>
        <song name="A Visit From the Dead" duration="6.22"/>
        <song name="The Wedding Dream" duration="6.03"/>
        <song name="“Amon” Belongs to “Them”" duration="3.87"/>
        <song name="Something Weird" duration="2.13"/>
        <song name="Victimized" duration="5.37"/>
        <song name="Let It Be Done" duration="1.23"/>
        <song name="Cremation" duration="4.18"/>
        <song name="Eye of the Witch" duration="3.78"/>
        <song name="The Trial (Chambre Ardent)" duration="5.22"/>
        <song name="Burn" duration="3.7"/>
        <song name="Two Little Girls" duration="2.68"/>
        <song name="Into the Convent" duration="4.78"/>
        <song name="Father Picard" duration="3.32"/>
        <song name="Behind These Walls" duration="3.75"/>
        <song name="The Meetings" duration="4.52"/>
        <song name="Insanity" duration="3"/>
        <song name="1642 Imprisonment" duration="3.52"/>
        <song name="The Curse" duration="5.7"/>
      </songs>
    </album>
    <album title="Dreams of Horror" release-date="2014">
      <songs>
        <song name="The Candle" duration=""/>
        <song name="Dressed in White" duration=""/>
        <song name="The Family Ghost" duration=""/>
        <song name="Black Horsemen" duration=""/>
        <song name="Welcome Home" duration=""/>
        <song name="The Invisible Guests" duration=""/>
        <song name="At the Graves" duration=""/>
        <song name="Sleepless Nights" duration=""/>
        <song name="Let It Be Done" duration=""/>
        <song name="Eye of the Witch" duration=""/>
        <song name="Insanity" duration=""/>
        <song name="Dreams" duration=""/>
        <song name="Shapes of Black" duration=""/>
        <song name="The Spider’s Lullabye" duration=""/>
        <song name="Waiting" duration=""/>
        <song name="Heads on the Wall" duration=""/>
        <song name="Voodoo" duration=""/>
        <song name="Black Devil" duration=""/>
        <song name="Help!!!" duration=""/>
        <song name="Spirits" duration=""/>
        <song name="Blue Eyes" duration=""/>
        <song name="The Puppet Master" duration=""/>
        <song name="Never Ending Hill" duration=""/>
      </songs>
    </album>
    <album title="The Puppet Master" release-date="2003">
      <songs>
        <song name="Funeral" duration="1.5"/>
        <song name="Arrival" duration="5.44"/>
        <song name="A Mansion in Darkness" duration="4.57"/>
        <song name="The Family Ghost" duration="4.1"/>
        <song name="The 7th Day of July 1777" duration="4.84"/>
        <song name="Omens" duration="3.94"/>
        <song name="The Possession" duration="3.44"/>
        <song name="Abigail" duration="4.85"/>
        <song name="Black Horsemen" duration="7.67"/>
        <song name="Shrine" duration="4.39"/>
        <song name="A Mansion in Darkness (rough mix)" duration="4.59"/>
        <song name="The Family Ghost (rough mix)" duration="4.16"/>
        <song name="The Possession (rough mix)" duration="3.48"/>
      </songs>
    </album>
    <album title="Two From the Vault: Fatal Portrait / Abigail" release-date="2003">
      <songs>
        <song name="Funeral" duration="1.5"/>
        <song name="Arrival" duration="5.44"/>
        <song name="A Mansion in Darkness" duration="4.57"/>
        <song name="The Family Ghost" duration="4.1"/>
        <song name="The 7th Day of July 1777" duration="4.84"/>
        <song name="Omens" duration="3.94"/>
        <song name="The Possession" duration="3.44"/>
        <song name="Abigail" duration="4.85"/>
        <song name="Black Horsemen" duration="7.67"/>
        <song name="Shrine" duration="4.39"/>
        <song name="A Mansion in Darkness (rough mix)" duration="4.59"/>
        <song name="The Family Ghost (rough mix)" duration="4.16"/>
        <song name="The Possession (rough mix)" duration="3.48"/>
      </songs>
    </album>
    <album title="Give Me Your Soul Please" release-date="2007">
      <songs>
        <song name="The Dead" duration="1.95"/>
        <song name="Never Ending Hill" duration="4.61"/>
        <song name="Is Anybody Here?" duration="4.21"/>
        <song name="Black of Night" duration="4.01"/>
        <song name="Mirror Mirror" duration="4.99"/>
        <song name="The Cellar" duration="4.51"/>
        <song name="Pictures in Red" duration="1.46"/>
        <song name="Give Me Your Soul" duration="5.48"/>
        <song name="The Floating Head" duration="4.78"/>
        <song name="Cold as Ice" duration="4.49"/>
        <song name="Shapes of Black" duration="4.37"/>
        <song name="The Girl in the Bloody Dress" duration="5.12"/>
        <song name="Moving On" duration="4.11"/>
      </songs>
    </album>
    <album title="Abigail II: The Revenge" release-date="2002">
      <songs>
        <song name="Spare This Life" duration="1.74"/>
        <song name="The Storm" duration="4.37"/>
        <song name="Mansion in Sorrow" duration="3.6"/>
        <song name="Miriam" duration="5.17"/>
        <song name="Little One" duration="4.53"/>
        <song name="Slippery Stairs" duration="5.17"/>
        <song name="The Crypt" duration="4.19"/>
        <song name="Broken Glass" duration="4.22"/>
        <song name="More Than Pain" duration="2.53"/>
        <song name="The Wheelchair" duration="5.32"/>
        <song name="Spirits" duration="4.96"/>
        <song name="Mommy" duration="6.44"/>
        <song name="Sorry Dear" duration="0.9"/>
      </songs>
    </album>
    <album title="Deadly Lullabyes Live" release-date="2004">
      <songs>
        <song name="Funeral" duration="2.61"/>
        <song name="A Mansion in Darkness" duration="4.63"/>
        <song name="The Family Ghost" duration="4.59"/>
        <song name="Black Horsemen" duration="8.05"/>
        <song name="Spare This Life" duration="1.68"/>
        <song name="Mansion in Sorrow" duration="3.87"/>
        <song name="Spirits" duration="5.3"/>
        <song name="Sorry Dear" duration="1.12"/>
        <song name="Eye of the Witch" duration="4.4"/>
        <song name="Sleepless Nights" duration="5.69"/>
        <song name="The Puppet Master" duration="5.85"/>
        <song name="Blood to Walk" duration="5.85"/>
        <song name="So Sad" duration="4.7"/>
        <song name="Living Dead (outro)" duration="1.69"/>
        <song name="Welcome Home" duration="5.83"/>
        <song name="The Invisible Guests" duration="5.56"/>
        <song name="Burn" duration="4.62"/>
        <song name="Introductions" duration="1.69"/>
        <song name="Halloween" duration="5.65"/>
        <song name="No Presents for Christmas" duration="6.81"/>
      </songs>
    </album>
    <album title="Nightmares in the Nineties" release-date="2001">
      <songs>
        <song name="From the Other Side" duration="3.82"/>
        <song name="Waiting" duration="4.46"/>
        <song name="The Exorcist" duration="4.85"/>
        <song name="Eastmann’s Cure" duration="4.54"/>
        <song name="Just a Shadow" duration="4.61"/>
        <song name="Cross of Baron Samedi" duration="4.5"/>
        <song name="Trick or Treat" duration="5.17"/>
        <song name="One Down Two to Go" duration="3.76"/>
        <song name="Catacomb" duration="5.03"/>
        <song name="Six Feet Under" duration="4.01"/>
        <song name="Lucy Forever" duration="4.92"/>
        <song name="The Trees Have Eyes" duration="4.78"/>
        <song name="“LOA” House" duration="5.55"/>
        <song name="Peace of Mind" duration="2.49"/>
      </songs>
    </album>
    <album title="House of God" release-date="2000">
      <songs>
        <song name="Upon the Cross" duration="1.74"/>
        <song name="The Trees Have Eyes" duration="4.77"/>
        <song name="Follow the Wolf" duration="4.46"/>
        <song name="House of God" duration="5.6"/>
        <song name="Black Devil" duration="4.47"/>
        <song name="The Pact" duration="4.17"/>
        <song name="Goodbye" duration="1.98"/>
        <song name="Just a Shadow" duration="4.6"/>
        <song name="Help!!!" duration="4.35"/>
        <song name="Passage to Hell" duration="1.98"/>
        <song name="Catacomb" duration="5.02"/>
        <song name="This Place Is Terrible" duration="5.57"/>
        <song name="Peace of Mind" duration="2.52"/>
      </songs>
    </album>
    <album title="Two From the Vault: Them / Conspiracy" release-date="2004">
      <songs>
        <song name="Funeral" duration="2.61"/>
        <song name="A Mansion in Darkness" duration="4.63"/>
        <song name="The Family Ghost" duration="4.59"/>
        <song name="Black Horsemen" duration="8.05"/>
        <song name="Spare This Life" duration="1.68"/>
        <song name="Mansion in Sorrow" duration="3.87"/>
        <song name="Spirits" duration="5.3"/>
        <song name="Sorry Dear" duration="1.12"/>
        <song name="Eye of the Witch" duration="4.4"/>
        <song name="Sleepless Nights" duration="5.69"/>
        <song name="The Puppet Master" duration="5.85"/>
        <song name="Blood to Walk" duration="5.85"/>
        <song name="So Sad" duration="4.7"/>
        <song name="Living Dead (outro)" duration="1.69"/>
        <song name="Welcome Home" duration="5.83"/>
        <song name="The Invisible Guests" duration="5.56"/>
        <song name="Burn" duration="4.62"/>
        <song name="Introductions" duration="1.69"/>
        <song name="Halloween" duration="5.65"/>
        <song name="No Presents for Christmas" duration="6.81"/>
      </songs>
    </album>
    <album title="The Best Of" release-date="2003">
      <songs>
        <song name="Funeral" duration="1.5"/>
        <song name="Arrival" duration="5.44"/>
        <song name="A Mansion in Darkness" duration="4.57"/>
        <song name="The Family Ghost" duration="4.1"/>
        <song name="The 7th Day of July 1777" duration="4.84"/>
        <song name="Omens" duration="3.94"/>
        <song name="The Possession" duration="3.44"/>
        <song name="Abigail" duration="4.85"/>
        <song name="Black Horsemen" duration="7.67"/>
        <song name="Shrine" duration="4.39"/>
        <song name="A Mansion in Darkness (rough mix)" duration="4.59"/>
        <song name="The Family Ghost (rough mix)" duration="4.16"/>
        <song name="The Possession (rough mix)" duration="3.48"/>
      </songs>
    </album>
    <album title="In Concert 1987: Abigail (Live)" release-date="2017">
      <songs>
        <song name="Funeral (Live)" duration="1.92"/>
        <song name="Arrival (Live)" duration="5.78"/>
        <song name="Come to the Sabbath (Live)" duration="5.72"/>
        <song name="The Family Ghost (Live)" duration="4.42"/>
        <song name="The 7th Day of July 1777 (Live)" duration="4.42"/>
        <song name="The Portrait (Live)" duration="4.78"/>
        <song name="Guitar Solo (Andy LaRocque) (Live)" duration="3.6"/>
        <song name="The Possession (Live)" duration="3.83"/>
        <song name="Abigail (Live)" duration="4.48"/>
        <song name="Drum Solo (Mikkey Dee) (Live)" duration="3.4"/>
        <song name="The Candle (Live)" duration="6.02"/>
        <song name="No Presents for Christmas (Live)" duration="4.38"/>
      </songs>
    </album>
    <album title="Songs for the Dead Live" release-date="2019">
      <songs>
        <song name="Out from the Asylum" duration="1.98"/>
        <song name="Welcome Home" duration="4.7"/>
        <song name="Sleepless Nights" duration="5.08"/>
        <song name="Eye of the Witch" duration="4.42"/>
        <song name="Halloween" duration="4.93"/>
        <song name="Melissa" duration="6.5"/>
        <song name="Come to the Sabbath" duration="5.72"/>
        <song name="Them" duration="1.98"/>
        <song name="Funeral" duration="1.47"/>
        <song name="Arrival" duration="5.58"/>
        <song name="A Mansion in Darkness" duration="4.67"/>
        <song name="The Family Ghost" duration="4.65"/>
        <song name="The 7th Day of July 1777" duration="5.1"/>
        <song name="Omens" duration="4.2"/>
        <song name="The Possession" duration="3.7"/>
        <song name="Abigail" duration="5.45"/>
        <song name="Black Horsemen" duration="7.85"/>
        <song name="Insanity" duration="1.85"/>
      </songs>
    </album>
    <album title="The Spider's Lullabye" release-date="2015">
      <songs>
        <song name="Funeral" duration="1.87"/>
        <song name="Arrival" duration="5.42"/>
        <song name="Come to the Sabbath" duration="5.82"/>
        <song name="The Family Ghost" duration="4.48"/>
        <song name="The 7th Day of July 1777" duration="4.3"/>
        <song name="The Portrait" duration="4.48"/>
        <song name="Guitar Solo Andy" duration="3.27"/>
        <song name="The Possession" duration="3.88"/>
        <song name="Abigail" duration="4.75"/>
        <song name="Drum Solo" duration="3.42"/>
        <song name="The Candle" duration="5.33"/>
        <song name="No Presents for Christmas" duration="5.08"/>
      </songs>
    </album>
    <album title="Songs for the Dead: Live at the Fillmore in Philadelphia" release-date="2019">
      <songs>
        <song name="Out from the Asylum" duration="1.98"/>
        <song name="Welcome Home" duration="4.7"/>
        <song name="Sleepless Nights" duration="5.08"/>
        <song name="Eye of the Witch" duration="4.42"/>
        <song name="Halloween" duration="4.93"/>
        <song name="Melissa" duration="6.5"/>
        <song name="Come to the Sabbath" duration="5.72"/>
        <song name="Them" duration="1.98"/>
        <song name="Funeral" duration="1.47"/>
        <song name="Arrival" duration="5.58"/>
        <song name="A Mansion in Darkness" duration="4.67"/>
        <song name="The Family Ghost" duration="4.65"/>
        <song name="The 7th Day of July 1777" duration="5.1"/>
        <song name="Omens" duration="4.2"/>
        <song name="The Possession" duration="3.7"/>
        <song name="Abigail" duration="5.45"/>
        <song name="Black Horsemen" duration="7.85"/>
        <song name="Insanity" duration="1.85"/>
      </songs>
    </album>
    <album title="Songs for the Dead: Live at Graspop Metal Meeting" release-date="2019">
      <songs>
        <song name="Out from the Asylum" duration="1.98"/>
        <song name="Welcome Home" duration="4.7"/>
        <song name="Sleepless Nights" duration="5.08"/>
        <song name="Eye of the Witch" duration="4.42"/>
        <song name="Halloween" duration="4.93"/>
        <song name="Melissa" duration="6.5"/>
        <song name="Come to the Sabbath" duration="5.72"/>
        <song name="Them" duration="1.98"/>
        <song name="Funeral" duration="1.47"/>
        <song name="Arrival" duration="5.58"/>
        <song name="A Mansion in Darkness" duration="4.67"/>
        <song name="The Family Ghost" duration="4.65"/>
        <song name="The 7th Day of July 1777" duration="5.1"/>
        <song name="Omens" duration="4.2"/>
        <song name="The Possession" duration="3.7"/>
        <song name="Abigail" duration="5.45"/>
        <song name="Black Horsemen" duration="7.85"/>
        <song name="Insanity" duration="1.85"/>
      </songs>
    </album>
    <album title="Songs for the Dead: Live" release-date="2019">
      <songs>
        <song name="Out from the Asylum" duration="1.98"/>
        <song name="Welcome Home" duration="4.7"/>
        <song name="Sleepless Nights" duration="5.08"/>
        <song name="Eye of the Witch" duration="4.42"/>
        <song name="Halloween" duration="4.93"/>
        <song name="Melissa" duration="6.5"/>
        <song name="Come to the Sabbath" duration="5.72"/>
        <song name="Them" duration="1.98"/>
        <song name="Funeral" duration="1.47"/>
        <song name="Arrival" duration="5.58"/>
        <song name="A Mansion in Darkness" duration="4.67"/>
        <song name="The Family Ghost" duration="4.65"/>
        <song name="The 7th Day of July 1777" duration="5.1"/>
        <song name="Omens" duration="4.2"/>
        <song name="The Possession" duration="3.7"/>
        <song name="Abigail" duration="5.45"/>
        <song name="Black Horsemen" duration="7.85"/>
        <song name="Insanity" duration="1.85"/>
      </songs>
    </album>
  </albums>
</discography>
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