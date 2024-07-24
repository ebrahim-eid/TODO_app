import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';

// ignore: must_be_immutable
class HomeLayout extends StatefulWidget {
  const HomeLayout({super.key});

  @override
  State<HomeLayout> createState() => _HomeLayoutState();
}

class _HomeLayoutState extends State<HomeLayout> {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  var formKey = GlobalKey<FormState>();
  var titleController = TextEditingController();
  var timeController = TextEditingController();
  var dateController = TextEditingController();
  bool isBottomSheetShown = false;
  IconData fabIcon = Icons.add;
  late Database database;
  Set<int> selectedIndices = <int>{};

  List<Map> tasks = [];

  /// bottom sheet state
  void changeBottomSheetState({required bool isShow, required IconData icon}) {
    isBottomSheetShown = isShow;
    fabIcon = icon;
    setState(() {});
  }

  /// create database
  void createDatabase() {
    openDatabase(
        'path.db',
        version: 1,
        onCreate: (database, version) {
      database
          .execute(
              'CREATE TABLE tasks (id INTEGER PRIMARY KEY, title TEXT, time TEXT, date TEXT, notes TEXT)');
    },
        onOpen: (database) {
      getDataFromDatabase(database).then((value) {
        tasks = value;
        setState(() {});
      });
    }).then((value) {
      database = value;
      setState(() {});
    });
  }

  /// inset to database

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
        setState(() {});
        getDataFromDatabase(database).then((value) {
          tasks = value;
          setState(() {});
        });
      });
    });
  }

  /// get data from database

  Future<List<Map>> getDataFromDatabase(database) async {
    setState(() {});

    return await database.rawQuery('SELECT * FROM tasks');
  }

  /// delete database
  void deleteDatabase({required int id}) async {
    database.rawDelete('DELETE FROM tasks WHERE id = ?', [id]).then((value) {
      getDataFromDatabase(database).then((value) {
        tasks = value;
        setState(() {});
      });
    });
  }

  @override
  void initState() {
    createDatabase();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[400],
      key: scaffoldKey,
      body: Padding(
        padding: const EdgeInsets.only(
          top: 60,
          left: 20,
          bottom: 80,
          right: 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.playlist_add_check,
                  color: Colors.white,
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  'All ToDos',
                  style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ],
            ),
            Text(
              '${tasks.length} tasks',
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const SizedBox(
              height: 20,
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: ConditionalBuilder(
                    condition: tasks.isNotEmpty,
                    builder: (BuildContext context) => ListView.separated(
                        itemBuilder: (context, index) {
                          bool isCheck = selectedIndices.contains(index);
                          return Column(
                            key: Key(tasks[index]['id'].toString()),
                            children: [
                              ListTile(
                                title: Text(
                                  '${tasks[index]['title']}',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    decoration: isCheck
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                                leading: IconButton(
                                  icon: Icon(isCheck
                                      ? Icons.check_box
                                      : Icons.check_box_outline_blank),
                                  onPressed: () {
                                    setState(() {
                                      if (isCheck) {
                                        selectedIndices.remove(index);
                                      } else {
                                        selectedIndices.add(index);
                                      }
                                    });
                                  },
                                  color: Colors.teal,
                                ),
                                trailing: Container(
                                  height: 35,
                                  width: 35,
                                  decoration: BoxDecoration(
                                    color: Colors.teal,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: IconButton(
                                    onPressed: () {
                                      deleteDatabase(id: tasks[index]['id']);
                                    },
                                    icon: const Icon(Icons.delete),
                                    color: Colors.white,
                                    iconSize: 18,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.only(
                                  right: 50,
                                  left: 50,
                                ),
                                child: Column(children: [
                                  Row(
                                    children: [
                                      Expanded(
                                          child: Text(
                                        '${tasks[index]['time']}',
                                        style: const TextStyle(
                                          color: Colors.grey,
                                        ),
                                      )),
                                      Text(
                                        '${tasks[index]['date']}',
                                        style: const TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ]),
                              ),
                            ],
                          );
                        },
                        separatorBuilder: (context, index) => Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Container(
                                width: double.infinity,
                                height: 1,
                                color: Colors.grey[300],
                              ),
                            ),
                        itemCount: tasks.length),
                    fallback: (BuildContext context) => const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.menu,
                            size: 100,
                            color: Colors.grey,
                          ),
                          Text(
                            'No tasks yet, please add some tasks',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        onPressed: () {
          if (isBottomSheetShown) {
            if (formKey.currentState!.validate()) {
              insertToDatabase(
                title: titleController.text,
                time: timeController.text,
                date: dateController.text,
              ).then((value) {
                Navigator.pop(context);
                changeBottomSheetState(isShow: true, icon: Icons.add);
              });
            }
          } else {
            scaffoldKey.currentState!
                .showBottomSheet(
                  (context) => Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Title must not be empty';
                              }
                              return null;
                            },
                            controller: titleController,
                            keyboardType: TextInputType.text,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(25.0)),
                              ),
                              labelText: 'Task Title',
                              prefixIcon: Icon(Icons.title),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'time must not be empty';
                              }
                              return null;
                            },
                            onTap: () {
                              showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.now())
                                  .then((value) {
                                timeController.text = value!.format(context);
                                print(value.format(context));
                              });
                            },
                            controller: timeController,
                            keyboardType: TextInputType.text,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(25.0)),
                              ),
                              labelText: 'Task Time',
                              prefixIcon: Icon(Icons.timer),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Date must not be empty';
                              }
                              return null;
                            },
                            onTap: () {
                              showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime.parse('2028-05-09'),
                              ).then((value) {
                                dateController.text =
                                    DateFormat.yMMMd().format(value!);
                                print(DateFormat.yMMMd().format(value));
                              });
                            },
                            controller: dateController,
                            keyboardType: TextInputType.text,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(25.0)),
                              ),
                              labelText: 'Task Date',
                              prefixIcon: Icon(Icons.date_range),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                .closed
                .then((value) {
              changeBottomSheetState(isShow: false, icon: Icons.add);
            });
            changeBottomSheetState(isShow: true, icon: Icons.edit);
          }
        },
        child: Icon(fabIcon),
      ),
    );
  }
}
