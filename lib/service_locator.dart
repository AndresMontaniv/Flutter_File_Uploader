import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

import 'data/data.dart';
import 'domain/domain.dart';
import 'presentation/presentation.dart';

final sl = GetIt.instance;

void setup() {
  // Register external dependencies
  sl.registerLazySingleton(() => http.Client());

  // Base URL for the API
  const baseUrl = 'http://184.168.22.152:3000';
  sl.registerSingleton<AppConfig>(AppConfig(baseUrl: baseUrl));

  // Register data sources
  sl.registerLazySingleton<CloudFileDataSource>(
    () => CloudFileRemoteDataSourceImpl(client: sl(), baseUrl: baseUrl),
  );

  // Register repositories
  sl.registerLazySingleton<CloudFileRepository>(
    () => CloudFileRepositoryImpl(remoteDataSource: sl()),
  );

  // Register use cases
  sl.registerLazySingleton(() => GetFiles(sl()));
  sl.registerLazySingleton(() => GetFile(sl()));
  sl.registerLazySingleton(() => DeleteFile(sl()));
  sl.registerLazySingleton(() => UploadFile(sl()));

  // Register BLoC
  sl.registerFactory(() => FileBloc(
        getFiles: sl(),
        getFile: sl(),
        deleteFile: sl(),
        uploadFile: sl(),
      ));
}
