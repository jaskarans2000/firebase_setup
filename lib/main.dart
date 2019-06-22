import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'model/board.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';


final FirebaseAuth _auth=FirebaseAuth.instance;
final GoogleSignIn _googleSignIn=new GoogleSignIn();
void main() => runApp(MyApp());


class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Community Board',
      theme: ThemeData(

        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

   String imageUrl;
   List<Board> boardMessages=List();
   Board board;
   final FirebaseDatabase database=FirebaseDatabase.instance;
   final GlobalKey<FormState> formKey=GlobalKey<FormState>();
   DatabaseReference databaseReference;


   @override
   void initState() {
     super.initState();

     board=Board("","");
     databaseReference=database.reference().child("community_board");
     databaseReference.onChildAdded.listen(_onEntryAdded);
     databaseReference.onChildChanged.listen(_onEntryChanged);
   }

   /*int _counter = 0;

  void _incrementCounter() {
    database.reference().child("message").set({
      "FirstName":"Jaskaran",
      "LastName":"Singh"
    });

    setState(() {

      database.reference().child("message").once().then((DataSnapshot snapShot){
        Map data=snapShot.value;
        print("Values: ${data.values}");
      });

      _counter++;
    });
  }*/

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Community Board"),
      ),
      body:Center(
        child: Stack(
          children: <Widget>[
        Image.network((imageUrl==null || imageUrl.isEmpty) ?"https://flutter.io/images/catalog-widget-placeholder.png":imageUrl),
      Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                FlatButton(
                  onPressed:()=> _gsignin(),
                  child: Text("Google Sign in"),
                  color: Colors.redAccent,),
                FlatButton(
                  onPressed: (){_signInWithEmail();},
                  child: Text("Sign in with email"),
                  color: Colors.orange,),
              FlatButton(
                  onPressed: ()=>{_createUser()},
                  child: Text("Create Account"),
                  color: Colors.purple,),
                FlatButton(onPressed: _signOutGoogleAccount, child: Text("logout"))

              ],
            )
          ],
        ),
      )

      /*Column(
        children: <Widget>[
          Flexible(
              flex: 0,
              child: Form(
                  key: formKey,
                  child: Flex(
                      direction: Axis.vertical,
                      children: <Widget>[
                        ListTile(
                          leading: Icon(Icons.subject),
                          title: TextFormField(
                            initialValue: "",
                            onSaved: (val)=>board.subject=val,
                            validator: (val)=>val == ""?val:null,
                          ),
                        ),
                        ListTile(
                          leading: Icon(Icons.message),
                          title: TextFormField(
                            initialValue: "",
                            onSaved: (val)=>board.body=val,
                            validator: (val)=>val==""?val:null,
                          ),
                        ),
                        //add send or post button
                        FlatButton(
                          child: Text("Submit"),
                          color: Colors.redAccent,
                          onPressed: (){
                            handlesubmit();
                          },)
                      ],
                  ))),
          Flexible(
              child: FirebaseAnimatedList(
                query: databaseReference,
                itemBuilder: (_,DataSnapshot snapshot,Animation<double> animation,int index){
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.redAccent,
                      ),
                      title: Text(boardMessages[index].subject),
                      subtitle: Text(boardMessages[index].body),
                    ) ,
                  );
                },
              ))
        ],
      )*/,

       // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void _onEntryAdded(Event event) {
    setState(() {
      boardMessages.add(Board.fromSnapshot(event.snapshot));
    });
  }

  void handlesubmit() {
    final FormState form=formKey.currentState;
    if(form.validate()){
      form.save();
      form.reset();
      databaseReference.push().set(board.toJson());
    }
  }

  void _onEntryChanged(Event event) {
    var oldEntry=boardMessages.singleWhere((entry){
      return entry.key==event.snapshot.key;
    });
    setState(()  {
      boardMessages[boardMessages.indexOf(oldEntry)]=Board.fromSnapshot(event.snapshot);
    });
  }

  Future<FirebaseUser>_gsignin() async{
    GoogleSignInAccount googleSignInAccount=await _googleSignIn.signIn();
    GoogleSignInAuthentication googleSignInAuthentication=await googleSignInAccount.authentication;
    FirebaseUser user =await _auth.signInWithGoogle(
        idToken: googleSignInAuthentication.idToken,
        accessToken: googleSignInAuthentication.accessToken);
    setState(() {
      imageUrl=user.photoUrl;
    });

    return user;
  }



   Future<String> _signOutGoogleAccount() async {
     await _auth.signOut();
     await _googleSignIn.signOut();
     return 'signOutWithGoogle succeeded....';
   }

Future  _createUser()async {
    FirebaseUser user=await _auth.createUserWithEmailAndPassword(
        email: "jaskaran@thisishyper.com",
        password: "password").then((user){
          print("User created: ${user.displayName}");
    });
    print(user.email);
}

  void _signInWithEmail() async{
    await _auth.signInWithEmailAndPassword(
        email: "jaskaran@thisishyper.om",
        password: "password").catchError((error){
          print("Something went wrong:${error.toString()}");
    }).then((user){
      print(user.email);
    });
  }
}
