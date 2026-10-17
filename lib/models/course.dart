class Course {
  final String code;
  final String title;
  final int credits;
  final String status;

  const Course({
    required this.code,
    required this.title,
    required this.credits,
    required this.status,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    final dynamic rawCredits = json['credits'];
    int parsedCredits = 0;

    if (rawCredits is int) {
      parsedCredits = rawCredits;
    } else if (rawCredits is num) {
      parsedCredits = rawCredits.toInt();
    } else if (rawCredits != null) {
      parsedCredits = int.tryParse(rawCredits.toString()) ?? 0;
    }

    return Course(
      code: (json['code'] ?? '').toString(),
      title: (json['title'] ?? 'Materi').toString(),
      credits: parsedCredits,
      status: (json['status'] ?? 'not_started').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'title': title,
      'credits': credits,
      'status': status,
    };
  }

  bool get isDone => status.toLowerCase() == 'done';

  String get creditsLabel {
    return credits > 0 ? '$credits SKS' : '-';
  }
}