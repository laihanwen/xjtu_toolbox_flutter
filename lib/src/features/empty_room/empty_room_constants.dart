const campusBuildings = <String, List<String>>{
  '兴庆校区': [
    '主楼A',
    '主楼B',
    '主楼C',
    '主楼D',
    '中2',
    '中3',
    '西2东',
    '西2西',
    '外文楼A',
    '外文楼B',
    '东1东',
    '东2',
    '仲英楼',
    '东1西',
    '教2楼',
    '中1',
    '主楼E座',
    '工程馆',
    '工程坊A区',
    '文管',
    '计教中心',
    '田家炳',
  ],
  '雁塔校区': [
    '东配楼',
    '微免楼',
    '综合楼',
    '教学楼',
    '药学楼',
    '解剖楼',
    '生化楼',
    '病理楼',
    '西配楼',
    '一附院科教楼',
    '二院教学楼',
    '护理楼',
    '卫法楼',
  ],
  '曲江校区': ['西一楼', '西五楼', '西四楼', '西六楼'],
  '创新港校区': ['1', '2', '3', '4', '5', '9', '18', '19', '20', '21'],
  '苏州校区': ['公共学院5号楼'],
};

const periodTimes = <RoomPeriod>[
  RoomPeriod(1, '08:00', '08:50'),
  RoomPeriod(2, '09:00', '09:50'),
  RoomPeriod(3, '10:10', '11:00'),
  RoomPeriod(4, '11:10', '12:00'),
  RoomPeriod(5, '14:00', '14:50'),
  RoomPeriod(6, '15:00', '15:50'),
  RoomPeriod(7, '16:10', '17:00'),
  RoomPeriod(8, '17:10', '18:00'),
  RoomPeriod(9, '19:00', '19:50'),
  RoomPeriod(10, '20:00', '20:50'),
  RoomPeriod(11, '21:00', '21:50'),
];

class RoomPeriod {
  const RoomPeriod(this.number, this.start, this.end);

  final int number;
  final String start;
  final String end;
}
