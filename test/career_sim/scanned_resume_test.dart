// Scanned resumes and photos: the page pictures are taken out of the PDF (or
// the photo), read by OCR, parsed like any other resume, and flagged so the
// student checks every field.
import 'dart:io';
import 'dart:typed_data';

import 'package:ai_study_buddy/career_sim/model/career_models.dart';
import 'package:ai_study_buddy/career_sim/resume/pdf_text.dart';
import 'package:ai_study_buddy/career_sim/resume/resume_ocr.dart';
import 'package:ai_study_buddy/career_sim/resume/resume_parser.dart';
import 'package:ai_study_buddy/career_sim/store/career_repository.dart';
import 'package:ai_study_buddy/career_sim/store/career_sim_store.dart';
import 'package:ai_study_buddy/career_sim/ui/resume_screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:provider/provider.dart';

import 'labs_flow_test.dart' show FakeLabRunner, k;

Uint8List fixture(String name) => File('test/fixtures/resumes/$name').readAsBytesSync();
final String transcript = File('test/fixtures/resumes/grace_kim_scan.txt').readAsStringSync();

/// Stands in for the AI reader: returns [text] and remembers what it was sent.
class FakeOcr implements ResumeOcr {
  FakeOcr(this.text, {this.fails = false});
  final String text;
  final bool fails;
  final List<List<ResumeImage>> calls = <List<ResumeImage>>[];
  @override
  Future<String> transcribe(List<ResumeImage> pages) async {
    calls.add(pages);
    if (fails) throw Exception('offline');
    return text;
  }
}

/// Mean grey level of a horizontal band, to compare two decodings of a page.
double band(img.Image p, int y0, int y1) {
  double sum = 0;
  int n = 0;
  for (int y = y0; y < y1; y++) {
    for (int x = 0; x < p.width; x += 3) {
      sum += p.getPixel(x, y).luminance;
      n++;
    }
  }
  return sum / n;
}

void save(String name, ResumeImage r) {
  Directory('build/screens').createSync(recursive: true);
  File('build/screens/$name.png').writeAsBytesSync(img.encodePng(img.decodeJpg(r.bytes)!));
}

