import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class FormPage extends StatefulWidget {
  const FormPage({super.key});
  static const routeName = '/FormPage';

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  List<dynamic> questions = [];
  Map<String, dynamic> currentSection = {};
  List<Map<String, dynamic>> questionAnswers = [];
  int currentSectionNumber = 1;
  int totalSections = 0;
  final _pageScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  _loadData() async {
    // Load the JSON file from the assets
    String jsonString = await rootBundle.loadString('assets/questions.json');
    // Parse the JSON string
    final jsonData = json.decode(jsonString);

    List<Map<String, dynamic>> qquestionAnswers = [];
    for (var section in jsonData) {
      for (var question in section['questions']) {
        qquestionAnswers.add({
          "section_id": section['sectionid'],
          "section_name": section['name'],
          "question_id": question['number'],
          "question": question['text'],
          "required": question['compulsory'],
          "answer": []
        });
      }
    }
// questionAnswers.

    setState(() {
      currentSection = jsonData[0];
      questions = jsonData;
      questionAnswers = qquestionAnswers;
      totalSections = questions.length;
    });
    print(qquestionAnswers);
  }

  _selectQuestionAnswer(int sectionId, int questionId, String answer) {
    final section = questions.firstWhere((s) => s['sectionid'] == sectionId);
    final question =
        section['questions'].firstWhere((q) => q['number'] == questionId);

    var copyQuestionAnswer = questionAnswers;
    for (var qa in copyQuestionAnswer) {
      if (qa['section_id'] == sectionId && qa['question_id'] == questionId) {
        if (question['singleChoice']) {
          qa['answer'] = [];
        }
        if (!qa['answer'].contains(answer)) {
          qa['answer'].add(answer);
        } else {
          qa['answer'].remove(answer);
        }
      }
    }
    setState(() {
      questionAnswers = copyQuestionAnswer;
    });
  }

  _checkQuestionAnswer(int sectionId, int questionId, String answer) {
    for (var qta in questionAnswers) {
      if (qta['section_id'] == sectionId && qta['question_id'] == questionId) {
        for (var qAnswer in qta['answer']) {
          if (qAnswer == answer) {
            return true;
          }
        }
      }
    }

    return false;
  }

  _previousSection() {
    if (currentSectionNumber <= 1) return;
    var previousSectionIndex = currentSectionNumber - 2;
    setState(() {
      currentSection = questions[previousSectionIndex];
      currentSectionNumber = currentSectionNumber - 1;
    });
    _pageScrollController.jumpTo(0);
  }

  _nextSection() {
    if (currentSectionNumber == questions.length) return;

    for (var question in currentSection['questions']) {
      if (question['compulsory']) {
        for (var qa in questionAnswers) {
          if (qa['section_id'] == currentSection['sectionid'] &&
              qa['question_id'] == question['number'] &&
              qa['answer'].isEmpty) {
            return;
          }
        }
      }
    }

    var nextSectionIndex = currentSectionNumber;

    setState(() {
      currentSection = questions[nextSectionIndex];
      currentSectionNumber = currentSectionNumber + 1;
    });
    _pageScrollController.jumpTo(0);
  }

  //  appBar: AppBar(
  //       automaticallyImplyLeading: false,
  //       title: Text(
  //         currentSection["name"] ?? "",
  //         style: TextStyle(
  //           color: Theme.of(context).primaryColor,
  //           fontWeight: FontWeight.w800,
  //           fontSize: 23,
  //         ),
  //       ),
  //     ),

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _pageScrollController,
        slivers: [
          SliverAppBar(
            expandedHeight: 120.0, // Adjust this value to fit your content
            pinned: true,
            automaticallyImplyLeading: false,
            floating: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Wrap(
                alignment: WrapAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: Text(
                      currentSection["name"] ?? "",
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 23,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  child: Column(
                    children: [
                      ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: currentSection["questions"] != null
                            ? currentSection["questions"].length
                            : 0,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 15),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.grey),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Flexible(
                                      child: RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: currentSection["questions"]
                                                  [index]["text"],
                                              style: const TextStyle(
                                                fontSize: 17,
                                                fontWeight: FontWeight.w600,
                                                color: Colors
                                                    .black, // Adjust color as needed
                                              ),
                                            ),
                                            if (currentSection["questions"]
                                                [index]["compulsory"]) ...[
                                              const TextSpan(text: " "),
                                              const TextSpan(
                                                text: "*",
                                                style: TextStyle(
                                                  color: Colors.red,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                            if (!currentSection["questions"]
                                                [index]["singleChoice"]) ...[
                                              const TextSpan(text: "  "),
                                              const TextSpan(
                                                text: "-- multiple",
                                                style: TextStyle(
                                                  color: Colors.black12,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ]
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                ListView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: currentSection["questions"][index]
                                              ["options"] !=
                                          null
                                      ? currentSection["questions"][index]
                                              ["options"]
                                          .length
                                      : 0,
                                  itemBuilder: (context, i) {
                                    var checked = _checkQuestionAnswer(
                                      currentSection["sectionid"],
                                      currentSection["questions"][index]
                                          ['number'],
                                      currentSection["questions"][index]
                                          ["options"][i]['label'],
                                    );
                                    return Container(
                                      padding: const EdgeInsets.all(2),
                                      margin: const EdgeInsets.only(bottom: 10),
                                      decoration: BoxDecoration(
                                        color: checked
                                            ? Theme.of(context).primaryColor
                                            : const Color.fromRGBO(
                                                241, 240, 242, 1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: InkWell(
                                        onTap: () => _selectQuestionAnswer(
                                          currentSection["sectionid"],
                                          currentSection["questions"][index]
                                              ['number'],
                                          currentSection["questions"][index]
                                              ["options"][i]['label'],
                                        ),
                                        child: Row(
                                          children: [
                                            Checkbox(
                                              activeColor: Theme.of(context)
                                                  .primaryColor,
                                              checkColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                              ),
                                              side: BorderSide(
                                                  color: Colors.blue, width: 2),
                                              value: checked,
                                              onChanged: (value) => {},
                                            ),
                                            Flexible(
                                              child: Text(
                                                currentSection["questions"]
                                                        [index]["options"][i]
                                                    ["label"],
                                                maxLines: 2,
                                                style: TextStyle(
                                                  color: checked
                                                      ? Colors.white
                                                      : const Color.fromRGBO(
                                                          40, 48, 114, 1),
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      Row(
                        children: [
                          if (currentSectionNumber > 1) ...[
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  padding: EdgeInsets.symmetric(vertical: 15),
                                ),
                                onPressed: _previousSection,
                                child: const Text(
                                  "Previous",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                          ],
                          if (currentSectionNumber < questions.length)
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).primaryColor,
                                  padding: EdgeInsets.symmetric(vertical: 15),
                                ),
                                onPressed: _nextSection,
                                child: const Text(
                                  "Next",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          if (currentSectionNumber == questions.length)
                            Expanded(
                              flex: 2,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  padding: EdgeInsets.symmetric(vertical: 15),
                                ),
                                onPressed: () {
                                  print("TRY SUBMITTING");
                                },
                                child: const Text(
                                  "Submit",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      )
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
