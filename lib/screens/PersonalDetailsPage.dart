import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class UserDetailsScreen extends StatefulWidget {
  @override
  _UserDetailsScreenState createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  final TextEditingController weightController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController futureWeightController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController medicalHistoryController = TextEditingController();
  String gender = 'Male';

  Future<void> addOrUpdatePersonalDetails(
      String userId,
      String weight,
      String height,
      String futureWeight,
      String gender,
      String age,
      String medicalHistory) async {
    try {
      FirebaseFirestore db = FirebaseFirestore.instance;
      await db.collection("Personal_Details").doc(userId).set({
        "Height": height,
        "Weight": weight,
        "FutureWeight": futureWeight,
        "Gender": gender,
        "Age": age,
        "Medical_History": medicalHistory
      });
      print("Personal details added or updated successfully");
    } catch (e) {
      print("Error writing document: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    String userId = "12345";
    return Scaffold(
      appBar: AppBar(
        title: Text('Enter Your Details'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Lottie.asset('assets/chef.json', width: 200, height: 200),
              SizedBox(height: 30),
              Text(
                'Please enter your details:',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              TextField(
                controller: weightController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Weight (kg)',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: heightController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Height (cm)',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: futureWeightController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Preferred Future Weight (kg)',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: ageController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Age',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Gender',
                style: TextStyle(fontSize: 16),
              ),
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: Text('Male'),
                      leading: Radio(
                        value: 'Male',
                        groupValue: gender,
                        onChanged: (String? value) {
                          setState(() {
                            gender = value!;
                          });
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      title: Text('Female'),
                      leading: Radio(
                        value: 'Female',
                        groupValue: gender,
                        onChanged: (String? value) {
                          setState(() {
                            gender = value!;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              TextField(
                controller: medicalHistoryController,
                keyboardType: TextInputType.multiline,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Medical History',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    String weight = weightController.text;
                    String height = heightController.text;
                    String futureWeight = futureWeightController.text;
                    String age = ageController.text;
                    String medicalHistory = medicalHistoryController.text;

                    if (weight.isEmpty || height.isEmpty || futureWeight.isEmpty || age.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Please fill in all mandatory fields'),
                        ),
                      );
                    } else {
                      addOrUpdatePersonalDetails(userId, weight, height, futureWeight, gender, age, medicalHistory);

                      Navigator.pushNamed(
                        context,
                        '/Plan',
                        arguments: {
                          'UserId': userId,
                          'Weight': weight,
                          'Height': height,
                          'FutureWeight': futureWeight,
                          'Gender': gender,
                          'Age': age,
                          'MedicalHistory': medicalHistory,
                        },
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Save Details',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
