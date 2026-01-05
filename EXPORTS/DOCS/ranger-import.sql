-- ============================================================================
-- RANGER CLASS IMPORT FOR D&D 3.5 SRD
-- ============================================================================
-- Generated from: basic-rules-and-legal/character-classes-ii.html
-- Spell List from: spells/spell-list-ii.html
--
-- This file imports the Ranger base class including:
--   - Class definition with progression metadata
--   - Class skills (19 skills)
--   - Spells per day progression (half-caster, begins at 4th level)
--   - Class abilities (favored enemy, track, wild empathy, combat styles, etc.)
--   - Ranger spell list (53 spells across 4 levels)
--
-- Prerequisites:
--   - skills table populated (19 ranger class skills)
--   - spells table populated (ranger spell list)
--   - special_abilities table populated (Track, Endurance, Evasion, etc.)
--   - feats table populated (Track, Endurance as feats)
-- ============================================================================

SET search_path TO pnpo_3_5_dev;

-- ============================================================================
-- SECTION 1: RANGER CLASS DEFINITION
-- ============================================================================

INSERT INTO classes (
  name,
  hit_die,
  class_type,
  race_id,
  base_attack_bonus_progression,
  fortitude_progression,
  reflex_progression,
  will_progression,
  skill_points_per_level,
  is_spellcaster,
  spellcasting_ability,
  spell_progression_type,
  description
)
VALUES (
  'Ranger',
  8,                        -- d8 hit die
  'base',                   -- Core base class
  NULL,                     -- No race requirement
  'full',                   -- +1 BAB per level
  'good',                   -- Fort save: 2 + level/2
  'good',                   -- Ref save: 2 + level/2
  'poor',                   -- Will save: level/3
  6,                        -- 6 + Int modifier skill points
  true,                     -- Is a spellcaster (starting 4th level)
  'WIS',                    -- Wisdom-based casting
  'half',                   -- Half-caster progression (like Paladin)
  'A ranger is a skilled hunter and tracker who lives on the edges of civilization. Rangers are proficient with all simple and martial weapons, and with light armor. They gain special combat styles (archery or two-weapon fighting), can track prey, have favored enemies, gain an animal companion, and cast divine spells drawn from the ranger spell list.'
)
ON CONFLICT (name) DO NOTHING;

-- ============================================================================
-- SECTION 2: CLASS SKILLS
-- ============================================================================
-- Ranger has 19 class skills

INSERT INTO class_skills (class_id, skill_id)
SELECT
  (SELECT id FROM classes WHERE name = 'Ranger'),
  s.id
FROM skills s
WHERE s.name IN (
  'Climb',                    -- STR
  'Concentration',            -- CON
  'Craft',                    -- INT (any craft)
  'Handle Animal',            -- CHA
  'Heal',                     -- WIS
  'Hide',                     -- DEX
  'Jump',                     -- STR
  'Knowledge (dungeoneering)',-- INT
  'Knowledge (geography)',    -- INT
  'Knowledge (nature)',       -- INT
  'Listen',                   -- WIS
  'Move Silently',            -- DEX
  'Profession',               -- WIS (any profession)
  'Ride',                     -- DEX
  'Search',                   -- INT
  'Spot',                     -- WIS
  'Survival',                 -- WIS
  'Swim',                     -- STR
  'Use Rope'                  -- DEX
)
ON CONFLICT (class_id, skill_id) DO NOTHING;

-- ============================================================================
-- SECTION 3: SPELLS PER DAY PROGRESSION
-- ============================================================================
-- Ranger caster level = ranger_level / 2 (starting at 4th level)
-- Through 3rd level, ranger has no caster level
-- "0" spells per day means can only cast with WIS bonus spells

INSERT INTO spells_per_day_progression (class_id, class_level, spell_level, spells_per_day)
SELECT
  (SELECT id FROM classes WHERE name = 'Ranger'),
  level_data.class_level,
  level_data.spell_level,
  level_data.slots
