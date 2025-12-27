-- =====================================================
-- WEAPON IMPORTS FOR D&D 3.5 SRD
-- =====================================================
-- Complete integration pattern demonstration
-- Source: equipment.html from SRD 3.5
--
-- Data Flow: weapon_types → effects → damage_effects → damage_effect_types → weapon_damage
-- =====================================================

SET search_path TO pnpo_3_5_dev;

-- =====================================================
-- WEAPON 1: DAGGER
-- Simple Light Melee/Thrown
-- Damage (Small): 1d3 piercing or slashing
-- Damage (Medium): 1d4 piercing or slashing
-- Critical: 19-20/x2
-- Range: 10 ft, Cost: 2 gp, Weight: 1 lb
-- =====================================================

-- Step 1: Insert weapon type
INSERT INTO weapon_types (name, weapon_category_id, is_melee, is_ranged, is_thrown, hands_required, cost_cp, weight_lb, range_increment_ft)
VALUES ('Dagger', (SELECT id FROM weapon_categories WHERE name = 'Simple'), true, true, true, 1, 200, 1.0, 10);

-- Step 2-4: Create damage effects for Small size (piercing and slashing options)
INSERT INTO effects (name, effect_type, is_beneficial, is_magical, description) VALUES
  ('Dagger damage (Small, piercing)', 'damage', false, false, 'Small dagger piercing damage'),
  ('Dagger damage (Small, slashing)', 'damage', false, false, 'Small dagger slashing damage');

INSERT INTO damage_effects (effect_id, number_of_dice, die_size, allows_save, multiplied_on_crit) VALUES
  ((SELECT id FROM effects WHERE name = 'Dagger damage (Small, piercing)'), 1, 3, false, true),
  ((SELECT id FROM effects WHERE name = 'Dagger damage (Small, slashing)'), 1, 3, false, true);

INSERT INTO damage_effect_types (damage_effect_id, damage_type_id, is_alternative) VALUES
  ((SELECT de.id FROM damage_effects de JOIN effects e ON de.effect_id = e.id WHERE e.name = 'Dagger damage (Small, piercing)'), (SELECT id FROM damage_types WHERE name = 'Piercing'), false),
  ((SELECT de.id FROM damage_effects de JOIN effects e ON de.effect_id = e.id WHERE e.name = 'Dagger damage (Small, slashing)'), (SELECT id FROM damage_types WHERE name = 'Slashing'), false);

-- Step 5: Create damage effects for Medium size
INSERT INTO effects (name, effect_type, is_beneficial, is_magical, description) VALUES
  ('Dagger damage (Medium, piercing)', 'damage', false, false, 'Medium dagger piercing damage'),
  ('Dagger damage (Medium, slashing)', 'damage', false, false, 'Medium dagger slashing damage');

INSERT INTO damage_effects (effect_id, number_of_dice, die_size, allows_save, multiplied_on_crit) VALUES
  ((SELECT id FROM effects WHERE name = 'Dagger damage (Medium, piercing)'), 1, 4, false, true),
  ((SELECT id FROM effects WHERE name = 'Dagger damage (Medium, slashing)'), 1, 4, false, true);

INSERT INTO damage_effect_types (damage_effect_id, damage_type_id, is_alternative) VALUES
  ((SELECT de.id FROM damage_effects de JOIN effects e ON de.effect_id = e.id WHERE e.name = 'Dagger damage (Medium, piercing)'), (SELECT id FROM damage_types WHERE name = 'Piercing'), false),
  ((SELECT de.id FROM damage_effects de JOIN effects e ON de.effect_id = e.id WHERE e.name = 'Dagger damage (Medium, slashing)'), (SELECT id FROM damage_types WHERE name = 'Slashing'), false);

