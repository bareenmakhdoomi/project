import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';
import 'package:salook/components/custom_image.dart';
import 'package:salook/models/user.dart';
import 'package:salook/result_screen.dart';
import 'package:salook/utils/firebase.dart';
import 'package:salook/view_models/auth/posts_view_model.dart';
import 'package:salook/widgets/indicators.dart';

class CreatePost extends StatefulWidget {
  @override
  _CreatePostState createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    currentUserId() {
      return firebaseAuth.currentUser!.uid;
    }

    PostsViewModel viewModel = Provider.of<PostsViewModel>(context);
    CustomResultScreen resultScreen = CustomResultScreen();

    // Initialize CustomResultScreen
    return WillPopScope(
      onWillPop: () async {
        await viewModel.resetPost();
        return true;
      },
      child: LoadingOverlay(
        progressIndicator: circularProgress(context),
        isLoading: viewModel.loading,
        child: Scaffold(
          key: viewModel.scaffoldKey,
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Ionicons.close_outline),
              onPressed: () {
                viewModel.resetPost();
                Navigator.pop(context);
              },
            ),
            title: Text('SALOOK'.toUpperCase()),
            centerTitle: true,
            actions: [
              GestureDetector(
                onTap: () async {
                   await viewModel.uploadPosts(context);
                   await viewModel.uploadPost();
                  Navigator.pop(context);
                  viewModel.resetPost();
                },
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    'Post'.toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15.0,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
              )
            ],
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start, // Align widgets to the left
                children: [
                  SizedBox(height: 15.0),
                  StreamBuilder(
                    stream: usersRef.doc(currentUserId()).snapshots(),
                    builder:
                        (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                      if (snapshot.hasData) {
                        final Map<String, dynamic>? data =
                            snapshot.data!.data() as Map<String, dynamic>?;
                        if (data != null) {
                          UserModel user = UserModel.fromJson(data);
                          return ListTile(
                            leading: CircleAvatar(
                              radius: 25.0,
                              backgroundImage: NetworkImage(user.photoUrl!),
                            ),
                            title: Text(
                              user.username!,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              user.email!,
                            ),
                          );
                        }
                      }
                      return Container();
                    },
                  ),
                  InkWell(
                    onTap: () => showImageChoices(
                      context,
                      viewModel,
                      resultScreen,
                    ),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.width - 30,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.all(
                          Radius.circular(5.0),
                        ),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      child: viewModel.imgLink != null
                          ? CustomImage(
                              imageUrl: viewModel.imgLink,
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.width - 30,
                              fit: BoxFit.cover,
                            )
                          : viewModel.mediaUrl == null
                              ? Center(
                                  child: Text(
                                    'Upload a Photo',
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                    ),
                                  ),
                                )
                              : Image.file(
                                  viewModel.mediaUrl!,
                                  width: MediaQuery.of(context).size.width,
                                  height:
                                      MediaQuery.of(context).size.width - 30,
                                  fit: BoxFit.cover,
                                ),
                    ),
                  ),
                  SizedBox(height: 20.0),
                  Text(
                    'Post Caption'.toUpperCase(),
                    textAlign: TextAlign.left, // Align text to the left
                    style: TextStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextFormField(
                    controller: viewModel.postdesc,
                    decoration: InputDecoration(
                      hintText: 'Eg. This is a very beautiful quote!',
                      focusedBorder: UnderlineInputBorder(),
                    ),
                    maxLines: null,
                    onChanged: (val) => {
                      setState(() {
                        viewModel.setDescription(val);
                        // _controller.text = viewModel.description.toString(),
                      })
                    },
                  ),
                  SizedBox(height: 20.0),
                  Text(
                    'Location'.toUpperCase(),
                    textAlign: TextAlign.left, // Align text to the left
                    style: TextStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.all(0.0),
                    title: Container(
                      width: 250.0,
                      child: TextFormField(
                        controller: viewModel.locationTEC,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(0.0),
                          hintText: 'Jammu & Kashmir!',
                          focusedBorder: UnderlineInputBorder(),
                        ),
                        maxLines: null,
                        onChanged: (val) => viewModel.setLocation(val),
                      ),
                    ),
                    trailing: IconButton(
                      tooltip: "Use your current location",
                      icon: Icon(
                        CupertinoIcons.map_pin_ellipse,
                        size: 25.0,
                      ),
                      iconSize: 30.0,
                      color: Theme.of(context).colorScheme.secondary,
                      onPressed: () => viewModel.getLocation(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  showImageChoices(BuildContext context, PostsViewModel viewModel,
      CustomResultScreen resultScreen) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: .6,
          child: ListView(
            padding: EdgeInsets.all(16.0),
            children: [
              SizedBox(height: 20.0),
              Text(
                'Select Image',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.mic),
                title: Text('Speak'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SpeechScreen()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.description),
                title: Text('OCR'),
                onTap: () {
                  Navigator.pop(context);
                  showOCRChoices(
                    context,
                    viewModel,
                    resultScreen,
                  );
                  // resultScreen.scanImage(context); // Use the 'result' parameter
                },
              ),
              ListTile(
                leading: Icon(Icons.text_fields),
                title: Text('Type'),
                onTap: () {
                  Navigator.pop(context);
                  resultScreen.buildTextField(context);
                },
              ),
              ListTile(
                leading: Icon(Ionicons.camera_outline),
                title: Text('Camera'),
                onTap: () async {
                  Navigator.pop(context);
                  await viewModel.pickImage1(camera: true, context: context);
                },
              ),
              ListTile(
                leading: Icon(Ionicons.image),
                title: Text('Gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  await viewModel.pickImage1(context: context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  showOCRChoices(BuildContext context, PostsViewModel viewModel,
      CustomResultScreen resultScreen) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: .41,
          child: ListView(
            padding: EdgeInsets.all(16.0),
            children: [
              Text(
                'Select Image',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Divider(),
              ListTile(
                leading: Icon(Ionicons.camera_outline),
                title: Text('Camera'),
                onTap: () async {
                  Navigator.pop(context);
                  await viewModel.pickImageOCR(camera: true, context: context);
                },
              ),
              ListTile(
                leading: Icon(Ionicons.image),
                title: Text('Gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  await viewModel.pickImageOCR(context: context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
