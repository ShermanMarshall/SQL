(in content_title varchar(255),
in content_grouping varchar(255),
in content_type char(1),
in content_subjects varchar(255),
in content_date char(10),
in content_content text,
out status varchar(8))
begin
declare group_id int default 0;
declare content_id int default 0;
declare group_count int default 0;
declare content_count int default 0;
declare done int default 0;
declare v_g_id cursor for select g_id from personal.groupings where name=content_grouping;
declare v_c_id cursor for select c_id from personal.content where title=content_title and g_id=group_id and type=content_type;
declare continue handler for not found set done=true;
select SQL_CALC_FOUND_ROWS * from personal.groupings where name=content_grouping;
set group_count = FOUND_ROWS();
if group_count > 0 then
	open v_g_id;
	fetch v_g_id into group_id;
	select SQL_CALC_FOUND_ROWS * from personal.content where type=content_type and g_id=group_id and title=content_title;
	set content_count = FOUND_ROWS();
	if content_count > 0 then
		open v_c_id;
		fetch v_c_id into content_id;
		if content_type = 'B' then
			update personal.blogs set content=content_content, subjects=content_subjects where c_id=content_id;
			update personal.content set date=content_date where c_id=content_id;
		elseif content_type='N' then
			update personal.notes set content=content_content, subjects=content_subjects where c_id=content_id;
			update personal.content set date=content_date where c_id=content_id;
		elseif content_type = 'P' then
			update personal.projects set content=content_content, subjects=content_subjects where c_id=content_id;
			update personal.content set date=content_date where c_id=content_id;
		end if;
	set status = 'Success';
	else
		insert into personal.content values (0, content_type, group_id, content_title, content_date);
		select c_id into content_id from personal.content where type=content_type and g_id=group_id and title=content_title;
		if content_id > 0 then
			if content_type = 'B' then
				insert into personal.blogs values (0, content_id, content_content, content_subjects);
				elseif content_type = 'N' then
					insert into personal.notes values (0, content_id, content_content, content_subjects);
				elseif content_type = 'P' then
					insert into personal.projects values (0, content_id, content_content, content_subjects);
			end if;
			set status = 'Success';
		else
			set status = 'Error';
		end if;
	end if;
else
	insert into personal.groupings values (0, content_grouping);
	select g_id into group_id from personal.groupings where name=content_grouping;
	if group_id > 0 then
		insert into personal.content values (0, content_type, group_id, content_title, content_date);
		select c_id into content_id from personal.content where g_id=group_id and title=content_title and type=content_type;
		if content_id > 0 then
			if content_type = 'B' then
				insert into personal.blogs values (0, content_id, content_content, content_subjects);
			elseif content_type = 'N' then
				insert into personal.notes values (0, content_id, content_content, content_subjects);
			elseif content_type = 'P' then
				insert into personal.projects values (0, content_id, content_content, content_subjects);
			end if;
			set status = 'Success';
		else
			set status = 'Error';
		end if;
	else
		set status = 'Error';
	end if;
end if;
