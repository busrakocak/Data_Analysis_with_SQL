drop table Transactions;
--1. 
CREATE TABLE Transactions (
			Sender_ID INT, 
			Receiver_ID INT, 
			Amount INT, 
			Transaction_Date DATE NOT NULL, );

INSERT INTO Transactions (Sender_ID, Receiver_ID, Amount, Transaction_Date)
VALUES 
(55,22,500,'20120518'),
(11,33,350,'20210519'),
(22,11,650,'20210519'),
(22,33,900,'20210520'),
(33,11,500,'20210521'),
(33,22,750,'20210521'),
(11,44,300,'20210522')

SELECT *
FROM Transactions

--2.

SELECT Sender_ID, SUM (Amount) AS Total_Sender
FROM Transactions
GROUP BY Sender_ID;

SELECT Receiver_ID, SUM (Amount) AS Total_Receiver
FROM Transactions
GROUP BY Receiver_ID;

--3.

SELECT coalesce( S.Sender_ID, R.Receiver_ID)  AS Account_ID, (coalesce(R.Total_Receiver, 0) - coalesce(S.Total_Sender, 0)) 
				AS Net_Change
FROM ( SELECT Sender_ID, SUM (Amount) AS Total_Sender
		FROM Transactions
		GROUP BY Sender_ID) AS S
FULL OUTER JOIN (SELECT Receiver_ID, SUM (Amount) AS Total_Receiver
				FROM Transactions
				GROUP BY Receiver_ID) AS R
ON S.Sender_ID = R.Receiver_ID
ORDER BY Net_Change DESC ;




