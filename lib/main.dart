import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrangeAccent),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        ),
      home: const AuthPage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({super.key, required this.title});

  final String title;
  final User? userID = FirebaseAuth.instance.currentUser;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  String ans = '';
  String prevNum = '';
  String newNum = '';
  String oper = '';
  String history = '';

  double num1 = 0.0;
  double num2 = 0.0;
  double temp = 0.0;
  
  bool shouldClear = false;
  bool darkEnabled = false;

  Color textBoxColor = Colors.white;
  Color backgroundColor = Colors.white;
  Color appBarColor = Colors.deepOrange.shade800;
  IconData themeIcon = Icons.dark_mode;

  var style1 = ElevatedButton.styleFrom(backgroundColor: Colors.red.shade500,
  foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius:
  BorderRadius.circular(20)),);
  var style2 = ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange.shade500,
  foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius:
  BorderRadius.circular(20)),);
  var style3 = ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange.shade300,
  foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius:
  BorderRadius.circular(20)),);

  void addUserHistory(String history) async {
    await FirebaseFirestore.instance.collection(widget.userID!.email.toString()).add({
      'history': history,
      'time': DateTime.now(),
    });
  }

  void backspace(){
    setState(() {
      if (shouldClear == true) {
        clear();
      }
      ans = ans.substring(0, ans.length - 1);
    });
  }

  void clear() {
    setState(() {
      ans = '';
      prevNum = '';
      newNum = '';
      oper = '';
      history = '';
      num1 = 0.0;
      num2 = 0.0;
      shouldClear = false;
    });
  }

  void calculate() {
    setState(() {
      shouldClear = true;
      if (ans.isNotEmpty) {
        num2 = double.parse(ans);
        if (oper == '+') {
          ans = (num1 + num2).toString();
        }
        else if (oper == '-') {
          ans = (num1 - num2).toString();
        }
        else if (oper == 'x') {
          ans = (num1 * num2).toString();
        }
        else if (oper == '÷') {
          if (num2 == 0) {
            clear();
          }
          else {
            ans = (num1 / num2).toString();
          }
        }
        prevNum = num1.toString();
        newNum = num2.toString();
        setPrecision();
        history = '$prevNum $oper $newNum = $ans';
        num1 = 0.0;
        num2 = 0.0;
        oper = '';
      }
      else {
        shouldClear = false;
      }
    });
  }

  void numClicked(numC){
    setState(() {
      if (shouldClear == true) {
        clear();
      }
      if (numC=='.'){
        if (!ans.contains('.')){
          ans = ans + numC;
        }
      }
      else {
        ans = ans + numC;
      }
    });
  }

  void operClicked(String ope){
    setState(() {
      shouldClear = false;
      if (ans.isNotEmpty) {
        prevNum = ans;
        if (oper != '') {
          calculate();
          shouldClear = false;
          prevNum = ans;
          num1 = double.parse(ans);
          ans = '';
          oper = ope;
        }
        else{
          num1 = double.parse(ans);
          ans = '';
          oper = ope;
        }
      }
      else if (ans.isEmpty) {
        oper = ope;
      }
      history = prevNum;
    });
  }

  void changeSign(){
    setState(() {
      temp = double.parse(ans) * (-1.0);
      ans = temp.toString();
      setPrecision();
      shouldClear == false;
    });
  }

  void percentage(){
    setState(() {
      temp = double.parse(ans) / 100.0;
      ans = temp.toString();
      setPrecision();
      shouldClear == true;
    });
  }

  void constants(k){
    setState(() {
      if (shouldClear == true) {
        clear();
      }
      if (k == 'π') {
        ans = '3.14159';
        shouldClear == false;
      }
      else if (k == 'e') {
        ans = '2.71828';
        shouldClear == false;
      }
    });
  }

  void square() {
    setState(() {
      temp = double.parse(ans);
      prevNum = ans;
      ans = (temp * temp).toString();
      setPrecision();
      shouldClear == true;
      history = '$prevNum ^ 2';
    });
  }

  void cube() {
    setState(() {
      temp = double.parse(ans);
      prevNum = ans;
      ans = (temp * temp * temp).toString();
      setPrecision();
      shouldClear == true;
      history = '$prevNum ^ 3';
    });
  }

  void setPrecision(){
    setState(() {
      if (ans.isNotEmpty)
      {
        temp = double.parse(ans);
        if ((temp - (temp.round()).toDouble()).abs() < 1e-12) {
          ans = (temp.round()).toString();
        }
      }
      if (prevNum.isNotEmpty)
      {
        temp = double.parse(prevNum);
        if (prevNum.isNotEmpty && (temp - (temp.round()).toDouble()).abs() < 1e-12) {
            prevNum = ((double.parse(prevNum)).round()).toString();
        }
      }
      if (newNum.isNotEmpty)
      {
        temp = double.parse(newNum);
        if (newNum.isNotEmpty && (temp - (temp.round()).toDouble()).abs() < 1e-12) {
            newNum = ((double.parse(newNum)).round()).toString();
        }
      }
      ans = ans.toString();
      prevNum = prevNum.toString();
      newNum = newNum.toString();
    });
  }

  void darkTheme() {
    setState(() {
      if (!darkEnabled) {
        darkEnabled = true;
        backgroundColor = Colors.black;
        textBoxColor = Colors.white70;
        appBarColor = Colors.black;
        themeIcon = Icons.light_mode;
        style1 = ElevatedButton.styleFrom(
          backgroundColor: Colors.cyan.shade900, foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),);
        style2 = ElevatedButton.styleFrom(
          backgroundColor: Colors.blueGrey.shade600, foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),);
        style3 = ElevatedButton.styleFrom(
          backgroundColor: Colors.blueGrey.shade900, foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),);
      }
      else {
        darkEnabled = false;
        backgroundColor = Colors.white;
        textBoxColor = Colors.white;
        appBarColor = Colors.deepOrange.shade800;
        themeIcon = Icons.dark_mode;
        style1 = ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade500, foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),);
        style2 = ElevatedButton.styleFrom(
          backgroundColor: Colors.deepOrange.shade500, foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),);
        style3 = ElevatedButton.styleFrom(
          backgroundColor: Colors.deepOrange.shade300, foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),);
      }
    });
  }

  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    SizedBox uiButton(double x, double y, ButtonStyle style,
      void Function() func, String txt) {
        return SizedBox(width: screenWidth*x, height: screenHeight*y, child:
          ElevatedButton(style: style, onPressed: func, child:
            FittedBox(fit: BoxFit.scaleDown, child: Text(txt,
              style: const TextStyle(fontSize: 40),),),),);
    }

    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white, backgroundColor: appBarColor,
        title: Text(widget.title), centerTitle: true,
        actions: <Widget>[
          IconButton(icon: Icon(themeIcon), onPressed: () {
              setState(() {
                darkTheme();
              });
            },),
            IconButton(icon: const Icon(Icons.logout), onPressed: () {
              setState(() {
                signUserOut();
              });
            },),
            IconButton(icon: const Icon(Icons.history), onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder:
              (context) => HistoryPage()));
            },),
            ],
      ),

      body:
    Container(color: backgroundColor, child:
    Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          SizedBox(width: screenWidth*0.975, height: screenHeight*0.07, child:
            OutlinedButton(style: TextButton.styleFrom(shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                backgroundColor: textBoxColor), onPressed: null, child:
                  Text(history.split(' = ')[0], style:
                    Theme.of(context).textTheme.headlineSmall,),),),
          SizedBox(width: screenWidth*0.975, height: screenHeight*0.07, child:
            OutlinedButton(style: TextButton.styleFrom(shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                backgroundColor: textBoxColor), onPressed: null, child:
                  Text(ans, style: Theme.of(context).textTheme.headlineSmall,),),),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  uiButton(0.18, 0.085, style1, clear, 'C'),
                  uiButton(0.18, 0.085, style2, square, 'x²'),
                  uiButton(0.18, 0.085, style2, cube, 'x³'),
                  uiButton(0.18, 0.085, style1, backspace, '⌫'),
                ],
              ),
              SizedBox(height: screenHeight*0.02),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  uiButton(0.18, 0.085, style2, percentage, '%'),
                  uiButton(0.18, 0.085, style2, (){constants('e');}, 'e'),
                  uiButton(0.18, 0.085, style2, (){constants('π');}, 'π'),
                  uiButton(0.18, 0.085, style2, (){operClicked('+');}, '+'),
                ],
              ),
              SizedBox(height: screenHeight*0.02),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  uiButton(0.18, 0.085, style3, (){numClicked('7');}, '7'),
                  uiButton(0.18, 0.085, style3, (){numClicked('8');}, '8'),
                  uiButton(0.18, 0.085, style3, (){numClicked('9');}, '9'),
                  uiButton(0.18, 0.085, style2, (){operClicked('-');}, '-'),
                ],
              ),
              SizedBox(height: screenHeight*0.02),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  uiButton(0.18, 0.085, style3, (){numClicked('4');}, '4'),
                  uiButton(0.18, 0.085, style3, (){numClicked('5');}, '5'),
                  uiButton(0.18, 0.085, style3, (){numClicked('6');}, '6'),
                  uiButton(0.18, 0.085, style2, (){operClicked('x');}, 'x'),
                ],
              ),
              SizedBox(height: screenHeight*0.02),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  uiButton(0.18, 0.085, style3, (){numClicked('1');}, '1'),
                  uiButton(0.18, 0.085, style3, (){numClicked('2');}, '2'),
                  uiButton(0.18, 0.085, style3, (){numClicked('3');}, '3'),
                  uiButton(0.18, 0.085, style2, (){operClicked('÷');}, '÷'),
                ],
              ),
              SizedBox(height: screenHeight*0.02),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  uiButton(0.18, 0.085, style2, changeSign, '±'),
                  uiButton(0.18, 0.085, style3, (){numClicked('0');}, '0'),
                  uiButton(0.18, 0.085, style2, (){numClicked('.');}, '.'),
                  uiButton(0.18, 0.085, style1, (){
                    calculate();
                    if (prevNum.isNotEmpty) {
                      addUserHistory(history);
                    }
                  }, '='),
                ],
              ),
            ],),
        ],
      ),
    ),
    );
  }
}

class HistoryPage extends StatelessWidget {
  HistoryPage({super.key});

  final User? userID = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.deepOrange.shade800,
        title: const Text('History'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection(userID!.email.toString()).
          orderBy('time', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final doc = snapshot.data!.docs[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child:
                    ListTile(
                      title: Text(doc['history'], style:
                        Theme.of(context).textTheme.headlineSmall,),
                      visualDensity: VisualDensity.standard,
                      tileColor: Colors.grey[200],
                    ),
                );
              },
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}