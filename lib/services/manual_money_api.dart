import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/manual_money_model.dart';

class ManualApi{
  static const baseUrl ="http://192.168.150.107:3000/api/";


  static Future<void> addexpense(Map mdata) async{
    try{
      final url=Uri.parse("${baseUrl}addexpense");
      print("Sending data to : $url");
      print("Payload: $mdata");

      final res = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(mdata),
      );

      print("Response status: ${res.statusCode}");
      print("Response body: ${res.body}");

      if(res.statusCode == 200){
        final data=jsonDecode(res.body);
        print("Success: $data");

      }
      else{
        print("Failed to get resposne");

      }

    }catch(e){
      print(e.toString());

    }

  }
  static Future<List<Manual>> getExpenses() async {
    try {
      final url = Uri.parse("${baseUrl}getexpense");
      final res = await http.get(url);

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return (data['expenses'] as List)
            .map((e) => Manual(
          expenseName: e['expenseName'],
          expenseMonth: e['expenseMonth'],
          expenseAmount: e['expenseAmount'],
        ))
            .toList();
      }
      throw Exception('Failed to load expenses');
    } catch (e) {
      throw e;
    }
  }
}