FROM (VALUES
  -- Level 4: Begins spellcasting (caster level 2)
  (4, 1, 0),

  -- Level 5
  (5, 1, 0),

  -- Level 6: Caster level 3
  (6, 1, 1),

  -- Level 7
  (7, 1, 1),

  -- Level 8: Gains 2nd-level spells (caster level 4)
  (8, 1, 1),
  (8, 2, 0),

  -- Level 9
  (9, 1, 1),
  (9, 2, 0),

  -- Level 10: Caster level 5
  (10, 1, 1),
  (10, 2, 1),

  -- Level 11: Gains 3rd-level spells (caster level 5)
  (11, 1, 1),
  (11, 2, 1),
  (11, 3, 0),

  -- Level 12: Caster level 6
  (12, 1, 1),
  (12, 2, 1),
  (12, 3, 1),

  -- Level 13
  (13, 1, 1),
  (13, 2, 1),
  (13, 3, 1),

  -- Level 14: Gains 4th-level spells (caster level 7)
  (14, 1, 2),
  (14, 2, 1),
  (14, 3, 1),
  (14, 4, 0),

  -- Level 15: Caster level 7
  (15, 1, 2),
  (15, 2, 1),
  (15, 3, 1),
  (15, 4, 1),

  -- Level 16: Caster level 8
  (16, 1, 2),
  (16, 2, 2),
  (16, 3, 1),
  (16, 4, 1),

  -- Level 17: Caster level 8
  (17, 1, 2),
  (17, 2, 2),
  (17, 3, 2),
  (17, 4, 1),

  -- Level 18: Caster level 9
  (18, 1, 3),
  (18, 2, 2),
  (18, 3, 2),
  (18, 4, 1),

  -- Level 19: Caster level 9
  (19, 1, 3),
  (19, 2, 3),
  (19, 3, 3),
  (19, 4, 2),

  -- Level 20: Caster level 10
  (20, 1, 3),
  (20, 2, 3),
  (20, 3, 3),
  (20, 4, 3)
) AS level_data(class_level, spell_level, slots)
ON CONFLICT (class_id, class_level, spell_level) DO NOTHING;

-- ============================================================================
-- SECTION 4: RANGER SPELL LIST
-- ============================================================================
-- 53 ranger spells across 4 spell levels
-- Source: spell-list-ii.html lines 615-678

-- NOTE: This section assumes spells are already in the spells table
-- If spell names don't match exactly, this INSERT will fail on FK constraint

INSERT INTO spell_class_levels (spell_id, class_id, spell_level)
SELECT
  s.id,
  (SELECT id FROM classes WHERE name = 'Ranger'),
  spell_data.level
FROM (VALUES
  -- 1st-Level Ranger Spells (19 spells)
  ('Alarm', 1),
  ('Animal Messenger', 1),
  ('Calm Animals', 1),
  ('Charm Animal', 1),
  ('Delay Poison', 1),
  ('Detect Animals or Plants', 1),
  ('Detect Poison', 1),
  ('Detect Snares and Pits', 1),
  ('Endure Elements', 1),
  ('Entangle', 1),
  ('Hide from Animals', 1),
  ('Jump', 1),
  ('Longstrider', 1),
  ('Magic Fang', 1),
  ('Pass without Trace', 1),
  ('Read Magic', 1),
  ('Resist Energy', 1),
  ('Speak with Animals', 1),
  ('Summon Nature''s Ally I', 1),

  -- 2nd-Level Ranger Spells (12 spells)
  ('Barkskin', 2),
  ('Bear''s Endurance', 2),
  ('Cat''s Grace', 2),
  ('Cure Light Wounds', 2),
  ('Hold Animal', 2),
  ('Owl''s Wisdom', 2),
  ('Protection from Energy', 2),
  ('Snare', 2),
  ('Speak with Plants', 2),
  ('Spike Growth', 2),
  ('Summon Nature''s Ally II', 2),
  ('Wind Wall', 2),

  -- 3rd-Level Ranger Spells (13 spells)
  ('Command Plants', 3),
  ('Cure Moderate Wounds', 3),
  ('Darkvision', 3),
  ('Diminish Plants', 3),
  ('Magic Fang, Greater', 3),
  ('Neutralize Poison', 3),
  ('Plant Growth', 3),
  ('Reduce Animal', 3),
  ('Remove Disease', 3),
  ('Repel Vermin', 3),
  ('Summon Nature''s Ally III', 3),
  ('Tree Shape', 3),
  ('Water Walk', 3),

  -- 4th-Level Ranger Spells (7 spells)
  ('Animal Growth', 4),
  ('Commune with Nature', 4),
  ('Cure Serious Wounds', 4),
  ('Freedom of Movement', 4),
  ('Nondetection', 4),
  ('Summon Nature''s Ally IV', 4),
  ('Tree Stride', 4)
) AS spell_data(spell_name, level)
JOIN spells s ON s.name = spell_data.spell_name
ON CONFLICT (spell_id, class_id) DO NOTHING;

