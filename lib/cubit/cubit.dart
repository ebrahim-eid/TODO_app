import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:to_do_app/cubit/states.dart';

class TodoCubit extends Cubit<TodoStates> {
  TodoCubit() : super(TodoInitialState());

  static TodoCubit get(context) => BlocProvider.of(context);

  late Database database;

  List<Map> tasks = [];

  int currentIndex = 0;
  void createDatabase() {
    openDatabase('path.db', version: 1, onCreate: (database, version) {
      print('oncreate');
      database
          .execute(
              'CREATE TABLE tasks (id INTEGER PRIMARY KEY, title TEXT, time TEXT, date TEXT, notes TEXT)')
          .then((value) {
        print('created');
      }).catchError((error) {
        print('error');
      });
    }, onOpen: (database) {
      getDataFromDatabase(database).then((value) {
        tasks = value;
        print(tasks);
        emit(TodoGetDatabaseState());
      });
      print('opened');
    }).then((value) {
      database = value;
      emit(TodoCreatDatabaseState());
    });
  }

  insertToDatabase({
    required String title,
    required String time,
    required String date,
  }) async {
    await database.transaction((txn) {
      return txn
          .rawInsert(
              'INSERT INTO tasks (title, time, date, notes) VALUES("$title", "$time", "$date" , "notes")')
          .then((value) {
        print('$value inserted');
        emit(TodoInsertDatabaseState());
        getDataFromDatabase(database).then((value) {
          tasks = value;
          print(tasks);
          emit(TodoGetDatabaseState());
        });
      });
    }).catchError((error) {
      print('$error');
    });
  }

  Future<List<Map>> getDataFromDatabase(database) async {
    emit(TodoGetDatabaseState());

    return await database.rawQuery('SELECT * FROM tasks');
  }

  bool isBottomSheetShown = false;
  IconData fabIcon = Icons.add;

  void changeBottomSheetState({required bool isShow, required IconData icon}) {
    isBottomSheetShown = isShow;
    fabIcon = icon;

    emit(TodoChangeBottomSheetState());
  }

  bool isCheck = false;
  IconData checkIcon = Icons.check_box_outline_blank;

  void changeCheckBoxIcon(
      {required IconData checkIconChange,
      required bool line,
      required int id}) {
    isCheck = line;
    checkIcon = checkIconChange;
    emit(TodoChangeCheckIconState());
  }

  void deleteDatabase({required int id}) async {
    database.rawDelete('DELETE FROM tasks WHERE id = ?', [id]).then((value) {
      getDataFromDatabase(database).then((value) {
        tasks = value;
        emit(TodoGetDatabaseState());
      });
    });
  }
}
