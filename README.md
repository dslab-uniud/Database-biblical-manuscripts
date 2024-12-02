# A Relational Database for Latin Biblical Manuscripts

## Description

This is the home page of the latin biblical manuscripts relational database project, developed within the Artificial Intelligence for Cultural Heritage (AI4CH) center and the Data Science and Automatic Verification Laboratory at the University of Udine, Italy.
The database aims to pose itself as an integrated and generalizable framework to store, manage and leverage information about the text and paratext of latin biblical manuscripts.

The current repository includes:
* an Excel file with the raw data about the biblical manuscripts: **TO-DO**
* the code to set up the database within a Postgres database instance: **TO-DO**
* the code to import the raw Excel file into the database: **TO-DO**
* the code of some queries that show how to use the database: **TO-DO**

The following picture reports the overall relational schema of the database:

<p align="center">
<img src="https://github.com/dslab-uniud/Database-biblical-manuscripts/blob/main/relational.png" alt="Overall Relational diagram" />
</p>

**Repository** is the entity that represents the current physical location of the manuscript, typically a library or a conservation institution. Its key is the *wd_code*, which consists of a unique alphanumeric code extracted from the [Wikidata portal](https://www.wikidata.org/wiki/Wikidata:Main_Page). The other attributes are _name_, _city_, and _country_, which respectively represent the name of the institution, the city, and the country where it is located.

**Manuscript** represents the physical manuscript, identified by the _siglum_, a unique identifier within this database (not universally unique). A manuscript is described by the following attributes:
	•	_City of origin_: The city where the manuscript is believed to have been written, which may differ from its current location. Optional.
	•	_Initial year_ and _final year_: The time range during which the manuscript was produced. Optional.
 	•	_Date attribution notes_: Text notes providing details on the manuscript’s date attribution. Optional.
	•	_Decorations_: A boolean attribute indicating whether the manuscript contains decorations.
	•	_Writing style_: Specifies the manuscript’s writing style.
	•	_Musical_ notation_: A boolean attribute indicating the presence of musical notation in the text.
	•	_Collection_: Refers to the collection the manuscript belongs to or the language it was written in. If unknown, the default designation “MS” (Manuscript) is used.
	•	_Number_: Works with the collection attribute to identify a specific manuscript within a collection. Represented as an integer or alphanumeric string.
	•	_Digital edition_: A hyperlink to a digital reproduction of the manuscript, if available. Optional.
	•	_MS identifier_: A unique identifier derived by combining repository WD code, collection, and number. The siglum is used as the key for brevity.

## Usage of the online implementation of the system

TODO

