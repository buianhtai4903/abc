--Câu 2: (4 điểm)

--a) Tạo thủ tục đặt tên là uspCustomerInfo có tham số đầu vào là
-- @PersonID (Person.Person.BusinessEntityID). Thủ tục cho biết tên 
-- khách hàng PersonName= FirstName + MiddleName + LastName, tổng tiền 
-- phải trả TotalDue. Chỉ lấy số liệu từ các khách hàng (Customer) có mua 
-- hàng trong năm 2005 và mua qua mạng (*) (OnlineOrderFlag=1). Nếu @PersonID 
-- không tồn tại theo yêu cầu của thủ tục nêu ở (*), thủ tục nhận giá trị trả về 
-- là 1 và có thông báo "Không có thông tin khách hàng n hat a y^ prime prime (3đ)
use AdventureWorks2008R2
go

create proc uspCustomerInfo
@PersonID int 
as 
begin
	if not exists (
		select 1
		from [Person].[Person] as p inner join [Sales].[Customer] as c on p.BusinessEntityID=c.PersonID 
									inner join [Sales].[SalesOrderHeader] as h on c.CustomerID=h.CustomerID
		where BusinessEntityID = @PersonID 
			and YEAR(OrderDate) = 2005 and OnlineOrderFlag = 1
		) 
		begin
			print 'Không có thông tin khách hàng'
			return 1 
		end

		select p.FirstName+' '+p.MiddleName+' '+p.LastName as PersonName, sum(h.TotalDue) as Tongtien
		from [Person].[Person] as p inner join [Sales].[Customer] as c on p.BusinessEntityID=c.PersonID 
									inner join [Sales].[SalesOrderHeader] as h on c.CustomerID=h.CustomerID
		where BusinessEntityID = @PersonID 
			and YEAR(OrderDate) = 2005 and OnlineOrderFlag = 1
		group by FirstName, MiddleName, LastName, BusinessEntityID
end 
	
EXEC uspCustomerInfo 1702;
EXEC uspCustomerInfo 1700;
go
--Câu 3: (4 điểm)
--a) Viết hàm ufnInventory dạng multi-statement table-valued function có tham số 
--là tên sản phẩm @ProductName (Production.Product.Name). Hàm in ra danh sách cho 
--biết tên kho hàng Production.Location.Name, vị trí sản phẩm trong kho, gồm: kệ hàng 
--(Shelf), ngăn (Bin), và số lượng (Quantity) (3đ)

create function ufnInventory(@ProductName nvarchar(50))
returns @ufnInventory table(LocationName nvarchar(50), Shelf nvarchar(20),Bin int, quanity int)
as
begin 
insert into @ufnInventory
	select pl.Name, i.Shelf, i.Bin, i.Quantity
	from [Production].[Location] as pl join [Production].[ProductInventory] as i on pl.LocationID=i.LocationID
	join [Production].[Product] as p on p.ProductID=i.ProductID
	where p.Name = @ProductName
return;
end;
--return 
--	(
--	select pl.Name, i.Shelf, i.Bin, i.Quantity
--	from [Production].[Location] as pl join [Production].[ProductInventory] as i on pl.LocationID=i.LocationID
--	where pl.Name = @ProductName
--	)
--go
select * from ufnInventory('Bearing Ball')

--b) Viết câu lệnh thực thi hàm cho sản phẩm vòng bi ‘Bearing Ball (1đ)

--Viết đoạn batch dùng biến mã người đại diện bán hàng @SalesPersonID 
--(Sales.SalesPerson.BusinessEntityID). Xác định định mức bán hàng hàng năm 
--@SalesQuota, số khách hàng là đại lý bán hàng @CountOfReseller (=count of 
--Sales.Store.BusinessEntityID) theo @SalesPersonID. Kết quả được in ra theo mẫu 
--«Người bán hàng @SalesPersonID, với định mức bán hàng hàng năm 
--@SalesQuota, có số khách hàng là @CountOfReseller»

declare @SalesPersonID int
declare @SalesQuota money
declare @CountOfReseller int

set @SalesPersonID = 277 

SELECT @SalesQuota = SalesQuota
FROM Sales.SalesPerson
WHERE BusinessEntityID = @SalesPersonID

select @CountOfReseller=COUNT(p.BusinessEntityID)
from [Sales].[Store] as s join [Sales].[SalesPerson] as p on s.BusinessEntityID = p.BusinessEntityID
join [Sales].[Customer] as c on c.PersonID=s.BusinessEntityID
where p.BusinessEntityID = @SalesPersonID

print 'Nguoi ban hang '+cast(@SalesPersonID as varchar)+' dinh muc '
+cast(@SalesQuota as varchar) 
+' co so khach hang la ' +cast(@CountOfReseller as varchar)

