-- DROP SCHEMA dbo;

CREATE SCHEMA dbo;
-- ProjektLK.dbo.[Role] definition

-- Drop table

-- DROP TABLE ProjektLK.dbo.[Role];

CREATE TABLE ProjektLK.dbo.[Role] (
	roleID int IDENTITY(1,1) NOT NULL,
	roleName varchar(20) COLLATE Slovenian_CI_AS NULL,
	CONSTRAINT PK__Role__CD98460A2CC0C94A PRIMARY KEY (roleID)
);


-- ProjektLK.dbo.Status definition

-- Drop table

-- DROP TABLE ProjektLK.dbo.Status;

CREATE TABLE ProjektLK.dbo.Status (
	statusID int IDENTITY(1,1) NOT NULL,
	statusName varchar(20) COLLATE Slovenian_CI_AS NULL,
	CONSTRAINT PK__Status__36257A388FBD8DCD PRIMARY KEY (statusID)
);


-- ProjektLK.dbo.[Type] definition

-- Drop table

-- DROP TABLE ProjektLK.dbo.[Type];

CREATE TABLE ProjektLK.dbo.[Type] (
	typeID int IDENTITY(1,1) NOT NULL,
	typeName varchar(30) COLLATE Slovenian_CI_AS NULL,
	CONSTRAINT PK__Type__F04DF11A50952EDF PRIMARY KEY (typeID)
);


-- ProjektLK.dbo.Employee definition

-- Drop table

-- DROP TABLE ProjektLK.dbo.Employee;

CREATE TABLE ProjektLK.dbo.Employee (
	empID int IDENTITY(1,1) NOT NULL,
	fname varchar(20) COLLATE Slovenian_CI_AS NULL,
	lname varchar(20) COLLATE Slovenian_CI_AS NULL,
	startDate date NULL,
	supervisor int NULL,
	salary real NULL,
	CONSTRAINT PK__Employee__AFB3EC6D6E4FE584 PRIMARY KEY (empID),
	CONSTRAINT FK__Employee__superv__690797E6 FOREIGN KEY (supervisor) REFERENCES ProjektLK.dbo.Employee(empID)
);


-- ProjektLK.dbo.EmployeeRole definition

-- Drop table

-- DROP TABLE ProjektLK.dbo.EmployeeRole;

CREATE TABLE ProjektLK.dbo.EmployeeRole (
	empID int NOT NULL,
	roleID int NOT NULL,
	CONSTRAINT PK__Employee__136A680DACFD3CA0 PRIMARY KEY (empID,roleID),
	CONSTRAINT FK__EmployeeR__empID__662B2B3B FOREIGN KEY (empID) REFERENCES ProjektLK.dbo.Employee(empID) ON DELETE CASCADE,
	CONSTRAINT FK__EmployeeR__roleI__671F4F74 FOREIGN KEY (roleID) REFERENCES ProjektLK.dbo.[Role](roleID) ON DELETE CASCADE
);


-- ProjektLK.dbo.Project definition

-- Drop table

-- DROP TABLE ProjektLK.dbo.Project;

CREATE TABLE ProjektLK.dbo.Project (
	projectID int IDENTITY(1,1) NOT NULL,
	managerID int NULL,
	projectType int NULL,
	cost real NULL,
	projectName varchar(30) COLLATE Slovenian_CI_AS NULL,
	status int NULL,
	startDate date NULL,
	finishDate date NULL,
	CONSTRAINT PK__Project__11F14D857AC6FEF2 PRIMARY KEY (projectID),
	CONSTRAINT FK__Project__manager__5BAD9CC8 FOREIGN KEY (managerID) REFERENCES ProjektLK.dbo.Employee(empID) ON DELETE SET NULL,
	CONSTRAINT FK__Project__project__5CA1C101 FOREIGN KEY (projectType) REFERENCES ProjektLK.dbo.[Type](typeID) ON DELETE SET NULL,
	CONSTRAINT FK__Project__status__5D95E53A FOREIGN KEY (status) REFERENCES ProjektLK.dbo.Status(statusID) ON DELETE SET NULL
);


-- ProjektLK.dbo.ProjectEmployee definition

-- Drop table

-- DROP TABLE ProjektLK.dbo.ProjectEmployee;

CREATE TABLE ProjektLK.dbo.ProjectEmployee (
	projectID int NOT NULL,
	empID int NOT NULL,
	CONSTRAINT PK__ProjectE__EEACF8B52471A95A PRIMARY KEY (empID,projectID),
	CONSTRAINT FK__ProjectEm__empID__625A9A57 FOREIGN KEY (empID) REFERENCES ProjektLK.dbo.Employee(empID) ON DELETE CASCADE,
	CONSTRAINT FK__ProjectEm__proje__634EBE90 FOREIGN KEY (projectID) REFERENCES ProjektLK.dbo.Project(projectID) ON DELETE CASCADE
);


-- ProjektLK.dbo.Estate definition

-- Drop table

