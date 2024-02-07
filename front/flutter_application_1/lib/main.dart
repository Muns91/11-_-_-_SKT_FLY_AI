import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class Product {
  final String image;
  final String name;
  final String detailUrl;

  Product({required this.image, required this.name, required this.detailUrl});

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      image: json['image'],
      name: json['name'],
      detailUrl: json['detailUrl'],
    );
  }
}

Future<Product> fetchProduct(String keyword) async {
  final response = await http.get(Uri.parse('http://10.0.2.2:3000/products?keyword=$keyword')); // Node 서버 URL

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return Product.fromJson(jsonResponse[0]);
  } else {
    throw Exception('Failed to load product');
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Product Search',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Product Search Home Page'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: FutureBuilder<Product>(
        future: fetchProduct('phone'), // 예시로 'phone' 키워드로 상품 검색 요청
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListTile(
              leading: Image.network(snapshot.data!.image), // 이미지만 표시하고, 클릭 이벤트는 제거
              title: InkWell(
                onTap: () => launch(snapshot.data!.detailUrl), // 상품명을 탭하면 상세 정보 페이지로 이동
                child: Text(snapshot.data!.name, style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline)), // 상품명 스타일 지정
              ),
            );
          } else if (snapshot.hasError) {
            return Text('${snapshot.error}');
          }
          return CircularProgressIndicator();
        },
      ),
    );
  }
}

