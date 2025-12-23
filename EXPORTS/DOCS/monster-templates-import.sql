-- =====================================================
-- D&D 3.5 SRD CREATURE TEMPLATES - SAMPLE INSERT STATEMENTS
-- =====================================================
-- Schema: pnpo_3_5_dev.monster_templates
-- Source: SRD HTML exports (monsters-*.html)
--
-- IMPORTANT: Creature templates (Skeleton, Zombie, Vampire, etc.) are NOT separate tables.
-- They are TRANSFORMATION RULES applied to base creatures to create new monster_templates.
-- This file documents how to create templated monsters by applying template rules to base creatures.

SET search_path TO pnpo_3_5_dev;

-- =====================================================
-- TEMPLATE OVERVIEW
-- =====================================================
--
-- Creature templates are ACQUIRED TEMPLATES that modify base creatures:
-- - Skeleton: Undead template for creatures with skeletal systems
-- - Zombie: Undead template for corporeal creatures
-- - Vampire: Undead template for humanoids/monstrous humanoids
-- - Lycanthrope: Shapechanger template for humanoids/giants
-- - Half-Dragon: Dragon template for living corporeal creatures
-- - Fiendish: Outsider template from Lower Planes
-- - Celestial: Outsider template from Upper Planes
--
-- Template Application Process:
-- 1. Start with base creature stats
-- 2. Apply template transformation rules (type change, HD change, stat adjustments, etc.)
-- 3. Add template-specific abilities
-- 4. Create new monster_templates entry for the templated creature
-- 5. Link template abilities via monster_template_special_abilities

-- =====================================================
-- SKELETON TEMPLATE
-- =====================================================
-- "Skeleton" is an acquired template that can be added to any corporeal creature
-- (other than an undead) that has a skeletal system.
--
-- Transformation Rules:
-- - Type: Changes to Undead (lose CON, gain undead traits)
-- - Hit Dice: Drop class HD (min 1), raise to d12
-- - Speed: Winged skeletons can't fly (unless magical flight)
-- - AC: Natural armor changes based on size (see table below)
-- - Attacks: Retains natural weapons, gains claw attacks if has hands
-- - Special Qualities: Darkvision 60 ft., immunity to cold, undead traits
-- - Saves: Poor for all (undead progression)
-- - Abilities: STR same, DEX +2, CON —, INT —, WIS +0, CHA +0
-- - Skills: None (mindless)
-- - Feats: None
-- - CR: Depends on HD (see table)
--
-- Natural Armor by Size:
-- | Size              | Natural Armor |
-- |-------------------|---------------|
-- | Tiny or smaller   | +0            |
-- | Small             | +1            |
-- | Medium or Large   | +2            |
-- | Huge              | +3            |
-- | Gargantuan        | +6            |
-- | Colossal          | +10           |
--
-- Challenge Rating by HD:
-- | Hit Dice  | Challenge Rating |
-- |-----------|------------------|
-- | 1/2       | 1/6              |
-- | 1         | 1/3              |
-- | 2-3       | 1                |
-- | 4-5       | 2                |
-- | 6-7       | 3                |
-- | 8-9       | 4                |
-- | 10-11     | 5                |
-- | 12-14     | 6                |
-- | 15-17     | 7                |
-- | 18-20     | 8                |

-- Example 1: HUMAN SKELETON (applying Skeleton template to Human Commoner)
-- Base creature: Human Commoner (1 HD humanoid)
-- Template: Skeleton
-- Result: Human Skeleton (1 HD undead)

