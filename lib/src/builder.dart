import 'package:drawerbehavior/drawerbehavior.dart';
import 'package:drawerbehavior/src/menu_item.dart';
import 'package:drawerbehavior/src/menu_list.dart';
import 'package:flutter/material.dart';

typedef SideDrawerItemBuilder = Function(
    BuildContext context, MenuItem menuItem, bool selected);

typedef SideDrawerIndexBuilder = Function(
    BuildContext context, int index, bool selected);

abstract class SideDrawerBuilder<T> {
  List<Widget> build(
      BuildContext context, SideDrawer drawer, MenuController menuController);
  Widget buildItem(BuildContext context, T t, bool selected);
}

class MenuSideDrawerBuilder extends SideDrawerBuilder<MenuItem> {
  final SideDrawerItemBuilder? builder;
  final Menu menu;

  MenuSideDrawerBuilder(
    this.menu,
    this.builder,
  );
  @override
  Widget buildItem(BuildContext context, MenuItem t, bool selected) {
    return builder?.call(context, t, selected);
  }

  Widget buildListItem(
    BuildContext context,
    SideDrawer widget,
    MenuController menuController,
    MenuItem item,
    double animationIntervalStart,
    double animationIntervalEnd,
    int millis,
    double maxDuration,
  ) {
    final isSelected = item.id == widget.selectedItemId;
    Color selectorColor =
        widget.selectorColor ?? Theme.of(context).indicatorColor;
    TextStyle? textStyle = widget.textStyle ??
        Theme.of(context).textTheme.subtitle1?.copyWith(
            color: widget.color.computeLuminance() < 0.5
                ? Colors.white
                : Colors.black);
    final onTap = () {
      widget.onMenuItemSelected?.call(item.id);
      if (widget.hideOnItemPressed) menuController.close();
    };
    bool useAnimation = widget.animation && !widget.peekMenu;

    Widget listItem = InkWell(
      child: builder == null
          ? MenuListItem(
              padding: widget.peekMenu
                  ? EdgeInsets.zero
                  : const EdgeInsets.only(left: 32.0),
              direction: widget.direction,
              title: item.title,
              isSelected: isSelected,
              selectorColor: selectorColor,
              textStyle: item.textStyle ?? textStyle,
              menuView: widget,
              width: widget.maxSlideAmount(context),
              icon: item.icon == null ? item.prefix : Icon(item.icon),
              suffix: item.suffix,
              drawBorder: !useAnimation)
          : Container(
              alignment: Alignment.centerLeft,
              child: Container(
                child: buildItem(context, item, isSelected),
                width: widget.maxSlideAmount(context),
              ),
            ),
      onTap: onTap,
    );

    if (useAnimation)
      return AnimatedMenuListItem(
        menuState: menuController.state,
        isSelected: isSelected,
        duration: Duration(milliseconds: millis),
        curve: Interval(animationIntervalStart / maxDuration,
            animationIntervalEnd / maxDuration,
            curve: Curves.easeOut),
        menuListItem: listItem,
      );
    else {
      return listItem;
    }
  }

  @override
  List<Widget> build(
      BuildContext context, SideDrawer drawer, MenuController menuController) {
    final animationIntervalDuration = 0.5;
    final perListItemDelay =
        menuController.state != MenuState.closing ? 0.15 : 0.0;
    final millis = menuController.state != MenuState.closing
        ? 150 * menu.items.length
        : 600;

    final maxDuration =
        (menu.items.length - 1) * perListItemDelay + animationIntervalDuration;

    int i = 0;
    return menu.items.map((e) {
      final animationIntervalStart = i * perListItemDelay;
      final animationIntervalEnd =
          animationIntervalStart + animationIntervalDuration;
      MenuItem item = menu.items[i];
      i++;
      return buildListItem(context, drawer, menuController, item,
          animationIntervalStart, animationIntervalEnd, millis, maxDuration);
    }).toList();
  }
}

class CountSideDrawerBuilder extends SideDrawerBuilder<int> {
  final SideDrawerIndexBuilder builder;
  final int itemCount;

  CountSideDrawerBuilder(
    this.itemCount,
    this.builder,
  );
  @override
  Widget buildItem(BuildContext context, int t, bool selected) {
    return builder(context, t, selected);
  }

  @override
  List<Widget> build(
      BuildContext context, SideDrawer drawer, MenuController menuController) {
    return List.generate(itemCount, (e) {
      final onTap = () {
        drawer.onMenuItemSelected?.call(e);
        if (drawer.hideOnItemPressed) menuController.close();
      };
      return InkWell(
        child: Container(
          alignment: Alignment.centerLeft,
          child: Container(
            child: buildItem(context, e, drawer.selectedItemId == e),
            width: drawer.maxSlideAmount(context),
          ),
        ),
        onTap: onTap,
      );
    });
  }
}

class WidgetSideDrawerBuilder extends SideDrawerBuilder {
  final Widget child;

  WidgetSideDrawerBuilder(
    this.child,
  );
  @override
  Widget buildItem(BuildContext context, dynamic t, bool selected) {
    return child;
  }

  @override
  List<Widget> build(
      BuildContext context, SideDrawer drawer, MenuController menuController) {
    return [buildItem(context, null, false)];
  }
}