import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gallery_image_viewer/gallery_image_viewer.dart';
import 'package:gtau_app_front/constants/theme_constants.dart';
import 'package:gtau_app_front/dto/image_data.dart';
import 'package:gtau_app_front/widgets/loading_overlay.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';
import '../viewmodels/images_viewmodel.dart';
import 'common/custom_elevated_button.dart';

class ImageGalleryModal extends StatefulWidget {
  final int? idTask;

  const ImageGalleryModal({super.key, this.idTask});

  @override
  State<ImageGalleryModal> createState() => _ImageGalleryModalState(idTask, []);
}

class _ImageGalleryModalState extends State<ImageGalleryModal> {
  int? idTask;
  List<Photo> photos;

  _ImageGalleryModalState(this.idTask, this.photos);

  

  @override
  Widget build(BuildContext context) {
    return CustomElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => _GelleryShow(idTask, photos)),
        );
      },
      text: AppLocalizations.of(context)!.see_images,
    );
  }
}

class _GelleryShow extends StatefulWidget {
  int? idTask;
  List<Photo> photos;

  _GelleryShow(this.idTask, this.photos);

  @override
  State<StatefulWidget> createState() => _GelleryShowState(idTask, this.photos);
}

class _GelleryShowState extends State<_GelleryShow> {
  int? idTask;
  List<Photo> photos;
   _GelleryShowState(this.idTask, this.photos);

  final ImagePicker _picker = ImagePicker();
  ImagesViewModel? imagesViewModel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    _initializeData();
    imagesViewModel = Provider.of<ImagesViewModel>(context, listen: false);
  }

  void _initializeData() async {
    List<String> urls = await _fetchTaskImages(context, widget.idTask!);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ImagesViewModel>(
        builder: (context, imagesViewModel, child) {
      photos = imagesViewModel.photos;

      if(photos.isEmpty){
        return LoadingOverlay(
          isLoading: imagesViewModel.isLoading,
          child: Scaffold(
            appBar:
                AppBar(title: Text(AppLocalizations.of(context)!.images_title)),
            body:Padding(
              padding: const EdgeInsets.symmetric(horizontal:15),
              child: Center(
                  child:Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding:const EdgeInsets.symmetric(vertical: 25, horizontal:15),
                        child: SvgPicture.asset('lib/assets/empty_gallery.svg', width: 128, height: 128, semanticsLabel: 'Empty Gallery'),
                      ),
                      Text(AppLocalizations.of(context)!
                        .empty_image_gallery,
                      style: TextStyle(color: Colors.black.withOpacity(0.6), fontSize: 20))
                      ,
                      ]
                  )
              )
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
            floatingActionButton: FloatingActionButton(
              onPressed: () => _selectPhoto(),
              foregroundColor: null,
              backgroundColor: null,
              shape: null,
              child: const Icon(Icons.add),
            )
          )
        );

      }else{
        return LoadingOverlay(
          isLoading: imagesViewModel.isLoading,
          child: Scaffold(
            appBar:
                AppBar(title: Text(AppLocalizations.of(context)!.images_title)),
            body: GridView.builder(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              padding: const EdgeInsets.all(1),
              itemCount: photos.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
              ),
              itemBuilder: ((context, index) {
                return Container(
                  padding: const EdgeInsets.all(0.5),
                  decoration: BoxDecoration(
                    border: photos[index].isSelected
                        ? Border.all(color: Colors.blue, width: 3)
                        : null,
                  ),
                  child: InkWell(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            PhotoViewPage(photos: photos, index: index),
                      ),
                    ),
                    onLongPress: () {
                      setState(() {
                        photos[index].isSelected = !photos[index].isSelected;
                      });
                    },
                    onDoubleTap: () {
                      setState(() {
                        photos[index].isSelected = !photos[index].isSelected;
                      });
                    },
                    child: Hero(
                      tag: photos[index],
                      child: CachedNetworkImage(
                        color: Colors.black
                            .withOpacity(photos[index].isSelected ? 1 : 0),
                        colorBlendMode: BlendMode.color,
                        imageUrl: photos[index].url,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            Container(color: softGrey),
                        errorWidget: (context, url, error) => Container(
                          color: !photos[index].isSelected
                              ? Colors.red.shade400
                              : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
            floatingActionButton: FloatingActionButton(
              onPressed: () => _selectPhoto(),
              foregroundColor: null,
              backgroundColor: null,
              shape: null,
              child: const Icon(Icons.add),
            ),
            bottomNavigationBar: photos.any((photo) => photo.isSelected)
                ? BottomNavigationBar(
                    items: [
                      BottomNavigationBarItem(
                        icon: const Icon(Icons.cleaning_services),
                        label: AppLocalizations.of(context)!
                            .modal_image_delete_selection,
                      ),
                      BottomNavigationBarItem(
                        icon: const Icon(Icons.delete),
                        label: AppLocalizations.of(context)!.deleteButtonLabel,
                      ),
                    ],
                    onTap: (index) {
                      if (index == 0) {
                        setState(() {
                          photos
                              .forEach((element) => element.isSelected = false);
                          this.photos = photos;
                        });
                      } else if (index == 1) {
                        _deleteSelectedImages(photos);
                      }
                    },
                    // Habilita o deshabilita el botón "Eliminar" según si hay imágenes seleccionadas o no
                    currentIndex: 1,
                  )
                : null,
          ));
        }
      });
    
      
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

  Future updateImageViewState(
      BuildContext context) async {
        final token = Provider.of<UserProvider>(context, listen: false).getToken;
        await imagesViewModel!.fetchTaskImages(token, idTask!);
  }

  Future updateImageViewStateWithDelay(
      BuildContext context, int delaysec) async {
        final token = Provider.of<UserProvider>(context, listen: false).getToken;
        await imagesViewModel!.fetchTaskImagesWithDelay(token, idTask!, delaysec);
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
          processImageSingular(imageDataDTO);
        });
      } else {
        final List<XFile> images =
            await _picker.pickMultiImage(imageQuality: 50);
        if (images.isEmpty) {
          // Manejo de caso en el que no se seleccionó ningún archivo.
          return;
        }

        List<ImageDataDTO>? temporaryFiles = images
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
          this.processImages(temporaryFiles);
        });
        
      }
      // Resto del código para comprimir y establecer la imagen.
    } on PlatformException catch (e) {
      print('Error al seleccionar la imagen: $e');
    } catch (error) {
      print('Error inesperado: $error');
    }
  }

  void processImageSingular(ImageDataDTO temporaryFileToUpload) async {
    final oldPhotosLength = photos.length;
    if (temporaryFileToUpload != null) {
      final token = Provider.of<UserProvider>(context, listen: false).getToken;
      final imagesViewModel =
          Provider.of<ImagesViewModel>(context, listen: false);
      
      try {
        final response = await imagesViewModel.uploadImage(
              token!, widget.idTask!, temporaryFileToUpload.path);
          
      } catch (error) {
        print(error);
        throw Exception('Error al subir imagen');
      }finally{
      }
      setState(() {
        updateImageViewStateWithDelay(context, 2);
        if(photos.length != oldPhotosLength + 1){
          updateImageViewStateWithDelay(context, 2);
        }
      });
    }
    
  }

  void processImages(List<ImageDataDTO> temporaryFilesToUpload) async {
    final oldPhotosLength = photos.length;
    if (temporaryFilesToUpload != null) {
      final token = Provider.of<UserProvider>(context, listen: false).getToken;
      final imagesViewModel =
          Provider.of<ImagesViewModel>(context, listen: false);
      
      temporaryFilesToUpload.forEach((image) async {
        try {
          final response = await imagesViewModel.uploadImage(
              token!, widget.idTask!, image.path);
          
        } catch (error) {
          print(error);
          throw Exception('Error al subir imagen');
        }finally{
          
        }
      });
      setState(() {
        updateImageViewStateWithDelay(context, temporaryFilesToUpload.length+1);
        if(photos.length != oldPhotosLength + temporaryFilesToUpload.length){
          updateImageViewStateWithDelay(context, 2);
        }
      });
      /*final tempFilesPaths = temporaryFilesToUpload.map((image) => {image.path}).toList(); 
      try {
          final response = await imagesViewModel.uploadImages(
              token!, widget.idTask!, tempFilesPaths.cast<String>());
          
      } catch (error) {
        print(error);
        throw Exception('Error al subir imagen');
      }finally{
        setState(() {
          updateImageViewState(context);
        });
      }*/
    }
    
  }

  void _deleteSelectedImages(List<Photo> photos) {
    final selectedImages = photos.where((photo) => photo.isSelected).toList();
    if (selectedImages.isNotEmpty) {
      final token = Provider.of<UserProvider>(context, listen: false).getToken;
      final imagesViewModel =
          Provider.of<ImagesViewModel>(context, listen: false);

      photos.forEach((photo) async {
        if (photo.isSelected) {
          bool deleteImage = await imagesViewModel.deleteImage(
              token!, this.idTask!, photo.url);
          if (!deleteImage) {
            photo.isSelected = false;
          }
        }
      });
      setState(() {
        photos.removeWhere((photo) => photo.isSelected);
      });
    }
  }
}

