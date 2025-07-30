-- SQL END-to-END Projesi - 2. Proje: Mevcut Veri Seti ile SQL Sorguları ve Analizler
-- Bu betik, Brazilian E-Commerce Public Data seti üzerinde veritabanı tablolarını oluşturma
-- ve çeşitli iş analizi sorularını yanıtlamak için SQL sorguları çalıştırma adımlarını içerir.

-- 1. Veri Setinin PostgreSQL Sunucusuna Bağlanarak ya da Kaggle ile Çekilmesi (Tabloların Oluşturulması)
-- Bu bölüm, Olist Brazilian E-Commerce veri setinden seçilen dört temel tablonun
-- veritabanında oluşturulmasını sağlar. Bu tablolar, analitik sorgular için temel yapıyı oluşturur.
-- Her bir CREATE TABLE ifadesi, ilgili veri setinden alınan sütunları ve veri tiplerini tanımlar.

-- olist_orders Tablosu: Sipariş ana bilgilerini içerir.
CREATE TABLE olist_orders (
    order_id VARCHAR(50) PRIMARY KEY, -- Siparişin benzersiz ID'si, birincil anahtar
    customer_id VARCHAR(50),           -- Müşterinin ID'si
    order_status VARCHAR(20),          -- Siparişin mevcut durumu (örn: 'delivered', 'pending', 'canceled')
    order_purchase_timestamp TIMESTAMP, -- Siparişin satın alma zaman damgası
    order_approved_at TIMESTAMP,        -- Siparişin onaylandığı zaman damgası
    order_delivered_carrier_date TIMESTAMP, -- Siparişin taşıyıcıya teslim edildiği zaman damgası
    order_delivered_customer_date TIMESTAMP, -- Siparişin müşteriye teslim edildiği zaman damgası
    order_estimated_delivery_date TIMESTAMP -- Tahmini teslimat zaman damgası
);

-- olist_order_items Tablosu: Her sipariş içindeki ürün öğelerini detaylandırır.
CREATE TABLE olist_order_items (
    order_id VARCHAR(50),              -- Siparişin ID'si (olist_orders tablosuna referans verir)
    order_item_id INT,                 -- Sipariş içindeki ürün öğesinin ID'si (bir siparişte birden fazla ürün olabilir)
    product_id VARCHAR(50),            -- Ürünün ID'si (olist_products tablosuna referans verir)
    seller_id VARCHAR(50),             -- Satıcının ID'si
    shipping_limit_date TIMESTAMP,      -- Nakliye limit tarihi
    price NUMERIC,                      -- Ürünün fiyatı
    freight_value NUMERIC,              -- Nakliye ücreti
    PRIMARY KEY (order_id, order_item_id) -- order_id ve order_item_id birlikte birincil anahtarı oluşturur
);

-- olist_products Tablosu: Ürün bilgilerini içerir.
CREATE TABLE olist_products (
    product_id VARCHAR(50) PRIMARY KEY, -- Ürünün benzersiz ID'si, birincil anahtar
    product_category_name VARCHAR(100), -- Ürünün kategori adı
    product_name_lenght INT,            -- Ürün adının karakter uzunluğu
    product_description_lenght INT,     -- Ürün açıklamasının karakter uzunluğu
    product_photos_qty INT,             -- Ürünün fotoğraf sayısı
    product_weight_g INT,               -- Ürünün ağırlığı (gram cinsinden)
    product_length_cm INT,              -- Ürünün uzunluğu (cm cinsinden)
    product_height_cm INT,              -- Ürünün yüksekliği (cm cinsinden)
    product_width_cm INT                -- Ürünün genişliği (cm cinsinden)
);

