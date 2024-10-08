import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:bu_pulse/data/models/online/dropdown_model.dart';
import 'package:bu_pulse/helpers/variables.dart';

class DropdownProvider {
  Future<Dropdown> getDropdownList({
    required String path,
    required int page,
    required String filter,
    required String q,
  }) async {
    String finalPath = '$path?page=$page';

    if (filter != '') finalPath = '$finalPath&filter=$filter';
    if (q != '') finalPath = '$finalPath&q=$q';

    var url = Uri.parse(ApiConfig.baseUrl + finalPath);
    http.Response response = await http.get(
      url,
      headers: {'x-api-key': ApiConfig.apiKey},
    );

    return Dropdown.fromJson(jsonDecode(response.body));
  }
}
