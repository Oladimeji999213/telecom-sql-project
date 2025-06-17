Create database Telecommunication
Use Telecommunication ;
CREATE TABLE Customer (
    CustomerID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(100),
    Email VARCHAR(100),
    Phone VARCHAR(15),
    Address TEXT
);

CREATE TABLE ServicePlan (
    PlanID INT AUTO_INCREMENT PRIMARY KEY,
    PlanName VARCHAR(50),
    MonthlyCost DECIMAL(10,2),
    CallLimit INT,
    SMSLimit INT,
    DataLimitMB INT
);

CREATE TABLE Subscription (
    SubscriptionID INT AUTO_INCREMENT PRIMARY KEY,
    CustomerID INT,
    PlanID INT,
    StartDate DATE,
    EndDate DATE,
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID),
    FOREIGN KEY (PlanID) REFERENCES ServicePlan(PlanID)
);

CREATE TABLE CallRecord (
    CallID INT AUTO_INCREMENT PRIMARY KEY,
    SubscriptionID INT,
    CallDate DATETIME,
    DurationMinutes INT,
    DestinationNumber VARCHAR(15),
    FOREIGN KEY (SubscriptionID) REFERENCES Subscription(SubscriptionID)
);

CREATE TABLE SMSRecord (
    SMSID INT AUTO_INCREMENT PRIMARY KEY,
    SubscriptionID INT,
    SMSDate DATETIME,
    DestinationNumber VARCHAR(15),
    FOREIGN KEY (SubscriptionID) REFERENCES Subscription(SubscriptionID)
);

CREATE TABLE DataUsage (
    SessionID INT AUTO_INCREMENT PRIMARY KEY,
    SubscriptionID INT,
    StartTime DATETIME,
    EndTime DATETIME,
    DataUsedMB INT,
    FOREIGN KEY (SubscriptionID) REFERENCES Subscription(SubscriptionID)
);

CREATE TABLE Invoice (
    InvoiceID INT AUTO_INCREMENT PRIMARY KEY,
    SubscriptionID INT,
    InvoiceDate DATE,
    Amount DECIMAL(10,2),
    Status VARCHAR(20),
    FOREIGN KEY (SubscriptionID) REFERENCES Subscription(SubscriptionID)
);

CREATE TABLE SupportTicket (
    TicketID INT AUTO_INCREMENT PRIMARY KEY,
    CustomerID INT,
    IssueDate DATE,
    IssueType VARCHAR(100),
    ResolutionStatus VARCHAR(50),
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID)
);
 -- Inserting samples data in the table created

INSERT INTO Customer (Name, Email, Phone, Address) VALUES
('Taku Nyansha', 'john@example.com', '08012345678', '12 Freedom Lane, Lagos'),
('Jane Smith', 'jane@example.com', '08087654321', '25 Unity Avenue, Abuja');

INSERT INTO ServicePlan (PlanName, MonthlyCost, CallLimit, SMSLimit, DataLimitMB) VALUES
('Basic Plan', 3000.00, 100, 50, 1000),
('Unlimited Plus', 10000.00, NULL, NULL, NULL);

INSERT INTO Subscription (CustomerID, PlanID, StartDate, EndDate) VALUES
(1, 1, '2024-01-01', NULL),
(2, 2, '2024-03-15', NULL);

INSERT INTO CallRecord (SubscriptionID, CallDate, DurationMinutes, DestinationNumber) VALUES
(1, '2024-05-01 09:30:00', 5, '08023456789'),
(1, '2024-05-02 11:00:00', 10, '07034567890'),
(2, '2024-05-02 14:45:00', 2, '08112345678');

INSERT INTO SMSRecord (SubscriptionID, SMSDate, DestinationNumber) VALUES
(1, '2024-05-01 08:00:00', '08023456789'),
(2, '2024-05-02 13:15:00', '08087654321');

INSERT INTO DataUsage (SubscriptionID, StartTime, EndTime, DataUsedMB) VALUES
(1, '2024-05-01 10:00:00', '2024-05-01 10:30:00', 200),
(2, '2024-05-02 12:00:00', '2024-05-02 12:45:00', 1500);

INSERT INTO Invoice (SubscriptionID, InvoiceDate, Amount, Status) VALUES
(1, '2024-05-31', 3000.00, 'Paid'),
(2, '2024-05-31', 10000.00, 'Unpaid');

INSERT INTO SupportTicket (CustomerID, IssueDate, IssueType, ResolutionStatus) VALUES
(1, '2024-05-10', 'Data not working', 'Resolved'),
(2, '2024-05-11', 'Overcharged invoice', 'Pending');