INSERT INTO monster_templates (
  name,
  creature_type_id,
  creature_subtype_ids,
  size_category_id,
  hit_dice_count,
  hit_die_size,
  hit_dice_bonus,
  challenge_rating,
  base_strength,
  base_dexterity,
  base_constitution,
  base_intelligence,
  base_wisdom,
  base_charisma,
  natural_armor_bonus,
  land_speed,
  darkvision_range,
  environment,
  organization,
  treasure_type,
  alignment,
  description
) VALUES (
  'Human Skeleton',
  (SELECT id FROM creature_types WHERE name = 'Undead'),
  NULL,
  (SELECT id FROM size_categories WHERE name = 'Medium'),
  1,        -- HD count (dropped class levels)
  12,       -- d12 (skeleton HD)
  0,        -- No CON bonus
  0.33,     -- CR 1/3 for 1 HD skeleton
  13,       -- STR (base human 10 + skeleton adjustment)
  13,       -- DEX (base human 11 + skeleton +2)
  NULL,     -- CON — (undead)
  NULL,     -- INT — (mindless)
  10,       -- WIS (base human 9 + 1)
  1,        -- CHA (undead minimum)
  2,        -- Natural armor (Medium size)
  30,       -- Speed (same as human)
  60,       -- Darkvision
  'Any',
  'Any',
  'none',
  'Always neutral',
  'Skeletons are the animated bones of the dead, mindless automatons that obey the orders of their evil masters.'
);

-- Link skeleton abilities
INSERT INTO monster_template_special_abilities (monster_template_id, special_ability_id, notes)
VALUES
  ((SELECT id FROM monster_templates WHERE name = 'Human Skeleton'), (SELECT id FROM special_abilities WHERE name = 'Darkvision 60 ft.'), NULL),
  ((SELECT id FROM monster_templates WHERE name = 'Human Skeleton'), (SELECT id FROM special_abilities WHERE name = 'Immunity to Cold'), NULL),
  ((SELECT id FROM monster_templates WHERE name = 'Human Skeleton'), (SELECT id FROM special_abilities WHERE name = 'Undead Traits'), NULL);

-- Example 2: WOLF SKELETON (applying Skeleton template to Wolf)
-- Base creature: Wolf (2d8+4 animal, STR 13, DEX 15, CON 15, INT 2, WIS 12, CHA 6)
-- Template: Skeleton
-- Result: Wolf Skeleton (2d12 undead, Medium)

INSERT INTO monster_templates (
  name,
  creature_type_id,
  creature_subtype_ids,
  size_category_id,
  hit_dice_count,
  hit_die_size,
  hit_dice_bonus,
  challenge_rating,
  base_strength,
  base_dexterity,
  base_constitution,
  base_intelligence,
  base_wisdom,
  base_charisma,
  natural_armor_bonus,
  land_speed,
  darkvision_range,
  environment,
  organization,
  treasure_type,
  alignment,
  description
) VALUES (
  'Wolf Skeleton',
  (SELECT id FROM creature_types WHERE name = 'Undead'),
  NULL,
  (SELECT id FROM size_categories WHERE name = 'Medium'),
  2,        -- 2 HD (wolf HD, no class levels to drop)
  12,       -- d12 (skeleton)
  0,        -- No CON
  1.00,     -- CR 1 for 2 HD skeleton
  13,       -- STR (same as wolf)
  17,       -- DEX (wolf 15 + skeleton +2)
  NULL,     -- CON — (undead)
  NULL,     -- INT — (mindless)
  12,       -- WIS (same as wolf)
  1,        -- CHA
  2,        -- Natural armor (Medium)
  50,       -- Speed (same as wolf)
  60,       -- Darkvision
  'Any',
  'Any',
  'none',
  'Always neutral',
  'An animated wolf skeleton, created through necromancy.'
);

INSERT INTO monster_template_special_abilities (monster_template_id, special_ability_id, notes)
VALUES
  ((SELECT id FROM monster_templates WHERE name = 'Wolf Skeleton'), (SELECT id FROM special_abilities WHERE name = 'Darkvision 60 ft.'), NULL),
  ((SELECT id FROM monster_templates WHERE name = 'Wolf Skeleton'), (SELECT id FROM special_abilities WHERE name = 'Immunity to Cold'), NULL),
  ((SELECT id FROM monster_templates WHERE name = 'Wolf Skeleton'), (SELECT id FROM special_abilities WHERE name = 'Undead Traits'), NULL);

