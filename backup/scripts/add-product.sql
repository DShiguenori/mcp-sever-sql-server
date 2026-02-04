-- Add new product: Notebook Macbook
USE ProductsDb;
GO

INSERT INTO dbo.Products (Name, Description, Price, Stock) VALUES
    (N'Notebook Macbook', N'its a computed', 15000.00, 2);
