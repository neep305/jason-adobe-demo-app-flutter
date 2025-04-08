import 'package:flutter/material.dart';

class Product {
  final String imageUrl;
  final String name;
  final String description;
  final double price;
  final String brand;
  final int productID;
  final List<String> options;

  Product({
    required this.imageUrl,
    required this.name,
    required this.description,
    required this.price,
    required this.brand,
    required this.productID,
    required this.options,
  });
}

class ProductListPage extends StatelessWidget {
  ProductListPage({super.key});

  final List<Product> products = [
    Product(
      imageUrl: 'https://static.nike.com/a/images/t_PDP_1728_v1/f_auto,q_auto:eco,u_126ab356-44d8-4a06-89b4-fcdcc8df0245,c_scale,fl_relative,w_1.0,h_1.0,fl_layer_apply/72e936e0-3eb0-4d0f-8233-44e577b3079b/AIR+JORDAN+1+MID+SE.png',
      name: 'Air Jordan 1 Mid SE',
      description: 'Description for Product 1',
      price: 135.00,
      brand: 'Nike',
      productID: 1000001,
      options: ['230','235','240','245','250','255','260','265','270','275','280','285','290','295','300'],
    ),
    Product(
      imageUrl: 'https://static.nike.com/a/images/t_PDP_1728_v1/f_auto,q_auto:eco,u_126ab356-44d8-4a06-89b4-fcdcc8df0245,c_scale,fl_relative,w_1.0,h_1.0,fl_layer_apply/52641389-2913-4db8-8bae-1ffa56965b39/JORDAN+6+RINGS.png',
      name: 'Jordan 6 Rings',
      description: 'Celebrate the legendary career of "His Airness" with the Jordan 6 Rings. Incorporating key features of each shoe worn during the championship series, it has premium details and lightweight, low-profile Zoom Air cushioning that delivers a responsive feel underfoot.',
      price: 170.00,
      brand: 'Nike',
      productID: 1000002,
      options: ['230','235','240','245','250','255','260','265','270','275','280','285','290','295','300'],
    ),
    Product(
      imageUrl: 'https://static.nike.com/a/images/t_PDP_1728_v1/f_auto,q_auto:eco,u_126ab356-44d8-4a06-89b4-fcdcc8df0245,c_scale,fl_relative,w_1.0,h_1.0,fl_layer_apply/0f9f04a1-0022-4336-b881-6f926f4e43dd/AIR+JORDAN+9+G.png',
      name: 'Air Jordan 9 G',
      description: 'Welcome to the links, legend. We drew direct inspiration from the ’93 classic released during MJ’s first year in retirement and gave it a golf update. A memory foam insole and synthetic leather tongue highlight a low-top design worthy of statues, swing-throughs and clean ball strikes that ultimately land gently on the green.',
      price: 126.97,
      brand: 'Nike',
      productID: 1000003,
      options: ['230','235','240','245','250','255','260','265','270','275','280','285','290','295','300'],
    ),
    Product(
      imageUrl: 'https://static.nike.com/a/images/t_PDP_864_v1/f_auto,b_rgb:f5f5f5/2b2d5992-9e75-483c-b27a-18a708e92418/custom-nike-sabrina-2-by-you.png',
      name: 'Sabrina 2 By Paige Bueckers',
      description: 'Sabrina set the basketball world ablaze with her debut signature custom shoe. How about the encore? With an extensive color palette and special design details, like glow-in-the-dark outsole options, multiple shimmering Swoosh designs and eye-popping graphics, the Sabrina 2 By You is even better. Sabrina’s handed you the paintbrush. Time to go to work.',
      price: 160.00,
      brand: 'Nike',
      productID: 1000004,
      options: ['230','235','240','245','250','255','260','265','270','275','280','285','290','295','300'],
    ),
    Product(
      imageUrl: 'https://static.nike.com/a/images/t_PDP_1728_v1/f_auto,q_auto:eco/c44a531f-78db-4c02-a71d-670e75c12f99/LBJ+NXXT+GENISUS.png',
      name: 'LeBron NXXT Genisus',
      description: 'With lightweight, supportive mesh and flexible Air Zoom cushioning for all-game speed, the LeBron NXXT Genisus gives you the tools you need to redefine the game.',
      price: 150.00,
      brand: 'Nike',
      productID: 1000005,
      options: ['230','235','240','245','250','255','260','265','270','275','280','285','290','295','300'],
    ),
    Product(
      imageUrl: 'https://static.nike.com/a/images/t_PDP_1728_v1/f_auto,q_auto:eco/b1303ca0-81f6-4ec4-855d-f049bc1e45f6/NIKE+DUNK+LOW+RETRO+SE.png',
      name: 'Nike Dunk Low Retro SE',
      description: 'Step out like an all star in this special edition Dunk Low. Bay Area inspired design details pair with premium materials and plush padding for game-changing comfort that lasts.',
      price: 120.00,
      brand: 'Nike',
      productID: 1000006,
      options: ['230','235','240','245','250','255','260','265','270','275','280','285','290','295','300'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.redAccent,
      ),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return ListTile(
            leading: Image.network(product.imageUrl, width: 50, height: 50,),
            title: Text(product.name),
            subtitle: Text(product.price.toStringAsFixed(0)),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetailPage(product: product),
                ),
              );
            },
          );
        }
      ),
    );
  }
}

