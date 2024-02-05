import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gtau_app_front/constants/theme_constants.dart';
import 'package:gtau_app_front/dto/image_data.dart';
import 'package:gtau_app_front/models/enums/element_type.dart';
import 'package:gtau_app_front/widgets/common/customDialog.dart';
import 'package:gtau_app_front/widgets/common/customMessageDialog.dart';
import 'package:gtau_app_front/widgets/loading_overlay.dart';
import 'package:gtau_app_front/widgets/photo.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';
import '../viewmodels/images_viewmodel.dart';
import 'common/custom_elevated_button.dart';

class ScheduledImageGalleryModal extends StatefulWidget {
  final int scheduledId;
  final int elementId;
  final ElementType elementType;

  const ScheduledImageGalleryModal({super.key,
    required this.scheduledId,
    required this.elementId,
    required this.elementType});

  @override
  State<ScheduledImageGalleryModal> createState() =>
      _ScheduledImageGalleryModalState(scheduledId, elementId, elementType, []);
}

class _ScheduledImageGalleryModalState
    extends State<ScheduledImageGalleryModal> {
  final int scheduledId;
  final int elementId;
  final ElementType elementType;
  List<Photo> photos;

  _ScheduledImageGalleryModalState(this.scheduledId, this.elementId,
      this.elementType, this.photos);

  @override
  Widget build(BuildContext context) {
    return CustomElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  _ScheduledGelleryShow(
                      scheduledId, elementId, elementType, photos)),
        );
      },
      text: AppLocalizations.of(context)!.see_images,
    );
  }
}

class _ScheduledGelleryShow extends StatefulWidget {
  final int scheduledId;
  final int elementId;
  final ElementType elementType;
  List<Photo> photos;

  _ScheduledGelleryShow(this.scheduledId, this.elementId, this.elementType,
      this.photos);

  @override
  State<StatefulWidget> createState() =>
      _ScheduledGelleryShowState(
          scheduledId, elementId, elementType, this.photos);
}

class _ScheduledGelleryShowState extends State<_ScheduledGelleryShow> {
  final int scheduledId;
  final int elementId;
  final ElementType elementType;
  List<Photo> photos;

  _ScheduledGelleryShowState(this.scheduledId, this.elementId, this.elementType,
      this.photos);

  final ImagePicker _picker = ImagePicker();
  ImagesViewModel? imagesViewModel;
  late String token;

  @override
  void initState() {
    super.initState();
    token = Provider
        .of<UserProvider>(context, listen: false)
        .getToken!;
    imagesViewModel = Provider.of<ImagesViewModel>(context, listen: false);
    _getImagesData();
  }

  //
  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  // }

  @override
  void dispose() {
    imagesViewModel?.reset();
    super.dispose();
  }

