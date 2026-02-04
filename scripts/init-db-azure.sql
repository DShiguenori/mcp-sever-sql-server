-- Azure SQL: Create Products table and seed data
-- Run against ProductsDb after az sql db create
-- Usage: sqlcmd -S <server>.database.windows.net -d ProductsDb -U <user> -P <password> -I -i init-db-azure.sql

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Products')
BEGIN
    CREATE TABLE dbo.Products (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        Name NVARCHAR(200) NOT NULL,
        Description NVARCHAR(500) NULL,
        Price DECIMAL(18,2) NOT NULL,
        Stock INT NOT NULL DEFAULT 0,
        CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE()
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Products)
BEGIN
    INSERT INTO dbo.Products (Name, Description, Price, Stock) VALUES
        (N'Wireless Headphones', N'Premium noise-cancelling wireless headphones', 149.99, 50),
        (N'USB-C Hub', N'7-in-1 USB-C hub with HDMI and SD card reader', 79.99, 120),
        (N'Mechanical Keyboard', N'RGB mechanical keyboard with Cherry MX switches', 129.99, 35),
        (N'Webcam HD', N'1080p webcam with built-in microphone', 89.99, 75),
        (N'External SSD 1TB', N'Portable NVMe SSD, 1TB capacity', 119.99, 40);
END
GO
