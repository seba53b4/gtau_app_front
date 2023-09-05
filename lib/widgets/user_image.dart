import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class UserImage extends StatefulWidget{

  final Function(String imageUrl) onFileChanged;

  UserImage({
    required this.onFileChanged,
  });

  @override
  _UserImageState createState() => _UserImageState();
  
}

class _UserImageState extends State<UserImage>{

  final ImagePicker _picker = ImagePicker();

  String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if(imageUrl == null)
          Icon(Icons.image, size:60, color:Colors.blue, semanticLabel: 'No image have been uploaded',),
        
        if(imageUrl != null)
          InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap:() => _selectPhoto(),
            child: Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: NetworkImage('https://googleflutter.com/sample_image.jpg'),
                  fit: BoxFit.fill
                ),
              ),
            ),
          ),

          InkWell(
            onTap:()  => _selectPhoto(),
            child: Padding(
              padding:EdgeInsets.all(8.0),
              child:Text(imageUrl != null ? 'Change Photo' : 'Select Photo',
              style:TextStyle(color:Colors.blue, fontWeight: FontWeight.bold),),
            ),
          )
      ],
    );
  }

  Future _selectPhoto() async{
    await showModalBottomSheet(context: context, builder: (context) => BottomSheet(
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(leading: Icon(Icons.camera), title: Text('Camera'), onTap: () {
            Navigator.of(context).pop(); 
            _pickImage(ImageSource.camera);
          }),
          ListTile(leading: Icon(Icons.filter), title: Text('Pick a File'), onTap: () {
            Navigator.of(context).pop(); 
            _pickImage(ImageSource.gallery);
          }),
        ],
      ),
      onClosing: () {},
    ));
  }

  Future _pickImage(ImageSource source) async{
    final pickedFile = await _picker.pickImage(source: source, imageQuality: 50); 
    if (pickedFile == null) {
      return; 
    }
    var file = File(pickedFile.path);
    /*var file = await ImageCropper().cropImage(sourcePath: pickedFile.path , aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1));
    if (file == null) {
      return; 
    } */
    file = await compressImage(file.path, 35);

    setState((){imageUrl='https://googleflutter.com/sample_image.jpg';});
    widget.onFileChanged('https://googleflutter.com/sample_image.jpg');
  }

  Future<File> compressImage(String path, int quality) async{
    final newPath = p.join((await getTemporaryDirectory()).path, '${DateTime.now()}.${p.extension(path)}'); 
    
    final result = await FlutterImageCompress.compressAndGetFile(
      path, 
      newPath, 
      quality: quality,
    ); 
    return File(result!.path); 
  }
}