-- Step 6: Link weapon to damage effects via junction table
INSERT INTO weapon_damage (weapon_type_id, size_category_id, damage_effect_id, is_two_handed) VALUES
  ((SELECT id FROM weapon_types WHERE name = 'Dagger'), (SELECT id FROM size_categories WHERE name = 'Small'), (SELECT id FROM effects WHERE name = 'Dagger damage (Small, piercing)'), false),
  ((SELECT id FROM weapon_types WHERE name = 'Dagger'), (SELECT id FROM size_categories WHERE name = 'Small'), (SELECT id FROM effects WHERE name = 'Dagger damage (Small, slashing)'), false),
  ((SELECT id FROM weapon_types WHERE name = 'Dagger'), (SELECT id FROM size_categories WHERE name = 'Medium'), (SELECT id FROM effects WHERE name = 'Dagger damage (Medium, piercing)'), false),
  ((SELECT id FROM weapon_types WHERE name = 'Dagger'), (SELECT id FROM size_categories WHERE name = 'Medium'), (SELECT id FROM effects WHERE name = 'Dagger damage (Medium, slashing)'), false);

-- Step 7: Critical properties
INSERT INTO effects (name, effect_type, is_beneficial, is_magical, description) VALUES ('Dagger critical properties', 'attack_property', true, false, 'Threatens 19-20, x2 multiplier');
INSERT INTO attack_property_effects (effect_id, critical_roll_min, critical_multiplier) VALUES ((SELECT id FROM effects WHERE name = 'Dagger critical properties'), 19, 2);

-- =====================================================
-- WEAPON 2: LONGSWORD
-- Martial One-Handed Melee
-- Damage (Small): 1d6 slashing
-- Damage (Medium): 1d8 slashing / 1d10 slashing (two-handed)
-- Critical: 19-20/x2
-- Cost: 15 gp, Weight: 4 lb
-- =====================================================

INSERT INTO weapon_types (name, weapon_category_id, is_melee, is_ranged, is_thrown, hands_required, cost_cp, weight_lb, range_increment_ft)
VALUES ('Longsword', (SELECT id FROM weapon_categories WHERE name = 'Martial'), true, false, false, 1, 1500, 4.0, NULL);

INSERT INTO effects (name, effect_type, is_beneficial, is_magical, description) VALUES
  ('Longsword damage (Small)', 'damage', false, false, 'Small longsword slashing'),
  ('Longsword damage (Medium)', 'damage', false, false, 'Medium longsword slashing one-handed'),
  ('Longsword damage (Medium, two-handed)', 'damage', false, false, 'Medium longsword slashing two-handed');

INSERT INTO damage_effects (effect_id, number_of_dice, die_size, allows_save, multiplied_on_crit) VALUES
  ((SELECT id FROM effects WHERE name = 'Longsword damage (Small)'), 1, 6, false, true),
  ((SELECT id FROM effects WHERE name = 'Longsword damage (Medium)'), 1, 8, false, true),
  ((SELECT id FROM effects WHERE name = 'Longsword damage (Medium, two-handed)'), 1, 10, false, true);

INSERT INTO damage_effect_types (damage_effect_id, damage_type_id, is_alternative) VALUES
  ((SELECT de.id FROM damage_effects de JOIN effects e ON de.effect_id = e.id WHERE e.name = 'Longsword damage (Small)'), (SELECT id FROM damage_types WHERE name = 'Slashing'), false),
  ((SELECT de.id FROM damage_effects de JOIN effects e ON de.effect_id = e.id WHERE e.name = 'Longsword damage (Medium)'), (SELECT id FROM damage_types WHERE name = 'Slashing'), false),
  ((SELECT de.id FROM damage_effects de JOIN effects e ON de.effect_id = e.id WHERE e.name = 'Longsword damage (Medium, two-handed)'), (SELECT id FROM damage_types WHERE name = 'Slashing'), false);

INSERT INTO weapon_damage (weapon_type_id, size_category_id, damage_effect_id, is_two_handed) VALUES
  ((SELECT id FROM weapon_types WHERE name = 'Longsword'), (SELECT id FROM size_categories WHERE name = 'Small'), (SELECT id FROM effects WHERE name = 'Longsword damage (Small)'), false),
  ((SELECT id FROM weapon_types WHERE name = 'Longsword'), (SELECT id FROM size_categories WHERE name = 'Medium'), (SELECT id FROM effects WHERE name = 'Longsword damage (Medium)'), false),
  ((SELECT id FROM weapon_types WHERE name = 'Longsword'), (SELECT id FROM size_categories WHERE name = 'Medium'), (SELECT id FROM effects WHERE name = 'Longsword damage (Medium, two-handed)'), true);

