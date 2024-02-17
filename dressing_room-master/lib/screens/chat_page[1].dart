import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:gap/gap.dart';
import 'package:dressing_room/utils/colors.dart';
import 'package:dressing_room/resources/comn[1].dart';

class ChatMessage {
  List<Widget> messageContent;
  String messageType;
  ChatMessage({required this.messageContent, required this.messageType});
}

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  String _text = '';
  TextEditingController _textController = TextEditingController();

  List<File> imageFiles = [];
  List<ChatMessage> messages = [];
  final ScrollController _scrollController = ScrollController();

  void _addMessage(ChatMessage message) {
    setState(() {
      messages.add(message);
      _scrollController.position.maxScrollExtent;
    });
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
  }

  IconData iconeCoringa = Icons.chat;
  Function()? funcBtCoringa;

  Future<void> _pickImages() async {
    List<XFile>? pickedImages = await ImagePicker().pickMultiImage();
    // ignore: unnecessary_null_comparison
    if (pickedImages != null) {
      setState(() {
        imageFiles =
            pickedImages.map((XFile image) => File(image.path)).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_ios,
            color: AppTheme.vinho,
          ),
        ),
        title: Text(
          'I.A.R.A',
          style: AppTheme.subheadlinevinho.copyWith(
            shadows: [
              Shadow(
                blurRadius: 2.0,
                color: Colors.black, // Shadow color
                // Shadow's X and Y offset
              ),
            ],
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(
              CupertinoIcons.list_bullet,
              color: AppTheme.vinho,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              shrinkWrap: true,
              itemCount: messages.length,
              padding: EdgeInsets.only(top: 10, bottom: 10),
              physics: BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                return Container(
                  padding:
                      EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
                  child: Align(
                    alignment: (messages[index].messageType == "receiver"
                        ? Alignment.topLeft
                        : Alignment.topRight),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40),
                        color: (messages[index].messageType == "receiver"
                            ? AppTheme.vinho
                            : Colors.grey),
                      ),
                      padding: EdgeInsets.all(10),
                      child: Column(
                        children: messages[index].messageContent,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                Visibility(
                  visible: imageFiles.isNotEmpty,
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: imageFiles.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Padding(
                          padding: EdgeInsets.all(2.0),
                          child: Dismissible(
                              key: Key(imageFiles[index].path),
                              direction: DismissDirection.up,
                              onDismissed: (direction) {
                                setState(() {
                                  imageFiles.removeAt(index);
                                });
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.file(
                                  imageFiles[index],
                                  fit: BoxFit.fill,
                                ),
                              )),
                        );
                      },
                    ),
                  ),
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final pickedFiles =
                            await ImagePicker().pickMultiImage();

                        if (pickedFiles != null) {
                          iconeCoringa = Icons.send;
                          setState(() {
                            imageFiles = pickedFiles
                                .map((file) => File(file.path))
                                .toList();
                            funcBtCoringa = enviarTextoImagem;
                          });
                        } else {
                          setState(() {
                            funcBtCoringa = enviarTexto;
                          });
                        }
                      },
                      child: Container(
                        height: 25,
                        width: 25,
                        decoration: BoxDecoration(
                          color: AppTheme.vinho,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          Icons.photo,
                          color: AppTheme.nearlyWhite,
                          size: 15,
                        ),
                      ),
                    ),
                    Gap(16),
                    Expanded(
                      child: TextField(
                        style: AppTheme.caption,
                        controller: _textController,
                        decoration: InputDecoration(
                            hintText: 'Digite sua mensagem',
                            hintStyle: AppTheme.subtitle),
                        onChanged: (value) {
                          setState(() {
                            _text = value;
                          });
                        },
                      ),
                    ),
                    Gap(16),
                    Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.vinho,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: FloatingActionButton(
                        backgroundColor: AppTheme.vinho,
                        onPressed: funcBtCoringa,
                        child: Icon(
                          iconeCoringa,
                          color: AppTheme.nearlyWhite,
                          size: 20,
                        ),
                      ),
                    ),
                    PopupMenuButton(
                      iconColor: AppTheme.nearlyBlack,
                      itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                        PopupMenuItem(
                          child: ElevatedButton(
                            child: Text(
                              'Enviar texto',
                              style: AppTheme.subheadlinewhite,
                            ),
                            onPressed: () {
                              iconeCoringa = Icons.message;
                              setState(() {
                                funcBtCoringa = enviarTexto;
                              });
                            },
                          ),
                        ),
                        PopupMenuItem(
                          child: ElevatedButton(
                            child: Text(
                              'Enviar texto e imagens',
                              style: AppTheme.subheadlinewhite,
                            ),
                            onPressed: () {
                              iconeCoringa = Icons.send;
                              setState(() {
                                funcBtCoringa = enviarTextoImagem;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _addText() {
    if (_text.isNotEmpty) {
      Text textWidget = Text(_text);
      Container containerWidget = Container(
        padding: EdgeInsets.only(left: 2, right: 2, top: 2, bottom: 2),
        child: textWidget,
      );

      setState(() {
        _addMessage(ChatMessage(
            messageContent: [containerWidget], messageType: "sender"));
      });
      _textController.clear();
    }
  }

  void _addQuestion(String texto) {
    Row buttonWidget = Row(
      children: [
        ElevatedButton(
          child: Text('Sim', style: AppTheme.titlewhite),
          onPressed: () {
            msg('Obrigado pela confirmação!');
          },
        ),
        Gap(10),
        ElevatedButton(
          child: Text('Não', style: AppTheme.titlewhite),
          onPressed: () {
            msg('Desculpe pelo erro.');
          },
        ),
      ],
    );
    Column coluna = Column(
      children: [
        Align(
          alignment: Alignment.bottomLeft,
          child: Text('Identificado:\n$texto\nEstá correto?'),
        ),
        buttonWidget,
      ],
    );
    Container conteiner = Container(
      padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
      child: coluna,
    );

    setState(() {
      _addMessage(
          ChatMessage(messageContent: [conteiner], messageType: "receiver"));
    });
  }

  void msg(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texto),
      ),
    );
  }

  Future<void> enviarTexto() async {
    _addText();
    // String statusSever = await checkServidorLocal();
    String statusSever = 'Server online';

    if (statusSever == 'Server online') {
      // String jsonresposta = resposta; //.replaceAll("\\", "");
      Map<String, dynamic> resultados =
          json.decode(await sendText('mensagem', _text));
      String formattedResultados = '';
      resultados.forEach((key, value) {
        formattedResultados += '$key: $value\n';
      });

      _addQuestion(formattedResultados);
    } else {
      msg(statusSever);
    }
  }

  Future<void> enviarTextoImagem() async {
    if (await sendTextAndImages('armazenamento', _text, imageFiles) ==
        'Sucesso!') {
      imageFiles.clear();
      funcBtCoringa = enviarTexto;
      iconeCoringa = Icons.message;
      msg('Sucesso!');
      _addText();
      _addQuestion('Feito!');
    }
  }
}
