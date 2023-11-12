import 'dart:io';
import 'dart:typed_data';
import 'package:emergencyapp/DB/Database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergencias registradas'),
        centerTitle: true,
      ),
      body: const EmergencyList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddEmergencyScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class EmergencyList extends StatefulWidget {
  const EmergencyList({super.key});

  @override
  _EmergencyListState createState() => _EmergencyListState();
}

class _EmergencyListState extends State<EmergencyList> {
  final dbHelper = DatabaseHelper();
  List<Emergency> emergencies = [];

  @override
  void initState() {
    super.initState();
    _loadEmergencies();
  }

  Future<void> _loadEmergencies() async {
    final loadedEmergencies = await dbHelper.getEmergency();
    setState(() {
      emergencies = loadedEmergencies;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: emergencies.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: MemoryImage(emergencies[index].photo),
          ),
          title: Text(emergencies[index].title),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EmergencyDetailsScreen(emergency: emergencies[index]),
              ),
            );
          },
        );
      },
    );
  }
}

class AddEmergencyScreen extends StatefulWidget {
  const AddEmergencyScreen({super.key});

  @override
  _AddEmergencyScreenState createState() => _AddEmergencyScreenState();
}


class _AddEmergencyScreenState extends State<AddEmergencyScreen> {
  final dbHelper = DatabaseHelper();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  DateTime? selectedDate = DateTime.now();
  Uint8List? imageBytes;

  @override
  void initState() {
    super.initState();
    _loadImageAsset();
  }

  // Cargar imagen de los activos
  Future<void> _loadImageAsset() async {
    final ByteData data = await rootBundle.load('assets/img/emergency.jpg');
    setState(() {
      imageBytes = data.buffer.asUint8List();
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Emergencia'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Título'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                child: selectedDate != null
                    ? Text('Fecha seleccionada: ${selectedDate.toString()}')
                    : Container(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      selectedDate = pickedDate;
                    });
                  }
                },
                child: const Text('Seleccionar Fecha'),
              ),
            ),
            // Visualización de la imagen cargada de los activos
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: imageBytes != null ? Image.memory(imageBytes!) : Container(),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: _saveEmergency,
                child: const Text('Guardar Emergencia'),
              ),
            ),
          ],
        ),
      ),
    );
  }


  void _saveEmergency() async {
    if (titleController.text.isNotEmpty &&
        descriptionController.text.isNotEmpty && imageBytes != null) {
      if (selectedDate != null) {
        final emergency = Emergency(
          title: titleController.text,
          description: descriptionController.text,
          date: selectedDate != null ? selectedDate!.toIso8601String() : '',
          photo: imageBytes!,
        );
        await dbHelper.insertEmergency(emergency);
        Navigator.of(context).pop();
      } else {
        // Debes seleccionar una fecha
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Error'),
              content: const Text('Debes seleccionar una fecha.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Ok'),
                ),
              ], // TextButton
            ); // AlertDialog
          },
        );
      }
    }
  }
}

class EmergencyDetailsScreen extends StatelessWidget {
  final Emergency emergency;

  const EmergencyDetailsScreen({super.key, required this.emergency});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles de la Emergencia'),
      ), // AppBar
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.all(10),
                child: Text('Fecha: ${emergency.date}', style: const TextStyle(fontSize: 20)),
              ), // Container
              Container(
                margin: const EdgeInsets.all(10),
                child: Text('Título: ${emergency.title}', style: const TextStyle(fontSize: 20)),
              ), // Container
              Container(
                margin: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Descripción:', style: TextStyle(fontSize: 20)),
                    const SizedBox(height: 10),
                    Text(
                      emergency.description,
                      style: const TextStyle(fontSize: 16),
                    ), // Text
                  ],
                ), // Column
              ), // Container
              Container(
                margin: const EdgeInsets.all(15),
                child: Image.memory(emergency.photo),
              ), // Container
            ],
          ), // Column
        ), // Padding
      ), // Center
    ); // Scaffold
  }
}



