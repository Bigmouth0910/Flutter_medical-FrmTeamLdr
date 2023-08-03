import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
  String injectionType = "Botox";

  @override
  void initState() {
    setState(() {
      numValue =
          widget.foundInjectionValue != null && widget.foundInjectionValue != ""
              ? widget.foundInjectionValue!
              : "0";
      injectionType =
          widget.oldInjectionType != null && widget.oldInjectionType != ""
              ? widget.oldInjectionType!
              : "Botox";
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
      alignment: Alignment(0.5, 0.8),
      child: Material(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        child: Container(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10)),
                    color: Colors.blue),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('Cancel',
                          style:
                              TextStyle(color: Colors.white, fontSize: 18.0)),
                    ),
                    DropdownButton<String>(
                      dropdownColor: Colors.blueGrey,
                      underline: Container(),
                      value: injectionType,
                      items: [
                        for (String item in ["Botox", "Belkyra", "Hyaluronan"])
                          DropdownMenuItem(
                            child: Text(
                              item.toString(),
                              style: TextStyle(color: Colors.white),
                            ),
                            value: item,
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
                      child: Text('Done',
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
                  margin: EdgeInsets.symmetric(vertical: 10),
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
                                child: Text("${i * 3 - 2}",
                                    style: TextStyle(fontSize: 18)),
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
                                child: Text("${i * 3 - 1}",
                                    style: TextStyle(fontSize: 18)),
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
                                child: Text("${i * 3}",
                                    style: TextStyle(fontSize: 18)),
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
                  child:
                      Center(child: Text(".", style: TextStyle(fontSize: 25))),
                )),
                Expanded(
                    child: InkWell(
                  onTap: () {
                    if (numValue != "0")
                      setState(() {
                        numValue += "0";
                      });
                  },
                  child:
                      Center(child: Text("0", style: TextStyle(fontSize: 18))),
                )),
                Expanded(
                    child: InkWell(
                        onTap: () {
                          setState(() {
                            numValue = "0";
                          });
                        },
                        child: Center(
                            child: Text("x", style: TextStyle(fontSize: 18)))))
              ]),
              Container(
                  margin: EdgeInsets.symmetric(vertical: 10),
                  child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          numValue = "0";
                        });
                      },
                      child: Text("Remove"))),
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
