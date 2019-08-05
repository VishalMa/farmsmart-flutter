import 'package:farmsmart_flutter/model/repositories/article/ArticleRepositoryInterface.dart';
import 'package:farmsmart_flutter/model/repositories/article/implementation/MockArticlesRepository.dart';
import 'package:farmsmart_flutter/model/repositories/crop/CropRepositoryInterface.dart';
import 'package:farmsmart_flutter/model/repositories/crop/implementation/MockCropRepository.dart';
import 'package:farmsmart_flutter/model/repositories/plot/PlotRepositoryInterface.dart';
import 'package:farmsmart_flutter/model/repositories/plot/implementation/MockPlotRepository.dart';
import 'package:flutter/widgets.dart';
import 'repository_provider.dart';
import 'transaction/TransactionRepositoryInterface.dart';
import 'transaction/implementation/MockTransactionRepository.dart';


class MockRepositoryProvider implements RepositoryProvider{

  PlotRepositoryInterface _plot = MockPlotRepository();
  CropRepositoryInterface _crop = MockCropRepository();
  TransactionRepositoryInterface _trans = MockTransactionRepository();

  init(BuildContext context){
    //ignore
  }
  
  @override
  ArticleRepositoryInterface getArticleRepository() => MockArticlesRepository();

  @override
  PlotRepositoryInterface getMyPlotRepository() => _plot;

  @override
  CropRepositoryInterface getCropRepository() => _crop;

    @override
  TransactionRepositoryInterface getTransactionRepository() => _trans;

}
