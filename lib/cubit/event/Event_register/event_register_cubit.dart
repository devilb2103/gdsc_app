import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:DSCSITP/utils/network_vars.dart';
import 'package:meta/meta.dart';
import 'package:DSCSITP/Models/event_model.dart';

part 'event_register_state.dart';

class EventRegisterCubit extends Cubit<EventRegisterState> {
  EventRegisterCubit() : super(const EventRegisterInitialState());

  bool _canTriggerActions = true;

  Future<void> registerEvent(EventModel eventData) async {
    if (!_canTriggerActions) return;
    _canTriggerActions = false;
    emit(const EventRegisterProcessingState());

    try {
      var res = await Dio().post(
        eventsRegisterPath,
        data: {
          "uid": FirebaseAuth.instance.currentUser?.uid,
          "domain": eventData.eventDomain.toString(),
          "name": eventData.eventName.toString(),
          "description": eventData.eventDescripion.toString(),
          "venue": eventData.eventVenue.toString(),
          "startDate": eventData.eventStartDate.toString(),
          "endDate": eventData.eventEndDate.toString(),
          "startTime": eventData.eventStartTime.toString(),
          "endTime": eventData.eventEndTime.toString()
        },
      );
      if (res.statusCode == 200) {
        var jsonRes = res.data;
        if (jsonRes["status"] == true) {
          emit(EventRegisteredState(jsonRes["message"].toString()));
        } else {
          // emit(EventRegisterErrorState(jsonRes["message"].toString()));
          emit(const EventRegisterErrorState(
              "An internal error has occured, try again later"));
        }
      } else {
        emit(EventRegisterErrorState(
            "Server returned an error with status code ${res.statusCode}"));
      }
      emit(const EventRegisterInitialState());
    } on DioError catch (e) {
      emit(EventRegisterErrorState(e.error.toString()));
      emit(const EventRegisterInitialState());
    } on Exception catch (e) {
      emit(EventRegisterErrorState(e.toString()));
      emit(const EventRegisterInitialState());
    }
    _canTriggerActions = true;
  }
}
