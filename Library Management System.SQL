-- Step 1: Create Database
CREATE DATABASE LibraryManagement;
USE LibraryManagement;

-- Step 2: Create Tables

-- Table for Books
CREATE TABLE Books (
    BookID INT AUTO_INCREMENT PRIMARY KEY,
    Title VARCHAR(255) NOT NULL,
    Author VARCHAR(255) NOT NULL,
    Publisher VARCHAR(255),
    YearPublished YEAR,
    Genre VARCHAR(100),
    Quantity INT DEFAULT 1
);

-- Table for Members
CREATE TABLE Members (
    MemberID INT AUTO_INCREMENT PRIMARY KEY,
    FullName VARCHAR(255) NOT NULL,
    Email VARCHAR(255) UNIQUE,
    PhoneNumber VARCHAR(15),
    Address TEXT,
    MembershipDate DATE  
);

-- Table for Transactions
CREATE TABLE Transactions (
    TransactionID INT AUTO_INCREMENT PRIMARY KEY,
    MemberID INT,
    BookID INT,
    IssueDate DATE ,
    DueDate DATE,
    ReturnDate DATE,
    Status ENUM('Issued', 'Returned') DEFAULT 'Issued',
    FOREIGN KEY (MemberID) REFERENCES Members(MemberID),
    FOREIGN KEY (BookID) REFERENCES Books(BookID)
);

-- Step 3: Insert Sample Data

-- Sample Books
INSERT INTO Books (Title, Author, Publisher, YearPublished, Genre, Quantity)
VALUES 
('The Great Gatsby', 'F. Scott Fitzgerald', 'Scribner', 1925, 'Fiction', 5),
('1984', 'George Orwell', 'Secker & Warburg', 1949, 'Dystopian', 3),
('To Kill a Mockingbird', 'Harper Lee', 'J.B. Lippincott & Co.', 1960, 'Fiction', 4);

-- Sample Members
INSERT INTO Members (FullName, Email, PhoneNumber, Address)
VALUES 
('John Doe', 'john.doe@example.com', '1234567890', '123 Main St'),
('Jane Smith', 'jane.smith@example.com', '0987654321', '456 Elm St');

-- Step 4: Basic Queries

-- Issue a Book
INSERT INTO Transactions (MemberID, BookID, DueDate)
VALUES (1, 1, DATE_ADD(CURRENT_DATE, INTERVAL 14 DAY)); 

-- Return a Book
UPDATE Transactions
SET ReturnDate = CURRENT_DATE, Status = 'Returned'
WHERE TransactionID = 1;

-- Check Available Books
SELECT Title, Author, Quantity - (
    SELECT COUNT(*) FROM Transactions WHERE BookID = Books.BookID AND Status = 'Issued'
) AS AvailableCopies
FROM Books;

-- View Transactions
SELECT 
    T.TransactionID, 
    M.FullName, 
    B.Title, 
    T.IssueDate, 
    T.DueDate, 
    T.ReturnDate, 
    T.Status
FROM Transactions T
JOIN Members M ON T.MemberID = M.MemberID
JOIN Books B ON T.BookID = B.BookID;

-- List Overdue Books
SELECT 
    T.TransactionID, 
    M.FullName, 
    B.Title, 
    T.IssueDate, 
    T.DueDate 
FROM Transactions T
JOIN Members M ON T.MemberID = M.MemberID
JOIN Books B ON T.BookID = B.BookID
WHERE T.Status = 'Issued' AND T.DueDate < CURRENT_DATE;

 -- Most Issued Books
SELECT 
    B.Title, 
    COUNT(T.TransactionID) AS IssueCount 
FROM Transactions T
JOIN Books B ON T.BookID = B.BookID
GROUP BY B.Title
ORDER BY IssueCount DESC
LIMIT 5;

-- Count Total Books in Library
SELECT 
    SUM(Quantity) AS TotalBooks 
FROM Books;

-- Members with Maximum Borrowed Books
SELECT 
 M.FullName, 
COUNT(T.TransactionID) AS BooksBorrowed 
FROM Transactions T
JOIN Members M ON T.MemberID = M.MemberID
WHERE T.Status = 'Issued'
GROUP BY M.FullName
ORDER BY BooksBorrowed DESC
LIMIT 5;

-- Check Book Availability

SELECT 
Title, 
Quantity - (
 SELECT COUNT(*) 
 FROM Transactions 
 WHERE BookID = Books.BookID AND Status = 'Issued'
 ) AS AvailableCopies
FROM Books
WHERE Title = 'The Great Gatsby';