-- DROP TABLE ProjektLK.dbo.Estate;

CREATE TABLE ProjektLK.dbo.Estate (
	estateID int IDENTITY(1,1) NOT NULL,
	projectID int NULL,
	estateName varchar(30) COLLATE Slovenian_CI_AS NULL,
	location varchar(30) COLLATE Slovenian_CI_AS NULL,
	CONSTRAINT PK__Estate__8925666A9EFA37A9 PRIMARY KEY (estateID),
	CONSTRAINT FK__Estate__projectI__681373AD FOREIGN KEY (projectID) REFERENCES ProjektLK.dbo.Project(projectID)
);




--------------------------------- POGLEDI --------------------------------------------------




-- dbo.vCostOfAllProjects source

CREATE VIEW vCostOfAllProjects AS
SELECT SUM(Cost) AS CostOfAllProjects FROM Project;


-- dbo.vCountPerRole source

CREATE VIEW vCountPerRole AS
SELECT 
	Role.roleName, 
	COUNT(EmployeeRole.roleID) AS SteviloVlog
FROM
	EmployeeRole
	JOIN Role ON Role.roleID = EmployeeRole.roleID
GROUP BY roleName;


-- dbo.vEmployeeList source

CREATE VIEW vEmployeeList AS
SELECT fname + ', ' + UPPER(lname) AS EmployeeList FROM Employee;


-- dbo.vListAllEstates source

CREATE VIEW vListAllEstates AS
SELECT * FROM Estate;


-- dbo.vListProjects source

CREATE VIEW vListProjects AS
SELECT * FROM Project;


-- dbo.vNewProjects source

CREATE VIEW vNewProjects AS
SELECT 
	typeName,
	statusName,
	ManagerName
FROM ( 
	SELECT 
		Estate.estateName, 
		Estate.location,
		Type.typeName AS typeName, 
		Status.statusName AS statusName, 
		Employee.fName + ' ' + Employee.lName AS ManagerName,
		Project.cost
	FROM 
		Estate 
		LEFT JOIN Project ON Estate.projectID = Project.projectID  
		LEFT JOIN Employee ON Project.managerID = Employee.empID
		LEFT JOIN Type ON Project.projectType = Type.typeID
		LEFT JOIN Status ON Project.status = Status.statusID
	WHERE 
		Project.finishDate > '2024-01-01'
) a;


-- dbo.vSalariesSum source

CREATE VIEW vSalariesSum AS
SELECT SUM(Salary) AS SalariesSum FROM Employee;


--------------------------------- FUNKCIJE --------------------------------------------------

CREATE FUNCTION fnGetEmployeeByRole(@role varchar(20))
RETURNS TABLE
AS RETURN
SELECT
	Employee.empID,
	Employee.fname+Employee.lname AS EmployeeName
FROM 
	Employee
	JOIN EmployeeRole ON Employee.empID=EmployeeRole.empID
	JOIN Role ON EmployeeRole.roleID=Role.roleID
WHERE roleName=@role



CREATE FUNCTION fnProjectStatus(@status int)
RETURNS TABLE 
AS 
RETURN
SELECT * FROM Project WHERE status = @status




CREATE FUNCTION fnTop3ProjectsByEmp (@fname varchar(20), @lname varchar(20))
RETURNS TABLE
AS
RETURN
SELECT *
FROM (
	SELECT TOP 3 
		Project.projectName as [Project Name],
		[Type].typeName as [Project Type],
		Employee.fname+' '+Employee.lname as Manager,
		Project.cost as Cost
	FROM 
		Project 
		JOIN [Type] ON [Type].typeID=Project.projectType
		JOIN Employee ON Employee.empID=Project.managerID
	WHERE Employee.fname=@fname AND Employee.lname=@lname
	ORDER BY Project.cost DESC
	) AS a




--------------------------------- SHRANJENE PROCEDURE --------------------------------------------------

CREATE PROCEDURE spAddEmployee(@fname varchar(20),
@lname varchar(20),@startDate date, @supervisor int, @salary float)
AS
IF @supervisor IN (SELECT Employee.empID FROM Employee)
BEGIN 
	INSERT INTO Employee(fname,lname,startDate,supervisor,salary)
	VALUES(@fname,@lname,@startDate,@supervisor,@salary)
END
ELSE
BEGIN
	INSERT INTO Employee(fname,lname,startDate,supervisor,salary)
	VALUES(@fname,@lname,@startDate,null,@salary)
END



CREATE PROCEDURE spAddEstate @estateName varchar(20), @location varchar(20)
AS
INSERT INTO Estate (estateName, location)
VALUES
(@estateName, @location)




CREATE PROCEDURE spGetEmployeesByRole @role varchar(20)
AS
SELECT
	Employee.empID,
	Employee.fname+Employee.lname AS EmployeeName
FROM 
	Employee
	JOIN EmployeeRole ON Employee.empID=EmployeeRole.empID
	JOIN Role ON EmployeeRole.roleID=Role.roleID
WHERE roleName=@role;