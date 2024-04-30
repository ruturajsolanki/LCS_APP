import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LCSApp(),
    );
  }
}

class LCSApp extends StatefulWidget {
  @override
  _LCSAppState createState() => _LCSAppState();
}

class _LCSAppState extends State<LCSApp> {
  late TextEditingController string1Controller;
  late TextEditingController string2Controller;
  bool isSubmitted = false;
  bool showButton = true;
  int selectedI = 0, selectedJ = 0;
  String string1 = "";
  String string2 = "";
  List<List<int>> lcsTable = [];
  List<List<int>> lcsSymboleTable = [];
  String lcs = "";
  ScrollController horizontalController = ScrollController();
  ScrollController verticalController = ScrollController();

  @override
  void initState() {
    super.initState();
    string1Controller = TextEditingController();
    string2Controller = TextEditingController();
  }

  @override
  void dispose() {
    string1Controller.dispose();
    string2Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isSubmitted
        ? buildResult()
        : Scaffold(
            appBar: AppBar(
              title: Text('LCS Algorithm'),
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: string1Controller,
                    decoration: InputDecoration(labelText: 'String 1'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: string2Controller,
                    decoration: InputDecoration(labelText: 'String 2'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: _calculateLCS,
                    child: Text('Calculate LCS'),
                  ),
                ),
              ],
            ),
          );
  }

  Scaffold buildResult() {
    int m = string1.length;
    int n = string2.length;

    List<DataColumn> columns = [];
    columns.add(DataColumn(label: Text('')));
    columns.add(DataColumn(label: Text('')));

    for (int j = 0; j < n; j++) {
      columns.add(DataColumn(label: Text(string2[j])));
    }

    List<DataRow> rows = [];
    for (int i = 0; i <= m; i++) {
      List<DataCell> cells = [];
      // if (i > 0) {
      //   cells.add(DataCell(Text(string1[i - 1])));
      // } else {
      //   cells.add(DataCell(Text('')));
      // }
      for (int j = -1; j <= n; j++) {
        if (j == -1) {
          if (i > 0) {
            cells.add(
              DataCell(
                Text(
                  string1[i - 1],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          } else {
            cells.add(DataCell(Text("")));
          }
        } else {
          cells.add(
            DataCell(
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    lcsSymboleTable.length <= i ? "" : lcsSymboleTable[0].length <= j ? "" : lcsSymboleTable[i][j] == 1 ? "↑" : lcsSymboleTable[i][j] == 2 ? "↖" : lcsSymboleTable[i][j] == 3 ? "←" : "",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                      "${lcsTable.length <= i ? "" : lcsTable[0].length <= j ? "" : lcsTable[i][j]}"),
                ],
              ),
              onTap: () {
                setState(() {
                  selectedI = i;
                  selectedJ = j;
                });
              },
            ),
          );
        }
      }
      rows.add(DataRow(cells: cells));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('LCS Algorithm Result'),
      ),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 3,
            child: SingleChildScrollView(
              controller: verticalController,
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                controller: horizontalController,
                scrollDirection: Axis.horizontal,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Longest Common Subsequence: $lcs',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: DataTable(
                        columns: columns,
                        rows: rows,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          if (showButton)
                            ElevatedButton(
                              onPressed: () {
                                if (i == 0 && j == 0) {
                                  lcs = _findLCS(lcsTable, string1, string2);
                                  showButton = false;
                                  setState(() {});
                                } else {
                                  _createLcsTable(string1, string2);
                                }
                              },
                              child: const Text("Next"),
                            ),
                          SizedBox(
                            width: 100,
                          ),
                          ElevatedButton(
                            onPressed: () {
                              isSubmitted = false;
                              showButton = true;
                              lcs = "";
                              string1Controller.text = "";
                              string2Controller.text = "";
                              lcsTable = [];
                              lcsSymboleTable = [];
                              i = j = 1;
                              setState(() {});
                            },
                            child: const Text("Reset"),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            height: double.infinity,
            width: 1.5,
            color: Colors.black,
          ),
          Expanded(
            flex: 3,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Selected Cell (i = $selectedI , j = $selectedJ)",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
                if (selectedI > 0 && selectedJ > 0)
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "Cell Value",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                if (selectedI > 0 && selectedJ > 0)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      " = if(str1[$selectedI] == str2[$selectedJ]) then (table[$selectedI-1][$selectedJ-1] + 1) else max(table[$selectedI-1][$selectedJ], table[$selectedI][$selectedJ-1])",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),
                if (selectedI > 0 && selectedJ > 0)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      " = if(${string1[selectedI - 1]} == ${string2[selectedJ - 1]}) then (table[${selectedI - 1}][${selectedJ - 1}] + 1) else max(table[${selectedI - 1}][$selectedJ], table[$selectedI][${selectedJ - 1}])",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),
                if (selectedI > 0 && selectedJ > 0)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      string1[selectedI - 1] == string2[selectedJ - 1]
                          ? "Here string1[$selectedI] == string2[$selectedJ] therefor table[${selectedI - 1}][${selectedJ - 1}] + 1"
                          : "Here string1[$selectedI] != string2[$selectedJ] therefor max(table[${selectedI - 1}][$selectedJ], table[$selectedI][${selectedJ - 1}]",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),
                if (selectedI > 0 && selectedJ > 0)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      string1[selectedI - 1] == string2[selectedJ - 1]
                          ? "= ${lcsTable[selectedI - 1][selectedJ - 1]} + 1 = ${lcsTable[selectedI - 1][selectedJ - 1] + 1}"
                          : "= max(${lcsTable[selectedI - 1][selectedJ]}, ${lcsTable[selectedI][selectedJ - 1]}) = ${max(lcsTable[selectedI - 1][selectedJ], lcsTable[selectedI][selectedJ - 1])}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _calculateLCS() {
    string1 = string1Controller.text;
    string2 = string2Controller.text;

    if (string1.isEmpty || string2.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Input Error'),
            content: Text('Please enter both strings.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }
    int m = string1.length;
    int n = string2.length;
    lcsTable = List.generate(m + 1, (i) => List<int>.filled(n + 1, 0));
    lcsSymboleTable = List.generate(m + 1, (i) => List<int>.filled(n + 1, 0));
    isSubmitted = true;
    setState(() {});
  }

  int i = 1;
  int j = 1;

  void _createLcsTable(String string1, String string2) {
    /*
    1:upper arrow
    2:cross arrow
    3:side arrow
    */
    isSubmitted = true;
    int m = string1.length;
    int n = string2.length;

    if (string1[i - 1] == string2[j - 1]) {
      lcsTable[i][j] = lcsTable[i - 1][j - 1] + 1;
      lcsSymboleTable[i][j] = 2;
    } else {
      lcsTable[i][j] = lcsTable[i - 1][j].compareTo(lcsTable[i][j - 1]) > 0
          ? lcsTable[i - 1][j]
          : lcsTable[i][j - 1];
      lcsSymboleTable[i][j] =
          lcsTable[i - 1][j].compareTo(lcsTable[i][j - 1]) > 0 ? 1 : 3;
    }
    if ((j + 1) <= n) {
      j++;
    } else {
      if ((i + 1) <= m) {
        i++;
        j = 1;
      } else {
        i = j = 0;
      }
    }
    setState(() {});
  }

  String _findLCS(List<List<int>> lcsTable, String string1, String string2) {
    int m = string1.length;
    int n = string2.length;

    int i = m;
    int j = n;
    StringBuffer lcs = StringBuffer();

    while (i > 0 && j > 0) {
      if (string1[i - 1] == string2[j - 1]) {
        lcs.write(string1[i - 1]);
        i--;
        j--;
      } else if (lcsTable[i - 1][j] > lcsTable[i][j - 1]) {
        i--;
      } else {
        j--;
      }
    }

    return lcs.toString().split('').reversed.join('');
  }
}
