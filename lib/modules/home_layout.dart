import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:to_do_app/cubit/cubit.dart';
import 'package:to_do_app/cubit/states.dart';

import '../components/components.dart';

class HomeLayout extends StatelessWidget {


  var scaffoldKey = GlobalKey<ScaffoldState>();
  var formKey = GlobalKey<FormState>();
  var titleController = TextEditingController();
  var timeController = TextEditingController();
  var dateController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => TodoCubit()..createDatabase(),
      child: BlocConsumer<TodoCubit , TodoStates>(
        listener: (context, state) {  },
        builder: (context,  state) {
          var cubit = TodoCubit.get(context);

          return Scaffold(
            backgroundColor: Colors.teal[400],
            key: scaffoldKey,
            body: Padding (
              padding: const EdgeInsets.only(
                top: 60,
                left: 20,
                bottom: 80,
                right: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.playlist_add_check,color: Colors.white,),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        'All ToDos',
                        style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ],
                  ),
                  Text(
                    '${cubit.tasks.length} tasks',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white
                    ),
                  ),
                  SizedBox(
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
                        child: taskBuilder(context),
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
                if (cubit.isBottomSheetShown) {
                  if (formKey.currentState!.validate()) {
                    cubit.insertToDatabase(
                      title: titleController.text,
                      time: timeController.text,
                      date: dateController.text,
                    ).then((value) {
                      cubit.getDataFromDatabase(cubit.database).then((value) {
                          Navigator.pop(context);
                          cubit.changeBottomSheetState(
                              isShow: true,
                              icon: Icons.add
                          );
                      });
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
                            SizedBox(
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
                            SizedBox(
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
                  ).closed
                      .then((value) {
                    cubit.changeBottomSheetState(
                        isShow: false,
                        icon: Icons.add
                    );
                  });
                  cubit.changeBottomSheetState(
                      isShow: true,
                      icon: Icons.edit
                  );
                }
              },
              child: Icon(cubit.fabIcon),

            ),
          );
        },
      ),
    );
  }

}

