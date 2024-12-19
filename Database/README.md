Here we collect the SQL DDL code to deploy the database.

In addition some exemplary SQL queries that can be run against the database are as follows.

<br />

**Determine all summaries of Genesis.** This type of query allows the identification of the various types of introductory paratexts (prologues and chapter headings) associated with the same biblical book, allowing for an examination of the diversity of editorial arrangements across different manuscripts.
```
select id as book_element_id
from book_element
where book_type='Genesis' and element_type='C';
```


**Determine all summaries from series A.** Such queries allow for the cross-sectional verification of the presence of capitula across the various biblical books identified by De Bruyne with the same letter. The search can be restricted to a single biblical book by specifying its reference abbreviation in the query (e.g., \_Gn) according to the conventions of the Weber-Gryson edition, or by filtering on the attribute book_type.
```
select id as book_element_id, book_type 
from book_element 
where element_type='C' and id like 'A\_%';
```


**Determine which prologues are associated with books named Genesis, and their respective frequencies.** This query provides a ranked view of the distribution of paratexts (prologues or chapter headings) for a specific biblical book, emphasizing the relative prevalence of distinct editorial choices within the manuscript tradition.
```
with 
  gbooks as (
    select *
    from book
    where book.book_type = 'Genesis'
  ),
  tmp_res as (
    select
      book_element.id as prologue_id
    , count(*) as asbsolute_occurrences
    from gbooks
          join includes on (gbooks.manuscript_siglum = includes.book_manuscript_siglum
                            and gbooks.sequence_number = includes.book_sequence_number)
          join book_element on includes.book_element_id = book_element.id
    where book_element.element_type = 'P'
    group by book_element.id
  )
select 
   tmp_res.*
,  round(tmp_res.asbsolute_occurrences/(select sum(asbsolute_occurrences)
                                        from tmp_res),2) as rel_occurences
from tmp_res
order by rel_occurences desc;
```


**Determine the initial and final headings of the book Canticum canticorum for all manuscripts in which it is present.** This type of query allows for a synoptic visualization of the initial and final headings of a specific biblical book, enabling the identification of discontinuities and potential affinities, particularly in the case of more elaborate headings than the standard formula (incipit liber...explicit liber). These may contain valuable information; for instance, benevolent formulas (such as Deo gratias or Amen) could point to an earlier exemplar where such formulas marked the beginning or end of an independent volume, which was later incorporated into a larger or differently composed collection.
The same query can be adapted to analyze the initial and final headings of both prologues and capitula.
```
select 
    I.book_manuscript_siglum as manuscript_siglum
,   I.initial_heading
,   I.final_heading 
from includes I 
       join book B on (I.book_manuscript_siglum=B.manuscript_siglum 
                       and I.book_sequence_number=B.sequence_number) 
where B.book_type='Canticum canticorum';
```


**Determine the relative order in which the books ‘1 Ezras,’ ‘2 Ezras (Neemia),’ ‘Iudith,’ ‘Hester,’ and ‘Tobias’ are presented in the manuscripts, considering only the manuscripts that contain at least one of these books.**  This more complex type of query addresses one of the fundamental research questions outlined earlier: the relationship between the canon expressed by individual biblical manuscripts and their arrangement, including codicological aspects, whether they are bibliothecae or pandectae, incorporating earlier partial collections. This aligns, for instance, with reflections on the 'modular' structure of Atlantic Bibles.
The example provided focuses on a group of biblical books characterized by significant instability in their presence and relative order. This instability can be traced back to Jerome's editorial project for the Vulgate and his adherence to the Hebraica veritas. Tobit, Judith, and parts of Esther belong, in fact, to the so-called deuterocanonical books, included in the Greek Septuagint translation but absent from the Hebrew canon. However, Jerome agreed to translate them, indirectly validating their inclusion in Vulgate manuscripts. Nonetheless, their sequence oscillates, which also impacts the complex dossier of the book of Ezra.
```
select 
   B.manuscript_siglum as man_siglum
,  row_number() over (partition by B.manuscript_siglum
                      order by B.sequence_number) as rel_order 
,  B.book_type
,  min(initial_sheet_page_number) as i_sheet
,  min(initial_sheet_page_column) as i_column
,  max(final_sheet_page_number) as f_sheet
,  max(final_sheet_page_column) as f_column
from book B
      join includes on (B.manuscript_siglum =includes.book_manuscript_siglum
  		        and B.sequence_number =  includes.book_sequence_number)
where B.book_type in ('1 Ezras', '2 Ezras (Neemia)', 'Iudith', 'Hester', 'Tobias')
group by B.manuscript_siglum, B.sequence_number;
```



**Determine the difference between two manuscripts in terms of book ordering, considering only the books they have in common.** We focus on a specific pair of manuscripts, identified by “Amt” and “Sg1.” First, we identify all books they have in common, beginning with those in “Amt.” For each shared book, we calculate its relative order of appearance within only the shared ones, and we also report its complete sequence within the manuscript. We then repeat this procedure for the “Sg1” manuscript. 
Next, we pinpoint all cases where the two manuscripts present different books occupying the same relative position in their respective sequences. In each such case, we list the book as it appears in “Amt” and provide its full order of appearance, comparing it to its full order in “Sg1.” On the same row, we also record the counterpart book that “Sg1” places in the same relative position, along with the location of that book in the “Amt” manuscript.
For the two manuscripts considered, from the query we obtain 17 rows over a total number of shared books of 32. Note that, starting from a similar query, it is possible to calculate an "index of diversity" between manuscripts, for instance, drawing inspiration from the Kendall tau rank distance, which represents the number of element swaps needed to transform one list into another.
```
with
  manuscript_1 as (
    select 
      book_type
    , row_number() over (partition by manuscript_siglum 
                         order by sequence_number) as rel_order
    , sequence_number as book_order
    from book 
    where manuscript_siglum = 'Amt'
          and book_type IN (select book_type
                            from book
                            where manuscript_siglum = 'Sg1')
  ),
  manuscript_2 as (
    select
      book_type
    , row_number() over (partition by manuscript_siglum 
                         order by sequence_number) as rel_order
    , sequence_number as book_order
    from book 
    where manuscript_siglum = 'Sg1'
          and book_type IN (select book_type
                            from book
                            where manuscript_siglum = 'Amt')
  )
select
   m1.book_type as b1_m1
,  m1.book_order as b1_m1_order
,  m1b.book_order as b1_m2_order
,  m2.book_type as b2_m2
,  m2.book_order as b2_m2_order
,  m2b.book_order as b2_m1_order
from manuscript_1 m1
        join manuscript_2 m2 on (m2.rel_order = m1.rel_order 
                                and m1.book_type < m2.book_type)
	join manuscript_2 m1b on m1b.book_type = m1.book_type
	join manuscript_1 m2b on m2b.book_type = m2.book_type;
```
