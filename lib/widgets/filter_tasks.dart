import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:searchfield/searchfield.dart';

class FilterTasks extends StatelessWidget {
  const FilterTasks({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    List<String> suggestionsUsers = ["gtau-admin", "gtau-oper", "no-asignada"];
    List<String> suggestionsStatus = [
      "Pendiente",
      "En curso",
      "Bloqueadas",
      "Terminadas"
    ];

    return Scaffold(
      appBar: AppBar(),
      body: SizedBox(
        height: 500,
        child: Padding(
          padding: const EdgeInsets.all(kIsWeb ? 100.0 : 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              DropdownButtonExample(
                suggestions: suggestionsUsers,
              ),
              SearchFieldSuggestions(
                suggestions: suggestionsUsers,
                hint: 'Usuario',
                keyName: "userfield",
              ),
              SearchFieldSuggestions(
                suggestions: suggestionsStatus,
                hint: 'Status',
                keyName: "statusfield",
              ),
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 50,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text(AppLocalizations.of(context)!
                                  .buttonCleanLabel),
                            ),
                            const SizedBox(width: 10.0),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text(AppLocalizations.of(context)!
                                  .buttonApplyLabel),
                            ),
                          ]),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SearchFieldSuggestions extends StatelessWidget {
  SearchFieldSuggestions({
    super.key,
    required this.suggestions,
    required this.hint,
    required this.keyName,
  });

  final List<String> suggestions;
  final String hint;
  final String keyName;
  final focus = FocusNode();

  @override
  Widget build(BuildContext context) {
    return SearchField(
      onSearchTextChanged: (query) {
        final filter = suggestions
            .where((element) =>
                element.toLowerCase().contains(query.toLowerCase()))
            .toList();
        return filter
            .map((e) => SearchFieldListItem<String>(e,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text(e,
                      style: TextStyle(fontSize: 24, color: Colors.black)),
                )))
            .toList();
      },
      key: Key(keyName),
      hint: hint,
      itemHeight: 50,
      scrollbarDecoration: ScrollbarDecoration(
        thumbVisibility: true,
        thumbColor: Colors.blue,
        fadeDuration: const Duration(milliseconds: 3000),
        trackColor: Colors.blue,
        trackRadius: const Radius.circular(10),
      ),
      searchInputDecoration:
          InputDecoration(hintStyle: TextStyle(color: Colors.black54)),
      suggestionsDecoration: SuggestionDecoration(
          padding: const EdgeInsets.all(4),
          border: Border.all(color: Colors.black12),
          borderRadius: BorderRadius.all(Radius.circular(10))),
      suggestions: suggestions
          .map((e) => SearchFieldListItem<String>(e,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text(e,
                    style: TextStyle(fontSize: 24, color: Colors.black87)),
              )))
          .toList(),
      focusNode: focus,
      suggestionState: Suggestion.expand,
      onSuggestionTap: (SearchFieldListItem<String> x) {
        focus.unfocus();
      },
    );
  }
}

class DropdownButtonExample extends StatefulWidget {
  DropdownButtonExample({Key? key, required this.suggestions});

  List<String> suggestions;

  @override
  State<DropdownButtonExample> createState() =>
      _DropdownButtonExampleState(this.suggestions);
}

class _DropdownButtonExampleState extends State<DropdownButtonExample> {
  _DropdownButtonExampleState(this.suggestions);

  List<String> suggestions;

  @override
  Widget build(BuildContext context) {
    String dropdownValue = suggestions.first;
    return DropdownButton<String>(
      value: dropdownValue,
      icon: const Icon(Icons.arrow_downward),
      elevation: 16,
      style: const TextStyle(color: Colors.deepPurple),
      underline: Container(
        height: 2,
        color: Colors.deepPurpleAccent,
      ),
      onChanged: (String? value) {
        // This is called when the user selects an item.
        setState(() {
          dropdownValue = value!;
        });
      },
      items: this.suggestions.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}
