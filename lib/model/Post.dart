import 'package:firebase_database/firebase_database.dart';

class Post {
  String key;
  String title;
  String description;
  String image_url;
  String source_url;
  String published_on;
  String label;
  Post(this.key,this.title, this.description, this.image_url, this.source_url, this.published_on, this.label);



  Post.fromSnapshot(DataSnapshot snapshot)
      :
        key = snapshot.key,
        title = snapshot.value["title"],
        description= snapshot.value["description"],
        image_url= snapshot.value["image_url"],
        source_url= snapshot.value["source_url"],
        published_on= snapshot.value["published_on"],
        label= snapshot.value["label"];


  toJson() {
    return {
      "key":key,
      "title": title,
      "description": description,
      "image_url": image_url,
      "source_url": source_url,
      "published_on": published_on,
      "label": label,
    };
  }
}