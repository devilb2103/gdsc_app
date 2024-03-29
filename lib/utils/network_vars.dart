// String serverAddress = 'https://gdsc-server.onrender.com';
// String serverAddress = "https://gdsc-server-production.up.railway.app";
String serverAddress = "https://gdsc-server.vercel.app";

String newsReadPath = '$serverAddress/read/news';

String eventsReadPath = '$serverAddress/read/events';
String eventsRegisterPath = '$serverAddress/create/event';
String eventsEditPath = '$serverAddress/update/event';
String deleteEventpath = '$serverAddress/delete/event';
String eventParticipantsReadPath = '$serverAddress/read/event/participants';
String addEventParticipantPath = '$serverAddress/create/event_participants';
String removeEventParticipantPath = '$serverAddress/delete/event_participants';

String registerUserPath = '$serverAddress/create/user';
String getUserInfoPath = '$serverAddress/read/userInfo';
String updateUserInfoPath = '$serverAddress/update/user';

var events = {};
var sortedEvents = {};
var news = {};
var userDetails = {};
var participantDetails = {};
var sortedParticipantsDetails = {};
