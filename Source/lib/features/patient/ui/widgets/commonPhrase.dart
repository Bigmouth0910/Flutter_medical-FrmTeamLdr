import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_treeview/flutter_treeview.dart';
import 'package:rxphoto/features/patient/bloc/patient_bloc.dart';
import 'package:rxphoto/models/commonphrase.model.dart';
import 'package:provider/provider.dart';
import 'package:rxphoto/generated/l10n.dart';

class commonPhrase extends StatefulWidget {
  final ValueSetter<String> callbackSetNotes;
  commonPhrase(this.callbackSetNotes);
  @override
  _commonPhraseState createState() => _commonPhraseState();
}

class _commonPhraseState extends State<commonPhrase> {
  String _selectedNode = "docs";
  late List<Node> _nodes;
  late TreeViewController _treeViewController;
  final TextEditingController searchController = new TextEditingController();
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
  int index = 0;
  Map<String, bool> isLeaf = {};

  List<Node<CommonPhrase>> convertToNodeList(
      List<CommonPhrase> totalCommonPhrase) {
    return totalCommonPhrase
        .map((CommonPhrase e) {
          List<Node<CommonPhrase>> _children = [];
          if (e.children != null) {
            _children = convertToNodeList(e.children!);
          }
          index++;

          String tmpKey = e.id.toString() + e.tagName.toString();

          if (isLeaf.keys.contains(tmpKey) == false) {
            if (_children.length == 0)
              isLeaf[tmpKey] = true;
            else
              isLeaf[tmpKey] = false;
          }

          return Node<CommonPhrase>(
            key: tmpKey,
            label: e.tagName ?? "TagName",
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
    var totalCommonPhrase = context.read<PatientBloc>().state.commonPhrase;
    _nodes = convertToNodeList(totalCommonPhrase);
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
              List<CommonPhrase> totalCommonPhrase =
                  context.read<PatientBloc>().state.commonPhrase;

              setState(() {
                _nodes = convertToNodeList(totalCommonPhrase);
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
            widget.callbackSetNotes(node!.label);
            // debugPrint('Selected: $key');
            // context
            //     .read<PatientBloc>()
            //     .add(PatientDialogCommonPhraseSelected(node!.key, node.label));
            setState(() {
              _selectedNode = key;
              _treeViewController =
                  _treeViewController.copyWith(selectedKey: key);
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
