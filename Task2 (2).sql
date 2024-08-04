	CREATE DATABASE Work2

	USE Work2

	CREATE TABLE Departments (
    Id INT PRIMARY KEY,
    Name NVARCHAR(20) NOT NULL
);

CREATE TABLE Positions (
    Id INT PRIMARY KEY,
    Name NVARCHAR(20) NOT NULL,
    Limit INT NOT NULL
);

CREATE TABLE Workers (
    Id INT PRIMARY KEY,
    Name NVARCHAR(30) NOT NULL,
    Surname NVARCHAR(30) NOT NULL,
    PhoneNumber NVARCHAR(20),
    Salary DECIMAL(10, 2),
    BirthDate DATE
);
INSERT INTO Departments (Id, Name)
VALUES (1, 'IT'),
       (2, 'HR'),
       (3, 'Finance');

INSERT INTO Positions (Id, Name, Limit)
VALUES (1, 'Software Developer', 10),
       (2, 'HR Manager', 5),
       (3, 'Financial Analyst', 8);

INSERT INTO Workers (Id, Name, Surname, PhoneNumber, Salary, BirthDate)
VALUES (1, 'John', 'Doe', '123456789', 5000.00, '1990-05-15'),
       (2, 'Jane', 'Smith', '987654321', 4500.00, '1995-10-20'),
       (3, 'Alice', 'Johnson', '456789123', 4800.00, '1988-03-25');


CREATE FUNCTION GetAverageSalaryByDepartment (@departmentId INT)
RETURNS DECIMAL(10, 2)
AS
BEGIN
    DECLARE @AvgSalary DECIMAL(10, 2);

    SELECT @AvgSalary = AVG(Salary)
    FROM Workers w
    JOIN Positions p ON w.PositionId = p.Id
    WHERE p.DepartmentId = @departmentId;

    RETURN @AvgSalary;
END;

CREATE TRIGGER CheckWorkerAge
ON Workers
FOR INSERT
AS
BEGIN
    DECLARE @WorkerBirthDate DATE;
    DECLARE @WorkerId INT;

    SELECT @WorkerBirthDate = i.BirthDate, @WorkerId = i.Id
    FROM inserted i;

    DECLARE @WorkerAge INT;
    SET @WorkerAge = DATEDIFF(YEAR, @WorkerBirthDate, GETDATE());

    IF @WorkerAge < 18
    BEGIN
        RAISERROR('Worker 18 yasindan boyuk olmalidir ', 16, 1);
        DELETE FROM Workers WHERE Id = @WorkerId; 
    END
END;

CREATE TRIGGER CheckPositionLimit
ON Workers
FOR INSERT
AS
BEGIN
    DECLARE @PositionId INT;
    DECLARE @PositionLimit INT;
    DECLARE @CurrentWorkersCount INT;

    SELECT @PositionId = w.PositionId, @PositionLimit = p.Limit
    FROM inserted w
    JOIN Positions p ON w.PositionId = p.Id;

    SELECT @CurrentWorkersCount = COUNT(*)
    FROM Workers
    WHERE PositionId = @PositionId;

    IF @CurrentWorkersCount >= @PositionLimit
    BEGIN
        RAISERROR('Position limiti kecib', 16, 1);
        ROLLBACK TRANSACTION; 
    END
END;