-- =====================================================
-- ZOMBIE TEMPLATE
-- =====================================================
-- "Zombie" is an acquired template that can be added to any corporeal creature
-- (other than a construct, elemental, ooze, plant, or undead).
--
-- Transformation Rules:
-- - Type: Changes to Undead (lose CON, gain undead traits)
-- - Hit Dice: Drop class HD (min 1), raise to d12, +3 HP per HD
-- - Speed: Reduce all speeds by 10 feet (min 5 feet), winged zombies can't fly
-- - AC: Natural armor +0 (same as base or 0, whichever is better)
-- - Attacks: Retains natural weapons, gains slam if has hands
-- - Damage: Slam damage by size
-- - Special Qualities: Darkvision 60 ft., single actions only, undead traits
-- - Saves: Poor for all
-- - Abilities: STR +2, DEX –2, CON —, INT —, WIS +0, CHA +0
-- - Skills: None (mindless)
-- - Feats: Toughness
-- - CR: Depends on HD (see table)
--
-- Challenge Rating by HD:
-- | Hit Dice  | Challenge Rating |
-- |-----------|------------------|
-- | 1/2       | 1/4              |
-- | 1         | 1/2              |
-- | 2-3       | 1                |
-- | 4-5       | 2                |
-- | 6-7       | 3                |
-- | 8-9       | 4                |
-- | 10-11     | 5                |
-- | 12-14     | 6                |

-- Example 3: HUMAN COMMONER ZOMBIE (applying Zombie template to Human Commoner)
INSERT INTO monster_templates (
  name,
  creature_type_id,
  creature_subtype_ids,
  size_category_id,
  hit_dice_count,
  hit_die_size,
  hit_dice_bonus,
  challenge_rating,
  base_strength,
  base_dexterity,
  base_constitution,
  base_intelligence,
  base_wisdom,
  base_charisma,
  natural_armor_bonus,
  land_speed,
  darkvision_range,
  environment,
  organization,
  treasure_type,
  alignment,
  description
) VALUES (
  'Human Commoner Zombie',
  (SELECT id FROM creature_types WHERE name = 'Undead'),
  NULL,
  (SELECT id FROM size_categories WHERE name = 'Medium'),
  1,        -- 1 HD (dropped class levels)
  12,       -- d12
  3,        -- +3 HP per zombie HD
  0.50,     -- CR 1/2 for 1 HD zombie
  12,       -- STR (human 10 + zombie +2)
  9,        -- DEX (human 11 + zombie -2)
  NULL,     -- CON — (undead)
  NULL,     -- INT — (mindless)
  10,       -- WIS
  1,        -- CHA
  0,        -- Natural armor (zombie has none)
  20,       -- Speed (human 30 - 10)
  60,       -- Darkvision
  'Any',
  'Any',
  'none',
  'Always neutral evil',
  'A shambling undead corpse, animated through necromancy. Zombies move slowly and can only perform a single action each round.'
);

-- Create zombie-specific ability
INSERT INTO special_abilities (name, ability_type, is_active, activation_type, description, source_category)
VALUES
  ('Single Actions Only', 'extraordinary', false, 'passive', 'Can only perform a single move action or standard action each round (not both), and cannot take full-round actions. Can still take free actions and swift actions.', 'general')
ON CONFLICT (name) DO NOTHING;

INSERT INTO monster_template_special_abilities (monster_template_id, special_ability_id, notes)
VALUES
  ((SELECT id FROM monster_templates WHERE name = 'Human Commoner Zombie'), (SELECT id FROM special_abilities WHERE name = 'Darkvision 60 ft.'), NULL),
  ((SELECT id FROM monster_templates WHERE name = 'Human Commoner Zombie'), (SELECT id FROM special_abilities WHERE name = 'Single Actions Only'), NULL),
  ((SELECT id FROM monster_templates WHERE name = 'Human Commoner Zombie'), (SELECT id FROM special_abilities WHERE name = 'Undead Traits'), NULL);

