CREATE DATABASE AngieRopas
GO

USE AngieRopas
GO

CREATE TABLE Categories (
	Id INT CONSTRAINT PK_Id_Categories
		PRIMARY KEY (Id) IDENTITY(1,1) NOT NULL,
	Name VARCHAR(80) NOT NULL,
	Description VARCHAR(300),
)
GO

CREATE TABLE Customers (
	Id INT CONSTRAINT PK_Id_Customers
		PRIMARY KEY (Id) IDENTITY(1,1) NOT NULL,
	Firstname VARCHAR(350) NOT NULL,
	Lastname VARCHAR (500),
	Phone VARCHAR(10),
	Email VARCHAR(500),
	Points INT DEFAULT 0,
);
GO

CREATE TABLE Products (
	Id INT CONSTRAINT PK_Id_Products 
		PRIMARY KEY (Id) IDENTITY(1,1) NOT NULL,
	Name VARCHAR(250) NOT NULL,
	Description VARCHAR(500),
	Price MONEY NOT NULL,
	Available BIT DEFAULT 1,
	Stock INT,
	CategoryId INT CONSTRAINT FK_Id_Products_Categories
		FOREIGN KEY (CategoryId) REFERENCES Categories (Id) NOT NULL,
);
GO


CREATE TABLE Orders(
	Id INT CONSTRAINT PK_Id_Orders
		PRIMARY KEY (Id) IDENTITY(1,1) NOT NULL,
	CustomerId INT CONSTRAINT FK_ID_Orders_Customers
		FOREIGN KEY (CustomerId) REFERENCES Customers (Id) NOT NULL,
	OrderDate DATETIME NOT NULL,
);
GO

CREATE TABLE OrderDetails(
	Id INT CONSTRAINT PK_Id_OrderDetails
		PRIMARY KEY (Id) IDENTITY(1,1) NOT NULL,
	OrderId INT CONSTRAINT FK_Id_OrderDetails_Orders
		FOREIGN KEY (OrderId) REFERENCES Orders (Id) NOT NULL,
	ProductId INT CONSTRAINT FK_Id_OrderDetails_Products
		FOREIGN KEY (ProductId) REFERENCES Products (Id) NOT NULL,
	Quantity INT NOT NULL,
	Price MONEY NOT NULL,
	Itbis MONEY NOT NULL,
);
GO

CREATE TABLE ShoppingCarts(
	Id INT CONSTRAINT PK_Id_ShoppingCart
		PRIMARY KEY (Id) IDENTITY(1,1) NOT NULL,
	CustomerId INT CONSTRAINT FK_Id_ShoppingCarts_Customers
		FOREIGN KEY (CustomerId) REFERENCES Customers (Id) NOT NULL,
	ProductId INT CONSTRAINT FK_Id_ShoppingCarts_Products
		FOREIGN KEY (ProductId) REFERENCES Products (Id) NOT NULL,
	Quantity INT NOT NULL
);
GO

/* 1. Ingresar nuevos productos, Store Procedure */
CREATE PROCEDURE InsertProduct(
	@name varchar(250),
	@description VARCHAR(500) = NULL,
	@price MONEY,
	@categoryId INT,
	@stock INT = 0,
	@available BIT = 1)
AS
BEGIN
	INSERT INTO Products (Name, Description, Price, CategoryId, Stock, Available)
		VALUES (@name, @description, @price, @categoryId, @stock, @available);
END
GO

/* 2. Eliminar Productos */
CREATE PROCEDURE DeleteProduct(@productId INT)
AS
BEGIN
	UPDATE Products SET Available = 0 WHERE Id = @productId;
END
GO


/* 3. Actualizar Productos */
CREATE PROCEDURE UpdateProduct(
	@id INT,
	@categoryId INT = NULL,
	@name varchar(250) = NULL,
	@description VARCHAR(500) = NULL,
	@price MONEY = NULL,
	@stock INT = NULL,
	@available BIT = NULL)
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION;
		IF(@categoryId IS NOT NULL)
			UPDATE Products SET CategoryId = @categoryId WHERE Id = @id;
		IF(@name IS NOT NULL)
			UPDATE Products SET Name = @name WHERE Id = @id;
		IF(@description IS NOT NULL)
			UPDATE Products SET Description = @description WHERE Id = @id;
		IF(@price IS NOT NULL)
			UPDATE Products SET Description = @description WHERE Id = @id;
		IF(@stock IS NOT NULL)
			Update Products SET Stock += @stock WHERE Id = @id;
		IF(@available IS NOT NULL)
			BEGIN
			Update Products SET Available = @available WHERE Id = @id;
			Update Products SET Stock = 0 WHERE Id = @id;
			END
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		PRINT 'Ha ocurrido un error. No hubieron cambios en la tabla Products'
	END CATCH
