import 'package:flutter/material.dart';
import 'package:flutter_dropdown_alert/dropdown_alert.dart';
import 'package:rxphoto/app/global_repository.dart';
import 'package:rxphoto/common/routes/routes.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxphoto/features/EditPreviewPhoto/editPreviewPhotoPage.dart';
import 'package:rxphoto/features/camera/camera_page.dart';
import 'package:rxphoto/features/compare/compare.dart';
import 'package:rxphoto/features/editCameraImage/editCameraImage.dart';
import 'package:rxphoto/features/editHomeCamera/editHomeCamera.dart';
import 'package:rxphoto/features/gallery/gallery_page.dart';
import 'package:rxphoto/features/login/bloc/login_bloc.dart';
import 'package:flutter/services.dart';
import 'package:rxphoto/features/login/ui/login_page.dart';
import 'package:rxphoto/features/normalCamera/camera_page.dart';
import 'package:rxphoto/features/patient/bloc/patient_bloc.dart';
import 'package:rxphoto/features/patient/ui/patient_page.dart';
import 'package:rxphoto/features/patientDetail/bloc/patientdetail_bloc.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:rxphoto/features/patientDetail/patientDetail_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:rxphoto/features/patientDetail/ui/widget/UploadPhoto.dart';
import 'package:rxphoto/features/report/report_page.dart';
import 'package:rxphoto/features/selectGhost/SelectGhostPage.dart';
import 'package:rxphoto/generated/l10n.dart';

class MobileApplication extends StatelessWidget {
  final GlobalRepository globalRepository;
  MobileApplication({required this.globalRepository});
  @override
  Widget build(BuildContext context) {
    // Set landscape orientation
    // SystemChrome.setPreferredOrientations([
    //   DeviceOrientation.landscapeLeft,
    //   DeviceOrientation.landscapeRight,
    // ]);
    // Set portrait orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
    return RepositoryProvider.value(
      value: globalRepository,
      child: AppView(),
    );
  }
}

class AppView extends StatelessWidget {
  const AppView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return GlobalLoaderOverlay(
        overlayWidget: Text("Saving..."),
        child: MultiBlocProvider(
            providers: [
              BlocProvider<LoginBloc>(
                  create: (_) => LoginBloc(
                      globalRepository: context.read<GlobalRepository>())),
              BlocProvider<PatientBloc>(
                  create: (_) => PatientBloc(
                      globalRepository: context.read<GlobalRepository>())),
              BlocProvider<PatientdetailBloc>(
                  create: (_) => PatientdetailBloc(
                      globalRepository: context.read<GlobalRepository>())),
            ],
            child: MaterialApp(
              localizationsDelegates: const [
                S.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
              ],
              supportedLocales: S.delegate.supportedLocales,
              debugShowCheckedModeBanner: false,
              builder: (context, child) => Stack(
                children: [child!, DropdownAlert()],
              ),
              // home: LoginPage(),
              routes: {
                Routes.LOGIN_PAGE: (context) => LoginPage(),
                Routes.PATIENT_PAGE: (context) => PatientPage(),
                Routes.PATIENT_DETAIL_PAGE: (context) => PatientDetailPage(),
                Routes.CAMERA_PAGE: (context) => CameraPage(),
                Routes.EDITCAMERA_PAGE: (context) => EditCameraPage(),
                Routes.EDITHOMECAMERA_PAGE: (context) => EditHomeCameraPage(),
                Routes.GALLERY_PAGE: (context) => GalleryPage(),
                Routes.COMPARE_PAGE: (context) => ComparePage(),
                Routes.SELECT_GHOST_PAGE: (context) => SelectGhostPage(),
                Routes.NORMAL_COMPARE_PAGE: (context) => NormalCameraPage(),
                Routes.EDIT_PREVIEW_PHOTO: (context) => EditPreviewPhotoPage(),
                Routes.REPORT_PAGE: (context) => ReportPage(),
              },
              initialRoute: Routes.LOGIN_PAGE,
            )));
  }
}