-- Link Toughness feat
-- INSERT INTO monster_template_feats (monster_template_id, feat_id, is_bonus_feat, notes)
-- VALUES
--   ((SELECT id FROM monster_templates WHERE name = 'Human Commoner Zombie'), (SELECT id FROM feats WHERE name = 'Toughness'), true, 'Zombie bonus feat');

-- =====================================================
-- VAMPIRE TEMPLATE (SPAWN)
-- =====================================================
-- "Vampire Spawn" is a lesser vampire template
--
-- Transformation Rules:
-- - Type: Changes to Undead (retains humanoid/monstrous humanoid as subtype)
-- - Hit Dice: Change to d12, keep all HD
-- - Speed: Same as base creature
-- - AC: Natural armor improves by +6
-- - Attacks: Retains all attacks, gains slam
-- - Special Attacks: Blood drain, domination, energy drain
-- - Special Qualities: DR 5/silver, fast healing 2, gaseous form, resistance 10 to cold/electricity, spider climb, +4 turn resistance, darkvision, undead traits
-- - Saves: Good for all (undead with good saves)
-- - Abilities: STR +4, DEX +4, CON —, INT same, WIS +2, CHA +2
-- - Skills: Bonus to Bluff, Hide, Listen, Move Silently, Search, Sense Motive, Spot
-- - Feats: Bonus feats (Alertness, Improved Initiative, Lightning Reflexes)
-- - CR: Base creature +2

-- Example 4: VAMPIRE SPAWN (applying Vampire Spawn template to Human Warrior)
INSERT INTO monster_templates (
  name,
  creature_type_id,
  creature_subtype_ids,
  size_category_id,
  hit_dice_count,
  hit_die_size,
  hit_dice_bonus,
  challenge_rating,
  base_strength,
  base_dexterity,
  base_constitution,
  base_intelligence,
  base_wisdom,
  base_charisma,
  natural_armor_bonus,
  land_speed,
  climb_speed,
  darkvision_range,
  spell_resistance,
  environment,
  organization,
  treasure_type,
  alignment,
  description
) VALUES (
  'Vampire Spawn',
  (SELECT id FROM creature_types WHERE name = 'Undead'),
  ARRAY[(SELECT id FROM creature_subtypes WHERE name = 'Augmented Humanoid')],
  (SELECT id FROM size_categories WHERE name = 'Medium'),
  4,        -- 4 HD (warrior levels)
  12,       -- d12 (undead)
  0,        -- No CON
  4.00,     -- CR (base 2 + template +2)
  17,       -- STR (human 13 + vampire +4)
  17,       -- DEX (human 13 + vampire +4)
  NULL,     -- CON — (undead)
  10,       -- INT (same)
  13,       -- WIS (human 11 + vampire +2)
  14,       -- CHA (human 12 + vampire +2)
  6,        -- Natural armor (human 0 + vampire +6)
  30,       -- Speed
  20,       -- Spider climb
  60,       -- Darkvision
  NULL,     -- No SR
  'Any',
  'Solitary or pack (2–5)',
  'standard',
  'Always chaotic evil',
  'Vampire spawn are undead creatures that serve a vampire master. They are created when a vampire slays a humanoid by draining blood and the victim rises as undead. Vampire spawn are weaker than true vampires but still formidable foes.'
);

