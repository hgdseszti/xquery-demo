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
* ./xml -- mappa az xml-s feladatok számára, ./make hozza létre
* ./json -- same
* ./html5 -- same
* ./html5/css -- Sass kimenet
* ./html5/scss -- scss források
* ./init.xq -- Make által futtatva, feladatok hajt végre
* ./utilities -- másodlagos segédlekérdezések


## Feladatok:

A feladatok megoldásához előadóként _King Diamond_-ot választottam.  
A feladatok megoldása a MusicBrainzAPI alapján történt, illetve a webszolgáltatáshoz/webszolgáltatóhoz kapcsolodó Cover Art Archive alapján történt.  
[CovertArtArchive and MusicBrainzAPI info](https://musicbrainz.org/doc/Cover_Art)

Használt URI: [URI](https://musicbrainz.org/ws/2/release/?artist=00565b31-14a3-4913-bd22-385eb40dd13c&type=album&status=official&inc=labels+recordings&fmt=json&limit=50)

1. **Feladat:**  A _MusicBrainz API_ szerint King Diamond összes hivatalos albunának összesen 94 kiadása van. Igazoljuk ezt egy XQuery lekérdezéssel!</br>
Típus: **ATOM**
```xquery
nem
```

2. **Feladat:** Készítsünk egy szekvenciát, amely tartalmazza King Diamond _The Spider's Lullaby_ albumának zeneszámainak nevét! </br>
Típus: ATOM
```xquery
nem
```

3. **Feladat:** Hányszor adták ki az _Abigal_ albumott 1999 előtt?</br>
Típus: ATOM
```xquery
nem
```

4. **Felada:**t </br>
Típus: JSON
```xquery
nem
```

5. Feladat </br>
Típus: JSON
```xquery
nem
```

6. Feladat </br>
Típus: XML
```xquery
nem
```

7. Feladat </br>
Típus: XML
```xquery
nem
```

8. Feladat </br>
Típus: XML
```xquery
nem
```

9. Feladat </br>
Típus: XML
```xquery
nem
```

10. Feladat </br>
Típus: HTML5
```xquery
nem
```