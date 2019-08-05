import './api.service.dart';
import 'package:flutter/material.dart';
// import 'package:http/http.dart';


void main() =>runApp(App());

//global variable for useriId;
String userId;

class Urls{
  static const BASE_API_URL = "https://jsonplaceholder.typicode.com";
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo Rest',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Login(),

    );
  }
} 

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {

  bool _isLoading = false; //use to render the loading screen.
  TextEditingController _usernameController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Log in')),
      body: Padding(
          padding:const EdgeInsets.all(32.0),
          child:Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                decoration: InputDecoration(
                  hintText: 'Username',
                ),
                controller: _usernameController,
              ),
              Container(
                height:  20,
              ),
              _isLoading ? CircularProgressIndicator(): SizedBox( //It will make its children have all the same size
                height: 40,
                width: double.infinity, //Take as much space as possible 
                child: RaisedButton(

                  color: Colors.blue,
                  child: Text('Login', style: TextStyle(color: Colors.white),),
                  onPressed: () async{

                    setState(() {
                     _isLoading =true; 
                    });

                    final users = await ApiService.getUserList();

                    setState(() {
                     _isLoading = false; 
                    });

                    if (users == null){
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('Error'),
                            content: Text("Check your internet connection"),
                            actions: <Widget>[
                              FlatButton(
                                child: Text('ok'),
                                onPressed: (){
                                  Navigator.pop(context);
                                },
                              )
                            ],
                          );
                        }
                      );
                      return;
                    } else {
                      final user = users.where((u)=>u['username']== _usernameController.text).first;
                      final userWithUsernameExists = user != null;
                      if(userWithUsernameExists){
                        //storing userid in global is not good in real world app, use storage, this is just an example
                        userId = user['id'].toString();
                        Navigator.push(
                          context, 
                          MaterialPageRoute(
                            builder: (context)=>Posts()
                          )
                        );
                      }else{
                        showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('Incorrect username'),
                            content: Text('Try with a different username'),
                            actions: <Widget>[
                              FlatButton(
                                child: Text('Ok'),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              )
                            ],
                          );
                        }
                      );
                      }
                    }

                  },
                ) ,
              )
              

            ],
          ),
      )
    );
  }
}


class Posts extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title:Text('Posts')),
      //FutureBuilder is a Widget that builds itself based on the latest snapshot of interaction with a Future.
      body: FutureBuilder(
        future: ApiService.getPostList(),
        builder: (context, snapshot){
          if (snapshot.connectionState == ConnectionState.done){
              final posts =snapshot.data;
              return ListView.separated(
                separatorBuilder: (context, index){
                  return Divider( height: 2, color: Colors.black,);
                },
                itemBuilder: (context, index){
                  return ListTile(
                    title: Text(
                        posts[index]['title'],
                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)
                    ),
                    subtitle: Text(posts[index]['body']),
                    onTap: (){
                      // debugPrint(posts[index]['id']);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context)=>Post(posts[index]['id'])
                        )
                      );
                      
                    },
                  );  
                },
                itemCount: posts.length,
              );
          }
          return Center(child: CircularProgressIndicator(),);
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: (){
          Navigator.push(context, MaterialPageRoute(
            builder: (context)=> NewPost(),
          ));
        },
      ),
    );
  }
}


//Single Post
class Post extends StatelessWidget {
  final  int _id;
  Post(this._id);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(title: Text('Post'),),
      body: Column(
        children: <Widget>[
          FutureBuilder(
            future: ApiService.getPost(_id),
            builder: (context,snapshot){
              if (snapshot.connectionState == ConnectionState.done){
                  // final posts =snapshot.data;
                  return Column(
                    children: <Widget>[
                      Text(
                        snapshot.data['title'],
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                      Text(snapshot.data['body'])
                    ],
                  );
              }
              return Center(child: CircularProgressIndicator(),);
            },
          ),
          Container(height: 20,),
          Divider(color: Colors.black, height:3),
          Container(height:20), 
          FutureBuilder(
            future: ApiService.getCommentsForPost(_id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                final comments = snapshot.data;
                return Expanded(
                  child: ListView.separated(
                    separatorBuilder: (context, index) => Divider(height: 2, color: Colors.black,),
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(
                          comments[index]['name'],
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(comments[index]['body']),
                        
                        
                      );
                    },
                    itemCount: comments.length,
                  ),
                );
              }
              return Center(child: CircularProgressIndicator(),);
            },
          )
        ],
      ),
    );
  }
}


class NewPost extends StatefulWidget {
  @override
  _NewPostState createState() => _NewPostState();
}

class _NewPostState extends State<NewPost> {

  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  bool _isLoading = false; //use to render the loading screen.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('New Post')),
      body: Padding( 
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
              TextField(
                controller: _titleController,
                decoration: InputDecoration(hintText: 'Title')),
              TextField(
                controller: _bodyController,
                decoration: InputDecoration(hintText: 'body')),
              Container(height: 40),
              _isLoading ? CircularProgressIndicator() : SizedBox( 
              
                width: double.infinity,
                height: 50,  
                child: RaisedButton(
                  color:Colors.blue,
                  child: Text('Submit', style: TextStyle(color: Colors.white)),
                  onPressed: (){
                    if(_titleController.text.isEmpty || _bodyController.text.isEmpty){
                      showDialog(
                        builder: (context) => AlertDialog(
                          title: Text('Failure'),
                          content: Text('You need to input the title and the body of the post'),
                          actions: <Widget>[FlatButton(
                            onPressed: (){
                              Navigator.pop(context);
                            },
                            child: Text('ok'),
                          )]
                        ),
                        context: context,
                      );
                      return;
                    }
                      final post = {
                        'title': _titleController.text,
                        'body': _bodyController.text,
                        'userId': userId,
                      };
                      setState(() {
                        _isLoading = true; 
                      });
                      ApiService.addPost(post)
                      .then((success){
                        setState(() {
                          _isLoading = false; 
                        });
                        String title, text;
                        if(success){
                          title="Success";
                          text="Your post has been successfully submitted";
                        } else{
                          title = "Error";
                          text = "An error  occurued while submitting your post";
                        }
                        showDialog(
                          builder: (context)=>AlertDialog(
                            title: Text(title),
                            content: Text(text),
                            actions: <Widget>[
                              FlatButton(
                                onPressed: (){
                                  Navigator.pop(context);
                                },
                                child: Text('ok'),
                              )
                            ],
                          ),
                          context: context,
                        );
                      });
                    
                  },
                ),
              )
              
            ],
        ),
      ) 
    );
  }
}