import 'dart:async';
import 'package:hortijoy_mobile_app/models/login/user.dart';
import 'package:hortijoy_mobile_app/models/request_response.dart';
import 'package:hortijoy_mobile_app/repositories/login/login_repository.dart';
import 'package:flutter/widgets.dart';
import 'package:rxdart/rxdart.dart';

class LoginBloc {
  final Repository _repository = Repository();

  //sample behavior subject here.
  final BehaviorSubject<bool> _sampleBehaviorSubject = BehaviorSubject<bool>();
  final BehaviorSubject<RequestResponse> _loginSubject =
      BehaviorSubject<RequestResponse>();
  Sink<bool> get sampleSink => _sampleBehaviorSubject.sink;
  Stream<bool> get sampleStream => _sampleBehaviorSubject.stream;

  //sample getter here.
  int _sampleData = 0;
  int get sampleData => _sampleData;
  BehaviorSubject<RequestResponse> get loginInfo => _loginSubject;

  LoginBloc() {
    init();
  }

  init() {
    //initial functions here.
  }

  dispose() {
    //dispose here.
    _loginSubject.close();
    _sampleBehaviorSubject.drain();
  }

  Future<RequestResponse> login(
      {String username = "",
      String password = "",
      String userType = 'CONDUCTOR'}) async {
    User user = User(username: username, password: password, role: userType);
    RequestResponse response = await _repository.login(user);
    // print('-----------RXDART GETTER-------');
    // _loginSubject.sink.add(response);
    // print(loginInfo);
    return response;
  }
}

///---Provider---
@immutable
class LoginBlocProvider extends InheritedWidget {
  final LoginBloc bloc;

  LoginBlocProvider({
    required Key key,
    required LoginBloc bloc,
    required Widget child,
  })   : bloc = bloc,
        super(key: key, child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;

  static LoginBloc of(BuildContext context) =>
      (context.dependOnInheritedWidgetOfExactType<LoginBlocProvider>())!.bloc;
}