void main() {
  test('a JPEG scan inside a PDF becomes one page picture', () {
    final List<ResumeImage> pages = extractPdfScanImages(fixture('grace_kim_scan_jpeg.pdf'));
    expect(pages.length, 1);
    expect(pages.single.mime, 'image/jpeg');
    expect((pages.single.width, pages.single.height), (1275, 1650));
    expect(img.decodeJpg(pages.single.bytes), isNotNull);
    save('scan_jpeg_page', pages.single);
  });

  test('a greyscale Flate scan with PNG predictors decodes to the same page', () {
    final img.Image jpeg = img.decodeJpg(extractPdfScanImages(fixture('grace_kim_scan_jpeg.pdf')).single.bytes)!;
    final ResumeImage grayPage = extractPdfScanImages(fixture('grace_kim_scan_gray.pdf')).single;
    final img.Image gray = img.decodeJpg(grayPage.bytes)!;
    expect((gray.width, gray.height), (1275, 1650));
    save('scan_gray_page', grayPage);
    // Margins are white, text lines are dark, and both decodings agree.
    expect(band(gray, 0, 60), greaterThan(0.95 * 255));
    expect(band(gray, 90, 130), lessThan(band(gray, 0, 60) - 4), reason: 'the name line has ink');
    for (int y = 0; y < 1600; y += 100) {
      expect((band(gray, y, y + 40) - band(jpeg, y, y + 40)).abs(), lessThan(8), reason: 'band at $y');
    }
  });

  test('fax-compressed scans are refused with a clear message', () {
    expect(
      () => extractResumeText('scan.pdf', fixture('grace_kim_scan_fax.pdf')),
      throwsA(isA<FormatException>().having((FormatException e) => e.message, 'message', contains('fax'))),
    );
  });

  test('a text PDF is still read directly, without OCR', () {
    expect(() => extractResumeText('cv.pdf', fixture('ethan_brooks_engineering.pdf')), returnsNormally);
  });

  test('scanned PDFs and photos are handed over for reading', () {
    for (final (String file, String format) in const <(String, String)>[
      ('grace_kim_scan_jpeg.pdf', 'pdf'),
      ('grace_kim_scan_gray.pdf', 'pdf'),
      ('grace_kim_photo.jpg', 'image'),
    ]) {
      try {
        extractResumeText(file, fixture(file));
        fail('$file should need OCR');
      } on ScannedResume catch (s) {
        expect(s.format, format, reason: file);
        expect(s.pages, isNotEmpty, reason: file);
        expect(s.pages.every((ResumeImage p) => p.width <= 2000 && p.height <= 2000), isTrue);
      }
    }
  });

  test('a scanned resume is read, parsed and flagged for checking', () async {
    final FakeOcr ocr = FakeOcr(transcript);
    final MemoryCareerRepository repo = MemoryCareerRepository();
    final CareerSimStore s = CareerSimStore(repository: repo, runner: FakeLabRunner(const <String, List<List<Object?>>>{}), ocr: ocr);
    await s.ensureLoaded(userId: 'scan_user', majorId: 'biology');
    final ResumeUpload u = await s.uploadResume('grace_scan.pdf', fixture('grace_kim_scan_jpeg.pdf'));
    expect(ocr.calls.single.length, 1);
    expect(u.scanned, isTrue);
    expect(u.format, 'pdf');
    expect(u.parsed.name, 'Grace Kim');
    expect(u.parsed.email, 'grace.kim@example.com');
    expect(u.parsed.education, isNotEmpty);
    expect(repo.files[u.storagePath], isNotNull);

    final ResumeUpload photo = await s.uploadResume('grace.jpg', fixture('grace_kim_photo.jpg'));
    expect(photo.format, 'image');
    expect(photo.storagePath, endsWith('.jpg'));
    expect(photo.scanned, isTrue);

    // The flag survives a restart.
    final CareerSimStore again = CareerSimStore(repository: repo, runner: FakeLabRunner(const <String, List<List<Object?>>>{}));
    await again.ensureLoaded(userId: 'scan_user', majorId: 'biology');
    expect(again.profile.resumeUpload(u.id)!.scanned, isTrue);
  });

  test('without the AI service, or when reading fails, the student is told what to do', () async {
    Future<CareerSimStore> store(ResumeOcr? ocr) async {
      final CareerSimStore s = CareerSimStore(repository: MemoryCareerRepository(), runner: FakeLabRunner(const <String, List<List<Object?>>>{}), ocr: ocr);
      await s.ensureLoaded(majorId: 'biology');
      return s;
    }

    Matcher says(String text) => throwsA(isA<CareerActionException>().having((CareerActionException e) => e.message, 'message', contains(text)));
    final Uint8List scan = fixture('grace_kim_scan_jpeg.pdf');
    await expectLater((await store(null)).uploadResume('scan.pdf', scan), says('scanned resume'));
    await expectLater((await store(FakeOcr('', fails: true))).uploadResume('scan.pdf', scan), says('could not be read just now'));
    await expectLater((await store(FakeOcr('Grace'))).uploadResume('scan.pdf', scan), says('Not enough text'));
    final CareerSimStore none = await store(null);
    await expectLater(none.uploadResume('scan.pdf', scan), throwsA(isA<CareerActionException>()));
    expect(none.profile.resumeUploads, isEmpty, reason: 'nothing is saved when reading fails');
  });

  testWidgets('a photo uploaded on screen shows the "check every field" notice', (WidgetTester t) async {
    t.view.physicalSize = const Size(1200, 4000);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    final CareerSimStore s = CareerSimStore(repository: MemoryCareerRepository(), runner: FakeLabRunner(const <String, List<List<Object?>>>{}), ocr: FakeOcr(transcript));
    await s.ensureLoaded(majorId: 'biology');
    ResumeHubScreen.picker = () async => ('grace.jpg', fixture('grace_kim_photo.jpg'));
    addTearDown(() => ResumeHubScreen.picker = pickResumeFile);
    await t.pumpWidget(ChangeNotifierProvider<CareerSimStore>.value(value: s, child: const MaterialApp(home: ResumeHubScreen())));
    await t.pumpAndSettle();
    expect(find.textContaining('photo (JPG/PNG)'), findsOneWidget);
    await t.tap(k('upload_resume'));
    await t.pumpAndSettle();
    expect(k('scan_notice'), findsOneWidget);
    expect(find.text('Grace Kim'), findsWidgets);
  });
}
