enum AchievementBadgeCategory {
  totalSteps,
  totalCyclingDistance,
  dailySteps,
}

class AchievementBadge {
  final int id;
  final String name;
  final String description;
  final int tier;
  final AchievementBadgeCategory category;
  final int threshold;
  final String iconPath;
  final bool isAchieved;
  final int achievedCount;
  final DateTime? lastAchievedDate;
  final bool isRepeatable;
  final int epValue;

  AchievementBadge({
    required this.id,
    required this.name,
    required this.description,
    required this.tier,
    required this.category,
    required this.threshold,
    required this.iconPath,
    this.isAchieved = false,
    this.achievedCount = 0,
    this.lastAchievedDate,
    this.isRepeatable = false,
    required this.epValue,
  });

  AchievementBadge copyWith({
    int? id,
    String? name,
    String? description,
    int? tier,
    AchievementBadgeCategory? category,
    int? threshold,
    String? iconPath,
    bool? isAchieved,
    int? achievedCount,
    DateTime? lastAchievedDate,
    bool? isRepeatable,
    int? epValue,
  }) {
    return AchievementBadge(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      tier: tier ?? this.tier,
      category: category ?? this.category,
      threshold: threshold ?? this.threshold,
      iconPath: iconPath ?? this.iconPath,
      isAchieved: isAchieved ?? this.isAchieved,
      achievedCount: achievedCount ?? this.achievedCount,
      lastAchievedDate: lastAchievedDate ?? this.lastAchievedDate,
      isRepeatable: isRepeatable ?? this.isRepeatable,
      epValue: epValue ?? this.epValue,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'tier': tier,
      'category': category.index,
      'threshold': threshold,
      'iconPath': iconPath,
      'isAchieved': isAchieved ? 1 : 0,
      'achievedCount': achievedCount,
      'lastAchievedDate': lastAchievedDate?.millisecondsSinceEpoch,
      'isRepeatable': isRepeatable ? 1 : 0,
      'epValue': epValue,
    };
  }

  factory AchievementBadge.fromMap(Map<String, dynamic> map) {
    return AchievementBadge(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      tier: map['tier'],
      category: AchievementBadgeCategory.values[map['category']],
      threshold: map['threshold'],
      iconPath: map['iconPath'],
      isAchieved: map['isAchieved'] == 1,
      achievedCount: map['achievedCount'],
      lastAchievedDate: map['lastAchievedDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['lastAchievedDate'])
          : null,
      isRepeatable: map['isRepeatable'] == 0,
      epValue: map['epValue'],
    );
  }
}
