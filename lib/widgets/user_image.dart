import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class UserImage extends StatefulWidget {
  final Function(List<Image> files) onFileChanged;

  UserImage({
    required this.onFileChanged,
  });

  @override
  _UserImageState createState() => _UserImageState();
}

class _UserImageState extends State<UserImage> {
  final ImagePicker _picker = ImagePicker();

  List<Image>? imagesFiles;
  int activeIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (imagesFiles == null)
          Icon(
            Icons.image,
            size: 60,
            color: Colors.blue,
            semanticLabel: 'No image have been uploaded',
          ),
        if (imagesFiles != null)
          CarouselSlider.builder(
              options: CarouselOptions(height: 200,
              onPageChanged: (index, reason) => setState(() => activeIndex = index),
              ),
              itemCount: imagesFiles!.length,
              itemBuilder: (context, index, realIndex){
                final actualImage = imagesFiles![index];
                return Stack(
                    children: [
                      InkWell(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () => _selectPhoto(),
                        child: Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image:
                                  DecorationImage(image: actualImage!.image, fit: BoxFit.fill),
                            ),
                        ),
                      ),
                      Positioned(
                        right: 10,
                        top: -9,
                        child: IconButton(
                            icon: Icon(
                              Icons.cancel,
                              color: Colors.red.withOpacity(1),
                              size: 40,
                            ),
                            onPressed: () => setState(() {
                              if(imagesFiles!.length==1){
                                imagesFiles=null;
                              }else{
                                imagesFiles!.removeAt(activeIndex);
                              }
                              /*images.removeAt(index);*/
                            })
                        )
                      )
                  ]
                );
              }
          ),
        InkWell(
          onTap: () => _selectPhoto(),
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              imagesFiles != null ? 'Add Photo' : 'Select Photo',
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
            ),
          ),
        )
      ],
    );
  }


  void _selectPhoto() async {
    await showModalBottomSheet(
        context: context,
        builder: (context) => BottomSheet(
              builder: (context) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                      leading: Icon(Icons.camera),
                      title: Text('Camera'),
                      onTap: () async {
                        Navigator.of(context).pop();
                        await _pickImage(ImageSource.camera);
                      }),
                  ListTile(
                      leading: Icon(Icons.filter),
                      title: Text('Pick a File'),
                      onTap: () async {
                        Navigator.of(context).pop();
                        await _pickImage(ImageSource.gallery);
                      }),
                ],
              ),
              onClosing: () {},
            ));
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      if(source==ImageSource.camera){
        final pickedFile =
          await _picker.pickImage(source: source, imageQuality: 50);
        if (pickedFile == null) {
          // Manejo de caso en el que no se seleccionó ningún archivo.
          return;
        }
        Image temporaryfile = kIsWeb
            ? Image.network(pickedFile.path)
            : Image.file(File(pickedFile.path));

        setState(() {
          if(imagesFiles != null){
            imagesFiles!.add(temporaryfile);
          }else{
            imagesFiles = <Image>[temporaryfile];
          }
        });
      }else{
        final List<XFile> images = await _picker.pickMultiImage(imageQuality: 50);
        if (images == null) {
          // Manejo de caso en el que no se seleccionó ningún archivo.
          return;
        }

        List<Image> tempImages = images.map((val) => kIsWeb ? Image.network(val.path) : Image.file(File(val.path))).toList();

        setState(() {
          if(imagesFiles != null){
            imagesFiles!.addAll(tempImages);
          }else{
            imagesFiles = tempImages;
          }
        });
      }
      
      // Resto del código para comprimir y establecer la imagen.
    } on PlatformException catch (e) {
      print('Error al seleccionar la imagen: $e');
    } catch (error) {
      print('Error inesperado: $error');
    }
  }

  Future<File> compressImage(String path, int quality) async {
    final newPath = p.join((await getTemporaryDirectory()).path,
        '${DateTime.now()}.${p.extension(path)}');

    final result = await FlutterImageCompress.compressAndGetFile(
      path,
      newPath,
      quality: quality,
    );
    return File(result!.path);
  }
}
