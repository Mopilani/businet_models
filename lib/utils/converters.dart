
String dateTimeToString(DateTime datetime) =>
    '${datetime.year}-${datetime.month}-${datetime.day} ${datetime.hour}:${datetime.minute}:${datetime.second}';
String dateTimeToHexDecString(DateTime datetime) =>
    '${(datetime.year).toRadixString(16)}-${datetime.month.toRadixString(16)}-${datetime.day.toRadixString(16)} ${datetime.hour.toRadixString(16)}:${datetime.minute.toRadixString(16)}:${datetime.second.toRadixString(16)}';
String dateTimeToOctString(DateTime datetime) =>
    '${(datetime.year).toRadixString(8)}-${datetime.month.toRadixString(8)}-${datetime.day.toRadixString(8)} ${datetime.hour.toRadixString(8)}:${datetime.minute.toRadixString(8)}:${datetime.second.toRadixString(8)}';
String dateTimeToString2(DateTime datetime) =>
    '${datetime.year}-${datetime.month}-${datetime.day}-${datetime.hour}-${datetime.minute}-${datetime.second}';
