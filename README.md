## Non-Graded-challenges-Database-Perpustakaan

```
membuat sebauh database dengan nama perpustakaanh8

membuat table buku
1. ISBN PRIMARY KEY,
2. title,
3. author,
4. publisher,
5. year_of_publication

membuat table member 
1. id_member PRIMARY KEY,
2. first_name,
3. last_name,
4. date-of-brith,
5. addres

membuat table transaksi
1. id_transactionPRIMARY KEY,
2. id_member FOREIGN KEY,
3. ISBN FOREIGN KEY,
4. date-of-lending,
5. date-of-return,
6. condition-at-retun

Setiap buku hanya dapat dipinjamkan kepada satu anggota dalam satu waktu. (one to one)

Anggota dapat meminjam beberapa buku sekaligus, namun tidak lebih dari 5 buku sekaligus.(one to many)

```