-- olist_customers Tablosu: Müşteri bilgilerini içerir.
CREATE TABLE olist_customers (
    customer_id VARCHAR(50) PRIMARY KEY,    -- Müşterinin ID'si (siparişlerle ilişkilendirilen ID)
    customer_unique_id VARCHAR(50),         -- Müşterinin benzersiz ID'si (aynı kişinin farklı customer_id'leri olabilir)
    customer_zip_code_prefix VARCHAR(20),   -- Müşterinin posta kodu ön eki
    customer_city VARCHAR(100),             -- Müşterinin şehri
    customer_state VARCHAR(10)              -- Müşterinin eyaleti
);

-- 2. SQL Sorgularının Yazılması ve Analizler
-- Veritabanına veriler yüklendikten sonra (COPY komutları ile veya ilgili araçlarla),
-- aşağıdaki sorgular çeşitli iş analizi ve müşteri segmentasyonu sorularını yanıtlamak için kullanılır.

-- Veri Doğrulama ve İlk Gözlem Sorguları:
-- Her tablodan ilk 5 kaydı görüntüleyerek verilerin doğru şekilde yüklendiğini kontrol eder.
SELECT * FROM olist_orders LIMIT 5;
SELECT * FROM olist_order_items LIMIT 5;
SELECT * FROM olist_products LIMIT 5;
SELECT * FROM olist_customers LIMIT 5;

[cite_start]-- Soru 1: Olist'in aylık toplam gelirini hesaplayın. [cite: 124, 125]
-- Çözüm: Sadece 'delivered' (teslim edilen) durumdaki siparişleri kullanarak,
-- her sipariş öğesinin fiyatı ve kargo ücretini toplayarak toplam geliri bulur.
-- Sonuçları siparişin satın alma zaman damgasına göre aylık bazda gruplandırır.
SELECT
    DATE_TRUNC('month', o.order_purchase_timestamp) AS month, -- Sipariş tarihini aya göre keser
    SUM(oi.price + oi.freight_value) AS total_revenue          -- Fiyat ve kargo ücreti toplamı
FROM
    olist_orders o
JOIN
    olist_order_items oi ON o.order_id = oi.order_id -- Siparişleri sipariş öğeleriyle birleştirir
WHERE
    o.order_status = 'delivered' -- Sadece teslim edilen siparişleri filtreler
GROUP BY
    DATE_TRUNC('month', o.order_purchase_timestamp) -- Aylık geliri gruplandırır
ORDER BY
    month; -- Aylara göre sıralar

[cite_start]-- Soru 2: En çok satılan 10 ürün kategorisini bulun. [cite: 129, 130]
-- Çözüm: Teslim edilen siparişlerdeki her bir ürün kategorisi için satılan toplam ürün sayısını
-- ve toplam satış değerini hesaplar. Sonuçları satılan ürün sayısına göre azalan sırada sıralayarak
-- en popüler 10 kategoriyi gösterir.
SELECT
    p.product_category_name,                        -- Ürün kategori adı
    COUNT(oi.order_item_id) AS total_items_sold,    -- Satılan toplam ürün adedi
    SUM(oi.price * oi.order_item_id) AS total_sales_value -- Toplam satış değeri (fiyat * miktar)
FROM
    olist_orders o
JOIN
    olist_order_items oi ON o.order_id = oi.order_id -- Siparişleri sipariş öğeleriyle birleştirir
JOIN
    olist_products p ON oi.product_id = p.product_id -- Sipariş öğelerini ürün bilgileriyle birleştirir
WHERE
    o.order_status = 'delivered' -- Sadece teslim edilen siparişleri filtreler
GROUP BY
    p.product_category_name -- Ürün kategorisine göre gruplandırır
ORDER BY
    total_items_sold DESC -- Satılan ürün adedine göre azalan sıralama
LIMIT 10; -- İlk 10 kategoriyi gösterir

