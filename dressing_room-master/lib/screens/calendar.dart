import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:dressing_room/utils/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:dressing_room/screens/favorites_screen.dart';
import 'package:gap/gap.dart';
import 'package:dressing_room/utils/utils.dart';

class CalendarScreen extends StatefulWidget {
  final String title;
  final DateTime Dataaa;
  CalendarScreen({Key? key, required this.title, required this.Dataaa})
      : super(key: key);
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _displayedMonth = DateTime.now();
  late DateTime data = DateTime.now();
  bool isLoading = false;
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
      var currentUserUid = FirebaseAuth.instance.currentUser!.uid;
      var querySnapshot = await FirebaseFirestore.instance
          .collection('calendar')
          .where('uid', isEqualTo: currentUserUid)
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
      });
    } catch (e) {
      showSnackBar(context, e.toString());
      print(e);
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getData();
    _displayedMonth = widget.Dataaa;
    data = widget.Dataaa;
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(
            child: CircularProgressIndicator(),
          )
        : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Gap(40),
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
                  IconButton(
                    icon: Icon(Icons.check, color: Colors.black),
                    onPressed: () {
                      Navigator.pop(context, data);
                    },
                  ),
                ],
              ),
            ),
            Gap(15),
            SizedBox(
                height: 600.h,
                child: Theme(
                    data: ThemeData(
                      highlightColor: Colors.grey[770],
                    ),
                    child: Scrollbar(
                        thickness: 5,
                        thumbVisibility: true,
                        child: buildCalendar(_displayedMonth, _previousMonth,
                            _nextMonth, data, _selectDate, calendarItems))))
          ]);
  }
}

Widget buildCalendar(
    DateTime month,
    VoidCallback previousMonth,
    VoidCallback nextMonth,
    DateTime data,
    Function(DateTime) onDateSelected,
    List<Map<String, dynamic>> calendarItems) {
  int daysInMonth = DateTime(month.year, month.month + 1, 0).day;

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
          child: GridView.builder(
              padding: EdgeInsets.zero,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 0.4,
              ),
              itemCount: daysInMonth,
              itemBuilder: (context, index) {
                DateTime date = DateTime(month.year, month.month, index + 1);
                bool selecionada = data.isAtSameMomentAs(date);
                String text = date.day.toString();
                String diadasemana = DateFormat.EEEE('pt_BR').format(date);

                Map<String, dynamic>? calendarItem;
                try {
                  calendarItem = calendarItems
                      .firstWhere((item) => item['data'].isSameDay(date));
                } catch (e) {
                  calendarItem = null;
                }

                String? look =
                    calendarItem != null ? calendarItem['look'] : null;

                return InkWell(
                  onTap: () {
                    onDateSelected(date);
                    print(calendarItems);
                  },
                  child: Container(
                    decoration: selecionada
                        ? BoxDecoration(
                            border: Border(
                              top:
                                  BorderSide(width: 3.0, color: AppTheme.vinho),
                              left:
                                  BorderSide(width: 3.0, color: AppTheme.vinho),
                              right:
                                  BorderSide(width: 3.0, color: AppTheme.vinho),
                              bottom:
                                  BorderSide(width: 3.0, color: AppTheme.vinho),
                            ),
                          )
                        : BoxDecoration(
                            border: Border(
                              top: BorderSide(width: 1.0, color: Colors.grey),
                              left: BorderSide(width: 1.0, color: Colors.grey),
                              right: BorderSide(width: 1.0, color: Colors.grey),
                              bottom:
                                  BorderSide(width: 1.0, color: Colors.grey),
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
                                : SizedBox
                                    .shrink(), // If photoUrl is null, display an empty container
                          ),
                        ),
                        Gap(10),
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding:
                                const EdgeInsets.only(left: 3.0, right: 3.0),
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
              }))
    ],
  );
}