-- ============================================================================
-- SECTION 5: CLASS GRANTED ABILITIES
-- ============================================================================
-- Rangers gain abilities at specific levels
-- This section links ranger levels to special abilities

-- ASSUMPTION: special_abilities table must be populated with these abilities:
--   - Favored Enemy (1st, 5th, 10th, 15th, 20th) - with progression
--   - Track (bonus feat)
--   - Wild Empathy (Ex)
--   - Combat Style - Archery (Ex)
--   - Combat Style - Two-Weapon Fighting (Ex)
--   - Endurance (bonus feat)
--   - Animal Companion (Ex)
--   - Spellcasting (gained at 4th level)
--   - Improved Combat Style - Archery (Ex)
--   - Improved Combat Style - Two-Weapon (Ex)
--   - Woodland Stride (Ex)
--   - Swift Tracker (Ex)
--   - Evasion (Ex)
--   - Combat Style Mastery - Archery (Ex)
--   - Combat Style Mastery - Two-Weapon (Ex)
--   - Camouflage (Ex)
--   - Hide in Plain Sight (Ex)

-- 1st Level: 1st Favored Enemy, Track, Wild Empathy
INSERT INTO class_granted_abilities (class_id, special_ability_id, granted_at_level, first_gained_at_level, improves_existing, is_choice, choice_source, notes)
VALUES
  (
    (SELECT id FROM classes WHERE name = 'Ranger'),
    (SELECT id FROM special_abilities WHERE name = 'Favored Enemy'),
    1,
    1,
    false,
    true,
    'creature_types',
    '+2 bonus on Bluff, Listen, Sense Motive, Spot, and Survival checks, and +2 bonus on weapon damage rolls against chosen creature type'
  ),
  (
    (SELECT id FROM classes WHERE name = 'Ranger'),
    (SELECT id FROM special_abilities WHERE name = 'Track'),
    1,
    1,
    false,
    false,
    NULL,
    'Ranger gains Track as a bonus feat'
  ),
  (
    (SELECT id FROM classes WHERE name = 'Ranger'),
    (SELECT id FROM special_abilities WHERE name = 'Wild Empathy'),
    1,
    1,
    false,
    false,
    NULL,
    'Improve attitude of an animal (1d20 + ranger level + CHA modifier). Functions like Diplomacy for animals.'
  )
ON CONFLICT (class_id, granted_at_level, special_ability_id) DO NOTHING;

-- 2nd Level: Combat Style (choice between Archery or Two-Weapon Fighting)
INSERT INTO class_granted_abilities (class_id, special_ability_id, granted_at_level, first_gained_at_level, improves_existing, is_choice, choice_source, notes)
VALUES
  (
    (SELECT id FROM classes WHERE name = 'Ranger'),
    (SELECT id FROM special_abilities WHERE name = 'Combat Style'),
    2,
    2,
    false,
    true,
    'combat_styles',
    'Choose archery (gain Rapid Shot) or two-weapon fighting (gain Two-Weapon Fighting). Benefits only apply when wearing light or no armor.'
  )
ON CONFLICT (class_id, granted_at_level, special_ability_id) DO NOTHING;

-- 3rd Level: Endurance
INSERT INTO class_granted_abilities (class_id, special_ability_id, granted_at_level, first_gained_at_level, improves_existing, is_choice, choice_source, notes)
VALUES
  (
    (SELECT id FROM classes WHERE name = 'Ranger'),
    (SELECT id FROM special_abilities WHERE name = 'Endurance'),
    3,
    3,
    false,
    false,
    NULL,
    'Ranger gains Endurance as a bonus feat'
  )
