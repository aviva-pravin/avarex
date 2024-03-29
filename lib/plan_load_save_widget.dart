import 'package:avaremp/plan_route.dart';
import 'package:avaremp/storage.dart';
import 'package:flutter/material.dart';

import 'data/user_database_helper.dart';

class PlanLoadSaveWidget extends StatefulWidget {
  const PlanLoadSaveWidget({super.key});


  @override
  State<StatefulWidget> createState() => PlanLoadSaveWidgetState();
}


class PlanLoadSaveWidgetState extends State<PlanLoadSaveWidget> {

  String _name = "";
  String _route = "";
  List<String> _currentItems = [];


  void _saveRoute(PlanRoute route) {
    UserDatabaseHelper.db.addPlan(_name, route).then((value) {
      setState(() {
        Storage().route.name = _name;
        _currentItems.insert(0, Storage().route.name);
      });
    });
  }

  Widget _makeContent() {
    _name = Storage().route.name;
    _route = Storage().route.toString();
    bool edited = false;

    return Container(padding: const EdgeInsets.all(0),
          child: Column(children: [
            Expanded(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0), child: const Text("Load & Save", style: TextStyle(fontWeight: FontWeight.w800),),)),
            Expanded(
                flex: 3,
                child: Container(
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: Row(
                        children: [
                          Expanded(
                              flex: 5,
                              child: TextFormField(
                                  initialValue: _name ,
                                  onChanged: (value)  {
                                    _name = value;
                                  },
                                  decoration: const InputDecoration(border: UnderlineInputBorder(), labelText: 'Plan Name',)
                              )
                          ),
                          const Padding(padding: EdgeInsets.all(10)),
                          Expanded(
                              flex: 5,
                              child: TextFormField(
                                  initialValue: _route ,
                                  onChanged: (value)  {
                                    edited = true;
                                    _route = value;
                                  },
                                  decoration: const InputDecoration(border: UnderlineInputBorder(), labelText: 'Route',)
                              )
                          ),
                          Expanded(
                              flex: 2,
                              child: TextButton(
                                  onPressed: () {
                                    if(edited) {
                                      // if user edited, then make a new plan and save, otherwise save the current plan
                                      PlanRoute.fromLine(_name, _route).then((value) {
                                        _saveRoute(value);
                                        edited = false;
                                      });
                                    }
                                    else {
                                      _saveRoute(Storage().route);
                                    }
                                  },
                                  child: const Text("Save")
                              )
                          )
                        ]
                    )
                )
            ),
            Expanded(
                flex: 10,
                child: ListView.builder(
                  itemCount: _currentItems.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(_currentItems[index].toString()),
                      trailing: PopupMenuButton(
                        itemBuilder: (BuildContext context)  => <PopupMenuEntry<String>>[
                          PopupMenuItem<String>(
                            child: const Text('Load'),
                            onTap: () {
                              UserDatabaseHelper.db.getPlan(_currentItems[index], false).then((value) {
                                Storage().route.copyFrom(value);
                                Storage().route.setCurrentWaypoint(0);
                                Navigator.pop(context);
                              });
                            },
                          ),
                          PopupMenuItem<String>(
                            child: const Text('Load Reversed'),
                            onTap: () {
                              UserDatabaseHelper.db.getPlan(_currentItems[index], true).then((value) {
                                Navigator.pop(context);
                                Storage().route.copyFrom(value);
                                Storage().route.setCurrentWaypoint(0);
                              });
                            },
                          ),
                          PopupMenuItem<String>(
                            child: const Text('Delete'),
                            onTap: () {
                              UserDatabaseHelper.db.deletePlan(_currentItems[index]);
                              setState(() {
                                _currentItems.removeAt(index);
                              });
                            },
                          ),
                        ],),
                    );
                  },
                )
            ),
          ],)
      );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: UserDatabaseHelper.db.getPlans(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          _currentItems = snapshot.data == null ? _currentItems : snapshot.data!;
        }
        return _makeContent();
      },
    );
  }
}
