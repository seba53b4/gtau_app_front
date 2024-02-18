import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:gtau_app_front/constants/theme_constants.dart';
import 'package:gtau_app_front/dto/image_data.dart';
import 'package:gtau_app_front/widgets/common/custom_elevated_button.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../utils/common_utils.dart';

class UserImage extends StatefulWidget {
  final Function(List<ImageDataDTO> files) onFileChanged;
  int? idTask = 0;

  UserImage({required this.onFileChanged, required this.idTask});

  @override
  _UserImageState createState() =>
      _UserImageState(this.onFileChanged, this.idTask);
}

class _UserImageState extends State<UserImage> {
  final Function(List<ImageDataDTO> files) onFileChanged;
  int? idTask = 0;

  final ImagePicker _picker = ImagePicker();

  List<ImageDataDTO>? imagesFiles;
  int activeIndex = 0;

  _UserImageState(this.onFileChanged, this.idTask);

  final double heightImageCarousel = 150;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 12),
        if (imagesFiles == null)
          Container(
            width: heightImageCarousel,
            height: heightImageCarousel,
            decoration: BoxDecoration(
              color: softGrey,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                Icons.image,
                size: 60,
                color: primarySwatch[100],
                semanticLabel: 'No image have been uploaded',
              ),
            ),
          ),
        if (imagesFiles != null)
          Container(
            height: heightImageCarousel,
            child: CarouselSlider.builder(
                options: CarouselOptions(
                  //aspectRatio: 0.25,
                  viewportFraction: 0.75,
                  height: heightImageCarousel,
                  onPageChanged: (index, reason) =>
                      setState(() => activeIndex = index),
                ),
                itemCount: imagesFiles!.length,
                itemBuilder: (context, index, realIndex) {
                  final actualImage = imagesFiles![index].getImage;
                  return Center(
                      heightFactor: 0.5,
                      child: Stack(children: [
                        InkWell(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () => _selectPhoto(),
                          child: Container(
                            width: 150,
                            height: heightImageCarousel,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                  image: actualImage.image, fit: BoxFit.fill),
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
                                      if (imagesFiles!.length == 1) {
                                        imagesFiles = null;
                                      } else {
                                        imagesFiles!.removeAt(activeIndex);
                                      }
                                      /*images.removeAt(index);*/
                                    }))),
                      ]));
                }),
          ),
        const SizedBox(height: 12),
        CustomElevatedButton(
          onPressed: () => _selectPhoto(),
          text: 'Agregar imagen',
          //style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12)
      ],
    );
  }

  void _selectPhoto() async {
    if (kIsWeb) {
      await _pickImage(ImageSource.gallery);
    } else {
      await showModalBottomSheet(
          context: context,
          builder: (context) => BottomSheet(
                builder: (context) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                        leading: const Icon(Icons.camera),
                        title: Text(AppLocalizations.of(context)!.from_camera),
                        onTap: () async {
                          Navigator.of(context).pop();
                          await _pickImage(ImageSource.camera);
                        }),
                    ListTile(
                        leading: const Icon(Icons.filter),
                        title: Text(AppLocalizations.of(context)!.pick_a_file),
                        onTap: () async {
                          Navigator.of(context).pop();
                          await _pickImage(ImageSource.gallery);
                        }),
                  ],
                ),
                onClosing: () {},
              ));
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      if (source == ImageSource.camera) {
        XFile? pickedFile =
            await _picker.pickImage(source: source, imageQuality: 50);
        if (pickedFile == null) {
          // Manejo de caso en el que no se seleccionó ningún archivo.
          return;
        }
        Image temporaryfile = kIsWeb
            ? Image.network(pickedFile.path)
            : Image.file(File(pickedFile.path));
        ImageDataDTO imageDataDTO = ImageDataDTO(
            image: temporaryfile, path: pickedFile.path, fromBlob: false);
        setState(() {
          if (imagesFiles != null) {
            imagesFiles!.add(imageDataDTO);
          } else {
            imagesFiles = [imageDataDTO];
          }
        });
        this.onFileChanged?.call(imagesFiles!);
      } else {
        final List<XFile> images =
            await _picker.pickMultiImage(imageQuality: 50);
        if (images.isEmpty) {
          // Manejo de caso en el que no se seleccionó ningún archivo.
          return;
        }

        List<ImageDataDTO> tempImages = images
            .map((val) => kIsWeb
                ? ImageDataDTO(
                    image: Image.network(val.path),
                    path: val.path,
                    fromBlob: false)
                : ImageDataDTO(
                    image: Image.file(File(val.path)),
                    path: val.path,
                    fromBlob: false))
            .toList();

        setState(() {
          if (imagesFiles != null) {
            imagesFiles!.addAll(tempImages);
          } else {
            imagesFiles = tempImages;
          }
        });
        this.onFileChanged?.call(imagesFiles!);
      }
      // Resto del código para comprimir y establecer la imagen.
    } on PlatformException catch (e) {
      printOnDebug('Error al seleccionar la imagen: $e');
    } catch (error) {
      printOnDebug('Error inesperado: $error');
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
