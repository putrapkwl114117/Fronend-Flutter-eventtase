// import 'package:flutter/material.dart';

// class ManageEventsPage extends StatefulWidget {
//   const ManageEventsPage({super.key});

//   @override
//   _ManageEventsPageState createState() => _ManageEventsPageState();
// }

// class _ManageEventsPageState extends State<ManageEventsPage> {
//   final List<Map<String, dynamic>> events = [];

//   // Fungsi untuk membuka form pembuatan event oleh admin
//   void _openCreateEventForm() {
//     showDialog(
//       context: context,
//       builder: (context) => CreateEventForm(
//         onSave: (newEvent) {
//           setState(() {
//             events.add(newEvent); // Menambah event baru ke dalam list
//           });
//         },
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Kelola Event'),
//       ),
//       body: ListView.builder(
//         itemCount: events.length,
//         itemBuilder: (context, index) {
//           final event = events[index];
//           return Card(
//             margin: const EdgeInsets.all(8.0),
//             child: ListTile(
//               title: Text(event['title'] ?? 'Unnamed Event'),
//               subtitle: Text(event['description'] ?? ''),
//               trailing: IconButton(
//                 icon: const Icon(Icons.edit),
//                 onPressed: () {
//                   // Ketika event di edit, admin bisa mengedit event tersebut
//                   _openCreateEventForm();
//                 },
//               ),
//             ),
//           );
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _openCreateEventForm,
//         child: const Icon(Icons.add),
//       ),
//     );
//   }
// }

// // Form untuk admin membuat event
// class CreateEventForm extends StatefulWidget {
//   final Function(Map<String, dynamic>) onSave;

//   const CreateEventForm({super.key, required this.onSave});

//   @override
//   _CreateEventFormState createState() => _CreateEventFormState();
// }

// class _CreateEventFormState extends State<CreateEventForm> {
//   final TextEditingController _titleController = TextEditingController();
//   final TextEditingController _descriptionController = TextEditingController();
//   final List<Map<String, dynamic>> _formFields = []; // Menyimpan field dinamis

//   // Menambahkan input text
//   void _addTextField() {
//     final TextEditingController labelController = TextEditingController();
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Masukkan Label untuk Input Teks'),
//         content: TextField(
//           controller: labelController,
//           decoration: const InputDecoration(labelText: 'Label Input Teks'),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               setState(() {
//                 _formFields.add({
//                   'type': 'text',
//                   'label': labelController.text, // Menyimpan label input
//                 });
//               });
//               Navigator.of(context).pop();
//             },
//             child: const Text('Simpan'),
//           ),
//         ],
//       ),
//     );
//   }

//   // Menambahkan dropdown
//   void _addDropdownField() {
//     final TextEditingController labelController = TextEditingController();
//     final TextEditingController optionsController = TextEditingController();
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Masukkan Label dan Opsi Dropdown'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             TextField(
//               controller: labelController,
//               decoration: const InputDecoration(labelText: 'Label Dropdown'),
//             ),
//             TextField(
//               controller: optionsController,
//               decoration: const InputDecoration(labelText: 'Opsi (Pisahkan dengan koma)'),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               setState(() {
//                 _formFields.add({
//                   'type': 'dropdown',
//                   'label': labelController.text,
//                   'options': optionsController.text.split(','),
//                 });
//               });
//               Navigator.of(context).pop();
//             },
//             child: const Text('Simpan'),
//           ),
//         ],
//       ),
//     );
//   }

//   // Menambahkan radio button
//   void _addRadioButtonField() {
//     final TextEditingController labelController = TextEditingController();
//     final TextEditingController optionsController = TextEditingController();
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Masukkan Label dan Opsi Radio Button'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             TextField(
//               controller: labelController,
//               decoration: const InputDecoration(labelText: 'Label Radio Button'),
//             ),
//             TextField(
//               controller: optionsController,
//               decoration: const InputDecoration(labelText: 'Opsi (Pisahkan dengan koma)'),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               setState(() {
//                 _formFields.add({
//                   'type': 'radio',
//                   'label': labelController.text,
//                   'options': optionsController.text.split(','),
//                 });
//               });
//               Navigator.of(context).pop();
//             },
//             child: const Text('Simpan'),
//           ),
//         ],
//       ),
//     );
//   }

//   // Menyimpan form dan mengirimkan data kembali ke halaman utama
//   void _saveEvent() {
//     final newEvent = {
//       'title': _titleController.text,
//       'description': _descriptionController.text,
//       'fields': _formFields
//     };
//     widget.onSave(newEvent);
//     Navigator.of(context).pop();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       title: const Text('Buat Formulir Event'),
//       content: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             TextFormField(
//               controller: _titleController,
//               decoration: const InputDecoration(labelText: 'Judul Event'),
//             ),
//             TextFormField(
//               controller: _descriptionController,
//               decoration: const InputDecoration(labelText: 'Deskripsi Event'),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _addTextField,
//               child: const Text('Tambah Input Teks'),
//             ),
//             ElevatedButton(
//               onPressed: _addDropdownField,
//               child: const Text('Tambah Dropdown'),
//             ),
//             ElevatedButton(
//               onPressed: _addRadioButtonField,
//               child: const Text('Tambah Radio Button'),
//             ),
//             const SizedBox(height: 20),
//             // Render Dynamic Fields
//             ..._formFields.map((field) {
//               return Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Menampilkan Label dan Field Dinamis
//                   Text(field['label'], style: const TextStyle(fontWeight: FontWeight.bold)),
//                   if (field['type'] == 'text')
//                     TextFormField(
//                       decoration: InputDecoration(labelText: 'Masukkan ${field['label']}'),
//                     ),
//                   if (field['type'] == 'dropdown')
//                     DropdownButtonFormField<String>(
//                       value: field['options']?.first,
//                       onChanged: (newValue) {},
//                       items: (field['options'] as List<String>)
//                           .map<DropdownMenuItem<String>>((option) {
//                         return DropdownMenuItem<String>(
//                           value: option,
//                           child: Text(option),
//                         );
//                       }).toList(),
//                     ),
//                   if (field['type'] == 'radio')
//                     Column(
//                       children: (field['options'] as List<String>).map((option) {
//                         return Row(
//                           children: [
//                             Radio<String>(
//                               value: option,
//                               groupValue: field['options']?.first,
//                               onChanged: (newValue) {},
//                             ),
//                             Text(option),
//                           ],
//                         );
//                       }).toList(),
//                     ),
//                   const SizedBox(height: 10),
//                 ],
//               );
//             }),
//           ],
//         ),
//       ),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.of(context).pop(),
//           child: const Text('Batal'),
//         ),
//         ElevatedButton(
//           onPressed: _saveEvent,
//           child: const Text('Simpan Event'),
//         ),
//       ],
//     );
//   }
// }
