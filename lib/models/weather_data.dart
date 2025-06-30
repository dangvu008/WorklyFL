import 'dart:convert';

enum WeatherCondition {
  clear('Trời quang', 'clear'),
  clouds('Có mây', 'clouds'),
  rain('Mưa', 'rain'),
  drizzle('Mưa phùn', 'drizzle'),
  thunderstorm('Dông bão', 'thunderstorm'),
  snow('Tuyết', 'snow'),
  mist('Sương mù', 'mist'),
  fog('Sương mù dày', 'fog'),
  haze('Khói mù', 'haze'),
  dust('Bụi', 'dust'),
  sand('Cát', 'sand'),
  ash('Tro bụi', 'ash'),
  squall('Gió giật', 'squall'),
  tornado('Lốc xoáy', 'tornado');

  const WeatherCondition(this.displayName, this.value);
  final String displayName;
  final String value;

  static WeatherCondition fromString(String value) {
    return WeatherCondition.values.firstWhere(
      (condition) => condition.value == value.toLowerCase(),
      orElse: () => WeatherCondition.clear,
    );
  }

  static WeatherCondition fromOpenWeatherMap(String main) {
    switch (main.toLowerCase()) {
      case 'clear':
        return WeatherCondition.clear;
      case 'clouds':
        return WeatherCondition.clouds;
      case 'rain':
        return WeatherCondition.rain;
      case 'drizzle':
        return WeatherCondition.drizzle;
      case 'thunderstorm':
        return WeatherCondition.thunderstorm;
      case 'snow':
        return WeatherCondition.snow;
      case 'mist':
        return WeatherCondition.mist;
      case 'fog':
        return WeatherCondition.fog;
      case 'haze':
        return WeatherCondition.haze;
      case 'dust':
        return WeatherCondition.dust;
      case 'sand':
        return WeatherCondition.sand;
      case 'ash':
        return WeatherCondition.ash;
      case 'squall':
        return WeatherCondition.squall;
      case 'tornado':
        return WeatherCondition.tornado;
      default:
        return WeatherCondition.clear;
    }
  }
}

enum WeatherSeverity {
  normal('Bình thường', 'normal'),
  warning('Cảnh báo', 'warning'),
  severe('Nghiêm trọng', 'severe'),
  extreme('Cực kỳ nghiêm trọng', 'extreme');

  const WeatherSeverity(this.displayName, this.value);
  final String displayName;
  final String value;

  static WeatherSeverity fromString(String value) {
    return WeatherSeverity.values.firstWhere(
      (severity) => severity.value == value,
      orElse: () => WeatherSeverity.normal,
    );
  }
}

class WeatherLocation {
  final double latitude;
  final double longitude;
  final String name;
  final String? address;

  WeatherLocation({
    required this.latitude,
    required this.longitude,
    required this.name,
    this.address,
  });

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'name': name,
      'address': address,
    };
  }

  factory WeatherLocation.fromJson(Map<String, dynamic> json) {
    return WeatherLocation(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      name: json['name'] as String,
      address: json['address'] as String?,
    );
  }

  @override
  String toString() => name;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WeatherLocation &&
        other.latitude == latitude &&
        other.longitude == longitude;
  }

  @override
  int get hashCode => Object.hash(latitude, longitude);
}

class WeatherAlert {
  final String id;
  final String title;
  final String message;
  final WeatherSeverity severity;
  final DateTime timestamp;
  final DateTime? expiresAt;
  final WeatherCondition relatedCondition;
  final String? actionSuggestion;

  WeatherAlert({
    required this.id,
    required this.title,
    required this.message,
    required this.severity,
    required this.timestamp,
    this.expiresAt,
    required this.relatedCondition,
    this.actionSuggestion,
  });

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  bool get isActive => !isExpired;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'severity': severity.value,
      'timestamp': timestamp.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'relatedCondition': relatedCondition.value,
      'actionSuggestion': actionSuggestion,
    };
  }

  factory WeatherAlert.fromJson(Map<String, dynamic> json) {
    return WeatherAlert(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      severity: WeatherSeverity.fromString(json['severity'] as String),
      timestamp: DateTime.parse(json['timestamp'] as String),
      expiresAt: json['expiresAt'] != null 
          ? DateTime.parse(json['expiresAt'] as String)
          : null,
      relatedCondition: WeatherCondition.fromString(json['relatedCondition'] as String),
      actionSuggestion: json['actionSuggestion'] as String?,
    );
  }
}