-- Create vampire spawn abilities
INSERT INTO special_abilities (name, ability_type, is_active, activation_type, description, source_category)
VALUES
  ('Blood Drain', 'extraordinary', true, 'standard', 'Can suck blood from a grappled victim, dealing 1d4 points of Constitution drain each round.', 'general'),
  ('Dominate', 'supernatural', true, 'standard', 'Can crush opponent''s will (gaze attack). Will save DC = 10 + 1/2 vampire''s HD + vampire''s CHA modifier negates.', 'general'),
  ('Energy Drain', 'supernatural', false, 'passive', 'Living creatures hit by slam attack gain two negative levels.', 'general'),
  ('Fast Healing 2', 'extraordinary', false, 'passive', 'Heals 2 hit points per round. Cannot heal from fire or sunlight damage.', 'general'),
  ('Gaseous Form', 'supernatural', true, 'standard', 'Can assume gaseous form at will as the spell (caster level 5th).', 'general'),
  ('Spider Climb', 'extraordinary', false, 'passive', 'Can climb sheer surfaces as though using spider climb spell.', 'general'),
  ('Turn Resistance +2', 'extraordinary', false, 'passive', '+2 bonus on turning resistance checks.', 'general'),
  ('Damage Reduction 5/silver', 'extraordinary', false, 'passive', 'DR 5/silver - ignores first 5 points of damage unless from silver weapons.', 'general'),
  ('Resistance to Cold 10', 'extraordinary', false, 'passive', 'Ignores first 10 points of cold damage from any source.', 'general'),
  ('Resistance to Electricity 10', 'extraordinary', false, 'passive', 'Ignores first 10 points of electricity damage from any source.', 'general')
ON CONFLICT (name) DO NOTHING;

INSERT INTO monster_template_special_abilities (monster_template_id, special_ability_id, notes)
VALUES
  ((SELECT id FROM monster_templates WHERE name = 'Vampire Spawn'), (SELECT id FROM special_abilities WHERE name = 'Blood Drain'), NULL),
  ((SELECT id FROM monster_templates WHERE name = 'Vampire Spawn'), (SELECT id FROM special_abilities WHERE name = 'Dominate'), NULL),
  ((SELECT id FROM monster_templates WHERE name = 'Vampire Spawn'), (SELECT id FROM special_abilities WHERE name = 'Energy Drain'), NULL),
  ((SELECT id FROM monster_templates WHERE name = 'Vampire Spawn'), (SELECT id FROM special_abilities WHERE name = 'Fast Healing 2'), NULL),
  ((SELECT id FROM monster_templates WHERE name = 'Vampire Spawn'), (SELECT id FROM special_abilities WHERE name = 'Gaseous Form'), NULL),
  ((SELECT id FROM monster_templates WHERE name = 'Vampire Spawn'), (SELECT id FROM special_abilities WHERE name = 'Spider Climb'), NULL),
  ((SELECT id FROM monster_templates WHERE name = 'Vampire Spawn'), (SELECT id FROM special_abilities WHERE name = 'Turn Resistance +2'), NULL),
  ((SELECT id FROM monster_templates WHERE name = 'Vampire Spawn'), (SELECT id FROM special_abilities WHERE name = 'Damage Reduction 5/silver'), NULL),
  ((SELECT id FROM monster_templates WHERE name = 'Vampire Spawn'), (SELECT id FROM special_abilities WHERE name = 'Resistance to Cold 10'), NULL),
  ((SELECT id FROM monster_templates WHERE name = 'Vampire Spawn'), (SELECT id FROM special_abilities WHERE name = 'Resistance to Electricity 10'), NULL),
  ((SELECT id FROM monster_templates WHERE name = 'Vampire Spawn'), (SELECT id FROM special_abilities WHERE name = 'Undead Traits'), NULL);

-- =====================================================
-- CELESTIAL TEMPLATE
-- =====================================================
-- "Celestial" template for creatures from the Upper Planes
-- Typically applied via summon monster spells
--
-- Transformation Rules:
-- - Type: Add "extraplanar" subtype when on Material Plane
-- - Special Attacks: Smite evil 1/day
-- - Special Qualities: Darkvision 60 ft., DR (varies by HD), resistance to acid/cold/electricity (varies by HD), SR (varies by HD)
-- - Abilities: +4 to one ability score (typically STR or WIS)
-- - CR: Base creature +0 or +1 depending on HD

