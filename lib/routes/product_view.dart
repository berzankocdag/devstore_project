import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:devstore_project/objects/products.dart';
import 'package:devstore_project/objects/users.dart';
import 'package:devstore_project/services/db.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:devstore_project/utils/color.dart';
import 'package:devstore_project/utils/styles.dart';
import 'package:devstore_project/utils/dimension.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

import 'cart.dart';

class productView extends StatefulWidget {
  const productView({Key? key, required this.id, required this.analytics, required this.observer})
      : super(key: key);

  final String id;
  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  @override
  _productViewState createState() => _productViewState();
}

void buttonClicked() {
  print('Button Clicked');
}

/*
final List<String> contents=[
  'https://cdn.vatanbilgisayar.com/Upload/PRODUCT/apple/thumb/129911-9_large.jpg',
  'https://photos5.appleinsider.com/gallery/44650-87056-Edge-of-iPhone-13-Pro-on-Edge-xl.jpg',
  'https://thumbor.forbes.com/thumbor/fit-in/1200x0/https%3A%2F%2Fspecials-images.forbesimg.com%2Fimageserve%2F5f8e0aaafeac9889106b860f%2F0x0.png%3FcropX1%3D0%26cropX2%3D1462%26cropY1%3D115%26cropY2%3D1211',
];
 */

final isSelected = <bool>[true, false, false];
bool _isFavoritePressed = false;
bool _isBookmarkPressed = false;

DBService db = DBService();

class _productViewState extends State<productView> {
  final int _current = 0;
  final CarouselController _controller = CarouselController();

  //analytics begin
  Future<void> _currentScreen() async {
    await widget.analytics.setCurrentScreen(
        screenName: 'Product Page', screenClassOverride: 'productPage');
  }