INSERT INTO effects (name, effect_type, is_beneficial, is_magical, description) VALUES ('Longsword critical properties', 'attack_property', true, false, 'Threatens 19-20, x2 multiplier');
INSERT INTO attack_property_effects (effect_id, critical_roll_min, critical_multiplier) VALUES ((SELECT id FROM effects WHERE name = 'Longsword critical properties'), 19, 2);

-- =====================================================
-- WEAPON 3: GREATSWORD
-- Martial Two-Handed Melee
-- Damage (Small): 1d10 slashing
-- Damage (Medium): 2d6 slashing
-- Critical: 19-20/x2
-- Cost: 50 gp, Weight: 8 lb
-- =====================================================

INSERT INTO weapon_types (name, weapon_category_id, is_melee, is_ranged, is_thrown, hands_required, cost_cp, weight_lb, range_increment_ft)
VALUES ('Greatsword', (SELECT id FROM weapon_categories WHERE name = 'Martial'), true, false, false, 2, 5000, 8.0, NULL);

INSERT INTO effects (name, effect_type, is_beneficial, is_magical, description) VALUES
  ('Greatsword damage (Small)', 'damage', false, false, 'Small greatsword slashing'),
  ('Greatsword damage (Medium)', 'damage', false, false, 'Medium greatsword slashing');

INSERT INTO damage_effects (effect_id, number_of_dice, die_size, allows_save, multiplied_on_crit) VALUES
  ((SELECT id FROM effects WHERE name = 'Greatsword damage (Small)'), 1, 10, false, true),
  ((SELECT id FROM effects WHERE name = 'Greatsword damage (Medium)'), 2, 6, false, true);

INSERT INTO damage_effect_types (damage_effect_id, damage_type_id, is_alternative) VALUES
  ((SELECT de.id FROM damage_effects de JOIN effects e ON de.effect_id = e.id WHERE e.name = 'Greatsword damage (Small)'), (SELECT id FROM damage_types WHERE name = 'Slashing'), false),
  ((SELECT de.id FROM damage_effects de JOIN effects e ON de.effect_id = e.id WHERE e.name = 'Greatsword damage (Medium)'), (SELECT id FROM damage_types WHERE name = 'Slashing'), false);

INSERT INTO weapon_damage (weapon_type_id, size_category_id, damage_effect_id, is_two_handed) VALUES
  ((SELECT id FROM weapon_types WHERE name = 'Greatsword'), (SELECT id FROM size_categories WHERE name = 'Small'), (SELECT id FROM effects WHERE name = 'Greatsword damage (Small)'), false),
  ((SELECT id FROM weapon_types WHERE name = 'Greatsword'), (SELECT id FROM size_categories WHERE name = 'Medium'), (SELECT id FROM effects WHERE name = 'Greatsword damage (Medium)'), false);

INSERT INTO effects (name, effect_type, is_beneficial, is_magical, description) VALUES ('Greatsword critical properties', 'attack_property', true, false, 'Threatens 19-20, x2 multiplier');
INSERT INTO attack_property_effects (effect_id, critical_roll_min, critical_multiplier) VALUES ((SELECT id FROM effects WHERE name = 'Greatsword critical properties'), 19, 2);

-- =====================================================
-- WEAPON 4: BATTLEAXE
-- Martial One-Handed Melee
-- Damage (Small): 1d6 slashing
-- Damage (Medium): 1d8 slashing
-- Critical: x3
-- Cost: 10 gp, Weight: 6 lb
-- =====================================================

INSERT INTO weapon_types (name, weapon_category_id, is_melee, is_ranged, is_thrown, hands_required, cost_cp, weight_lb, range_increment_ft)
VALUES ('Battleaxe', (SELECT id FROM weapon_categories WHERE name = 'Martial'), true, false, false, 1, 1000, 6.0, NULL);