END
GO

-- 4. Register purchases
CREATE PROC AddToShoppingCart(
	@customerId INT,
	@productId INT,
	@quantity INT)
AS
BEGIN
	-- Testing availability
	DECLARE @availability BIT = (SELECT Available FROM Products WHERE Id = @productId);
	IF(@availability = 0)
		PRINT 'El artículo no se encuentra disponible. No se agregó al carrito de compras';
	ELSE
		BEGIN
			IF(@quantity > 0)
				BEGIN
					-- Add products to the shopping cart. Before, test if the quantity es greater than 0.
					DECLARE @stock INT = (SELECT Stock FROM Products WHERE Id = @productId);
					IF(@quantity > @stock)
						PRINT CONCAT('No existen suficientes de ese artículo. Solo quedan', @stock, ' disponibles');
					ELSE
						BEGIN
							BEGIN TRY
								IF EXISTS ((SELECT * FROM ShoppingCarts WHERE CustomerId = @customerId AND ProductId = @productId))
									BEGIN
										UPDATE ShoppingCarts SET Quantity += @quantity 
										WHERE CustomerId = @customerId AND ProductId = @productId
									END
								ELSE
									BEGIN
										INSERT INTO ShoppingCarts (CustomerId, ProductId, Quantity) 
										VALUES (@customerId, @productId, @quantity);
									END
							END TRY
								BEGIN CATCH
									PRINT 'Hubo un error con los datos suministrados. No se agregó al carrito';
							END CATCH
						END
				END
			ELSE
				PRINT 'Debe especificar una cantidad. El producto no fue añadido al carrito';
		END
END
GO

-- 4.1 Delete Products from the shopping cart
CREATE PROC RemoveFromShoppingCart(@customerId INT, @productId INT)
AS
BEGIN
	BEGIN TRY
		DELETE FROM ShoppingCarts WHERE ProductId = @productId AND CustomerId = @customerId;
	END TRY
	BEGIN CATCH
		PRINT 'El producto solicitado para eliminar no se encuentra en su carrito de compras';
	END CATCH
END
GO

-- 4.2 Purchase
CREATE PROC Purchase(@customerId INT)
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION
			/* Update the stock */
			
			-- ShoppingCart cursor
			DECLARE ShoppingCart_Cursor CURSOR LOCAL FOR
				SELECT ProductId, Quantity
				FROM ShoppingCarts 
				WHERE CustomerId = @customerId;
	
			OPEN ShoppingCart_Cursor;

			-- Store current product of the shopping cart in the following variables.
			DECLARE @productId INT, @productQuantity INT;
			FETCH ShoppingCart_Cursor INTO @productId, @productQuantity;

			-- Iterating through the rest of products in the shopping cart.
			FETCH NEXT FROM ShoppingCart_Cursor;
			WHILE @@FETCH_STATUS = 0
				BEGIN
					DECLARE @stock INT = (SELECT Stock FROM Products WHERE Id = @productId);
					IF(@productQuantity <= @stock)
						BEGIN
							UPDATE Products SET Stock -= @productQuantity WHERE Id = @productId;
							FETCH NEXT FROM ShoppingCart_Cursor;
						END
					ELSE
						BEGIN
							-- Cancel transaction after discover insuficient stock for the required product.
							DECLARE @productName VARCHAR(250) = (SELECT Name FROM Products WHERE Id = @productId);
							PRINT CONCAT('La cantidad del producto "', @productName, '" es insuficiente. La compra ha sido cancelada');
					
							-- Close cursor.
							CLOSE ShoppingCart_Cursor
							DEALLOCATE ShoppingCart_Cursor
					
							-- Cancel transaction.
							ROLLBACK TRANSACTION
					
							RETURN;
						END
				END

			-- Close cursor
			CLOSE ShoppingCart_Cursor;
			DEALLOCATE ShoppingCart_Cursor;

			/* Register Shopping Cart Order (affects Orders and OrderDetails tables) */

			DECLARE @table TABLE (OrderId INT); -- Table to store the CustomerId

			-- Insert the new order.
			INSERT Orders (CustomerId, OrderDate)
			OUTPUT INSERTED.Id INTO @table
			VALUES (@customerId, GETDATE());

			DECLARE @orderId INT = (SELECT TOP 1 OrderId FROM @table);

			-- Insert order details (related with the inserted order).
			INSERT INTO OrderDetails 
			SELECT 
				@orderId,
				s.ProductId,
				s.Quantity,
				p.Price,
				(p.Price * s.Quantity * 0.18)
			FROM ShoppingCarts AS s
			INNER JOIN Products as p ON p.Id = s.ProductId
			WHERE s.CustomerId = @customerId;

			/* Update customer points */
			DECLARE @totalPurchase MONEY;
			SET @totalPurchase = (SELECT SUM(Price * Quantity) FROM OrderDetails WHERE OrderId = @orderId);
			
			DECLARE @itbisTotal MONEY
			SET @itbisTotal = (SELECT SUM(Itbis) FROM OrderDetails WHERE OrderId = @orderId);
			
			DECLARE @total MONEY 
			SET @total = @totalPurchase + @itbisTotal;

			IF(@total >= 100)
				UPDATE Customers SET Points += FLOOR(@total / 100) WHERE Id = @customerId;

			/* Clean shopping cart */
			DELETE ShoppingCarts WHERE CustomerId = @customerId;
	
			PRINT 'Orden Registrada';
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		PRINT 'Ha ocurrido un problema. La orden no fue registrada.';
	END CATCH
