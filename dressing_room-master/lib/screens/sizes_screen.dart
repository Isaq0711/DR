import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';

class TwoDimensionalScrollableDemo extends StatelessWidget {
  TwoDimensionalScrollableDemo({super.key});

  List<Map<String, int>> imagePositions = [
    {'row': 4, 'col': 4},
    {'row': 6, 'col': 4},
    // Adicione mais posições conforme necessário
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Table view Demo"),
      ),
      body: TableView.builder(
        columnCount: 20, // Ajuste conforme necessário
        rowCount: 10, // Ajuste conforme necessário
        columnBuilder: buildColumnSpan,
        rowBuilder: buildTableSpan,
        diagonalDragBehavior: DiagonalDragBehavior.none,
        cellBuilder: (BuildContext context, TableVicinity vicinity) {
          return Center(child: addText(vicinity, context));
        },
      ),
    );
  }

  TableSpan buildColumnSpan(int index) {
    TableSpanDecoration decoration = const TableSpanDecoration(
        border: TableSpanBorder(
            trailing: BorderSide(color: Colors.black),
            leading: BorderSide(color: Colors.black)));
    return TableSpan(
      extent: imagePositions.any((position) =>
              (index == position['col'] && index == position['row']))
          ? const FixedTableSpanExtent(350)
          : const FixedTableSpanExtent(50),
      backgroundDecoration: decoration,
    );
  }

  TableSpan buildTableSpan(int index) {
    TableSpanDecoration foreGroundDecoration = const TableSpanDecoration(
        border: TableSpanBorder(
            trailing: BorderSide(color: Colors.black),
            leading: BorderSide(color: Colors.black)));
    TableSpanDecoration backGroundDecoration = TableSpanDecoration(
      color: index == 0 ? Colors.grey[300] : null,
    );
    return TableSpan(
      extent: const FixedTableSpanExtent(100),
      backgroundDecoration: backGroundDecoration,
      foregroundDecoration: foreGroundDecoration,
      recognizerFactories: <Type, GestureRecognizerFactory>{
        TapGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
                () => TapGestureRecognizer(), (TapGestureRecognizer t) {
          t.onTap = () {
            print("Tapping on Row $index");
          };
        })
      },
      onEnter: (PointerEnterEvent event) {
        print("Row OnEnter: $index ${event.localPosition} ");
      },
      onExit: (PointerExitEvent event) {
        print("Row OnExit: $index ${event.localPosition} ");
      },
    );
  }

  Widget addText(TableVicinity vicinity, BuildContext context) {
    double emptySpaceSize = 5.0;

    // Verifica se a célula atual está próxima a alguma célula de imagem
    bool isNearImage = imagePositions.any((position) =>
        (vicinity.yIndex >= position['row']! - 1 &&
            vicinity.yIndex <= position['row']! + 1) &&
        (vicinity.xIndex >= position['col']! - 1 &&
            vicinity.xIndex <= position['col']! + 1));

    // Verifica se a célula atual é uma célula de imagem
    bool isImageCell = imagePositions.any((position) =>
        (vicinity.yIndex == position['row'] &&
            vicinity.xIndex == position['col']));

    // Ajusta o tamanho das células com imagem para ocupar mais espaço
    double cellSize = isImageCell ? 150.0 : 100.0;

    return Container(
      width: cellSize,
      height: cellSize,
      color: isImageCell ? Colors.lightBlue : null,
      child: isImageCell
          ? Center(
              child: Image.network(
                'https://example.com/your_image_url.jpg',
                fit: BoxFit.cover,
              ),
            )
          : isNearImage
              ? Container(
                  width: emptySpaceSize,
                  height: emptySpaceSize,
                )
              : Text(""),
    );
  }
}
