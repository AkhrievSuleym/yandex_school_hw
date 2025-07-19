import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:yandex_shmr_hw/core/error/failure.dart';
import 'package:yandex_shmr_hw/core/network/connectivity_service.dart';
import 'package:yandex_shmr_hw/core/sync/sync_service.dart';
import 'package:yandex_shmr_hw/features/finance/data/local_datasource/categories_local_datasource.dart';
import 'package:yandex_shmr_hw/features/finance/data/local_datasource/operation_local_datasource.dart';
import 'package:yandex_shmr_hw/features/finance/data/mocks.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/category/category_model.dart';
import 'package:yandex_shmr_hw/features/finance/data/remote_datasource/category_remote_ds.dart';
import 'package:yandex_shmr_hw/features/finance/domain/repository/category_repository.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoriesLocalDatasource _categoryLocalDataSource;
  final CategoryRemoteDatasource _categoryRemoteDataSource;
  final OperationLocalDatasource
  _operationLocalDataSource; // Все еще нужен для логирования операций
  final ConnectivityService _connectivityService;
  final SyncService _syncService;

  CategoryRepositoryImpl(
    this._categoryLocalDataSource,
    this._categoryRemoteDataSource,
    this._operationLocalDataSource,
    this._connectivityService,
    this._syncService, // Инжектируем SyncService
  );

  // Вспомогательная функция для маппинга любых других исключений в Failure
  Failure _mapLocalExceptionToFailure(Object e) {
    return Failure('Ошибка при обработке локальных данных: ${e.toString()}');
  }

  @override
  Future<Either<Failure, List<CategoryModel>>> getAllCategories() async {
    try {
      // 1. Попытка синхронизировать ожидающие операции через SyncService.
      final syncResult = await _syncService.syncPendingOperations();
      if (syncResult.isLeft()) {
        print(
          'Синхронизация ожидающих операций не удалась при получении категорий, пробуем локально.',
        );
      }

      // 2. Если есть соединение, пытаемся получить актуальные данные с бэкенда.
      if (await _connectivityService.isConnected()) {
        try {
          final remoteCategories = await _categoryRemoteDataSource
              .getCategories();
          // Обновляем локальный кэш полным списком категорий с сервера
          await _categoryLocalDataSource.clearAndInsertAll(remoteCategories);
          return right(remoteCategories);
        } on DioException catch (e) {
          print(
            'Ошибка при загрузке категорий с сервера, используем локальные данные.',
          );
          return await _getCategoriesLocally();
        } on Exception catch (e) {
          print(
            'Неизвестная ошибка при загрузке категорий с сервера, используем локальные данные: ${e.toString()}',
          );
          return await _getCategoriesLocally();
        }
      } else {
        print('Нет сети, получаем категории локально.');
        return await _getCategoriesLocally();
      }
    } catch (e) {
      return left(_mapLocalExceptionToFailure(e));
    }
  }

  /// Вспомогательный метод для получения категорий только из локальной БД.
  Future<Either<Failure, List<CategoryModel>>> _getCategoriesLocally() async {
    try {
      final localCategories = await _categoryLocalDataSource.getAllCategories();
      return right(localCategories);
    } catch (e) {
      return left(_mapLocalExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<CategoryModel>>> getCategoriesByType(
    bool isIncome,
  ) async {
    try {
      // 1. Попытка синхронизировать ожидающие операции через SyncService.
      final syncResult = await _syncService.syncPendingOperations();
      if (syncResult.isLeft()) {
        print(
          'Синхронизация ожидающих операций не удалась при получении категорий по типу, пробуем локально.',
        );
      }

      // 2. Если есть соединение, пытаемся получить актуальные данные с бэкенда.
      if (await _connectivityService.isConnected()) {
        try {
          final remoteCategories = await _categoryRemoteDataSource
              .getCategoriesByType(isIncome);
          return right(remoteCategories);
        } on DioException catch (e) {
          print(
            'Ошибка при загрузке категорий по типу с сервера, используем локальные данные.',
          );
          return await _getCategoriesByTypeLocally(isIncome);
        } on Exception catch (e) {
          print(
            'Неизвестная ошибка при загрузке категорий по типу с сервера, используем локальные данные: ${e.toString()}',
          );
          return await _getCategoriesByTypeLocally(isIncome);
        }
      } else {
        print('Нет сети, получаем категории по типу локально.');
        return await _getCategoriesByTypeLocally(isIncome);
      }
    } catch (e) {
      return left(_mapLocalExceptionToFailure(e));
    }
  }

  /// Вспомогательный метод для получения категорий по типу только из локальной БД.
  Future<Either<Failure, List<CategoryModel>>> _getCategoriesByTypeLocally(
    bool isIncome,
  ) async {
    try {
      final localCategories = await _categoryLocalDataSource
          .getCategoriesByType(isIncome);
      return right(localCategories);
    } catch (e) {
      return left(_mapLocalExceptionToFailure(e));
    }
  }

  final _mockCategories = CategoriesMockData.mockCategories
      .map((json) => CategoryModel.fromJson(json))
      .toList();
}
