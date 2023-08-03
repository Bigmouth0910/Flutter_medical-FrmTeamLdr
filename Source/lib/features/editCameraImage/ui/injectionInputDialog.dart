import 'package:flutter/cupertino.dart';
import 'package:rxphoto/features/patient/bloc/patient_bloc.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:rxphoto/models/treatmentInfo.model.dart';
import 'package:rxphoto/generated/l10n.dart';

extension ColorExtension on String {
  toColor() {
    var hexColor = this.replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    if (hexColor.length == 8) {
      return Color(int.parse("0x$hexColor"));
    }
  }
}

class InjectionInputDialog extends StatefulWidget {
  Function(String, String)? callback;
  String? foundInjectionValue;
  String? oldInjectionType;
  InjectionInputDialog(
      {this.callback, this.foundInjectionValue, this.oldInjectionType});

  @override
  _InjectionInputDialogState createState() => _InjectionInputDialogState();
}

class _InjectionInputDialogState extends State<InjectionInputDialog> {
  String numValue = "0";
  String injectionType = "#14991F";
  List<TreatmentInfo>? injectionList;

  @override
  void initState() {
    final patientBloc = context.read<PatientBloc>();
    final InjectionList = patientBloc.state.treatmentInfo
        .firstWhere((element) => element.tagName == "Injection")
        .children;
    setState(() {
      injectionList = InjectionList;
      numValue =
          widget.foundInjectionValue != null && widget.foundInjectionValue != ""
              ? widget.foundInjectionValue!
              : "0";
      injectionType =
          widget.oldInjectionType != null && widget.oldInjectionType != ""
              ? widget.oldInjectionType!
              : InjectionList![0].injectionColor!;
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Material(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        child: Container(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10)),
                    color: Color(0xffF4568C)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(S.of(context).cancel,
                          style:
                              TextStyle(color: Colors.white, fontSize: 18.0)),
                    ),
                    DropdownButton<String>(
                      iconEnabledColor: Colors.white,
                      dropdownColor: Color(0xffF4568C),
                      underline: Container(),
                      value: injectionType,
                      items: [
                        for (TreatmentInfo item in injectionList!)
                          DropdownMenuItem(
                            child: Text(
                              item.tagName.toString(),
                              style: TextStyle(color: Colors.white),
                            ),
                            value: item.injectionColor,
                          )
                      ],
                      onChanged: (value) {
                        setState(() {
                          injectionType = value!;
                        });
                      },
                      hint: Text("Select item"),
                    ),
                    // Text(
                    //   'Botox',
                    //   style: TextStyle(fontSize: 20.0, color: Colors.white),
                    // ),
                    InkWell(
                      onTap: () {
                        widget.callback!(numValue, injectionType);
                        Navigator.of(context).pop();
                      },
                      child: Text(S.of(context).injectionAdd,
                          style:
                              TextStyle(color: Colors.white, fontSize: 18.0)),
                    ),
                  ],
                ),
              ),
              Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.all(10.0),
                  color: Colors.black12,
                  child: Center(
                      child:
                          Text("$numValue", style: TextStyle(fontSize: 18)))),
              for (var i = 3; i >= 1; i--)
                Container(
                  margin: EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                          child: InkWell(
                              onTap: () {
                                if (numValue == "0")
                                  setState(() {
                                    numValue = (i * 3 - 2).toString();
                                  });
                                else
                                  setState(() {
                                    numValue += (i * 3 - 2).toString();
                                  });
                              },
                              child: Center(
                                child: Container(
                                    alignment: Alignment.center,
                                    width: 35,
                                    height: 35,
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(50.0),
                                        color: Color(0xffeeeeee)),
                                    child: Text("${i * 3 - 2}",
                                        style: TextStyle(fontSize: 18))),
                              )),
                        ),
                        Expanded(
                          child: InkWell(
                              onTap: () {
                                if (numValue == "0")
                                  setState(() {
                                    numValue = (i * 3 - 1).toString();
                                  });
                                else
                                  setState(() {
                                    numValue += (i * 3 - 1).toString();
                                  });
                              },
                              child: Center(
                                child: Container(
                                    alignment: Alignment.center,
                                    width: 35,
                                    height: 35,
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(50.0),
                                        color: Color(0xffeeeeee)),
                                    child: Text("${i * 3 - 1}",
                                        style: TextStyle(fontSize: 18))),
                              )),
                        ),
                        Expanded(
                          child: InkWell(
                              onTap: () {
                                if (numValue == "0")
                                  setState(() {
                                    numValue = (i * 3).toString();
                                  });
                                else
                                  setState(() {
                                    numValue += (i * 3).toString();
                                  });
                              },
                              child: Center(
                                child: Container(
                                    alignment: Alignment.center,
                                    width: 35,
                                    height: 35,
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(50.0),
                                        color: Color(0xffeeeeee)),
                                    child: Text("${i * 3}",
                                        style: TextStyle(fontSize: 18))),
                              )),
                        )
                      ]),
                ),
              Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                Expanded(
                    child: InkWell(
                  onTap: () {
                    setState(() {
                      numValue += ".";
                    });
                  },
                  child: Center(
                      child: Container(
                          alignment: Alignment.center,
                          width: 35,
                          height: 35,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50.0),
                              color: Color(0xffeeeeee)),
                          child: Text(".", style: TextStyle(fontSize: 25)))),
                )),
                Expanded(
                    child: InkWell(
                  onTap: () {
                    if (numValue != "0")
                      setState(() {
                        numValue += "0";
                      });
                  },
                  child: Center(
                      child: Container(
                          alignment: Alignment.center,
                          width: 35,
                          height: 35,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50.0),
                              color: Color(0xffeeeeee)),
                          child: Text("0", style: TextStyle(fontSize: 18)))),
                )),
                Expanded(
                    child: InkWell(
                        onTap: () {
                          setState(() {
                            numValue = "0";
                          });
                        },
                        child: Center(
                            child: Container(
                                alignment: Alignment.center,
                                width: 35,
                                height: 35,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50.0),
                                    color: Color(0xffeeeeee)),
                                child: Text("x",
                                    style: TextStyle(fontSize: 18))))))
              ]),
              Container(
                  margin: EdgeInsets.only(top: 10),
                  child: IconButton(
                    onPressed: () {
                      setState(() {
                        numValue = "0";
                      });
                    },
                    icon: Icon(
                      Icons.delete,
                      size: 30,
                      color: Color(0xffF45666),
                    ),
                  )),
              // Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              //   Text("-", style: TextStyle(fontSize: 25)),
              //   Text("10.0Units", style: TextStyle(fontSize: 18)),
              //   Text("+", style: TextStyle(fontSize: 25))
              // ]),
              SizedBox(height: 10)
            ],
          ),
        ),
      ),
    );
  }
}