class WeatherData {
  final WeatherLocation location;
  final WeatherCondition condition;
  final String description;
  final double temperature; // Celsius
  final double feelsLike; // Celsius
  final double humidity; // Percentage
  final double pressure; // hPa
  final double windSpeed; // m/s
  final double? windDirection; // degrees
  final double visibility; // km
  final double? uvIndex;
  final DateTime timestamp;
  final DateTime sunrise;
  final DateTime sunset;
  final List<WeatherAlert> alerts;
  final String iconCode;

  WeatherData({
    required this.location,
    required this.condition,
    required this.description,
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.pressure,
    required this.windSpeed,
    this.windDirection,
    required this.visibility,
    this.uvIndex,
    required this.timestamp,
    required this.sunrise,
    required this.sunset,
    this.alerts = const [],
    required this.iconCode,
  });

  // Helper getters
  String get temperatureString => '${temperature.round()}°C';
  String get feelsLikeString => '${feelsLike.round()}°C';
  String get humidityString => '${humidity.round()}%';
  String get windSpeedString => '${windSpeed.toStringAsFixed(1)} m/s';
  String get visibilityString => '${visibility.toStringAsFixed(1)} km';
  String get pressureString => '${pressure.round()} hPa';

  bool get isDaytime {
    final now = DateTime.now();
    return now.isAfter(sunrise) && now.isBefore(sunset);
  }

  // Weather severity analysis
  WeatherSeverity get severity {
    // Extreme conditions
    if (condition == WeatherCondition.thunderstorm ||
        condition == WeatherCondition.tornado ||
        temperature > 40 ||
        temperature < -10 ||
        windSpeed > 20) {
      return WeatherSeverity.extreme;
    }

    // Severe conditions
    if (condition == WeatherCondition.rain ||
        condition == WeatherCondition.snow ||
        temperature > 35 ||
        temperature < 0 ||
        windSpeed > 15 ||
        visibility < 1) {
      return WeatherSeverity.severe;
    }

    // Warning conditions
    if (condition == WeatherCondition.drizzle ||
        condition == WeatherCondition.fog ||
        condition == WeatherCondition.mist ||
        temperature > 30 ||
        temperature < 5 ||
        windSpeed > 10 ||
        humidity > 90) {
      return WeatherSeverity.warning;
    }

    return WeatherSeverity.normal;
  }

  // Generate weather alerts based on conditions
  List<WeatherAlert> generateAlerts() {
    final List<WeatherAlert> generatedAlerts = [];
    final now = DateTime.now();

    // Temperature alerts
    if (temperature > 35) {
      generatedAlerts.add(WeatherAlert(
        id: 'temp_hot_${now.millisecondsSinceEpoch}',
        title: 'Cảnh báo nóng',
        message: 'Nhiệt độ cao $temperatureString, cảm giác như $feelsLikeString',
        severity: temperature > 40 ? WeatherSeverity.extreme : WeatherSeverity.severe,
        timestamp: now,
        expiresAt: now.add(const Duration(hours: 3)),
        relatedCondition: condition,
        actionSuggestion: 'Mang theo nước uống, tránh tiếp xúc trực tiếp với nắng',
      ));
    }

    if (temperature < 5) {
      generatedAlerts.add(WeatherAlert(
        id: 'temp_cold_${now.millisecondsSinceEpoch}',
        title: 'Cảnh báo lạnh',
        message: 'Nhiệt độ thấp $temperatureString, cảm giác như $feelsLikeString',
        severity: temperature < 0 ? WeatherSeverity.extreme : WeatherSeverity.severe,
        timestamp: now,
        expiresAt: now.add(const Duration(hours: 3)),
        relatedCondition: condition,
        actionSuggestion: 'Mặc ấm, đeo găng tay và khăn quàng cổ',
      ));
    }

    // Rain alerts
    if (condition == WeatherCondition.rain || condition == WeatherCondition.thunderstorm) {
      generatedAlerts.add(WeatherAlert(
        id: 'rain_${now.millisecondsSinceEpoch}',
        title: condition == WeatherCondition.thunderstorm ? 'Cảnh báo dông bão' : 'Cảnh báo mưa',
        message: description,
        severity: condition == WeatherCondition.thunderstorm 
            ? WeatherSeverity.extreme 
            : WeatherSeverity.severe,
        timestamp: now,
        expiresAt: now.add(const Duration(hours: 2)),
        relatedCondition: condition,
        actionSuggestion: 'Mang theo áo mưa hoặc ô, tránh di chuyển nếu có thể',
      ));
    }

    // Wind alerts
    if (windSpeed > 15) {
      generatedAlerts.add(WeatherAlert(
        id: 'wind_${now.millisecondsSinceEpoch}',
        title: 'Cảnh báo gió mạnh',
        message: 'Gió mạnh $windSpeedString',
        severity: windSpeed > 20 ? WeatherSeverity.extreme : WeatherSeverity.severe,
        timestamp: now,
        expiresAt: now.add(const Duration(hours: 2)),
        relatedCondition: condition,
        actionSuggestion: 'Cẩn thận khi di chuyển, tránh đứng dưới cây cao',
      ));
    }

    // Visibility alerts
    if (visibility < 1) {
      generatedAlerts.add(WeatherAlert(
        id: 'visibility_${now.millisecondsSinceEpoch}',
        title: 'Cảnh báo tầm nhìn hạn chế',
        message: 'Tầm nhìn chỉ $visibilityString',
        severity: WeatherSeverity.severe,
        timestamp: now,
        expiresAt: now.add(const Duration(hours: 2)),
        relatedCondition: condition,
        actionSuggestion: 'Lái xe chậm, bật đèn, tăng khoảng cách an toàn',
      ));
    }

    return generatedAlerts;
  }