INSERT INTO effects (name, effect_type, is_beneficial, is_magical, description) VALUES
  ('Battleaxe damage (Small)', 'damage', false, false, 'Small battleaxe slashing'),
  ('Battleaxe damage (Medium)', 'damage', false, false, 'Medium battleaxe slashing');

INSERT INTO damage_effects (effect_id, number_of_dice, die_size, allows_save, multiplied_on_crit) VALUES
  ((SELECT id FROM effects WHERE name = 'Battleaxe damage (Small)'), 1, 6, false, true),
  ((SELECT id FROM effects WHERE name = 'Battleaxe damage (Medium)'), 1, 8, false, true);

INSERT INTO damage_effect_types (damage_effect_id, damage_type_id, is_alternative) VALUES
  ((SELECT de.id FROM damage_effects de JOIN effects e ON de.effect_id = e.id WHERE e.name = 'Battleaxe damage (Small)'), (SELECT id FROM damage_types WHERE name = 'Slashing'), false),
  ((SELECT de.id FROM damage_effects de JOIN effects e ON de.effect_id = e.id WHERE e.name = 'Battleaxe damage (Medium)'), (SELECT id FROM damage_types WHERE name = 'Slashing'), false);

INSERT INTO weapon_damage (weapon_type_id, size_category_id, damage_effect_id, is_two_handed) VALUES
  ((SELECT id FROM weapon_types WHERE name = 'Battleaxe'), (SELECT id FROM size_categories WHERE name = 'Small'), (SELECT id FROM effects WHERE name = 'Battleaxe damage (Small)'), false),
  ((SELECT id FROM weapon_types WHERE name = 'Battleaxe'), (SELECT id FROM size_categories WHERE name = 'Medium'), (SELECT id FROM effects WHERE name = 'Battleaxe damage (Medium)'), false);

INSERT INTO effects (name, effect_type, is_beneficial, is_magical, description) VALUES ('Battleaxe critical properties', 'attack_property', true, false, 'Threatens 20, x3 multiplier');
INSERT INTO attack_property_effects (effect_id, critical_roll_min, critical_multiplier) VALUES ((SELECT id FROM effects WHERE name = 'Battleaxe critical properties'), 20, 3);

-- =====================================================
-- WEAPON 5: RAPIER
-- Martial One-Handed Melee
-- Damage (Small): 1d4 piercing
-- Damage (Medium): 1d6 piercing
-- Critical: 18-20/x2
-- Cost: 20 gp, Weight: 2 lb
-- Special: Weapon Finesse compatible
-- =====================================================

INSERT INTO weapon_types (name, weapon_category_id, is_melee, is_ranged, is_thrown, hands_required, cost_cp, weight_lb, range_increment_ft)
VALUES ('Rapier', (SELECT id FROM weapon_categories WHERE name = 'Martial'), true, false, false, 1, 2000, 2.0, NULL);

INSERT INTO effects (name, effect_type, is_beneficial, is_magical, description) VALUES
  ('Rapier damage (Small)', 'damage', false, false, 'Small rapier piercing'),
  ('Rapier damage (Medium)', 'damage', false, false, 'Medium rapier piercing');

INSERT INTO damage_effects (effect_id, number_of_dice, die_size, allows_save, multiplied_on_crit) VALUES
  ((SELECT id FROM effects WHERE name = 'Rapier damage (Small)'), 1, 4, false, true),
  ((SELECT id FROM effects WHERE name = 'Rapier damage (Medium)'), 1, 6, false, true);

INSERT INTO damage_effect_types (damage_effect_id, damage_type_id, is_alternative) VALUES
  ((SELECT de.id FROM damage_effects de JOIN effects e ON de.effect_id = e.id WHERE e.name = 'Rapier damage (Small)'), (SELECT id FROM damage_types WHERE name = 'Piercing'), false),
  ((SELECT de.id FROM damage_effects de JOIN effects e ON de.effect_id = e.id WHERE e.name = 'Rapier damage (Medium)'), (SELECT id FROM damage_types WHERE name = 'Piercing'), false);

