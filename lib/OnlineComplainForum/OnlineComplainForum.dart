import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:swat/OnlineComplainForum/common.dart';

class OnlineComplainForum extends StatefulWidget {
  const OnlineComplainForum({Key? key}) : super(key: key);

  @override
  State<OnlineComplainForum> createState() => _OnlineComplainForumState();
}

class _OnlineComplainForumState extends State<OnlineComplainForum> {
  String? selectedDistrict; // Initial selected district
// Initial selected district
  List<String> districts = [];

  String finalresult = "";
  Future<void> postData() async {
    try {
      final Map<String, dynamic> requestBody = {
        "name": name,
        "fathername": fathername,
        "cnic": cnic,
        "district": selectedDistrict,
        "taluka": _selectedTaluka,
        "contact": cellnumber,
        "nature_of_complaint": selectedcomplaintype,
        "other_descrpition": complaint,
      };

      final response = await http.post(
        Uri.parse("https://cms.swatagriculture.gos.pk/api/store-complain"),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        setState(() {
          finalresult = "Complain Registered Successful";
        });
      } else {
        setState(() {
          finalresult = "Failed to submit complaint";
        });
      }
    } catch (error) {
      setState(() {
        finalresult = "Failed to submit complaint";
      });
    }
  }

  List<String> Taluka = [];
  String hintTaluka = "Select Taluka";
  String hintdistricts = "Select Districts";
  String hintcomplaint = "Select Nature";
  String? _selectedTaluka;
  String? selectedcomplaintype;
  List<String> complaintype = [
    "De-Credit",
    "Eligible",
    "Ineligible",
    "Underage Case",
    "Error 938",
    "Error 920",
    "Error 933 - District Not Match",
    "Error 368 - CNIC cannot be verified",
    "Death Case",
    "Finger Print Issue",
    "Expired CNIC",
    "Wrong CNIC",
    "Total"
  ];