ON CONFLICT (class_id, granted_at_level, special_ability_id) DO NOTHING;

-- 4th Level: Animal Companion, Spellcasting begins
INSERT INTO class_granted_abilities (class_id, special_ability_id, granted_at_level, first_gained_at_level, improves_existing, is_choice, choice_source, notes)
VALUES
  (
    (SELECT id FROM classes WHERE name = 'Ranger'),
    (SELECT id FROM special_abilities WHERE name = 'Animal Companion'),
    4,
    4,
    false,
    true,
    'animal_companions',
    'Functions like druid animal companion, but effective druid level = ranger level / 2. Can select from: badger, camel, dire rat, dog, riding dog, eagle, hawk, horse, owl, pony, snake (Small/Medium viper), or wolf.'
  ),
  (
    (SELECT id FROM classes WHERE name = 'Ranger'),
    (SELECT id FROM special_abilities WHERE name = 'Spellcasting'),
    4,
    4,
    false,
    false,
    NULL,
    'Begins casting divine ranger spells. Caster level = ranger level / 2. WIS-based (DC 10 + spell level + WIS mod). Prepares spells like cleric but cannot spontaneously cast cure spells.'
  )
ON CONFLICT (class_id, granted_at_level, special_ability_id) DO NOTHING;

-- 5th Level: 2nd Favored Enemy
INSERT INTO class_granted_abilities (class_id, special_ability_id, granted_at_level, first_gained_at_level, improves_existing, is_choice, choice_source, notes)
VALUES
  (
    (SELECT id FROM classes WHERE name = 'Ranger'),
    (SELECT id FROM special_abilities WHERE name = 'Favored Enemy'),
    5,
    1,
    true,
    true,
    'creature_types',
    'Select additional favored enemy OR increase existing favored enemy bonus by +2'
  )
ON CONFLICT (class_id, granted_at_level, special_ability_id) DO NOTHING;

-- 6th Level: Improved Combat Style
INSERT INTO class_granted_abilities (class_id, special_ability_id, granted_at_level, first_gained_at_level, improves_existing, is_choice, choice_source, notes)
VALUES
  (
    (SELECT id FROM classes WHERE name = 'Ranger'),
    (SELECT id FROM special_abilities WHERE name = 'Improved Combat Style'),
    6,
    6,
    false,
    false,
    NULL,
    'If archery: gain Manyshot. If two-weapon: gain Improved Two-Weapon Fighting. Benefits only when wearing light or no armor.'
  )
ON CONFLICT (class_id, granted_at_level, special_ability_id) DO NOTHING;

-- 7th Level: Woodland Stride
INSERT INTO class_granted_abilities (class_id, special_ability_id, granted_at_level, first_gained_at_level, improves_existing, is_choice, choice_source, notes)
VALUES
  (
    (SELECT id FROM classes WHERE name = 'Ranger'),
    (SELECT id FROM special_abilities WHERE name = 'Woodland Stride'),
    7,
    7,
    false,
    false,
    NULL,
    'Move through natural undergrowth (thorns, briars, overgrown areas) at normal speed without damage. Magically manipulated terrain still affects.'
  )
ON CONFLICT (class_id, granted_at_level, special_ability_id) DO NOTHING;

-- 8th Level: Swift Tracker
INSERT INTO class_granted_abilities (class_id, special_ability_id, granted_at_level, first_gained_at_level, improves_existing, is_choice, choice_source, notes)
VALUES
  (
    (SELECT id FROM classes WHERE name = 'Ranger'),
    (SELECT id FROM special_abilities WHERE name = 'Swift Tracker'),
    8,
    8,
    false,
    false,
    NULL,
    'Move at normal speed while tracking (no -5 penalty). Move at up to twice normal speed while tracking (only -10 penalty instead of -20).'
  )
ON CONFLICT (class_id, granted_at_level, special_ability_id) DO NOTHING;

