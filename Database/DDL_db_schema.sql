create domain repository_code as varchar check (value like 'Q%');

create domain book_name as varchar check (value in ('Genesis', 'Exodus', 'Leviticus', 'Numeri', 'Deuteronomium', 'Iosue', 'Iudicum', 'Ruth', '1 Samuhel_1 Regum', '2 Samuhel_ 2 Regum',
'3 Regum_1 Malachim', '4 Regum_Malachim', '4 Regum_2 Malachim', 'Isaias', 'Hieremias', 'Lamentationes', 'Hiezechiel', 'Danihel', 'Osee', 'Iohel', 'Amos', 'Abdias', 'Ionas', 'Micha', 'Naum', 'Abacuc','Sofonias',
'Aggeus', 'Zaccharias', 'Malachi', 'Iob', 'Psalmi', 'Psalmus CLI', 'Proverbia', 'Ecclesiastes', 'Canticum canticorum', 'Sapientia', 'Sirach_Ecclesiasticus', '1 Paralipomenon', '2 Paralipomenon', 
'1 Ezras', '2 Ezras (Neemia)', 'Hester', 'Tobias', 'Iudith', '1 Macchabeorum', '2 Macchabeorum', 'Novum Testamentum', 'Baruch', 'Malachias', '2 Samuhel_2 Regum', 'Iona', '1 Ezras + 2 Ezras', 'Psalmi_Heb.'));

create domain element_type_format as varchar check (value in ('P','C','T'));

create domain junction_format as varchar check (value in ('x', '(x)', '?', '(?)', '/', '/?', '(/)', '(/?)', 'B'));

create table Repository(
	WD_code repository_code primary key,
	name varchar not null,
	city varchar not null,
	country varchar not null
);

create table Manuscript(
	siglum varchar primary key,
	repository_WD_code repository_code,
	place varchar,
	collection varchar not null,
	number varchar not null,
	initial_year integer check (initial_year <= final_year),
	final_year integer,
	notes varchar,
	decorations boolean not null,
	writing_style varchar not null,
	musical_notation boolean not null,
	height numeric,
	width numeric,
	size numeric,
	proportion numeric,
	digital_edition text,
	foreign key (repository_WD_code) references Repository(WD_code) on update cascade on delete restrict 
);

create view Manuscript_with_MS_identifier as select *, concat(repository_WD_code, ' ', collection, ' ', number) as MS_identifier from Manuscript; 

create table Book(
	manuscript_siglum varchar,
	sequence_number integer, 
	book_type book_name not null,
	incipit varchar, --sarà NN
	explicit varchar, --sarà NN
	primary key (manuscript_siglum, sequence_number),
	foreign key (manuscript_siglum) references Manuscript(siglum) on update cascade on delete restrict
);

create table Book_Element(
	id varchar primary key,
	book_type book_name not null,
	element_type element_type_format not null 
);

create table Includes(	
	book_manuscript_siglum varchar,
	book_sequence_number integer,
	book_element_id varchar,
	element_sequence_order integer not null,
	notes varchar,
	junction junction_format,
	stichometry integer,
	decoration_initial_letter varchar,
	running_title varchar,
	initial_heading varchar,
	final_heading varchar,
	marginal_numbering varchar, --sarà NN
	incipit_anomaly varchar,
	explicit_anomaly varchar,
	extra_biblical_books varchar,
	initial_sheet_page_number varchar not null check ( (initial_sheet_page_number ~ '^\d+(\.\d+)?$' and final_sheet_page_number ~ '^\d+(\.\d+)?$' 
	and cast(initial_sheet_page_number as decimal) <= cast(final_sheet_page_number as decimal)) or (not (initial_sheet_page_number ~ '^\d+(\.\d+)?$' and final_sheet_page_number ~ '^\d+(\.\d+)?$'))),
	initial_sheet_page_column varchar not null,
	final_sheet_page_number varchar not null,
	final_sheet_page_column varchar not null,
	primary key (book_manuscript_siglum,book_sequence_number,book_element_ID),
	foreign key (book_manuscript_siglum,book_sequence_number) references Book(manuscript_siglum,sequence_number) on update cascade on delete restrict,
	foreign key (book_element_id) references Book_Element(id) on update cascade on delete restrict
);
