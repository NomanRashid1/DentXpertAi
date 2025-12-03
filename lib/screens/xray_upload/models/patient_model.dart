import 'dart:io';

class Patient {
  String? name;
  String age;
  String gender;
  String pain;
  String? painLocation;
  String duration;
  String visitedDentist;
  String email;
  File? xrayImage;

  Patient({
    this.name,
    required this.age,
    required this.gender,
    required this.pain,
    this.painLocation,
    required this.duration,
    required this.visitedDentist,
    required this.email,
    this.xrayImage,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name ?? 'Not Provided',
      'age': age,
      'gender': gender,
      'pain': pain,
      'pain_location': painLocation ?? 'None',
      'duration': duration,
      'visited_dentist': visitedDentist,
      'email': email,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  String get patientInfo {
    return '''
Patient Name: ${name ?? 'Not Provided'}
Age: $age
Gender: $gender
Pain: $pain${pain == 'Yes' ? ' (Location: ${painLocation ?? 'Not specified'})' : ''}
Pain Duration: $duration
Recently Visited Dentist: $visitedDentist
Analysis Date: ${DateTime.now().toLocal()}
''';
  }
}
