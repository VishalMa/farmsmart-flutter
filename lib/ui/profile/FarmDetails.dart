import 'package:farmsmart_flutter/ui/common/ActionSheet.dart';
import 'package:farmsmart_flutter/ui/common/ActionSheetListItem.dart';
import 'package:farmsmart_flutter/ui/common/Alert.dart';
import 'package:farmsmart_flutter/ui/common/ContextualAppBar.dart';
import 'package:farmsmart_flutter/ui/common/ListDivider.dart';
import 'package:farmsmart_flutter/ui/common/roundedButton.dart';
import 'package:farmsmart_flutter/ui/profile/FarmDetailsListItem.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class _Strings {
  static final String yourFarmDetails = 'Your Farm Details';
  static final String cancel = 'Cancel';
  static final String editProfile = 'Edit Profile';
  static final String deleteProfile = 'Delete Profile';
  static final String delete = 'Delete';
  static final String deleteProfileDescription =
      'Are you sure you want to delete your profile? Doing so will erase '
      'all data and this action cannot be undone.';
}

class _Constants {
  static final EdgeInsets floatingButtonEdgePadding = const EdgeInsets.all(32);
  static final EdgeInsets headerEdgePadding =
      const EdgeInsets.only(left: 32, right: 32, top: 10.5, bottom: 16);

  static final double bottomMargin = 112;
  static final double buttonHeight = 48;

  static final BorderRadius buttonRadius = BorderRadius.all(
    Radius.circular(12),
  );
}

class FarmDetailsViewModel {
  final List<FarmDetailsListItemViewModel> items;
  final String buttonTitle;
  final Function confirm;
  final Function editProfile;
  final Function removeProfile;

  FarmDetailsViewModel({
    this.items,
    this.buttonTitle,
    this.confirm,
    this.removeProfile,
    this.editProfile,
  });
}

class FarmDetailsStyle {
  final TextStyle titleTextStyle;
  final TextStyle buttonTextStyle;

  const FarmDetailsStyle({
    this.titleTextStyle,
    this.buttonTextStyle,
  });

  FarmDetailsStyle copyWith({
    TextStyle titleTextStyle,
    TextStyle buttonTextStyle,
  }) {
    return FarmDetailsStyle(
      titleTextStyle: titleTextStyle ?? this.titleTextStyle,
      buttonTextStyle: buttonTextStyle ?? this.buttonTextStyle,
    );
  }
}

class _DefaultStyle extends FarmDetailsStyle {
  final TextStyle titleTextStyle = const TextStyle(
    color: Color(0xff1a1b46),
    fontSize: 27,
    fontWeight: FontWeight.w700,
  );

  final TextStyle buttonTextStyle = const TextStyle(
    color: Color(0xffffffff),
    fontSize: 15,
    fontWeight: FontWeight.w500,
  );

  const _DefaultStyle({
    TextStyle titleTextStyle,
  });
}

const FarmDetailsStyle _defaultStyle = const _DefaultStyle();

class FarmDetails extends StatelessWidget {
  final FarmDetailsViewModel _viewModel;
  final FarmDetailsStyle _style;

  const FarmDetails({
    Key key,
    FarmDetailsViewModel viewModel,
    FarmDetailsStyle style = _defaultStyle,
  })  : this._viewModel = viewModel,
        this._style = style,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context, _viewModel),
      body: buildPage(context),
      floatingActionButton: Padding(
        padding: _Constants.floatingButtonEdgePadding,
        child: RoundedButton(
          viewModel: RoundedButtonViewModel(
            title: _viewModel.buttonTitle,
            onTap: () => _viewModel.confirm(),
          ),
          style: RoundedButtonStyle.largeRoundedButtonStyle().copyWith(
            height: _Constants.buttonHeight,
            borderRadius: _Constants.buttonRadius,
            buttonTextStyle: _style.buttonTextStyle,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget buildPage(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildHeader(),
          _buildList(),
          ListDivider.build(),
          SizedBox(
            height: _Constants.bottomMargin,
          )
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: _Constants.headerEdgePadding,
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              Intl.message(_Strings.yourFarmDetails),
              style: _style.titleTextStyle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    return ListView.separated(
      primary: false,
      itemBuilder: (context, index) => FarmDetailsListItem(
        viewModel: _viewModel.items[index],
      ),
      shrinkWrap: true,
      separatorBuilder: (context, index) => ListDivider.build(),
      itemCount: _viewModel.items.length,
    );
  }

  Widget _buildAppBar(BuildContext context, FarmDetailsViewModel viewModel) {
    return ContextualAppBar(
      moreAction: () => _moreTapped(
        _moreMenu(viewModel, context),
        context,
      ),
    ).build(context);
  }

  void _moreTapped(ActionSheet sheet, BuildContext context) {
    ActionSheet.present(sheet, context);
  }

  void _removeAction(FarmDetailsViewModel viewModel, BuildContext context) {
    Alert.present(
      Alert(
        viewModel: AlertViewModel(
          cancelActionText: Intl.message(_Strings.cancel),
          confirmActionText: Intl.message(_Strings.delete),
          titleText: Intl.message(_Strings.deleteProfile),
          detailText: Intl.message(_Strings.deleteProfileDescription),
          isDestructive: true,
          confirmAction: () {
            viewModel.removeProfile();
            Navigator.of(context).pop();
          },
        ),
      ),
      context,
    );
  }

  void _editAction(FarmDetailsViewModel viewModel) {
    viewModel.editProfile(); //TODO: add the UI for input when ready (Chat)
  }

  ActionSheet _moreMenu(FarmDetailsViewModel viewModel, BuildContext context) {
    final actions = [
      ActionSheetListItemViewModel(
        title: Intl.message(_Strings.editProfile),
        type: ActionType.simple,
        onTap: () => _editAction(viewModel),
      ),
      ActionSheetListItemViewModel(
        title: Intl.message(_Strings.deleteProfile),
        type: ActionType.simple,
        isDestructive: true,
        onTap: () => _removeAction(viewModel, context),
      ),
    ];
    final actionSheetViewModel = ActionSheetViewModel(
      actions,
      Intl.message(_Strings.cancel),
    );
    return ActionSheet(
      viewModel: actionSheetViewModel,
      style: ActionSheetStyle.defaultStyle(),
    );
  }
}