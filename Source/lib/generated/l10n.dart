// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Patients`
  String get PatientPage_patients {
    return Intl.message(
      'Patient list',
      name: 'PatientPage_patients',
      desc: '',
      args: [],
    );
  }

  /// `Add Patient`
  String get PatientPage_addPatient {
    return Intl.message(
      'Add Patient',
      name: 'PatientPage_addPatient',
      desc: '',
      args: [],
    );
  }

  String get PatientPage_addHistory {
    return Intl.message(
      'Visiting Records',
      name: 'PatientPage_addHistory',
      desc: '',
      args: [],
    );
  }

  /// `Add Profile Picture`
  String get PatientPage_addProfilePicture {
    return Intl.message(
      'Add Profile Picture',
      name: 'PatientPage_addProfilePicture',
      desc: '',
      args: [],
    );
  }

  /// `Name`
  String get PatientPage_name {
    return Intl.message(
      'Name',
      name: 'PatientPage_name',
      desc: '',
      args: [],
    );
  }

  /// `First Name`
  String get PatientPage_firstName {
    return Intl.message(
      'First Name',
      name: 'PatientPage_firstName',
      desc: '',
      args: [],
    );
  }

  /// `Medical History NO`
  String get PatientPage_medicalHistoryNo {
    return Intl.message(
      'Chart No.',
      name: 'PatientPage_medicalHistoryNo',
      desc: '',
      args: [],
    );
  }

  String get PatientPage_medicalHistory {
    return Intl.message(
      'Visit Record',
      name: 'PatientPage_medicalHistory',
      desc: '',
      args: [],
    );
  }

  /// `Last Name`
  String get PatientPage_lastName {
    return Intl.message(
      'Last Name',
      name: 'PatientPage_lastName',
      desc: '',
      args: [],
    );
  }

  /// `Date of birth`
  String get PatientPage_DateOfBirth {
    return Intl.message(
      'Date of birth',
      name: 'PatientPage_DateOfBirth',
      desc: '',
      args: [],
    );
  }

  /// `Birth Date`
  String get PatientPage_BirthDate {
    return Intl.message(
      'Birth Date',
      name: 'PatientPage_BirthDate',
      desc: '',
      args: [],
    );
  }

  /// `Diagnosis`
  String get PatientPage_Diagnosis {
    return Intl.message(
      'Diagnosis',
      name: 'PatientPage_Diagnosis',
      desc: '',
      args: [],
    );
  }

  /// `Treatment`
  String get PatientPage_Treatment {
    return Intl.message(
      'Treatment',
      name: 'PatientPage_Treatment',
      desc: '',
      args: [],
    );
  }

  /// `Please select language you will use`
  String get PatientPage_languageChoose {
    return Intl.message(
      'Please select language you will use',
      name: 'PatientPage_languageChoose',
      desc: '',
      args: [],
    );
  }

  /// `Head`
  String get PatientDetailPage_Head {
    return Intl.message(
      'Head',
      name: 'PatientDetailPage_Head',
      desc: '',
      args: [],
    );
  }

  /// `Trunk`
  String get PatientDetailPage_Trunk {
    return Intl.message(
      'Trunk',
      name: 'PatientDetailPage_Trunk',
      desc: '',
      args: [],
    );
  }

  /// `Legs`
  String get PatientDetailPage_Legs {
    return Intl.message(
      'Legs',
      name: 'PatientDetailPage_Legs',
      desc: '',
      args: [],
    );
  }

  /// `Select Taking Photo Method`
  String get PatientDetailPage_SelectPhotoTakingMethod {
    return Intl.message(
      'Select Taking Photo Method',
      name: 'PatientDetailPage_SelectPhotoTakingMethod',
      desc: '',
      args: [],
    );
  }

  /// `By Template`
  String get PatientDetailPage_ByTemplate {
    return Intl.message(
      'By Template',
      name: 'PatientDetailPage_ByTemplate',
      desc: '',
      args: [],
    );
  }

  /// `By Ghost`
  String get PatientDetailPage_ByGhost {
    return Intl.message(
      'By Ghost',
      name: 'PatientDetailPage_ByGhost',
      desc: '',
      args: [],
    );
  }

  String get PatientDetailPage_ByUpload {
    return Intl.message(
      'By Upload',
      name: 'PatientDetailPage_ByUpload',
      desc: '',
      args: [],
    );
  }

  /// `Uploaded Success`
  String get uploadAlertTitle {
    return Intl.message(
      'Uploaded Success',
      name: 'uploadAlertTitle',
      desc: '',
      args: [],
    );
  }

  /// `Current Photo was successfully uploaded to Server`
  String get uploadAlertContent {
    return Intl.message(
      'Current Photo was successfully uploaded to Server',
      name: 'uploadAlertContent',
      desc: '',
      args: [],
    );
  }

  /// `Gallery`
  String get gallery {
    return Intl.message(
      'Gallery',
      name: 'gallery',
      desc: '',
      args: [],
    );
  }

  /// `LOW`
  String get low {
    return Intl.message(
      'LOW',
      name: 'low',
      desc: '',
      args: [],
    );
  }

  /// `MEDIUM`
  String get medium {
    return Intl.message(
      'MEDIUM',
      name: 'medium',
      desc: '',
      args: [],
    );
  }

  /// `HIGH`
  String get high {
    return Intl.message(
      'HIGH',
      name: 'high',
      desc: '',
      args: [],
    );
  }

  /// `VERYHIGH`
  String get veryhigh {
    return Intl.message(
      'VERYHIGH',
      name: 'veryhigh',
      desc: '',
      args: [],
    );
  }

  /// `ULTRAHIGH`
  String get ultrahigh {
    return Intl.message(
      'ULTRAHIGH',
      name: 'ultrahigh',
      desc: '',
      args: [],
    );
  }

  /// `MAX`
  String get max {
    return Intl.message(
      'MAX',
      name: 'max',
      desc: '',
      args: [],
    );
  }

  /// `Retake`
  String get retake {
    return Intl.message(
      'Retake',
      name: 'retake',
      desc: '',
      args: [],
    );
  }

  /// `Save`
  String get save {
    return Intl.message(
      'Save',
      name: 'save',
      desc: '',
      args: [],
    );
  }

  /// `Add More`
  String get addMore {
    return Intl.message(
      'Add More',
      name: 'addMore',
      desc: '',
      args: [],
    );
  }

  /// `Add Note`
  String get addNote {
    return Intl.message(
      'Add Note',
      name: 'addNote',
      desc: '',
      args: [],
    );
  }

  /// `Search by`
  String get searchBy {
    return Intl.message(
      'Search by',
      name: 'searchBy',
      desc: '',
      args: [],
    );
  }

  /// `Text`
  String get text {
    return Intl.message(
      'Text',
      name: 'text',
      desc: '',
      args: [],
    );
  }

  /// `Diagnosis`
  String get diagnosis {
    return Intl.message(
      'Diagnosis',
      name: 'diagnosis',
      desc: '',
      args: [],
    );
  }

  /// `Treatment`
  String get treatment {
    return Intl.message(
      'Treatment',
      name: 'treatment',
      desc: '',
      args: [],
    );
  }

  /// `Notes`
  String get notes {
    return Intl.message(
      'Notes',
      name: 'notes',
      desc: '',
      args: [],
    );
  }

  /// `Loading...`
  String get loading {
    return Intl.message(
      'Loading...',
      name: 'loading',
      desc: '',
      args: [],
    );
  }

  /// `Search`
  String get search {
    return Intl.message(
      'Search',
      name: 'search',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message(
      'Cancel',
      name: 'cancel',
      desc: '',
      args: [],
    );
  }

  /// `Create`
  String get create {
    return Intl.message(
      'Create',
      name: 'create',
      desc: '',
      args: [],
    );
  }

  /// `Back`
  String get back {
    return Intl.message(
      'Back',
      name: 'back',
      desc: '',
      args: [],
    );
  }

  /// `Success`
  String get success {
    return Intl.message(
      'Success',
      name: 'success',
      desc: '',
      args: [],
    );
  }

  /// `Failed`
  String get failed {
    return Intl.message(
      'Failed',
      name: 'failed',
      desc: '',
      args: [],
    );
  }

  /// `New patient was successfully created.`
  String get newPatientCreateSuccess {
    return Intl.message(
      'New patient was successfully created.',
      name: 'newPatientCreateSuccess',
      desc: '',
      args: [],
    );
  }

  /// `New patient was failed.`
  String get newPatientCreateFailed {
    return Intl.message(
      'New patient was failed.',
      name: 'newPatientCreateFailed',
      desc: '',
      args: [],
    );
  }

  /// `You are logged in successfully.`
  String get loginSuccess {
    return Intl.message(
      'You are logged in successfully.',
      name: 'loginSuccess',
      desc: '',
      args: [],
    );
  }

  /// `LogIn was failed.`
  String get loginFailed {
    return Intl.message(
      'LogIn was failed.',
      name: 'loginFailed',
      desc: '',
      args: [],
    );
  }

  /// `UPDATED`
  String get updated {
    return Intl.message(
      'UPDATED',
      name: 'updated',
      desc: '',
      args: [],
    );
  }

  /// `NOT UPDATED`
  String get notUpdated {
    return Intl.message(
      'NOT UPDATED',
      name: 'notUpdated',
      desc: '',
      args: [],
    );
  }

  /// `Wrong`
  String get wrong {
    return Intl.message(
      'Wrong',
      name: 'wrong',
      desc: '',
      args: [],
    );
  }

  /// `please input correct username and password.`
  String get wrongPassword {
    return Intl.message(
      'Account and password are incorrect.',
      name: 'wrongPassword',
      desc: '',
      args: [],
    );
  }

  /// `please check the network connection to server.`
  String get connectionError {
    return Intl.message(
      'Please check the internet connection.',
      name: 'connectionError',
      desc: '',
      args: [],
    );
  }

  /// `Log out`
  String get logOut {
    return Intl.message(
      'Log out',
      name: 'logOut',
      desc: '',
      args: [],
    );
  }

  /// `Are you going to log out?`
  String get logOutContent {
    return Intl.message(
      'Are you going to log out?',
      name: 'logOutContent',
      desc: '',
      args: [],
    );
  }

  /// `Yes`
  String get yes {
    return Intl.message(
      'Yes',
      name: 'yes',
      desc: '',
      args: [],
    );
  }

  /// `No`
  String get no {
    return Intl.message(
      'No',
      name: 'no',
      desc: '',
      args: [],
    );
  }

  /// `Set a Profile Picture`
  String get setProfilePicture {
    return Intl.message(
      'Set a Profile Picture',
      name: 'setProfilePicture',
      desc: '',
      args: [],
    );
  }

  /// `Choose From Library`
  String get chooseFromLibrary {
    return Intl.message(
      'Choose From Library',
      name: 'chooseFromLibrary',
      desc: '',
      args: [],
    );
  }

  /// `Take a New Photo`
  String get takeNewPhoto {
    return Intl.message(
      'Take a New Photo',
      name: 'takeNewPhoto',
      desc: '',
      args: [],
    );
  }

  /// `Sort by `
  String get sortBy {
    return Intl.message(
      'Sort by ',
      name: 'sortBy',
      desc: '',
      args: [],
    );
  }

  /// `Date`
  String get date {
    return Intl.message(
      'Date',
      name: 'date',
      desc: '',
      args: [],
    );
  }

  /// `Area`
  String get area {
    return Intl.message(
      'Area',
      name: 'area',
      desc: '',
      args: [],
    );
  }

  /// `Compare`
  String get compare {
    return Intl.message(
      'Compare',
      name: 'compare',
      desc: '',
      args: [],
    );
  }

  /// `There is no patient image`
  String get noPatientImage {
    return Intl.message(
      'There is no patient image',
      name: 'noPatientImage',
      desc: '',
      args: [],
    );
  }

  /// `Error`
  String get error {
    return Intl.message(
      'Error',
      name: 'error',
      desc: '',
      args: [],
    );
  }

  /// `please choose only two photos for reporting.`
  String get twoPhotoForReport {
    return Intl.message(
      'Please select two photos to make the report.',
      name: 'twoPhotoForReport',
      desc: '',
      args: [],
    );
  }

  String get twoPhotoForCompare {
    return Intl.message(
      'Please select two photos to compare.',
      name: 'twoPhotoForCompare',
      desc: '',
      args: [],
    );
  }

  /// `Please input First name.`
  String get pleaseInputFirstName {
    return Intl.message(
      'Please input First name.',
      name: 'pleaseInputFirstName',
      desc: '',
      args: [],
    );
  }

  /// `Please input Last name.`
  String get pleaseInputLastName {
    return Intl.message(
      'Please input Last name.',
      name: 'pleaseInputLastName',
      desc: '',
      args: [],
    );
  }

  /// `Please input Medical History Number.`
  String get pleaseInputMedicalHistoryNo {
    return Intl.message(
      'Please input Medical History Number.',
      name: 'pleaseInputMedicalHistoryNo',
      desc: '',
      args: [],
    );
  }

  /// `Please select the profile image.`
  String get pleaseSelectProfileImage {
    return Intl.message(
      'Please select the profile image.',
      name: 'pleaseSelectProfileImage',
      desc: '',
      args: [],
    );
  }

  /// `Please choose the birth.`
  String get pleaseChooseBirth {
    return Intl.message(
      'Please choose the birth.',
      name: 'pleaseChooseBirth',
      desc: '',
      args: [],
    );
  }

  // Order by

  String get PatientPage_NewToOld {
    return Intl.message(
      'From New to Old',
      name: 'PatientPage_NewToOld',
      desc: '',
      args: [],
    );
  }

  String get PatientPage_OldToNew {
    return Intl.message(
      'From Old to New',
      name: 'PatientPage_OldToNew',
      desc: '',
      args: [],
    );
  }

  String get PatientPage_DateOfVisit {
    return Intl.message(
      'Date of Visit',
      name: 'PatientPage_DateOfVisit',
      desc: '',
      args: [],
    );
  }

  String get PatientPage_AttendingPhysician {
    return Intl.message(
      'Attending Physician',
      name: 'PatientPage_AttendingPhysician',
      desc: '',
      args: [],
    );
  }

  String get PatientPage_AddCommonPhrase {
    return Intl.message(
      'Add Common Phrase',
      name: 'PatientPage_AddCommonPhrase',
      desc: '',
      args: [],
    );
  }

  String get PatientPage_EnterNotes {
    return Intl.message(
      'Please enter notes',
      name: 'PatientPage_EnterNotes',
      desc: '',
      args: [],
    );
  }

  String get UploadPhotos {
    return Intl.message(
      'Upload Photos',
      name: 'UploadPhotos',
      desc: '',
      args: [],
    );
  }

  String get TreatmentTime {
    return Intl.message(
      'Treatment Time',
      name: 'TreatmentTime',
      desc: '',
      args: [],
    );
  }

  String get PhotoAuthor {
    return Intl.message(
      'Photo Author',
      name: 'PhotoAuthor',
      desc: '',
      args: [],
    );
  }

  String get SelectBodyPart {
    return Intl.message(
      'Select body-part',
      name: 'SelectBodyPart',
      desc: '',
      args: [],
    );
  }

  String get SelectAngle {
    return Intl.message(
      'Select angle',
      name: 'SelectAngle',
      desc: '',
      args: [],
    );
  }

  String get login {
    return Intl.message(
      'Login',
      name: 'login',
      desc: '',
      args: [],
    );
  }

  String get ContactUs {
    return Intl.message(
      'Contact Us',
      name: 'ContactUs',
      desc: '',
      args: [],
    );
  }

  String get preview {
    return Intl.message(
      'Preview',
      name: 'preview',
      desc: '',
      args: [],
    );
  }

  String get edit {
    return Intl.message(
      'Edit',
      name: 'edit',
      desc: '',
      args: [],
    );
  }

  String get report {
    return Intl.message(
      'Report',
      name: 'report',
      desc: '',
      args: [],
    );
  }

  String get filters {
    return Intl.message(
      'Filters',
      name: 'filters',
      desc: '',
      args: [],
    );
  }

  String get EnterKeywords {
    return Intl.message(
      'Enter Keywords',
      name: 'EnterKeywords',
      desc: '',
      args: [],
    );
  }

  String get TreatmentInterval {
    return Intl.message(
      'Treatment Interval',
      name: 'TreatmentInterval',
      desc: '',
      args: [],
    );
  }

  String get NoPhoto {
    return Intl.message(
      'There are photos taken in this visit.',
      name: 'NoPhoto',
      desc: '',
      args: [],
    );
  }

  String get all {
    return Intl.message(
      'All',
      name: 'all',
      desc: '',
      args: [],
    );
  }

  String get withinWeek {
    return Intl.message(
      'Within a week',
      name: 'withinWeek',
      desc: '',
      args: [],
    );
  }

  String get withinMonth {
    return Intl.message(
      'Within a month',
      name: 'withinMonth',
      desc: '',
      args: [],
    );
  }

  String get within3Month {
    return Intl.message(
      'Within three months',
      name: 'within3Month',
      desc: '',
      args: [],
    );
  }

  String get withinYear {
    return Intl.message(
      'Within a year',
      name: 'withinYear',
      desc: '',
      args: [],
    );
  }

  String get overYear {
    return Intl.message(
      'Over a year',
      name: 'overYear',
      desc: '',
      args: [],
    );
  }

  String get reportDate {
    return Intl.message(
      'Report date',
      name: 'reportDate',
      desc: '',
      args: [],
    );
  }

  String get clinicInformation {
    return Intl.message(
      'Clinic Information',
      name: 'clinicInformation',
      desc: '',
      args: [],
    );
  }

  String get contactNumber {
    return Intl.message(
      'Contact Number',
      name: 'contactNumber',
      desc: '',
      args: [],
    );
  }

  String get address {
    return Intl.message(
      'Address',
      name: 'address',
      desc: '',
      args: [],
    );
  }

  String get website {
    return Intl.message(
      'Website',
      name: 'website',
      desc: '',
      args: [],
    );
  }

  String get patientInformation {
    return Intl.message(
      'Patient Information',
      name: 'patientInformation',
      desc: '',
      args: [],
    );
  }

  String get patientName {
    return Intl.message(
      'Patient Name',
      name: 'patientName',
      desc: '',
      args: [],
    );
  }

  String get userName {
    return Intl.message(
      'Account',
      name: 'userName',
      desc: '',
      args: [],
    );
  }

  String get password {
    return Intl.message(
      'Password',
      name: 'password',
      desc: '',
      args: [],
    );
  }

  String get sureToContact {
    return Intl.message(
      'Are you sure to go to the contact page?',
      name: 'sureToContact',
      desc: '',
      args: [],
    );
  }

  String get sureToDeleteHistory {
    return Intl.message(
      'You can not restore the item after deleting it.',
      name: 'sureToDeleteHistory',
      desc: '',
      args: [],
    );
  }

  String get noteForThisPhoto {
    return Intl.message(
      'Notes for this photo',
      name: 'noteForThisPhoto',
      desc: '',
      args: [],
    );
  }

  String get shootingTime {
    return Intl.message(
      'Shooting time',
      name: 'shootingTime',
      desc: '',
      args: [],
    );
  }

  String get selectDate {
    return Intl.message(
      'Select Date',
      name: 'selectDate',
      desc: '',
      args: [],
    );
  }

  String get ok {
    return Intl.message(
      'Ok',
      name: 'ok',
      desc: '',
      args: [],
    );
  }

  String get go {
    return Intl.message(
      'Go',
      name: 'go',
      desc: '',
      args: [],
    );
  }

  String get delete {
    return Intl.message(
      'Delete',
      name: 'delete',
      desc: '',
      args: [],
    );
  }

  String get add {
    return Intl.message(
      'Add',
      name: 'add',
      desc: '',
      args: [],
    );
  }

  String get upload {
    return Intl.message(
      'Upload',
      name: 'upload',
      desc: '',
      args: [],
    );
  }

  String get uploadSuccess {
    return Intl.message(
      'Upload Success',
      name: 'uploadSuccess',
      desc: '',
      args: [],
    );
  }

  String get uploadFailed {
    return Intl.message(
      'Error',
      name: 'uploadFailed',
      desc: '',
      args: [],
    );
  }

  String get uploadFailedDesc {
    return Intl.message(
      'The data has not been saved. Please try again.',
      name: 'uploadFailedDesc',
      desc: '',
      args: [],
    );
  }

  String get uploadSuccessDesc {
    return Intl.message(
      'The photo has been uploaded to server. Please continue to take the next angles.',
      name: 'uploadSuccessDesc',
      desc: '',
      args: [],
    );
  }

  String get uploadSuccessDesc1 {
    return Intl.message(
      'The photo has been uploaded to server.',
      name: 'uploadSuccessDesc1',
      desc: '',
      args: [],
    );
  }

  String get visitTime {
    return Intl.message(
      'Visit Time',
      name: 'visitTime',
      desc: '',
      args: [],
    );
  }

  String get dx {
    return Intl.message(
      'Dx',
      name: 'dx',
      desc: '',
      args: [],
    );
  }

  String get tx {
    return Intl.message(
      'Tx',
      name: 'tx',
      desc: '',
      args: [],
    );
  }

  String get filterOk {
    return Intl.message(
      'OK',
      name: 'filterOk',
      desc: '',
      args: [],
    );
  }

  String get enterKeywordDesc {
    return Intl.message(
      'Diagnosis, treatment or notes…',
      name: 'enterKeywordDesc',
      desc: '',
      args: [],
    );
  }

  String get selectDr {
    return Intl.message(
      'Select Dr.',
      name: 'selectDr',
      desc: '',
      args: [],
    );
  }

  String get selectBodyPart {
    return Intl.message(
      'Select body-part',
      name: 'selectBodyPart',
      desc: '',
      args: [],
    );
  }

  String get bodyPart {
    return Intl.message(
      'Body-part',
      name: 'bodyPart',
      desc: '',
      args: [],
    );
  }

  String get injectionAdd {
    return Intl.message(
      'Add',
      name: 'injectionAdd',
      desc: '',
      args: [],
    );
  }

  String get moreInfo {
    return Intl.message(
      'More info',
      name: 'moreInfo',
      desc: '',
      args: [],
    );
  }

  String get moreInfoDesc {
    return Intl.message(
      'You can input more info here',
      name: 'moreInfoDesc',
      desc: '',
      args: [],
    );
  }

  String get downloadSuccess {
    return Intl.message(
      'Download Success',
      name: 'downloadSuccess',
      desc: '',
      args: [],
    );
  }

  String get downloadSuccessDesc {
    return Intl.message(
      'The report has been saved at',
      name: 'downloadSuccessDesc',
      desc: '',
      args: [],
    );
  }

  String get saveSuccess {
    return Intl.message(
      'Save Success',
      name: 'saveSuccess',
      desc: '',
      args: [],
    );
  }

  String get saveSuccessDesc {
    return Intl.message(
      'Photo is saved successfully to Gallery directory.',
      name: 'saveSuccessDesc',
      desc: '',
      args: [],
    );
  }

  String get searchBarHint {
    return Intl.message(
      'Name/Chart No./Diagnosis/Treatment/Notes',
      name: 'searchBarHint',
      desc: '',
      args: [],
    );
  }

  String get photoSource {
    return Intl.message(
      'Photo Source',
      name: 'photoSource',
      desc: '',
      args: [],
    );
  }

  String get localDevice {
    return Intl.message(
      'Local Device',
      name: 'localDevice',
      desc: '',
      args: [],
    );
  }

  String get temporaryAlbum {
    return Intl.message(
      'Temporary Album',
      name: 'temporaryAlbum',
      desc: '',
      args: [],
    );
  }

  String get temporaryStorage {
    return Intl.message(
      'Temporary Storage',
      name: 'temporaryStorage',
      desc: '',
      args: [],
    );
  }

  String get complete {
    return Intl.message(
      'Complete',
      name: 'complete',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'zh'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