[cite_start]-- Soru 3: Müşterileri toplam harcamalarına göre segmentlere ayırın (>1000 BRL = Premium, 500-1000 BRL = Regular, <500 BRL = Low). [cite: 133, 134]
-- Çözüm: Her müşterinin toplam harcamasını (fiyat + kargo ücreti) hesaplar ve bu harcamaya göre
-- müşterileri 'Premium', 'Regular' veya 'Low' segmentlerine ayırır.
SELECT
    c.customer_unique_id,               -- Müşterinin benzersiz ID'si
    c.customer_state,                   -- Müşterinin eyaleti
    SUM(oi.price + oi.freight_value) AS total_spent, -- Müşterinin toplam harcaması
    CASE                                            -- Harcamaya göre müşteri segmenti ataması
        WHEN SUM(oi.price + oi.freight_value) > 1000 THEN 'Premium'
        WHEN SUM(oi.price + oi.freight_value) BETWEEN 500 AND 1000 THEN 'Regular'
        ELSE 'Low'
    END AS segment
FROM
    olist_customers c
JOIN
    olist_orders o ON c.customer_id = o.customer_id     -- Müşterileri siparişlerle birleştirir
JOIN
    olist_order_items oi ON o.order_id = oi.order_id -- Siparişleri sipariş öğeleriyle birleştirir
WHERE
    o.order_status = 'delivered' -- Sadece teslim edilen siparişleri filtreler
GROUP BY
    c.customer_unique_id, c.customer_state -- Benzersiz müşteri ve eyalete göre gruplandırır
ORDER BY
    total_spent DESC; -- Toplam harcamaya göre azalan sıralama

[cite_start]-- Soru 4: Her ürün kategorisi için ortalama sipariş değerini (AOV) hesaplayın. [cite: 138, 139]
-- Çözüm: Teslim edilen siparişlerdeki her ürün kategorisi için ortalama sipariş değerini
-- (fiyat + kargo ücreti) hesaplar.
SELECT
    p.product_category_name,                            -- Ürün kategori adı
    AVG(oi.price + oi.freight_value) AS avg_order_value -- Ortalama sipariş değeri
FROM
    olist_orders o
JOIN
    olist_order_items oi ON o.order_id = oi.order_id -- Siparişleri sipariş öğeleriyle birleştirir
JOIN
    olist_products p ON oi.product_id = p.product_id -- Sipariş öğelerini ürün bilgileriyle birleştirir
WHERE
    o.order_status = 'delivered' -- Sadece teslim edilen siparişleri filtreler
GROUP BY
    p.product_category_name -- Ürün kategorisine göre gruplandırır
ORDER BY
    avg_order_value DESC; -- Ortalama sipariş değerine göre azalan sıralama

[cite_start]-- Soru 5: Tekrar alım yapan müşterilerin sayısını ve toplam satışlara katkısını (%) hesaplayın. [cite: 143, 144]
-- Çözüm: CTE (Common Table Expression) kullanarak önce her müşterinin toplam sipariş sayısını
-- ve toplam harcamasını bulur. Ardından, birden fazla sipariş veren müşterileri (tekrar alım yapan)
-- sayısını, bunların toplam satışlarını ve genel satışlara oranını hesaplar.
WITH customer_orders AS (
    SELECT
        c.customer_unique_id,               -- Müşterinin benzersiz ID'si
        COUNT(DISTINCT o.order_id) AS order_count, -- Müşterinin sipariş sayısı
        SUM(oi.price + oi.freight_value) AS customer_total -- Müşterinin toplam harcaması
    FROM
        olist_customers c
    JOIN
        olist_orders o ON c.customer_id = o.customer_id     -- Müşterileri siparişlerle birleştirir
    JOIN
        olist_order_items oi ON o.order_id = oi.order_id -- Siparişleri sipariş öğeleriyle birleştirir
    WHERE
        o.order_status = 'delivered' -- Sadece teslim edilen siparişleri filtreler
    GROUP BY
        c.customer_unique_id -- Benzersiz müşteriye göre gruplandırır
)
SELECT
    COUNT(*) FILTER (WHERE order_count > 1) AS repeat_customers, -- Tekrar alım yapan müşteri sayısı
    SUM(customer_total) FILTER (WHERE order_count > 1) AS repeat_customers_sales, -- Tekrar alım yapan müşterilerin toplam satışı
    (SUM(customer_total) FILTER (WHERE order_count > 1) * 100.0 / SUM(customer_total)) AS repeat_customers_ratio -- Tekrar alım yapan müşterilerin toplam satışlara oranı
