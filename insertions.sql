USE AngieRopas

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

	Select * from Categories

-- Ingresar Customers
INSERT INTO Customers (FirstName, LastName, Phone, Points)
	VALUES
		('Abraham', 'Santos', '8295650292', 0),
		('Abigail', 'Fernández', '8295402463', 0);

SELECT * FROM Customers
-- DELETE FROM Customers where Id = 10
/* Test Store Procedures */

-- 1. Test InsertProduct
EXEC InsertProduct 'Producto 1', 'Descripción del Producto 1', 100, 1, 20;
EXEC InsertProduct 'Producto 2', 'Descripción del Producto 2', 100, 2, 20;
EXEC InsertProduct 'Producto 3', 'Descripción del Producto 3', 100, 3, 20;
EXEC InsertProduct 'Producto 4', 'Descripción del Producto 4', 300, 4, 20;
EXEC InsertProduct 'Producto 5', 'Descripción del Producto 5', 250, 5, 20;
EXEC InsertProduct 'Producto 6', 'Descripción del Producto 6', 200, 6, 20;

SELECT * FROM Products

-- 2. Test Delete Product
EXEC DeleteProduct 2;
SELECT * FROM Products

-- 3. Test UpdateProduct
EXEC UpdateProduct 2, NULL, 'Le he cambiado el nombre al Producto 2';
SELECT * FROM Products

-- 4. Test RegisterPurchases
SELECT * FROM Products
SELECT * FROM Customers

EXEC AddToShoppingCart 12, 13, 5 -- NO SE VA A AGREGAR El artículo CustomerId, ProductId and Quantity
EXEC AddToShoppingCart 12, 11, 5 -- NO SE VA A AGREGAR El artículo CustomerId, ProductId and Quantity
EXEC AddToShoppingCart 12, 10, 5 -- NO SE VA A AGREGAR El artículo CustomerId, ProductId and Quantity

SELECT * FROM ShoppingCarts

-- 4.1 Test Remove from shopping cart
EXEC RemoveFromShoppingCart 8, 3

-- 4.2 Purchase. The following select statements are the modified tables after executing the store procedure after those.
SELECT * FROM Orders
SELECT * FROM OrderDetails
SELECT * FROM Customers
SELECT * FROM ShoppingCarts

EXEC Purchase 12;
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

SELECT * FROM TopFiveProducts
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

EXEC BestSellingForACustomer 12, 4;
GO

-- 8. Obtener el cliente con más puntos en la tienda para que pueda obtener un descuento.
CREATE VIEW ClientWithHighestScore
AS
SELECT TOP(1) * FROM Customers ORDER BY Points DESC
GO
go

SELECT * FROM ClientWithHighestScore;
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

SELECT * FROM CategoriesRanking -- Test 10.1
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

EXEC ProductsRankingByCategory 6