INSERT INTO weapon_damage (weapon_type_id, size_category_id, damage_effect_id, is_two_handed) VALUES
  ((SELECT id FROM weapon_types WHERE name = 'Rapier'), (SELECT id FROM size_categories WHERE name = 'Small'), (SELECT id FROM effects WHERE name = 'Rapier damage (Small)'), false),
  ((SELECT id FROM weapon_types WHERE name = 'Rapier'), (SELECT id FROM size_categories WHERE name = 'Medium'), (SELECT id FROM effects WHERE name = 'Rapier damage (Medium)'), false);

INSERT INTO effects (name, effect_type, is_beneficial, is_magical, description) VALUES ('Rapier critical properties', 'attack_property', true, false, 'Threatens 18-20, x2 multiplier');
INSERT INTO attack_property_effects (effect_id, critical_roll_min, critical_multiplier) VALUES ((SELECT id FROM effects WHERE name = 'Rapier critical properties'), 18, 2);

-- =====================================================
-- WEAPON 6: SHORTBOW
-- Martial Ranged Two-Handed
-- Damage (Small): 1d4 piercing
-- Damage (Medium): 1d6 piercing
-- Critical: x3
-- Range: 60 ft, Cost: 30 gp, Weight: 2 lb
-- =====================================================

INSERT INTO weapon_types (name, weapon_category_id, is_melee, is_ranged, is_thrown, hands_required, cost_cp, weight_lb, range_increment_ft)
VALUES ('Shortbow', (SELECT id FROM weapon_categories WHERE name = 'Martial'), false, true, false, 2, 3000, 2.0, 60);

INSERT INTO effects (name, effect_type, is_beneficial, is_magical, description) VALUES
  ('Shortbow damage (Small)', 'damage', false, false, 'Small shortbow piercing'),
  ('Shortbow damage (Medium)', 'damage', false, false, 'Medium shortbow piercing');

INSERT INTO damage_effects (effect_id, number_of_dice, die_size, allows_save, multiplied_on_crit) VALUES
  ((SELECT id FROM effects WHERE name = 'Shortbow damage (Small)'), 1, 4, false, true),
  ((SELECT id FROM effects WHERE name = 'Shortbow damage (Medium)'), 1, 6, false, true);

INSERT INTO damage_effect_types (damage_effect_id, damage_type_id, is_alternative) VALUES
  ((SELECT de.id FROM damage_effects de JOIN effects e ON de.effect_id = e.id WHERE e.name = 'Shortbow damage (Small)'), (SELECT id FROM damage_types WHERE name = 'Piercing'), false),
  ((SELECT de.id FROM damage_effects de JOIN effects e ON de.effect_id = e.id WHERE e.name = 'Shortbow damage (Medium)'), (SELECT id FROM damage_types WHERE name = 'Piercing'), false);

INSERT INTO weapon_damage (weapon_type_id, size_category_id, damage_effect_id, is_two_handed) VALUES
  ((SELECT id FROM weapon_types WHERE name = 'Shortbow'), (SELECT id FROM size_categories WHERE name = 'Small'), (SELECT id FROM effects WHERE name = 'Shortbow damage (Small)'), false),
  ((SELECT id FROM weapon_types WHERE name = 'Shortbow'), (SELECT id FROM size_categories WHERE name = 'Medium'), (SELECT id FROM effects WHERE name = 'Shortbow damage (Medium)'), false);

INSERT INTO effects (name, effect_type, is_beneficial, is_magical, description) VALUES ('Shortbow critical properties', 'attack_property', true, false, 'Threatens 20, x3 multiplier');
INSERT INTO attack_property_effects (effect_id, critical_roll_min, critical_multiplier) VALUES ((SELECT id FROM effects WHERE name = 'Shortbow critical properties'), 20, 3);

-- =====================================================
-- END OF WEAPON IMPORTS
-- =====================================================
-- Integration patterns demonstrated:
-- 1. Multiple damage types (Dagger: piercing OR slashing choice)
-- 2. Size scaling (Small vs Medium for all weapons)
-- 3. Two-handed wielding (Longsword 1d8 → 1d10)
-- 4. Critical properties via attack_property_effects
-- 5. Ranged weapons with range_increment_ft
-- 6. Thrown weapons with is_thrown flag
-- =====================================================
