import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sports App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About'),
        backgroundColor: Colors.grey[200],
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Add your navigation logic here
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'حول التطبيق',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.right,
            ),
            SizedBox(height: 10),
            Text(
              'تطبيقنا هو وجهتك المثالية لتنظيم ومشاركة شغفك بالرياضة والنشاط البدني. يتيح لك تطبيقنا حجز الملاعب الرياضية بسهولة ويسر، بالإضافة إلى إمكانية حجز الفعاليات الرياضية المختلفة مثل الجري وركوب الدراجات.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.right,
            ),
            SizedBox(height: 20),
            Text(
              'حول المدربين',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.right,
            ),
            SizedBox(height: 10),
            Text(
              'يعد قسم المدربين في تطبيقنا مكانًا مثاليًا للبحث عن والحجز مع مدربين محترفين في مختلف المجالات الرياضية. سواء كنت تبحث عن مدرب شخصي لتحسين لياقتك البدنية أو تدريبات متخصصة في رياضة معينة، فإن قسم المدربين يضم مجموعة متنوعة من المدربين المؤهلين لمساعدتك في تحقيق أهدافك الرياضية.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.right,
            ),
            SizedBox(height: 20),
            Text(
              'ما يميزنا',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.right,
            ),
            SizedBox(height: 10),
            Text(
              '- سهولة الاستخدام: تطبيقنا مصمم ليكون بسيطاً وسهلاً للاستخدام، حتى يتيح لك الوصول السريع لما تبحث عنه.\n'
                  '- مرونة التنظيم: يمكنك تنظيم جدولك الرياضي بسهولة، سواء كنت ترغب في حجز ملعب لكرة القدم أو الاشتراك في فعاليات رياضية مختلفة.\n'
                  '- تواصل اجتماعي: قم بمشاركة نشاطاتك وتجاربك الرياضية مع الآخرين، واكتسب تجارب جديدة من خلال تواصلك مع مجتمعنا الرياضي الواسع.\n'
                  '- أمان وموثوقية: نحن نولي اهتماماً كبيراً بأمان بياناتك ومعلوماتك الشخصية، لتتمكن من الاستمتاع بتجربة استخدام آمنة وموثوقة.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.right,
            ),
            SizedBox(height: 20),
            Text(
              'رؤيتنا',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.right,
            ),
            SizedBox(height: 10),
            Text(
              'نطمح إلى تحفيز وتشجيع المجتمع على اعتماد أسلوب حياة صحي ونشط، من خلال توفير وسيلة سهلة وممتعة لممارسة الرياضة والنشاط البدني.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.right,
            ),
            SizedBox(height: 20),
            Text(
              'تواصل معنا',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.right,
            ),
            SizedBox(height: 10),
            Text(
              'نحن هنا لمساعدتك في العثور على المدرب المثالي لاحتياجاتك الرياضية. لا تتردد في الاتصال بنا لأي استفسار أو مساعدة تحتاجها.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.right,
            ),
          ],
        ),
      ),
    );
  }
}