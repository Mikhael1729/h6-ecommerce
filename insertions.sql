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
INSERT INTO Customers (FirstName, LastName, Phone)
	VALUES('Mikhael', 'Santos', '8493518051')
INSERT INTO Customers (FirstName, LastName, Phone)
	VALUES('Abraham', 'Santos', '8295650292')

SELECT * FROM Customers
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

EXEC AddToShoppingCart 3, 2, 5 -- NO SE VA A AGREGAR El artículo CustomerId, ProductId and Quantity
EXEC AddToShoppingCart 3, 1, 5 -- NO SE VA A AGREGAR El artículo CustomerId, ProductId and Quantity

SELECT * FROM ShoppingCarts
DELETE FROM ShoppingCarts 

-- 4.1 Test Add to shopping cart