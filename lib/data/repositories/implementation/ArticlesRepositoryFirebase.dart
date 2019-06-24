import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmsmart_flutter/data/model/article_entity.dart';
import 'FlameLink.dart';
import '../../firebase_const.dart';
import '../ArticleRepositoryInterface.dart';

ArticleEntity _transform(FlameLink cms, DocumentSnapshot snapshot) {
  var article = ArticleEntity.articleFromDocument(snapshot);
  article.related = ArticleEntityCollectionFlamelink.list(cms: cms, paths: article.relatedArticlesPathReference);
  return article;
}

class ArticleEntityCollectionFlamelink implements ArticleEntityCollection {
  final FlameLink _cms;
  final Query _query;
  final List<String> _paths;

  ArticleEntityCollectionFlamelink({FlameLink cms, Query query}) : _cms = cms, _query = query, _paths = [];

  ArticleEntityCollectionFlamelink.list( {FlameLink cms, List<String> paths}) : _cms = cms, _paths = paths, _query = null; 

  @override
  Future<List<ArticleEntity>> getEntities({int limit = 0}) async {
    if (_paths.isNotEmpty) {
      return _cms.get(_paths).then((snapshots) {
        return snapshots.map((document) => _transform(_cms, document)).toList();
    });
    }
    return _query.getDocuments().then((snapshot) {
      return snapshot.documents
          .map((document) => _transform(_cms, document))
          .toList();
    });
  }
}

class ArticlesRepositoryFlameLink implements ArticleRepositoryInterface {
  final FlameLink _cms;
  static final _articleSchema = "article";

  ArticlesRepositoryFlameLink(FlameLink cms) : _cms = cms;

  @override
  Future<ArticleEntity> getArticle(uri) {
    if (uri.isEmpty) {
      return null;
    }
    final baseCollection = _cms.content();
    return baseCollection
        .document(uri)
        .get()
        .then((snapshot) => _transform(_cms, snapshot));
  }

  @override
  Stream<ArticleEntity> observeArticle(uri) {
    if (uri.isEmpty) {
      return null;
    }
    final baseCollection = _cms.content();
    final _typeTransform =
        StreamTransformer<DocumentSnapshot, ArticleEntity>.fromHandlers(
            handleData: (snapshot, sink) {
      sink.add(_transform(_cms, snapshot));
    });
    return baseCollection.document(uri).snapshots().transform(_typeTransform);
  }

  @override
  Future<List<ArticleEntity>> getArticles(ArticleEntityCollection collection) {
    return collection.getEntities();
  }

  @override
  Future<List<ArticleEntity>> get(
      {ArticleCollectionGroup group = ArticleCollectionGroup.all,
      int limit = 0}) {
    //NB: for now there is only one  group (all articles)
    final publishedDocuments = _cms.documentsQuery(schema: _articleSchema, limit: limit).where(PUBLICATION_STATUS, isEqualTo: DataStatus.PUBLISHED);
    var collection;
    switch (group) {
      default:
        collection = ArticleEntityCollectionFlamelink(cms: _cms, query: publishedDocuments);
    }
    return collection.getEntities();
  }
}
