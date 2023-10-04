import 'package:flutter/material.dart';
import 'package:gallery_image_viewer/gallery_image_viewer.dart';
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
        List<ImageProvider> _imageProviders =
            _urls.map((url) => Image.network(url).image).toList();
        _showGalleryModal(context, _imageProviders);
      },
      child: const Text("Imágenes"),
    );
  }

  void _showGalleryModal(
      BuildContext context, List<ImageProvider> _imageProviders) {
    showGeneralDialog(
        context: context,
        barrierDismissible: false,
        barrierLabel: "Map Modal",
        transitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (_, __, ___) {
          return Scaffold(
            appBar: AppBar(
              title: Text("Imágenes"),
            ),
            body: SingleChildScrollView(
              child: Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GalleryImageView(
                    listImage: _imageProviders,
                    width: 200,
                    height: 200,
                    imageDecoration:
                        BoxDecoration(border: Border.all(color: Colors.white)),
                    galleryType: 1,
                  )
                ],
              )),
            ),
          );
        });
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
