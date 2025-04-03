import 'package:http/http.dart' as http;
import 'dart:convert';

class ManualApi{
  static const baseUrl ="http://192.168.100.107:3000/api/";


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
}