class ProductDetailPage extends StatefulWidget {
  final Product product;

  const ProductDetailPage({Key? key, required this.product}): super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ProductDetailPageState();
  }
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  bool _isExpanded = false; // ✅ 아코디언 열림 여부
  bool _isWishlist = false; // ✅ Wishlist 상태 (하트 토글)
  String? _selectedSize;
  int _quantity = 1;
  double _totalPrice = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.product.name)),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.network(widget.product.imageUrl, width: 250, height: 250),
              ),
              SizedBox(height: 16.0),
              Text(widget.product.brand, style: TextStyle(fontSize: 16.0)),
              SizedBox(height: 8.0),
              Text(widget.product.name, style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold)),
              SizedBox(height: 8.0),
              Text("\$ ${widget.product.price.toStringAsFixed(0)}", style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
              SizedBox(height: 16.0),
              Text(widget.product.description, style: TextStyle(fontSize: 16.0)),
              SizedBox(height: 16.0),
            ],
          ),
        ),
      ),

      // ✅ bottomNavigationBar에서 아코디언 UI 구현
      bottomNavigationBar: AnimatedContainer(
        duration: Duration(milliseconds: 300), // ✅ 애니메이션 적용
        height: _isExpanded ? 350 : 80, // ✅ 최대 높이 제한 (300px)
        padding: EdgeInsets.only(left: 12, right: 12, bottom: 20), // ✅ 하단 여백 추가
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade300, width: 1)),
        ),
        child: _isExpanded
            ? SingleChildScrollView( // ✅ 스크롤 가능하도록 수정
          child: Column(
            mainAxisSize: MainAxisSize.min, // ✅ 최소 높이 조정하여 overflow 방지
            children: [
              // ✅ 아코디언 닫기 버튼 (위쪽 중앙)
              IconButton(
                icon: Icon(Icons.keyboard_arrow_down, size: 32.0),
                onPressed: () {
                  setState(() {
                    _isExpanded = false; // 아코디언 닫기
                  });
                },
              ),

              // ✅ Flexible 추가하여 내부 콘텐츠 크기 조정
              Flexible(
                child: Column(
                  children: [
                    // 1️⃣ 사이즈 선택 드롭다운
                    DropdownButton<String>(
                      isExpanded: true,
                      value: _selectedSize,
                      hint: Text("사이즈 선택"),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedSize = newValue;
                          _totalPrice = widget.product.price * _quantity;
                        });
                      },
                      items: widget.product.options.map<DropdownMenuItem<String>>((String size) {
                        return DropdownMenuItem<String>(
                          value: size,
                          child: Text(size),
                        );
                      }).toList(),
                    ),

                    if (_selectedSize != null) ...[
                      SizedBox(height: 12.0),

                      // 2️⃣ 선택한 옵션 및 삭제 버튼
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("선택한 사이즈: $_selectedSize", style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                _selectedSize = null;
                                _quantity = 1;
                                _totalPrice = 0.0;
                              });
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 12.0),

                      // 3️⃣ 수량 선택 버튼 & 가격 표시
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.remove),
                                onPressed: _quantity > 1
                                    ? () {
                                  setState(() {
                                    _quantity--;
                                    _totalPrice = widget.product.price * _quantity;
                                  });
                                }
                                    : null,
                              ),
                              Text("$_quantity", style: TextStyle(fontSize: 18.0)),
                              IconButton(
                                icon: Icon(Icons.add),
                                onPressed: () {
                                  setState(() {
                                    _quantity++;
                                    _totalPrice = widget.product.price * _quantity;
                                  });
                                },
                              ),
                            ],
                          ),
                          Text("\$ ${_totalPrice.toStringAsFixed(2)}", style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
                        ],
                      ),

                      SizedBox(height: 12.0),

                      // 4️⃣ 총 금액 표시
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("총 금액", style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
                          Text("\$ ${_totalPrice.toStringAsFixed(2)}", style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.red)),
                        ],
                      ),

                      SizedBox(height: 16.0),

                      // 5️⃣ 장바구니 & 구매하기 버튼
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                if (_selectedSize != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("장바구니 담기 완료!")));
                                  setState(() {
                                    _isExpanded = false;
                                  });
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                side: BorderSide(color: Colors.redAccent),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              child: Text(
                                "장바구니 담기",
                                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.redAccent),
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                if (_selectedSize != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("구매 완료!")));
                                  setState(() {
                                    _isExpanded = false;
                                    _selectedSize = null;
                                    _quantity = 1;
                                    _totalPrice = 0.0;
                                  });
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              child: Text("구매하기",
                                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ]
                  ],
                ),
              ),
            ],
          ),
        )
            : Row(
          children: [
            IconButton(
              icon: Icon(_isWishlist ? Icons.favorite : Icons.favorite_border, color: Colors.red),
              onPressed: () {
                setState(() {
                  _isWishlist = !_isWishlist;
                });
              },
            ),
            SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isExpanded = true;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Text("구매하기", style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}