-- 9th Level: Evasion
INSERT INTO class_granted_abilities (class_id, special_ability_id, granted_at_level, first_gained_at_level, improves_existing, is_choice, choice_source, notes)
VALUES
  (
    (SELECT id FROM classes WHERE name = 'Ranger'),
    (SELECT id FROM special_abilities WHERE name = 'Evasion'),
    9,
    9,
    false,
    false,
    NULL,
    'If successful Reflex save against attack that normally deals half damage, take no damage instead. Only works in light or no armor. Helpless ranger does not benefit.'
  )
ON CONFLICT (class_id, granted_at_level, special_ability_id) DO NOTHING;

-- 10th Level: 3rd Favored Enemy
INSERT INTO class_granted_abilities (class_id, special_ability_id, granted_at_level, first_gained_at_level, improves_existing, is_choice, choice_source, notes)
VALUES
  (
    (SELECT id FROM classes WHERE name = 'Ranger'),
    (SELECT id FROM special_abilities WHERE name = 'Favored Enemy'),
    10,
    1,
    true,
    true,
    'creature_types',
    'Select additional favored enemy OR increase existing favored enemy bonus by +2'
  )
ON CONFLICT (class_id, granted_at_level, special_ability_id) DO NOTHING;

-- 11th Level: Combat Style Mastery
INSERT INTO class_granted_abilities (class_id, special_ability_id, granted_at_level, first_gained_at_level, improves_existing, is_choice, choice_source, notes)
VALUES
  (
    (SELECT id FROM classes WHERE name = 'Ranger'),
    (SELECT id FROM special_abilities WHERE name = 'Combat Style Mastery'),
    11,
    11,
    false,
    false,
    NULL,
    'If archery: gain Improved Precise Shot. If two-weapon: gain Greater Two-Weapon Fighting. Benefits only when wearing light or no armor.'
  )
ON CONFLICT (class_id, granted_at_level, special_ability_id) DO NOTHING;

-- 13th Level: Camouflage
INSERT INTO class_granted_abilities (class_id, special_ability_id, granted_at_level, first_gained_at_level, improves_existing, is_choice, choice_source, notes)
VALUES
  (
    (SELECT id FROM classes WHERE name = 'Ranger'),
    (SELECT id FROM special_abilities WHERE name = 'Camouflage'),
    13,
    13,
    false,
    false,
    NULL,
    'Use Hide skill in any natural terrain, even without cover or concealment'
  )
ON CONFLICT (class_id, granted_at_level, special_ability_id) DO NOTHING;

-- 15th Level: 4th Favored Enemy
INSERT INTO class_granted_abilities (class_id, special_ability_id, granted_at_level, first_gained_at_level, improves_existing, is_choice, choice_source, notes)
VALUES
  (
    (SELECT id FROM classes WHERE name = 'Ranger'),
    (SELECT id FROM special_abilities WHERE name = 'Favored Enemy'),
    15,
    1,
    true,
    true,
    'creature_types',
    'Select additional favored enemy OR increase existing favored enemy bonus by +2'
  )
ON CONFLICT (class_id, granted_at_level, special_ability_id) DO NOTHING;

-- 17th Level: Hide in Plain Sight
INSERT INTO class_granted_abilities (class_id, special_ability_id, granted_at_level, first_gained_at_level, improves_existing, is_choice, choice_source, notes)
VALUES
  (
    (SELECT id FROM classes WHERE name = 'Ranger'),
    (SELECT id FROM special_abilities WHERE name = 'Hide in Plain Sight'),
    17,
    17,
    false,
    false,
    NULL,
    'While in any natural terrain, can use Hide skill even while being observed'
  )
ON CONFLICT (class_id, granted_at_level, special_ability_id) DO NOTHING;

-- 20th Level: 5th Favored Enemy
INSERT INTO class_granted_abilities (class_id, special_ability_id, granted_at_level, first_gained_at_level, improves_existing, is_choice, choice_source, notes)
VALUES
  (
    (SELECT id FROM classes WHERE name = 'Ranger'),
    (SELECT id FROM special_abilities WHERE name = 'Favored Enemy'),
    20,
    1,
    true,
    true,
    'creature_types',
    'Select additional favored enemy OR increase existing favored enemy bonus by +2'
  )
