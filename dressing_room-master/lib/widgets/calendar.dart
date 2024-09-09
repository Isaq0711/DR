import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:dressing_room/utils/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:dressing_room/screens/tinder_like_page.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gap/gap.dart';
import 'package:dressing_room/utils/utils.dart';

class CalendarWidget extends StatefulWidget {
  final String title;
  final DateTime Dataaa;
  final bool isWidget;
  CalendarWidget(
      {Key? key,
      required this.title,
      required this.Dataaa,
      required this.isWidget})
      : super(key: key);
  @override
  _CalendarWidgetState createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  late DateTime _displayedMonth = DateTime.now();
  late DateTime data = DateTime.now();
  bool isLoading = false;
  late ScrollController _scrollController;

  List<Map<String, dynamic>> calendarItems = [];

  void _previousMonth() {
    setState(() {
      _displayedMonth =
          DateTime(_displayedMonth.year, _displayedMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _displayedMonth =
          DateTime(_displayedMonth.year, _displayedMonth.month + 1);
    });
  }

  void _selectDate(DateTime date) {
    setState(() {
      data = date;
    });
  }

  getData() async {
    setState(() {
      isLoading = true;
    });

    try {
      var querySnapshot = await FirebaseFirestore.instance
          .collection('calendar')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('looks')
          .get();

      calendarItems = querySnapshot.docs.map((doc) {
        return {
          'look': doc['look'],
          'data': doc['data'],
          'troncoId': doc['troncoId'],
          'pernasId': doc['pernasId'],
          'pesId': doc['pesId'],
        };
      }).toList();

      setState(() {
        isLoading = false;
        // Scroll to today's date
        WidgetsBinding.instance?.addPostFrameCallback((_) {
          _scrollToToday();
        });
      });
    } catch (e) {
      showSnackBar(context, e.toString());

      setState(() {
        isLoading = false;
      });
    }
  }

  void _scrollToToday() {
    int daysInMonth =
        DateTime(_displayedMonth.year, _displayedMonth.month + 1, 0).day;
    int todayIndex = DateTime.now().day - 1;
    if (todayIndex >= 0 && todayIndex < daysInMonth) {
      double position = (todayIndex / 4) * 150.h; // Adjust as necessary
      _scrollController.animateTo(
        position,
        duration: const Duration(milliseconds: 500),
        curve: Curves.fastLinearToSlowEaseIn,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('pt_BR', null);
    _scrollController = ScrollController();
    getData();
    _displayedMonth = widget.Dataaa;
    data = widget.Dataaa;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(
            child: CircularProgressIndicator(),
          )
        : Scaffold(
            body:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Padding(
              padding: widget.isWidget
                  ? EdgeInsets.symmetric(horizontal: 25)
                  : EdgeInsets.symmetric(vertical: 1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Visibility(
                      visible: !widget.isWidget,
                      child: IconButton(
                        icon: Icon(Icons.arrow_back_ios, color: Colors.black),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      )),
                  Visibility(
                    visible: widget.isWidget,
                    child: Gap(40),
                  ),
                  Expanded(
                      child: Center(
                          child: Text(
                    widget.title,
                    style: AppTheme.barapp.copyWith(
                      shadows: [
                        Shadow(
                          blurRadius: 2.0,
                          color: Colors.black,
                        ),
                      ],
                    ),
                  ))),
                  Visibility(
                    visible: !widget.isWidget,
                    child: Gap(40),
                  ),
                  Visibility(
                      visible: widget.isWidget,
                      child: IconButton(
                        icon: Icon(Icons.check, color: Colors.black),
                        onPressed: () {
                          Navigator.pop(context, data);
                        },
                      ))
                ],
              ),
            ),
            Gap(15),
            SizedBox(
                height: widget.isWidget ? 600.h : 700.h,
                child: Theme(
                    data: ThemeData(
                      highlightColor: Colors.grey[770],
                    ),
                    child: Scrollbar(
                        thickness: 5,
                        thumbVisibility: true,
                        child: buildCalendar(
                            _displayedMonth,
                            _previousMonth,
                            _nextMonth,
                            data,
                            widget.isWidget,
                            _selectDate,
                            calendarItems,
                            _scrollController))))
          ]));
  }
}

