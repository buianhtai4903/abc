-- 1. Thêm cột NumEmp vào bảng Department
select * from [HumanResources].[Department]
ALTER TABLE [HumanResources].[Department]  ADD NumEmp INT;

select * from [HumanResources].[Department]
select * from [HumanResources].[EmployeeDepartmentHistory]
select * from [HumanResources].[Shift]
-- 2. Cập nhật NumEmp theo số lượng nhân viên làm ca ngày (Day shift)
UPDATE d
SET d.NumEmp = (
    SELECT COUNT(*)
    FROM [HumanResources].[EmployeeDepartmentHistory] edh
    WHERE edh.DepartmentID = d.DepartmentID AND edh.ShiftID = 1
)
FROM [HumanResources].[Department] d;

select * from [HumanResources].[Department]
go
-- 3. Trigger để cập nhật số lượng nhân viên (NumEmp) 
--trong bảng Department khi có cập nhật EndDate trong bảng 
--EmployeeDepartmentHistory.
CREATE TRIGGER uDepHistory
ON [HumanResources].[EmployeeDepartmentHistory]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF UPDATE(EndDate)
    BEGIN
        UPDATE d
        SET d.NumEmp = (
            SELECT COUNT(*)
            FROM EmployeeDepartmentHistory edh
             WHERE edh.DepartmentID = d.DepartmentID
              AND edh.ShiftID = 1
              AND edh.EndDate IS NULL  -- chỉ đếm người đang còn làm
        )
        FROM Department d
        INNER JOIN (
            SELECT DISTINCT DepartmentID
            FROM inserted
        ) i ON d.DepartmentID = i.DepartmentID;
    END
END;
--test
-- Cập nhật EndDate của 1 nhân viên (giả sử đã từng làm ca ngày)
select * from [HumanResources].[EmployeeDepartmentHistory]
select * from [HumanResources].[Department]

INSERT INTO [HumanResources].[EmployeeDepartmentHistory] (BusinessEntityID, DepartmentID, StartDate, ShiftID)
VALUES 
(55, 1, '2025-01-01', 1), 
(56, 1, '2025-01-01', 1),
(57, 1, '2025-01-01', 1);
--them 3 nhan vien lam ca sang

UPDATE [HumanResources].[EmployeeDepartmentHistory]
set EndDate = null

UPDATE [HumanResources].[EmployeeDepartmentHistory]
set EndDate = GETDATE()


-- Kiểm tra Department tương ứng

select * from [HumanResources].[Department]
--phan 2
backup database [AdventureWorks2008R2]
to disk = 'T:\HK2_Nam4\hqtcsdl\pt\backhere.bak'
with init;
--b
select * from [HumanResources].[EmployeePayHistory]

UPDATE ph
SET ph.Rate = ph.Rate * 1.1 -- tăng 10% lương cho nhân viên làm việc ca chiều
from [HumanResources].[EmployeePayHistory] as ph 
join [HumanResources].[EmployeeDepartmentHistory] as dh
on ph.BusinessEntityID = dh.BusinessEntityID
WHERE dh.ShiftID = 2

UPDATE ph
SET ph.Rate = ph.Rate * 1.1 -- tăng 20% lương cho nhân viên làm việc ca dem
from [HumanResources].[EmployeePayHistory] as ph 
join [HumanResources].[EmployeeDepartmentHistory] as dh
on ph.BusinessEntityID = dh.BusinessEntityID
WHERE dh.ShiftID = 3

--c
DELETE FROM [Production].[ProductCostHistory];

--backup database [AdventureWorks2008R2]
--to disk = 'T:\HK2_Nam4\hqtcsdl\pt\backhere.bak'
--with init;

BACKUP DATABASE [AdventureWorks2008R2] 
to disk = 'T:\HK2_Nam4\hqtcsdl\pt\backhereDiff.bak'--file 1
WITH DIFFERENTIAL;

--d
SELECT * 
FROM Person.PersonPhone
WHERE BusinessEntityID = 10001;

INSERT INTO Person.PersonPhone (BusinessEntityID, PhoneNumber, PhoneNumberTypeID)
VALUES (10001, '1234567890', 1); -- thêm số điện thoại mới

backup log [AdventureWorks2008R2]
to disk ='T:\HK2_Nam4\hqtcsdl\pt\backhereLog.bak'

--e
-- Xóa cơ sở dữ liệu
DROP DATABASE [AdventureWorks2008R2];

-- Phục hồi cơ sở dữ liệu về trạng thái bước c
RESTORE DATABASE Adventure Works2008R2
FROM DISK = 'T:\HK2_Nam4\hqtcsdl\pt\backhereDiff.bak'
WITH NORECOVERY;

-- Phục hồi transaction log
RESTORE LOG Adventure Works2008R2
FROM DISK = 'T:\HK2_Nam4\hqtcsdl\pt\backhereLog.bak'
WITH NORECOVERY;

-- Đánh dấu phục hồi hoàn tất
RESTORE DATABASE Adventure Works2008R2 WITH RECOVERY;

-- Kiểm tra dữ liệu phục hồi
SELECT * 
FROM Person.PersonPhone
WHERE BusinessEntityID = 10001;