  Future opendialogbox() => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: SizedBox(
            height: 80,
            width: 100,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    finalresult,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    height: 30,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          nameController.clear();
                          fatherNameController.clear();
                          cnicController.clear();
                          contactNoController.clear();
                          complaintController.clear();
                          selectedDistrict = null;
                          _selectedTaluka = null;
                          selectedcomplaintype = null;
                          Taluka.clear();
                          Navigator.of(context).pop();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(5.0), // Set border radius
                        ),
                      ),
                      child: const Text(
                        "Close",
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                            color: Colors.white,
                            letterSpacing: 1,
                            fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  Future<void> fetchDistrict() async {
    try {
      final response = await http.get(
          Uri.parse("https://cms.swatagriculture.gos.pk/api/get-districts"));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        FetchAPI Districtapi = FetchAPI.fromJson(data);

        if (Districtapi.success == true) {
          List<String> unsortedData = Districtapi.data ?? [];
          unsortedData.sort(); // Sort the data

          setState(() {
            districts = unsortedData;
          });
        }
      }
    } catch (e) {
      setState(() {
        hintdistricts = "Failed to load data";
      });
      throw Exception('Failed to load data \n$e');
    }
  }

  Future<void> fetchTaluka(String selectedDistrict) async {
    try {
      final response = await http.get(Uri.parse(
          "https://cms.swatagriculture.gos.pk/api/get-talukas?district=$selectedDistrict"));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        FetchAPI api = FetchAPI.fromJson(data);

        if (api.success == true) {
          List<String> unsortedData = api.data ?? [];
          unsortedData.sort(); // Sort the data

          setState(() {
            Taluka = unsortedData;
            _selectedTaluka =
                Taluka.isNotEmpty ? Taluka.first : null; // Change this line
          });
        }
      }
    } catch (e) {
      setState(() {
        hintTaluka = "Failed to load data";
      });
      throw Exception('Failed to load data\n$e');
    }
  }

  bool isSubmitButtonEnabled() {
// Check if all text fields are filled
    if (_selectedTaluka?.isNotEmpty == true &&
        selectedcomplaintype?.isNotEmpty == true) {
      return nameController.text.isNotEmpty &&
          fatherNameController.text.isNotEmpty &&
          cnicController.text.length == 15 &&
          contactNoController.text.length == 12 &&
          complaintController.text.isNotEmpty;
    }

// Default return if selectedTaluka is null or empty
    return false;
  }

  bool isCnic = false;
  bool RedCnic = false;
  bool RedNO = false;

  var name;
  var fathername;
  var cnic;
  var cellnumber;
  var complaint;

  @override
  void initState() {
    super.initState();
    fetchDistrict();
    nameController.addListener(() {
      setState(() {
        name = nameController.text;
      });
    });
    fatherNameController.addListener(() {
      setState(() {
        fathername = fatherNameController.text;
      });
    });
    cnicController.addListener(() {
      setState(() {
        cnic = cnicController.text;
        if (cnicController.text.length < 15 && cnicController.text.length > 2) {
          RedCnic = true;
        } else {
          RedCnic = false;
        }
      });
    });
    contactNoController.addListener(() {
      setState(() {
        cellnumber = contactNoController.text;

        if (contactNoController.text.length < 12 &&
            contactNoController.text.length > 2) {
          RedNO = true;
        } else {
          RedNO = false;
        }
      });
    });
    complaintController.addListener(() {
      setState(() {
        complaint = complaintController.text;
      });
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    fatherNameController.dispose();
    cnicController.dispose();
    contactNoController.dispose();
    super.dispose();
  }

  final TextEditingController nameController = TextEditingController();
  final TextEditingController fatherNameController = TextEditingController();
  final TextEditingController cnicController = TextEditingController();
  final TextEditingController contactNoController = TextEditingController();
  final TextEditingController complaintController = TextEditingController();

  List<String> talukas = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(
                height: 40,
              ),
              SizedBox(
                height: 100,
                child: Image.asset(
                  "assets/images/logo.jpeg",
                  fit: BoxFit.fill,
                  filterQuality: FilterQuality.high,
                ),
              ),
              const SizedBox(
                height: 13,
              ),
              const Text(
                "Sindh Water & Agriculture\nTransformation Project",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  height: 1.1,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(
                height: 4,
              ),
              const Text(
                "Online Complaint Form",
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(
                height: 18,
              ),
              T_T(
                heading: 'Name of Complainant',
                hint_text: 'Enter your name',
                SecondWidget: false,
                controller: nameController,
                maxlength: 50,
                maxlines: 1,
                isCnic: false,
                needFormatter: false,
                keyboard_type: TextInputType.name,
              ),
              const SizedBox(
                height: 7,
              ),
              T_T(
                heading: 'Father/Husband of Complainant',
                hint_text: 'Enter your Father Name/Husband Name',
                SecondWidget: false,
                controller: fatherNameController,
                maxlength: 30,
                maxlines: 1,
                isCnic: false,
                needFormatter: false,
                keyboard_type: TextInputType.name,
              ),
              const SizedBox(
                height: 7,
              ),
              T_T(
                heading: 'CNIC No',
                hint_text: '41306-xxxxxxx-x',
                SecondWidget: true,
                controller: cnicController,
                maxlength: 15,
                maxlines: 1,
                isCnic: true,
                needFormatter: true,
                keyboard_type: TextInputType.number,
              ),
              TextFormField(
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  inputFormater(!isCnic),
                ],
                minLines: 1,
                maxLines: 1,
                maxLength: 15, // Set the maximum length
                maxLengthEnforcement: MaxLengthEnforcement.enforced,
                buildCounter: (BuildContext context,
                    {required int currentLength,
                    required bool isFocused,
                    required int? maxLength}) {
                  return const SizedBox();
                },
                controller: cnicController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(5)),
                    borderSide: BorderSide(
                        color: RedCnic
                            ? Colors.red
                            : Colors.blue), // Border color when focused
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(5)),
                    borderSide: BorderSide(
                        color: RedCnic
                            ? Colors.red
                            : Colors.grey), // Border color when not focused
                  ),
                  hintText: "41306-xxxxxxx-x",
                ),
              ),
              const SizedBox(
                height: 7,
              ),
              T_T(
                heading: 'District',
                hint_text: hintdistricts,
                SecondWidget: true,
                controller: nameController,
                maxlength: 0,
                maxlines: 1,
                isCnic: false,
                needFormatter: false,
              ),
              DropdownButtonFormField<String>(
                hint: Text(hintdistricts),
                value: selectedDistrict,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedDistrict = newValue!;
                    fetchTaluka("$selectedDistrict") ?? [];
                  });
                },
                items: districts.map((String district) {
                  return DropdownMenuItem<String>(
                    value: district,
                    child: Text(district,
                        style: const TextStyle(fontWeight: FontWeight.w400)),
                  );
                }).toList(),
                decoration: const InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.blue), // Border color when focused
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.grey), // Border color when not focused
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              T_T(
                heading: 'Taluka',
                hint_text: hintTaluka,
                SecondWidget: true,
                controller: nameController,
                maxlength: 0,
                maxlines: 1,
                isCnic: false,
                needFormatter: false,
              ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.blue,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
                hint: Text(hintTaluka),
                value: _selectedTaluka,
                items: Taluka.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value,
                        style: const TextStyle(fontWeight: FontWeight.w400)),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedTaluka = newValue;
                  });
                },
              ),
              const SizedBox(
                height: 10,
              ),
              T_T(
                heading: 'Contact No',
                hint_text: '0312-11xxxxx',
                SecondWidget: true,
                controller: contactNoController,
                maxlength: 12,
                maxlines: 1,
                isCnic: false,
                needFormatter: true,
                keyboard_type: TextInputType.number,
              ),
              TextFormField(
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  inputFormater(isCnic),
                ],
                minLines: 1,
                maxLines: 1,
                maxLength: 12, // Set the maximum length
                maxLengthEnforcement: MaxLengthEnforcement.enforced,
                buildCounter: (BuildContext context,
                    {required int currentLength,
                    required bool isFocused,
                    required int? maxLength}) {
                  return const SizedBox();
                },
                controller: contactNoController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(5)),
                    borderSide: BorderSide(
                        color: RedNO
                            ? Colors.red
                            : Colors.blue), // Border color when focused
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(5)),
                    borderSide: BorderSide(
                        color: RedNO
                            ? Colors.red
                            : Colors.grey), // Border color when not focused
                  ),
                  hintText: "0312-11xxxxx",
                ),
              ),
              const SizedBox(
                height: 7,
              ),
              T_T(
                heading: 'Nature of Complaint',
                hint_text: hintTaluka,
                SecondWidget: true,
                controller: nameController,
                maxlength: 0,
                maxlines: 1,
                isCnic: false,
                needFormatter: false,
              ),
              DropdownButtonFormField<String>(
                hint: Text(hintcomplaint),
                value: selectedcomplaintype,
                onChanged: (value) {
                  setState(() {
                    selectedcomplaintype = value!;
                  });
                },
                items: complaintype.map((complaintype) {
                  return DropdownMenuItem<String>(
                    value: complaintype,
                    child: Text(complaintype,
                        style: const TextStyle(fontWeight: FontWeight.w400)),
                  );
                }).toList(),
                decoration: const InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.blue), // Border color when focused
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.grey), // Border color when not focused
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              T_T(
                heading: 'Other Description',
                hint_text: 'Enter Descrption',
                SecondWidget: false,
                controller: complaintController,
                maxlength: 500,
                maxlines: 5,
                isCnic: false,
                needFormatter: false,
              ),
              const SizedBox(
                height: 7,
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isSubmitButtonEnabled()
                      ? () async {
                          await postData();
                          setState(() {
                            opendialogbox();
                          });
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(5.0), // Set border radius
                    ),
                  ),
                  child: const Text(
                    "Register",
                    style: TextStyle(color: Colors.white, letterSpacing: 1),
                  ),
                ),
              ),
              const SizedBox(
                height: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FetchAPI {
  bool? success;
  List<String>? data;

  FetchAPI({this.success, this.data});

  FetchAPI.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['success'] = this.success;
    data['data'] = this.data;
    return data;
  }
}
