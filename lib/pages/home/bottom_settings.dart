import 'package:flutter/material.dart';
import 'package:one_article/bean/button_bean.dart';
import 'package:one_article/generated/i18n.dart';
import 'package:one_article/utils/constant.dart';
import 'package:one_article/utils/date_util.dart';

typedef DateCallback = void Function(String date);

class BottomSettings {
  final BuildContext context;

  BottomSettings(this.context);

  Row fontSizeSelector(double _fontSize, int _themeColorIndex, onChanged) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          S.of(context).action_font_size,
        ),
        Expanded(
            child: Slider(
          onChanged: onChanged,
          divisions: 16,
          label: "${_fontSize.round()}",
          value: _fontSize,
          activeColor: themeColors[_themeColorIndex],
          min: 10,
          max: 26,
        )),
      ],
    );
  }

  Row themeSelector(TabController tabController, int _themeColorIndex, onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          S.of(context).action_theme,
        ),
        Expanded(
          child: TabBar(
            tabs: themeTabs(),
            isScrollable: false,
            controller: tabController,
            indicatorPadding: const EdgeInsets.only(left: 12, right: 12),
            onTap: onTap,
            indicatorColor: themeColors[_themeColorIndex],
          ),
        )
      ],
    );
  }

  List<Tab> themeTabs() {
    List<Tab> tabs = List();
    for (Color color in themeColors) {
      tabs.add(Tab(icon: Icon(Icons.markunread_mailbox, color: color)));
    }
    return tabs;
  }

  Widget articleChange(Color themeColor, String current, DateCallback onPress) {
    return Expanded(
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: getArticleChangeButtons(themeColor, current, onPress)),
    );
  }

  List<Widget> getArticleChangeButtons(
      Color themeColor, String current, DateCallback onPress) {
    List<Widget> buttons = List();
    List<ButtonBean> buttonIds = List();

    DateTime today = DateTime.now();
    DateTime currentDate = str2Date(current);
    int year = currentDate?.year;
    int month = currentDate?.month;
    int day = currentDate?.day;

    buttonIds.add(ButtonBean(context, -1, current));
    buttonIds.add(ButtonBean(context, 2, current));
    if (today.year != year || today.month != month || today.day != day) {
      buttonIds.add(ButtonBean(context, 1, current));
      buttonIds.add(ButtonBean(context, 0, current));
    }

    for (ButtonBean bean in buttonIds) {
      buttons.add(MaterialButton(
        color: themeColor,
        textColor: Colors.white,
        child: Text(bean.buttonText),
        onPressed: () {
          onPress(bean.date);
        },
      ));
    }

    return buttons;
  }

  Widget starredList(bool starred, Color themeColor,
      Function onStarredPressed, Function onStarredListPressed) {
    TextStyle style = const TextStyle(color: Colors.white);
    return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      MaterialButton(
        child: Row(children: <Widget>[
          Icon(starred ? Icons.star : Icons.star_border, color: Colors.white,),
          Text(starred ? S.of(context).action_starred : S.of(context).action_not_starred, style: style,)
        ],),
        color: themeColor,
        onPressed: onStarredPressed,
      ),
      MaterialButton(
        child: Row(children: <Widget>[
          Icon(
            Icons.list,
            color: Colors.white,
          ),
          Text(S.of(context).action_starred_list, style: style,)
        ], ),
        onPressed: onStarredListPressed,
        color: themeColor,
      )
    ]);
  }
}
