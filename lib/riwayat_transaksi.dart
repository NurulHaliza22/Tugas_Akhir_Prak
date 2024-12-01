import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class TransactionHistoryPage extends StatelessWidget {
  const TransactionHistoryPage({super.key});

  Future<List<Map<String, dynamic>>> _loadTransactions() async {
  Box transactionBox = await Hive.openBox('transactionBox');
  print("Isi transactionBox: ${transactionBox.values.toList()}"); // Debug isi kotak
  return transactionBox.values.cast<Map<String, dynamic>>().toList();
}




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 252, 252),
      appBar: AppBar(
        title: const Text('Riwayat Transaksi'),
        backgroundColor: const Color.fromARGB(255, 255, 252, 252),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(  // Menunggu data transaksi
        future: _loadTransactions(),  // Memuat transaksi dari Hive
        builder: (context, snapshot) {
  print("Snapshot: ${snapshot.data}");
  if (snapshot.connectionState == ConnectionState.waiting) {
    return const Center(child: CircularProgressIndicator());
  }
  if (!snapshot.hasData || snapshot.data!.isEmpty) {
    return const Center(child: Text('Belum ada transaksi'));
  }

  final transactions = snapshot.data!;
  return ListView.builder(
    itemCount: transactions.length,
    itemBuilder: (context, index) {
      final transaction = transactions[index];
      return Card(
        margin: const EdgeInsets.all(8),
        child: ListTile(
          title: Text('Total: Rp ${transaction['totalPrice']}'),
          subtitle: Text('Waktu: ${transaction['timestamp']}'),
        ),
      );
    },
  );
}
      ),
    );
  }
}
