import 'dart:ffi';
import 'dart:math';

import 'package:NeoDim_Skyrim_on_Words/utils/find_image.dart';
import 'package:NeoDim_Skyrim_on_Words/utils/prompt.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import 'models/story_data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  windowManager.setTitle('Скайрим на Словах');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Skyrim Themed App',
      theme: ThemeData(
        primaryColor: Color(0xFF1B1B1B),
        // Основной цвет (темный)
        hintColor: Color(0xFFD4AF37),
        // Фон (темный серый)
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.white), // Белый текст
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFFD4AF37))
            .copyWith(background: Color(0xFF2E2E2E)),
      ),
      home: SkyrimApp(),
    );
  }
}

Future<String> getPackageInfo() async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  String version = "${packageInfo.version}+${packageInfo.buildNumber}";
  return version;
}

class SkyrimApp extends StatefulWidget {
  bool isFirstTime = true;
  @override
  State<SkyrimApp> createState() => SkyrimAppState();
}

class SkyrimAppState extends State<SkyrimApp> {
  String prompt = promptNew;
  StoryData prevStoryData = StoryData(image: "", text: "", button: []);
  final String imageUrl =
      'https://www.google.com/search?q=skyrim+cart+ride&tbm=isch';
  final List<String> buttonLabels = ['Button 1', 'Button 2', 'Button 3'];
  String imageText = 'Подпись под картинкой';

  @override
  Widget build(BuildContext context) {
    TextEditingController controller = TextEditingController();

    void updatePrevPrompt(StoryData prevStoryData) {
      this.prevStoryData = prevStoryData;
    }

    StoryData getPrevStoryData() {
      return prevStoryData;
    }

    void updatePrompt(String addition) {
      prompt = "$prompt\n$addition";
    }

    void updateAll() {
      setState(() {});
    }

    return Scaffold(
      backgroundColor: Color(0xFF2E2E2E),
      body: FutureBuilder<StoryData>(
          future: generateStoryData(
              prompt, updatePrompt, getPrevStoryData, updatePrevPrompt),
          builder: (BuildContext context, AsyncSnapshot<StoryData> snapshot) {
            if (snapshot.hasData &&
                snapshot.connectionState == ConnectionState.done) {
              StoryData data = snapshot.data!;
              return Container(
                color: Theme.of(context).colorScheme.surface,
                padding: EdgeInsets.all(16.0),
                child: ListView(
                  shrinkWrap: true,
                  padding: EdgeInsets.all(15.0),
                  // crossAxisAlignment: CrossAxisAlignment.stretch,
                  // mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    FutureBuilder<String>(
                        future: fetchImageUrl(data.image),
                        builder: (BuildContext context,
                            AsyncSnapshot<String> snapshot) {
                          if (snapshot.hasData) {
                            return Image.network(
                              snapshot.data ?? "",
                              height: 600,
                              fit: BoxFit.fitHeight,
                            );
                          } else {
                            return Center(
                              child: Container(
                                  height: 20,
                                  width: 20,
                                  child: const CircularProgressIndicator(
                                    color: Color(0xFFD4AF37),
                                  )),
                            );
                          }
                        }),
                    SizedBox(height: 8.0),
                    Text(
                      data.text,
                      style: TextStyle(
                          color: Theme.of(context).hintColor, fontSize: 25),
                      textAlign: TextAlign.justify,
                    ),
                    SizedBox(height: 16.0),
                    ...data.button.map((label) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: ElevatedButton(
                            onPressed: () {
                              //prompt = prompt + label;
                              updatePrompt(label);
                              updateAll();
                            },
                            child: Text(
                              label,
                              style: TextStyle(fontSize: 16),
                            ),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.black,
                              backgroundColor: Theme.of(context).hintColor,
                            ),
                          ),
                        )),
                    SizedBox(height: 16.0),
                    TextField(
                      textInputAction: TextInputAction.send,
                      controller: controller,
                      keyboardType: TextInputType.multiline,
                      maxLines: 5,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Color(0xFF545454),
                        hintText: "Свой вариант действий",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      style: TextStyle(color: Color(0xFFD4AF37)),
                      onSubmitted: (value) {
                        updatePrompt(controller.text);
                        updateAll();
                      },
                    ),
                    FutureBuilder<String>(
                        future: getPackageInfo(),
                        builder: (BuildContext context,
                            AsyncSnapshot<String> snapshot) {
                          if (snapshot.hasData) {
                            return Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                "Сделал: NeoDim (крутой) | Версия: ${snapshot.data} ",
                                style: TextStyle(color: Color(0xFFD4AF37)),
                              ),
                            );
                          } else {
                            return Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                "Сделал: NeoDim (крутой) | Версия: 1.0.0",
                                style: TextStyle(color: Color(0xFFD4AF37)),
                              ),
                            );
                          }
                        })
                    // Spacer(),
                    // ElevatedButton(
                    //   onPressed: () {
                    //     updatePrompt(controller.text);
                    //     updateAll();
                    //   },
                    //   child: Padding(
                    //     padding: const EdgeInsets.all(16.0),
                    //     child: Text(
                    //       'Отправить',
                    //       style: TextStyle(fontSize: 18.0),
                    //     ),
                    //   ),
                    //   style: ElevatedButton.styleFrom(
                    //     primary: Theme.of(context).hintColor,
                    //     onPrimary: Colors.black,
                    //     shape: RoundedRectangleBorder(
                    //       borderRadius: BorderRadius.circular(8.0),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              );
            } else {
              return Scaffold(
                  backgroundColor: Colors.black,
                  body: Center(
                    child: Image.network(
                      getRandomLoadingScreen(),
                      fit: BoxFit.fitHeight,
                      scale: 0.1,
                    ),
                  ));
            }
          }),
    );
  }
}

String getRandomLoadingScreen() {
  List<String> screens = [
    "https://anatolykulikov.ru/wp-content/uploads/2023/02/skloader.jpg",
    "https://static.wikia.nocookie.net/elderscrolls/images/8/86/%D0%97%D0%B0%D0%B3%D1%80%D1%83%D0%B7%D0%BA%D0%B0_%D0%A1%D0%BA%D0%B0%D0%B9%D1%80%D0%B8%D0%BC.png/revision/latest/scale-to-width-down/1200?cb=20230627181509&path-prefix=ru",
    "https://anatolykulikov.ru/wp-content/uploads/2023/02/SkyrimLikeLoader-968x504.png",
    "https://ic.pics.livejournal.com/interes2012/25717847/744558/744558_original.jpg",
    "https://cs2.modgames.net/images/93d682949f05801adefe1ff31a36e5153276ffb8de1c421b18beaa24ac1d55be.jpg",
    "https://i.playground.ru/p/9-RjCNUfyPUPZlu7cvhhNg.jpeg",
    "https://gamer-mods.ru/_ld/107/59248795.jpg",
    "https://avatars.dzeninfra.ru/get-zen_doc/3976017/pub_5f3ab4b4c9028454257d12fa_5f3bc57f8157c67d0b3b4fbe/scale_1200",
    "https://ic.pics.livejournal.com/interes2012/25717847/745042/745042_original.jpg",
    "https://imperialcity.ucoz.net/_fr/7/4505888.jpg",
    "https://ic.pics.livejournal.com/interes2012/25717847/744732/744732_original.jpg",
    "https://ic.pics.livejournal.com/interes2012/25717847/745774/745774_original.jpg"
  ];
  var rng = Random();
  return screens[rng.nextInt(screens.length)];
}
