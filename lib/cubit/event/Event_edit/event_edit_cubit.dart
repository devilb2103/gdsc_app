import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:DSCSITP/Models/event_model.dart';
import 'package:DSCSITP/utils/network_vars.dart';
import 'package:meta/meta.dart';

part 'event_edit_state.dart';

class EventEditCubit extends Cubit<EventEditState> {
  EventEditCubit() : super(const EventEditInitialState());

  bool _canTriggerActions = true;

  Future<void> editEvent(String eid, EventModel eventData) async {
    if (!_canTriggerActions) return;
    _canTriggerActions = false;
    emit(const EventEditProcessingState());

    try {
      var res = await Dio().patch(
        eventsEditPath,
        data: {
          "eid": eid,
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
          emit(EventEditedState(jsonRes["message"].toString()));
        } else {
          emit(EventEditErrorState(jsonRes["message"].toString()));
        }
      } else {
        emit(EventEditErrorState(
            "Server returned an error with status code ${res.statusCode}"));
      }
      emit(const EventEditInitialState());
    } on DioError catch (e) {
      emit(EventEditErrorState(e.error.toString()));
      emit(const EventEditInitialState());
    } on Exception catch (e) {
      emit(EventEditErrorState(e.toString()));
      emit(const EventEditInitialState());
    }
    _canTriggerActions = true;
  }
}