-- Example 5: CELESTIAL DOG (applying Celestial template to Riding Dog)
INSERT INTO monster_templates (
  name,
  creature_type_id,
  creature_subtype_ids,
  size_category_id,
  hit_dice_count,
  hit_die_size,
  hit_dice_bonus,
  challenge_rating,
  base_strength,
  base_dexterity,
  base_constitution,
  base_intelligence,
  base_wisdom,
  base_charisma,
  natural_armor_bonus,
  land_speed,
  darkvision_range,
  scent,
  spell_resistance,
  environment,
  organization,
  treasure_type,
  alignment,
  description
) VALUES (
  'Celestial Riding Dog',
  (SELECT id FROM creature_types WHERE name = 'Magical Beast'),
  ARRAY[(SELECT id FROM creature_subtypes WHERE name = 'Extraplanar')],
  (SELECT id FROM size_categories WHERE name = 'Medium'),
  2,        -- 2 HD
  8,        -- d8 (animal/magical beast)
  4,        -- CON bonus
  1.00,     -- CR 1 (base 1 + template +0 for low HD)
  17,       -- STR (dog 15 + celestial +2)
  15,       -- DEX
  15,       -- CON
  2,        -- INT
  16,       -- WIS (dog 12 + celestial +4)
  6,        -- CHA
  2,        -- Natural armor
  40,       -- Speed
  60,       -- Darkvision
  true,     -- Scent
  7,        -- SR (5 + HD for HD 1-4)
  'Upper Planes',
  'Solitary or pack (2–5)',
  'none',
  'Always good',
  'A celestial riding dog is a good-aligned magical beast from the Upper Planes, often summoned to serve good-aligned spellcasters.'
);

-- Create celestial abilities
INSERT INTO special_abilities (name, ability_type, is_active, activation_type, description, source_category)
VALUES
  ('Smite Evil 1/day', 'supernatural', true, 'swift', 'Once per day, can add CHA bonus to attack roll and HD to damage against evil foe.', 'general'),
  ('Resistance to Acid 5', 'extraordinary', false, 'passive', 'Ignores first 5 points of acid damage from any source.', 'general'),
  ('Resistance to Cold 5', 'extraordinary', false, 'passive', 'Ignores first 5 points of cold damage from any source.', 'general'),
  ('Resistance to Electricity 5', 'extraordinary', false, 'passive', 'Ignores first 5 points of electricity damage from any source.', 'general')
ON CONFLICT (name) DO NOTHING;

INSERT INTO monster_template_special_abilities (monster_template_id, special_ability_id, notes)
VALUES
  ((SELECT id FROM monster_templates WHERE name = 'Celestial Riding Dog'), (SELECT id FROM special_abilities WHERE name = 'Darkvision 60 ft.'), NULL),
  ((SELECT id FROM monster_templates WHERE name = 'Celestial Riding Dog'), (SELECT id FROM special_abilities WHERE name = 'Smite Evil 1/day'), NULL),
  ((SELECT id FROM monster_templates WHERE name = 'Celestial Riding Dog'), (SELECT id FROM special_abilities WHERE name = 'Resistance to Acid 5'), NULL),
  ((SELECT id FROM monster_templates WHERE name = 'Celestial Riding Dog'), (SELECT id FROM special_abilities WHERE name = 'Resistance to Cold 5'), NULL),
  ((SELECT id FROM monster_templates WHERE name = 'Celestial Riding Dog'), (SELECT id FROM special_abilities WHERE name = 'Resistance to Electricity 5'), NULL),
  ((SELECT id FROM monster_templates WHERE name = 'Celestial Riding Dog'), (SELECT id FROM special_abilities WHERE name = 'Scent'), NULL);

