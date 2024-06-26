import 'package:avaremp/constants.dart';
import 'package:avaremp/plan_create_widget.dart';
import 'package:avaremp/plan_file_widget.dart';
import 'package:avaremp/plan_item_widget.dart';
import 'package:avaremp/plan_line_widget.dart';
import 'package:avaremp/plan_load_save_widget.dart';
import 'package:avaremp/plan_manage_widget.dart';
import 'package:avaremp/plan_route.dart';
import 'package:avaremp/storage.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

class PlanScreen extends StatefulWidget {
  const PlanScreen({super.key});
  @override
  State<StatefulWidget> createState() => PlanScreenState();
}

class PlanScreenState extends State<PlanScreen> {


  final CarouselController _controller = CarouselController();

  Widget _makeContent() {

    Widget loadSavePage = const PlanLoadSaveWidget();

    Widget createPage = const PlanCreateWidget();

    Widget filePage = const PlanFileWidget();

    Widget managePage = const PlanManageWidget();

    List<Widget> pages = [];
    pages.add(loadSavePage);
    pages.add(createPage);
    pages.add(filePage);
    pages.add(managePage);

    // carousel
    List<Card> cards = [];
    for (Widget page in pages) {
      cards.add(Card(
          child: Align(
              alignment: Alignment.topLeft,
              child: SizedBox.expand(
                  child: page
              )
          )
      ));
    }

    return Container(
        padding: const EdgeInsets.all(5),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
        ),
        child:
          Column(children: [
            // various info
            Expanded(flex: 8, child: CarouselSlider(
              carouselController: _controller,
              items: cards,
              options: CarouselOptions(
                viewportFraction: 1,
                enlargeFactor: 0.5,
                enableInfiniteScroll: false,
                enlargeCenterPage: true,
                aspectRatio: Constants.carouselAspectRatio(context),
              ),
            )),
          // add various buttons that expand to diagram
          Expanded(flex: 1, child: Row(mainAxisAlignment: MainAxisAlignment.end, children:[
              TextButton(
                  child: const Text("Load & Save"),
                  onPressed: () => _controller.animateToPage(0)
              ),
              TextButton(
                  child: const Text("Create"),
                  onPressed: () => _controller.animateToPage(1)
              ),
              TextButton(
                  child: const Text("Brief & File"),
                  onPressed: () => _controller.animateToPage(2)
              ),
              TextButton(
                  child: const Text("Manage"),
                  onPressed: () => _controller.animateToPage(3)
              ),
            ]),
          ),
        ],
          )
    );

  }

  @override
  Widget build(BuildContext context) {
    final PlanRoute route = Storage().route;

    double height = 0;
    double bottom = Constants.bottomPaddingSize(context);

    // user can rearrange widgets
    return Container(padding: EdgeInsets.fromLTRB(5, height + 10, 5, bottom),
      child: Stack(children:[
        Column(
          children: [
            Expanded(flex: 1,
              child: ValueListenableBuilder<int>( // update in plan change
                valueListenable: route.change,
                builder: (context, value, _) {
                  return ListTile( // header
                    key: Key(Storage().getKey()),
                    leading: const Icon(Icons.summarize_outlined),
                    title: PlanLineWidgetState.getHeading(),
                    subtitle: PlanLineWidgetState.getFieldsFromCalculations(Storage().route.totalCalculations));
                }
              )
            ), // heading for dist, time etc.
            Expanded(flex: 5, child: ReorderableListView(
              scrollDirection: Axis.vertical,
              children: <Widget>[
                for(int index = 0; index < route.length; index++)
                  Dismissible( // able to delete with swipe
                    background: Container(alignment:
                    Alignment.centerRight,child: const Icon(Icons.delete_forever),),
                    key: Key(Storage().getKey()),
                    direction: DismissDirection.endToStart,
                    onDismissed:(direction) {
                      setState(() {
                        route.removeWaypointAt(index);
                      });
                    },
                    child: ValueListenableBuilder<int>( // update in plan change
                      valueListenable: route.change,
                      builder: (context, value, _) {
                        return PlanItemWidget(
                          waypoint: route.getWaypointAt(index),
                          current: route.isCurrent(index),
                          onTap: () {
                            setState(() {
                              Storage().route.setCurrentWaypoint(index);
                            });
                          },
                        );
                     },
                  )
                ),
              ],
              onReorder: (int oldIndex, int newIndex) {
                setState(() {
                  if (oldIndex < newIndex) {
                    newIndex -= 1;
                  }
                  route.moveWaypoint(oldIndex, newIndex);
                });
              })
            ),
            Expanded(flex: 1, child: Row(
              children:[ // header
                TextButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      useSafeArea: true,
                      showDragHandle: true,
                      isScrollControlled: true,
                      builder: (BuildContext context) {
                        return _makeContent();
                      },
                    ).then((value) => setState(() {})); // this is important so if modal changes plan then we update it here
                  },
                  child: const Text("Actions"),),
                DropdownButtonHideUnderline(child:DropdownButton2<String>(
                  isExpanded: false,
                  isDense: true,
                  value: Storage().settings.getTas().toString(),
                  items: [
                    for(int speed = 10; speed <= 500; speed+=10)
                      DropdownMenuItem<String>(value : speed.toString(), child: Text("${speed}KT", style: const TextStyle(fontSize: 12)))
                  ],
                  onChanged: (value) {
                    setState(() {
                      Storage().settings.setTas(int.parse(value ?? Storage().settings.getTas().toString()));
                    });
                  },
                )),
                DropdownButtonHideUnderline(child:DropdownButton2<String>(
                  isExpanded: false,
                  isDense: true,
                  value: Storage().settings.getFuelBurn().toString(),
                  items: [
                    for(int fuel = 1; fuel < 100; fuel++)
                      DropdownMenuItem<String>(value : fuel.toString(), child: Text("${fuel}GPH", style: const TextStyle(fontSize: 12)))
                  ],
                  onChanged: (value) {
                    setState(() {
                      Storage().settings.setFuelBurn(int.parse(value ?? Storage().settings.getFuelBurn().toString()));
                    });
                  },
                )),
                DropdownButtonHideUnderline(child:DropdownButton2<String>(
                  isExpanded: false,
                  isDense: true,
                  value: Storage().route.altitude,
                  items: [
                    for(int altitude = 3000; altitude <= 30000; altitude += 500)
                      DropdownMenuItem<String>(value : "$altitude", child: Text("${altitude}ft", style: const TextStyle(fontSize: 12)))
                  ],
                  onChanged: (value) {
                    setState(() {
                      Storage().route.altitude = value?? "3000";
                    });
                  },
                )),
              ]
            ))
          ]
        )
      ]
      ),
    );
  }
}
