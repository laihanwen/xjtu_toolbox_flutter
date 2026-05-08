import 'package:flutter_test/flutter_test.dart';
import 'package:xjtu_toolbox_flutter/src/features/calendar/school_calendar_models.dart';
import 'package:xjtu_toolbox_flutter/src/features/calendar/school_calendar_parser.dart';

void main() {
  const parser = SchoolCalendarParser();

  test('parses terms and sorted events', () {
    final terms = parser.parseTerms(_calendarJson());

    expect(terms, hasLength(2));
    expect(terms.first.id, '2025-1');
    expect(terms.first.totalWeeks, 20);
    expect(terms.first.workDays, 98);
    expect(terms.first.events, hasLength(2));
    expect(terms.first.events.first.name, '国庆节');
    expect(terms.first.events.last.name, '考试周');
  });

  test('throws when response code is not success', () {
    expect(
      () => parser.parseTerms('{"code":500,"msg":"failed","data":[]}'),
      throwsA(isA<SchoolCalendarParseException>()),
    );
  });

  test('skips bad events but keeps valid term', () {
    final terms = parser.parseTerms(
      _calendarJson(
        holidays: '''
        [
          {"id":"bad","start_date":"broken","end_date":"2025-10-01"},
          {
            "id":"ok",
            "start_date":"2025-10-01",
            "end_date":"2025-10-03",
            "holiday_name":"国庆节",
            "holiday_remark":"放假",
            "holiday_days":"3",
            "holiday_color":"#ff3355"
          }
        ]
        ''',
      ),
    );

    expect(terms.single.events, hasLength(1));
    expect(terms.single.events.single.id, 'ok');
  });

  test('throws when term has invalid required date', () {
    expect(
      () => parser.parseTerms(_calendarJson(startDate: 'broken')),
      throwsA(isA<FormatException>()),
    );
  });

  test('computes term progress and current event', () {
    final term = SchoolTerm(
      id: 'term',
      startDate: DateTime(2025, 9, 1),
      endDate: DateTime(2026, 1, 18),
      termName: '2025-2026学年第一学期',
      yearName: '2025-2026',
      totalWeeks: 20,
      workDays: 98,
      events: [
        CalendarEvent(
          id: 'event',
          startDate: DateTime(2025, 10, 1),
          endDate: DateTime(2025, 10, 7),
          name: '国庆节',
          remark: '放假',
          days: 7,
          colorHex: '#ff3355',
        ),
      ],
    );

    expect(term.currentWeek(DateTime(2025, 8, 31)), 0);
    expect(term.currentWeek(DateTime(2025, 9, 1)), 1);
    expect(term.currentWeek(DateTime(2025, 9, 8)), 2);
    expect(term.currentWeek(DateTime(2026, 1, 19)), 0);
    expect(term.progress(DateTime(2025, 8, 31)), 0);
    expect(term.progress(DateTime(2026, 1, 19)), 1);
    expect(term.daysRemaining(DateTime(2026, 1, 19)), 0);
    expect(term.todayEvent(DateTime(2025, 10, 2))?.name, '国庆节');
  });
}

String _calendarJson({
  String startDate = '2025-09-01',
  String holidays = '''
  [
    {
      "id":"exam",
      "start_date":"2026-01-05",
      "end_date":"2026-01-18",
      "holiday_name":"考试周",
      "holiday_remark":"期末考试",
      "holiday_days":"14",
      "holiday_color":"#196dd0"
    },
    {
      "id":"national",
      "start_date":"2025-10-01",
      "end_date":"2025-10-07",
      "holiday_name":"国庆节",
      "holiday_remark":"放假",
      "holiday_days":"7",
      "holiday_color":"#ff3355"
    }
  ]
  ''',
}) {
  return '''
  {
    "code": 200,
    "data": [
      {
        "id": "2025-1",
        "start_date": "$startDate",
        "end_date": "2026-01-18",
        "term_num": "2025-2026学年第一学期",
        "year_num": "2025-2026",
        "week_number": "20",
        "work_days": 98,
        "holidays": $holidays
      },
      {
        "id": "2024-2",
        "start_date": "2025-02-17",
        "end_date": "2025-07-06",
        "term_num": "2024-2025学年第二学期",
        "year_num": "2024-2025",
        "week_number": "20",
        "work_days": 100,
        "holidays": []
      }
    ]
  }
  ''';
}
