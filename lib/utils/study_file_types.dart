/// Extensions accepted for study-set uploads (summarizer).
class StudyFileTypes {
  StudyFileTypes._();

  static const List<String> uploadExtensions = <String>[
    'pdf',
    'ppt',
    'pptx',
    'jpg',
    'jpeg',
    'png',
    'webp',
    'mp3',
    'wav',
    'm4a',
    'aac',
    'mp4',
    'mov',
    'webm',
  ];

  static const List<String> documentExtensions = <String>['pdf', 'ppt', 'pptx'];

  static bool isAudioVideo(String ext) =>
      <String>['mp3', 'wav', 'm4a', 'aac', 'mp4', 'mov', 'webm'].contains(ext);

  static bool isImage(String ext) => <String>['jpg', 'jpeg', 'png', 'webp'].contains(ext);

  static bool isPowerPoint(String ext) => <String>['ppt', 'pptx'].contains(ext);

  static bool isPdf(String ext) => ext == 'pdf';
}
