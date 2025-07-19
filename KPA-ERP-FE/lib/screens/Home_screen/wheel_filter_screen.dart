import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kpa_erp/provider/icf_wheel_provider.dart';

class WheelFilterScreen extends StatefulWidget {
  @override
  _WheelFilterScreenState createState() => _WheelFilterScreenState();
}

class _WheelFilterScreenState extends State<WheelFilterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController formNumberController = TextEditingController();
  final TextEditingController submittedByController = TextEditingController();
  final TextEditingController submittedDateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<IcfWheelProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Filter Wheel Data"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: formNumberController,
                    decoration: const InputDecoration(labelText: "Form Number"),
                  ),
                  TextFormField(
                    controller: submittedByController,
                    decoration: const InputDecoration(labelText: "Submitted By"),
                  ),
                  TextFormField(
                    controller: submittedDateController,
                    decoration: const InputDecoration(
                      labelText: "Submitted Date (YYYY-MM-DD)",
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      provider.applyFilter(
                        formNumber: formNumberController.text,
                        createdBy: submittedByController.text,
                        createdAt: submittedDateController.text,
                      );
                      await provider.fetchFilteredWheelSpecs(context);
                    },
                    child: const Text("Apply Filter & Fetch"),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Result List Section
            provider.showSummaryCard
                ? Expanded(
                    child: provider.fetchedResults.isEmpty
                        ? const Center(child: Text("No Results Found"))
                        : ListView.builder(
                            itemCount: provider.fetchedResults.length,
                            itemBuilder: (context, index) {
                              final item = provider.fetchedResults[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                child: ListTile(
                                  title: Text(item['formNumber'] ?? 'N/A'),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Submitted By: ${item['submittedBy'] ?? 'N/A'}"),
                                      Text("Date: ${item['submittedDate'] ?? 'N/A'}"),
                                      Text("Status: ${item['status'] ?? 'N/A'}"),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  )
                : const SizedBox(), // Empty when no filter applied
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    formNumberController.dispose();
    submittedByController.dispose();
    submittedDateController.dispose();
    super.dispose();
  }
}
