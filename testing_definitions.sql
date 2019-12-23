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
		('Abigail', 'Fern�ndez', '8295402463', 0);

SELECT * FROM Customers
-- DELETE FROM Customers where Id = 10
/* Test Store Procedures */

-- 1. Test InsertProduct
EXEC InsertProduct 'Producto 1', 'Descripci�n del Producto 1', 100, 1, 20;
EXEC InsertProduct 'Producto 2', 'Descripci�n del Producto 2', 100, 2, 20;
EXEC InsertProduct 'Producto 3', 'Descripci�n del Producto 3', 100, 3, 20;
EXEC InsertProduct 'Producto 4', 'Descripci�n del Producto 4', 300, 4, 20;
EXEC InsertProduct 'Producto 5', 'Descripci�n del Producto 5', 250, 5, 20;
EXEC InsertProduct 'Producto 6', 'Descripci�n del Producto 6', 200, 6, 20;

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

EXEC AddToShoppingCart 12, 13, 5 -- NO SE VA A AGREGAR El art�culo CustomerId, ProductId and Quantity
EXEC AddToShoppingCart 12, 11, 5 -- NO SE VA A AGREGAR El art�culo CustomerId, ProductId and Quantity
EXEC AddToShoppingCart 12, 10, 5 -- NO SE VA A AGREGAR El art�culo CustomerId, ProductId and Quantity

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
SELECT * FROM TopFiveProducts
GO

-- 6. 
EXEC BestSellingForACustomer 12, 4;
GO

-- 8. Obtener el cliente con m�s puntos en la tienda para que pueda obtener un descuento.
SELECT * FROM ClientWithHighestScore;
GO

-- 9. Actualizar clientes
EXEC UpdateCustomer 12, 'CAmbiado el nombre No. 12';
GO

-- 10.1 Ranking de las categorias m�s vendidas
SELECT * FROM CategoriesRanking -- Test 10.1
GO

-- 10.2 Ranking de los productos m�s vendidos por categor�as.
EXEC ProductsRankingByCategory 6