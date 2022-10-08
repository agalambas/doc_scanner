import 'package:doc_scanner/src/features/documents/domain/document.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfx/pdfx.dart';

class DocumentCard extends ConsumerWidget {
  final Document document;
  final VoidCallback? onPressed;
  const DocumentCard(this.document, {Key? key, this.onPressed})
      : super(key: key);

  ThumbnailConfig getConfig(BuildContext context) {
    final imageWidth = MediaQuery.of(context).size.width / 3;
    return ThumbnailConfig(document, imageWidth);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final thumbnailValue = ref.watch(thumbnailProvider(getConfig(context)));
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.hardEdge,
      child: Material(
        child: InkWell(
          onTapDown: (_) {},
          onTap: onPressed,
          child: thumbnailValue.whenOrNull(
            loading: () => Container(color: Colors.black12)
                .animate(onPlay: (controller) => controller.repeat())
                .shimmer(duration: 1.seconds),
            data: (bytes) => Column(
              children: [
                Expanded(
                  child: Ink.image(
                    image: MemoryImage(bytes),
                    fit: BoxFit.cover,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Text(
                    document.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .labelMedium!
                        .copyWith(color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ThumbnailConfig with EquatableMixin {
  final Document document;
  final double width;
  ThumbnailConfig(this.document, this.width);

  @override
  List<Object?> get props => [document];
}

final thumbnailProvider = FutureProvider.family<Uint8List, ThumbnailConfig>(
  (ref, config) async {
    final pdf = await PdfDocument.openFile(config.document.path);
    final page = await pdf.getPage(1);
    final image = await page.render(
      width: config.width,
      height: config.width * page.height / page.width,
      // backgroundColor: '#000033',
    );
    return image!.bytes;
  },
);
