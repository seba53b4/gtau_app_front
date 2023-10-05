import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gallery_image_viewer/gallery_image_viewer.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';
import '../viewmodels/task_list_viewmodel.dart';

class ImageGalleryModal extends StatefulWidget {
  final int? idTask;

  const ImageGalleryModal({super.key, this.idTask});

  @override
  State<ImageGalleryModal> createState() => _ImageGalleryModalState(idTask);
}

class _ImageGalleryModalState extends State<ImageGalleryModal> {
  int? idTask;

  _ImageGalleryModalState(this.idTask);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        List<String> _urls = await _fetchTaskImages(context, widget.idTask!);
        _showGalleryModal(context, _urls);
      },
      child: const Text("Imágenes"),
    );
  }

  void _showGalleryModal(BuildContext context, List<String> photos) {
    showGeneralDialog(
        context: context,
        barrierDismissible: false,
        barrierLabel: "Map Modal",
        transitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (_, __, ___) {
          return Scaffold(
            appBar: AppBar(title: const Text("Gallery")),
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
                  child: InkWell(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            PhotoViewPage(photos: photos, index: index),
                      ),
                    ),
                    child: Hero(
                      tag: photos[index],
                      child: CachedNetworkImage(
                        imageUrl: photos[index],
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            Container(color: Colors.grey),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.red.shade400,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          );
        });
  }
}

class PhotoViewPage extends StatelessWidget {
  final List<String> photos;
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
            imageUrl: photos[index],
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
  final taskListViewModel =
      Provider.of<TaskListViewModel>(context, listen: false);
  try {
    return await taskListViewModel.fetchTaskImages(token!, idTask);
  } catch (error) {
    print(error);
    throw Exception('Error al obtener los datos');
  }
}
