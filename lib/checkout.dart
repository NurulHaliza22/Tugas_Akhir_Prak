import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:tugas_akhir/home_page.dart';

class CheckoutPage extends StatefulWidget {
  final Map<int, int> cartItems;
  final List<dynamic> products;

  const CheckoutPage({super.key, required this.cartItems, required this.products});

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  late Map<int, int> cartItems;
  double totalPrice = 0;
  List<Map<String, dynamic>> orderHistory = []; // Riwayat pemesanan
  

  @override
  void initState() {
    super.initState();
    cartItems = Map.from(widget.cartItems); // Menyalin data cartItems agar tidak merubah data aslinya
    calculateTotalPrice();
  }

void calculateTotalPrice() {
  double total = 0;
  cartItems.forEach((productId, quantity) {
    final product = widget.products.firstWhere(
      (product) => product['id'] == productId,
      orElse: () => null,
    );
    if (product != null) {
      double productPrice = double.tryParse(product['price'].toString()) ?? 0.0;
      total += productPrice * quantity;
    }
  });

  setState(() {
    totalPrice = total;
  });
}


  void updateQuantity(int productId, int quantity) {
    setState(() {
      if (quantity > 0) {
        cartItems[productId] = quantity;
      } else {
        cartItems.remove(productId);
      }
    });
    calculateTotalPrice();
  }

  void showPaymentMethods() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pilih Metode Pembayaran',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        showCashPaymentDialog();
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                        backgroundColor: const Color.fromARGB(255, 215, 153, 161),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                      ),
                      child: const Text('Cash'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        showQRISPaymentDialog();
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                        backgroundColor: const Color.fromARGB(255, 215, 153, 161),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                      ),
                      child: const Text('QRIS'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void showQRISPaymentDialog() {
    showDialog(
      context: context,
      barrierDismissible: true, // Close dialog by tapping outside
      builder: (_) {
        return AlertDialog(
          title: const Text('Pembayaran QRIS'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  'Total Harga: \$${totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Image.asset(
                  'assets/barcode.jpg',
                  width: 200,
                  height: 200,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  saveOrder();
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HomePage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                  backgroundColor: const Color.fromARGB(255, 215, 153, 161),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                child: const Text('Selesai'),
              ),
            ],
          ),
        );
      },
    );
  }

  void showCashPaymentDialog() {
    double cashAmount = 0;
    double changeAmount = 0;

    showDialog(
      context: context,
      barrierDismissible: true, // Close dialog by tapping outside
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Pembayaran Cash'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text(
                      'Total Harga: \$${totalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Jumlah Uang Tunai',
                      labelStyle: TextStyle(color: Color.fromARGB(255, 83, 83, 102)),
                      border: OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color.fromARGB(255, 83, 83, 102), width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color.fromARGB(255, 28, 28, 28), width: 2.0),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red, width: 1.5),
                      ),
                    ),
                    onChanged: (value) {
                      cashAmount = double.tryParse(value) ?? 0;
                      setState(() {
                        changeAmount = cashAmount - totalPrice;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  if (cashAmount > 0)
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(
                        'Kembalian: \$${changeAmount.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                    ),
                  const SizedBox(height: 16,),
                  ElevatedButton(
                    onPressed: () {
                      saveOrder();
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomePage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                      backgroundColor: const Color.fromARGB(255, 215, 153, 161),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                    child: const Text('Selesai'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void saveOrder() async {
  Box transactionBox = await Hive.openBox('transactionBox');

  final transaction = {
    'items': Map.from(cartItems),
    'totalPrice': totalPrice,
    'timestamp': DateTime.now().toString(),
  };

  await transactionBox.add(transaction);

  print("Transaksi berhasil disimpan: $transaction");

  setState(() {
    cartItems.clear();
    totalPrice = 0;
  });

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Transaksi berhasil'), duration: Duration(seconds: 2)),
  );
}




  Future<void> checkout() async {
  Box cartBox = await Hive.openBox('cartBox');
  Box transactionBox = await Hive.openBox('transactionBox');

  // Ambil data keranjang dan simpan sebagai transaksi
  List cartItems = cartBox.values.toList();
  Map<String, dynamic> transactionData = {
    'items': cartItems,
    'timestamp': DateTime.now().toString(),
  };

  // Simpan transaksi ke riwayat
  await transactionBox.add(transactionData);

  // Hapus keranjang setelah transaksi selesai
  await cartBox.clear();
}


  @override
  Widget build(BuildContext context) {
    if (cartItems.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFF2F2F2),
        appBar: AppBar(
          title: const Text('Checkout'),
          backgroundColor: const Color.fromARGB(255, 215, 153, 161),
        ),
        body: const Center(
          child: Text(
            'Keranjang kosong',
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: const Color.fromARGB(255, 215, 153, 161),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            'Rincian Pesanan',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: cartItems.length,
            itemBuilder: (context, index) {
              final productId = cartItems.keys.elementAt(index);
              final quantity = cartItems[productId];
              final product = widget.products.firstWhere(
                (product) => product['id'] == productId,
                orElse: () => null,
              );
              if (product != null) {
                double productPrice = double.tryParse(product['price'].toString()) ?? 0.0;
                double totalProductPrice = productPrice * quantity!;

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
                  title: Text(product['name']),
                  subtitle: Text('x$quantity'),
                  trailing: Text('Rp ${totalProductPrice.toStringAsFixed(2)}'),
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Harga',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                'Rp ${totalPrice.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: showPaymentMethods,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              foregroundColor: const Color.fromARGB(255, 255, 255, 255),
              backgroundColor: const Color.fromARGB(255, 215, 153, 161),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
            ),
            child: const Text('Pilih Metode Pembayaran'),
          ),
        ],
      ),
    );
  }
}
