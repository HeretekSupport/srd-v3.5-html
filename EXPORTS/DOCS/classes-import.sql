SET search_path TO pnpo_3_5_dev;

-- =====================================================
-- WIZARD CLASS MAPPING
-- =====================================================
-- Based on SRD PHB character-classes-ii.html lines 2168-2967
-- Source: Player's Handbook p56-58 (Wizard class)
--
-- This file demonstrates how the Wizard class from D&D 3.5 SRD maps to the
-- normalized database schema, including:
-- - Basic class metadata (hit die, BAB, saves, skills)
-- - Spells per day progression (all 20 levels)
-- - Class granted abilities (automatic and choice-based)
-- - Normalized choice system for bonus feats
-- - Class archetypes for specialist wizards
-- - Weapon/armor proficiencies
-- - Familiar progression integration

-- =====================================================
-- STEP 1: INSERT WIZARD CLASS
-- =====================================================

INSERT INTO classes (
  name,
  hit_die,
  class_type,
  base_attack_bonus_progression,
  fortitude_progression,
  reflex_progression,
  will_progression,
  skill_points_per_level,
  is_spellcaster,
  spellcasting_ability,
  spell_progression_type,
  description
) VALUES (
  'Wizard',
  4,  -- d4 hit die
  'base',
  'poor',    -- +1/2 BAB per level
  'poor',    -- Poor Fort save
  'poor',    -- Poor Ref save
  'good',    -- Good Will save (+2 at 1st, scaling)
  2,         -- 2 + INT modifier skill points per level
  true,
  'INT',
  'full',    -- 9th level spells at level 17
  'A wizard casts arcane spells which are drawn from the sorcerer/wizard spell list. A wizard must choose and prepare her spells ahead of time.'
);

-- =====================================================
-- STEP 2: ADD CLASS SKILLS
-- =====================================================

-- Wizard has 6 class skills (PHB p57):
-- - Concentration (Con)
-- - Craft (Int)
-- - Decipher Script (Int)
-- - Knowledge (all skills, taken individually) (Int)
-- - Profession (Wis)
-- - Spellcraft (Int)

INSERT INTO class_skills (class_id, skill_id)
SELECT
  (SELECT id FROM classes WHERE name = 'Wizard'),
  id
FROM skills
WHERE name IN (
  'Concentration',
  'Craft',
  'Decipher Script',
  'Knowledge (arcana)',
  'Knowledge (architecture and engineering)',
  'Knowledge (dungeoneering)',
  'Knowledge (geography)',
  'Knowledge (history)',
  'Knowledge (local)',
  'Knowledge (nature)',
  'Knowledge (nobility and royalty)',
  'Knowledge (religion)',
  'Knowledge (the planes)',
  'Profession',
  'Spellcraft'
);

-- =====================================================
-- STEP 3: SPELLS PER DAY PROGRESSION
-- =====================================================

-- Wizard spell progression from PHB p57 Table: The Wizard
-- Base spells per day (excludes bonus spells from high INT)

-- Level 1
INSERT INTO spells_per_day_progression (class_id, class_level, spell_level, spells_per_day)
SELECT
  (SELECT id FROM classes WHERE name = 'Wizard'),
  1,
  unnest(ARRAY[0, 1]),
  unnest(ARRAY[3, 1]);

-- Level 2
INSERT INTO spells_per_day_progression (class_id, class_level, spell_level, spells_per_day)
SELECT
  (SELECT id FROM classes WHERE name = 'Wizard'),
  2,
  unnest(ARRAY[0, 1]),
  unnest(ARRAY[4, 2]);

-- Level 3
INSERT INTO spells_per_day_progression (class_id, class_level, spell_level, spells_per_day)
SELECT
  (SELECT id FROM classes WHERE name = 'Wizard'),
  3,
  unnest(ARRAY[0, 1, 2]),
  unnest(ARRAY[4, 2, 1]);

-- Level 4
INSERT INTO spells_per_day_progression (class_id, class_level, spell_level, spells_per_day)
SELECT
  (SELECT id FROM classes WHERE name = 'Wizard'),
  4,
  unnest(ARRAY[0, 1, 2]),
  unnest(ARRAY[4, 3, 2]);

-- Level 5
INSERT INTO spells_per_day_progression (class_id, class_level, spell_level, spells_per_day)
SELECT
  (SELECT id FROM classes WHERE name = 'Wizard'),
  5,
  unnest(ARRAY[0, 1, 2, 3]),
  unnest(ARRAY[4, 3, 2, 1]);

