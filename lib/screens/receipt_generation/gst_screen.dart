import 'package:flutter/material.dart';
import 'package:inventory_management_software/screens/app_drawer.dart';
import 'package:inventory_management_software/services/db/inventory_dao.dart';
import 'package:inventory_management_software/services/model/recepit_inventory_model.dart';
import 'package:open_filex/open_filex.dart';
import 'package:number_to_words_english/number_to_words_english.dart';
import 'package:path/path.dart';

import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;


class GSTScreen extends StatefulWidget {
  final String userName;
  final String address;
  final String emailAddress;
  final String mobile;
  final String gstin;
  final List<InventoryItem> selectedItems;

  const GSTScreen({
    super.key,
    required this.userName,
    required this.address,
    required this.emailAddress,
    required this.mobile,
    required this.gstin,
    required this.selectedItems,
  });

  @override
  State<GSTScreen> createState() => _GSTScreenState();
}

class _GSTScreenState extends State<GSTScreen> {
  final TextEditingController _gstController = TextEditingController();
  final InventoryDao inventoryDao = InventoryDao();



  String capitalizeAllWords(String input) {
    return input
        .split(' ')
        .map((word) => word.isNotEmpty
        ? word[0].toUpperCase() + word.substring(1)
        : '')
        .join(' ');
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(title: const Text('Apply GST & Generate PDF')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextFormField(
              controller: _gstController,
              decoration: const InputDecoration(
                labelText: 'Enter GST %',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (){
                  _generatePDF();
                },
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7),
                    ),
                    backgroundColor: Colors.black
                ),
                child: const Text('Generate PDF', style: TextStyle(color: Colors.white),),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _generatePDF() async {
    final gstPercent = double.tryParse(_gstController.text.trim()) ?? 0;
    final pdf = pw.Document();

    final imageBytes = await rootBundle.load('assets/app_logo.jpeg');
    final logoImage = pw.MemoryImage(imageBytes.buffer.asUint8List());


    int sumAmountBeforeGST = 0;

    // Your existing data
    final List<List<String>> data = [
    ];

    for (int i = 0; i < widget.selectedItems.length; i++) {
      final item = widget.selectedItems[i];
      final int price = item.sellingPrice;
      final int quantity = item.sellingQuantity;

      sumAmountBeforeGST += (price * quantity);



      data.add([
        "${i + 1}.", // Serial number
        item.productName,
        item.hsnCode ?? "N/A",
        quantity.toString(),
        price.toStringAsFixed(2),
        (quantity*price).toStringAsFixed(2),
      ]);
    }

    double gstAmount = (gstPercent * sumAmountBeforeGST) / 100;
    double sumAmountAfterGST = sumAmountBeforeGST + gstAmount;

    // Define headers
    final headers = [
      "S.N.",
      "Description of Goods",
      "HSN/SAC Code",
      "Qty.",
      "Price",
      "Amount"
    ];

// Fill empty rows to make a total of 10 rows
    while (data.length < 34) {
      data.add(List.filled(6, "")); // 8 columns
    }

    var defaultSmallTextStyle = pw.TextStyle(
      fontSize: 8,
      fontWeight: pw.FontWeight.bold,
    );
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(30),
        build: (pw.Context context) {
          return pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(width: 0.5, color: PdfColors.black),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Container(
                        width: 100, // Set width/height as needed
                        height: 100,
                        child: pw.Image(logoImage),
                      ),
                      pw.SizedBox(width: 10),
                      pw.Expanded(
                        child: pw.Column(
                         crossAxisAlignment: pw.CrossAxisAlignment.center,
                         children: [
                           pw.Text("PROFORMA INVOICE",
                               style: pw.TextStyle(
                                 fontSize: 10,
                                 fontWeight: pw.FontWeight.bold,
                                 decoration: pw.TextDecoration.underline,
                               )),
                           pw.SizedBox(height: 2),
                           pw.Text("OVI REFRIGERATION AND SOLAR", style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                           pw.Text("15 A Bagade Layout, Pusad Road", style: defaultSmallTextStyle),
                           pw.Text("Pusad, Yavatmal, Maharashtra, 445204", style: defaultSmallTextStyle),
                           pw.Text("C/O-HARISH BHAGWAT TAGALPALLEWAR", style: defaultSmallTextStyle),
                           pw.Text("CIN: U74994HR2018PTC077516 | PAN: AINPT2018G", style: defaultSmallTextStyle),
                           pw.Text("GSTIN: 27AINPT2018G1Z4", style: defaultSmallTextStyle),
                           pw.Text("Tel: 9881325407    Email: harish.Pusad@gmail.com", style: defaultSmallTextStyle),
                         ]
                        )
                      )
                    ]
                ),

                pw.Divider(thickness: 0.5),

                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Container(width: 5),

                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text("To:", style: defaultSmallTextStyle),
                          pw.Text(widget.userName, style: defaultSmallTextStyle),
                          pw.Text(widget.address, style: defaultSmallTextStyle),
                          pw.Text("Party Mobile No: ${widget.mobile}", style: defaultSmallTextStyle),
                          if(widget.gstin != "")
                            pw.Text("GSTIN/UIN: ${widget.gstin}", style: defaultSmallTextStyle),
                        ],
                      ),
                    ),

                    pw.Container(
                      height: 90,
                      child: pw.VerticalDivider(
                        thickness: 0.5, // Divider thickness
                        color: PdfColors.black,
                      ),
                      // margin: pw.EdgeInsets.symmetric(horizontal: -10)
                    ),


                    pw.Expanded(
                        child: pw.SizedBox()
                    ),
                  ],
                ),

                // pw.Divider(thickness: 0.5),

                pw.Table(
                  border: const pw.TableBorder(
                    top: pw.BorderSide(width: 0.5, color: PdfColors.black), // Add this
                    verticalInside: pw.BorderSide(width: 0.5, color: PdfColors.black),
                    left: pw.BorderSide(width: 0.5, color: PdfColors.black),
                    right: pw.BorderSide(width: 0.5, color: PdfColors.black),
                  ),
                  children: [
                    // Header row
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(
                        border: pw.Border(
                          bottom: pw.BorderSide(width: 0.5, color: PdfColors.black),
                        ),
                      ),
                      children: headers
                          .map(
                            (header) => pw.Container(
                          padding: const pw.EdgeInsets.all(4),
                          alignment: pw.Alignment.center,
                          child: pw.Text(
                            header,
                            style: pw.TextStyle(
                              fontSize: 7,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                      )
                          .toList(),
                    ),

                    // Data rows
                    ...data.map(
                          (row) => pw.TableRow(
                        children: row
                            .map(
                              (cell) => pw.Container(
                            padding: const pw.EdgeInsets.all(4),
                            alignment: pw.Alignment.center,
                            child: pw.Text(
                              cell,
                              style: pw.TextStyle(fontSize: 7),
                            ),
                          ),
                        )
                            .toList(),
                      ),
                    )
                  ],
                ),

                pw.Table(
                  border: pw.TableBorder.all(),
                  columnWidths: {
                    0: pw.FlexColumnWidth(7),
                    1: pw.FlexColumnWidth(1),
                  },
                  children: [
                    pw.TableRow(
                      children: [
                        // First column
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.end, // <- Push to right
                            children: [
                              pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Row(
                                    mainAxisSize: pw.MainAxisSize.min,
                                    children: [
                                      pw.Container(
                                        width: 35,
                                        alignment: pw.Alignment.centerRight,
                                        child: pw.Text("Sum :", style: const pw.TextStyle(fontSize: 7)),
                                      ),
                                      pw.SizedBox(width: 4),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Second column: amount values
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.end,
                            children: [
                              pw.Text(sumAmountBeforeGST.toString(), style: const pw.TextStyle(fontSize: 7)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                pw.Table(
                  border: pw.TableBorder.all(),
                  columnWidths: {
                    0: pw.FlexColumnWidth(7),
                    1: pw.FlexColumnWidth(1),
                  },
                  children: [
                    pw.TableRow(
                      children: [
                        // First column
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.end, // <- Push to right
                            children: [
                              pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Row(
                                    mainAxisSize: pw.MainAxisSize.min,
                                    children: [
                                      pw.Container(
                                        width: 35,
                                        alignment: pw.Alignment.centerRight,
                                        child: pw.Text("Add :", style: const pw.TextStyle(fontSize: 7)),
                                      ),
                                      pw.SizedBox(width: 4),
                                      pw.Text(
                                        "IGST @ $gstPercent %",
                                        style: const pw.TextStyle(fontSize: 7),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Second column: amount values
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.end,
                            children: [
                              pw.Text(gstAmount.toString(), style: const pw.TextStyle(fontSize: 7)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                pw.Table(
                    border: pw.TableBorder.all(),
                    columnWidths: {
                      0: pw.FlexColumnWidth(7),
                      1: pw.FlexColumnWidth(1),
                    },
                    children: [
                      pw.TableRow(
                        children: [
                          // Left column (description)
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4),
                            child: pw.Align(
                              alignment: pw.Alignment.centerRight,
                              child: pw.Text(
                                "Grand Amount",
                                style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold),
                              ),
                            ),
                          ),
                          // Right column (amount)
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4),
                            child: pw.Align(
                              alignment: pw.Alignment.centerRight,
                              child: pw.Text(
                                sumAmountAfterGST.toString(),
                                style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),

                    ]
                ),
                pw.SizedBox(height: 5),

                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 2), // Adjust padding
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // Left Side: Column for Labels
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text("Tax Rate ", style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold)),
                          pw.SizedBox(height: 2),
                          pw.Text("$gstPercent%", style: const pw.TextStyle(fontSize: 7)),
                        ],
                      ),

                      pw.SizedBox(width: 10), // Space between columns

                      // Middle Column: Taxable Amt & IGST
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text("Taxable Amt. ", style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold, decoration: pw.TextDecoration.underline)),
                          pw.SizedBox(height: 2),
                          pw.Text(sumAmountBeforeGST.toString(), style: const pw.TextStyle(fontSize: 7)),
                        ],
                      ),

                      pw.SizedBox(width: 10),

                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text("IGST Amt. ", style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold, decoration: pw.TextDecoration.underline)),
                          pw.SizedBox(height: 2),
                          pw.Text(sumAmountAfterGST.toString(), style: const pw.TextStyle(fontSize: 7)),
                        ],
                      ),

                      pw.SizedBox(width: 10),

                      // Right Column: Total Tax
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text("Total Tax", style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold, decoration: pw.TextDecoration.underline)),
                          pw.SizedBox(height: 2),
                          pw.Text(sumAmountAfterGST.toString(), style: const pw.TextStyle(fontSize: 7)),
                        ],
                      ),
                    ],
                  ),
                ),

                pw.SizedBox(height: 4), // Space before amount in words

// Rupees in words
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 2),
                  child: pw.Text(
                    "${capitalizeAllWords(NumberToWordsEnglish.convert(sumAmountAfterGST).replaceFirst("point", ""))} Rupees Only",
                    style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold),
                  ),
                ),






                pw.SizedBox(height: 5),


                //declaration Section
                pw.Divider(thickness: 0.5),
                pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    children: [
                      pw.Center(
                          child: pw.Text(
                            "Declaration",
                            style: pw.TextStyle(
                              fontSize: 14,
                              fontWeight: pw.FontWeight.bold,
                              decoration: pw.TextDecoration.underline,
                            ),
                          )
                      ),

                      pw.Center(
                        child: pw.Text(""
                            "We declare that proforma invoice shows the actual price of the goods described and that all particulars are true and correct.",
                          style: const pw.TextStyle(
                            fontSize: 9,
                          ),
                        ),
                      )

                    ]
                ),
                pw.Divider(thickness: 0.5),

                pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    children: [
                      pw.Center(
                          child: pw.Text(
                            "Bank Details",
                            style: pw.TextStyle(
                              fontSize: 14,
                              fontWeight: pw.FontWeight.bold,
                              decoration: pw.TextDecoration.underline,
                            ),
                          )
                      ),

                      pw.SizedBox(height: 5),

                      pw.Text("Bank Details: State Bank Of India  | Name: OVI REFRIGERATION AND SOLAR | Type: Overdraft", style: const pw.TextStyle(fontSize: 9)),
                      pw.Text("IFSC: SBIN0000459 | A/c No: 41477818348 | UPI: 8700353139@hdfcbank", style: const pw.TextStyle(fontSize: 9)),

                    ]
                ),
                pw.Divider(thickness: 0.5),

                pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Expanded(
                          child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [

                                pw.Padding(
                                  padding: const pw.EdgeInsets.only(left: 2), // You can adjust the left padding value
                                  child: pw.Text(
                                    "Receiver Signature: ",
                                    style: pw.TextStyle(
                                      fontSize: 9,
                                      fontWeight: pw.FontWeight.bold,
                                    ),
                                  ),
                                ),



                              ]
                          )
                      ),

                      pw.Container(
                          width: 1,
                          height: 83, // fills available height
                          color: PdfColors.black,
                          margin: pw.EdgeInsets.only(top: -7, bottom: -2)
                      ),

                      pw.Expanded(
                          child: pw.Column(
                              mainAxisAlignment: pw.MainAxisAlignment.start,
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [

                                pw.Row(
                                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                                    mainAxisAlignment: pw.MainAxisAlignment.end,
                                    children: [
                                      pw.Column(
                                          crossAxisAlignment: pw.CrossAxisAlignment.end,
                                          mainAxisAlignment: pw.MainAxisAlignment.end,
                                          children: [
                                            pw.Text("For Ovi Refrigeration and Solars", style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                                            pw.SizedBox(
                                                height: 40
                                            ),
                                            pw.Text("Authorized Signature", style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                                          ]
                                      ),
                                      pw.SizedBox(
                                          width: 5
                                      ),

                                    ]
                                )
                              ]
                          )

                      )

                    ]

                ),



              ],
            ),
          );
        },
      ),
    );

    //reduce qty from inventory
    for (int i = 0; i < widget.selectedItems.length; i++){
      final item = widget.selectedItems[i];
      final inventoryId = item.inventoryId;
      final selectedQuantity = item.sellingQuantity;

      await inventoryDao.reduceInventoryQuantity(inventoryId, selectedQuantity);
    }

    //add customer and inventory to tables
    int receiptID = await inventoryDao.addReceipt(
        widget.userName,
        widget.address,
        widget.mobile,
        widget.emailAddress,
        gstPercent.toString(),
        widget.gstin
    );

    for (int i = 0; i < widget.selectedItems.length; i++){
      final item = widget.selectedItems[i];


      await inventoryDao.addReceiptInventory(
        receiptID,
        item.inventoryId,
        item.hsnCode,
        item.sellingQuantity,
        item.sellingPrice
      );
    }



    final documentsDir = await getApplicationDocumentsDirectory();
    final customDir = Directory(join(documentsDir.path, 'inventory_management_system'));
    if (!await customDir.exists()) {
      await customDir.create(recursive: true);
    }
    final file = File(join(customDir.path, 'invoice.pdf'));
    await file.writeAsBytes(await pdf.save());

    // Open PDF
    OpenFilex.open(file.path);
  }

}
