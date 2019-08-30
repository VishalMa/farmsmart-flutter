import 'dart:async';

import 'package:farmsmart_flutter/model/bloc/Transformer.dart';
import 'package:farmsmart_flutter/model/bloc/plot/PlotStatistics.dart';
import 'package:farmsmart_flutter/model/bloc/profile/PersonName.dart';
import 'package:farmsmart_flutter/model/bloc/profile/SwitchProfileListProvider.dart';
import 'package:farmsmart_flutter/model/entities/PlotEntity.dart';
import 'package:farmsmart_flutter/model/entities/ProfileEntity.dart';
import 'package:farmsmart_flutter/model/entities/loading_status.dart';
import 'package:farmsmart_flutter/model/repositories/account/AccountRepositoryInterface.dart';
import 'package:farmsmart_flutter/model/repositories/plot/PlotRepositoryInterface.dart';
import 'package:farmsmart_flutter/model/repositories/profile/ProfileRepositoryInterface.dart';
import 'package:farmsmart_flutter/ui/mockData/MockUserProfileViewModel.dart';
import 'package:farmsmart_flutter/ui/profile/Profile.dart';
import 'package:farmsmart_flutter/ui/profile/ProfileListItem.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import '../ViewModelProvider.dart';

class _LocalisedStrings {
  static logout() => Intl.message('Logout');
  static removeProfile() => Intl.message('Remove Profile');
}

class ProfileDetailProvider
    extends ObjectTransformer<ProfileEntity, ProfileViewModel>
    implements ViewModelProvider<ProfileViewModel> {
  final AccountRepositoryInterface _accountRepository;
  final PlotRepositoryInterface _plotRepository;
  ProfileRepositoryInterface _profileRepository;
  int _activeCrops = 0;
  int _completedCrops = 0;
  ProfileViewModel _snapshot;
  ProfileEntity _currentProfile;
  PlotStatistics _plotStatistics = PlotStatistics();
  LoadingStatus _loadingStatus = LoadingStatus.LOADING;
  final StreamController<ProfileViewModel> _controller =
      StreamController<ProfileViewModel>.broadcast();

  ProfileDetailProvider({
    @required AccountRepositoryInterface accountRepo,
    @required PlotRepositoryInterface plotRepo,
  })  : this._accountRepository = accountRepo,
        this._plotRepository = plotRepo;

  @override
  Stream<ProfileViewModel> stream() {
    return _controller.stream;
  }

  @override
  ProfileViewModel snapshot() {
    return _snapshot;
  }

  @override
  ProfileViewModel initial() {
    if (_snapshot == null) {
      _accountRepository.observeAuthorized().listen((currentAccount) {
        _profileRepository = currentAccount?.profileRepository;
        currentAccount?.profileRepository
            ?.observeCurrent()
            ?.listen((currentProfile) {
          _loadingStatus = LoadingStatus.SUCCESS;
          _currentProfile = currentProfile;
          _snapshot = transform(from: currentProfile);
          _controller.sink.add(_snapshot);
        });
      });

      _plotRepository.observeFarm().listen((List<PlotEntity> plots) {
        _activeCrops = _plotStatistics.activeCount(plots);
        _completedCrops = _plotStatistics.compeletedCount(plots);
        _update();
      });

      _snapshot = transform(from: null);
      _snapshot.refresh();
    }
    return _snapshot;
  }

  @override
  ProfileViewModel transform({ProfileEntity from}) {
    List<ProfileListItemViewModel> list = _profileItems();
    final switchProfileProvider =
        SwitchProfileListProvider(profileRepo: _profileRepository);
    final personName = PersonName(from?.name ?? "");
    return ProfileViewModel(
      loadingStatus: _loadingStatus,
      username: personName.fullname,
      initials: personName.initials,
      refresh: _refresh,
      remove: () => _remove(),
      logout: () => _logout(),
      items: list,
      image: from?.avatar,
      activeCrops: _activeCrops,
      completedCrops: _completedCrops,
      switchProfileProvider: switchProfileProvider,
    );
  }

  List<ProfileListItemViewModel> _profileItems() {
    List<ProfileListItemViewModel> list = []; //TODO; replace with real items

    for (var i = 0; i < 7; i++) {
      list.add(MockUserProfileListItemViewModel.build(i));
    }

    list.add(ProfileListItemViewModel(
      title: _LocalisedStrings.removeProfile(),
      icon: null,
      onTap: () => _remove(),
      isDestructive: true,
    ));

    list.add(ProfileListItemViewModel(
      title: _LocalisedStrings.logout(),
      icon: null,
      onTap: () => _logout(),
      isDestructive: true,
    ));
    return list;
  }

  Future<bool> _logout() {
    _loadingStatus = LoadingStatus.LOADING;
    _update();
    return _accountRepository.deauthorize();
  }

  Future<bool> _remove() {
    return _profileRepository.remove(_currentProfile).then((success) {
      _profileRepository.getAll().then((profiles) {
        final profile = profiles.isNotEmpty ? profiles.first : null;
        _profileRepository.switchTo(profile);
      });
      return success;
    });
  }

  void _update() {
    _snapshot = transform(from: _currentProfile);
    _controller.sink.add(_snapshot);
  }

  void _refresh() {
    _accountRepository.authorized().then((account) {
      _profileRepository.getCurrent();
      _plotRepository.getFarm();
    });
  }

  void dispose() {
    _controller.sink.close();
    _controller.close();
  }
}
