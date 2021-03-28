# Soosiana content

This repository hosts the journal articles (PDF files and metadata) organized by volumes.
Metadata is provided as [BibJSON](http://okfnlabs.org/bibjson/).

## Structure

```
baseurl/                            # soosiana.github.io or custom url

baseurl/index.json                  # lists available volumes

baseurl/volume-:vol:/               # volume
baseurl/volume-:vol:/index.json     # lists articles in volume

baseurl/volume-:vol:/:article:.pdf  # article pdf
```

## PDF file naming

Front matter: `01_Soosiana_1973_1_I-IV`; articles: `02_Soosiana_1973_1_PinterI_1-3`.
`$FILE` is a concatenation of:

* ordering number (with leading 0s, `00`-`99`),
* `Soosiana` the journal name,
* year of publishing,
* volume (`1` or `10-11`),
* name of 1st author (1st name initial used when there are multiple authors with same last name),
* starting and ending page number (`:start:-:end:`, no leading 0s).

## Article BibJSON

```
[
  {
    "id": "$FILE",
    "title": "$TITLE",
    "author":[
        {"name": "$AUTHOR"}
    ],
    "type": "article",
    "year": "$YEAR",
    "journal": {
        "name": "Soosiana",
        "shortcode": "Soosiana",
        "id": "soosiana",
        "identifier": [
            {
                "id": "0133-7971",
                "type": "ISSN"
            }
        ],
        "volume": "$VOLUME",
        "pages": "$START--$END"
    },
    "link": [
        {
            "url":"https://soosiana.github.io/content/$VOLUME/$FILE.pdf"
        }
    ],
    "identifier": [
        {
            "type": "DOI",
            "id": "$DOI",
            "url": "https://doi.org/$DOI"
        }
    ],
    "license": [
        {
            "type": "CC BY 4.0",
            "url": "https://creativecommons.org/licenses/by/4.0/",
            "description": "Attribution 4.0 International",
            "jurisdiction": "universal"
        }
    ]
  },
  ...
]
```

## Authors

Adrás Varga scanned documents, Péter Sólymos organized files and created metadata.