END
GO

-- 5 Mostrar los 5 productos mas vendidos
CREATE VIEW TopFiveProducts
AS
SELECT TOP 5
	O.ProductId,
	Name,
	SUM(Quantity) AS [Total Sales]
FROM Products AS p
INNER JOIN OrderDetails AS o ON p.Id = o.ProductId
GROUP BY o.ProductId, Name
ORDER BY [Total Sales] DESC
GO

-- 6. 
CREATE PROC BestSellingForACustomer (@customerId int, @quantity INT)
AS BEGIN
	SELECT TOP(@quantity)
		c.FirstName as [Customer's Name], 
		od.ProductId as [Product ID], 
		p.Name as [Product Description], 
		sum(Quantity) as [Total Sales]
	from Products as p
	INNER JOIN OrderDetails AS od on p.Id = od.ProductId
	INNER JOIN Orders as o on o.Id = od.OrderId
	INNER JOIN Customers as c on c.Id = o.CustomerId
	WHERE o.CustomerID = @customerId
	GROUP BY od.ProductId, Name, c.FirstName
	ORDER BY [Total Sales] DESC
END
GO

-- 8. Obtener el cliente con más puntos en la tienda para que pueda obtener un descuento.
CREATE VIEW ClientWithHighestScore
AS
SELECT TOP(1) * FROM Customers ORDER BY Points DESC
GO

-- 9. Actualizar clientes
CREATE PROC UpdateCustomer(
	@customerId INT,
	@firstname VARCHAR(350) = NULL,
	@lastname VARCHAR (500) = NULL,
	@phone VARCHAR(10) = NULL,
	@email VARCHAR(500) = NULL,
	@points INT = NULL)
AS BEGIN
	BEGIN TRY
		BEGIN TRANSACTION
			IF(@firstname IS NOT NULL)
				UPDATE Customers SET Firstname = @firstname WHERE Id = @customerId;
			IF(@lastname IS NOT NULL)
				UPDATE Customers SET Lastname = @lastname WHERE Id = @customerId;
			IF(@phone IS NOT NULL)
				UPDATE Customers SET Phone = @phone WHERE Id = @customerId;
			IF(@email IS NOT NULL)
				UPDATE Customers SET Email = @email WHERE Id = @customerId;
			IF(@points IS NOT NULL)
				UPDATE Customers SET Points = @points WHERE Id = @customerId;
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		PRINT 'Ha ocurrido un error en la actualización del Customer. No se aplicaron cambios.';
	END CATCH
END
GO

-- 10.1 Ranking de las categorias más vendidas
CREATE VIEW CategoriesRanking
AS
SELECT TOP(10)
	c.Name AS [Category Name],
	SUM(od.Quantity) AS [Total Sales]
FROM Categories AS c
INNER JOIN Products AS p 
	ON p.CategoryId = c.Id
INNER JOIN OrderDetails AS od 
	ON od.ProductId = p.Id
GROUP BY c.Name
ORDER BY [Total SAles] desc
GO

-- 10.2 Ranking de los productos más vendidos por categorías.
CREATE PROC ProductsRankingByCategory(@categoryId INT)
AS BEGIN
	SELECT TOP(10)
		p.Id AS [Product Id], 
		p.Name AS [Product Name],
		c.Name AS [Category Name],
		p.Price,
		SUM(od.Quantity) AS [Total Sales]
	FROM Products AS p
	INNER JOIN Categories as c
		ON p.CategoryId = c.Id
	INNER JOIN OrderDetails AS od
		ON od.ProductId = p.Id
	WHERE p.CategoryId = @categoryId
	GROUP BY p.Id, p.Name, c.Name, p.Price
	ORDER BY [Total Sales] DESC
END