FROM customer_orders;

[cite_start]-- Soru 6: En yüksek gelir getiren 10 eyaleti bulun. [cite: 147, 148]
-- Çözüm: Her eyalet için benzersiz müşteri sayısını ve toplam geliri (fiyat + kargo ücreti)
-- hesaplar. Sonuçları toplam gelire göre azalan sırada sıralayarak en yüksek gelir sağlayan ilk 10 eyaleti gösterir.
SELECT
    c.customer_state,                           -- Müşterinin eyaleti
    COUNT(DISTINCT c.customer_unique_id) AS customer_count, -- Eyaletteki benzersiz müşteri sayısı
    SUM(oi.price + oi.freight_value) AS total_revenue       -- Eyaletten elde edilen toplam gelir
FROM
    olist_customers c
JOIN
    olist_orders o ON c.customer_id = o.customer_id     -- Müşterileri siparişlerle birleştirir
JOIN
    olist_order_items oi ON o.order_id = oi.order_id -- Siparişleri sipariş öğeleriyle birleştirir
WHERE
    o.order_status = 'delivered' -- Sadece teslim edilen siparişleri filtreler
GROUP BY
    c.customer_state -- Eyalete göre gruplandırır
ORDER BY
    total_revenue DESC -- Toplam gelire göre azalan sıralama
LIMIT 10; -- İlk 10 eyaleti gösterir

[cite_start]-- Soru 7: Kategori bazında ortalama teslimat süresini (gün cinsinden) hesaplayın. [cite: 152, 153]
-- Çözüm: Teslim edilen ve teslimat tarihi boş olmayan siparişler için her ürün kategorisi
-- için ortalama teslimat süresini (satın alma tarihi ile müşteriye teslimat tarihi arasındaki fark)
-- gün cinsinden hesaplar.
SELECT
    p.product_category_name, -- Ürün kategori adı
    AVG(DATE_PART('day', o.order_delivered_customer_date - o.order_purchase_timestamp)) AS avg_delivery_days -- Ortalama teslimat süresi (gün olarak)
FROM
    olist_orders o
JOIN
    olist_order_items oi ON o.order_id = oi.order_id -- Siparişleri sipariş öğeleriyle birleştirir
JOIN
    olist_products p ON oi.product_id = p.product_id -- Sipariş öğelerini ürün bilgileriyle birleştirir
WHERE
    o.order_status = 'delivered' -- Sadece teslim edilen siparişleri filtreler
    AND o.order_delivered_customer_date IS NOT NULL -- Teslimat tarihi boş olmayanları filtreler
GROUP BY
    p.product_category_name -- Ürün kategorisine göre gruplandırır
ORDER BY
    avg_delivery_days; -- Ortalama teslimat süresine göre sıralar

[cite_start]-- Soru 8: En yüksek iade oranına sahip ürün kategorilerini bulun. [cite: 157, 158]
-- Çözüm: İptal edilen ('canceled') veya kullanılamayan ('unavailable') siparişlerin
-- toplam siparişlere oranını ürün kategorisi bazında hesaplayarak iade oranlarını belirler.
SELECT
    p.product_category_name,        -- Ürün kategori adı
    COUNT(*) AS canceled_orders,    -- İptal edilen/kullanılamayan sipariş sayısı
    COUNT(*) * 100.0 /              -- İade oranı yüzdesi
        (SELECT COUNT(*) FROM olist_orders WHERE order_status IN ('canceled', 'unavailable')) AS cancel_ratio
FROM
    olist_orders o
JOIN
    olist_order_items oi ON o.order_id = oi.order_id -- Siparişleri sipariş öğeleriyle birleştirir