  void _getImagesData() async {
    List<String>? urls = await _fetchTaskImages();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ImagesViewModel>(
        builder: (context, imagesViewModel, child) {
          photos = imagesViewModel.photos;

          if (photos.isEmpty) {
            return LoadingOverlay(
                isLoading: imagesViewModel.isLoading,
                child: Scaffold(
                    appBar: AppBar(
                      title: Text(AppLocalizations.of(context)!.images_title),
                      centerTitle: true,
                    ),
                    body: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Center(
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 25, horizontal: 15),
                                    child: SvgPicture.asset(
                                        'lib/assets/empty_gallery.svg',
                                        width: 128,
                                        height: 128,
                                        semanticsLabel: 'Empty Gallery'),
                                  ),
                                  Text(
                                      AppLocalizations.of(context)!
                                          .empty_image_gallery,
                                      style: TextStyle(
                                          color: Colors.black.withOpacity(0.6),
                                          fontSize: 20)),
                                ]))),
                    floatingActionButtonLocation:
                    FloatingActionButtonLocation.centerFloat,
                    floatingActionButton: FloatingActionButton(
                      onPressed: () {
                        _selectPhoto();
                      },
                      foregroundColor: null,
                      backgroundColor: null,
                      shape: null,
                      child: const Icon(Icons.add),
                    )));
          } else {
            return LoadingOverlay(
                isLoading: imagesViewModel.isLoading,
                child: Scaffold(
                  appBar: AppBar(
                      title: Text(AppLocalizations.of(context)!.images_title),
                      centerTitle: true),
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
                          onTap: () =>
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      PhotoViewPage(
                                          photos: photos, index: index),
                                ),
                              ),
                          onLongPress: () {
                            setState(() {
                              photos[index].isSelected =
                              !photos[index].isSelected;
                            });
                          },
                          onDoubleTap: () {
                            setState(() {
                              photos[index].isSelected =
                              !photos[index].isSelected;
                            });
                          },
                          child: Hero(
                            tag: photos[index],
                            child: CachedNetworkImage(
                              color: Colors.black
                                  .withOpacity(
                                  photos[index].isSelected ? 1 : 0),
                              colorBlendMode: BlendMode.color,
                              imageUrl: photos[index].url,
                              fit: BoxFit.cover,
                              placeholder: (context, url) =>
                                  Container(color: softGrey),
                              errorWidget: (context, url, error) =>
                                  Container(
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
                  floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerFloat,
                  floatingActionButton: FloatingActionButton(
                    onPressed: () {
                      _selectPhoto();
                    },
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
                        label:
                        AppLocalizations.of(context)!.deleteButtonLabel,
                      ),
                    ],
                    onTap: (index) {
                      if (index == 0) {
                        setState(() {
                          photos.forEach(
                                  (element) => element.isSelected = false);
                          this.photos = photos;
                        });
                      } else if (index == 1) {
                        _showDeleteConfirmationDialog(context);
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

  Future<void> _showDeleteConfirmationDialog(BuildContext context) async {
    final showDialogContext = context;

    await showCustomDialog(
      context: showDialogContext,
      title: AppLocalizations.of(showDialogContext)!.dialogWarning,
      content:
      AppLocalizations.of(showDialogContext)!.dialogContent_deleteImage,
      onDisablePressed: () {
        Navigator.of(showDialogContext).pop();
      },
      onEnablePressed: () async {
        Navigator.of(showDialogContext).pop();
        bool result = await _deleteSelectedImages(photos);

        if (result == true) {
          /*print('Imagen ha sido eliminada correctamente');*/
          await showCustomMessageDialog(
            context: showDialogContext,
            messageType: DialogMessageType.success,
            onAcceptPressed: () {},
          );
        } else {
          /*print('No se pudo eliminar la imagen');*/
          await showCustomMessageDialog(
            context: showDialogContext,
            messageType: DialogMessageType.error,
            onAcceptPressed: () {},
          );
        }
      },
      acceptButtonLabel: AppLocalizations.of(context)!.dialogAcceptButton,
      cancelbuttonLabel: AppLocalizations.of(context)!.dialogCancelButton,
    );
  }

  void _selectPhoto() async {
    if (kIsWeb) {
      await _pickImage(ImageSource.gallery);
    } else {
      await showModalBottomSheet(
          context: context,
          builder: (context) =>
              BottomSheet(
                builder: (context) =>
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                            leading: const Icon(Icons.camera),
                            title: Text(
                                AppLocalizations.of(context)!.from_camera),
                            onTap: () async {
                              Navigator.of(context).pop();
                              await _pickImage(ImageSource.camera);
                            }),
                        ListTile(
                            leading: const Icon(Icons.filter),
                            title: Text(
                                AppLocalizations.of(context)!.pick_a_file),
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

  // Future updateImageViewState() async {
  //   await imagesViewModel!.fetchImagesScheduledElement(
  //       token, widget.scheduledId, widget.elementId, widget.elementType);
  // }

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
        processImageSingular(imageDataDTO);
      } else {
        final List<XFile> images =
        await _picker.pickMultiImage(imageQuality: 50);
        if (images.isEmpty) {
          // Manejo de caso en el que no se seleccionó ningún archivo.
          return;
        }

        List<ImageDataDTO>? temporaryFiles = images
            .map((val) =>
        kIsWeb
            ? ImageDataDTO(
            image: Image.network(val.path),
            path: val.path,
            fromBlob: false)
            : ImageDataDTO(
            image: Image.file(File(val.path)),
            path: val.path,
            fromBlob: false))
            .toList();
        processImages(temporaryFiles);
      }
      // Resto del código para comprimir y establecer la imagen.
    } on PlatformException catch (e) {
      print('Error al seleccionar la imagen: $e');
    } catch (error) {
      print('Error inesperado: $error');
    }
  }

  void processImageSingular(ImageDataDTO temporaryFileToUpload) async {
    if (temporaryFileToUpload != null) {
      try {
        final response = await imagesViewModel?.scheduledUploadImage(
            token,
            widget.scheduledId,
            widget.elementId,
            temporaryFileToUpload.path,
            widget.elementType);
        setState(() {

        });
        _getImagesData();
      } catch (error) {
        print(error);
        throw Exception('Error al subir imagen');
      }
    }
    ;
  }

  void processImages(List<ImageDataDTO> temporaryFilesToUpload) async {
    final oldPhotosLength = photos.length;
    if (temporaryFilesToUpload != null) {
      List<String> list = [];
      final tempFilesPaths =
      temporaryFilesToUpload.map((image) => list.add(image.path)).toList();
      try {
        final response = {};
        await imagesViewModel?.scheduledUploadImages(
            token, widget.scheduledId, widget.elementId, list, elementType);
        setState(() {

        });
        _getImagesData();
      } catch (error) {
        print(error);
        throw Exception('Error al subir imagen');
      }
    }
  }

  Future<bool> _deleteSelectedImages(List<Photo> photos) async {
    bool isLoadingDelete;
    bool deleteImage = true;
    final selectedImages = photos.where((photo) => photo.isSelected).toList();
    if (selectedImages.isNotEmpty) {
      final len = photos.length;
      int cont = 0;
      isLoadingDelete = true;
      for (var photo in photos) {
        cont++;
        if (photo.isSelected) {
          deleteImage = await imagesViewModel?.deleteImageScheduled(
              token, widget.scheduledId, photo.url) ??
              deleteImage;
          /*if (deleteImage == false) {
            photo.isSelected = false;
          }*/
        }
        /*if(cont == len){
          return deleteImage;
        }*/
      }
      isLoadingDelete = false;
      setState(() {
        photos.removeWhere((photo) => photo.isSelected);
      });
      return deleteImage;
    }
    return false;
  }

  Future<List<String>?> _fetchTaskImages() async {
    try {
      return await imagesViewModel?.fetchImagesScheduledElement(
          token, widget.scheduledId, widget.elementId, widget.elementType);
    } catch (error) {
      print(error);
      throw Exception('Error al obtener los datos');
    }
  }
}
