import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory_management_software/screens/app_drawer.dart';
import 'package:inventory_management_software/services/db/inventory_dao.dart';
import 'package:inventory_management_software/services/model/receipt_model.dart';
import 'package:inventory_management_software/services/model/recepit_inventory_model.dart';
import 'package:number_to_words_english/number_to_words_english.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart';

import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

class ReceiptListScreen extends StatefulWidget {
  const ReceiptListScreen({Key? key}) : super(key: key);

  @override
  State<ReceiptListScreen> createState() => _ReceiptListScreenState();
}

class _ReceiptListScreenState extends State<ReceiptListScreen> {
  late Future<List<Receipt>> _receipts;
  final InventoryDao inventoryDao = InventoryDao();

  bool _isSearching = false;
  TextEditingController _searchController = TextEditingController();


  @override
  void initState() {
    super.initState();
    _receipts = fetchReceipts();
  }

  Future<List<Receipt>> fetchReceipts({String? customerName}) async {

    if(customerName == null){
      final data = await inventoryDao.getAllReceipts();
      return data;
    }else{
      return await inventoryDao.getReceiptsByCustomerName(customerName);
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      drawer: AppDrawer(),
      appBar: AppBar(
        title: !_isSearching
            ? const Text(
          "Customer Receipts",
          style: TextStyle(fontSize: 24),
        )
            : null,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _searchController.clear();
                  _receipts = fetchReceipts(); // reload all receipts
                }
                _isSearching = !_isSearching;
              });
            },

          ),
        ],
        bottom: _isSearching
            ? PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Search receipts...',
                border: InputBorder.none,
              ),
              style: const TextStyle(color: Colors.white, fontSize: 18),
              textInputAction: TextInputAction.search,
              onSubmitted: (value) {
                setState(() {
                  _receipts = fetchReceipts(customerName: value);
                });
              },
            ),
          ),
        )
            : null,
      ),

      body: FutureBuilder<List<Receipt>>(
        future: _receipts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No receipts found.'));
          }

          final receipts = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.separated(
              itemCount: receipts.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final receipt = receipts[index];
                return Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      // Left section: Customer Name and Date
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              receipt.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Date: ${receipt.date}",
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),

                      // Right section: Show PDF Button
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: ()async{
                          //fetch inventory
                          Receipt currentReceipt = receipts[index];
                          List<InventoryItem> inventories = await inventoryDao.getInventoryItemsByReceiptId(currentReceipt.id);

                          _generatePDF(
                            currentReceipt.gst,
                            currentReceipt.name,
                            currentReceipt.address,
                            currentReceipt.phone,
                            currentReceipt.email,
                            currentReceipt.gstin,
                              inventories);
                        },
                        child: const Text("Show PDF", style: TextStyle(color: Colors.white),),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  String capitalizeAllWords(String input) {
    return input
        .split(' ')
        .map((word) => word.isNotEmpty
        ? word[0].toUpperCase() + word.substring(1)
        : '')
        .join(' ');
  }

  Future<void> _generatePDF(
      double gstPercent,
      String customerName,
      String address,
      String mobile,
      String email,
      String gstin,
      List<InventoryItem> inventories
      ) async {

    final pdf = pw.Document();

    int sumAmountBeforeGST = 0;

    // Your existing data
    final List<List<String>> data = [
    ];

    for (int i = 0; i < inventories.length; i++) {
      final item = inventories[i];
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
                pw.Center(
                  child: pw.Text(
                    "PROFORMA INVOICE",
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                      decoration: pw.TextDecoration.underline,
                    ),
                  ),
                ),
                pw.SizedBox(height: 1),
                pw.Center(
                  child: pw.Column(
                    children: [
                      pw.Text("OVI REFRIGERATION AND SOLAR", style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                      pw.Text("15 A Bagade Layout, Pusad Road", style: defaultSmallTextStyle),
                      pw.Text("Pusad, Yavatmal, Maharashtra, 445204", style: defaultSmallTextStyle),
                      pw.Text("C/O-HARISH BHAGWAT TAGALPALLEWAR", style: defaultSmallTextStyle),
                      pw.Text("CIN: U74994HR2018PTC077516 | PAN: AINPT2018G", style: defaultSmallTextStyle),
                      pw.Text("GSTIN: 27AINPT2018G1Z4", style: defaultSmallTextStyle),
                      pw.Text("Tel: 9881325407    Email: harish.Pusad@gmail.com", style: defaultSmallTextStyle),
                    ],
                  ),
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
                          pw.Text(customerName, style: defaultSmallTextStyle),
                          pw.Text(address, style: defaultSmallTextStyle),
                          pw.Text("Party Mobile No: ${mobile}", style: defaultSmallTextStyle),
                          if(gstin != "")
                            pw.Text("GSTIN/UIN: ${gstin}", style: defaultSmallTextStyle),
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




    final baseDir = await getApplicationDocumentsDirectory();
    final receiptsDir = Directory(join(baseDir.path, 'inventory_management_system', 'generated_receipts'));
    if (!await receiptsDir.exists()) {
      await receiptsDir.create(recursive: true);
    }
    final now = DateTime.now();
    final formattedDate = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    final file = File(join(receiptsDir.path, '${customerName}_$formattedDate.pdf'));
    await file.writeAsBytes(await pdf.save());

    // Open PDF
    OpenFilex.open(file.path);
  }

}