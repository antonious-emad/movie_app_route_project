import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';


import '../../../../database_utils/database_utils.dart';
import '../../../../models/movie_model.dart';

class NewReleasesMovieWidget extends StatefulWidget {
  Movie mov;
  NewReleasesMovieWidget(this.mov);

  @override
  State<NewReleasesMovieWidget> createState() => _NewReleasesMovieWidgetState();
}

class _NewReleasesMovieWidgetState extends State<NewReleasesMovieWidget> {
  String img = 'https://image.tmdb.org/t/p/w500';
  int isSelected = 0;

  @override
  void initState() {
    super.initState();
    checkMovieInFireStore();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Card(
          clipBehavior: Clip.antiAlias,
          shape: BeveledRectangleBorder(borderRadius: BorderRadius.circular(4)),
          elevation: 5,
          child: CachedNetworkImage(
            imageUrl: "$img${widget.mov.posterPath}",
            imageBuilder: (context, imageProvider) => Container(
              height: MediaQuery.of(context).size.height * 0.30,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            placeholder: (context, url) => CircularProgressIndicator(),
            errorWidget: (context, url, error) => Center(child: Icon(Icons.error,color: Colors.red,)),
          ),
        ),

        Positioned(
          top: MediaQuery.of(context).size.height * 0.005,
          left: MediaQuery.of(context).size.width * 0.01,
          child: InkWell(
              onTap: (){
                isSelected=1-isSelected;
                if(isSelected==1){
                 DatabaseUtils.AddMoviesToFirebase(widget.mov);
                }
                else{
                  DatabaseUtils.DeleteMovie('${widget.mov.DataBaseId}');
                }
                setState(() {

                });
              },
              child: isSelected == 0 ? Image.asset('assets/bookmark.png'):Image.asset('assets/bookmarkSelected.png')
          ),
        ),
      ],
    );
  }

  Future<void> checkMovieInFireStore ()async{
    QuerySnapshot<Movie> temp= await DatabaseUtils.readMovieFormFirebase(widget.mov.id!);
    if(temp.docs.isEmpty){
    }else{
      widget.mov.DataBaseId=temp.docs[0].data().DataBaseId;
      isSelected=1;
      setState(() {
      });
    }
  }
}
