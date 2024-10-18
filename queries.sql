
-- Response time per HTTP method
SELECT HTTP_Method, AVG(Response_Time), MAX(Response_Time), MIN(Response_Time) 
FROM HTTP_Log
GROUP BY HTTP_Method;

-- Response time per endpoint
SELECT Endpoint, AVG(Response_Time), MAX(Response_Time), MIN(Response_Time) 
FROM HTTP_Log
WHERE Endpoint IS NOT NULL
GROUP BY Endpoint;

-- Requests per 10 minutes
SELECT 
    DATE_FORMAT(Timestamp, '%Y-%m-%d %H:%i:00') AS time_interval,
    COUNT(*) AS request_count
FROM HTTP_Log
GROUP BY time_interval
ORDER BY time_interval;

-- Buys and Sells distribution
SELECT Side, COUNT(*) 
FROM `Order` 
GROUP BY Side;

-- HTTP Method distribution
SELECT 
    HTTP_Method,
    (COUNT(*) * 100.0 / (SELECT COUNT(*) FROM HTTP_Log)) AS percentage
FROM 
    HTTP_Log
GROUP BY 
    HTTP_Method;

-- Average Heartbeat Interval per Target Company
SELECT TargetCompID, AVG(HeartBtInt) AS AvgHeartbeatInterval
FROM Heartbeat_Message
GROUP BY TargetCompID;
