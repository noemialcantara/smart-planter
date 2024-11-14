import 'dart:async';
import 'package:hortijoy_mobile_app/models/register/register.dart';
import 'package:hortijoy_mobile_app/models/request_response.dart';
import 'package:hortijoy_mobile_app/repositories/register/register_repository.dart';
import 'package:flutter/widgets.dart';
import 'package:rxdart/rxdart.dart';

class RegisterBloc {
  final Repository _repository = Repository();

  //sample behavior subject here.
  final BehaviorSubject<bool> _sampleBehaviorSubject = BehaviorSubject<bool>();
  Sink<bool> get sampleSink => _sampleBehaviorSubject.sink;
  Stream<bool> get sampleStream => _sampleBehaviorSubject.stream;

  //sample getter here.
  int _sampleData = 0;
  int get sampleData => _sampleData;

  RegisterBloc() {
    init();
  }

  init() {
    //initial functions here.
  }

  dispose() {
    //dispose here.
    _sampleBehaviorSubject.drain();
  }

  Future<RequestResponse> register(
      {String name = "",
      String phone = "",
      String email = "",
      String licenseNumber = "",
      String referralCode = "",
      String password = "",
      String userType = 'commuter'}) async {
    User user = User(
        name: name,
        phone: phone,
        email: email,
        licenseNumber: licenseNumber,
        referralCode: referralCode,
        password: password);
    RequestResponse response = await _repository.register(user);
    return response;
  }
}

///---Provider---
@immutable
class RegisterBlocProvider extends InheritedWidget {
  final RegisterBloc bloc;

  RegisterBlocProvider({
    required Key key,
    required RegisterBloc bloc,
    required Widget child,
  })   : bloc = bloc,
        super(key: key, child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;

  static RegisterBloc of(BuildContext context) =>
      (context.dependOnInheritedWidgetOfExactType<RegisterBlocProvider>())!
          .bloc;
}
