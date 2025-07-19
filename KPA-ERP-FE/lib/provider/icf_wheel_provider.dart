import 'package:flutter/material.dart';
import 'package:kpa_erp/services/api_services/api_service.dart';

class IcfWheelProvider extends ChangeNotifier {
  bool submitted = false;
  bool isEditing = false;
  bool showSummaryCard = false;
  bool showFilterCard = false;  // for filter summary card
  List<Map<String, dynamic>> fetchedResults = [];  // To store filtered response


  final searchController = TextEditingController();
  final treadDiameterController = TextEditingController(text: "915 (900-1000)");
  final lastShopIssueController = TextEditingController(text: "837 (800-900)");
  final condemningDiaController = TextEditingController(text: "825 (800-900)");
  final wheelGaugeController = TextEditingController(text: "1600 (+2,-1)");

  final List<Map<String, Widget>> allFields = [];
  List<Map<String, Widget>> visibleFields = [];

  String filterFormNumber = '';
  String filterCreatedAt = '';
  String filterCreatedBy = '';

  void initializeFields(List<Map<String, Widget>> fields) {
    allFields.clear();
    allFields.addAll(fields);
    visibleFields = List.from(allFields);
    notifyListeners();
  }

  void filterFields(String query) {
    visibleFields = query.isEmpty
        ? List.from(allFields)
        : allFields
            .where((field) => field.keys.first.toLowerCase().contains(query.toLowerCase()))
            .toList();
    notifyListeners();
  }

  void applyFilter({String formNumber = '', String createdAt = '', String createdBy = ''}) {
    filterFormNumber = formNumber;
    filterCreatedAt = createdAt;
    filterCreatedBy = createdBy;

    // Example condition for demonstration, adjust logic according to your actual data
    showSummaryCard = formNumber.isNotEmpty || createdAt.isNotEmpty || createdBy.isNotEmpty;

    notifyListeners();
  }

  void handleSubmit(BuildContext context) async {
    try {
      final now = DateTime.now();
      final submittedDate = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

      final requestBody = {
        "formNumber": "WHEEL-${now.millisecondsSinceEpoch}",
        "submittedBy": "user_id_123", // Replace with actual user ID
        "submittedDate": submittedDate,  // ✅ Send only date, no time
        "fields": {
          "treadDiameterNew": treadDiameterController.text,
          "lastShopIssueSize": lastShopIssueController.text,
          "condemningDia": condemningDiaController.text,
          "wheelGauge": wheelGaugeController.text,
        }
      };

      final response = await ApiService.post("/api/forms/wheel-specifications", requestBody);

      submitted = true;
      isEditing = false;
      notifyListeners();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ Submitted: ${response['message']}")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Submission failed: $e")),
      );
    }
  }

  Future<void> fetchFilteredWheelSpecs(BuildContext context) async {
  try {
    final queryParams = {
      if (filterFormNumber.isNotEmpty) 'formNumber': filterFormNumber,
      if (filterCreatedBy.isNotEmpty) 'submittedBy': filterCreatedBy,
      if (filterCreatedAt.isNotEmpty) 'submittedDate': filterCreatedAt,
    };

    final response = await ApiService.get("/api/forms/wheel-specifications", queryParams);

    if (response['success']) {
      fetchedResults = List<Map<String, dynamic>>.from(response['data']);
      showSummaryCard = true;
      notifyListeners();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ Fetched: ${response['message']}")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Fetch failed: ${response['message']}")),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("❌ Error fetching data: $e")),
    );
  }
}






  void handleEdit() {
    isEditing = true;
    notifyListeners();
  }
}
