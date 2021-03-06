import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const request = "https://api.hgbrasil.com/finance?format=json&key=9e62397b";

void main() async {

  print(await getData());
  runApp(
      MaterialApp(
          home: Home(),
          theme: ThemeData(
            hintColor:Colors.amber,
            primaryColor: Colors.white,
          ),
      )
  );
}

Future<Map> getData() async {
  http.Response response = await http.get(request);
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  double dolar;
  double euro;
  double ibovespa;
  double nasdaq;
  double cac;
  double ibovespaVariation;

  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  void _realChanges(String text){
      double real = double.parse(text);
      dolarController.text = (real / dolar).toStringAsFixed(2);
      euroController.text = (real / euro).toStringAsFixed(2);
  }

  void _dolarChanges(String text){
    double dolar = double.parse(text);
    realController.text = (dolar * this.dolar).toStringAsFixed(2);
    euroController.text = (dolar * this.dolar / euro).toStringAsFixed(2);
  }

  void _euroChanges(String text){
    double euro = double.parse(text);
    realController.text = (euro * this.euro).toStringAsFixed(2);
    euroController.text = (euro * this.euro / dolar).toStringAsFixed(2);
  }

  void _resetFields() {
    setState(() {
      euroController.text = "";
      realController.text = "";
      dolarController.text = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar:  AppBar(
        title: Text("Conversor de Moedas"),
        backgroundColor: Colors.amber,
        centerTitle: true,
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: _resetFields)
        ],
      ),
      body: FutureBuilder<Map>(
        future: getData(),
        builder: (context, snapshot) {
          switch(snapshot.connectionState){
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Text('Carregando dados...',style: TextStyle(
                  color: Colors.amber,
                  fontSize: 25.0
                ), textAlign: TextAlign.center,
                ),
              );
              default:
                if(snapshot.hasError){
                  return Center(
                    child: Text('Erro ao carregar dados...',style: TextStyle(
                        color: Colors.amber,
                        fontSize: 25.0
                    ), textAlign: TextAlign.center,
                    ),
                  );

                } else {
                  dolar = snapshot.data['results']['currencies']['USD']['buy'];
                  euro = snapshot.data['results']['currencies']['EUR']['buy'];
                  ibovespa = snapshot.data['results']['stocks']['IBOVESPA']['points'];
                  ibovespaVariation = snapshot.data['results']['stocks']['IBOVESPA']['variation'];
                  nasdaq = snapshot.data['results']['stocks']['NASDAQ']['points'];

                  return 
                      SingleChildScrollView(
                        padding: EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Icon(Icons.monetization_on, size: 100.0, color: Colors.amber,),
                              buildTextField('Real', 'R\$', realController, _realChanges),
                              Divider(),
                              buildTextField('Dólar', 'US\$', dolarController, _dolarChanges),
                              Divider(),
                              buildTextField('Euro', 'Eur', euroController, _euroChanges ),
                              Divider(),
                              Text('Ibovespa: $ibovespa', style: TextStyle(color: Colors.blueAccent, fontSize: 20.0)),
                              Text('Ibovespa Hoje: $ibovespaVariation', style: TextStyle(color: Colors.blueAccent, fontSize: 20.0)),
                              Text('NASDAQ: $nasdaq', style: TextStyle(color: Colors.blueAccent, fontSize: 20.0)),

                            ],
                          ),            
                      );
            }
          }
        })
    );
  }
}

Widget buildTextField(String label, String prefix, TextEditingController contro, Function f){
    return TextField(
      onChanged: f,
      controller: contro,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.amber),
          border: OutlineInputBorder(),
          prefixText: prefix
      ),
      style: TextStyle(
          color: Colors.amber, fontSize: 25.0
      ),
    );
}