-- Level 6
INSERT INTO spells_per_day_progression (class_id, class_level, spell_level, spells_per_day)
SELECT
  (SELECT id FROM classes WHERE name = 'Wizard'),
  6,
  unnest(ARRAY[0, 1, 2, 3]),
  unnest(ARRAY[4, 3, 3, 2]);

-- Level 7
INSERT INTO spells_per_day_progression (class_id, class_level, spell_level, spells_per_day)
SELECT
  (SELECT id FROM classes WHERE name = 'Wizard'),
  7,
  unnest(ARRAY[0, 1, 2, 3, 4]),
  unnest(ARRAY[4, 4, 3, 2, 1]);

-- Level 8
INSERT INTO spells_per_day_progression (class_id, class_level, spell_level, spells_per_day)
SELECT
  (SELECT id FROM classes WHERE name = 'Wizard'),
  8,
  unnest(ARRAY[0, 1, 2, 3, 4]),
  unnest(ARRAY[4, 4, 3, 3, 2]);

-- Level 9
INSERT INTO spells_per_day_progression (class_id, class_level, spell_level, spells_per_day)
SELECT
  (SELECT id FROM classes WHERE name = 'Wizard'),
  9,
  unnest(ARRAY[0, 1, 2, 3, 4, 5]),
  unnest(ARRAY[4, 4, 4, 3, 2, 1]);

-- Level 10
INSERT INTO spells_per_day_progression (class_id, class_level, spell_level, spells_per_day)
SELECT
  (SELECT id FROM classes WHERE name = 'Wizard'),
  10,
  unnest(ARRAY[0, 1, 2, 3, 4, 5]),
  unnest(ARRAY[4, 4, 4, 3, 3, 2]);

-- Level 11
INSERT INTO spells_per_day_progression (class_id, class_level, spell_level, spells_per_day)
SELECT
  (SELECT id FROM classes WHERE name = 'Wizard'),
  11,
  unnest(ARRAY[0, 1, 2, 3, 4, 5, 6]),
  unnest(ARRAY[4, 4, 4, 4, 3, 2, 1]);

-- Level 12
INSERT INTO spells_per_day_progression (class_id, class_level, spell_level, spells_per_day)
SELECT
  (SELECT id FROM classes WHERE name = 'Wizard'),
  12,
  unnest(ARRAY[0, 1, 2, 3, 4, 5, 6]),
  unnest(ARRAY[4, 4, 4, 4, 3, 3, 2]);

-- Level 13
INSERT INTO spells_per_day_progression (class_id, class_level, spell_level, spells_per_day)
SELECT
  (SELECT id FROM classes WHERE name = 'Wizard'),
  13,
  unnest(ARRAY[0, 1, 2, 3, 4, 5, 6, 7]),
  unnest(ARRAY[4, 4, 4, 4, 4, 3, 2, 1]);

-- Level 14
INSERT INTO spells_per_day_progression (class_id, class_level, spell_level, spells_per_day)
SELECT
  (SELECT id FROM classes WHERE name = 'Wizard'),
  14,
  unnest(ARRAY[0, 1, 2, 3, 4, 5, 6, 7]),
  unnest(ARRAY[4, 4, 4, 4, 4, 3, 3, 2]);

-- Level 15
INSERT INTO spells_per_day_progression (class_id, class_level, spell_level, spells_per_day)
SELECT
  (SELECT id FROM classes WHERE name = 'Wizard'),
  15,
  unnest(ARRAY[0, 1, 2, 3, 4, 5, 6, 7, 8]),
  unnest(ARRAY[4, 4, 4, 4, 4, 4, 3, 2, 1]);

-- Level 16
INSERT INTO spells_per_day_progression (class_id, class_level, spell_level, spells_per_day)
SELECT
  (SELECT id FROM classes WHERE name = 'Wizard'),
  16,
  unnest(ARRAY[0, 1, 2, 3, 4, 5, 6, 7, 8]),
  unnest(ARRAY[4, 4, 4, 4, 4, 4, 3, 3, 2]);

-- Level 17
INSERT INTO spells_per_day_progression (class_id, class_level, spell_level, spells_per_day)
SELECT
  (SELECT id FROM classes WHERE name = 'Wizard'),
  17,
  unnest(ARRAY[0, 1, 2, 3, 4, 5, 6, 7, 8, 9]),
  unnest(ARRAY[4, 4, 4, 4, 4, 4, 4, 3, 2, 1]);

-- Level 18
INSERT INTO spells_per_day_progression (class_id, class_level, spell_level, spells_per_day)
SELECT
  (SELECT id FROM classes WHERE name = 'Wizard'),
  18,
  unnest(ARRAY[0, 1, 2, 3, 4, 5, 6, 7, 8, 9]),
  unnest(ARRAY[4, 4, 4, 4, 4, 4, 4, 3, 3, 2]);

