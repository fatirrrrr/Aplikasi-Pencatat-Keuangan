# Expense Tracker

Manage Your Personal Finances Privately

## Requirements

1. Flutter 3.32.5 • channel stable
2. Dart 3.8.1

## QuickStart

### Clone Repository

```bash
git clone https://github.com/fatirrrrr/Aplikasi-Pencatat-Keuangan.git
```

### Get Package

```bash
cd Aplikasi-Pencatat-Keuangan
flutter pub get
```

### Run Application

```bash
flutter run
```

note: tested on some Android Device

## Notes

### Package

1. SQFLite
2. Path
3. persistent_bottom_nav_bar_v2

### Main Table

1. **transactions** - Menyimpan semua transaksi keuangan
2. **categories** - Menyimpan kategori untuk transaksi
3. **budgets** - Menyimpan anggaran per kategori

### Type Data

- **integer** - Untuk ID dan timestamp (millisecondsSinceEpoch)
- **real** - Untuk nilai uang (amount, spent)
- **text** - Untuk string data

### Relationals

- Transactions → Categories (Many-to-One)
- Budgets → Categories (Many-to-One)

### Indexes

- Dioptimalkan untuk query berdasarkan tanggal, kategori, dan tipe transaksi
- Composite index untuk query yang sering digunakan

### Enum Values

- **type**: 'income' atau 'expense'
- **category**: Nama kategori dari tabel categories

### Default Categories

#### Expense Categories

- Makanan (🍽️)
- Transportasi (🚗)
- Belanja (🛒)
- Hiburan (🎬)
- Kesehatan (💊)
- Tagihan (💡)
- Lainnya (📦)

#### Income Categories

- Gaji (💰)
- Freelance (💻)
- Investasi (📈)
- Bonus (🎁)
- Lainnya (💸)
