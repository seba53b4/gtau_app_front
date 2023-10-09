import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gallery_image_viewer/gallery_image_viewer.dart';
import 'package:gtau_app_front/widgets/loading_overlay.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';
import '../viewmodels/images_viewmodel.dart';

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
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => _GelleryShow(idTask, photos)),
        );
      },
      child: const Text("Imágenes"),
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeData();
  }

  void _initializeData() async {
    List<String> urls = await _fetchTaskImages(context, widget.idTask!);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ImagesViewModel>(
        builder: (context, imagesViewModel, child) {
      photos = imagesViewModel.photos;

      return LoadingOverlay(
          isLoading: imagesViewModel.isLoading,
          child: Scaffold(
            appBar: AppBar(title: const Text("Imágenes")),
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
                            Container(color: Colors.grey),
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
            bottomNavigationBar: photos.any((photo) => photo.isSelected)
                ? BottomNavigationBar(
                    items: const [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.cleaning_services),
                        label: 'Quitar seleccion',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.delete),
                        label: 'Eliminar',
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
    });
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
              color: Colors.grey,
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
