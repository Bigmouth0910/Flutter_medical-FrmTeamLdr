import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_treeview/flutter_treeview.dart';
import 'package:rxphoto/features/patient/bloc/patient_bloc.dart';
import 'package:rxphoto/models/diagnosis.model.dart';
import 'package:provider/provider.dart';
import 'package:rxphoto/generated/l10n.dart';

class TreeWidget extends StatefulWidget {
  TreeWidget();
  @override
  _TreeWidgetState createState() => _TreeWidgetState();
}

class _TreeWidgetState extends State<TreeWidget> {
  String _selectedNode = "docs";
  late List<Node> _nodes;
  late TreeViewController _treeViewController;
  bool docsOpen = true;
  bool deepExpanded = true;
  final Map<ExpanderPosition, Widget> expansionPositionOptions = const {
    ExpanderPosition.start: Text('Start'),
    ExpanderPosition.end: Text('End'),
  };
  final Map<ExpanderType, Widget> expansionTypeOptions = {
    ExpanderType.none: Container(),
    ExpanderType.caret: Icon(
      Icons.arrow_drop_down,
      size: 28,
    ),
    ExpanderType.arrow: Icon(Icons.arrow_downward),
    ExpanderType.chevron: Icon(Icons.expand_more),
    ExpanderType.plusMinus: Icon(Icons.add),
  };
  ExpanderPosition _expanderPosition = ExpanderPosition.end;
  ExpanderType _expanderType = ExpanderType.arrow;
  ExpanderModifier _expanderModifier = ExpanderModifier.none;
  bool _allowParentSelect = false;
  bool _supportParentDoubleTap = false;
  Map<String, bool> isLeaf = {};
  final TextEditingController searchController = new TextEditingController();
  PatientBloc? patientBloc;

  List<Node<Diagnosis>> convertToNodeList(
      List<Diagnosis> totalDiagnosis, Node? node) {
    return totalDiagnosis
        .map((Diagnosis e) {
          List<Node<Diagnosis>> _children = [];
          if (e.children != null) {
            _children = convertToNodeList(e.children!, node);
          }

          String tmpKey = e.id.toString() + '_' + e.tagName.toString();

          if (isLeaf.keys.contains(tmpKey) == false) {
            if (_children.length == 0)
              isLeaf[tmpKey] = true;
            else
              isLeaf[tmpKey] = false;
          }

          bool isSelected = (node != null && node.key == tmpKey);

          int pos = patientBloc!.state.selectedDiagnosis.indexWhere((element) {
            return e.id.toString() == element['key'];
          });

          if (pos >= 0) isSelected = true;

          return Node<Diagnosis>(
            key: tmpKey,
            label: (e.tagName ?? "TagName") + (isSelected ? ' (V)' : ''),
            expanded: true,
            // parent: e.parentId != null ? true : false,
            children: _children,
          );
        })
        .toList()
        .where((element) {
          if (isLeaf[element.key] == true &&
              element.label
                      .toLowerCase()
                      .contains(searchController.text.toLowerCase()) ==
                  false) return false;

          if (isLeaf[element.key] == false && element.children.length == 0)
            return false;

          return true;
        })
        .toList();
  }

  @override
  void initState() {
    super.initState();
    patientBloc = context.read<PatientBloc>();
    var totalDiagnosis = context.read<PatientBloc>().state.diagnosis;
    _nodes = convertToNodeList(totalDiagnosis, null);
    _treeViewController = TreeViewController(
      children: _nodes,
      selectedKey: _selectedNode,
    );
  }

  @override
  Widget build(BuildContext context) {
    TreeViewTheme _treeViewTheme = TreeViewTheme(
      expanderTheme: ExpanderThemeData(
          type: _expanderType,
          modifier: _expanderModifier,
          position: _expanderPosition,
          // color: Colors.grey.shade800,
          size: 20,
          color: Color(0xffF45666)),
      labelStyle: TextStyle(
        fontSize: 16,
        letterSpacing: 0.3,
      ),
      parentLabelStyle: TextStyle(
        fontSize: 16,
        letterSpacing: 0.1,
        fontWeight: FontWeight.w800,
        color: Color(0xffF45666),
      ),
      iconTheme: IconThemeData(
        size: 18,
        color: Colors.grey.shade800,
      ),
      colorScheme: Theme.of(context).colorScheme,
    );

    FocusNode focusNode = FocusNode();

    return Stack(children: [
      Positioned(
        left: 20,
        top: 20,
        child: Container(
          width: MediaQuery.of(context).size.width - 40,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(width: 1, color: Colors.black26),
          ),
          child: TextField(
            focusNode: focusNode,
            onChanged: (value) {
              var totalDiagnosis = context.read<PatientBloc>().state.diagnosis;

              setState(() {
                _nodes = convertToNodeList(totalDiagnosis, null);
                _treeViewController = TreeViewController(
                  children: _nodes,
                  selectedKey: "docs",
                );
              });
            },
            onTap: () {
              FocusScope.of(context).requestFocus(focusNode);
            },
            controller: searchController,
            maxLines: 1,
            autofocus: true,
            decoration: InputDecoration(
                fillColor: Colors.white,
                hintText: S.of(context).search,
                hintStyle: TextStyle(color: Colors.black26),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.fromLTRB(13, 8, 5, 8)),
          ),
        ),
      ),
      Container(
        margin: EdgeInsets.only(top: 40),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
        child: TreeView(
          controller: _treeViewController,
          allowParentSelect: _allowParentSelect,
          supportParentDoubleTap: _supportParentDoubleTap,
          onExpansionChanged: (key, expanded) => _expandNode(key, expanded),
          onNodeTap: (key) {
            Node? node = _treeViewController.getNode(key);
            context.read<PatientBloc>().add(PatientDialogDiagnosisSelected(
                node!.key.split('_')[0], node.label));

            var totalDiagnosis = context.read<PatientBloc>().state.diagnosis;

            setState(() {
              _nodes = convertToNodeList(totalDiagnosis, node);
              _treeViewController =
                  _treeViewController.copyWith(children: _nodes);
            });
            // Navigator.of(context).pop();
          },
          theme: _treeViewTheme,
        ),
      )
    ]);
  }

  _expandNode(String key, bool expanded) {
    String msg = '${expanded ? "Expanded" : "Collapsed"}: $key';
    debugPrint(msg);
    Node? node = _treeViewController.getNode(key);

    if (node != null) {
      List<Node> updated;
      if (key == 'docs') {
        updated = _treeViewController.updateNode(
            key,
            node.copyWith(
              expanded: expanded,
              icon: expanded ? Icons.folder_open : Icons.folder,
            ));
      } else {
        updated = _treeViewController.updateNode(
            key, node.copyWith(expanded: expanded));
      }
      setState(() {
        if (key == 'docs') docsOpen = expanded;
        _treeViewController = _treeViewController.copyWith(children: updated);
      });
    }
  }
}
