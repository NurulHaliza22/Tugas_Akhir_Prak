import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'checkout.dart';
import 'profile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> products = [];
  List<dynamic> filteredProducts = [];
  Map<int, int> cartItems = {}; // Menyimpan ID produk dan jumlah item
  bool isLoading = true;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchProducts();
    searchController.addListener(_filterProducts);
  }

  Future<void> fetchProducts() async {
    const url =
        'http://makeup-api.herokuapp.com/api/v1/products.json?product_type=lipstick';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          products = json.decode(response.body).map((product) {
            return {
              'id': product['id'] ?? 0,
              'name': product['name'] ?? 'Unknown Product',
              'description': product['description'] ?? '',
              'price': product['price'] != null
                  ? double.tryParse(product['price']) ?? 0.0
                  : 0.0,
              'image_link': product['image_link'] ?? '',
            };
          }).toList();
          filteredProducts = products;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error: $e');
    }
  }

  void _filterProducts() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredProducts = products
          .where((product) =>
              product['name'].toLowerCase().contains(query) ||
              product['description'].toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 252, 252),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'LippyPay',
              style: TextStyle(color: Colors.black),
            ),
            IconButton(
              icon: const Icon(Icons.person,
                  color: Color.fromARGB(255, 215, 153, 161)),
              iconSize: 35,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfilePage(),
                  ),
                );
              },
            ),
          ],
        ),
        backgroundColor: const Color.fromARGB(255, 255, 252, 252),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Cari produk...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide:
                      const BorderSide(color: Color.fromARGB(255, 215, 153, 161)),
                ),
              ),
            ),
          ),
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16.0),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16.0,
                      mainAxisSpacing: 16.0,
                      childAspectRatio: 0.7,
                    ),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      return GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                backgroundColor: Colors.white.withOpacity(0.70),
                                title: Text(
                                  product['name'] ?? 'Unknown Product',
                                  style:
                                      const TextStyle(color: Colors.black),
                                ),
                                content: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Center(
                                        child: Image.network(
                                          product['image_link'] ?? '',
                                          fit: BoxFit.fitWidth,
                                          width: 150,
                                          errorBuilder: (context, error,
                                              stackTrace) {
                                            return const Center(
                                              child: Icon(Icons.broken_image,
                                                  size: 50),
                                            );
                                          },
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        product['description'] ??
                                            'No description available',
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Price: \$${product['price']}',
                                        style: const TextStyle(
                                          color: Colors.black54,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text(
                                      'Close',
                                      style:
                                          TextStyle(color: Colors.black),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color.fromARGB(255, 215, 153, 161), // Warna border (warna item)
                              width: 2.0, // Ketebalan border
                            ),
                            borderRadius: BorderRadius.circular(12.0),
                            image: DecorationImage(
                              image: NetworkImage(
                                product['image_link'] ?? 'https://placehold.co/600x400',
                              ),
                              fit: BoxFit.cover,
                              onError: (error, stackTrace) => const Icon(
                                Icons.broken_image,
                                size: 50,
                              ),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        product['name'] ?? 'Unknown Product',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          int productId = product['id'];
                                          cartItems[productId] =
                                              (cartItems[productId] ?? 0) + 1;
                                        });
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              '${product['name']} telah ditambahkan ke keranjang!',
                                              style: const TextStyle(
                                                  color: Colors.white),
                                            ),
                                            backgroundColor: const Color.fromARGB(
                                                255, 83, 83, 102),
                                            duration:
                                                const Duration(seconds: 2),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(8.0),
                                        decoration: BoxDecoration(
                                          color: const Color.fromARGB(
                                              255, 215, 153, 161),
                                          borderRadius:
                                              BorderRadius.circular(4.0),
                                        ),
                                        child: const Icon(
                                          Icons.add_shopping_cart,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 215, 153, 161),
        child: const Icon(Icons.shopping_cart, color: Colors.white),
        onPressed: () {
          if (cartItems.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Keranjang kosong',
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: Color.fromARGB(255, 83, 83, 102),
                duration: Duration(seconds: 2),
              ),
            );
            return;
          }
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CheckoutPage(
                cartItems: cartItems,
                products: products,
              ),
            ),
          );
        },
      ),
    );
  }
}
