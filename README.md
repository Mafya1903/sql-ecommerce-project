# E-Ticaret SQL & BI Projesi

Bu repo, bir e-ticaret veritabanı şeması oluşturulup temel analizlerin yapıldığı ve Brazilian E-Commerce Public Data seti üzerinde SQL & Power BI ile analizlerin gerçekleştirildiği iki bağımsız projeden oluşmaktadır.

## İçerik/Klasörler

- `1.sql`: Proje 1 — E-ticaret veritabanı şeması, örnek veriler, ilişkiler ve temel testler.
- `2.sql`: Proje 2 — Olist veri seti için tablo oluşturma ve analiz amaçlı 10 SQL sorgusu.
- `olist_aylik_gelir.csv`: Olist’in aylık gelir analiz çıktısı (Soru 1).
- `olist_musteri_segment.csv`: Müşteri segmentasyonu analizi (Soru 3).
- `olist_en_zengin_eyaletler.csv`: En yüksek gelir getiren eyaletler analizi (Soru 6).
- `Olist_Analiz_Raporu.pbix`: Power BI görselleştirme ve dashboard dosyası.
- `README.md`: Projenin dokümantasyonu ve klasör açıklamaları.

## Proje 1 — E-ticaret Veritabanı Tasarımı

- **Amaç:** Sıfırdan ilişkilendirilmiş bir e-ticaret veritabanı oluşturmak, normalizasyonu sağlamak ve örnek veri ile test etmek.
- **Kapsam:**
  - Customers, Orders, Products, Categories, Payments ve OrderItems tablolarının CREATE TABLE komutları
  - Tablolar arası temel ilişki (foreign key) kuralları
  - INSERT INTO ile örnek veri yükleme
  - SELECT, JOIN gibi temel doğrulama ve ilişki test sorguları

## Proje 2 — Olist Dataseti SQL Analizleri ve BI

- **Amaç:** Büyük hacimli gerçek bir veri setini SQL ile analiz edip iş zekası görselleri üretmek.
- **Kapsam:**
  - 4 ana CSV dosyasının PostgreSQL’e aktarılması ve ilgili tablo şemalarının hazırlanması (orders, order_items, products, customers)
  - 10 örnek iş analitiği SQL sorgusu (hepsi 2.sql dosyasındadır)
  - 3 temel analizin (.csv) dışa aktarılması: aylık gelir, müşteri segmentasyonu, eyalet bazında gelir
  - Tüm analiz sonuçlarının Power BI’da dashboard olarak görselleştirilmesi

## Kullanım/Çalıştırma

1. SQL dosyalarını sırasıyla PostgreSQL’de çalıştırınız.
2. Veri yükleme adımlarını izleyiniz.
3. Output alınan CSV’ler, Power BI’da görselleştirme için kullanılabilir.
4. PBIX dosyasını Power BI Desktop ile açabilirsiniz.

## Ek Açıklamalar

- “sql/”, “csv/” ya da “report/” gibi alt klasörler oluşturmanız tavsiye edilir.
- Dosya boyutu çok büyük olan orijinal veri setleri (ham CSV’ler) bu repo dışındadır.
- Sorular: [Kaggle Olist Public Data](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) kullanıldı.

## Yazar/Geliştirici

- M. Furkan Yardibi
- 30.07.2025