JOIN
    olist_products p ON oi.product_id = p.product_id -- Sipariş öğelerini ürün bilgileriyle birleştirir
WHERE
    o.order_status IN ('canceled', 'unavailable') -- Sadece iptal edilen veya kullanılamayan siparişleri filtreler
GROUP BY
    p.product_category_name -- Ürün kategorisine göre gruplandırır
ORDER BY
    cancel_ratio DESC; -- İade oranına göre azalan sıralama

[cite_start]-- Soru 9: En yüksek satış yapan 10 satıcıyı ve kategorilerini bulun. [cite: 161, 162]
-- Çözüm: Teslim edilen siparişlerdeki her satıcı ve sattığı ürün kategorisi kombinasyonu için
-- toplam satış gelirini hesaplar. Sonuçları toplam satışlara göre azalan sırada sıralayarak
-- en yüksek geliri elde eden ilk 10 satıcı-kategori ikilisini gösterir.
SELECT
    oi.seller_id,                   -- Satıcının ID'si
    p.product_category_name,        -- Ürün kategori adı
    SUM(oi.price + oi.freight_value) AS total_sales -- Toplam satış geliri
FROM
    olist_orders o
JOIN
    olist_order_items oi ON o.order_id = oi.order_id -- Siparişleri sipariş öğeleriyle birleştirir
JOIN
    olist_products p ON oi.product_id = p.product_id -- Sipariş öğelerini ürün bilgileriyle birleştirir
WHERE
    o.order_status = 'delivered' -- Sadece teslim edilen siparişleri filtreler
GROUP BY
    oi.seller_id, p.product_category_name -- Satıcı ve ürün kategorisine göre gruplandırır
ORDER BY
    total_sales DESC -- Toplam satışlara göre azalan sıralama
LIMIT 10; -- İlk 10 satıcı-kategori ikilisini gösterir

[cite_start]-- Soru 10: Hafta içi ve hafta sonu sipariş sayılarını ve gelirlerini karşılaştırın. [cite: 167, 168]
-- Çözüm: Siparişin satın alma zaman damgasından günün türünü (hafta içi veya hafta sonu) çıkarır.
-- Her gün türü için toplam sipariş sayısını ve toplam geliri hesaplayarak karşılaştırma yapar.
SELECT
    CASE                                            -- Günü hafta içi veya hafta sonu olarak ayırır
        WHEN EXTRACT(DOW FROM o.order_purchase_timestamp) IN (0,6) THEN 'weekend' -- 0: Pazar, 6: Cumartesi
        ELSE 'weekday'
    END AS day_type,
    COUNT(*) AS total_orders,                       -- Toplam sipariş sayısı
    SUM(oi.price + oi.freight_value) AS total_revenue -- Toplam gelir
FROM
    olist_orders o
JOIN
    olist_order_items oi ON o.order_id = oi.order_id -- Siparişleri sipariş öğeleriyle birleştirir
WHERE
    o.order_status = 'delivered' -- Sadece teslim edilen siparişleri filtreler
GROUP BY
    day_type -- Gün türüne göre gruplandırır
ORDER BY
    day_type; -- Gün türüne göre sıralar (alfabetik olarak)

-- Ek Notlar (Veri Temizliği ve Analiz İpuçları):
-- order_delivered_customer_date sütununda NULL değerler olabilir; bu nedenle ilgili sorgularda
[cite_start]-- IS NOT NULL koşulu kullanarak sadece geçerli teslimat verilerini kullanmak önemlidir. [cite: 173]
-- customer_unique_id sütunu, aynı müşterinin farklı siparişlerde farklı customer_id'lere sahip olabileceği durumlarda
[cite_start]-- benzersiz müşteri analizleri için kullanılmalıdır. [cite: 173]