-- Customers Information Retrieval
-- Get all customer details
Select * from Customer

-- Find a customer's subscription and service plan
SELECT 
c.Name,
    s.SubscriptionID,
    sp.PlanName,
    sp.MonthlyCost,
    s.StartDate
FROM Customer c
JOIN Subscription s ON c.CustomerID = s.CustomerID
JOIN ServicePlan sp ON s.PlanID = sp.PlanID;

-- Service plan management
SELECT * FROM ServicePlan;

-- Get customers on the 'unlimited plus' plan
SELECT 
    c.Name,
    sp.PlanName
FROM Customer c
JOIN Subscription s ON c.CustomerID = s.CustomerID
JOIN ServicePlan sp ON s.PlanID = sp.PlanID
WHERE sp.PlanName = 'Unlimited Plus';

 -- Count of customers per plan
SELECT 
    sp.PlanName,
    COUNT(s.SubscriptionID) AS NumberOfSubscribers
FROM ServicePlan sp
LEFT JOIN Subscription s ON sp.PlanID = s.PlanID
GROUP BY sp.PlanName;

-- Usage history analysis
-- Total call duration per customer
SELECT 
    c.Name,
    SUM(cr.DurationMinutes) AS TotalCallMinutes
FROM CallRecord cr
JOIN Subscription s ON cr.SubscriptionID = s.SubscriptionID
JOIN Customer c ON s.CustomerID = c.CustomerID
GROUP BY c.Name;

-- Top 5 highest mobile data users

SELECT 
    c.Name,
    SUM(d.DataUsedMB) AS TotalDataUsed
FROM DataUsage d
JOIN Subscription s ON d.SubscriptionID = s.SubscriptionID
JOIN Customer c ON s.CustomerID = c.CustomerID
GROUP BY c.Name
ORDER BY TotalDataUsed DESC
LIMIT 5;

-- Total sms sent per customer
SELECT 
    c.Name,
    COUNT(sms.SMSID) AS TotalSMS
FROM SMSRecord sms
JOIN Subscription s ON sms.SubscriptionID = s.SubscriptionID
JOIN Customer c ON s.CustomerID = c.CustomerID
GROUP BY c.Name;

-- Billing details
-- View all invoices with status
SELECT 
    i.InvoiceID,
    c.Name,
    i.Amount,
    i.Status,
    i.InvoiceDate
FROM Invoice i
JOIN Subscription s ON i.SubscriptionID = s.SubscriptionID
JOIN Customer c ON s.CustomerID = c.CustomerID;

-- Total revenue earned from all customers
SELECT 
    SUM(Amount) AS TotalRevenue
FROM Invoice
WHERE Status = 'Paid';

CREATE TABLE NetworkPerformance (
    PerformanceID INT AUTO_INCREMENT PRIMARY KEY,
    SubscriptionID INT,
    ReportDate DATE,
    CallDropRate DECIMAL(5,2),       -- in percentage (e.g., 3.75%)
    AvgLatencyMS INT,                -- in milliseconds
    SignalStrengthDBM INT,           -- in dBm (e.g., -85 is moderate)
    DowntimeMinutes INT,            -- minutes of network unavailability
    FOREIGN KEY (SubscriptionID) REFERENCES Subscription(SubscriptionID)
);

INSERT INTO NetworkPerformance 
(SubscriptionID, ReportDate, CallDropRate, AvgLatencyMS, SignalStrengthDBM, DowntimeMinutes)
VALUES
(1, '2024-06-01', 2.50, 150, -85, 10),
(2, '2024-06-01', 0.75, 90, -70, 0);

-- Network performance indicator queries

SELECT 
    c.Name,
    COUNT(cr.CallID) AS ShortCalls
FROM CallRecord cr
JOIN Subscription s ON cr.SubscriptionID = s.SubscriptionID
JOIN Customer c ON s.CustomerID = c.CustomerID
WHERE cr.DurationMinutes < 1
GROUP BY c.Name;

-- Subscrption with weak signal strength
-- Signal strength below -90 dBm is considered poor. This query finds them
SELECT 
    s.SubscriptionID,
    c.Name AS CustomerName,
    np.SignalStrengthDBM,
    np.ReportDate
FROM NetworkPerformance np
JOIN Subscription s ON np.SubscriptionID = s.SubscriptionID
JOIN Customer c ON s.CustomerID = c.CustomerID
WHERE np.SignalStrengthDBM < -90
ORDER BY np.SignalStrengthDBM;

