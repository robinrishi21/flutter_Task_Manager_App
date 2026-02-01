import 'package:flutter/material.dart';

import '../database/local/db.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController priorityController = TextEditingController();
  final List<String> priorityCategory = ["High","Medium","Low"];
  Color getPriorityColor(String priority){
    switch(priority){
      case "High": return Colors.red.shade100;
      case "Medium": return Colors.yellow.shade100;
      case "Low": return Colors.green.shade100;
      default: return Colors.white;
    }
  }
  List<Map<String, dynamic>> allTasks = [];
  DB? dbRef;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    dbRef = DB.getInstance;
    getTask();
  }

  Future<void> getTask() async {
    allTasks = await dbRef!.getAllTask();
    //if data takes time to render and ui renders without data then this will help to get all data
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task Manager'),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
              icon: Icon(Icons.filter_alt_outlined),
              onSelected: (value){
                //Function Call
                applyFilter(value);
              },
              itemBuilder: (context)=>[
                PopupMenuItem(value:'all',child: Text('All Tasks')),
                PopupMenuItem(value:'completed',child: Text('Completed')),
                PopupMenuItem(value:'pending',child: Text('Pending')),
              ]),
          SizedBox(width: 30,)
        ],
      ),
      body: allTasks.isNotEmpty
          ? ListView.builder(
              itemCount: allTasks.length,
              itemBuilder: (context, index) {
                return ListTile(
                  tileColor: getPriorityColor(allTasks[index][DB.COLUMN_PRIORITY]),
                  leading: Text('${index+1}'),
                  title: Text(allTasks[index][DB.COLUMN_TITLE]),
                  subtitle: Text(allTasks[index][DB.COLUMN_PRIORITY]),
                  trailing: SizedBox(
                    width: 100,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        //Edit Button
                        InkWell(
                          onTap: () async {
                            titleController.text =
                            allTasks[index][DB.COLUMN_TITLE];
                            priorityController.text =
                            allTasks[index][DB.COLUMN_PRIORITY];
                            showModalBottomSheet(
                              context: context,
                              builder: (context) {
                                return getBottomSheetWidget(
                                  isUpdate: true,
                                  sno: allTasks[index][DB.COLUMN_SNO],
                                );
                              },
                            );
                          },
                          child: Icon(Icons.edit),
                        ),
                        //Delete Button
                        InkWell(
                          onTap: () async {
                            bool check = await dbRef!.deleteTask(
                              sno: allTasks[index][DB.COLUMN_SNO],
                            );
                            if (check) {
                              getTask();
                            }
                          },
                          child: Icon(Icons.delete, color: Colors.red),
                        ),
                        //CheckBox
                        Checkbox(
                            value: allTasks[index][DB.COLUMN_COMPLETED]==1,
                            onChanged: (value)async{
                              await dbRef!.updateTaskStatus(
                                  sno: allTasks[index][DB.COLUMN_SNO],
                                  isCompleted: value! ? 1 : 0,
                              );
                              getTask();
                            })
                      ],
                    ),
                  ),
                );
              },
            )
          : Center(child: Text('No Task !!!')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          titleController.clear();
          priorityController.clear();
          showModalBottomSheet(
            context: context,
            builder: (context) {
              return getBottomSheetWidget();
            },
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget getBottomSheetWidget({bool isUpdate = false, int sno = 0}) {
    return Container(
      padding: EdgeInsets.all(11),
      width: double.infinity,
      child: Column(
        children: [
          Text(
            isUpdate ? 'Update Task' : 'Add Note',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 21),

          //Title TextFormField
          TextFormField(
            controller: titleController,
            // validator: (value){
            //   if(value==null || value.isEmpty){
            //     return "Please select a category";
            //   }
            //   return null;
            // },
            decoration: InputDecoration(
              hintText: "Enter Title",
              label: Text('Title *'),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
              ),
            ),
          ),

          SizedBox(height: 21),

          //Priority Drop-Down Menu
          TextFormField(
            controller: priorityController,
            readOnly: true,
            validator: (value){
              if(value==null || value.isEmpty){
                return "Please select a category";
              }
              return null;
            },
            decoration: InputDecoration(
              hintText: "Enter Priority",
              label: Text('Select Category *'),
              suffixIcon: Icon(Icons.arrow_drop_down),
              border: OutlineInputBorder(),
            ),
            onTap: (){
              //Drop Down Menu Function Call
              FocusScope.of(context).unfocus();
              showCategoryBottomSheet();
            },
          ),

          SizedBox(height: 21),

          Row(
            children: [
              //Add or Update Button
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    side: BorderSide(color: Colors.black, width: 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11),
                    ),
                  ),
                  onPressed: () async {
                    var title = titleController.text;
                    var priority = priorityController.text;
                    if (title.isNotEmpty && priority.isNotEmpty) {
                      bool check = isUpdate
                          ? await dbRef!.updateTask(
                              mtitle: title,
                              mpriority: priority,
                              sno: sno,
                            )
                          : await dbRef!.addTask(
                              mtitle: title,
                              mpriority: priority,
                            );
                      if (check) {
                        getTask();
                      }
                    }
                    titleController.clear();
                    priorityController.clear();
                    Navigator.pop(context);
                  },
                  child: Text(isUpdate ? 'Update' : 'Add'),
                ),
              ),
              SizedBox(width: 11),
              //Cancel Button
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    side: BorderSide(color: Colors.black, width: 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> showCategoryBottomSheet() async {
    final selectCategory = await
    showModalBottomSheet<String>(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(11),
        ),
        builder: (context){
          return SizedBox(
            height: 250,
            child: ListView.builder(
                itemCount: priorityCategory.length,
                itemBuilder: (context,index){
                  return ListTile(
                    title: Text(priorityCategory[index]),
                    onTap: (){
                      Navigator.pop(context,priorityCategory[index]);
                    },
                  );
            }),
          );
        });
    if(selectCategory!=null){
      priorityController.text = selectCategory;
    }
  }

  Future<void> applyFilter(String filter) async {
    if(filter == 'all'){
      allTasks = await dbRef!.getAllTask();
    } else if(filter == 'completed'){
      allTasks = await dbRef!.getCompletedTask();
    } else if(filter == 'pending'){
      allTasks = await dbRef!.getPendingTask();
    }
    setState(() {

    });
  }
}