class Photo {
  String url;
  bool isSelected;

  Photo({required this.url, this.isSelected = false});
}

class PhotoViewPage extends StatelessWidget {
  final List<Photo> photos;
  final int index;

  const PhotoViewPage({
    Key? key,
    required this.photos,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: PhotoViewGallery.builder(
        itemCount: photos.length,
        builder: (context, index) => PhotoViewGalleryPageOptions.customChild(
          child: CachedNetworkImage(
            imageUrl: photos[index].url,
            placeholder: (context, url) => Container(
              color: softGrey,
            ),
            errorWidget: (context, url, error) => Container(
              color: Colors.red.shade400,
            ),
          ),
          minScale: PhotoViewComputedScale.covered,
          heroAttributes: PhotoViewHeroAttributes(tag: photos[index]),
        ),
        pageController: PageController(initialPage: index),
        enableRotation: true,
      ),
    );
  }
}

class CustomImageProvider extends EasyImageProvider {
  @override
  final int initialIndex;
  final List<String> imageUrls;

  CustomImageProvider({required this.imageUrls, this.initialIndex = 0})
      : super();

  @override
  ImageProvider<Object> imageBuilder(BuildContext context, int index) {
    return NetworkImage(imageUrls[index]);
  }

  @override
  int get imageCount => imageUrls.length;
}

Future<List<String>> _fetchTaskImages(BuildContext context, int idTask) async {
  final token = Provider.of<UserProvider>(context, listen: false).getToken;
  final imagesViewModel = Provider.of<ImagesViewModel>(context, listen: false);
  try {
    return await imagesViewModel.fetchTaskImages(token!, idTask);
  } catch (error) {
    print(error);
    throw Exception('Error al obtener los datos');
  }
}
