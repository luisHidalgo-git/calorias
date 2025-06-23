import 'package:flutter/material.dart';

void main() {
  runApp(CaloriasApp());
}

class CaloriasApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Contador de Calorías',
      theme: ThemeData.dark(),
      home: CaloriasHomePage(),
    );
  }
}

class CaloriasHomePage extends StatefulWidget {
  @override
  _CaloriasHomePageState createState() => _CaloriasHomePageState();
}

class _CaloriasHomePageState extends State<CaloriasHomePage> {
  int pasos = 0;
  double calorias = 0.0;

  void _incrementarPasos() {
    setState(() {
      pasos++;
      calorias = pasos * 0.04; // Aproximado: 0.04 kcal por paso
    });
  }

  void _reiniciar() {
    setState(() {
      pasos = 0;
      calorias = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Pasos: $pasos', style: TextStyle(fontSize: 20)),
            Text(
              'Calorías quemadas: ${calorias.toStringAsFixed(2)} kcal',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: _incrementarPasos,
              child: Text('+1 Paso'),
            ),
            ElevatedButton(onPressed: _reiniciar, child: Text('Reiniciar')),
          ],
        ),
      ),
    );
  }
}
