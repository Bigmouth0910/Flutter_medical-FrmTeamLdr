import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxphoto/features/patient/bloc/patient_bloc.dart';
import 'package:rxphoto/features/patient/ui/widgets/list_element.dart';
import 'package:rxphoto/models/diagnosis.model.dart';
import 'package:rxphoto/models/medicalhistory.model.dart';
import 'package:rxphoto/models/patient.model.dart';
import 'package:rxphoto/models/treatment.model.dart';
import 'package:rxphoto/generated/l10n.dart';

class CustomSearchDelegate extends SearchDelegate<List<Patient>> {
  final String searchType;
  final List<Diagnosis> diagnosis;
  final List<Treatment> treatment;

  CustomSearchDelegate(this.searchType, this.diagnosis, this.treatment)
      : super(searchFieldLabel: S.current.searchBarHint);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = "";
          // query = '';
          // UPDATE BY EDGE
          // close(context, []);
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, []);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final patientBloc = context.watch<PatientBloc>();
    final totalPatients = patientBloc.state.patients;
    final totalMedicalHistory = patientBloc.state.totalmedicalHistory;
    List<Patient> searchResult =
        searchUsers(query, totalPatients, totalMedicalHistory);
    return SafeArea(
        child: ListView.builder(
      itemCount: searchResult.length,
      itemBuilder: (_, i) {
        var patientResult = searchResult[i];
        return ListElement(patient: patientResult);
      },
    ));
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return buildResults(context);
  }

  List<Patient> searchUsers(String query, List<Patient> totalPatients,
      List<MedicalHistory> totalMedicalHistory) {
    List<Patient> searchResult = [];
    if (query.isNotEmpty && query.length >= 1) {
      if (query.split(" ").length >= 1) {
        final searchQuery = query.replaceAll(" ", "").toLowerCase();
        for (var patient in totalPatients) {
          if ((patient.firstName! + patient.lastName!)
              .replaceAll(" ", "")
              .toLowerCase()
              .contains(searchQuery)) {
            if (!searchResult.contains(patient)) {
              searchResult.add(patient);
            }
          }
        }
        for (var patient in totalPatients) {
          if ((patient.medicalHistoryNo!)
              .replaceAll(" ", "")
              .toLowerCase()
              .contains(searchQuery)) {
            if (!searchResult.contains(patient)) {
              searchResult.add(patient);
            }
          }
        }
        final searchQuery1 = query.toLowerCase().trim().split(' ');
        var convertedDiagnosis = "";
        var convertedTreatment = "";

        searchQuery1.forEach((e) {
          for (var item in this.diagnosis) {
            if (item.tagName != null &&
                item.tagName!.toString().toLowerCase().contains(e)) {
              convertedDiagnosis += item.id.toString() + " ";
            }
            if (item.children != null) {
              for (var sub_item in item.children!) {
                if (sub_item.tagName != null &&
                    sub_item.tagName!.toString().toLowerCase().contains(e))
                  convertedDiagnosis += sub_item.id.toString() + " ";
              }
            }
          }
        });
        searchQuery1.forEach((e) {
          for (var item in this.treatment) {
            if (item.tagName != null &&
                item.tagName!.toString().toLowerCase().contains(e)) {
              convertedTreatment += item.id.toString() + " ";
            }
            if (item.children != null) {
              for (var sub_item in item.children!) {
                if (sub_item.tagName != null &&
                    sub_item.tagName!.toString().toLowerCase().contains(e))
                  convertedTreatment += sub_item.id.toString() + " ";
              }
            }
          }
        });
        for (var patient in totalPatients) {
          var fCnt = 0;
          if (convertedDiagnosis.trim().length != 0 &&
              convertedDiagnosis.trim().split(' ').length != 0) {
            convertedDiagnosis.trim().split(' ').forEach((element) {
              totalMedicalHistory
                  .where((element) =>
                      element.medicalHistoryNo == patient.medicalHistoryNo)
                  .toList()
                  .forEach((melement) {
                if (melement.diagnosis
                    .toLowerCase()
                    .contains(convertedDiagnosis.trim())) fCnt++;
              });
            });
          }
          if (convertedTreatment.trim().length != 0 &&
              convertedTreatment.trim().split(' ').length != 0) {
            convertedTreatment.trim().split(' ').forEach((element) {
              totalMedicalHistory
                  .where((element) =>
                      element.medicalHistoryNo == patient.medicalHistoryNo)
                  .toList()
                  .forEach((melement) {
                if (melement.treatment
                    .toLowerCase()
                    .contains(convertedTreatment.trim())) fCnt++;
              });
            });
          }
          totalMedicalHistory
              .where((element) =>
                  element.medicalHistoryNo == patient.medicalHistoryNo)
              .toList()
              .forEach((melement) {
            if (melement.notes!.toLowerCase().contains(query)) fCnt++;
          });
          if (fCnt != 0 && !searchResult.contains(patient)) {
            searchResult.add(patient);
          }
        }
      } else {
        searchResult = totalPatients;
      }
    } else {
      searchResult = totalPatients;
    }
    return searchResult;
  }
}