Widget buildCalendar(
    DateTime month,
    VoidCallback previousMonth,
    VoidCallback nextMonth,
    DateTime data,
    bool isWidget,
    Function(DateTime) onDateSelected,
    List<Map<String, dynamic>> calendarItems,
    ScrollController scrollController) {
  int daysInMonth = DateTime(month.year, month.month + 1, 0).day;
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  return Column(
    children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: previousMonth,
        ),
        Text(
          DateFormat.yMMMM('pt_BR').format(month),
          style: AppTheme.subheadline,
        ),
        IconButton(
          icon: Icon(Icons.arrow_forward_ios, color: Colors.black),
          onPressed: nextMonth,
        ),
      ]),
      Gap(5),
      Expanded(
          child: GestureDetector(
              /////////////////melhorar isso
              onHorizontalDragEnd: (details) {
                if (details.velocity.pixelsPerSecond.dx > 0) {
                  previousMonth();
                } else if (details.velocity.pixelsPerSecond.dx < 0) {
                  nextMonth();
                }
              },
              child: GridView.builder(
                  controller: scrollController,
                  padding: EdgeInsets.zero,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    childAspectRatio: 0.4,
                  ),
                  itemCount: daysInMonth,
                  itemBuilder: (context, index) {
                    DateTime date =
                        DateTime(month.year, month.month, index + 1);
                    bool selecionada = data.isAtSameMomentAs(date);
                    String text = date.day.toString();
                    String diadasemana = DateFormat.EEEE('pt_BR').format(date);

                    Map<String, dynamic>? calendarItem;
                    try {
                      calendarItem = calendarItems.firstWhere(
                        (item) => _isSameDay(item['data'].toDate(), date),
                      );
                    } catch (e) {
                      calendarItem = null;
                    }

                    String? look =
                        calendarItem != null ? calendarItem['look'] : null;

                    return InkWell(
                      onTap: () {
                        if (isWidget) {
                          DateTime today = DateTime.now();
                          DateTime todayNormalized =
                              DateTime(today.year, today.month, today.day);
                          DateTime dateNormalized =
                              DateTime(date.year, date.month, date.day);

                          if (dateNormalized.isBefore(todayNormalized)) {
                            // Ação caso a data seja anterior ao dia de hoje
                          } else {
                            onDateSelected(date);
                          }
                        } else {
                          // go to see look page
                        }
                      },
                      child: Container(
                        decoration: selecionada
                            ? BoxDecoration(
                                border: Border(
                                  top: BorderSide(
                                      width: 3.0, color: AppTheme.vinho),
                                  left: BorderSide(
                                      width: 3.0, color: AppTheme.vinho),
                                  right: BorderSide(
                                      width: 3.0, color: AppTheme.vinho),
                                  bottom: BorderSide(
                                      width: 3.0, color: AppTheme.vinho),
                                ),
                              )
                            : BoxDecoration(
                                border: Border(
                                  top: BorderSide(
                                      width: 1.0, color: Colors.grey),
                                  left: BorderSide(
                                      width: 1.0, color: Colors.grey),
                                  right: BorderSide(
                                      width: 1.0, color: Colors.grey),
                                  bottom: BorderSide(
                                      width: 1.0, color: Colors.grey),
                                ),
                              ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              flex: 1,
                              child: Center(
                                child: Text(text, style: AppTheme.subtitle),
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: SizedBox(
                                child: look != null
                                    ? Image.network(
                                        look,
                                        width: 100,
                                        height: 60,
                                        fit: BoxFit.cover,
                                      )
                                    : !isWidget
                                        ? Builder(
                                            builder: (context) {
                                              // Defina as variáveis dentro do Builder
                                              DateTime today = DateTime.now();
                                              DateTime todayNormalized =
                                                  DateTime(today.year,
                                                      today.month, today.day);
                                              DateTime dateNormalized =
                                                  DateTime(date.year,
                                                      date.month, date.day);

                                              return dateNormalized
                                                      .isBefore(todayNormalized)
                                                  ? SizedBox
                                                      .shrink() // Se a data for anterior ao dia de hoje, não exibe nada
                                                  : InkWell(
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Icon(Icons.add_circle,
                                                              color: AppTheme
                                                                  .vinho),
                                                          Gap(5),
                                                          Text("Add look",
                                                              style: AppTheme
                                                                  .subtitle),
                                                        ],
                                                      ),
                                                      onTap: () {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                TinderScreen(
                                                              uid: FirebaseAuth
                                                                  .instance
                                                                  .currentUser!
                                                                  .uid,
                                                              datainicial:
                                                                  dateNormalized,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    );
                                            },
                                          )
                                        : SizedBox
                                            .shrink(), // Se `isWidget` for verdadeiro, não exibe nada
                              ),
                            ),
                            Gap(3),
                            Expanded(
                              flex: 1,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 3.0, right: 3.0),
                                child: Text(
                                  diadasemana,
                                  textAlign: TextAlign.center,
                                  style: AppTheme.caption,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  })))
    ],
  );
}
