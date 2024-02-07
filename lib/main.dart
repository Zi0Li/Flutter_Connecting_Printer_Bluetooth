import 'dart:async';
import 'package:intl/intl.dart';
import 'package:bluetooth_thermal_printer/bluetooth_thermal_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/material.dart';

void main(List<String> args) {
  runApp(
    MaterialApp(
      home: MyApp(),
      debugShowCheckedModeBanner: false,
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    this.getBluetooth();
  }

  bool isChecked = false; //CheckBox start

  bool connected = false; //conectado ao bluetooth
  bool bluetoothStart = false; //bluetooth ligado
  bool errorBluetoothConnected = false; //erro ao conectar no bluetooth
  bool loadBluetooth = false; //carregando/conectando ao bluetooth
  List availableBluetoothDevices = [];
  String bluetoothConnectedName = '';
  String bluetoothConnectedMac = '';

  Future<void> getBluetooth() async {
    setState(() => loadBluetooth = true);
    final List? bluetooths = await BluetoothThermalPrinter.getBluetooths;
    print("Print $bluetooths");
    if (bluetooths!.isEmpty) {
      setState(() {
        bluetoothStart = false;
      });
    } else {
      setState(() {
        bluetoothStart = true;
        availableBluetoothDevices = bluetooths;
      });
    }
    setState(() => loadBluetooth = false);
  }

  Future<void> setConnect(String mac, String name) async {
    setState(() => loadBluetooth = true);
    final String? result = await BluetoothThermalPrinter.connect(mac);
    print("state conneected $result");
    if (result == "true") {
      setState(() {
        connected = true;
        bluetoothConnectedName = name;
      });
    } else {
      setState(() {
        errorBluetoothConnected = true;
        Timer(Duration(seconds: 5), () {
          setState(() {
            errorBluetoothConnected = false;
          });
        });
      });
    }
    setState(() => loadBluetooth = false);
  }

  Future<void> printTicket() async {
    String? isConnected = await BluetoothThermalPrinter.connectionStatus;
    if (isConnected == "true") {
      List<int> bytes = await getTicket();
      final result = await BluetoothThermalPrinter.writeBytes(bytes);
      print("Print $result");
    } else {
      //Hadnle Not Connected Senario
    }
  }

  Future<List<int>> getTicket() async {
    DateTime date = DateTime.now();

    String data = DateFormat("dd/MM/yyyy").format(date).toString();
    String horas = DateFormat("hh:mm").format(date).toString();

    List<int> bytes = [];
    CapabilityProfile profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);

    bytes += generator.text("Nome da empresa",
        styles: PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
        linesAfter: 1);

    bytes += generator.text('- - - - - - - - - - - - - - - -',
        styles: PosStyles(align: PosAlign.center, bold: true));

    bytes += generator.text('Agradecemos pela preferencia!',
        styles: PosStyles(align: PosAlign.center, bold: true));

    bytes += generator.text('- - - - - - - - - - - - - - - -',
        styles: PosStyles(align: PosAlign.center, bold: true));

    bytes += generator.text("Data: $data",
        styles: PosStyles(align: PosAlign.center), linesAfter: 1);

    bytes += generator.text("Horas: $horas",
        styles: PosStyles(align: PosAlign.center), linesAfter: 1);

    bytes += generator.text('Obs: Junte 5 tickets para ganhar descontos!',
        styles: PosStyles(align: PosAlign.center, bold: false));
    bytes += generator.cut();
    return bytes;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Impressora Bluetooth'),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(width: 1, color: Colors.black12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Pesquisar bluetooth",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        RichText(
                          text: TextSpan(
                            text: 'Status: ',
                            style: TextStyle(color: Colors.black, fontSize: 18),
                            children: [
                              (loadBluetooth)
                                  ? TextSpan(
                                      text: 'carregando',
                                      style: TextStyle(
                                        color: Colors.amber,
                                      ),
                                    )
                                  : (connected)
                                      ? TextSpan(
                                          text: 'conectado',
                                          style: TextStyle(
                                            color: Colors.green,
                                          ),
                                        )
                                      : TextSpan(
                                          text: 'desconectado',
                                          style: TextStyle(
                                            color: Colors.red,
                                          ),
                                        ),
                            ],
                          ),
                        ),
                        (connected)
                            ? Row(
                                children: [
                                  Text(
                                    'Conectar automaticamente',
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 18),
                                  ),
                                  Spacer(),
                                  Checkbox(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    checkColor: Colors.white,
                                    activeColor:
                                        Color.fromRGBO(104, 116, 232, 1),
                                    value: isChecked,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        isChecked = value!;
                                      });
                                    },
                                  ),
                                ],
                              )
                            : Container(),
                        Row(
                          children: [
                            TextButton.icon(
                              onPressed: () {
                                this.getBluetooth();
                              },
                              icon: Icon(Icons.replay_outlined,
                                  color: Colors.white),
                              label: Text(
                                "Recarregar",
                                style: TextStyle(color: Colors.white),
                              ),
                              style: TextButton.styleFrom(
                                backgroundColor:
                                    Color.fromRGBO(104, 116, 232, 1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            Spacer(),
                            TextButton.icon(
                              onPressed: connected ? this.printTicket : null,
                              icon: connected
                                  ? Icon(
                                      Icons.print_outlined,
                                      color: Colors.white,
                                    )
                                  : Icon(
                                      Icons.print_disabled_outlined,
                                      color: Colors.white,
                                    ),
                              label: Text(
                                "Imprimir teste",
                                style: TextStyle(color: Colors.white),
                              ),
                              style: TextButton.styleFrom(
                                backgroundColor:
                                    Color.fromRGBO(104, 116, 232, 1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                disabledBackgroundColor: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 6,
                ),
                (errorBluetoothConnected)
                    ? Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 24,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          RichText(
                            text: TextSpan(
                              text: 'ERRO: ',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                  text: 'Falha ao conectar no bluetooth',
                                  style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 14,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      )
                    : Container(),
                SizedBox(
                  height: 6,
                ),
                (connected)
                    ? Container(
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Conectado ao bluetooth: ',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                bluetoothConnectedName,
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      )
                    : (bluetoothStart)
                        ? Container(
                            height: 500,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    width: 1, color: Colors.black26)),
                            child: ListView.builder(
                              itemCount: availableBluetoothDevices.length > 0
                                  ? availableBluetoothDevices.length
                                  : 0,
                              itemBuilder: (context, index) {
                                List<String> bluetooth =
                                    availableBluetoothDevices[index].split('#');

                                return ListTile(
                                  onTap: () {
                                    String select =
                                        availableBluetoothDevices[index];
                                    List list = select.split("#");
                                    String mac = list[1];
                                    String name = list[0];
                                    this.setConnect(mac, name);
                                  },
                                  title: Text('${bluetooth[0]}'),
                                  subtitle: Text("${bluetooth[1]}"),
                                );
                              },
                            ),
                          )
                        : Container(
                            child: Padding(
                              padding: EdgeInsets.all(8),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Ops...',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    'Parece que o bluetooth está desligado',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
