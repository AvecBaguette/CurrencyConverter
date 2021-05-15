import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

void main() {
  runApp(new MaterialApp(
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _controller = TextEditingController();

  List<String> currencies;
  String fromCurrency = "USD";
  String toCurrency = "RON";
  String result;

  @override
  void initState() {
    super.initState();
    loadCurrencies();
  }

  //it tells my app that this is gonna be called in the future and not immediately
  Future<String> loadCurrencies() async {
    String uri = "https://api.openrates.io/latest?base=RON";
    var response =
        await http.get(Uri.parse(uri), headers: {"Accept": "application/json"});
    var responseBody = json.decode(response.body);
    Map currenciesMap = responseBody["rates"];
    currencies = currenciesMap.keys.toList();
    setState(() {});
    return "Success";
  }

  Future<String> _doConversion() async {
    String uri =
        "https://api.openrates.io/latest?base=$fromCurrency&symbols=$toCurrency";
    var response =
        await http.get(Uri.parse(uri), headers: {"Accept": "application/json"});
    var responseBody = json.decode(response.body);
    setState(() {
      result =
          (double.parse(_controller.text) * responseBody["rates"][toCurrency])
              .toStringAsFixed(2);
    });
    return "Success";
  }

  _onFromChanged(String value) {
    setState(() {
      fromCurrency = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Valoare Converter"),
      ),
      body: currencies == null
          ? Center(child: CircularProgressIndicator())
          : Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Image.asset('assets/images/Valuare.jpg'),
                Container(
                  height: MediaQuery.of(context).size.height / 2,
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      elevation: 5.0,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          ListTile(
                            title: TextField(
                              controller: _controller,
                              style: TextStyle(
                                  fontSize: 30.0, color: Colors.black),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'(^\d+\.?\d*)'))
                              ],
                              decoration: InputDecoration(
                                hintText: "Enter a number",
                              ),
                            ),
                            trailing: _myDropDownButton(fromCurrency),
                          ),
                          IconButton(
                            iconSize: 150,
                            icon: Image.asset(
                                'assets/images/Valuare_converter.png'),
                            onPressed: _doConversion,
                          ),
                          ListTile(
                            title: Chip(
                              labelStyle: TextStyle(
                                  fontSize: 20.0, color: Colors.black),
                              padding: EdgeInsets.all(15.0),
                              label: result != null
                                  ? Text(
                                      result + " RON",
                                    )
                                  : Text(""),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _myDropDownButton(String currencyCategory) {
    return DropdownButton(
      //UI loads before the currencies so there's that error "map called on null"
      value: currencyCategory,
      items: currencies
          .map((String value) => DropdownMenuItem(
                value: value,
                child: Row(
                  children: <Widget>[
                    Text(value),
                  ],
                ),
              ))
          .toList(),
      onChanged: (String value) {
        _onFromChanged(value);
      },
    );
  }
}
