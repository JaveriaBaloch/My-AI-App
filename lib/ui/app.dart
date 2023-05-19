import 'package:google_cloud_translation/google_cloud_translation.dart';
import 'package:text_to_speech/text_to_speech.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';

class App extends StatefulWidget{
  const App({super.key});

  @override
  State<App> createState() => _App();
}
class _App extends State<App>{
  late Translation _translation;
  TranslationModel _translated = TranslationModel(translatedText: '', detectedSourceLanguage: '');
  TextEditingController textEditingController = TextEditingController();
  late TextToSpeech tts;
  List images =[];
  var results = "results";
  var gt = "AIzaSyCqBc9_jJ8O_QL5d2M-64D971jUrQet1RY";

  @override
  void initState(){
    super.initState();
    tts = TextToSpeech();
    _translation = Translation(
      apiKey: gt,
    );
    super.initState();
  }

  ChatUser user = ChatUser(
    id: '1',
    firstName: 'Charles',
    lastName: 'Leclerc',
  );
  ChatUser openGTP = ChatUser(
    id: '2',
    firstName: 'Chat',
    lastName: 'GTP',
  );
  List<ChatMessage> messages = <ChatMessage>[];

  @override
  Widget build(BuildContext context){
    const token = "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";
    return Scaffold(
      appBar: AppBar(
       title: const Text("My AI App"),
       centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 5),
           child:IconButton(
            icon: const Icon(Icons.record_voice_over),
             onPressed: (){
                tts.speak(messages[0].text);
             },
           ),
        )
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/img.png",),fit: BoxFit.cover
          )
        ),
      child: Center(
        child: Padding(
      padding: const EdgeInsets.only(top: 10,bottom: 20,left: 20, right: 20),
      child: Center(
          child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(child:  DashChat(
              currentUser: user,
              onSend: (ChatMessage m) {
                setState(() {
                  messages.insert(0, m);
                });
              },
              messages: messages,readOnly:true,
            ),),
             // imagesLoad(),
            Align(
              alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 5,bottom: 5, left: 10),
                      child:
                    Column(
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width*0.9,
                            child: TextField(
                              decoration: InputDecoration(

                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(50),
                                ),
                                filled: true,
                                hintStyle: TextStyle(color: Colors.grey[800]),
                                hintText: "Enter your question here...",
                                fillColor: Colors.white,
                              ),
                              controller:textEditingController,
                              // controller: controller,
                            )
                        ),
                        const SizedBox(height: 20,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: ()async{
                                final openAI = OpenAI.instance.build(token: token,baseOption: HttpSetup(receiveTimeout: const Duration(seconds: 360)),enableLog: true);
                                final request = CompleteText(prompt:textEditingController.text, model: Model.textDavinci3, maxTokens: 4000);
                                final response = await openAI.onCompletion(request:request);
                                var msg = ChatMessage(
                                  text: textEditingController.text,
                                  user: user,
                                  createdAt: DateTime.now(),
                                );
                                messages.insert(0,msg);
                                setState((){
                                  results = response?.choices.first.text.trim() ?? "not reply found";
                                  var msg2 = ChatMessage(
                                    text: results,
                                    user: openGTP,
                                    createdAt: DateTime.now(),
                                  );
                                  messages.insert(0, msg2);
                                });
                                textEditingController.clear();
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  shape: const CircleBorder(),
                                  padding: const EdgeInsets.all(12)
                              ),
                              child: const Icon(Icons.search, color: Colors.white,size: 30,),
                            ),
                            ElevatedButton(
                              onPressed: ()async{
                                var msg = ChatMessage(
                                  text: textEditingController.text,
                                  user: user,
                                  createdAt: DateTime.now(),
                                );
                                messages.insert(0,msg);
                                _translated = await _translation.translate(text: textEditingController.text, to: 'ur');
                                setState((){
                                  var msg2 = ChatMessage(
                                      text: _translated.translatedText,
                                      user: openGTP,
                                      createdAt: DateTime.now(),
                                  );
                                  messages.insert(0, msg2);
                                });
                                textEditingController.clear();
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  shape: const CircleBorder(),
                                  padding: const EdgeInsets.all(12)
                              ),
                              child: const Icon(Icons.translate, color: Colors.white,size: 30,),
                            ),
                            ElevatedButton(
                              onPressed: ()async{
                                var msg = ChatMessage(
                                  text: textEditingController.text,
                                  user: user,
                                  createdAt: DateTime.now(),
                                );
                                messages.insert(0,msg);
                                final openAI = OpenAI.instance.build(token: token, baseOption: HttpSetup(receiveTimeout: const Duration(seconds: 1660)),enableLog: true);
                                final request = GenerateImage(textEditingController.text, 3,size: ImageSize.size256,
                                    responseFormat: Format.url);
                                final response = await openAI.generateImage(request);

                                setState((){
                                 response?.data?.forEach((element) {
                                   images.add(element?.url);
                                 });
                                 for (var element in images) {
                                   var msg2 = ChatMessage(
                                       text: "Image",
                                       user: openGTP,
                                       createdAt: DateTime.now(),
                                       medias: [ChatMedia(url: element, fileName: "image", type: MediaType.image)]
                                   );
                                   messages.insert(0, msg2);
                                 }

                                  // results = images.toString();
                                });
                                textEditingController.clear();
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  shape: const CircleBorder(),
                                  padding: const EdgeInsets.all(12)
                              ),
                              child: const Icon(Icons.image, color: Colors.white,size: 30,),
                            ),

                          ],
                        ),

                      ],
                      )
                  )
        )
      ]
      ),
    )
    )
    )
    )
    );
  }

}