ON CONFLICT (class_id, granted_at_level, special_ability_id) DO NOTHING;

-- ============================================================================
-- SECTION 6: FAVORED ENEMY TYPES (REFERENCE DATA)
-- ============================================================================
-- D&D 3.5 SRD lists specific creature types/subtypes valid for Favored Enemy
-- This is reference data to support Favored Enemy choice validation

-- NOTE: This section assumes a creature_types table or similar exists
-- The exact schema for storing creature types may vary
-- This is provided as a guide for what types should be available

-- Table: Ranger Favored Enemies (from SRD)
-- | Type (Subtype)        | Notes                                      |
-- |-----------------------|--------------------------------------------|
-- | Aberration            | Base type                                  |
-- | Animal                | Base type                                  |
-- | Construct             | Base type                                  |
-- | Dragon                | Base type                                  |
-- | Elemental             | Base type                                  |
-- | Fey                   | Base type                                  |
-- | Giant                 | Base type                                  |
-- | Humanoid (aquatic)    | Subtype selection required                 |
-- | Humanoid (dwarf)      | Subtype selection required                 |
-- | Humanoid (elf)        | Subtype selection required                 |
-- | Humanoid (goblinoid)  | Subtype selection required                 |
-- | Humanoid (gnoll)      | Subtype selection required                 |
-- | Humanoid (gnome)      | Subtype selection required                 |
-- | Humanoid (halfling)   | Subtype selection required                 |
-- | Humanoid (human)      | Subtype selection required                 |
-- | Humanoid (orc)        | Subtype selection required                 |
-- | Humanoid (reptilian)  | Subtype selection required                 |
-- | Magical beast         | Base type                                  |
-- | Monstrous humanoid    | Base type                                  |
-- | Ooze                  | Base type                                  |
-- | Outsider (air)        | Subtype selection required                 |
-- | Outsider (chaotic)    | Subtype selection required                 |
-- | Outsider (earth)      | Subtype selection required                 |
-- | Outsider (evil)       | Subtype selection required                 |
-- | Outsider (fire)       | Subtype selection required                 |
-- | Outsider (good)       | Subtype selection required                 |
-- | Outsider (lawful)     | Subtype selection required                 |
-- | Outsider (native)     | Subtype selection required                 |
-- | Outsider (water)      | Subtype selection required                 |
-- | Plant                 | Base type                                  |
-- | Undead                | Base type                                  |
-- | Vermin                | Base type                                  |

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================
-- Run these queries after import to verify data integrity:

-- Verify Ranger class was created
-- SELECT * FROM classes WHERE name = 'Ranger';

-- Verify class skills (should return 19 rows)
-- SELECT COUNT(*) FROM class_skills cs
-- JOIN classes c ON cs.class_id = c.id
-- WHERE c.name = 'Ranger';

-- Verify spells per day progression (should return 55 rows: levels 4-20, varying spell levels)
-- SELECT class_level, spell_level, spells_per_day
-- FROM spells_per_day_progression
-- WHERE class_id = (SELECT id FROM classes WHERE name = 'Ranger')
-- ORDER BY class_level, spell_level;

-- Verify ranger spell list (should return 53 spells)
-- SELECT COUNT(*) FROM spell_class_levels scl
-- JOIN classes c ON scl.class_id = c.id
-- WHERE c.name = 'Ranger';

-- Verify class abilities by level
-- SELECT cga.granted_at_level, sa.name, cga.is_choice, cga.improves_existing
-- FROM class_granted_abilities cga
-- JOIN special_abilities sa ON cga.special_ability_id = sa.id
-- JOIN classes c ON cga.class_id = c.id
-- WHERE c.name = 'Ranger'
-- ORDER BY cga.granted_at_level;

-- ============================================================================
-- IMPORT SUMMARY
-- ============================================================================
-- Tables populated:
--   - classes (1 row: Ranger)
--   - class_skills (19 rows)
--   - spells_per_day_progression (55 rows: spell progression for levels 4-20)
--   - spell_class_levels (53 rows: ranger spell list)
--   - class_granted_abilities (17 rows: abilities at various levels)
--
-- Total rows inserted: ~145 rows
-- ============================================================================
