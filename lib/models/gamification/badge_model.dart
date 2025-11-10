import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum BadgeCategory { milestone, consistency, achievement, special }

enum BadgeRarity { common, uncommon, rare, epic, legendary }

class BadgeModel {
  final String id;
  final String name;
  final String description;
  final BadgeCategory category;
  final int tier;
  final IconData icon;
  final BadgeRarity rarity;
  final int points;
  final Map<String, dynamic> criteria;
  final bool isActive;

  const BadgeModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.tier,
    required this.icon,
    required this.rarity,
    required this.points,
    required this.criteria,
    this.isActive = true,
  });

  factory BadgeModel.fromMap(Map<String, dynamic> map) {
    return BadgeModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      category: BadgeCategory.values[map['category'] ?? 0],
      tier: map['tier'] ?? 1,
      icon: Icons.star, // Default icon, will be overridden by specific badges
      rarity: BadgeRarity.values[map['rarity'] ?? 0],
      points: map['points'] ?? 0,
      criteria: Map<String, dynamic>.from(map['criteria'] ?? {}),
      isActive: map['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category.index,
      'tier': tier,
      'iconCode': icon.codePoint, // Store icon as code point
      'rarity': rarity.index,
      'points': points,
      'criteria': criteria,
      'isActive': isActive,
    };
  }

  BadgeModel copyWith({
    String? id,
    String? name,
    String? description,
    BadgeCategory? category,
    int? tier,
    IconData? icon,
    BadgeRarity? rarity,
    int? points,
    Map<String, dynamic>? criteria,
    bool? isActive,
  }) {
    return BadgeModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      tier: tier ?? this.tier,
      icon: icon ?? this.icon,
      rarity: rarity ?? this.rarity,
      points: points ?? this.points,
      criteria: criteria ?? this.criteria,
      isActive: isActive ?? this.isActive,
    );
  }
}
