import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:upi_india/upi_india.dart';

import '../helper/dialogs.dart';
import '../widgets/particle_animation.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  Future<UpiResponse>? _transaction;
  final UpiIndia _upiIndia = UpiIndia();
  List<UpiApp>? _upiApps;

  TextStyle header = const TextStyle(fontSize: 20, fontWeight: FontWeight.bold);
  TextStyle value = const TextStyle(fontSize: 17, fontWeight: FontWeight.bold);

  @override
  void initState() {
    super.initState();
    _upiIndia.getAllUpiApps(mandatoryTransactionId: false).then((value) {
      setState(() {
        _upiApps = value;
      });
    }).catchError((error) {
      Dialogs.showErrorSnackBar(context, error.toString());
      _upiApps = [];
    });
  }

  Future<UpiResponse> initiateTransaction(UpiApp app) async {
    // String upiId = '9113415228';
    // if (app == UpiApp.amazonPay)
    //   upiId += '@yapl';
    // else if (app == UpiApp.paytm) upiId += '@paytm';
    return _upiIndia.startTransaction(
      app: app,
      receiverUpiId: '9113415228@paytm',
      // receiverUpiId: upiId,
      receiverName: 'AMAN KUMAR',
      transactionRefId: DateTime.now().toIso8601String(),
      amount: 5,
      flexibleAmount: true,
    );
  }

  Widget displayUpiApps(BuildContext context) {
    if (_upiApps == null) {
      return const Center(child: CircularProgressIndicator());
    } else if (_upiApps!.isEmpty) {
      return Text(
        'No apps found to handle transaction!',
        style: header,
      );
    } else {
      return Align(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Wrap(
            children: _upiApps!.map<Widget>((UpiApp app) {
              return GestureDetector(
                onTap: () {
                  _transaction = initiateTransaction(app);
                  setState(() {});
                },
                child: SizedBox(
                  height: 100,
                  width: 100,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.memory(
                        app.icon,
                        height: 60,
                        width: 60,
                      ),
                      Text(app.name),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      );
    }
  }

  void _checkTxnStatus(String status) {
    switch (status) {
      case UpiPaymentStatus.SUCCESS:
        log('Payment successful!');
        // Dialogs.showSnackBar(context, 'Payment successful!');
        break;
      case UpiPaymentStatus.SUBMITTED:
        log('Transaction submitted!');
        // Dialogs.showSnackBar(context, 'Transaction submitted!');
        break;
      case UpiPaymentStatus.FAILURE:
        log('Transaction failed!');
        // Dialogs.showErrorSnackBar(context, 'Transaction failed!');
        break;
      default:
        log(status.toString());
    }
  }

  Widget displayTxnData(String title, body) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('$title: ', style: header),
          Flexible(child: Text(body, style: value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Back',
          icon: const Icon(CupertinoIcons.chevron_back),
        ),
        title: const Text('Payment',
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2)),
      ),
      body: Stack(
        children: [
          particles(context),
          Column(
            children: [
              Expanded(child: displayUpiApps(context)),
              Expanded(
                  child: FutureBuilder(
                future: _transaction,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Error', style: header));
                    }
                    UpiResponse upiResponse = snapshot.data!;

                    String txnId = upiResponse.transactionId ?? 'N/A';
                    String resCode = upiResponse.responseCode ?? 'N/A';
                    String txnRef = upiResponse.transactionRefId ?? 'N/A';
                    String status = upiResponse.status ?? 'N/A';
                    String approvalRef = upiResponse.approvalRefNo ?? 'N/A';
                    _checkTxnStatus(status);

                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          displayTxnData('Transaction Id', txnId),
                          displayTxnData('Response code', resCode),
                          displayTxnData('Reference Id', txnRef),
                          displayTxnData('Status', status.toUpperCase()),
                          displayTxnData('Approval no.', approvalRef),
                        ],
                      ),
                    );
                  } else {
                    return Center(child: Text('', style: header));
                  }
                },
              ))
            ],
          ),
        ],
      ),
    );
  }
}
