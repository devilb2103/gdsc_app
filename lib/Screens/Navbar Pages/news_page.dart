import 'package:DSCSITP/Screens/news_details_screen.dart';
import 'package:DSCSITP/utils/network_vars.dart';
import 'package:DSCSITP/utils/page_transition.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:DSCSITP/cubit/news/news_cubit.dart';
import 'package:intl/intl.dart' show toBeginningOfSentenceCase;
import 'package:url_launcher/url_launcher.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  @override
  void initState() {
    super.initState();
    context.read<NewsCubit>().refreshNewsData();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NewsCubit, NewsState>(
      listener: (context, state) {
        if (state is NewsErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              backgroundColor: Colors.red[300], content: Text(state.message)));
        }
      },
      builder: (context, state) {
        if (state is NewsProcessingState) {
          return const Center(child: CircularProgressIndicator());
        } else {
          return const NewsPageOverview();
        }
      },
    );
  }
}

class NewsPageOverview extends StatefulWidget {
  const NewsPageOverview({super.key});

  @override
  State<NewsPageOverview> createState() => _NewsPageOverviewState();
}

class _NewsPageOverviewState extends State<NewsPageOverview> {
  Future<void> openUrl(String url) async {
    try {
      launchUrl(Uri.parse(url));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.red[300],
          content: const Text("could not open news url")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await context.read<NewsCubit>().refreshNewsData();
      },
      child: Container(
        color: Colors.grey[50],
        child: ListView.builder(
          physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics()),
          itemCount: news['count-articles'],
          itemBuilder: (context, index) {
            return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                child: newsItem(index, context));
          },
        ),
      ),
    );
  }

  Widget newsItem(int index, BuildContext context) {
    String category = news['category'].toString();
    String author = news['data'][index]['author'].toString();
    String description = news['data'][index]['content'].toString();
    String time = news['data'][index]['postedAt'].toString();
    String title = news['data'][index]['title'].toString();
    String url = news['data'][index]['readMore'].toString();
    String imageUrl = news['data'][index]['image'].toString();
    return Column(
      children: [
        index == 0 ? const SizedBox(height: 12) : const SizedBox(),
        InkWell(
          onTap: () {
            Navigator.push(
                context,
                customSlideTransitionRight(NewsDetailsScreen(
                  author: author,
                  category: category,
                  description: description,
                  imageUrl: imageUrl,
                  time: time,
                  title: title,
                  url: url,
                )));
          },
          child: Card(
              elevation: 3,
              color: Colors.blueGrey[50],
              shadowColor: Colors.black,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18)),
              child: Padding(
                padding: const EdgeInsets.only(
                    top: 6, bottom: 12, left: 6, right: 6),
                child: Column(
                  children: [
                    if (imageUrl != "None")
                      Stack(
                        alignment: Alignment.topLeft,
                        children: [
                          Material(
                            elevation: 3,
                            shadowColor: Colors.black,
                            borderRadius: BorderRadius.circular(18),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: AspectRatio(
                                aspectRatio: 10 / 5.5,
                                child: Image(
                                  image: NetworkImage(imageUrl),
                                  fit: BoxFit.fitWidth,
                                  alignment: FractionalOffset.center,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey[300],
                                      child: Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(children: [
                                            const Icon(Icons.error,
                                                color: Colors.red),
                                            const SizedBox(height: 9),
                                            Text(
                                              error.toString(),
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w300),
                                            )
                                          ]),
                                        ),
                                      ),
                                    );
                                  },
                                  frameBuilder: (context, child, frame,
                                      wasSynchronouslyLoaded) {
                                    return child;
                                  },
                                  loadingBuilder: (BuildContext context,
                                      Widget child,
                                      ImageChunkEvent? loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          value: loadingProgress
                                                      .expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                          if (category != "None")
                            Positioned(
                              left: 10,
                              top: 10,
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.blue[500],
                                    borderRadius: BorderRadius.circular(18)),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    toBeginningOfSentenceCase(category)!,
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          if (imageUrl != "None")
                            Positioned(
                              bottom: 10,
                              right: 10,
                              child: ElevatedButton(
                                onPressed: () async {
                                  await openUrl(url);
                                },
                                style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(18)),
                                    shadowColor: Colors.black,
                                    backgroundColor: Colors.black54,
                                    elevation: 3),
                                child: const Text("Visit"),
                              ),
                            )
                        ],
                      ),
                    Padding(
                      padding: const EdgeInsets.only(top: 6, right: 8, left: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (imageUrl == "None")
                            ElevatedButton(
                              onPressed: () async {
                                await openUrl(url);
                              },
                              style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18)),
                                  shadowColor: Colors.black,
                                  backgroundColor: Colors.black,
                                  elevation: 3),
                              child: const Text("Visit"),
                            ),
                          Expanded(child: Container()),
                        ],
                      ),
                    ),
                    const SizedBox(height: 9),
                    if (title != "None" || title == "null")
                      Padding(
                        padding: const EdgeInsets.only(
                            right: 8, left: 8, bottom: 0, top: 0),
                        child: Column(
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w400, fontSize: 21),
                            )
                          ],
                        ),
                      ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (author != "None")
                          Padding(
                            padding: const EdgeInsets.only(left: 8, top: 9),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  author,
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 14),
                                )
                              ],
                            ),
                          ),
                        Expanded(child: Container()),
                        if (time != "None")
                          Padding(
                            padding: const EdgeInsets.only(top: 9, right: 8),
                            child: Text(
                              time,
                              // DateFormat.yMMMMd()
                              //     .format(DateTime.parse(time).toLocal()),
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.grey),
                            ),
                          ),
                      ],
                    )
                  ],
                ),
              )),
        ),
        if (index == news['count-articles'] - 1) const SizedBox(height: 12)
      ],
    );
  }
}
