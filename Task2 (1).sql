CREATE DATABASE Course2

USE Course2

CREATE TABLE Groups (
    Id INT PRIMARY KEY,
    Name NVARCHAR(50) NOT NULL,
    Limit INT NOT NULL,
    BeginDate DATE NOT NULL,
    EndDate DATE
);

CREATE TABLE Students (
    Id INT PRIMARY KEY,
    Name NVARCHAR(50) NOT NULL,
    Surname NVARCHAR(50) NOT NULL, 
    Email NVARCHAR(100),
    PhoneNumber NVARCHAR(20),
    BirthDate DATE,
    GPA DECIMAL(3, 2) 
);
INSERT INTO Students (Id, Name, Surname, Email, PhoneNumber, BirthDate, GPA)
VALUES
    (1, 'John', 'Doe', 'john.doe@example.com', '123456789', '2000-01-01', 3.75),
    (2, 'Jane', 'Smith', 'jane.smith@example.com', '987654321', '1999-08-15', 3.90),
    (3, 'Alice', 'Johnson', 'alice.johnson@example.com', '456789123', '2002-03-20', 3.60);



CREATE TRIGGER CheckGroupLimit
ON Students
FOR INSERT
AS
BEGIN
    DECLARE @GroupId INT;
    DECLARE @GroupLimit INT;
    DECLARE @CurrentStudentCount INT;

    SELECT @GroupId = g.Id, @GroupLimit = g.Limit
    FROM Groups g
    JOIN inserted i ON i.GroupId = g.Id;

    SELECT @CurrentStudentCount = COUNT(*)
    FROM Students
    WHERE GroupId = @GroupId;

    IF @CurrentStudentCount >= @GroupLimit
    BEGIN
        RAISERROR('Qrup limiti kecildi', 16, 1);
        ROLLBACK TRANSACTION; 
    END
END;


CREATE TRIGGER CheckStudentAge
ON Students
FOR INSERT
AS
BEGIN
    DECLARE @StudentBirthDate DATE;
    DECLARE @StudentId INT;

    SELECT @StudentBirthDate = i.BirthDate, @StudentId = i.Id
    FROM inserted i;

    DECLARE @StudentAge INT;
    SET @StudentAge = DATEDIFF(YEAR, @StudentBirthDate, GETDATE());

    IF @StudentAge < 16
    BEGIN
        RAISERROR('Yas 16-dan boyuk olmalidir', 16, 1);
        DELETE FROM Students WHERE Id = @StudentId;
    END
END;


CREATE FUNCTION GetGroupAverageGPA (@groupId INT)
RETURNS DECIMAL(3, 2)
AS
BEGIN
    DECLARE @AvgGPA DECIMAL(3, 2);

    SELECT @AvgGPA = AVG(GPA)
    FROM Students
    WHERE GroupId = @groupId;

    RETURN @AvgGPA;
END;