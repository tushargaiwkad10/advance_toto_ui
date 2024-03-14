import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart' ;
dynamic database ;
List retData = [];


class ToDoClassModel {

   int? todoNumber ; 
   String? title ;
   String? description;
   String? date ;


  ToDoClassModel(  
    {
     
      required this.title ,
      required this.description ,
      required this.date
    }
  );


  Map<String , dynamic> taskMap(){
    return {
      'title': title ,
      'description':description ,
      'date':date ,

    };
  }
}

Future<void> insertTask(ToDoClassModel obj)async {

  final localDB = await database ;

  localDB.insert(
    'task',
    obj.taskMap() ,
    conflictAlgorithm:ConflictAlgorithm.replace,
  );
}


Future<List<Map<String , dynamic>>> getTask()async{
  final localDB = await database ;
  List<Map<String , dynamic>> retData = await localDB.query("task");
  return retData ;

}


Future<void>updateTask(ToDoClassModel? obj, String title , String des , String date)async {
  
  final localDB = await database ;

  await localDB.update(
    "task",
    {
      'title': title ,
      'description': des ,
      'date':date ,

    } ,   
    where :"title = ?",
    whereArgs : [obj!.title],
  );

}



 Future<void> deleteTask(ToDoClassModel obj)async {
  final localDB = await database ;

  localDB.delete(
    "task",
    where:"title= ?",
    whereArgs:[obj.title]
  );

}
void main()async {
  runApp(const MyApp());
   database = openDatabase(   
  join(await getDatabasesPath() , "todo_model4.db"),
  version: 1 ,
  onCreate:(db, version) {
    db.execute('''
  CREATE TABLE task(

     
     title TEXT PRIMARY KEY ,
     description TEXT ,
     date TEXT 
    
)
''');
  },
   );


  //  ToDoClassModel obj1 = ToDoClassModel(title: "prajwal", description: "hello", date: "22 march");
  //  ToDoClassModel obj2 = ToDoClassModel(title: "harsh", description: "hell i ibio", date: "22 july");


  //  insertTask(obj1);
  //  insertTask(obj2);


List ret = await getTask();
for(int i = 0 ; i<ret.length ; i++){
  print(ret[i]);
}

}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  Widget build(BuildContext context){
    return const MaterialApp(

      home: MainApp(),

     );
  }
}
class MainApp extends StatefulWidget {
  const MainApp({super.key});


  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {

@override
  initState(){
    super.initState();
    getData();
    setState(() {
      
    });
  }


   final TextEditingController _title= TextEditingController();
   final TextEditingController _description = TextEditingController();
   final TextEditingController _date = TextEditingController();

  void controllerValue(int index){
           _title.text = retData[index]["title"] ;
           _description.text = retData[index]["description"] ;
           _date.text = retData[index]["date"];
                showBottomSheet(true ,ToDoClassModel(title: retData[index]["title"], description: retData[index]["description"], date: retData[index]["date"]) );


         
  }


   void getData()async{
    retData = await getTask();
    setState(() {
      
    });
   }


   void showBottomSheet(isEdit , [ ToDoClassModel? obj] ) {

    showModalBottomSheet(
        context: this.context,
        isScrollControlled: true,
        builder: (context) {
          return Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: Container(
              //height: 600,

              color: Colors.grey.shade100,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: double.infinity,
                      margin:
                          const EdgeInsets.only(left: 50, right: 50, top: 10),
                      child: TextField(
                         maxLength: 45,
                        controller: _title,
                        autofocus: true,
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          hintText: "Add Title",
                       //   errorText: isError ? errorMsg(_Title.text) : null,
                          focusColor: Colors.black,
                          filled: true,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: const BorderSide(color: Colors.red)),

                              
                        ),
                        onTap: (){
                        //  isError = false ;

                        },
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      margin:
                          const EdgeInsets.only(left: 50, right: 50, top: 10),
                      child: TextField(
                        controller: _description,
                        
                        decoration: InputDecoration(
                            fillColor: Colors.white,
                            filled: true,
                            hintText: "Add Discription",
                            //  errorText: isError?errorMsg(_discription.text):null,
                            focusColor: Colors.black,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide:
                                    const BorderSide(color: Colors.black))),
                      
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      margin:
                          const EdgeInsets.only(left: 50, right: 50, top: 10,bottom: 10),
                      child: TextField(
                          readOnly: true,
                          controller: _date,
                          keyboardType: TextInputType.datetime,
                          decoration: InputDecoration(
                            fillColor: Colors.white,
                            filled: true,
                            hintText: "Add Date ",
                            focusColor: Colors.black,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15)),
                            suffix: const Icon(Icons.calendar_month),
                          ),
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              firstDate: DateTime(2024),
                              lastDate: DateTime(2025),
                            );

                            String formatDate =
                                DateFormat.yMMMd().format(pickedDate!);
                            setState(() {
                              _date.text = formatDate;
                            });
                           }

                          ),
                  ),
                    Container(
                      width: 300,
                      height: 50,
                      margin:
                          const EdgeInsets.only(left: 50, right: 50, top: 15),
                      child: ElevatedButton(
                        onPressed: () {

                          if(!isEdit){
                             insertTask(ToDoClassModel(title:_title.text, description: _description.text, date:_date.text));
                           
                             _title.clear() ;
                             _description.clear();
                             _date.clear();
                               getData();
                          }
                          else{

                            updateTask(obj , _title.text , _description.text , _date.text);
                            getData();
                            
                          }
                         
                           

                             Navigator.pop(context);
                                 
                          
                        },
                        style: const ButtonStyle(
                          backgroundColor:
                              MaterialStatePropertyAll(Color(0xff6F51FF),),
                          shadowColor: MaterialStatePropertyAll(Colors.black),
                        ),
                        child: const Text(
                          "Submit",
                          style: TextStyle(fontSize: 25, color: Colors.white),
                        ),
                      ),
                    ),
                  ]),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    
    return 
       Scaffold(
        floatingActionButton: FloatingActionButton(onPressed: (){

        showBottomSheet(false);
         

        },
        child: const  Icon(Icons.add),
        ),
          body:

      Column(  
        children: [  

          Expanded(  
            flex: 1,
            child: Container(  
            width: double.infinity,
            height: double.infinity,
            color: const Color(0xff6F51FF),

            child: Column(  
              children: [  
               Container( 
              
                margin:const  EdgeInsets.only(top: 40 , left: 15),
                child: const Column(  
                
                  children: [ 
                    SizedBox(width: double.infinity, child: Text("good morning", style: TextStyle(fontSize:30 , color:Colors.white))),
                    SizedBox(width: double.infinity,    child: Text("prajwal",style: TextStyle(fontSize:30 , color:Colors.white))),

                    
                  ],
                ), 
               )
              ],
            ),
            
            ) ,
            
          ),

          Expanded(
            flex: 3,
            child: Container(  
               decoration: BoxDecoration(  
                color:const  Color(0xffD9D9D9),
                      borderRadius: BorderRadius.circular(35),
                    ),
              


              child: Column(  
                children: [  
                  Container(
                   
                    padding: const EdgeInsets.all(15),
                    child:const  Text("CREATE TO DO LIST ",style:TextStyle(fontSize:18, fontWeight:FontWeight.bold))),
                  Expanded(  
                    child: Container(

                      decoration: const BoxDecoration(  
                      color: Color(0xffFFFFFF),
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight:Radius.circular(25)),
                    ),
                    child: ListView.builder(  
                      shrinkWrap: true,
                      itemCount: retData.length,
                      itemBuilder: (context , index){
                        return 
                           
                        Slidable(
                          
                          closeOnScroll: true,
                          endActionPane: ActionPane(
                            extentRatio : 0.2,
                            
                            motion:BehindMotion( ) , 

                            children: [
                              Column(  
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [  
                                  GestureDetector(
                                    onTap: (){
                                      
                                    controllerValue(index);
                                   
                                    getData();
                                  //  showBottomSheet(true);
                                    //  getData() ;
                                    },
                                    child: Container(
                                      height: 40,
                                      width: 40 ,
                                      decoration: BoxDecoration(  
                                        borderRadius: BorderRadius.circular(10),
                                    
                                      ),
                                      child:const  Icon(Icons.edit , color:Color(0xff6F51FF) ,),
                                      ),
                                  ),

                                   GestureDetector(
                                    onTap: (){
                                       deleteTask(ToDoClassModel(title: retData[index]["title"] , description: retData[index]["description"],date: retData[index]["date"]));
                                         getData();

                                    },
                                    child: Container(
                                      height: 40,
                                      width: 40 ,
                                      decoration: BoxDecoration(  
                                        borderRadius: BorderRadius.circular(10),
                                    
                                      ),
                                      child:const Icon(Icons.delete , color:Color(0xff6F51FF) ,),
                                      ),
                                  ),

                                   
                                  
                                ],
                              )
                            ]
                           
                            ),
                          child: Container(
                              margin: EdgeInsets.only(bottom: 15,left: 10,right: 10),
                          
                              height: 130,
                              width: double.infinity,
                          
                              decoration:const  BoxDecoration(  
                                color: Colors.white,
                                boxShadow: [
                          
                                  BoxShadow(  
                                    offset: Offset(5, 5),
                                    blurRadius: 10,
                                    spreadRadius: 1,
                                    color: Colors.grey ,
                                  )
                                ],
                              ),
                            
                              child: Container(
                                child: Column(
                                  children: [
                                    Row(  
                                      
                                    
                                      children: [  
                                      
                                       Container(  
                                        
                                            height: 70,
                                            width: 70,
                                            decoration: BoxDecoration(  
                                              borderRadius: BorderRadius.circular(35),
                                              color: Colors.grey.shade400
                                              
                                            ),
                                            child: Icon(Icons.person),
                                          ),
                                        const  SizedBox(width: 20,),
                                        
                                     
                                          Column(  
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [  
                                              SizedBox(width:200 , child: Text(retData[index]["title"])),
                                                              
                                              SizedBox(width:200,child : Text(retData[index]["description"])),
                                                              
                                            ],
                                            
                                            
                                          ),
                                        
                                        Expanded(
                                          flex: 2,
                                          child: GestureDetector(
                                            onTap: (){
                                            
                                            },
                                            child: Icon(Icons.circle_outlined, color: Colors.green,)),
                                        ),
                                    
                                      ],
                                      
                                    ),
                                  ],
                                ),
                              ),
                          
                          ),
                        );
                      },

                    )
                    ),
                  )
                ],
              ),
            ),

        ) , 

        ],
      )

    
    );
  }
}
