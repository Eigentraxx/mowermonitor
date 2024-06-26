import 'package:flutter/material.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:quickalert/quickalert.dart';

class SmsApp extends StatefulWidget {
  const SmsApp({Key? key}) : super(key: key);

  @override
  State<SmsApp> createState() => _MyAppState();
}

class _MyAppState extends State<SmsApp> {
  final SmsQuery _query = SmsQuery();
  List<SmsMessage> _messages = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SMS'),
      ),
      body: Container(
        padding: const EdgeInsets.all(10.0),
        child: _messages.isNotEmpty
            ? _MessagesListView(
                messages: _messages,
              )
            : Center(
                child: Text(
                  'No messages to show.\n Tap refresh button...',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          var permission = await Permission.sms.status;
          if (permission.isGranted) {
            //  final messages = await _query.querySms(
            //    kinds: [
            ///     SmsQueryKind.inbox,
            //     SmsQueryKind.sent,
            //    ],
            final messages = await _query.getAllSms;
            // address: '+254712345789',
            final addre = await _query.querySms(address: '+0163044347505');
            //  );
            debugPrint('sms inbox messages: ${messages.length}');
            debugPrint('address inbox messages: ${addre.length}');

            setState(() => _messages = messages);
          } else {
            await Permission.sms.request();
          }
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}

class _MessagesListView extends StatelessWidget {
  const _MessagesListView({
    Key? key,
    required this.messages,
  }) : super(key: key);

  final List<SmsMessage> messages;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: messages.length,
      itemBuilder: (BuildContext context, int i) {
        var message = messages[i];

        return ListTile(
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: Colors.black, width: 1),
            borderRadius: BorderRadius.circular(5),
          ),
          leading: const Icon(
            Icons.question_answer_outlined,
            color: Colors.blue,
            size: 25,
          ),
          selectedTileColor: Colors.orange[100],
          title: Text('${message.sender} [${message.date}]'),
          subtitle: Text('${message.body}'),
          onTap: () => saveToClient(message.sender, message.body, context),
        );
      },
    );
  }
}

saveToClient(sms, smsbody, context) {
  var customerToAssociate = '';
  var senderNumber = sms;
  var senderMessage = smsbody;
  QuickAlert.show(
    context: context,
    type: QuickAlertType.custom,
    barrierDismissible: true,
    confirmBtnText: 'Save',
    customAsset: 'assets/imgs/ewatchcrop.png',
    widget: TextFormField(
      decoration: const InputDecoration(
        alignLabelWithHint: true,
        hintText: 'customer',
        prefixIcon: Icon(
          Icons.telegram,
        ),
      ),
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.text,
      onChanged: (value) => customerToAssociate = value,
    ),
    onConfirmBtnTap: () async {
      Navigator.pop(context);
      await Future.delayed(const Duration(milliseconds: 1000));
      await QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        text: "$senderMessage' has been saved to $customerToAssociate",
      );
    },
  );
}
