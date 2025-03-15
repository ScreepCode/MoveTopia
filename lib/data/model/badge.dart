enum AchivementBadgeCategory {
  totalSteps,
  totalCyclingDistance,
  dailySteps,
}

class AchivementBadge {
  final int id;
  final String name;
  final String description;
  final AchivementBadgeCategory category;
  final int threshold;
  final String iconPath;
  final bool isAchieved;
  final int achievedCount;
  final DateTime? lastAchievedDate;

  AchivementBadge({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.threshold,
    required this.iconPath,
    this.isAchieved = false,
    this.achievedCount = 0,
    this.lastAchievedDate,
  });

  AchivementBadge copyWith({
    int? id,
    String? name,
    String? description,
    AchivementBadgeCategory? category,
    int? threshold,
    String? iconPath,
    bool? isAchieved,
    int? achievedCount,
    DateTime? lastAchievedDate,
  }) {
    return AchivementBadge(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      threshold: threshold ?? this.threshold,
      iconPath: iconPath ?? this.iconPath,
      isAchieved: isAchieved ?? this.isAchieved,
      achievedCount: achievedCount ?? this.achievedCount,
      lastAchievedDate: lastAchievedDate ?? this.lastAchievedDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category.index,
      'threshold': threshold,
      'iconPath': iconPath,
      'isAchieved': isAchieved ? 1 : 0,
      'achievedCount': achievedCount,
      'lastAchievedDate': lastAchievedDate?.millisecondsSinceEpoch,
    };
  }

  factory AchivementBadge.fromMap(Map<String, dynamic> map) {
    return AchivementBadge(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      category: AchivementBadgeCategory.values[map['category']],
      threshold: map['threshold'],
      iconPath: map['iconPath'],
      isAchieved: map['isAchieved'] == 1,
      achievedCount: map['achievedCount'],
      lastAchievedDate: map['lastAchievedDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['lastAchievedDate'])
          : null,
    );
  }
}