  // Get weather icon URL
  String getIconUrl({String size = '2x'}) {
    return 'https://openweathermap.org/img/wn/$iconCode@$size.png';
  }

  // Copy with modifications
  WeatherData copyWith({
    WeatherLocation? location,
    WeatherCondition? condition,
    String? description,
    double? temperature,
    double? feelsLike,
    double? humidity,
    double? pressure,
    double? windSpeed,
    double? windDirection,
    double? visibility,
    double? uvIndex,
    DateTime? timestamp,
    DateTime? sunrise,
    DateTime? sunset,
    List<WeatherAlert>? alerts,
    String? iconCode,
  }) {
    return WeatherData(
      location: location ?? this.location,
      condition: condition ?? this.condition,
      description: description ?? this.description,
      temperature: temperature ?? this.temperature,
      feelsLike: feelsLike ?? this.feelsLike,
      humidity: humidity ?? this.humidity,
      pressure: pressure ?? this.pressure,
      windSpeed: windSpeed ?? this.windSpeed,
      windDirection: windDirection ?? this.windDirection,
      visibility: visibility ?? this.visibility,
      uvIndex: uvIndex ?? this.uvIndex,
      timestamp: timestamp ?? this.timestamp,
      sunrise: sunrise ?? this.sunrise,
      sunset: sunset ?? this.sunset,
      alerts: alerts ?? this.alerts,
      iconCode: iconCode ?? this.iconCode,
    );
  }

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'location': location.toJson(),
      'condition': condition.value,
      'description': description,
      'temperature': temperature,
      'feelsLike': feelsLike,
      'humidity': humidity,
      'pressure': pressure,
      'windSpeed': windSpeed,
      'windDirection': windDirection,
      'visibility': visibility,
      'uvIndex': uvIndex,
      'timestamp': timestamp.toIso8601String(),
      'sunrise': sunrise.toIso8601String(),
      'sunset': sunset.toIso8601String(),
      'alerts': alerts.map((alert) => alert.toJson()).toList(),
      'iconCode': iconCode,
    };
  }

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      location: WeatherLocation.fromJson(json['location'] as Map<String, dynamic>),
      condition: WeatherCondition.fromString(json['condition'] as String),
      description: json['description'] as String,
      temperature: (json['temperature'] as num).toDouble(),
      feelsLike: (json['feelsLike'] as num).toDouble(),
      humidity: (json['humidity'] as num).toDouble(),
      pressure: (json['pressure'] as num).toDouble(),
      windSpeed: (json['windSpeed'] as num).toDouble(),
      windDirection: (json['windDirection'] as num?)?.toDouble(),
      visibility: (json['visibility'] as num).toDouble(),
      uvIndex: (json['uvIndex'] as num?)?.toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      sunrise: DateTime.parse(json['sunrise'] as String),
      sunset: DateTime.parse(json['sunset'] as String),
      alerts: (json['alerts'] as List?)
          ?.map((alertJson) => WeatherAlert.fromJson(alertJson as Map<String, dynamic>))
          .toList() ?? [],
      iconCode: json['iconCode'] as String,
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory WeatherData.fromJsonString(String jsonString) {
    return WeatherData.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
  }

  @override
  String toString() {
    return 'WeatherData(location: ${location.name}, condition: ${condition.displayName}, temp: $temperatureString)';
  }
}
