class ServiceModel {
  String? id; // Optional to prevent breaking existing code
  String name;
  String category;
  String icon;
  String? location;
  String? imgURL;
  List<Map<String, String>> attributes;

  ServiceModel({
    this.id,
    required this.name,
    required this.category,
    required this.icon,
    this.location,
    this.imgURL,
    required this.attributes,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json, String docId) {
    return ServiceModel(
      id: docId,
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      icon: json['icon'] ?? '',
      attributes: List<Map<String, String>>.from(
        (json['attributes'] ?? []).map<Map<String, String>>(
              (attr) => Map<String, String>.from(attr),
        ),
      ),
    );
  }


  factory ServiceModel.fromJson2(Map<String, dynamic> json, String docId) {
    final rawAttributes = json['attributes'];
    List<Map<String, String>> parsedAttributes = [];


    // if (rawAttributes is List) {
    //   parsedAttributes = rawAttributes.map<Map<String, String>>((attr) {
    //     if (attr is Map) {
    //       return Map<String, String>.from(attr.map((key, value) =>
    //           MapEntry(key.toString(), value.toString())));
    //     } else {
    //       return {};
    //     }
    //   }).toList();
    // }

    if (rawAttributes is List) {
      parsedAttributes = rawAttributes
          .whereType<Map>() // Ensures each item is a Map
          .map<Map<String, String>>((attr) {
        return {
          'key': attr['key'].toString(),
          'value': attr['value'].toString(),
        };
      }).toList();
    } else if (rawAttributes is Map) {
      parsedAttributes = rawAttributes.entries.map((entry) {
        return {
          'key': entry.key.toString(),
          'value': entry.value.toString(),
        };
      }).toList();
    } else {
      print("Unexpected attribute format: $rawAttributes");
    }

    return ServiceModel(
      id: docId,
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      icon: json['icon'] ?? '',
      location:json['location'],
      imgURL:json['imageUrl'],
      attributes: parsedAttributes,
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category,
      'icon': icon,
      'attributes': attributes,
    };
  }
}
