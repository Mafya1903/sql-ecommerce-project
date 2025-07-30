-- SQL END-to-END Projesi - 1. Proje: Veritabanı Oluşturma ve Yapılandırma
-- Bu dosya, e-ticaret veritabanı şemasını oluşturmak, örnek verilerle doldurmak
-- ve temel veri doğrulama sorgularını çalıştırmak için gerekli tüm SQL komutlarını içerir.

-- Veritabanı Tasarımı ve Tabloların Oluşturulması
-- Aşağıdaki CREATE TABLE komutları, e-ticaret sistemi için gerekli temel tabloları
-- ve aralarındaki ilişkileri tanımlar. Her tablo, birincil anahtarlar ve
-- dış anahtarlar ile ilişkisel bütünlüğü sağlayacak şekilde tasarlanmıştır.

-- 1. Customers Tablosu: Müşteri bilgilerini saklar
CREATE TABLE Customers (
    customer_id SERIAL PRIMARY KEY, -- Müşteri için benzersiz ID, otomatik artar
    name VARCHAR(100),              -- Müşterinin adı
    email VARCHAR(100),             -- Müşterinin e-posta adresi (benzersiz olabilir, ancak burada UNIQUE kısıtlaması yok)
    phone VARCHAR(20),              -- Müşterinin telefon numarası
    address TEXT                    -- Müşterinin adresi
);

-- 2. Categories Tablosu: Ürün kategorilerini saklar
CREATE TABLE Categories (
    category_id SERIAL PRIMARY KEY, -- Kategori için benzersiz ID, otomatik artar
    category_name VARCHAR(100) NOT NULL -- Kategori adı, boş bırakılamaz
);

-- 3. Products Tablosu: Ürün bilgilerini saklar
CREATE TABLE Products (
    product_id SERIAL PRIMARY KEY,  -- Ürün için benzersiz ID, otomatik artar
    category_id INT REFERENCES Categories(category_id), -- Ürünün ait olduğu kategori ID'si (Categories tablosuna referans verir)
    product_name VARCHAR(100) NOT NULL, -- Ürün adı, boş bırakılamaz
    price DECIMAL(10,2),            -- Ürünün fiyatı (10 toplam basamak, virgülden sonra 2 basamak)
    stock INT                       -- Ürünün stok miktarı
);

-- 4. Orders Tablosu: Sipariş bilgilerini saklar
CREATE TABLE Orders (
    order_id SERIAL PRIMARY KEY,    -- Sipariş için benzersiz ID, otomatik artar
    customer_id INT REFERENCES Customers(customer_id), -- Siparişi veren müşteri ID'si (Customers tablosuna referans verir)
    order_date DATE,                -- Siparişin verildiği tarih
    status VARCHAR(30)              -- Siparişin durumu (örn: 'pending', 'delivered', 'canceled')
);

-- 5. OrderItems Tablosu: Her siparişin içerdiği ürünleri ve miktarlarını saklar
-- Bu tablo, Orders ve Products tabloları arasındaki çoktan çoğa ilişkiyi yönetir.
CREATE TABLE OrderItems (
    order_item_id SERIAL PRIMARY KEY, -- Sipariş öğesi için benzersiz ID, otomatik artar
    order_id INT REFERENCES Orders(order_id), -- İlişkili siparişin ID'si (Orders tablosuna referans verir)
    product_id INT REFERENCES Products(product_id), -- İlişkili ürünün ID'si (Products tablosuna referans verir)
    quantity INT,                   -- Sipariş edilen ürün miktarı
    unit_price DECIMAL(10,2)        -- Ürünün sipariş anındaki birim fiyatı
);

-- 6. Payments Tablosu: Ödeme bilgilerini saklar
CREATE TABLE Payments (
    payment_id SERIAL PRIMARY KEY,  -- Ödeme için benzersiz ID, otomatik artar
    order_id INT REFERENCES Orders(order_id) UNIQUE, -- İlişkili siparişin ID'si (Orders tablosuna referans verir), UNIQUE kısıtlaması ile her siparişin tek bir ödemesi olmasını sağlar
    payment_date DATE,              -- Ödemenin yapıldığı tarih
    amount DECIMAL(10,2),           -- Ödenen miktar
    payment_method VARCHAR(50)      -- Ödeme yöntemi (örn: 'Kredi Kartı', 'Nakit', 'Havale')
);


