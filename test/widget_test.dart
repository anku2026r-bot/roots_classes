import 'package:flutter_test/flutter_test.dart';
import 'package:roots_classes/core/network/api_constants.dart';
import 'package:roots_classes/core/utils/security_utils.dart';
import 'package:roots_classes/core/utils/validators.dart';
import 'package:roots_classes/models/educational_video_model.dart';
import 'package:roots_classes/models/home_banner_model.dart';
import 'package:roots_classes/models/team_member_model.dart';
import 'package:roots_classes/models/user_model.dart';

void main() {
  group('Validators Test', () {
    test('Email validation returns null on valid emails and error message on invalid', () {
      expect(Validators.validateEmail(''), isNotNull);
      expect(Validators.validateEmail('invalid-email'), isNotNull);
      expect(Validators.validateEmail('student@rootsclasses.com'), isNull);
    });

    test('Full name validation checks length and allowed characters', () {
      expect(Validators.validateFullName(''), isNotNull);
      expect(Validators.validateFullName('A'), isNotNull);
      expect(Validators.validateFullName('Rahul Sharma'), isNull);
    });

    test('Password strength evaluation calculates score and flags correctly', () {
      final weak = Validators.evaluatePassword('123');
      expect(weak.isAcceptable, isFalse);
      expect(weak.label, equals('Weak'));

      final strong = Validators.evaluatePassword('P@ssw0rd2026!');
      expect(strong.isAcceptable, isTrue);
      expect(strong.hasUppercase, isTrue);
      expect(strong.hasLowercase, isTrue);
      expect(strong.hasDigit, isTrue);
      expect(strong.hasSpecialChar, isTrue);
    });

    test('Confirm password requires exact match', () {
      expect(Validators.validateConfirmPassword('pass1', 'pass2'), isNotNull);
      expect(Validators.validateConfirmPassword('pass1', 'pass1'), isNull);
    });

    test('Phone validation verifies 10 digits starting with 6, 7, 8, 9', () {
      expect(Validators.validatePhone(''), isNotNull);
      expect(Validators.validatePhone('1234567890'), isNotNull); // starts with 1
      expect(Validators.validatePhone('987654321'), isNotNull); // 9 digits
      expect(Validators.validatePhone('9876543210'), isNull); // valid
      expect(Validators.validatePhone('7000000000'), isNull); // valid
    });
  });

  group('Security Cryptography Test', () {
    test('Salted password hashing produces consistent SHA-256 digests', () {
      final salt = SecurityUtils.generateSalt();
      final hash1 = SecurityUtils.hashPassword('MySecurePass1!', salt);
      final hash2 = SecurityUtils.hashPassword('MySecurePass1!', salt);
      final hashDiff = SecurityUtils.hashPassword('DifferentPass!', salt);

      expect(hash1, equals(hash2));
      expect(hash1, isNot(equals(hashDiff)));
    });

    test('Random session token and OTP generators produce valid lengths', () {
      final token = SecurityUtils.generateToken(16);
      expect(token.isNotEmpty, isTrue);

      final otp = SecurityUtils.generateVerificationCode();
      expect(otp.length, equals(6));
      expect(int.tryParse(otp), isNotNull);
    });
  });

  group('Home Models and Feature Tests', () {
    test('HomeBannerModel correctly parses json and exposes fields', () {
      final banner = HomeBannerModel.fromJson({
        'id': 'b1',
        'title': 'Test Banner',
        'subtitle': 'Test Subtitle',
        'tag': 'SPECIAL',
        'ctaText': 'Join Now',
        'stats': ['1000+ Enrolled', 'AIR 1'],
      });

      expect(banner.id, equals('b1'));
      expect(banner.title, equals('Test Banner'));
      expect(banner.tag, equals('SPECIAL'));
      expect(banner.stats.length, equals(2));
      expect(banner.toJson()['title'], equals('Test Banner'));
    });

    test('TeamMemberModel correctly parses faculty info', () {
      final member = TeamMemberModel.fromJson({
        'id': 't1',
        'name': 'Dr. Sharma',
        'designation': 'HOD Physics',
        'subject': 'Physics',
        'experience': '15+ Years',
        'qualification': 'Ph.D. IIT Delhi',
        'bio': 'Physics specialist.',
        'expertiseTags': ['Mechanics', 'Optics'],
      });

      expect(member.name, equals('Dr. Sharma'));
      expect(member.subject, equals('Physics'));
      expect(member.expertiseTags, contains('Mechanics'));
      expect(member.rating, equals(4.9));
    });

    test('EducationalVideoModel parses video metadata and duration', () {
      final video = EducationalVideoModel.fromJson({
        'id': 'v1',
        'title': 'Rotational Mechanics in 30 Min',
        'subject': 'Physics',
        'instructorName': 'Dr. Sharma',
        'duration': '30:00',
        'durationSeconds': 1800,
        'views': 5000,
        'category': 'JEE',
        'description': 'Master moment of inertia.',
        'topicsCovered': ['Theorem 1', 'Theorem 2'],
      });

      expect(video.duration, equals('30:00'));
      expect(video.durationSeconds, equals(1800));
      expect(video.topicsCovered.length, equals(2));
      expect(video.views, equals(5000));
    });
  });

  group('Student Backend API Integration Schema Tests', () {
    test('UserModel parses student controller response schema (_id and fullName)', () {
      final json = {
        '_id': '64abc123xyz',
        'fullName': 'Rahul Sharma',
        'email': 'rahul@gmail.com',
        'role': 'student',
        'phone': '9876543210',
        'currentClass': '11th',
        'interestedCourse': 'NEET',
        'gender': 'Male',
        'address': 'Delhi, India',
      };

      final student = UserModel.fromJson(json);

      expect(student.id, equals('64abc123xyz'));
      expect(student.name, equals('Rahul Sharma'));
      expect(student.email, equals('rahul@gmail.com'));
      expect(student.role, equals('student'));
      expect(student.phone, equals('9876543210'));
      expect(student.currentClass, equals('11th'));
      expect(student.interestedCourse, equals('NEET'));
    });

    test('ApiConstants defines student authentication endpoints correctly', () {
      expect(ApiConstants.studentRegister, equals('/student/register'));
      expect(ApiConstants.studentLogin, equals('/student/login'));
      expect(ApiConstants.studentSendOtp, equals('/student/send-otp'));
      expect(ApiConstants.studentVerifyOtp, equals('/student/verify-otp'));
      expect(ApiConstants.studentResetPassword, equals('/student/reset-password'));
    });
  });
}
