class PotentialApiResult {
  final bool found;
  final String matchedCompany;
  final String address;
  final String website;
  final List<dynamic> types;
  final String businessStatus;
  final int confidenceScore;
  final String level;
  final String stromRange;
  final String gasRange;
  final String reasoning;
  final List<dynamic> hints;
  final String? message;

  PotentialApiResult({
    required this.found,
    required this.matchedCompany,
    required this.address,
    required this.website,
    required this.types,
    required this.businessStatus,
    required this.confidenceScore,
    required this.level,
    required this.stromRange,
    required this.gasRange,
    required this.reasoning,
    required this.hints,
    this.message,
  });

  factory PotentialApiResult.fromJson(Map<String, dynamic> json) {
    return PotentialApiResult(
      found: json['found'] ?? false,
      matchedCompany: json['matchedCompany'] ?? '',
      address: json['address'] ?? '',
      website: json['website'] ?? '',
      types: json['types'] ?? [],
      businessStatus: json['businessStatus'] ?? '',
      confidenceScore: json['confidenceScore'] ?? 0,
      level: json['level'] ?? '',
      stromRange: json['stromRange'] ?? '',
      gasRange: json['gasRange'] ?? '',
      reasoning: json['reasoning'] ?? '',
      hints: json['hints'] ?? [],
      message: json['message'],
    );
  }
}