-- Worst Performing Subscriptions (High Call Drop Rate)
-- Shows customers whose connections are experiencing more than 5% dropped calls.
SELECT 
    s.SubscriptionID,
    c.Name AS CustomerName,
    np.CallDropRate,
    np.ReportDate
FROM NetworkPerformance np
JOIN Subscription s ON np.SubscriptionID = s.SubscriptionID
JOIN Customer c ON s.CustomerID = c.CustomerID
WHERE np.CallDropRate > 5.00
ORDER BY np.CallDropRate DESC;

-- Total Downtime (per Customer)
-- Useful for SLA tracking and support prioritization. Shows who experienced the most outages.
SELECT 
    c.Name AS CustomerName,
    SUM(np.DowntimeMinutes) AS TotalDowntime
FROM NetworkPerformance np
JOIN Subscription s ON np.SubscriptionID = s.SubscriptionID
JOIN Customer c ON s.CustomerID = c.CustomerID
GROUP BY c.Name
ORDER BY TotalDowntime DESC;

-- Average Latency by Customer
-- Helps evaluate which customers are facing high latency issues (slower connections).
SELECT 
    c.Name AS CustomerName,
    ROUND(AVG(np.AvgLatencyMS), 2) AS AverageLatency
FROM NetworkPerformance np
JOIN Subscription s ON np.SubscriptionID = s.SubscriptionID
JOIN Customer c ON s.CustomerID = c.CustomerID
GROUP BY c.Name
ORDER BY AverageLatency DESC;

-- Daily Network Health Summary
-- Provides a summary of network quality over time. Can be used to spot trends or issues.
SELECT 
    ReportDate,
    ROUND(AVG(CallDropRate), 2) AS AvgCallDropRate,
    ROUND(AVG(AvgLatencyMS), 2) AS AvgLatency,
    ROUND(AVG(SignalStrengthDBM), 2) AS AvgSignalStrength,
    SUM(DowntimeMinutes) AS TotalDowntime
FROM NetworkPerformance
GROUP BY ReportDate
ORDER BY ReportDate DESC;


-- Below are advanced SQL Queries.
-- Shows the monthly invoice amount and status for each customer.
SELECT 
    c.Name AS CustomerName,
    MONTH(i.InvoiceDate) AS BillMonth,
    YEAR(i.InvoiceDate) AS BillYear,
    i.Amount AS MonthlyCharge,
    i.Status AS PaymentStatus
FROM Invoice i
JOIN Subscription s ON i.SubscriptionID = s.SubscriptionID
JOIN Customer c ON s.CustomerID = c.CustomerID
ORDER BY BillYear DESC, BillMonth DESC;

-- Analyze Calling Patterns (Average Call Duration per Customer
-- Identifies customers with long call durations, which may indicate heavy users.
select
    c.Name AS CustomerName,
    COUNT(cr.CallID) AS TotalCalls,
    ROUND(AVG(cr.DurationMinutes), 2) AS AvgCallDuration
FROM CallRecord cr
JOIN Subscription s ON cr.SubscriptionID = s.SubscriptionID
JOIN Customer c ON s.CustomerID = c.CustomerID
GROUP BY c.Name
ORDER BY AvgCallDuration DESC;

-- High-Value Customers Based on Usage (Calls + Data + SMS)
-- Combines call minutes, data used, and SMS count into a usage score — to rank top customers.
SELECT 
    c.Name,
    COALESCE(call_stats.TotalCallMinutes, 0) + 
    COALESCE(data_stats.TotalDataUsedMB, 0) +
    COALESCE(sms_stats.TotalSMS, 0) AS TotalUsageScore
FROM Customer c
LEFT JOIN (
    SELECT s.CustomerID, SUM(cr.DurationMinutes) AS TotalCallMinutes
    FROM CallRecord cr
    JOIN Subscription s ON cr.SubscriptionID = s.SubscriptionID
    GROUP BY s.CustomerID
) AS call_stats ON c.CustomerID = call_stats.CustomerID
LEFT JOIN (
    SELECT s.CustomerID, SUM(du.DataUsedMB) AS TotalDataUsedMB
    FROM DataUsage du
    JOIN Subscription s ON du.SubscriptionID = s.SubscriptionID
    GROUP BY s.CustomerID
) AS data_stats ON c.CustomerID = data_stats.CustomerID
LEFT JOIN (
    SELECT s.CustomerID, COUNT(*) AS TotalSMS
    FROM SMSRecord sr
    JOIN Subscription s ON sr.SubscriptionID = s.SubscriptionID
    GROUP BY s.CustomerID
) AS sms_stats ON c.CustomerID = sms_stats.CustomerID
ORDER BY TotalUsageScore DESC;



