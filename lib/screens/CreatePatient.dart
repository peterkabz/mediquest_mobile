import 'package:edge_alert/edge_alert.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:loading_dialog/loading_dialog.dart';
import 'package:mediquest_mobile/managers/QuestionnaireManager.dart';
import 'package:mediquest_mobile/models/Patient.dart';
import 'package:mediquest_mobile/models/Questionnaire.dart';

// so we're create a normal startup of a flutter application here
// so in our MyHomePage is where we're going to be working

class CreatePatient extends StatefulWidget {
  Questionnaire questionnnaire;

  CreatePatient(this.questionnnaire);

  @override
  _CreatePatientState createState() => _CreatePatientState();
}

class _CreatePatientState extends State<CreatePatient> {
  // So all this four controller's is for the textfield we're creating
  final _formKey = new GlobalKey<FormState>();
  bool hidePass = true;
  String _initials;

  String _sex;
  int age;

  _CreatePatientState(); // this is a boolean called hidePass we're going to use it for show and hide password
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Card(
          elevation: 2,
          shadowColor: Colors.grey,
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Center(
                      child: Text(
                        'Patient Registration',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        children: <Widget>[
                          // textfield for the name session and so on
                          SizedBox(height: 10),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'initials',
                            ),
                            validator: (value) => value.isEmpty
                                ? 'Initials can\'t be empty'
                                : null,
                            onSaved: (value) => _initials = value.trim(),
                          ),
                          SizedBox(height: 10),
                          //sex
                          Container(
                            child: FormBuilderRadioGroup(
                              options: [
                                FormBuilderFieldOption(value: "Male"),
                                FormBuilderFieldOption(value: "Female"),
                              ],
                              initialValue: "",
                              decoration: InputDecoration(),
                              onSaved: (value) {
                                _sex = value;
                              },
                              validator: (value) {
                                return value.toString().isEmpty
                                    ? "Sex can\'t be null"
                                    : null;
                              },
                            ),
                          ),
                          SizedBox(height: 10),
                          //age
                          TextFormField(
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Age',
                            ),
                            onSaved: (value) => age = int.parse(value),
                            validator: (value) =>
                                value.isEmpty ? 'Age can\'t be empty' : null,
                          ),
                          SizedBox(height: 10),

                          //DOB

                          SizedBox(height: 10),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: MaterialButton(
                                  color: Theme.of(context).accentColor,
                                  child: const Text(
                                    'Submit',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  onPressed: () async {
                                    if (_formKey.currentState.validate()) {
                                      _formKey.currentState.save();
                                      print(_formKey.currentState);
                                      Patient patient = Patient(
                                        updatedAt: DateTime.now().toString(),
                                        sex: _sex,
                                        questionnaireId:
                                            widget.questionnnaire.id,
                                        age: age,
                                        createdAt: DateTime.now().toString(),
                                        initials: _initials,
                                        institutionId:
                                            widget.questionnnaire.institutionId,
                                      );

                                      Patient newPatient =
                                          await addPatient(patient, context);
                                      print(newPatient?.toJson());
                                      Navigator.of(context).pop();
                                    } else {
                                      print(_formKey.currentState);
                                      print('validation failed');
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: OutlineButton(
                                  color: Theme.of(context).accentColor,
                                  child: Text(
                                    'Reset',
                                    style: TextStyle(
                                        color: Theme.of(context).accentColor),
                                  ),
                                  onPressed: () {
                                    _formKey.currentState.reset();
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }


  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }
}

Future<Patient> addPatient(Patient patientData, BuildContext context) async {
  LoadingDialog loadingDialog =
      LoadingDialog(buildContext: context, loadingMessage: "Creating...");
  loadingDialog.show();

  Patient patient = await QuestionnaireManager().addPatient(patientData);
  loadingDialog.hide();
  if (patient != null) {
    EdgeAlert.show(context,
        title: 'Success',
        description: 'Patient Created.',
        icon: Icons.check_circle_outline,
        backgroundColor: Colors.green,
        gravity: EdgeAlert.TOP);
  } else {
    {
      EdgeAlert.show(context,
          title: 'Failure',
          description: 'Failed to create patient.',
          icon: Icons.dangerous,
          backgroundColor: Colors.red,
          gravity: EdgeAlert.TOP);
    }
  }
  return patient;
}
