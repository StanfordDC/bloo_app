class WasteType{
  String material;
  String item;
  bool recyclable;
  String instructions;
  String link;

  WasteType(this.material, this.item, this.recyclable, this.instructions, this.link);

  WasteType.fromJson(Map<String, dynamic> json)
    : material = json['material'] ?? '',
      item = json['item'] ?? '',
      recyclable = json['recyclable'] ?? '',
      instructions = json['instructions'] ?? '',
      link = json['links'].isEmpty ? '' : json['links'][0];
  
}