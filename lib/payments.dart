import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:untitled17/screens/paytriner.dart';
import 'package:untitled17/screens/vod.dart';

class FirestoreService {
  final CollectionReference bookingRequests =
  FirebaseFirestore.instance.collection('BookingRequests');

  final CollectionReference approvedBookingRequests =
  FirebaseFirestore.instance.collection('ApprovedBookingRequests');

  Future<void> moveApprovedRequest() async {
    final QuerySnapshot bookingSnapshot = await bookingRequests.get();

    if (bookingSnapshot.docs.isNotEmpty) {
      final QueryDocumentSnapshot bookingDoc = bookingSnapshot.docs.first;
      final requestData = bookingDoc.data();

      await approvedBookingRequests.add(requestData);
      await bookingRequests.doc(bookingDoc.id).delete();
    }
  }
}

class Buy extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Screen'),
      ),
      body: Padding(
        padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.02),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return VodafonePlayground();
                    },
                  ),
                );
              },
              child: Container(
                padding:
                EdgeInsets.all(MediaQuery.of(context).size.height * 0.02),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(30.0),
                ),
                child: Center(
                  child: Text(
                    'Electronic wallet',
                    style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.05,
                        color: Colors.white),
                  ),
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return MySample();
                    },
                  ),
                );
              },
              child: Container(
                padding:
                EdgeInsets.all(MediaQuery.of(context).size.height * 0.02),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(30.0),
                ),
                child: Center(
                  child: Text(
                    'Visa',
                    style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.05,
                        color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MySample extends StatefulWidget {
  const MySample({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => MySampleState();
}

class MySampleState extends State<MySample> {
  bool isLightTheme = false; // حالة الثيم الحالي (فاتح/داكن)
  String cardNumber = ''; // رقم البطاقة
  String expiryDate = ''; // تاريخ انتهاء الصلاحية
  String cardHolderName = ''; // اسم صاحب البطاقة
  String cvvCode = ''; // رمز CVV
  bool isCvvFocused = false; // هل تم التركيز على رمز CVV
  bool useGlassMorphism = false; // هل يجب استخدام تأثير "Glassmorphism"
  bool useBackgroundImage = false; // هل يجب استخدام صورة خلفية
  bool useFloatingAnimation = true; // هل يجب استخدام الرسوم المتحركة الطافية
  final OutlineInputBorder border = OutlineInputBorder(
    borderSide: BorderSide(
      color: Colors.grey.withOpacity(0.7),
      width: 2.0,
    ),
  );
  final GlobalKey<FormState> formKey =
  GlobalKey<FormState>(); // مفتاح عالمي لنموذج البطاقة

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      isLightTheme ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light,
    );
    return MaterialApp(
      title: 'Card View',
      debugShowCheckedModeBanner: false,
      themeMode: isLightTheme ? ThemeMode.light : ThemeMode.dark,
      theme: ThemeData(
        // ثيم النصوص والحقول النصية في حالة الثيم الفاتح
        textTheme: const TextTheme(
          titleMedium: TextStyle(color: Colors.black, fontSize: 18),
        ),
        // تكوين الألوان لحالة الثيم الفاتح
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.light,
          seedColor: Colors.black,
          background: Colors.white,
          primary: Colors.black,
        ),
        // تصميم الحقول النصية
        inputDecorationTheme: InputDecorationTheme(
          hintStyle: const TextStyle(color: Colors.black),
          labelStyle: const TextStyle(color: Colors.black),
          focusedBorder: border,
          enabledBorder: border,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.0),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      darkTheme: ThemeData(
        // ثيم النصوص والحقول النصية في حالة الثيم الداكن
        textTheme: const TextTheme(
          titleMedium: TextStyle(color: Colors.white, fontSize: 18),
        ),
        // تكوين الألوان لحالة الثيم الداكن
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.dark,
          seedColor: Colors.black,
          background: Colors.white,
          primary: Colors.white,
        ),
        // تصميم الحقول النصية
        inputDecorationTheme: InputDecorationTheme(
          hintStyle: const TextStyle(color: Colors.black),
          labelStyle: const TextStyle(color: Colors.black),
          focusedBorder: border,
          enabledBorder: border,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.0),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Card View'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        resizeToAvoidBottomInset: false,
        body: Builder(
          builder: (BuildContext context) {
            return Container(
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    // عنصر عرض بطاقة الائتمان
                    CreditCardWidget(
                      enableFloatingCard: useFloatingAnimation,
                      glassmorphismConfig: _getGlassmorphismConfig(),
                      cardNumber: cardNumber,
                      expiryDate: expiryDate,
                      cardHolderName: cardHolderName,
                      cvvCode: cvvCode,
                      bankName: 'Axis Bank',
                      backgroundImage: 'images/visa.jpg',
                      frontCardBorder: useGlassMorphism
                          ? null
                          : Border.all(color: Colors.grey),
                      backCardBorder: useGlassMorphism
                          ? null
                          : Border.all(color: Colors.grey),
                      showBackView: isCvvFocused,
                      obscureCardNumber: true,
                      obscureCardCvv: true,
                      isHolderNameVisible: true,
                      // تعيين صورة خلفية مخصصة إذا تم تفعيلها
                      isSwipeGestureEnabled: true,
                      onCreditCardWidgetChange:
                          (CreditCardBrand creditCardBrand) {},
                      customCardTypeIcons: <CustomCardTypeIcon>[
                        CustomCardTypeIcon(
                          cardType: CardType.mastercard,
                          cardImage: Image.asset(
                            'assets/mastercard.png',
                            height: 48,
                            width: 48,
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: <Widget>[
                            // نموذج إدخال بيانات بطاقة الائتمان
                            CreditCardForm(
                              formKey: formKey,
                              obscureCvv: true,
                              obscureNumber: true,
                              cardNumber: cardNumber,
                              cvvCode: cvvCode,
                              isHolderNameVisible: true,
                              isCardNumberVisible: true,
                              isExpiryDateVisible: true,
                              cardHolderName: cardHolderName,
                              expiryDate: expiryDate,
                              inputConfiguration: const InputConfiguration(
                                cardNumberDecoration: InputDecoration(
                                  labelText: 'Number',
                                  hintText: 'XXXX XXXX XXXX XXXX',
                                ),
                                expiryDateDecoration: InputDecoration(
                                  labelText: 'Expired Date',
                                  hintText: 'XX/XX',
                                ),
                                cvvCodeDecoration: InputDecoration(
                                  labelText: 'CVV',
                                  hintText: 'XXX',
                                ),
                                cardHolderDecoration: InputDecoration(
                                  labelText: 'Card Holder',
                                ),
                              ),
// دالة تنفيذ عند تغيير البيانات في نموذج البطاقة
                              onCreditCardModelChange: onCreditCardModelChange,
                            ),
                            const SizedBox(height: 20),
// زر "Validate" للتحقق من صحة البيانات
                            GestureDetector(
                              onTap: _onValidate,
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: <Color>[
                                      Color(0xFFB58D67),
                                      Color(0xFFE5D1B2),
                                      Color(0xFFF9EED2),
                                      Color(0xFFEFEFED),
                                      Color(0xFFF9EED2),
                                      Color(0xFFB58D67),
                                    ],
                                    begin: Alignment(-1, -4),
                                    end: Alignment(1, 4),
                                  ),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      spreadRadius: 3,
                                      blurRadius: 7,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                padding:
                                const EdgeInsets.symmetric(vertical: 15),
                                alignment: Alignment.center,
                                child: const Text(
                                  'Validate',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: 'halter',
                                    fontSize: 14,
                                    package: 'flutter_credit_card',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

// دالة التحقق من صحة البيانات
  void _onValidate() {
    if (formKey.currentState?.validate() ?? false) {
      print('صحيحة!');
    } else {
      print('غير صحيحة!');
    }
  }

// دالة لإرجاع تكوين "Glassmorphism" المطلوب
  Glassmorphism? _getGlassmorphismConfig() {
    if (!useGlassMorphism) {
      return null;
    }
    final LinearGradient gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: <Color>[Colors.grey.withAlpha(50), Colors.grey.withAlpha(50)],
      stops: const <double>[0.3, 0],
    );

    return isLightTheme
        ? Glassmorphism(blurX: 8.0, blurY: 16.0, gradient: gradient)
        : Glassmorphism.defaultConfig();
  }

// دالة تنفيذ عند تغيير البيانات في نموذج بطاقة الائتمان
  void onCreditCardModelChange(CreditCardModel creditCardModel) {
    setState(() {
      cardNumber = creditCardModel.cardNumber;
      expiryDate = creditCardModel.expiryDate;
      cardHolderName = creditCardModel.cardHolderName;
      cvvCode = creditCardModel.cvvCode;
      isCvvFocused = creditCardModel.isCvvFocused;
    });
  }
}



