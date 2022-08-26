import 'package:animated_cart/Models/Items.dart';
import 'package:animated_cart/Screens/item/components/cart_button.dart';
import 'package:animated_cart/Screens/item/components/custom_drop_down.dart';
import 'package:animated_cart/components/app_bar.dart';
import 'package:animated_cart/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ItemScreen extends StatefulWidget {
  @override
  _ItemScreenState createState() => _ItemScreenState();
}

class _ItemScreenState extends State<ItemScreen> with TickerProviderStateMixin {
  List<Items> cart = [demoProducts[1], demoProducts[2]];
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  AnimationController animationController;
  Animation<double> cartContainerSize;
  AnimationController dragZoneAnimationController;
  Animation<double> dragZoneSize;
  Duration animationDuration = Duration(milliseconds: 300);
  double cartTotal = 0.0;
  PageController _controller = PageController(initialPage: 0, keepPage: false);
  bool isContainerOpened = false;
  bool isDragging = false;

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    animationController =
        AnimationController(vsync: this, duration: animationDuration);
    dragZoneAnimationController =
        AnimationController(vsync: this, duration: animationDuration);
    calculateCart();
    super.initState();
  }

  @override
  void dispose() {
    animationController.dispose();
    dragZoneAnimationController.dispose();
    super.dispose();
  }

  void calculateCart() {
    double total = 0.0;
    for (var element in cart) {
      total += element.price;
    }
    setState(() {
      cartTotal = total;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double defaultCartContainerSize = 100;
    double defaultDropZone = 60;
    cartContainerSize = Tween<double>(begin: defaultCartContainerSize, end: 250)
        .animate(
            CurvedAnimation(parent: animationController, curve: Curves.linear));
    dragZoneSize = Tween<double>(begin: defaultDropZone, end: 70).animate(
        CurvedAnimation(
            parent: dragZoneAnimationController, curve: Curves.linear));
    return Scaffold(
      appBar: buildAppBar(context,
          title: 'ITEM DETAILS',
          leading: IconButton(
              icon: Icon(Icons.arrow_back, color: kIconColor),
              onPressed: () {})),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: kDefaultPadding),
              child: Container(
                width: double.infinity,
                margin: EdgeInsets.only(bottom: 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Name
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        demoProducts[0].name,
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),

                    SizedBox(height: kDefaultPadding),

                    // Product Image
                    ClipRRect(
                        borderRadius: BorderRadius.circular(kDefaultPadding),
                        child: Image.asset(demoProducts[0].image,
                            width: size.width - (kDefaultPadding * 2))),

                    SizedBox(height: kDefaultPadding),

                    // Price
                    Text(
                      "\$" + demoProducts[0].price.toString(),
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: kTextColor),
                    ),

                    SizedBox(height: kDefaultPadding),

                    // Dropdown List
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: CustomDropDown(
                            items: demoProducts[0].colors,
                            hint: 'Color',
                          ),
                        ),
                        SizedBox(width: kDefaultPadding),
                        Expanded(
                            flex: 2,
                            child: CustomDropDown(
                              items: demoProducts[0]
                                  .sizes
                                  .map((e) => e.toString())
                                  .toList(),
                              hint: 'Size',
                            )),
                      ],
                    ),

                    SizedBox(height: kDefaultPadding),

                    // Cart Button
                    CartButton(tapEvent: () {
                      setState(() {
                        cart.insert(0, demoProducts[0]);
                        _listKey.currentState.insertItem(0);
                        calculateCart();
                      });
                    }),

                    SizedBox(height: kDefaultPadding),

                    // Description
                    Text(
                      demoProducts[0].description,
                      style: TextStyle(
                          color: kTextLightColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w700),
                    )
                  ],
                ),
              ),
            ),
          ),
          AnimatedOpacity(
            opacity: isDragging ? 1 : 0,
            duration: animationDuration,
            child: Visibility(
                visible: isDragging,
                child: Container(
                  height: size.height,
                  width: size.width,
                  color: Colors.black.withOpacity(0.2),
                )),
          ),
          Visibility(
            visible: isDragging,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: cartContainerSize.value + 90,
                alignment: Alignment.topCenter,
                child: DragTarget<Items>(
                  builder: (context, candidateData, rejectedData) {
                    if (candidateData.isEmpty) {
                      dragZoneAnimationController.forward();
                    } else {
                      dragZoneAnimationController.reverse();
                    }
                    return AnimatedBuilder(
                      animation: dragZoneAnimationController,
                      builder: (context, child) {
                        return Container(
                          width: dragZoneSize.value,
                          height: dragZoneSize.value,
                          transformAlignment: Alignment.center,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: Colors.white),
                          alignment: Alignment.center,
                          child: Icon(Icons.close),
                        );
                      },
                    );
                  },
                  onAccept: (data) {
                    calculateCart();
                    setState(() {
                      isDragging = false;
                    });
                  },
                ),
              ),
            ),
          ),
          AnimatedBuilder(
            animation: animationController,
            builder: (context, child) => _buildCartContainer(),
          )
        ],
      ),
    );
  }

  Widget _buildCartContainer() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.infinity,
        height: cartContainerSize.value,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(kDefaultPadding + 1.5),
              topRight: Radius.circular(kDefaultPadding + 1.5),
            ),
            boxShadow: [
              BoxShadow(
                  blurRadius: 6,
                  offset: Offset(0, 0),
                  color: Colors.black.withAlpha(16))
            ]),
        padding: EdgeInsets.all(kDefaultPadding),
        child: Stack(
          children: [
            AnimatedOpacity(
              opacity: (isContainerOpened && animationController.isCompleted)
                  ? 1
                  : 0,
              duration: animationDuration,
              child: Visibility(
                visible: isContainerOpened && animationController.isCompleted,
                child: PageView.builder(
                  itemBuilder: (context, index) => Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 1,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset(
                            cart[index].image,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: kDefaultPadding,
                      ),
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(cart[index].brand),
                            SizedBox(
                              height: kDefaultPadding / 4,
                            ),
                            Text(
                              cart[index].name,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            SizedBox(
                              height: kDefaultPadding,
                            ),
                            Text(
                              "\$" + cart[index].price.toString(),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  itemCount: cart.length,
                  controller: _controller,
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 50,
                child: Row(
                  children: [
                    Expanded(
                        flex: 4,
                        child: AnimatedList(
                          key: _listKey,
                          scrollDirection: Axis.horizontal,
                          initialItemCount: cart.length,
                          itemBuilder: (context, index, animation) =>
                              _buildCartItems(
                                  context, cart[index], animation, index),
                        )),
                    Expanded(
                      flex: 2,
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "Total\n",
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: kTextLightColor),
                            ),
                            TextSpan(
                              text: "\$" + cartTotal.toString(),
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        setState(() {
                          isContainerOpened = false;
                        });
                        animationController.reverse();
                      },
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            color: kPrimaryColor),
                        alignment: Alignment.center,
                        child: SvgPicture.asset(
                          "assets/icons/arrow_down.svg",
                          fit: BoxFit.scaleDown,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCartItems(BuildContext context, Items cartItem,
      Animation<double> animation, int index) {
    return SizeTransition(
      sizeFactor: animation,
      axis: Axis.horizontal,
      child: LongPressDraggable(
        data: demoProducts[0],
        onDragStarted: () {
          cart.removeAt(index);
          setState(() {
            isDragging = true;
          });
          _listKey.currentState.removeItem(
            index,
            (context, animation) => FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Interval(0.5, 1.0),
              ),
              child: _buildCartItems(context, cartItem, animation, index),
            ),
          );
        },
        onDraggableCanceled: (velocity, offset) {
          setState(() {
            isDragging = false;
          });
          cart.insert(index, cartItem);
          _listKey.currentState.insertItem(index);
        },
        feedback: FractionalTranslation(
          translation: Offset(-0.5, -0.5),
          child: SizedBox(
            width: 60,
            height: 60,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Image.asset(cartItem.image),
            ),
          ),
        ),
        child: GestureDetector(
          onTap: () {
            if (!isContainerOpened) {
              _controller = PageController(initialPage: index, keepPage: false);
            }

            setState(() {
              isContainerOpened = true;
            });
            animationController.forward();

            if (_controller.hasClients) {
              _controller.animateToPage(index,
                  duration: animationDuration * 0.7, curve: Curves.linear);
            }
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 5),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: Image.asset(cartItem.image),
            ),
          ),
        ),
        dragAnchorStrategy: pointerDragAnchorStrategy,
      ),
    );
  }
}
