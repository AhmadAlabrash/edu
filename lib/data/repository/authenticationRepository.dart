// ignore_for_file: non_constant_identifier_names

import 'package:e_demand/app/generalImports.dart';

class AuthenticationRepository {
  static String? kPhoneNumber;
  static String? verificationId;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool get isLoggedIn => _auth.currentUser != null;

  Future verifyPhoneNumber(
    final String phoneNumber, {
    Function(dynamic err)? onError,
    VoidCallback? onCodeSent,
  }) async {
    kPhoneNumber = phoneNumber;
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (final PhoneAuthCredential complete) {},
      verificationFailed: (final FirebaseAuthException err) {
        onError?.call(err);
      },
      codeSent: (final String verification, final int? forceResendingToken) {
        verificationId = verification;
        // this is force resending token
        HiveRepository.setResendToken = forceResendingToken;

        if (onCodeSent != null) {
          onCodeSent();
        }
      },
      forceResendingToken: HiveRepository.getResendToken,
      //Hive.box(authStatusBoxKey).get("resendToken"),
      codeAutoRetrievalTimeout: (final String timeout) {},
    );

    //  confirmation = confirmationResult;
  }

  static Future<UserDetailsModel> loginUser({
    required final String latitude,
    required final String longitude,
    required final String mobileNumber,
    required final String countryCode,
    final String? fcmId,
  }) async {
    try {
      final parameters = <String, dynamic>{
        Api.countryCode: countryCode,
        Api.mobile: mobileNumber,
        Api.latitude: latitude,
        Api.longitude: longitude,
      };
      if (fcmId != null) {
        parameters[Api.fcmId] = fcmId;
        parameters[Api.platform] = Platform.isAndroid ? "android" : "ios";
      }

      final Map<String, dynamic> result =
          await Api.post(url: Api.manageUser, parameter: parameters, useAuthToken: false);

      final UserDetailsModel userDetailsModel = UserDetailsModel.fromMap(result["data"]);

      HiveRepository.setUserToken = result["token"];

      final Map<String, dynamic> map = userDetailsModel.toMap();

      final LocationPermission permisison = await Geolocator.checkPermission();

      if (permisison == LocationPermission.denied ||
          permisison == LocationPermission.deniedForever) {
        map.remove("latitude");
        map.remove("longitude");
      }

      await HiveRepository.putAllValue(boxName: HiveRepository.userDetailBoxKey, values: map);

      HiveRepository.setLatitude = latitude;
      HiveRepository.setLongitude = longitude;
      return userDetailsModel;
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future verifyOtp({
    required final String code,
    required final Function(UserCredential credential) onVerificationSuccess,
  }) async {
    if (verificationId != null) {
      final PhoneAuthCredential credential =
          PhoneAuthProvider.credential(verificationId: verificationId!, smsCode: code);

      await _auth.signInWithCredential(credential).then(onVerificationSuccess);
    }
  }

  Future<Map<String, dynamic>> verifyUserMobileNumberFromAPI(
      {required final String mobileNumber, required final String countryCode}) async {
    try {
      final Map<String, dynamic> parameter = <String, dynamic>{
        Api.mobile: mobileNumber,
        Api.countryCode: countryCode
      };

      final response =
          await Api.post(parameter: parameter, url: Api.verifyUser, useAuthToken: false);

      return {"error": response['error'], "status_code": response['message_code']};
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<Map<String, dynamic>> deleteUserAccount() async {
    try {
      //delete account from Firebase
      await FirebaseAuth.instance.currentUser?.delete();

      //delete account from database
      final Map<String, dynamic> accountData =
          await Api.post(url: Api.deleteUserAccount, parameter: {}, useAuthToken: true);

      return {"error": accountData['error'], "message": accountData['message']};
    } catch (e) {
      if (e.toString().contains('firebase_auth/requires-recent-login')) {
        return {"error": true, "message": "pleaseReLoginAgainToDeleteAccount"};
      }
      return {"error": true, "message": e.toString()};
    }
  }

  Future<UserDetailsModel> getUserDetails() async {
    try {
      final Map<String, dynamic> result =
          await Api.post(url: Api.getUserDetails, parameter: {}, useAuthToken: true);

      final UserDetailsModel userDetailsModel = UserDetailsModel.fromMap(result["data"]);

      final Map<String, dynamic> map = userDetailsModel.toMap();

   //   await HiveRepository.putAllValue(boxName: HiveRepository.userDetailBoxKey, values: map);


      var latitude = HiveRepository.getLatitude;
      var longitude = HiveRepository.getLongitude;

      await HiveRepository.putAllValue(boxName: HiveRepository.userDetailBoxKey, values: map);

      HiveRepository.setLatitude = latitude;
      HiveRepository.setLongitude = longitude;
      //
      return userDetailsModel;
    } catch (e) {
      throw ApiException(e.toString());
    }
  }
}
