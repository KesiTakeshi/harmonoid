import 'dart:async';
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:harmonoid/globals.dart' as Globals;
import 'package:harmonoid/scripts/globalspersistent.dart';
import 'package:harmonoid/about.dart';


class ColorPicker extends StatefulWidget {
  ColorPicker({Key key}) : super(key: key);
  ColorPickerState createState() => ColorPickerState();
}

class ColorPickerState extends State<ColorPicker> with TickerProviderStateMixin {

  List<AnimationController> _checkControllerList = new List<AnimationController>();
  List<Widget> _colorButtonList = [Container()];

  @override
  void initState() {
    super.initState();
    this._colorButtonList.clear();
    for (int index = 0; index < Globals.colors.length; index++) {
      this._checkControllerList.add(
        AnimationController(
          vsync: this,
          lowerBound: 0.0,
          upperBound: 1.0,
          duration: Duration(milliseconds: 200),
          reverseDuration: Duration(microseconds: 200),
        ),
      );
      this._colorButtonList.add(
        Stack(
          alignment: Alignment.center,
          children: [
            ClipOval(
              child: Container(
                alignment: Alignment.center,
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: InkWell(
                  splashColor: Color(0x00000000),
                  highlightColor: Color(0x00000000),
                  focusColor: Color(0x00000000),
                  hoverColor: Color(0x00000000),
                  onTap: () async {
                    this._checkControllerList[index].forward();
                    await GlobalsPersistent.changeConfiguration('accent', index);
                    for (int i = 0; i < Globals.colors.length; i++) {
                      if (i == index) this._checkControllerList[i].forward();
                      else this._checkControllerList[i].reverse();
                    }
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Container(
                          color: Globals.colors[index][0],
                        ),
                      ),
                      Expanded(
                        child: Container(
                          color: Globals.colors[index][1],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            AnimatedBuilder(
              animation: this._checkControllerList[index],
              child: Icon(
                Icons.check,
                color: Colors.white,
                size: 28,
              ),
              builder: (BuildContext context, Widget child) => ScaleTransition(
                alignment: Alignment.center,
                child: child,
                scale: this._checkControllerList[index].view,
              ),
            )
          ],
        ),
      );
      this.setState(() {});
    }
    this._checkControllerList[Globals.globalColor].forward();
  }

  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 16, bottom: 16),
      child: Container(
        width: MediaQuery.of(context).size.width,
        child: GridView.count(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          crossAxisCount: 4,
          children: this._colorButtonList,
        ),
      ),
    );
  }
}

enum LanguageRegion {
  enUs,
  ruRu,
  slSi,
  ptBr,
  hiIn,
  deDe,
}

class Setting extends StatefulWidget {
  Setting({Key key}) : super(key : key);
  SettingState createState() => SettingState();
}

class SettingState extends State<Setting> {

  TextEditingController _serverInputController = new TextEditingController(text: Globals.STRING_HOME_URL);
  LanguageRegion _language;
  Widget _serverLabelWidget = Container(
    height: 18,
  );

  void _updateServerURL(String url) {
    this.setState(() {
      this._serverLabelWidget = Container(
        height: 18,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.info,
              color: Theme.of(context).primaryColor,
              size: 24,
            ),
            Padding(
              padding: EdgeInsets.only(left: 8),
              child: Text(
                Globals.STRING_SETTING_SERVER_CHANGE_CHANGING,
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ); 
    });
    http.get(Uri.https(url, '/', {}))
    .then((response) {
      this.setState(() {
        if (response.body == Globals.VERIFICATION_STRING) {
          Globals.STRING_HOME_URL = url;
          GlobalsPersistent.changeConfiguration('server', url);
          this._serverLabelWidget = Container(
            height: 18,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.check,
                  color: Colors.green,
                  size: 24,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Text(
                    Globals.STRING_SETTING_SERVER_CHANGE_DONE,
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        else {
          this._serverLabelWidget = Container(
            height: 18,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.close,
                  color: Colors.red,
                  size: 24,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Text(
                    Globals.STRING_SETTING_SERVER_CHANGE_ERROR_INVALID,
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      });
    })
    .catchError((error) => this.setState(() {
      print(error);
      this._serverLabelWidget = Container(
        height: 18,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.close,
              color: Colors.red,
              size: 24,
            ),
            Padding(
              padding: EdgeInsets.only(left: 8),
              child: Text(
                Globals.STRING_SETTING_SERVER_CHANGE_ERROR_NETWORK,
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      );
    }));
  }

  String _serverURL = Globals.STRING_HOME_URL;

  void _showRestartDialog() {
    Timer(Duration(milliseconds: 400), () => showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(Globals.STRING_SETTING_LANGUAGE_RESTART_DIALOG_TITLE),
        content: Text(Globals.STRING_SETTING_LANGUAGE_RESTART_DIALOG_SUBTITLE),
        actions: [
          MaterialButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              Globals.STRING_OK,
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
          ),
        ],
      ),
    ));
  }

  @override
  void initState() {
    super.initState();

    GlobalsPersistent.getConfiguration('language')
    .then((value) {
      this.setState(() {
        if (value == 'en_us') this._language = LanguageRegion.enUs;
        else if (value == 'ru_ru') this._language = LanguageRegion.ruRu;
        else if (value == 'sl_si') this._language = LanguageRegion.slSi; 
        else if (value == 'pt_br') this._language = LanguageRegion.ptBr; 
        else if (value == 'hi_in') this._language = LanguageRegion.hiIn; 
        else if (value == 'de_de') this._language = LanguageRegion.deDe; 
      });
    });
  }

  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      child: ListView(
        scrollDirection: Axis.vertical,
        children: [
          Card(
            elevation: 1,
            margin: EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
            child: Container(
              width: MediaQuery.of(context).size.width - 32,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(left: 16, right: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Divider(
                          color: Color(0x00000000),
                          height: 16,
                          thickness: 0,
                        ),
                        Text(
                          Globals.STRING_SETTING_ACCENT_COLOR_TITLE,
                          maxLines: 1,
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 18,
                          ),
                        ),
                        Divider(
                          color: Color(0x00000000),
                          height: 4,
                          thickness: 0,
                        ),
                        Text(
                          Globals.STRING_SETTING_ACCENT_COLOR_SUBTITLE,
                          maxLines: 1,
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 14,
                          ),
                        ),
                        Divider(
                          color: Color(0x00000000),
                          height: 16,
                          thickness: 0,
                        ),
                      ],
                    ),
                  ),
                  ColorPicker(),
                  Divider(
                    color: Color(0x00000000),
                    height: 8,
                    thickness: 0,
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 16, right: 16),
                    child: Text(
                      Globals.STRING_SETTING_LANGUAGE_RESTART_DIALOG_SUBTITLE,
                      maxLines: 1,
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Divider(
                    color: Color(0x00000000),
                    height: 16,
                    thickness: 0,
                  ),
                ],
              ),
            ),
          ),
          Card(
            elevation: 1,
            margin: EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
            child: Container(
              width: MediaQuery.of(context).size.width - 32,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(left: 16, right: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Divider(
                          color: Color(0x00000000),
                          height: 16,
                          thickness: 0,
                        ),
                        Text(
                          Globals.STRING_SETTING_LANGUAGE_TITLE,
                          maxLines: 1,
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 18,
                          ),
                        ),
                        Divider(
                          color: Color(0x00000000),
                          height: 4,
                          thickness: 0,
                        ),
                        Text(
                          Globals.STRING_SETTING_LANGUAGE_SUBTITLE,
                          maxLines: 1,
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 14,
                          ),
                        ),
                        Divider(
                          color: Color(0x00000000),
                          height: 16,
                          thickness: 0,
                        ),
                      ],
                    ),
                  ),
                  ListTile(
                    title: Text('English'),
                    subtitle: Text('United States'),
                    onTap: () {
                      GlobalsPersistent.changeConfiguration('language', 'en_us');
                      this.setState(() {
                        this._language = LanguageRegion.enUs;
                      });
                      this._showRestartDialog();
                    },
                    leading: Radio(
                      value: LanguageRegion.enUs,
                      groupValue: this._language,
                      onChanged: (LanguageRegion language) {
                        GlobalsPersistent.changeConfiguration('language', 'en_us');
                        this.setState(() {
                          this._language = language;
                        });
                        this._showRestartDialog();
                      },
                    ),
                  ),
                  ListTile(
                    title: Text('Русский'),
                    subtitle: Text('Россия'),
                    onTap: () {
                      GlobalsPersistent.changeConfiguration('language', 'ru_ru');
                      this.setState(() {
                        this._language = LanguageRegion.ruRu;
                      });
                      this._showRestartDialog();
                    },
                    leading: Radio(
                      value: LanguageRegion.ruRu,
                      groupValue: this._language,
                      onChanged: (LanguageRegion language) {
                        GlobalsPersistent.changeConfiguration('language', 'ru_ru');
                        this.setState(() {
                          this._language = language;
                        });
                        this._showRestartDialog();
                      },
                    ),
                  ),
                  ListTile(
                    title: Text('Slovenščina'),
                    subtitle: Text('Slovenia'),
                    onTap: () {
                      GlobalsPersistent.changeConfiguration('language', 'sl_si');
                      this.setState(() {
                        this._language = LanguageRegion.slSi;
                      });
                      this._showRestartDialog();
                    },
                    leading: Radio(
                      value: LanguageRegion.slSi,
                      groupValue: this._language,
                      onChanged: (LanguageRegion language) {
                        GlobalsPersistent.changeConfiguration('language', 'sl_si');
                        this.setState(() {
                          this._language = language;
                        });
                        this._showRestartDialog();
                      },
                    ),
                  ),
                  ListTile(
                    title: Text('Português'),
                    subtitle: Text('Brasil'),
                    onTap: () {
                      GlobalsPersistent.changeConfiguration('language', 'pt_br');
                      this.setState(() {
                        this._language = LanguageRegion.ptBr;
                      });
                      this._showRestartDialog();
                    },
                    leading: Radio(
                      value: LanguageRegion.ptBr,
                      groupValue: this._language,
                      onChanged: (LanguageRegion language) {
                        GlobalsPersistent.changeConfiguration('language', 'pt_br');
                        this.setState(() {
                          this._language = language;
                        });
                        this._showRestartDialog();
                      },
                    ),
                  ),
                  ListTile(
                    title: Text('हिन्दी'),
                    subtitle: Text('भारत'),
                    onTap: () {
                      GlobalsPersistent.changeConfiguration('language', 'hi_in');
                      this.setState(() {
                        this._language = LanguageRegion.hiIn;
                      });
                      this._showRestartDialog();
                    },
                    leading: Radio(
                      value: LanguageRegion.hiIn,
                      groupValue: this._language,
                      onChanged: (LanguageRegion language) {
                        GlobalsPersistent.changeConfiguration('language', 'hi_in');
                        this.setState(() {
                          this._language = language;
                        });
                        this._showRestartDialog();
                      },
                    ),
                  ),
                  ListTile(
                    title: Text('Deutsche'),
                    subtitle: Text('Deutschland'),
                    onTap: () {
                      GlobalsPersistent.changeConfiguration('language', 'de_de');
                      this.setState(() {
                        this._language = LanguageRegion.deDe;
                      });
                      this._showRestartDialog();
                    },
                    leading: Radio(
                      value: LanguageRegion.deDe,
                      groupValue: this._language,
                      onChanged: (LanguageRegion language) {
                        GlobalsPersistent.changeConfiguration('language', 'de_de');
                        this.setState(() {
                          this._language = language;
                        });
                        this._showRestartDialog();
                      },
                    ),
                  ),
                  Divider(
                    color: Colors.white,
                    height: 16,
                    thickness: 0,
                  ),
                ],
              ),
            ),
          ),
          Card(
            elevation: 1,
            margin: EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
            child: Container(
              width: MediaQuery.of(context).size.width - 32,
              child: Column(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(left: 16, right: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Divider(
                          color: Color(0x00000000),
                          height: 16,
                          thickness: 0,
                        ),
                        Text(
                          Globals.STRING_SETTING_SERVER_CHANGE_TITLE,
                          maxLines: 1,
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 18,
                          ),
                        ),
                        Divider(
                          color: Color(0x00000000),
                          height: 4,
                          thickness: 0,
                        ),
                        Text(
                          Globals.STRING_SETTING_SERVER_CHANGE_SUBTITLE,
                          maxLines: 1,
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 14,
                          ),
                        ),
                        Divider(
                          color: Color(0x00000000),
                          height: 16,
                          thickness: 0,
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 16, bottom: 16),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: this._serverInputController,
                                  onSubmitted: (value) => this._updateServerURL(value),
                                  onChanged: (value) => this._serverURL = value,
                                  autocorrect: false,
                                  autofocus: false,
                                  cursorWidth: 1,
                                  cursorColor: Theme.of(context).primaryColor,
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 16,
                                  ),
                                  decoration: InputDecoration(
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1.0),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1.0),
                                    ),
                                    hintText: Globals.STRING_SETTING_SERVER_CHANGE_SERVER_HINT,
                                    hintStyle: TextStyle(
                                      color: Colors.black26,
                                    ),
                                    labelText: Globals.STRING_SETTING_SERVER_CHANGE_SERVER_LABEL,
                                    labelStyle: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                height: 56,
                                width: 56,
                                alignment: Alignment.center,
                                child: IconButton(
                                  onPressed: () => this._updateServerURL(this._serverURL),
                                  icon: Icon(
                                    Icons.check,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  iconSize: 24,
                                  splashRadius: 20,
                                ),
                              )
                            ],
                          ),
                        ),
                        this._serverLabelWidget,
                        Divider(
                          color: Color(0x00000000),
                          height: 16,
                          thickness: 0,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          OpenContainer(
            closedElevation: 0,
            closedColor: Color(0x00000000),
            openElevation: 0,
            openColor: Color(0x00000000),
            transitionDuration: Duration(milliseconds: 400),
            closedBuilder: (ctx, act) => Card(
              margin: EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
              child: ListTile(
                title: Text(Globals.STRING_ABOUT_TITLE),
                subtitle: Text(Globals.STRING_ABOUT_SUBTITLE),
              ),
            ),
            openBuilder: (ctx, act) => AboutScreen(),
          ),
        ],
      ),
    );
  }
}