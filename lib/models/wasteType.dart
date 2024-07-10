class WasteType{
  String material;
  String item;
  bool recyclable;
  String instructions;
  String link;
  String source;

  WasteType(this.material, this.item, this.recyclable, this.instructions, this.link, this.source);

  WasteType.fromJson(Map<String, dynamic> json)
    : material = json['material'] ?? '',
      item = json['item'] ?? '',
      recyclable = json['recyclable'] ?? '',
      instructions = json['instructions'] ?? '',
      link = json.containsKey('links') && json['links'].length != 0 ? json['links'][0] : '',
      source = json['source'];
  
}