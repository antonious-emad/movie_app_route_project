import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:movie_app_route_project/layout/home_layout.dart';

import '../../../database_utils/database_utils.dart';
import '../../../models/movie_model.dart';
import '../Home_tab/movie_details_screen.dart';

class SearchWidget extends StatefulWidget {
  Movie movie;
  SearchWidget(this.movie, {super.key});

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  String img = 'https://image.tmdb.org/t/p/w500';
  int isSelected = 0;

  @override
  void initState() {
    super.initState();
    checkMovieInFireStore();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Stack(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, MovieDetails.routeName,
                          arguments: widget.movie);
                    },
                    child: CachedNetworkImage(
                      imageUrl: "$img${widget.movie.posterPath}",
                      imageBuilder: (context, imageProvider) => Container(
                        height: MediaQuery.of(context).size.height * 0.20,
                        width: MediaQuery.of(context).size.width * 0.40,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(),
                      errorWidget: (context, url, error) => const Center(
                          child: Icon(
                        Icons.error,
                        color: Colors.red,
                        size: 42,
                      )),
                    ),
                  ),
                  Positioned(
                    child: InkWell(
                        onTap: () {
                          isSelected = 1 - isSelected;
                          if (isSelected == 1) {
                            DatabaseUtils.AddMoviesToFirebase(widget.movie);
                          } else {
                            DatabaseUtils.DeleteMovie(
                                '${widget.movie.DataBaseId}');
                          }
                          setState(() {});
                        },
                        child: isSelected == 0
                            ? Image.asset('assets/bookmark.png')
                            : Image.asset('assets/bookmarkSelected.png')),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.movie.title}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        overflow: TextOverflow.ellipsis,
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Text(
                      '${widget.movie.releaseDate!.substring(0, 4)} ',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Text(
                      '${widget.movie.overview} ',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                      maxLines: 6,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ));
  }

  Future<void> checkMovieInFireStore() async {
    QuerySnapshot<Movie> temp =
        await DatabaseUtils.readMovieFormFirebase(widget.movie.id!);
    if (temp.docs.isEmpty) {
    } else {
      widget.movie.DataBaseId = temp.docs[0].data().DataBaseId;
      isSelected = 1;
      setState(() {});
    }
  }

}