-- Veri Tiplerinin Belirlenmesi ve Tabloların Doldurulması
-- Aşağıdaki INSERT INTO komutları, yukarıda oluşturulan tablolara örnek veriler ekler.
-- Bu veriler, veritabanı yapısının ve ilişkilerinin doğru çalıştığını test etmek için kullanılır.

-- Customers tablosuna veri ekleme
INSERT INTO Customers (name, email, phone, address) VALUES
('Ali Veli', 'ali@eposta.com', '5551234567', 'İstanbul'),
('Ayşe Yılmaz', 'ayse@eposta.com', '5557654321', 'Ankara');

-- Categories tablosuna veri ekleme
INSERT INTO Categories (category_name) VALUES
('Elektronik'),
('Giyim');

-- Products tablosuna veri ekleme
-- category_id'ler, Categories tablosundaki ID'lere göre ayarlanmıştır.
INSERT INTO Products (category_id, product_name, price, stock) VALUES
(1, 'Laptop', 15000.00, 10), -- Elektronik kategorisine ait
(2, 'Tişört', 120.00, 50);   -- Giyim kategorisine ait

-- Orders tablosuna veri ekleme
-- customer_id'ler, Customers tablosundaki ID'lere göre ayarlanmıştır.
INSERT INTO Orders (customer_id, order_date, status) VALUES
(1, '2024-07-01', 'delivered'), -- Ali Veli'nin siparişi
(2, '2024-07-02', 'pending');   -- Ayşe Yılmaz'ın siparişi

-- OrderItems tablosuna veri ekleme
-- order_id ve product_id'ler ilgili tablolardaki ID'lere göre ayarlanmıştır.
INSERT INTO OrderItems (order_id, product_id, quantity, unit_price) VALUES
(1, 1, 1, 15000.00), -- 1. siparişte 1 adet Laptop
(1, 2, 2, 120.00),   -- 1. siparişte 2 adet Tişört
(2, 2, 1, 120.00);   -- 2. siparişte 1 adet Tişört

-- Payments tablosuna veri ekleme
-- order_id, Orders tablosundaki ID'ye göre ayarlanmıştır.
INSERT INTO Payments (order_id, payment_date, amount, payment_method) VALUES
(1, '2024-07-01', 15240.00, 'Kredi Kartı'); -- 1. siparişin ödemesi


-- Veritabanı ve Tabloların Doğrulaması & Veritabanı İlişkilerinin Doğruluğunu Kontrol Etme
-- Aşağıdaki SELECT sorgusu, farklı tabloları birleştirerek veri bütünlüğünü ve
-- ilişkilerin doğru kurulduğunu doğrular.

-- Sipariş detaylarını müşteri, ürün ve ödeme bilgileriyle birlikte getiren sorgu
SELECT
    o.order_id,         -- Sipariş ID'si
    c.name AS customer_name, -- Müşteri adı
    p.product_name,     -- Ürün adı
    oi.quantity,        -- Sipariş edilen miktar
    pay.payment_method  -- Ödeme yöntemi (eğer varsa)
FROM
    Orders o
JOIN
    Customers c ON o.customer_id = c.customer_id -- Orders tablosunu Customers tablosuyla müşteri ID'sine göre birleştir
JOIN
    OrderItems oi ON o.order_id = oi.order_id   -- Orders tablosunu OrderItems tablosuyla sipariş ID'sine göre birleştir
JOIN
    Products p ON oi.product_id = p.product_id   -- OrderItems tablosunu Products tablosuyla ürün ID'sine göre birleştir
LEFT JOIN
    Payments pay ON o.order_id = pay.order_id    -- Orders tablosunu Payments tablosuyla sipariş ID'sine göre sol birleştir (ödemesi olmayan siparişler de görünür)
ORDER BY
    o.order_id; -- Sonuçları sipariş ID'sine göre sırala

