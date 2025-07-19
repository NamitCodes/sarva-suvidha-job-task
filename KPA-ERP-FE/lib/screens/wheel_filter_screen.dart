import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kpa_erp/provider/icf_wheel_provider.dart';

class WheelFilterScreen extends StatelessWidget {
  WheelFilterScreen({super.key});

  final TextEditingController formNumberController = TextEditingController();
  final TextEditingController createdByController = TextEditingController();
  final TextEditingController createdAtController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<IcfWheelProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wheel Specifications Filter'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            /// Filter Inputs
            TextField(
              controller: formNumberController,
              decoration: const InputDecoration(
                labelText: 'Form Number',
              ),
            ),
            TextField(
              controller: createdByController,
              decoration: const InputDecoration(
                labelText: 'Submitted By',
              ),
            ),
            TextField(
              controller: createdAtController,
              decoration: const InputDecoration(
                labelText: 'Submitted Date (YYYY-MM-DD)',
              ),
            ),
            const SizedBox(height: 16),

            /// Filter Button
            ElevatedButton(
              onPressed: () {
                provider.applyFilter(
                  formNumber: formNumberController.text.trim(),
                  createdBy: createdByController.text.trim(),
                  createdAt: createdAtController.text.trim(),
                );
                provider.fetchFilteredWheelSpecs(context);
              },
              child: const Text("Apply Filter & Fetch"),
            ),

            const SizedBox(height: 16),

            /// Results
            Expanded(
              child: Consumer<IcfWheelProvider>(
                builder: (context, provider, _) {
                  if (!provider.showSummaryCard) {
                    return const Text("No filter applied yet.");
                  }

                  if (provider.fetchedData.isEmpty) {
                    return const Text("No records found.");
                  }

                  return ListView.builder(
                    itemCount: provider.fetchedData.length,
                    itemBuilder: (context, index) {
                      final item = provider.fetchedData[index];
                      return Card(
                        child: ListTile(
                          title: Text("Form: ${item['formNumber']}"),
                          subtitle: Text("By: ${item['submittedBy']} on ${item['submittedDate']}"),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