-- Level 19
INSERT INTO spells_per_day_progression (class_id, class_level, spell_level, spells_per_day)
SELECT
  (SELECT id FROM classes WHERE name = 'Wizard'),
  19,
  unnest(ARRAY[0, 1, 2, 3, 4, 5, 6, 7, 8, 9]),
  unnest(ARRAY[4, 4, 4, 4, 4, 4, 4, 4, 3, 3]);

-- Level 20
INSERT INTO spells_per_day_progression (class_id, class_level, spell_level, spells_per_day)
SELECT
  (SELECT id FROM classes WHERE name = 'Wizard'),
  20,
  spell_level,
  4
FROM generate_series(0, 9) AS spell_level;

-- =====================================================
-- STEP 4: CLASS GRANTED ABILITIES (Automatic)
-- =====================================================

-- 4a. Summon Familiar (level 1) - Automatic
INSERT INTO class_granted_abilities (
  class_id,
  special_ability_id,
  granted_at_level,
  is_choice
) VALUES (
  (SELECT id FROM classes WHERE name = 'Wizard'),
  (SELECT id FROM special_abilities WHERE name = 'Summon Familiar'),
  1,
  false
);

-- 4b. Scribe Scroll (level 1) - Automatic bonus feat
INSERT INTO class_granted_abilities (
  class_id,
  special_ability_id,
  granted_at_level,
  is_choice
) VALUES (
  (SELECT id FROM classes WHERE name = 'Wizard'),
  (SELECT id FROM special_abilities WHERE name = 'Scribe Scroll'),
  1,
  false
);

-- =====================================================
-- STEP 5: BONUS FEAT CHOICES (Normalized)
-- =====================================================

-- Wizard gains bonus feats at levels 5, 10, 15, 20
-- Can choose from: metamagic feats, item creation feats, or Spell Mastery

-- 5a. Create choice abilities for each bonus feat level
INSERT INTO class_granted_abilities (
  class_id,
  special_ability_id,
  granted_at_level,
  is_choice
)
SELECT
  (SELECT id FROM classes WHERE name = 'Wizard'),
  NULL,  -- No specific ability - it's a choice
  level,
  true
FROM unnest(ARRAY[5, 10, 15, 20]) AS level;

-- 5b. Add choice constraints for each bonus feat
INSERT INTO class_ability_choice_constraints (
  class_ability_id,
  min_choices,
  max_choices,
  choice_source,
  description
)
SELECT
  cga.id,
  1,
  1,
  'feats',
  'Wizard bonus feat (level ' || cga.granted_at_level || '): choose metamagic, item creation, or Spell Mastery'
FROM class_granted_abilities cga
WHERE cga.class_id = (SELECT id FROM classes WHERE name = 'Wizard')
  AND cga.granted_at_level IN (5, 10, 15, 20)
  AND cga.is_choice = true;

-- 5c. Add choice filters for each bonus feat (OR logic)
INSERT INTO class_ability_choice_filters (
  class_ability_id,
  filter_column,
  filter_operator,
  filter_value,
  description
)
SELECT
  cga.id,
  unnest(ARRAY['feat_type', 'feat_type', 'name']),
  '=',
  unnest(ARRAY['metamagic', 'item_creation', 'Spell Mastery']),
  unnest(ARRAY['Metamagic feats allowed', 'Item creation feats allowed', 'Spell Mastery allowed'])
FROM class_granted_abilities cga
WHERE cga.class_id = (SELECT id FROM classes WHERE name = 'Wizard')
  AND cga.granted_at_level IN (5, 10, 15, 20)
  AND cga.is_choice = true;

-- =====================================================
-- STEP 6: WEAPON AND ARMOR PROFICIENCIES
-- =====================================================

-- Wizards are proficient with:
-- - Weapons: club, dagger, heavy crossbow, light crossbow, quarterstaff
-- - Armor: None
-- - Shields: None

-- Note: This could be stored as a special ability or in a dedicated proficiencies table
-- For now, we'll create a special ability

INSERT INTO special_abilities (
  name,
  ability_type,
  description,
  source
) VALUES (
  'Wizard Weapon Proficiency',
  'extraordinary',
  'Proficient with club, dagger, heavy crossbow, light crossbow, and quarterstaff only. Not proficient with any armor or shields.',
  'PHB p57'
);

INSERT INTO class_granted_abilities (
  class_id,
  special_ability_id,
  granted_at_level,
  is_choice
) VALUES (
  (SELECT id FROM classes WHERE name = 'Wizard'),
  (SELECT id FROM special_abilities WHERE name = 'Wizard Weapon Proficiency'),
  1,
  false
);

