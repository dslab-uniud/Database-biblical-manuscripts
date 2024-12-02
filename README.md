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
* _City of origin_: The city where the manuscript is believed to have been written, which may differ from its current location. Optional.
* _Initial year_ and _final year_: The time range during which the manuscript was produced. Optional.
* _Date attribution notes_: Text notes providing details on the manuscript’s date attribution. Optional.
* _Decorations_: A boolean attribute indicating whether the manuscript contains decorations.
* _Writing style_: Specifies the manuscript’s writing style.
* _Musical_ notation_: A boolean attribute indicating the presence of musical notation in the text.
* _Collection_: Refers to the collection the manuscript belongs to or the language it was written in. If unknown, the default designation “MS” (Manuscript) is used.
* _Number_: Works with the collection attribute to identify a specific manuscript within a collection. Represented as an integer or alphanumeric string.
* _Digital edition_: A hyperlink to a digital reproduction of the manuscript, if available. Optional.
* _MS identifier_: A unique identifier derived by combining repository WD code, collection, and number. The siglum is used as the key for brevity.

**Book** represents a specific biblical book within a manuscript (e.g., Genesis or Exodus, tracked by the attribute _book_type_). It has the attribute _sequence number_, which indicates the book’s order within the manuscript. Since the sequence order depends on the manuscript, this entity is subordinate to Manuscript. Note that the relationship between Book and Manuscript is many-to-one: a specific book, as transcribed (including its unique errors and variations), belongs to one manuscript only, while a manuscript can contain multiple books.

**Book Element** represents a "generic" component of a book, which can be one of three types (attribute _element_type_): prologue, summary, and text. The structure is as follows:
* A book can contain up to five prologues, at most one summary, and exactly one text
* Books can exist without prologues and/or summaries
Each Book Element has a unique _ID_, which serves as the primary key within the database. The idea is that the ID ties the book element to a particular text (e.g., a specific prologue known in the domain). Thus, for example, two distinct prologues for the book of Genesis will have different _IDs_ to distinguish them from each other. Conversely, a prologue with a given _ID_ can appear in more than one book, represents the same shared textual content. Note how Book Element is a generic, abstract concept used to differentiate between element types and their defining textual content. 

**Includes** tracks the many-to-many relationship between a specific manuscript’s book and its elements. While the Book Element entity represents generic elements of a book, characterized by their type and uniquely identified by their text (via the ID attribute), linking a Book Element to a Book “materializes” it. This connection describes the attributes of the specific physical instance of the Book Element as it appears within the particular manuscript’s book. Such physical characteristics, such as the paratext, are described by the attributes: 
* _Element sequence order_: Indicates the order of the element within the book. The text is always the last element, while prologues and summaries are interchangeable.
* _Initial sheet_ and _final sheet_: Specify the starting and ending sheet of the element in the manuscript, defined by: _page number_ and _column_ (e.g., “ra” for recto-column a, “vb” for verso-column b). Values such as “om.” (omitted) or “lac.” (lacuna) are used for missing or damaged portions.
* _Initial heading_ and _final heading_: Represent the starting and ending headings of the element. These mix uppercase and lowercase letters to expand abbreviations, aiding text search. These attributes can also have “om.” or “lac.” values and are optional.
* _Running title_: An optional attribute for the abbreviated book title in the page margin.
* _Decorated initial letter_: An optional attribute indicating the presence of a decorated initial letter, which can also have “om.” or “lac.” values.
* _Stichometry_: An optional attribute recording the number of lines declared at the end of some texts.
* _Junction_: Indicates whether the element ends at a gathering’s junction. Values include:
** “True” (at the junction),
** “True with blank spaces” (ends with gaps),
** “Unconfirmed” (uncertainty due to lack of evidence),
** “False” (not at the junction).
* _Notes_: An optional textual field for additional information about the element.

## Usage of the online implementation of the system

TODO

