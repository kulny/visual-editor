import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../controller/controllers/editor-controller.dart';
import '../../../documents/models/attribute.model.dart';
import '../../../documents/models/attributes/attributes-aliases.model.dart';
import '../../../documents/models/attributes/attributes.model.dart';
import '../../../documents/models/style.model.dart';
import '../../../shared/models/editor-icon-theme.model.dart';
import '../../../shared/state/editor-state-receiver.dart';
import '../../../shared/state/editor.state.dart';
import '../toolbar.dart';

// ignore: must_be_immutable
class SelectHeaderStyleButton extends StatefulWidget with EditorStateReceiver {
  final EditorController controller;
  final double iconSize;
  final double buttonsSpacing;
  final EditorIconThemeM? iconTheme;

  // Used internally to retrieve the state from the EditorController instance to which this button is linked to.
  // Can't be accessed publicly (by design) to avoid exposing the internals of the library.
  late EditorState _state;

  @override
  void setState(EditorState state) {
    _state = state;
  }

  SelectHeaderStyleButton({
    required this.controller,
    required this.buttonsSpacing,
    this.iconSize = defaultIconSize,
    this.iconTheme,
    Key? key,
  }) : super(key: key) {
    controller.setStateInEditorStateReceiver(this);
  }

  @override
  _SelectHeaderStyleButtonState createState() =>
      _SelectHeaderStyleButtonState();
}

class _SelectHeaderStyleButtonState extends State<SelectHeaderStyleButton> {
  AttributeM? _value;
  StreamSubscription? _refreshListener;

  StyleM get _selectionStyle => widget.controller.getSelectionStyle();

  @override
  void initState() {
    super.initState();
    setState(() {
      _value = _getHeaderValue();
    });
    _subscribeToRefreshListener();
  }

  @override
  Widget build(BuildContext context) {
    final _valueToText = <AttributeM, String>{
      AttributesM.header: 'N',
      AttributesAliasesM.h1: 'H1',
      AttributesAliasesM.h2: 'H2',
      AttributesAliasesM.h3: 'H3',
    };

    final _valueAttribute = <AttributeM>[
      AttributesM.header,
      AttributesAliasesM.h1,
      AttributesAliasesM.h2,
      AttributesAliasesM.h3
    ];
    final _valueString = <String>['N', 'H1', 'H2', 'H3'];

    final theme = Theme.of(context);
    final style = TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: widget.iconSize * 0.7,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(4, (index) {
        return Container(
          // ignore: prefer_const_constructors
          margin: EdgeInsets.symmetric(
            horizontal: !kIsWeb ? 1.0 : widget.buttonsSpacing,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints.tightFor(
              width: widget.iconSize * iconButtonFactor,
              height: widget.iconSize * iconButtonFactor,
            ),
            child: RawMaterialButton(
              hoverElevation: 0,
              highlightElevation: 0,
              elevation: 0,
              visualDensity: VisualDensity.compact,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  widget.iconTheme?.borderRadius ?? 2,
                ),
              ),
              fillColor: _valueToText[_value] == _valueString[index]
                  ? (widget.iconTheme?.iconSelectedFillColor ??
                      theme.toggleableActiveColor)
                  : (widget.iconTheme?.iconUnselectedFillColor ??
                      theme.canvasColor),
              onPressed: () => widget.controller.formatSelection(
                _valueAttribute[index],
              ),
              child: Text(
                _valueString[index],
                style: style.copyWith(
                  color: _valueToText[_value] == _valueString[index]
                      ? (widget.iconTheme?.iconSelectedColor ??
                          theme.primaryIconTheme.color)
                      : (widget.iconTheme?.iconUnselectedColor ??
                          theme.iconTheme.color),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  @override
  void didUpdateWidget(covariant SelectHeaderStyleButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If a new controller was generated by setState() in the parent
    // we need to subscribe to the new state store.
    if (oldWidget.controller != widget.controller) {
      _refreshListener?.cancel();
      widget.controller.setStateInEditorStateReceiver(widget);
      _subscribeToRefreshListener();
      _value = _getHeaderValue();
    }
  }

  @override
  void dispose() {
    _refreshListener?.cancel();
    super.dispose();
  }

  // === PRIVATE ===

  void _subscribeToRefreshListener() {
    _refreshListener = widget._state.refreshEditor.refreshEditor$.listen(
      (_) => _didChangeEditingValue(),
    );
  }

  void _didChangeEditingValue() {
    setState(() {
      _value = _getHeaderValue();
    });
  }

  AttributeM<dynamic> _getHeaderValue() {
    final attr = widget.controller.toolbarButtonToggler[AttributesM.header.key];
    if (attr != null) {
      // Checkbox tapping causes controller.selection to go to offset 0
      widget.controller.toolbarButtonToggler.remove(AttributesM.header.key);
      return attr;
    }
    return _selectionStyle.attributes[AttributesM.header.key] ??
        AttributesM.header;
  }
}
