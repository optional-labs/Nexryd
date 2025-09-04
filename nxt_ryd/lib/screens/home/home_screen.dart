import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/product.dart';
import '../../helpers/database_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Product> _products = [];
  List<Product> _cartItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _loadCartItems();
  }

  Future<void> _loadProducts() async {
    try {
      final dbHelper = DatabaseHelper();
      final products = await dbHelper.getProducts();
      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadCartItems() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final dbHelper = DatabaseHelper();
      final cartData = await dbHelper.getCartItems(authProvider.currentUser);
      
      final cartProducts = <Product>[];
      for (var item in cartData) {
        cartProducts.add(Product(
          id: item['product_id'],
          name: item['name'],
          price: item['price'],
          image: item['image'],
          description: item['description'],
        ));
      }
      
      setState(() {
        _cartItems = cartProducts;
      });
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _addToCart(Product product) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final dbHelper = DatabaseHelper();
      
      await dbHelper.addToCart(authProvider.currentUser, product.id);
      await _loadCartItems(); // Refresh cart
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${product.name} added to cart'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to add item to cart'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showCartDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Shopping Cart'),
          content: SizedBox(
            width: double.maxFinite,
            height: MediaQuery.of(context).size.height * 0.4,
            child: _cartItems.isEmpty
                ? const Center(child: Text('Your cart is empty'))
                : ListView.builder(
                    itemCount: _cartItems.length,
                    itemBuilder: (context, index) {
                      final product = _cartItems[index];
                      return ListTile(
                        leading: Text(product.image, style: const TextStyle(fontSize: 24)),
                        title: Text(product.name),
                        subtitle: Text('₹${product.price.toInt()}'),
                        trailing: IconButton(
                           icon: const Icon(Icons.remove_circle, color: Colors.red),
                           onPressed: () async {
                             try {
                               final authProvider = Provider.of<AuthProvider>(context, listen: false);
                               final dbHelper = DatabaseHelper();
                               await dbHelper.removeFromCart(authProvider.currentUser, product.id);
                               await _loadCartItems();
                               Navigator.of(context).pop();
                               _showCartDialog();
                             } catch (e) {
                               // Handle error
                             }
                           },
                         ),
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            if (_cartItems.isNotEmpty)
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Checkout functionality coming soon!'),
                      backgroundColor: Colors.blue,
                    ),
                  );
                },
                child: const Text('Checkout'),
              ),
          ],
        );
      },
    );
  }

  void _logout() {
    Provider.of<AuthProvider>(context, listen: false).logout();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'NxtRyd',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: _showCartDialog,
              ),
              if (_cartItems.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${_cartItems.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                _logout();
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'profile',
                child: Row(
                  children: [
                    const Icon(Icons.person, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text(authProvider.currentUser),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Book Your Ride Button - Prominent at top
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/booking');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.directions_car, size: 28),
                  SizedBox(width: 12),
                  Text(
                    'Book Your Ride',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Products Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Text(
                  'Car Accessories',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {},
                  child: const Text('View All'),
                ),
              ],
            ),
          ),
          
          // Products Grid
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final screenWidth = MediaQuery.of(context).size.width;
                      final crossAxisCount = screenWidth < 600 ? 2 : screenWidth < 900 ? 3 : 4;
                      final childAspectRatio = screenWidth < 600 ? 0.75 : 0.8;
                      
                      return GridView.builder(
                  padding: EdgeInsets.all(screenWidth < 600 ? 12 : 16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: childAspectRatio,
                    crossAxisSpacing: screenWidth < 600 ? 12 : 16,
                    mainAxisSpacing: screenWidth < 600 ? 12 : 16,
                  ),
                  itemCount: _products.length,
                  itemBuilder: (context, index) {
                    final product = _products[index];
                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Product Image (Emoji)
                            Center(
                              child: Text(
                                product.image,
                                style: const TextStyle(fontSize: 40),
                              ),
                            ),
                            const SizedBox(height: 8),
                            
                            // Product Name
                            Text(
                              product.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            
                            // Product Description
                            Text(
                              product.description,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Spacer(),
                            
                            // Price and Add to Cart
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '₹${product.price.toInt()}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.blue,
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () => _addToCart(product),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    minimumSize: const Size(60, 30),
                                  ),
                                  child: const Text(
                                    'Add',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
                   },
                 ),
          ),
        ],
      ),
    );
  }
}