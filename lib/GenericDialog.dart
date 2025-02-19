import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum ActionStyle { normal, destructive, important, important_destructive }

class GenericDialog {
  static Color _normal = Colors.green;
  static Color _destructive = Colors.red;



  /// show the OS Native dialog
  static show(BuildContext context, String title, String message,
      String firstButtonText, Function firstCallBack,
      {ActionStyle firstActionStyle = ActionStyle.normal,
        String secondButtonText,
        Function secondCallback,
        ActionStyle secondActionStyle = ActionStyle.normal, bool canBeDismissed = false}) {
    showDialog(
      context: context,
      barrierDismissible: canBeDismissed,
      builder: (BuildContext context) {
        Widget dialog = Platform.isIOS
            ? _iosDialog(
            context, title, message, firstButtonText, firstCallBack,
            firstActionStyle: firstActionStyle,
            secondButtonText: secondButtonText,
            secondCallback: secondCallback,
            secondActionStyle: secondActionStyle)
            : _androidDialog(
            context, title, message, firstButtonText, firstCallBack,
            firstActionStyle: firstActionStyle,
            secondButtonText: secondButtonText,
            secondCallback: secondCallback,
            secondActionStyle: secondActionStyle);

        if(canBeDismissed) return dialog;
        else return WillPopScope(
            onWillPop: () async => canBeDismissed,
            child:dialog);
      },
    );
  }






  /// show the OS Native dialog
  static showLocDialog(BuildContext context, String title, String message,
      String firstButtonText, Function firstCallBack,
      {ActionStyle firstActionStyle = ActionStyle.important,
      String secondButtonText,
      Function secondCallback,
      ActionStyle secondActionStyle = ActionStyle.normal, Function popCallback}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        Widget dialog = Platform.isIOS
            ? _iosDialog(
            context, title, message, firstButtonText, firstCallBack,
            firstActionStyle: firstActionStyle,
            secondButtonText: secondButtonText,
            secondCallback: secondCallback,
            secondActionStyle: secondActionStyle)
            : _androidDialog(
            context, title, message, firstButtonText, firstCallBack,
            firstActionStyle: firstActionStyle,
            secondButtonText: secondButtonText,
            secondCallback: secondCallback,
            secondActionStyle: secondActionStyle);

        return WillPopScope(
            onWillPop: () async {
              await popCallback();
              return true;
            },
            child:dialog);
      },
    );
  }

  /// show the android Native dialog
  static Widget _androidDialog(BuildContext context, String title,
      String message, String firstButtonText, Function firstCallBack,
      {ActionStyle firstActionStyle = ActionStyle.normal,
      String secondButtonText,
      Function secondCallback,
      ActionStyle secondActionStyle = ActionStyle.normal}) {
    List<FlatButton> actions = [];
    actions.add(FlatButton(
      child: Text(
        firstButtonText,
        style: TextStyle(
            color: (firstActionStyle == ActionStyle.important_destructive ||
                    firstActionStyle == ActionStyle.destructive)
                ? _destructive
                : _normal,
            fontWeight:
                (firstActionStyle == ActionStyle.important_destructive ||
                        firstActionStyle == ActionStyle.important)
                    ? FontWeight.bold
                    : FontWeight.normal),
      ),
      onPressed: () {
        Navigator.of(context).pop();
        firstCallBack();
      },
    ));

    if (secondButtonText != null) {
      actions.add(FlatButton(
        child: Text(secondButtonText,
            style: TextStyle(
                color:
                    (secondActionStyle == ActionStyle.important_destructive ||
                            firstActionStyle == ActionStyle.destructive)
                        ? _destructive
                        : _normal)),
        onPressed: () {
          Navigator.of(context).pop();
          secondCallback();
        },
      ));
    }
    return AlertDialog(
        title: Text(title), content: Text(message), actions: actions);
  }

  /// show the iOS Native dialog
  static Widget _iosDialog(BuildContext context, String title, String message,
      String firstButtonText, Function firstCallback,
      {ActionStyle firstActionStyle = ActionStyle.normal,
      String secondButtonText,
      Function secondCallback,
      ActionStyle secondActionStyle = ActionStyle.normal}) {
    List<CupertinoDialogAction> actions = [];
    actions.add(
      CupertinoDialogAction(
        isDefaultAction: true,
        onPressed: () {
          Navigator.of(context).pop();
          firstCallback();
        },
        child: Text(
          firstButtonText,
          style: TextStyle(
              color: (firstActionStyle == ActionStyle.important_destructive ||
                      firstActionStyle == ActionStyle.destructive)
                  ? _destructive
                  : _normal,
              fontWeight:
                  (firstActionStyle == ActionStyle.important_destructive ||
                          firstActionStyle == ActionStyle.important)
                      ? FontWeight.bold
                      : FontWeight.normal),
        ),
      ),
    );

    if (secondButtonText != null) {
      actions.add(
        CupertinoDialogAction(
          isDefaultAction: true,
          onPressed: () {
            Navigator.of(context).pop();
            secondCallback();
          },
          child: Text(
            secondButtonText,
            style: TextStyle(
                color:
                    (secondActionStyle == ActionStyle.important_destructive ||
                            secondActionStyle == ActionStyle.destructive)
                        ? _destructive
                        : _normal,
                fontWeight:
                    (secondActionStyle == ActionStyle.important_destructive ||
                            secondActionStyle == ActionStyle.important)
                        ? FontWeight.bold
                        : FontWeight.normal),
          ),
        ),
      );
    }

    return CupertinoAlertDialog(
      title: Text(title),
      content: Text(message),
      actions: actions,
    );
  }
}
