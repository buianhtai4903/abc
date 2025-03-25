create proc aaa
@a int
as
	begin
		if not exists(
		select
		from 
		where
		)
		begin
			print 'a'
			return 1
		end

		select
		from
		where
		group by
	end

	exec aaa 2;

create function bbb (@b int)
returns table
as
return(
	select
	from
	where
	)
go

create function ccc (@c int)
returns @ccc table (ac int, bc int, cc int)
as
	begin
		insert into @ccc
		select 
		from 
		where 
		return;
	end;

	select * from ccc()