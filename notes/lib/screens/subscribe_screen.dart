import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

class SubscribeScreen
    extends StatefulWidget {
  const SubscribeScreen({
    super.key,
  });

  @override
  State<SubscribeScreen>
      createState() =>
          _SubscribeScreenState();
}

class _SubscribeScreenState
    extends State<SubscribeScreen> {
  final TextEditingController
      _topicController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    final l10n =
        AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            Colors.deepPurple,

        foregroundColor:
            Colors.white,

        title: Text(
          l10n.subscribeScreenTitle,
        ),
      ),

      body: Padding(
        padding:
            const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment
                  .start,

          children: [
            Text(
              l10n.customTopicTitle,

              style: const TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            TextField(
              controller:
                  _topicController,

              decoration:
                  InputDecoration(
                hintText:
                    l10n.customTopicHint,

                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
                ),
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            SizedBox(
              width:
                  double.infinity,

              child: ElevatedButton(
                onPressed: () {},

                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.deepPurple,

                  foregroundColor:
                      Colors.white,
                ),

                child: Text(
                  l10n.subscribe,
                ),
              ),
            ),

            const SizedBox(
              height: 24,
            ),

            Text(
              l10n.suggestedTopics,

              style: const TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}