-- =====================================================
-- STEP 7: WIZARD SCHOOL SPECIALIZATION (Archetypes)
-- =====================================================

-- Specialist wizards are variants that gain +1 spell per level from
-- their chosen school but must prohibit 2 other schools
-- (Divination specialists only prohibit 1 school)

-- Example: Evoker (Evocation Specialist)
INSERT INTO class_archetypes (
  class_id,
  name,
  description,
  source
) VALUES (
  (SELECT id FROM classes WHERE name = 'Wizard'),
  'Evoker',
  'Wizard who specializes in evocation magic. Gains +1 spell slot per spell level for evocation spells, but must select 2 prohibited schools (cannot include divination).',
  'PHB p57'
);

-- Add other specialist archetypes
INSERT INTO class_archetypes (class_id, name, description, source)
SELECT
  (SELECT id FROM classes WHERE name = 'Wizard'),
  name,
  description,
  'PHB p57'
FROM (VALUES
  ('Abjurer', 'Wizard who specializes in abjuration (protective magic)'),
  ('Conjurer', 'Wizard who specializes in conjuration (summoning and teleportation)'),
  ('Diviner', 'Wizard who specializes in divination (information and detection). Only prohibits 1 school instead of 2.'),
  ('Enchanter', 'Wizard who specializes in enchantment (mind-affecting magic)'),
  ('Illusionist', 'Wizard who specializes in illusion (deception and sensory effects)'),
  ('Necromancer', 'Wizard who specializes in necromancy (death and undeath magic)'),
  ('Transmuter', 'Wizard who specializes in transmutation (alteration and enhancement)')
) AS t(name, description);

-- Note: The +1 spell slot and prohibited schools would be handled by:
-- - archetype_granted_abilities for the bonus spell slot ability
-- - character creation logic for prohibited school selection (Phase 2)

-- =====================================================
-- STEP 8: FAMILIAR PROGRESSION INTEGRATION
-- =====================================================

-- Wizards who take the Summon Familiar ability automatically benefit from
-- the familiar progression system (srd_ref_familiar_progressions table)
-- No additional class_granted_abilities entries needed - the progression
-- is based on the character's wizard class level automatically

-- =====================================================
-- VERIFICATION QUERIES
-- =====================================================

-- Get all wizard class details
-- SELECT
--   c.name, c.hit_die, c.base_attack_bonus_progression,
--   c.skill_points_per_level, c.spellcasting_ability
-- FROM classes c
-- WHERE c.name = 'Wizard';

-- Get wizard class skills
-- SELECT s.name
-- FROM class_skills cs
-- JOIN skills s ON cs.skill_id = s.id
-- WHERE cs.class_id = (SELECT id FROM classes WHERE name = 'Wizard')
-- ORDER BY s.name;

-- Get wizard spells per day at level 10
-- SELECT spell_level, spells_per_day
-- FROM spells_per_day_progression
-- WHERE class_id = (SELECT id FROM classes WHERE name = 'Wizard')
--   AND class_level = 10
-- ORDER BY spell_level;

-- Get wizard bonus feat choices with filters
-- SELECT
--   cga.granted_at_level,
--   cacc.min_choices,
--   cacc.max_choices,
--   cacc.choice_source,
--   string_agg(cacf.filter_value, ', ' ORDER BY cacf.id) AS allowed_types
-- FROM class_granted_abilities cga
-- JOIN class_ability_choice_constraints cacc ON cga.id = cacc.class_ability_id
-- LEFT JOIN class_ability_choice_filters cacf ON cga.id = cacf.class_ability_id
-- WHERE cga.class_id = (SELECT id FROM classes WHERE name = 'Wizard')
--   AND cga.is_choice = true
-- GROUP BY cga.granted_at_level, cacc.min_choices, cacc.max_choices, cacc.choice_source
-- ORDER BY cga.granted_at_level;

-- Get all automatic abilities granted at level 1
-- SELECT
--   sa.name,
--   sa.ability_type,
--   sa.description
-- FROM class_granted_abilities cga
-- JOIN special_abilities sa ON cga.special_ability_id = sa.id
-- WHERE cga.class_id = (SELECT id FROM classes WHERE name = 'Wizard')
--   AND cga.granted_at_level = 1
--   AND cga.is_choice = false;

-- Get all wizard specialist archetypes
-- SELECT name, description
-- FROM class_archetypes
-- WHERE class_id = (SELECT id FROM classes WHERE name = 'Wizard')
-- ORDER BY name;

-- =====================================================
-- END OF WIZARD CLASS MAPPING
-- =====================================================