[cite_start]-- 3. PostgreSQL'den Veri Export Etme (Dışarı aktarma) [cite: 174]
-- Belirtilen 3 sorgunun (Soru 1, Soru 3, Soru 6) sonuçlarını PostgreSQL'den dışa aktarma işlemi
-- genellikle COPY komutu veya veritabanı yönetim araçları aracılığıyla yapılır. Bu SQL betiği,
-- bu dışa aktarma işlemlerinin çalıştırılması için gerekli olan sorguları sağlar.
-- Örnek (gerçek export komutu veritabanı ortamına göre değişebilir):
-- COPY (SELECT DATE_TRUNC('month', o.order_purchase_timestamp) AS month, SUM(oi.price + oi.freight_value) AS total_revenue FROM olist_orders o JOIN olist_order_items oi ON o.order_id = oi.order_id WHERE o.order_status = 'delivered' GROUP BY DATE_TRUNC('month', o.order_purchase_timestamp) ORDER BY month) TO 'C:\path\to\your\monthly_revenue.csv' WITH CSV HEADER;
-- COPY (SELECT c.customer_unique_id, c.customer_state, SUM(oi.price + oi.freight_value) AS total_spent, CASE WHEN SUM(oi.price + oi.freight_value) > 1000 THEN 'Premium' WHEN SUM(oi.price + oi.freight_value) BETWEEN 500 AND 1000 THEN 'Regular' ELSE 'Low' END AS segment FROM olist_customers c JOIN olist_orders o ON c.customer_id = o.customer_id JOIN olist_order_items oi ON o.order_id = oi.order_id WHERE o.order_status = 'delivered' GROUP BY c.customer_unique_id, c.customer_state ORDER BY total_spent DESC) TO 'C:\path\to\your\customer_segments.csv' WITH CSV HEADER;
-- COPY (SELECT c.customer_state, COUNT(DISTINCT c.customer_unique_id) AS customer_count, SUM(oi.price + oi.freight_value) AS total_revenue FROM olist_customers c JOIN olist_orders o ON c.customer_id = o.customer_id JOIN olist_order_items oi ON o.order_id = oi.order_id WHERE o.order_status = 'delivered' GROUP BY c.customer_state ORDER BY total_revenue DESC LIMIT 10) TO 'C:\path\to\your\top_10_states_revenue.csv' WITH CSV HEADER;

[cite_start]-- 4. Sonuçların Görselleştirilmesi ve Raporlama (Power BI/Tableau) [cite: 183]
-- Dışa aktarılan veriler (Soru 1, Soru 3, Soru 6'nın sonuçları) Power BI veya Tableau gibi
-- görselleştirme araçlarına aktarılır ve bu araçlar kullanılarak anlamlı grafikler, tablolar
-- ve dashboard'lar oluşturulur. Bu aşama SQL betiği içinde yer almaz ancak projenin önemli bir çıktısıdır.

[cite_start]-- 5. Projenin Teslimi [cite: 194]
-- Bu SQL betiği, projenin SQL ile ilgili tüm adımlarını (tablo oluşturma, veri analizi sorguları)
-- eksiksiz bir şekilde içermektedir. Teslim edilebilir bir proje raporu, bu SQL betiği ile birlikte
-- dışa aktarılan verileri ve görselleştirme (Power BI/Tableau) dosyalarını içermelidir.

[cite_start]-- 6. Proje Dosyalarının Yönetimi (GitHub) [cite: 201]
-- Bu SQL betiği (2.sql dosyası olarak), dışa aktarılan CSV verileri ve görselleştirme dosyaları
-- (Power BI/Tableau), projenin bir parçası olarak bir GitHub deposuna yüklenmelidir.

[cite_start]-- 7. Tableau Public Ortamına Dashboard Yükleme [cite: 211]
-- Oluşturulan dashboard'lar (özellikle görselleştirme aşamasında Power BI veya Tableau'da oluşturulanlar)
-- Tableau Public gibi platformlara yüklenerek erişilebilir hale getirilir ve linkleri paylaşılır.
