CREATE DATABASE AngieRopas

USE AngieRopas

CREATE TABLE Categories (
	Id INT CONSTRAINT PK_Id_Categories
		PRIMARY KEY (Id) IDENTITY(1,1) NOT NULL,
	Name VARCHAR(80) NOT NULL,
	Description VARCHAR(300),
)

CREATE TABLE Products (
	Id INT CONSTRAINT PK_Id_Products 
		PRIMARY KEY (Id) IDENTITY(1,1) NOT NULL,
	Name VARCHAR(250) NOT NULL,
	Description VARCHAR(500),
	CateogoryId INT CONSTRAINT FK_ID_Categories
		FOREIGN KEY (Id) REFERENCES Categories (Id) NOT NULL,
);

CREATE TABLE Customers (
	Id INT CONSTRAINT PK_Id_Customers
		PRIMARY KEY (Id) IDENTITY(1,1) NOT NULL,
	Firstname VARCHAR(350) NOT NULL,
	Lastname VARCHAR (500),
	Phone VARCHAR(10),
	Email VARCHAR(500),
);

CREATE TABLE Orders(
	Id INT CONSTRAINT PK_Id_Orders
		PRIMARY KEY (Id) IDENTITY(1,1) NOT NULL,
	CustomerId INT CONSTRAINT FK_ID_Customers
		FOREIGN KEY (Id) REFERENCES Customers (Id) NOT NULL,
	OrderDate DATE NOT NULL,
);

CREATE TABLE OrderDetails(
	Id INT CONSTRAINT PK_Id_Orders
		PRIMARY KEY (Id) IDENTITY(1,1) NOT NULL,
	OrderId INT CONSTRAINT FK_ID_Orders
		FOREIGN KEY (Id) REFERENCES Orders (Id) NOT NULL,
	ProductId INT CONSTRAINT FK_ID_Products
		FOREIGN KEY (Id) REFERENCES Products (Id) NOT NULL,
	Quantity INT NOT NULL,
	ShipDate Date NOT NULL,
);

/* Categories insertion */
INSERT INTO Categories (Name)
	VALUES 
		('Calzados'),
		('Camisas'),
		('Blusas'),
		('Pantalones'),
		('Faldas'),
		('Vestidos'),
		('Accesorios');

INSERT 