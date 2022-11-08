import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:to_do_app/cubit/cubit.dart';

Widget buildListItem(Map model, context) => Column(
      key: Key(model['id'].toString()),
      children: [
        ListTile(
          title: Text(
            '${model['title']}',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              decoration: TodoCubit.get(context).isCheck
                  ? TextDecoration.lineThrough
                  : null,
            ),
          ),
          leading: IconButton(
            icon: Icon(TodoCubit.get(context).checkIcon),
            onPressed: () {
              if (TodoCubit.get(context).isCheck) {
                TodoCubit.get(context).changeCheckBoxIcon(
                  id: model['id'],
                  line: false,
                  checkIconChange: Icons.check_box_outline_blank,
                );
              } else {
                TodoCubit.get(context).changeCheckBoxIcon(
                  id: model['id'],
                  line: true,
                  checkIconChange: Icons.check_box,
                );
              }
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
                TodoCubit.get(context).deleteDatabase(id: model['id']);
              },
              icon: Icon(Icons.delete),
              color: Colors.white,
              iconSize: 18,
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.only(
            right: 50,
            left: 50,
          ),
          child: Column(children: [
            Row(
              children: [
                Expanded(
                    child: Text(
                  '${model['time']}',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                )),
                Text(
                  '${model['date']}',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ]),
        ),
      ],
    );

Widget buildSeparator() => Padding(
      padding: const EdgeInsets.all(20.0),
      child: Container(
        width: double.infinity,
        height: 1,
        color: Colors.grey[300],
      ),
    );

Widget taskBuilder(context) => ConditionalBuilder(
      condition: TodoCubit.get(context).tasks.length > 0,
      builder: (BuildContext context) => ListView.separated(
          itemBuilder: (context, index) =>
              buildListItem(TodoCubit.get(context).tasks[index], context),
          separatorBuilder: (context, index) => buildSeparator(),
          itemCount: TodoCubit.get(context).tasks.length),
      fallback: (BuildContext context) => Center(
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
    );
