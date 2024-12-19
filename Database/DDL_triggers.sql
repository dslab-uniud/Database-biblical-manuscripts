create or replace function duplicate_books_func()
returns trigger as $$
declare 
	n integer;
begin 
	select count(*) into n from Book where manuscript_siglum=new.manuscript_siglum and book_type=new.book_type;
	
	if n = 0 then 
		return new;
	else 
		raise exception 'The book % is already present', new.book_type;
	end if;
end;
$$language plpgsql; 


create trigger duplicate_books before insert or update
on Book 
for each row 
execute procedure duplicate_books_func();

------------------------------------------------------------------------------------------------

create or replace function mandatory_participation_manuscript_repository_func() 
returns trigger as $$
declare 
	n integer;
begin
	select count(*) into n from Manuscript where repository_WD_code=old.repository_WD_code;
	
	if TG_OP = 'UPDATE' then 
		if new.repository_WD_code != old.repository_WD_code then
			if n-1 = 0 then 
				raise exception 'There has to be at least one manuscript that is placed in %', old.repository_WD_code;
			end if; 
		end if;
	elsif TG_OP = 'DELETE' then 
		if n-1 = 0 then 
			raise exception 'There has to be at least one manuscript that is placed in %', old.repository_WD_code;
		end if;
	end if;
	return new;
end;
$$language plpgsql;


create trigger mandatory_participation_manuscript_repository before delete or update
on Manuscript 
for each row 
execute procedure mandatory_participation_manuscript_repository_func();

------------------------------------------------------------------------------------------------

create or replace function mandatory_participation_manuscript_repository_on_insert_func() 
returns trigger as $$
declare 
	n integer;
begin 
	select count(*) into n from Manuscript where repository_WD_code=new.WD_code;
	
	if n = 0 then 
		raise exception 'Insert at least one manuscript that is placed in %', new.WD_code;
	end if; 
	return new;
end;
$$language plpgsql;


create constraint trigger mandatory_participation_manuscript_repository_on_insert after insert
on Repository 
deferrable
for each row 
execute procedure mandatory_participation_manuscript_repository_on_insert_func();

------------------------------------------------------------------------------------------------

create or replace function mandatory_participation_manuscript_book_func() 
returns trigger as $$
declare 
	n integer;
begin 
	select count(*) into n from Book where manuscript_siglum=old.manuscript_siglum;
	
	if TG_OP = 'UPDATE' then 
		if (new.manuscript_siglum != old.manuscript_siglum and new.sequence_number != old.book_sequence_order) then
			if n-1 = 0 then 
				raise exception 'There has to be at least one book that belongs to %', old.manuscript_siglum;
			end if; 
		end if;
	elsif TG_OP = 'DELETE' then 
		if n-1 = 0 then 
			raise exception 'There has to be at least one book that belongs to %', old.manuscript_siglum;
		end if;
	end if;
	return new;
end;
$$language plpgsql;


create trigger mandatory_participation_manuscript_book before delete or update
on Book 
for each row 
execute procedure mandatory_participation_manuscript_book_func();

------------------------------------------------------------------------------------------------

create or replace function mandatory_participation_manuscript_book_on_insert_func() 
returns trigger as $$
declare 
	n integer;
begin 
	select count(*) into n from Book where manuscript_siglum=new.siglum;
	
	if n = 0 then 
		raise exception 'Insert at least one book that belongs to %', new.siglum;
	end if; 
	return new;
end;
$$language plpgsql;


create constraint trigger mandatory_participation_manuscript_book_on_insert after insert
on Manuscript 
deferrable
for each row
execute procedure mandatory_participation_manuscript_book_on_insert_func();

------------------------------------------------------------------------------------------------

create or replace function element_sequence_order_in_book_func()
returns trigger as $$
declare 
	n integer;
begin 
	select count(*) into n from Includes where 
	book_manuscript_siglum=new.book_manuscript_siglum and book_sequence_number=new.book_sequence_number
	and element_sequence_order=new.element_sequence_order;
	
	if n = 0 then 
		return new;
	elsif (TG_OP = 'UPDATE' and old.element_sequence_order=new.element_sequence_order) then
		return new;
	else
		raise exception 'The element % can''t be present in position %', new.book_element_ID, new.element_sequence_order;
	end if;
end;
$$language plpgsql; 


create trigger element_sequence_order_in_book before insert or update
on Includes 
for each row 
execute procedure element_sequence_order_in_book_func();

------------------------------------------------------------------------------------------------

create or replace function maximum_elements_admitted_func()
returns trigger as $$
declare 
	e_type varchar;
	n integer;
begin
	select element_type into e_type from Book_Element where ID=new.book_element_ID; 
	
		if e_type = 'P' then 
			select count(*) into n from Includes,Book_Element where ID=book_element_ID and 
			book_manuscript_siglum=new.book_manuscript_siglum and book_sequence_number=new.book_sequence_number and 
			element_type = 'P';
			if TG_OP = 'INSERT' then 
				if n < 5 then 
				return new;
				else 
					raise exception 'This book has reached the maximum number of prologi';
				end if;
			elsif TG_OP = 'UPDATE' then 
				return new;
			end if;
		end if;	
		
		if e_type = 'C' then 
			select count(*) into n from Includes,Book_Element where ID=book_element_ID and 
			book_manuscript_siglum=new.book_manuscript_siglum and book_sequence_number=new.book_sequence_number and 
			element_type = 'C';
			if TG_OP = 'INSERT' then 
				if n < 1 then 
				return new;
				else 
					raise exception 'This book has reached the maximum number of capitola';
				end if;
			elsif TG_OP = 'UPDATE' then 
				return new;
			end if;
		end if;
		
		if e_type = 'T' then 
			select count(*) into n from Includes,Book_Element where ID=book_element_ID and 
			book_manuscript_siglum=new.book_manuscript_siglum and book_sequence_number=new.book_sequence_number and 
			element_type = 'T';
			if TG_OP = 'INSERT' then 
				if n < 1 then 
				return new;
				else 
					raise exception 'This book has reached the maximum number of texts';
				end if;
			elsif TG_OP = 'UPDATE' then 
				return new;
			end if;
		end if;
end;
$$language plpgsql; 


create trigger maximum_elements_admitted before insert or update
on Includes 
for each row
execute procedure maximum_elements_admitted_func();