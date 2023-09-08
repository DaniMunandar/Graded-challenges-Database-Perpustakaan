-- membuat database
CREATE DATABASE perpustakaanh8;

-- membuat table di database
CREATE TABLE IF NOT EXISTS Book (
	ISBN INT AUTO_INCREMENT,
    title VARCHAR(255),
    author VARCHAR(255),
    publisher VARCHAR(255),
    year_of_publication YEAR,
    PRIMARY KEY(ISBN)
);
CREATE TABLE IF NOT EXISTS Member (
	id_member INT AUTO_INCREMENT,
    first_name VARCHAR(255),
    last_name VARCHAR(255),
    date_of_birth DATE,
    PRIMARY KEY(id_member)
);
CREATE TABLE IF NOT EXISTS Lending_Transaction (
	id_transaction INT AUTO_INCREMENT,
    id_member INT,
    ISBN INT,
    date_of_lending DATE,
    date_of_return DATE,
    condition_at_return VARCHAR(255),
    FOREIGN KEY(id_member) REFERENCES Member(id_member),
    FOREIGN KEY(ISBN) REFERENCES Book (ISBN),
    PRIMARY KEY(id_transaction)
    
);

-- Adding a constraint to ensure a member can't borrow more than 5 books at a time
-- DELIMITER //
-- CREATE TRIGGER Before_LendingTransaction_Insert
-- BEFORE INSERT ON Lending_Transaction
-- FOR EACH ROW
-- BEGIN
--     DECLARE BorrowedBooksCount INT;
    
--     SELECT COUNT(*) INTO BorrowedBooksCount
--     FROM Lending_Transaction
--     WHERE id_member = NEW.id_member AND date_of_return IS NULL;
    
--     IF BorrowedBooksCount >= 5 THEN
--         SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'A member cannot borrow more than 5 books at a time';
--     END IF;
-- END;
-- //
-- DELIMITER ;

DELIMITER //
CREATE TRIGGER CheckBookAvailability
BEFORE INSERT ON Lending_Transaction
FOR EACH ROW
BEGIN
    DECLARE book_count INT;

    -- Menghitung jumlah transaksi yang menggunakan ISBN buku yang sama yang belum dikembalikan
    SELECT COUNT(*) INTO book_count
    FROM Lending_Transaction
    WHERE ISBN = NEW.ISBN AND date_of_return IS NULL;

    -- Memeriksa apakah buku tersebut sudah dipinjam oleh anggota lain
    IF book_count > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Buku ini sedang dipinjam oleh anggota lain. Tidak dapat meminjamkan kepada anggota lain.';
    END IF;
END;
//
DELIMITER ;

DELIMITER //
CREATE TRIGGER CheckBorrowLimit
BEFORE INSERT ON Lending_Transaction
FOR EACH ROW
BEGIN
    DECLARE borrow_count INT;

    -- Menghitung jumlah buku yang sudah dipinjam oleh anggota
    SELECT COUNT(*) INTO borrow_count
    FROM Lending_Transaction
    WHERE id_member = NEW.id_member AND date_of_return IS NULL;

    -- Memeriksa apakah anggota telah meminjam lebih dari 5 buku
    IF borrow_count >= 5 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Anggota tidak dapat meminjam lebih dari 5 buku sekaligus';
    END IF;
END;
//
DELIMITER ;


-- input data tabel di databse 
INSERT INTO Book (title, author, publisher, year_of_publication)
VALUES 
    ('Buku Engginering Aviation', 'B. Habibi', 'Pustaka Buku', 1970),
    ('Buku Instrumen Musik', 'Ebit G. Ade', 'Guna Buku', 1990),
    ('Buku Infromatin Technology', 'Albret H.', 'Keras Buku', 2003),
    ('Buku Teknik Sipil', 'Antony Bao', 'Selembar Buku', 1988);

INSERT INTO Member (first_name, last_name, date_of_birth)
VALUES 
    ('Andre','Wijaya','1990-07-17'),
    ('Ridho','Saputra','1989-08-01'),
    ('Bobi','Nasution','1987-05-21'),
    ('Antoni','Raharja','1993-06-12');

INSERT INTO Lending_Transaction ( date_of_lending, date_of_return, condition_at_return)
VALUES
    ('2023-09-08', '2023-09-15', 'Good'),
    ('2023-09-10', '2023-09-17', 'Excellent'),
    ('2023-09-12', '2023-09-19', 'Fair'),
    ('2023-09-14', '2023-09-21', 'Poor');

-- Daftar judul buku yang dipinjam oleh anggota (diidentifikasi dengan Member_ID tertentu).
SELECT Book.title
FROM Book
INNER JOIN Lending_Transaction ON Book.ISBN = Lending_Transaction.ISBN
WHERE Lending_Transaction.id_member = 5;

--Cari tahu anggota yang sudah meminjam buku tetapi belum mengembalikannya.
SELECT Member.first_name, Member.last_name
FROM Member
INNER JOIN Lending_Transaction ON Member.id_member = Lending_Transaction.id_member
WHERE Lending_Transaction.date_of_return IS NULL;

--Cari tahu jumlah total buku yang dipinjam oleh seorang anggota (diidentifikasi dengan ID_Anggota tertentu).
SELECT Member.first_name, Member.last_name, COUNT(*) AS total_buku_dipinjam
FROM Member
INNER JOIN Lending_Transaction ON Member.id_member = Lending_Transaction.id_member
WHERE Lending_Transaction.date_of_return IS NULL
GROUP BY Member.id_member;

--Buat daftar buku-buku yang tidak dikembalikan dalam kondisi baik.
SELECT Book.title
FROM Book
INNER JOIN Lending_Transaction ON Book.ISBN = Lending_Transaction.ISBN
WHERE Lending_Transaction.date_of_return IS NULL
    AND Lending_Transaction.condition_at_return = 'Good';

-- Identifikasi anggota yang telah meminjam lebih dari satu buku sekaligus.
SELECT Member.first_name, Member.last_name, COUNT(*) AS total_buku_dipinjam
FROM Member
INNER JOIN Lending_Transaction ON Member.id_member = Lending_Transaction.id_member
WHERE Lending_Transaction.date_of_return IS NULL
GROUP BY Member.id_member
HAVING COUNT(*) > 1;


