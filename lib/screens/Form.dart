import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:surveyapp/component/FullPageLoader.dart';
import 'package:surveyapp/util/api.dart';
import 'package:surveyapp/util/shared_preference_helper.dart';
import 'package:surveyapp/util/util.dart';
import 'package:surveyapp/util/constant.dart' as constant;

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
          "totalScore": 0,
          "answer": []
        });
      }
    }

    setState(() {
      currentSection = jsonData[0];
      questions = jsonData;
      questionAnswers = qquestionAnswers;
      totalSections = questions.length;
    });
  }

  _selectQuestionAnswer(
      int sectionId, int questionId, String answer, int score) {
    final section = questions.firstWhere((s) => s['sectionid'] == sectionId);
    final question =
        section['questions'].firstWhere((q) => q['number'] == questionId);

    var copyQuestionAnswer = questionAnswers;
    var qaIndex = copyQuestionAnswer.indexWhere(
        (q) => q['section_id'] == sectionId && q['question_id'] == questionId);
    if (qaIndex != -1) {
      if (question['openEnded'] != null && question['openEnded']) {
        copyQuestionAnswer[qaIndex]['answer'] = [];
        copyQuestionAnswer[qaIndex]['answer']
            .add({"answer": answer, "score": score});
      } else {
        if (question['singleChoice']) {
          copyQuestionAnswer[qaIndex]['answer'] = [];
        }

        var checkAnswerIndex = copyQuestionAnswer[qaIndex]['answer']
            .indexWhere((a) => a['answer'] == answer);

        if (checkAnswerIndex == -1) {
          copyQuestionAnswer[qaIndex]['answer']
              .add({"answer": answer, "score": score});
        } else {
          copyQuestionAnswer[qaIndex]['answer'].removeAt(checkAnswerIndex);
        }
      }
      num totalScore = 0;
      copyQuestionAnswer[qaIndex]['answer'].forEach((a) {
        totalScore += a['score'];
      });
      copyQuestionAnswer[qaIndex]['totalScore'] = totalScore;
    }

    setState(() {
      questionAnswers = copyQuestionAnswer;
    });
  }

  _checkQuestionAnswer(int sectionId, int questionId, String answer) {
    var qta = questionAnswers.firstWhere(
        (q) => q['section_id'] == sectionId && q['question_id'] == questionId);

    // print(qta);
    var checkAnswerIndex =
        qta['answer'].indexWhere((a) => a['answer'] == answer);

    if (checkAnswerIndex != -1) {
      return true;
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
            showAlert(context, "Please answer all required questions");
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

  showConfirmationDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: const Text(
        "Cancel",
        style: TextStyle(color: Colors.red),
      ),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = ElevatedButton(
      onPressed: () {
        Navigator.of(context).pop();
        submitQuestions();
      },
      style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green, foregroundColor: Colors.white),
      child: const Text("Continue"),
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("Confirm Submission"),
      content:
          const Text("Are you sure you want to submit this questionnaire?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  submitQuestions() async {
    final pref = await SharedPreferencesHelper.getInstance();

    final Map<String, dynamic>? user = pref.getMap(constant.userKey);
    print(user);

    if (user == null) {
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return const FullPageLoader();
      },
    );
    var response =
        await Api.instance.submitQuestions(user['username'], questionAnswers);
    Navigator.of(context).pop();

    if (response != null) {
      var title = "SUCCESS";
      if (!response['status']) {
        title = "ERROR";
      }
      showAlert(context, response['message'], title: title);
      if (response['status']) {
        _pageScrollController.jumpTo(0);
        _loadData();
      }
      return;
    }

    showAlert(context, "Someting went wrong, kindly contact support");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          controller: _pageScrollController,
          slivers: [
            SliverAppBar(
              expandedHeight: 150.0, // Adjust this value to fit your content
              pinned: true,
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
                          fontSize: 20,
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
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      RichText(
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
                                            if (currentSection["questions"]
                                                            [index]
                                                        ["singleChoice"] !=
                                                    null &&
                                                !currentSection["questions"]
                                                        [index]
                                                    ["singleChoice"]) ...[
                                              const TextSpan(text: "  "),
                                              const TextSpan(
                                                text: "-- multiple",
                                                style: TextStyle(
                                                  color: Colors.black26,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ]
                                          ],
                                        ),
                                      ),
                                      // ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  if (currentSection["questions"][index]
                                          ["options"] !=
                                      null)
                                    ListView.builder(
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount: currentSection["questions"]
                                                  [index]["options"] !=
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
                                          margin:
                                              const EdgeInsets.only(bottom: 10),
                                          decoration: BoxDecoration(
                                            color: checked
                                                ? Theme.of(context).primaryColor
                                                : const Color.fromRGBO(
                                                    241, 240, 242, 1),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: InkWell(
                                            onTap: () => _selectQuestionAnswer(
                                              currentSection["sectionid"],
                                              currentSection["questions"][index]
                                                  ['number'],
                                              currentSection["questions"][index]
                                                  ["options"][i]['label'],
                                              currentSection["questions"][index]
                                                  ["options"][i]['score'],
                                            ),
                                            child: Row(
                                              children: [
                                                Checkbox(
                                                  activeColor: Theme.of(context)
                                                      .primaryColor,
                                                  checkColor: Colors.white,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15),
                                                  ),
                                                  side: BorderSide(
                                                      color: Colors.blue,
                                                      width: 2),
                                                  value: checked,
                                                  onChanged: (value) => {},
                                                ),
                                                Flexible(
                                                  child: Text(
                                                    currentSection["questions"]
                                                            [index]["options"]
                                                        [i]["label"],
                                                    maxLines: 2,
                                                    style: TextStyle(
                                                      color: checked
                                                          ? Colors.white
                                                          : const Color
                                                              .fromRGBO(
                                                              40, 48, 114, 1),
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  if (currentSection["questions"][index]
                                          ["openEnded"] !=
                                      null)
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: TextFormField(
                                        maxLines: 4, //or null
                                        decoration:
                                            const InputDecoration.collapsed(
                                          border: InputBorder.none,
                                          hintText: "Enter your text here",
                                        ),
                                        onChanged: (value) {
                                          _selectQuestionAnswer(
                                            currentSection["sectionid"],
                                            currentSection["questions"][index]
                                                ['number'],
                                            value,
                                            5,
                                          );
                                        },
                                      ),
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
                                  onPressed: () =>
                                      showConfirmationDialog(context),
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
      ),
    );
  }
}
