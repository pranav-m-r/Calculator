import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'login.dart';
import 'globals.dart' as globals;

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
  MyHomePage({super.key});

  final String? userID = FirebaseAuth.instance.currentUser!.email;
  
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  String prevNum = '';
  String newNum = '';
  String oper = '';
  double num1 = 0.0;
  double num2 = 0.0;
  double temp = 0.0;
  
  bool shouldClear = false;

  void save(String lastCalc) async {
    await FirebaseFirestore.instance.collection(widget.userID!).add({
      'calc': lastCalc,
      'time': DateTime.now(),
    });
  }

  void backspace(){
    setState(() {
      if (shouldClear == true) {
        clear();
      }
      globals.ans = globals.ans.substring(0, globals.ans.length - 1);
    });
  }

  void clear() {
    setState(() {
      globals.ans = '';
      prevNum = '';
      newNum = '';
      oper = '';
      globals.lastCalc = '';
      num1 = 0.0;
      num2 = 0.0;
      shouldClear = false;
    });
  }

  void calculate() {
    setState(() {
      shouldClear = true;
      if (globals.ans.isNotEmpty) {
        num2 = double.parse(globals.ans);
        if (oper == '+') {
          globals.ans = (num1 + num2).toString();
          prevNum = num1.toString();
          newNum = num2.toString();
          setPrecision();
          globals.lastCalc = '$prevNum $oper $newNum = ${globals.ans}';
        }
        else if (oper == '-') {
          globals.ans = (num1 - num2).toString();
          prevNum = num1.toString();
          newNum = num2.toString();
          setPrecision();
          globals.lastCalc = '$prevNum $oper $newNum = ${globals.ans}';
        }
        else if (oper == 'x') {
          globals.ans = (num1 * num2).toString();
          prevNum = num1.toString();
          newNum = num2.toString();
          setPrecision();
          globals.lastCalc = '$prevNum $oper $newNum = ${globals.ans}';
        }
        else if (oper == '÷') {
          if (num2 == 0) {
            clear();
          }
          else {
            globals.ans = (num1 / num2).toString();
            prevNum = num1.toString();
            newNum = num2.toString();
            setPrecision();
            globals.lastCalc = '$prevNum $oper $newNum = ${globals.ans}';
          }
        }
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
        if (!globals.ans.contains('.')){
          globals.ans = globals.ans + numC;
        }
      }
      else {
        globals.ans = globals.ans + numC;
      }
    });
  }

  void operClicked(String ope){
    setState(() {
      shouldClear = false;
      if (globals.ans.isNotEmpty) {
        prevNum = globals.ans;
        if (oper != '') {
          calculate();
          shouldClear = false;
          prevNum = globals.ans;
          num1 = double.parse(globals.ans);
          globals.ans = '';
          oper = ope;
        }
        else{
          num1 = double.parse(globals.ans);
          globals.ans = '';
          oper = ope;
        }
      }
      else if (globals.ans.isEmpty) {
        oper = ope;
      }
      globals.lastCalc = prevNum;
    });
  }

  void changeSign(){
    setState(() {
      temp = double.parse(globals.ans) * (-1.0);
      globals.ans = temp.toString();
      setPrecision();
      shouldClear == false;
    });
  }

  void percentage(){
    setState(() {
      temp = double.parse(globals.ans) / 100.0;
      prevNum = globals.ans;
      globals.ans = temp.toString();
      setPrecision();
      shouldClear == true;
      globals.lastCalc = '$prevNum% = ${globals.ans}';
    });
  }

  void constants(k){
    setState(() {
      if (shouldClear == true) {
        clear();
      }
      if (k == 'π') {
        globals.ans = '3.14159';
        shouldClear == false;
      }
      else if (k == 'e') {
        globals.ans = '2.71828';
        shouldClear == false;
      }
    });
  }

  void square() {
    setState(() {
      temp = double.parse(globals.ans);
      prevNum = globals.ans;
      globals.ans = (temp * temp).toString();
      setPrecision();
      shouldClear == true;
      globals.lastCalc = '$prevNum ^ 2 = ${globals.ans}';
    });
  }

  void cube() {
    setState(() {
      temp = double.parse(globals.ans);
      prevNum = globals.ans;
      globals.ans = (temp * temp * temp).toString();
      setPrecision();
      shouldClear == true;
      globals.lastCalc = '$prevNum ^ 3 = ${globals.ans}';
    });
  }

  void setPrecision(){
    setState(() {
      if (globals.ans.isNotEmpty)
      {
        temp = double.parse(globals.ans);
        if ((temp - (temp.round()).toDouble()).abs() < 1e-12) {
          globals.ans = (temp.round()).toString();
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
      globals.ans = globals.ans.toString();
      prevNum = prevNum.toString();
      newNum = newNum.toString();
    });
  }

  void darkTheme() {
    setState(() {
      if (!globals.darkEnabled) {
        globals.darkEnabled = true;
        globals.backgroundColor = Colors.black;
        globals.textColor = Colors.white;
        globals.textBoxColor = Colors.grey.shade900;
        globals.appBarColor = Colors.black;
        globals.themeIcon = Icons.light_mode;
        globals.style1 = ElevatedButton.styleFrom(
          backgroundColor: Colors.cyan.shade900, foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),);
        globals.style2 = ElevatedButton.styleFrom(
          backgroundColor: Colors.blueGrey.shade600, foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),);
        globals.style3 = ElevatedButton.styleFrom(
          backgroundColor: Colors.blueGrey.shade900, foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),);
      }
      else {
        globals.darkEnabled = false;
        globals.backgroundColor = Colors.white;
        globals.textColor = Colors.black;
        globals.textBoxColor = Colors.grey.shade200;
        globals.appBarColor = Colors.deepOrange.shade800;
        globals.themeIcon = Icons.dark_mode;
        globals.style1 = ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade500, foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),);
        globals.style2 = ElevatedButton.styleFrom(
          backgroundColor: Colors.deepOrange.shade500, foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),);
        globals.style3 = ElevatedButton.styleFrom(
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
        foregroundColor: Colors.white, backgroundColor: globals.appBarColor,
        title: const Text('Calculator'), centerTitle: true,
        leading: IconButton(icon: Icon(globals.themeIcon),
          onPressed: () {
              setState(() {darkTheme();});
            },),
        actions: <Widget>[
            IconButton(icon: const Icon(Icons.history), onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder:
              (context) => HistoryPage())).then((value) {setState(() {});});
              }),
            IconButton(icon: const Icon(Icons.logout), onPressed: () {
              setState(() {
                signUserOut();
              });
            },),
            ],
      ),

      body:
    Container(color: globals.backgroundColor, child:
    Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          SizedBox(width: screenWidth*0.92, height: screenHeight*0.07, child:
            OutlinedButton(style: TextButton.styleFrom(shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                backgroundColor: globals.textBoxColor), onPressed: null, child:
                  Text(globals.lastCalc.split(' = ')[0], style:
                    TextStyle(fontSize: 25, color: globals.textColor)),),),
          SizedBox(width: screenWidth*0.92, height: screenHeight*0.07, child:
            OutlinedButton(style: TextButton.styleFrom(shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                backgroundColor: globals.textBoxColor), onPressed: null, child:
                  Text(globals.ans, style: TextStyle(fontSize: 25, color: globals.textColor)),),),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  uiButton(0.18, 0.085, globals.style1, clear, 'C'),
                  uiButton(0.18, 0.085, globals.style2, square, 'x²'),
                  uiButton(0.18, 0.085, globals.style2, cube, 'x³'),
                  uiButton(0.18, 0.085, globals.style1, backspace, '⌫'),
                ],
              ),
              SizedBox(height: screenHeight*0.02),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  uiButton(0.18, 0.085, globals.style2, percentage, '%'),
                  uiButton(0.18, 0.085, globals.style2, (){constants('e');}, 'e'),
                  uiButton(0.18, 0.085, globals.style2, (){constants('π');}, 'π'),
                  uiButton(0.18, 0.085, globals.style2, (){operClicked('+');}, '+'),
                ],
              ),
              SizedBox(height: screenHeight*0.02),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  uiButton(0.18, 0.085, globals.style3, (){numClicked('7');}, '7'),
                  uiButton(0.18, 0.085, globals.style3, (){numClicked('8');}, '8'),
                  uiButton(0.18, 0.085, globals.style3, (){numClicked('9');}, '9'),
                  uiButton(0.18, 0.085, globals.style2, (){operClicked('-');}, '-'),
                ],
              ),
              SizedBox(height: screenHeight*0.02),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  uiButton(0.18, 0.085, globals.style3, (){numClicked('4');}, '4'),
                  uiButton(0.18, 0.085, globals.style3, (){numClicked('5');}, '5'),
                  uiButton(0.18, 0.085, globals.style3, (){numClicked('6');}, '6'),
                  uiButton(0.18, 0.085, globals.style2, (){operClicked('x');}, 'x'),
                ],
              ),
              SizedBox(height: screenHeight*0.02),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  uiButton(0.18, 0.085, globals.style3, (){numClicked('1');}, '1'),
                  uiButton(0.18, 0.085, globals.style3, (){numClicked('2');}, '2'),
                  uiButton(0.18, 0.085, globals.style3, (){numClicked('3');}, '3'),
                  uiButton(0.18, 0.085, globals.style2, (){operClicked('÷');}, '÷'),
                ],
              ),
              SizedBox(height: screenHeight*0.02),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  uiButton(0.18, 0.085, globals.style2, changeSign, '±'),
                  uiButton(0.18, 0.085, globals.style3, (){numClicked('0');}, '0'),
                  uiButton(0.18, 0.085, globals.style2, (){numClicked('.');}, '.'),
                  uiButton(0.18, 0.085, globals.style1, (){
                    calculate();
                    if (prevNum.isNotEmpty) {
                      save(globals.lastCalc);
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

  final String? userID = FirebaseAuth.instance.currentUser!.email;

  void clearHistory() {
    FirebaseFirestore.instance.collection(userID!).get().then((snapshot) {
      for (DocumentSnapshot ds in snapshot.docs){ds.reference.delete();}
    });
  }

  @override
  Widget build(BuildContext context) {

    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: globals.appBarColor,
        title: const Text('History'),
        centerTitle: true,
        actions: <Widget>[
          IconButton(icon: const Icon(Icons.delete), onPressed: () {clearHistory();}),
        ],
      ),
      body: Container(color: globals.backgroundColor,
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection(userID!).
            orderBy('time', descending: true).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final doc = snapshot.data!.docs[index];
                  return Padding(
                    padding: EdgeInsets.all(screenWidth*0.04),
                    child:
                      GestureDetector(
                        onTap: () {
                          globals.lastCalc = doc['calc'];
                          globals.ans = doc['calc'].split(' = ')[1];
                          Navigator.of(context).pop();
                        },
                        child: ListTile(
                          title: Text(doc['calc'], style: const TextStyle(fontSize: 20)),
                          textColor: globals.textColor,
                        ),
                      ),
                  );
                },
              );
            }
            else {
                return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }
}