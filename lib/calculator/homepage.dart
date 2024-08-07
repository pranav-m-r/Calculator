import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:decimal/decimal.dart';
import 'dart:math' as math;
import 'history.dart';
import '../currency/currency.dart';
import '../data/themedata.dart' as globals;

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
  Decimal num1 = Decimal.parse('0.0');
  Decimal num2 = Decimal.parse('0.0');
  Decimal temp = Decimal.parse('0.0');
  bool shouldClear = false;

  final pwd = TextEditingController();

  void saveHistory(String lastCalc) async {
    await FirebaseFirestore.instance.collection(widget.userID!).add({
      'calc': lastCalc,
      'time': DateTime.now(),
    });
  }

  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  void deleteAccount() async {
    if (pwd.text.isEmpty) {
      globals.showErrorMessage('Please enter your password', context);
      return;
    }
    try {
      User user = FirebaseAuth.instance.currentUser!;
      AuthCredential credentials = EmailAuthProvider.credential(
          email: widget.userID!, password: pwd.text);
      await user.reauthenticateWithCredential(credentials);
      FirebaseFirestore.instance
          .collection(widget.userID!)
          .get()
          .then((snapshot) {
        for (DocumentSnapshot ds in snapshot.docs) {
          ds.reference.delete();
        }
      });
      await user.delete();
      if (mounted) {
        Navigator.pop(context);
        globals.showErrorMessage('Account Deleted', context);
      }
    } catch (e) {
      if (mounted) {
        globals.showErrorMessage(
            "Authentication Error (${e.toString()})", context);
      }
    }
  }

  void backspace() {
    setState(() {
      if (shouldClear == true) {
        clear();
      }
      if (globals.ans.isNotEmpty) {
        globals.ans = globals.ans.substring(0, globals.ans.length - 1);
      }
    });
  }

  void clear() {
    setState(() {
      globals.ans = '';
      prevNum = '';
      newNum = '';
      oper = '';
      globals.lastCalc = '';
      num1 = Decimal.parse('0.0');
      num2 = Decimal.parse('0.0');
      shouldClear = false;
    });
  }

  void calculate() {
    setState(() {
      shouldClear = true;
      if (globals.ans.isNotEmpty) {
        num2 = Decimal.parse(globals.ans);
        if (oper == '+') {
          globals.ans = (num1 + num2).toString();
          prevNum = num1.toString();
          newNum = num2.toString();
        } else if (oper == '-') {
          globals.ans = (num1 - num2).toString();
          prevNum = num1.toString();
          newNum = num2.toString();
        } else if (oper == 'x') {
          globals.ans = (num1 * num2).toString();
          prevNum = num1.toString();
          newNum = num2.toString();
        } else if (oper == '^') {
          try {
            temp = Decimal.parse(
                (math.pow(num1.toDouble(), num2.toDouble())).toString());
            globals.ans = temp.toString();
            prevNum = num1.toString();
            newNum = num2.toString();
          } catch (e) {
            globals.showErrorMessage('Math Error (Invalid Input)', context);
            shouldClear = false;
            return;
          }
        } else if (oper == '÷') {
          if (num2 == Decimal.parse('0.0')) {
            globals.showErrorMessage(
                'Math Error (Cannot divide by zero)', context);
            shouldClear = false;
            return;
          } else {
            globals.ans = (num1 / num2).toDouble().toString();
            prevNum = num1.toString();
            newNum = num2.toString();
          }
        }
        globals.ans = globals.formatNumber(globals.ans);
        prevNum = globals.formatNumber(prevNum);
        newNum = globals.formatNumber(newNum);
        globals.lastCalc = '$prevNum $oper $newNum = ${globals.ans}';
        num1 = Decimal.parse('0.0');
        num2 = Decimal.parse('0.0');
        oper = '';
      } else {
        shouldClear = false;
      }
    });
  }

  void numClicked(numC) {
    setState(() {
      if (shouldClear) {
        clear();
      }
      if (numC == '.') {
        if (!globals.ans.contains('.')) {
          globals.ans = globals.ans + numC;
        }
      } else {
        globals.ans = globals.ans + numC;
      }
    });
  }

  void operClicked(String ope) {
    setState(() {
      shouldClear = false;
      if (globals.ans.isNotEmpty) {
        prevNum = globals.formatNumber(globals.ans);
        if (oper != '') {
          calculate();
          shouldClear = false;
          prevNum = globals.ans;
          num1 = Decimal.parse(globals.ans);
          globals.ans = '';
          oper = ope;
        } else {
          num1 = Decimal.parse(globals.ans);
          globals.ans = '';
          oper = ope;
        }
      } else if (globals.ans.isEmpty) {
        oper = ope;
      }
      globals.lastCalc = prevNum;
    });
  }

  void changeSign() {
    setState(() {
      if (globals.ans.isEmpty) {
        return;
      }
      temp = Decimal.parse(globals.ans) * Decimal.parse('-1.0');
      globals.ans = temp.toString();
      shouldClear = false;
    });
  }

  void constants(k) {
    setState(() {
      if (shouldClear) {
        clear();
      }
      if (k == 'π') {
        globals.ans = '3.14159';
        shouldClear = false;
      } else if (k == 'e') {
        globals.ans = '2.71828';
        shouldClear = false;
      }
    });
  }

  void scientific(String s) {
    setState(() {
      if (globals.ans.isEmpty) {
        return;
      }
      try {
        if (s == 'sin') {
          temp =
              Decimal.parse((math.sin(double.parse(globals.ans))).toString());
        } else if (s == 'cos') {
          temp =
              Decimal.parse((math.cos(double.parse(globals.ans))).toString());
        } else if (s == 'tan') {
          temp =
              Decimal.parse((math.tan(double.parse(globals.ans))).toString());
        } else if (s == 'arcsin') {
          temp =
              Decimal.parse((math.asin(double.parse(globals.ans))).toString());
        } else if (s == 'arccos') {
          temp =
              Decimal.parse((math.acos(double.parse(globals.ans))).toString());
        } else if (s == 'arctan') {
          temp =
              Decimal.parse((math.atan(double.parse(globals.ans))).toString());
        } else if (s == 'ln') {
          temp =
              Decimal.parse((math.log(double.parse(globals.ans))).toString());
        } else if (s == 'sqrt') {
          temp = Decimal.parse(
              (math.pow(double.parse(globals.ans), 0.5)).toString());
        }
        prevNum = globals.ans;
        globals.ans = temp.toStringAsFixed(5);
        globals.ans = globals.formatNumber(globals.ans);
        prevNum = globals.formatNumber(prevNum);
        globals.lastCalc = '$s($prevNum) = ${globals.ans}';
        saveHistory(globals.lastCalc);
      } catch (e) {
        globals.showErrorMessage('Math Error (Invalid Input)', context);
      }
      shouldClear = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double btnHeight = screenHeight * 0.085;

    Future showDeleteDialog() {
      return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: globals.backgroundColor,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(Icons.delete_forever, size: 28, color: globals.textColor),
                Text("Delete Account",
                    style: TextStyle(color: globals.textColor)),
                const SizedBox(),
                const SizedBox(),
              ],
            ),
            content: TextField(
              controller: pwd,
              obscureText: true,
              onTapOutside: (event) {
                FocusManager.instance.primaryFocus?.unfocus();
              },
              decoration: InputDecoration(
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                  fillColor: globals.textBoxColor,
                  filled: true,
                  hintText: "Password",
                  hintStyle: TextStyle(color: Colors.grey.shade500)),
            ),
            actions: <Widget>[
              SizedBox(
                height: screenHeight * 0.07,
                child: ElevatedButton(
                  style: globals.style1,
                  onPressed: deleteAccount,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        "Confirm",
                        style: TextStyle(fontSize: 25),
                      ),
                      Icon(
                        Icons.arrow_forward,
                        size: 25,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: globals.appBarColor,
        title: const Text('Calculator'),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
              icon: const Icon(Icons.history),
              onPressed: () {
                Navigator.of(context)
                    .push(
                        MaterialPageRoute(builder: (context) => HistoryPage()))
                    .then((value) {
                  setState(() {});
                });
              }),
        ],
      ),
      drawer: Drawer(
        backgroundColor: globals.backgroundColor,
        child: ListView(
          children: <Widget>[
            DrawerHeader(
              child: Center(
                child: Text(
                  'Options',
                  style: TextStyle(fontSize: 25, color: globals.textColor),
                ),
              ),
            ),
            ListTile(
              title: Text((!globals.darkEnabled) ? 'Dark Theme' : 'Light Theme',
                  style: TextStyle(color: globals.textColor)),
              leading: Icon(globals.themeIcon, color: globals.textColor),
              onTap: () {
                setState(() {
                  globals.darkTheme();
                });
              },
            ),
            const Divider(),
            ListTile(
              title: Text('Calculator',
                  style: TextStyle(color: globals.textColor)),
              leading: Icon(Icons.calculate_outlined, color: globals.textColor),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title:
                  Text('History', style: TextStyle(color: globals.textColor)),
              leading: Icon(Icons.history, color: globals.textColor),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context)
                    .push(
                        MaterialPageRoute(builder: (context) => HistoryPage()))
                    .then((value) {
                  setState(() {});
                });
              },
            ),
            ListTile(
              title:
                  Text('Currency', style: TextStyle(color: globals.textColor)),
              leading: Icon(Icons.currency_exchange_outlined,
                  color: globals.textColor),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context)
                    .push(MaterialPageRoute(
                        builder: (context) => const CurrencyPage()))
                    .then((value) {
                  setState(() {});
                });
              },
            ),
            const Divider(),
            ListTile(
              title:
                  Text('Sign Out', style: TextStyle(color: globals.textColor)),
              leading: Icon(Icons.logout, color: globals.textColor),
              onTap: () {
                setState(() {
                  clear();
                  signUserOut();
                });
              },
            ),
            ListTile(
              title: Text('Delete Account',
                  style: TextStyle(color: globals.textColor)),
              leading: Icon(Icons.delete_forever, color: globals.textColor),
              onTap: () {
                setState(() {
                  clear();
                  showDeleteDialog();
                });
              },
            ),
          ],
        ),
      ),
      body: Container(
        color: globals.backgroundColor,
        width: screenWidth,
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              globals.textBox(screenWidth * 0.95, screenHeight * 0.075,
                  globals.lastCalc.split(' = ')[0]),
              globals.textBox(
                  screenWidth * 0.95, screenHeight * 0.075, globals.ans),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  globals.uiButton(btnHeight, globals.style1, clear, 'C'),
                  globals.uiButton(btnHeight, globals.style2, () {
                    scientific('sin');
                  }, 'sin'),
                  globals.uiButton(btnHeight, globals.style2, () {
                    scientific('cos');
                  }, 'cos'),
                  globals.uiButton(btnHeight, globals.style2, () {
                    scientific('tan');
                  }, 'tan'),
                  globals.uiButton(btnHeight, globals.style1, backspace, '⌫'),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  globals.uiButton(btnHeight, globals.style2, () {
                    operClicked('^');
                  }, '^'),
                  globals.uiButton(btnHeight, globals.style2, () {
                    scientific('arcsin');
                  }, 'arc\nsin'),
                  globals.uiButton(btnHeight, globals.style2, () {
                    scientific('arccos');
                  }, 'arc\ncos'),
                  globals.uiButton(btnHeight, globals.style2, () {
                    scientific('arctan');
                  }, 'arc\ntan'),
                  globals.uiButton(btnHeight, globals.style2, () {
                    operClicked('+');
                  }, '+'),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  globals.uiButton(btnHeight, globals.style2, () {
                    scientific('sqrt');
                  }, '√'),
                  globals.uiButton(btnHeight, globals.style3, () {
                    numClicked('7');
                  }, '7'),
                  globals.uiButton(btnHeight, globals.style3, () {
                    numClicked('8');
                  }, '8'),
                  globals.uiButton(btnHeight, globals.style3, () {
                    numClicked('9');
                  }, '9'),
                  globals.uiButton(btnHeight, globals.style2, () {
                    operClicked('-');
                  }, '-'),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  globals.uiButton(btnHeight, globals.style2, () {
                    scientific('ln');
                  }, 'ln'),
                  globals.uiButton(btnHeight, globals.style3, () {
                    numClicked('4');
                  }, '4'),
                  globals.uiButton(btnHeight, globals.style3, () {
                    numClicked('5');
                  }, '5'),
                  globals.uiButton(btnHeight, globals.style3, () {
                    numClicked('6');
                  }, '6'),
                  globals.uiButton(btnHeight, globals.style2, () {
                    operClicked('x');
                  }, 'x'),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  globals.uiButton(btnHeight, globals.style2, () {
                    constants('e');
                  }, 'e'),
                  globals.uiButton(btnHeight, globals.style3, () {
                    numClicked('1');
                  }, '1'),
                  globals.uiButton(btnHeight, globals.style3, () {
                    numClicked('2');
                  }, '2'),
                  globals.uiButton(btnHeight, globals.style3, () {
                    numClicked('3');
                  }, '3'),
                  globals.uiButton(btnHeight, globals.style2, () {
                    operClicked('÷');
                  }, '÷'),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  globals.uiButton(btnHeight, globals.style2, () {
                    constants('π');
                  }, 'π'),
                  globals.uiButton(btnHeight, globals.style2, changeSign, '±'),
                  globals.uiButton(btnHeight, globals.style3, () {
                    numClicked('0');
                  }, '0'),
                  globals.uiButton(btnHeight, globals.style2, () {
                    numClicked('.');
                  }, '.'),
                  globals.uiButton(btnHeight, globals.style1, () {
                    calculate();
                    if (prevNum.isNotEmpty && shouldClear) {
                      saveHistory(globals.lastCalc);
                    }
                  }, '='),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