-- =====================================================
-- TEMPLATE APPLICATION GUIDELINES
-- =====================================================
--
-- When creating a templated monster:
--
-- 1. READ THE TEMPLATE RULES from SRD (Creating a [Template] section)
-- 2. START WITH BASE CREATURE stats
-- 3. APPLY TYPE CHANGE (Undead, Outsider, etc.)
-- 4. ADJUST HIT DICE (d12 for undead, keep for others)
-- 5. MODIFY ABILITY SCORES per template rules
-- 6. ADJUST NATURAL ARMOR per template rules
-- 7. MODIFY SPEEDS per template rules
-- 8. ADD TEMPLATE SPECIAL ABILITIES via junction table
-- 9. REMOVE INCOMPATIBLE ABILITIES (flight for wingless skeletons, etc.)
-- 10. CALCULATE NEW CR per template rules
-- 11. UPDATE ALIGNMENT if template specifies
-- 12. ADD TEMPLATE-SPECIFIC FEATS/SKILLS if any
--
-- Common Template Types:
-- - Undead Templates: Skeleton, Zombie, Vampire, Lich, Ghost, Wraith, Wight
-- - Planar Templates: Celestial, Fiendish, Half-Celestial, Half-Fiendish, Half-Dragon
-- - Lycanthrope Templates: Werewolf, Wererat, Wereboar, Weretiger, Werebear
-- - Other Templates: Paragon, Advanced, Young, Juvenile
--
-- =====================================================
-- QUERY EXAMPLES
-- =====================================================

-- Find all templated monsters (by naming convention):
-- SELECT name, challenge_rating
-- FROM monster_templates
-- WHERE name LIKE '% Skeleton'
--    OR name LIKE '% Zombie'
--    OR name LIKE 'Vampire %'
--    OR name LIKE 'Celestial %'
--    OR name LIKE 'Fiendish %'
-- ORDER BY challenge_rating;

-- Compare base creature to templated version:
-- SELECT
--   mt.name,
--   ct.name AS type,
--   mt.hit_dice_count || 'd' || mt.hit_die_size AS hit_dice,
--   mt.base_strength,
--   mt.base_dexterity,
--   mt.base_constitution,
--   mt.challenge_rating,
--   STRING_AGG(sa.name, ', ') AS abilities
-- FROM monster_templates mt
-- JOIN creature_types ct ON mt.creature_type_id = ct.id
-- LEFT JOIN monster_template_special_abilities mtsa ON mt.id = mtsa.monster_template_id
-- LEFT JOIN special_abilities sa ON mtsa.special_ability_id = sa.id
-- WHERE mt.name IN ('Wolf', 'Wolf Skeleton')
-- GROUP BY mt.id, ct.name
-- ORDER BY mt.name;

-- =====================================================
-- NOTES ON TEMPLATE PATTERNS
-- =====================================================
--
-- UNDEAD TEMPLATES:
-- - Always set base_constitution = NULL
-- - Always set base_intelligence = NULL for mindless (Skeleton, Zombie)
-- - Always change hit_die_size to 12
-- - Always add Undead Traits ability
-- - Always add Darkvision 60 ft.
-- - Update creature_type_id to Undead
--
-- PLANAR TEMPLATES:
-- - Add appropriate subtype (Extraplanar when not on native plane)
-- - Add energy resistances (varies by HD)
-- - Add spell resistance (varies by HD)
-- - Add smite ability (Celestial = smite evil, Fiendish = smite good)
-- - Increase one ability score by +4
--
-- LYCANTHROPE TEMPLATES:
-- - Add shapechanger subtype
-- - Add alternate forms (animal, hybrid, humanoid)
-- - Add DR/silver
-- - Add lycanthropy curse transmission
-- - Increase STR, DEX, CON in animal/hybrid forms
--
-- IMPORT STRATEGY:
-- 1. Create all special_abilities for template-specific powers
-- 2. For each base creature you want to template:
--    a. Read base creature stats
--    b. Apply template transformation rules
--    c. Create new monster_templates entry
--    d. Link abilities via monster_template_special_abilities
--    e. Link feats via monster_template_feats (if any)
--    f. Create DR entries via creature_dr (if applicable)
-- 3. Document which template was applied in description field
--
-- =====================================================