  Future<void> _setLogEvent() async {
    await widget.analytics
        .logEvent(name: 'product_page', parameters: <String, dynamic>{});
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: db.productsCollection.doc(widget.id).get(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          Products productsClass =
              Products.fromJson(snapshot.data!.data() as Map<String, dynamic>);
          List<dynamic> contents = productsClass.imageURL;
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0.0,
              leading: IconButton(
                splashRadius: 16.0,
                onPressed: () => {Navigator.pop(context)},
                icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.black),
              ),
            ),
            body: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CarouselSlider(
                    options: CarouselOptions(
                      height: 260.0,
                      initialPage: 0,
                      autoPlay: true,
                      autoPlayInterval: const Duration(seconds: 8),
                      autoPlayAnimationDuration: const Duration(milliseconds: 800),
                      autoPlayCurve: Curves.fastOutSlowIn,
                      enlargeCenterPage: true,
                    ),
                    items: contents.map((i) {
                      return Builder(
                        builder: (BuildContext context) {
                          return Container(
                            width: MediaQuery.of(context).size.width,
                            margin: const EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 8.0),
                            decoration: BoxDecoration(
                                image: DecorationImage(image: NetworkImage(i),
                                    fit: BoxFit.contain)
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: contents.asMap().entries.map((entry) {
                      return GestureDetector(
                        onTap: () => _controller.animateToPage(entry.key),
                        child: Container(
                          width: 12.0,
                          height: 12.0,
                          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: (Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white
                                  : Colors.black)
                                  .withOpacity(_current == entry.key ? 0.9 : 0.4)),
                        ),
                      );
                    }).toList(),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(productsClass.productName, style: fav_camp_recomBanner),
                            RichText(
                              text: TextSpan(
                                children: <TextSpan>[
                                  TextSpan(text: 'By ', style: productPageSellerText1),
                                  TextSpan(text: productsClass.productBrand, style: productPageSellerText2),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          Wrap(
                            direction: Axis.horizontal,
                            spacing: -12.0,
                            children: [
                              IconButton(
                                icon: Icon(_isFavoritePressed
                                    ? Icons.favorite
                                    : Icons.favorite_outline),
                                iconSize: 28,
                                splashRadius: 21.0,
                                onPressed: () {
                                  setState(() {
                                    _isFavoritePressed = !_isFavoritePressed;
                                  });
                                  if (_isFavoritePressed) {
                                    //TODO: FAV'A EKLE
                                    print('Added to Favorites');
                                  } else {
                                    //TODO: FAV'DAN CIKAR
                                    print('Removed from Favorites');
                                  }
                                },
                              ),
                              IconButton(
                                icon: Icon(_isBookmarkPressed
                                    ? Icons.bookmark
                                    : Icons.bookmark_border_outlined),
                                iconSize: 28,
                                splashRadius: 21.0,
                                onPressed: () {
                                  setState(() {
                                    _isBookmarkPressed = !_isBookmarkPressed;
                                  });
                                  if (_isBookmarkPressed) {
                                    //TODO: BOOKMARK'A EKLE
                                    print('Added to Bookmark');
                                  } else {
                                    //TODO: BOOKMARK'TAN CIKAR
                                    print('Removed from Bookmark');
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8.0,0.0,0.0,0.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.star,
                          color: AppColors.starColor,
                          size: 16.0,
                        ),
                        const SizedBox(width: 2.0),
                        RichText(
                          text: TextSpan(
                            children: <TextSpan>[
                              TextSpan(text: productsClass.rating.toString(), style: productPageRating),
                              TextSpan(text: " (${productsClass.ratingCount.toString()})", style: productPageRating),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Container(
                    padding: EdgeInsets.zero,
                    decoration: BoxDecoration(
                      color: const Color(0xFFBFA2DB).withOpacity(0.40),
                      borderRadius: const BorderRadius.all(Radius.circular(50.0)),
                    ),
                    child: ToggleButtons(
                      color: const Color(0xFF5B278D),
                      selectedColor: AppColors.toggleButton,
                      disabledColor: const Color(0xFFBFA2DB).withOpacity(0.40),
                      fillColor: AppColors.settingIconsColor,
                      splashColor: const Color(0xFF5B278D).withOpacity(0.12),
                      hoverColor: const Color(0xFF5B278D).withOpacity(0.04),
                      borderRadius: BorderRadius.circular(50.0),
                      constraints: const BoxConstraints(minHeight: 34.0),
                      renderBorder: false,
                      isSelected: isSelected,
                      onPressed: (index) {
                        // Respond to button selection
                        setState(() {
                          for (var i = 0; i < 3; i++) {
                            if (i == index) {
                              isSelected[i] = !isSelected[i];
                            } else {
                              isSelected[i] = false;
                            }
                          }
                        });
                      },
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20.0, 8.0, 20.0, 8.0),
                          child: Text('Overview', style: toggleButtonText),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20.0, 8.0, 20.0, 8.0),
                          child: Text('Details', style: toggleButtonText),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20.0, 8.0, 20.0, 8.0),
                          child: Text('Comments', style: toggleButtonText),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8.0),

                  if (isSelected[0] == true)
                    Padding(
                      padding: Dimen.regularPadding12,
                      child: Text(
                        productsClass.overview,
                        textAlign: TextAlign.left,
                        style: productDescription,
                      ),
                    ),

                  if (isSelected[1] == true)
                    Padding(
                      padding: Dimen.regularPadding12,
                      child: Text(
                        productsClass.details,
                        textAlign: TextAlign.left,
                        style: productDescription,
                      ),
                    ),

                  if (isSelected[2] == true)
                    Padding(
                      padding: Dimen.regularPadding12,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          for(int i=0; i < productsClass.comments.length; i++)
                            Text(
                              productsClass.comments[i].toString(),
                              textAlign: TextAlign.left,
                              style: productDescription,
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            bottomNavigationBar: BottomAppBar(
              elevation: 0.0,
              color: Colors.transparent,
              child: Container(
                height: 93.0,
                decoration: BoxDecoration(
                    color: const Color(0xFFBFA2DB).withOpacity(0.20),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(15.0))
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    productsClass.previousPrice != productsClass.salePrice
                    ? Container(
                      width: 71.43,
                      height: 30.36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFBFA2DB),
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "${((productsClass.previousPrice -
                            productsClass.salePrice) /
                            productsClass.previousPrice * 100).toStringAsFixed(
                            1)}%",
                        textAlign: TextAlign.center,
                        style: productDiscount,
                      ),
                    )
                    : Container(
                      width: 1, height: 1,
                    ),
                    const SizedBox(width: 32.0),
                    productsClass.previousPrice != productsClass.salePrice
                    ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '\$${productsClass.previousPrice}.00',
                          textAlign: TextAlign.center,
                          style: prevPrice,
                        ),
                        Text(
                          '\$${productsClass.salePrice}.00',
                          textAlign: TextAlign.center,
                          style: finalPrice,
                        ),
                      ],
                    )
                    : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '\$${productsClass.salePrice}.00',
                          textAlign: TextAlign.center,
                          style: finalPrice,
                        ),
                      ],
                    ),
                    const SizedBox(width: 32.0),
                    ElevatedButton(
                      onPressed: () {
                        //TODO: CART'A EKLE
                        pushNewScreen(
                          context,
                          screen: cart(analytics: widget.analytics, observer: widget.observer),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                          minimumSize: const Size(154,39),
                          primary: const Color(0xFF9441E4),
                          elevation: 0.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50.0),
                          )),
                      child: Row(
                        children: [
                          Text('Add To Cart', style: productDiscount),
                          const SizedBox(width: 8.0),
                          const Icon(Icons.shopping_cart_outlined),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        return Scaffold();
      },
    );
  }
}
