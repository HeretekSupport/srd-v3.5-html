SET search_path TO pnpo_3_5_dev;

-- =====================================================
-- SPELL IMPORT EXAMPLES
-- =====================================================
-- This file demonstrates how to map D&D 3.5 SRD spells to the pnpo_3_5_dev schema.
-- Two complete examples are provided:
--   1. Daze Monster - Condition-granting spell with prerequisites
--   2. Detect Evil - Divination/detection spell with narrative effects
--
-- Prerequisites:
--   - All reference tables populated (spell_schools, spell_component_types, etc.)
--   - conditions table populated (Dazed, Stunned, etc.)
--   - effects system initialized
--   - formulas system initialized
--   - prerequisites system initialized
--
-- Phase: Phase 1 (SRD Data Entry)

-- =====================================================
-- EXAMPLE 1: DAZE MONSTER
-- =====================================================
-- Source: SRD Enchantment (Compulsion) [Mind-Affecting]
-- Level: Brd 2, Sor/Wiz 2
-- Target: One living creature of 6 HD or less
-- Effect: Applies "Dazed" condition for 1 round (Will negates)
--
-- Key Features:
-- - Uses spell_granted_conditions to link to conditions system
-- - Uses spell_prerequisites for HD restriction
-- - Uses spell_saves for Will save
-- - Fully structured, no narrative needed

-- Step 1: Insert spell into spells table
INSERT INTO spells (
  name,
  spell_school_id,
  spell_subschool_id,
  is_arcane,
  is_divine,
  casting_time,
  range_type,
  range_formula_id,
  area_of_effect,
  duration,
  allows_spell_resistance,
  description
) VALUES (
  'Daze Monster',
  (SELECT id FROM spell_schools WHERE name = 'Enchantment'),
  (SELECT id FROM spell_subschools WHERE name = 'Compulsion'),
  true,   -- Arcane (Brd, Sor/Wiz)
  false,  -- Not divine
  'standard',
  'medium',
  (SELECT id FROM formulas WHERE formula_text = '100 + 10 * CASTER_LEVEL'),  -- 100 ft. + 10 ft./level
  'One living creature',
  '1 round',
  true,   -- Allows SR
  'This spell functions like daze, but daze monster can affect any one living creature of any type. Creatures of 7 or more HD are not affected.'
);

-- Step 2: Link to spell classes and levels
INSERT INTO spell_class_levels (spell_id, class_id, spell_level) VALUES
  ((SELECT id FROM spells WHERE name = 'Daze Monster'), (SELECT id FROM classes WHERE name = 'Bard'), 2),
  ((SELECT id FROM spells WHERE name = 'Daze Monster'), (SELECT id FROM classes WHERE name = 'Sorcerer'), 2),
  ((SELECT id FROM spells WHERE name = 'Daze Monster'), (SELECT id FROM classes WHERE name = 'Wizard'), 2);

-- Step 3: Define spell components
INSERT INTO spell_components (spell_id, component_type_id, component_description) VALUES
  ((SELECT id FROM spells WHERE name = 'Daze Monster'), (SELECT id FROM spell_component_types WHERE code = 'V'), NULL),
  ((SELECT id FROM spells WHERE name = 'Daze Monster'), (SELECT id FROM spell_component_types WHERE code = 'S'), NULL);

-- Step 4: Link spell descriptors
INSERT INTO spell_descriptors_link (spell_id, spell_descriptor_id) VALUES
  ((SELECT id FROM spells WHERE name = 'Daze Monster'), (SELECT id FROM spell_descriptors WHERE name = 'Mind-Affecting'));

-- Step 5: Define condition granted by spell
-- This spell grants the "Dazed" condition for 1 round
INSERT INTO spell_granted_conditions (
  spell_id,
  condition_id,
  duration_type,
  duration_formula_id,
  allows_save
) VALUES (
  (SELECT id FROM spells WHERE name = 'Daze Monster'),
  (SELECT id FROM conditions WHERE name = 'Dazed'),  -- Links to existing Dazed condition
  'rounds_per_level',
  (SELECT id FROM formulas WHERE formula_text = '1'),  -- 1 round duration
  true  -- Will save negates
);

-- Step 6: Define HD prerequisite (target must have 6 HD or less)
-- First, create the prerequisite group
INSERT INTO prerequisite_groups (logic_operator, description) VALUES
  ('AND', 'Daze Monster: Target must have 6 HD or less');

-- Create special prerequisite for runtime validation
INSERT INTO special_prerequisites (description, validation_type, validation_context) VALUES
  ('target_hd <= 6', 'runtime_condition', 'Validates target has 6 or fewer Hit Dice');

-- Link special prerequisite to group
INSERT INTO prerequisite_conditions (
  prerequisite_group_id,
  prerequisite_type,
  special_prerequisite_id
) VALUES (
  (SELECT id FROM prerequisite_groups WHERE description = 'Daze Monster: Target must have 6 HD or less'),
  'special',
  (SELECT id FROM special_prerequisites WHERE description = 'target_hd <= 6')
);

-- Link prerequisite group to spell (via spell_prerequisites junction table)
-- Note: This table may need to be created in spells.sql if it doesn't exist yet
INSERT INTO spell_prerequisites (spell_id, prerequisite_group_id) VALUES
  ((SELECT id FROM spells WHERE name = 'Daze Monster'),
   (SELECT id FROM prerequisite_groups WHERE description = 'Daze Monster: Target must have 6 HD or less'));

-- Step 7: Define saving throw
INSERT INTO spell_saves (
  spell_id,
  throw_id,
  save_dc_formula_id,
  save_result_type,
  effect_on_failed_save_id,
  effect_on_successful_save_id
) VALUES (
  (SELECT id FROM spells WHERE name = 'Daze Monster'),
  (SELECT id FROM throws WHERE name = 'Will Save'),
  (SELECT id FROM formulas WHERE formula_text = '10 + SPELL_LEVEL + ABILITY_MODIFIER'),
  'negates',  -- Will save negates entire effect
  NULL,       -- Uses spell_granted_conditions on failed save
  NULL        -- No effect on successful save
);

-- =====================================================
-- RUNTIME EXAMPLE: DAZE MONSTER
-- =====================================================
--
-- When cast at runtime (Phase 3):
--
-- 1. Check prerequisites:
-- SELECT
--   CASE
--     WHEN c.monster_template_id IS NOT NULL THEN mt.hit_dice_count <= 6
--     ELSE c.total_character_level <= 6
--   END AS can_target
-- FROM characters c
-- LEFT JOIN monster_templates mt ON c.monster_template_id = mt.id
-- WHERE c.id = ?;  -- Target creature
--
-- 2. If passes prerequisites, roll Will save:
-- DC = 10 + spell_level (2) + caster's ability modifier (INT/CHA)
--
-- 3. If fails save, apply Dazed condition:
-- INSERT INTO character_active_conditions (
--   character_id,
--   condition_id,
--   source_type,
--   source_id,
--   duration_remaining_rounds
-- ) VALUES (
--   target_character_id,
--   (SELECT id FROM conditions WHERE name = 'Dazed'),
--   'spell',
--   spell_instance_id,
--   1  -- 1 round duration
-- );

-- =====================================================
-- EXAMPLE 2: DETECT EVIL
-- =====================================================
-- Source: SRD Divination
-- Level: Clr 1
-- Range: 60 ft. cone
-- Effect: Detects evil auras with progressive information
--
-- Key Features:
-- - Uses narrative_effects for detection logic (too complex for structured effects)
-- - Runtime queries alignments, HD, creature types from database
-- - No saves, no SR, no direct effects - pure divination
-- - Aura power calculation done at runtime based on creature properties

-- Step 1: Insert spell into spells table
INSERT INTO spells (
  name,
  spell_school_id,
  spell_subschool_id,
  is_arcane,
  is_divine,
  casting_time,
  range_type,
  range_value,
  area_of_effect,
  duration,
  allows_spell_resistance,
  description
) VALUES (
  'Detect Evil',
  (SELECT id FROM spell_schools WHERE name = 'Divination'),
  NULL,   -- No subschool
  false,  -- Not arcane
  true,   -- Divine (Cleric only)
  'standard',
  'special',  -- 60 ft. cone (special range)
  60,
  '60-ft. cone-shaped emanation',
  'Concentration, up to 10 min./level (D)',
  false,  -- No SR
  'You can sense the presence of evil. The amount of information revealed depends on how long you study a particular area or subject. Progressive information gathering over 3 rounds of concentration.'
);

-- Step 2: Link to spell classes and levels
INSERT INTO spell_class_levels (spell_id, class_id, spell_level) VALUES
  ((SELECT id FROM spells WHERE name = 'Detect Evil'), (SELECT id FROM classes WHERE name = 'Cleric'), 1);

-- Step 3: Define spell components
INSERT INTO spell_components (spell_id, component_type_id, component_description) VALUES
  ((SELECT id FROM spells WHERE name = 'Detect Evil'), (SELECT id FROM spell_component_types WHERE code = 'V'), NULL),
  ((SELECT id FROM spells WHERE name = 'Detect Evil'), (SELECT id FROM spell_component_types WHERE code = 'S'), NULL),
  ((SELECT id FROM spells WHERE name = 'Detect Evil'), (SELECT id FROM spell_component_types WHERE code = 'DF'), 'Divine focus');

-- Step 4: Create narrative effect for detection mechanics
-- This is too complex for structured effects, so we use narrative_effects
INSERT INTO effects (
  name,
  effect_type,
  is_beneficial,
  is_magical,
  description
) VALUES (
  'Detect Evil - Detection',
  'narrative',  -- Uses narrative effect type for complex detection logic
  true,
  true,
  'Detects evil auras within 60-ft cone with progressive information gathering over 3 rounds'
);

-- Step 5: Create narrative_effects entry with full detection rules
INSERT INTO narrative_effects (
  effect_id,
  narrative_text
) VALUES (
  (SELECT id FROM effects WHERE name = 'Detect Evil - Detection'),
  '### Progressive Information Gathering

**1st Round:** Presence or absence of evil within the area.

**2nd Round:** Number of evil auras (creatures, objects, or spells) in the area and the power of the most potent evil aura present.

**3rd Round:** The power and location of each aura. If an aura is outside your line of sight, then you discern its direction but not its exact location.

### Aura Power by Creature Type and HD

**Evil Creature (general):**
- Faint: ≤10 HD
- Moderate: 11-25 HD
- Strong: 26-50 HD
- Overwhelming: 51+ HD

**Undead:**
- Faint: ≤2 HD
- Moderate: 3-8 HD
- Strong: 9-20 HD
- Overwhelming: 21+ HD

**Evil Outsider:**
- Faint: ≤1 HD
- Moderate: 2-4 HD
- Strong: 5-10 HD
- Overwhelming: 11+ HD

**Cleric of Evil Deity (class levels):**
- Faint: 1
- Moderate: 2-4
- Strong: 5-10
- Overwhelming: 11+

**Evil Magic Item or Spell (caster level):**
- Faint: ≤2nd
- Moderate: 3rd-8th
- Strong: 9th-20th
- Overwhelming: 21st+

### Lingering Aura

An evil aura lingers after its original source dissipates or is destroyed:
- Faint: 1d6 rounds
- Moderate: 1d6 minutes
- Strong: 1d6×10 minutes
- Overwhelming: 1d6 days

### Special Effect: Overwhelming Aura Stun

If you are of good alignment, and the strongest evil aura''s power is overwhelming, and the HD or level of the aura''s source is at least twice your character level, you are **stunned for 1 round** and the spell ends.

### Runtime Implementation

Application layer detects creatures/objects with evil alignment within 60-ft cone, calculates aura power based on HD/level and creature type, and presents information progressively over 3 rounds of concentration.'
);

-- Step 6: Link effect to spell (all caster levels use same narrative effect)
INSERT INTO spell_effects (
  spell_id,
  caster_level,
  effect_id,
  applies_when
) VALUES (
  (SELECT id FROM spells WHERE name = 'Detect Evil'),
  1,  -- Same effect for all caster levels
  (SELECT id FROM effects WHERE name = 'Detect Evil - Detection'),
  NULL  -- Always applies
);

-- =====================================================
-- RUNTIME EXAMPLE: DETECT EVIL
-- =====================================================
--
-- When cast at runtime (Phase 3):
--
-- Scan for evil creatures in 60-ft cone from caster position:
--
-- SELECT
--   c.id,
--   c.name,
--   a.code AS alignment,
--   CASE
--     WHEN c.monster_template_id IS NOT NULL THEN mt.hit_dice_count
--     ELSE c.total_character_level
--   END AS hd_or_level,
--   ct.name AS creature_type,
--   -- Calculate aura power based on creature type and HD
--   CASE
--     -- Undead creatures (stronger auras)
--     WHEN ct.name = 'Undead' THEN
--       CASE
--         WHEN hd_or_level <= 2 THEN 'Faint'
--         WHEN hd_or_level <= 8 THEN 'Moderate'
--         WHEN hd_or_level <= 20 THEN 'Strong'
--         ELSE 'Overwhelming'
--       END
--     -- Evil outsiders (stronger auras)
--     WHEN ct.name = 'Outsider' AND 'evil' = ANY(c.creature_subtypes) THEN
--       CASE
--         WHEN hd_or_level <= 1 THEN 'Faint'
--         WHEN hd_or_level <= 4 THEN 'Moderate'
--         WHEN hd_or_level <= 10 THEN 'Strong'
--         ELSE 'Overwhelming'
--       END
--     -- Clerics of evil deities (class level based)
--     WHEN EXISTS (
--       SELECT 1 FROM character_classes cc
--       JOIN classes cl ON cc.class_id = cl.id
--       WHERE cc.character_id = c.id AND cl.name = 'Cleric'
--         AND c.deity_alignment_code IN ('LE', 'NE', 'CE')
--     ) THEN
--       CASE
--         WHEN hd_or_level = 1 THEN 'Faint'
--         WHEN hd_or_level <= 4 THEN 'Moderate'
--         WHEN hd_or_level <= 10 THEN 'Strong'
--         ELSE 'Overwhelming'
--       END
--     -- Generic evil creature
--     ELSE
--       CASE
--         WHEN hd_or_level <= 10 THEN 'Faint'
--         WHEN hd_or_level <= 25 THEN 'Moderate'
--         WHEN hd_or_level <= 50 THEN 'Strong'
--         ELSE 'Overwhelming'
--       END
--   END AS aura_power
-- FROM characters c
-- JOIN alignments a ON c.alignment_id = a.id
-- LEFT JOIN monster_templates mt ON c.monster_template_id = mt.id
-- LEFT JOIN creature_types ct ON mt.creature_type_id = ct.id
-- WHERE a.code IN ('LE', 'NE', 'CE')  -- Evil alignments only
--   AND distance_from_caster <= 60    -- Within range
--   AND in_cone_area = true;          -- Within cone emanation
--
-- Round 1: Return COUNT > 0 (presence/absence)
-- Round 2: Return COUNT and MAX(aura_power)
-- Round 3: Return full list with power and location for each
--
-- Check for stun effect:
-- IF caster_alignment = 'LG' OR caster_alignment = 'NG' OR caster_alignment = 'CG'
--   AND strongest_aura = 'Overwhelming'
--   AND strongest_source_hd >= (caster_level * 2)
-- THEN
--   Apply Stunned condition for 1 round
--   End spell

-- =====================================================
-- ADDITIONAL NOTES
-- =====================================================

-- Junction table needed for spell prerequisites (add to spells.sql if not present):
--
-- CREATE TABLE spell_prerequisites (
--   spell_id INTEGER NOT NULL REFERENCES spells(id) ON DELETE CASCADE,
--   prerequisite_group_id INTEGER NOT NULL REFERENCES prerequisite_groups(id) ON DELETE RESTRICT,
--   PRIMARY KEY (spell_id, prerequisite_group_id)
-- );
--
-- CREATE INDEX idx_spell_prerequisites_spell ON spell_prerequisites(spell_id);
-- CREATE INDEX idx_spell_prerequisites_group ON spell_prerequisites(prerequisite_group_id);
--
-- COMMENT ON TABLE spell_prerequisites IS 'Links spells to prerequisite groups (e.g., HD limits, creature type restrictions)';

-- =====================================================
-- EXAMPLE 3: ALTER SELF
-- =====================================================
-- Source: SRD Transmutation
-- Level: Brd 2, Sor/Wiz 2
-- Duration: 10 min./level (D)
-- Effect: Assume form of creature (same type, within 1 size category, max 5 HD)
--
-- Key Features:
-- - Uses spell_available_forms to link to monster_templates library
-- - Restriction filters: same type, size difference, HD limit via formula
-- - Property transfer flags: grants physical qualities, blocks special abilities
-- - Reuses entire monster_templates catalog (~700 forms) instead of enumerating
-- - Runtime validates restrictions and applies chosen form's properties

-- Step 1: Insert spell into spells table
INSERT INTO spells (
  name,
  spell_school_id,
  spell_subschool_id,
  is_arcane,
  is_divine,
  casting_time,
  range_type,
  range_value,
  area_of_effect,
  duration,
  allows_spell_resistance,
  description
) VALUES (
  'Alter Self',
  (SELECT id FROM spell_schools WHERE name = 'Transmutation'),
  NULL,   -- No subschool
  true,   -- Arcane (Brd, Sor/Wiz)
  false,  -- Not divine
  'standard',
  'personal',
  NULL,   -- Personal range has no value
  'You',
  '10 min./level (D)',
  false,  -- No SR (personal spell)
  'You assume the form of a creature of the same type as your normal form. The new form must be within one size category of your normal size. The maximum HD of an assumed form is equal to your caster level, to a maximum of 5 HD at 5th level. You retain your own ability scores but gain the physical qualities of the new form.'
);

-- Step 2: Link to spell classes and levels
INSERT INTO spell_class_levels (spell_id, class_id, spell_level) VALUES
  ((SELECT id FROM spells WHERE name = 'Alter Self'), (SELECT id FROM classes WHERE name = 'Bard'), 2),
  ((SELECT id FROM spells WHERE name = 'Alter Self'), (SELECT id FROM classes WHERE name = 'Sorcerer'), 2),
  ((SELECT id FROM spells WHERE name = 'Alter Self'), (SELECT id FROM classes WHERE name = 'Wizard'), 2);

-- Step 3: Define spell components
INSERT INTO spell_components (spell_id, component_type_id, component_description) VALUES
  ((SELECT id FROM spells WHERE name = 'Alter Self'), (SELECT id FROM spell_component_types WHERE code = 'V'), NULL),
  ((SELECT id FROM spells WHERE name = 'Alter Self'), (SELECT id FROM spell_component_types WHERE code = 'S'), NULL);

-- Step 4: Define form selection rules via spell_available_forms
-- This is the key table for polymorph-type spells - links to monster_templates
INSERT INTO spell_available_forms (
  spell_id,
  requires_same_creature_type,
  max_size_difference,
  max_hd_formula_id,
  fixed_max_hd,
  allowed_creature_type_ids,
  grants_size,
  grants_natural_armor,
  grants_movement,
  grants_natural_weapons,
  grants_racial_skill_bonuses,
  grants_racial_bonus_feats,
  blocks_extraordinary_abilities,
  blocks_supernatural_abilities,
  blocks_spell_like_abilities,
  blocks_senses,
  description
) VALUES (
  (SELECT id FROM spells WHERE name = 'Alter Self'),
  true,  -- Must choose creature of SAME type (Humanoid → Humanoid, etc.)
  1,     -- Within ONE size category (Medium can choose Small or Large)
  (SELECT id FROM formulas WHERE formula_text = 'MIN(CASTER_LEVEL, 5)'),  -- Max HD = caster level, capped at 5
  NULL,  -- Using formula, not fixed value
  NULL,  -- Any creature type allowed (as long as it's same as caster's type)

  -- What you GAIN from chosen form:
  true,  -- grants_size: Assume size of chosen form
  true,  -- grants_natural_armor: Gain natural armor bonus
  true,  -- grants_movement: Gain movement speeds (land/fly/swim/burrow/climb up to 120ft fly, 60ft other)
  true,  -- grants_natural_weapons: Gain natural attacks (claws, bite, etc.)
  true,  -- grants_racial_skill_bonuses: Gain racial bonuses to skills
  true,  -- grants_racial_bonus_feats: Gain racial bonus feats

  -- What you DO NOT GAIN from chosen form:
  true,  -- blocks_extraordinary_abilities: NO extraordinary abilities (no darkvision, scent, etc.)
  true,  -- blocks_supernatural_abilities: NO supernatural abilities
  true,  -- blocks_spell_like_abilities: NO spell-like abilities
  true,  -- blocks_senses: NO special senses (covered by extraordinary block)

  'Assume form of creature of same type, within one size category, max HD equal to caster level (max 5 HD). Gain size, natural armor, movement (max 120ft fly/60ft other), natural weapons, and racial bonuses. Do NOT gain extraordinary abilities, supernatural abilities, spell-like abilities, or special senses.'
);

-- Step 5: Add the +10 Disguise bonus effect
-- This is a separate structured effect, not part of the polymorph mechanic
INSERT INTO effects (
  name,
  effect_type,
  is_beneficial,
  is_magical,
  description
) VALUES (
  'Alter Self - Disguise Bonus',
  'throw_modifier',
  true,
  true,
  '+10 bonus on Disguise checks when using Alter Self to create a disguise'
);

-- Link the Disguise bonus to a modifier definition
INSERT INTO throw_modifier_effects (
  effect_id,
  modifier_definition_id,
  throw_id,
  applies_when
) VALUES (
  (SELECT id FROM effects WHERE name = 'Alter Self - Disguise Bonus'),
  (SELECT id FROM modifier_definitions WHERE bonus_type_id = (SELECT id FROM bonus_types WHERE name = 'circumstance') AND base_value = 10),
  (SELECT id FROM throws WHERE name = 'Disguise' AND throw_category = 'skill_check'),
  'when using spell to create disguise'
);

-- Link the Disguise bonus effect to the spell
INSERT INTO spell_effects (
  spell_id,
  caster_level,
  effect_id,
  applies_when
) VALUES (
  (SELECT id FROM spells WHERE name = 'Alter Self'),
  1,  -- Same for all caster levels
  (SELECT id FROM effects WHERE name = 'Alter Self - Disguise Bonus'),
  'when using spell to create disguise'
);

-- =====================================================
-- RUNTIME EXAMPLE: ALTER SELF
-- =====================================================
--
-- When cast at runtime (Phase 3):
--
-- Step 1: Query available forms based on caster's creature type, size, and level
--
-- SELECT
--   mt.id,
--   mt.name,
--   mt.hit_dice_count AS hd,
--   sc.name AS size,
--   ct.name AS creature_type,
--   mt.land_speed,
--   mt.fly_speed,
--   mt.swim_speed,
--   mt.climb_speed,
--   mt.burrow_speed,
--   mt.natural_armor_bonus
-- FROM monster_templates mt
-- JOIN spell_available_forms saf ON saf.spell_id = (SELECT id FROM spells WHERE name = 'Alter Self')
-- JOIN size_categories sc ON mt.size_category_id = sc.id
-- JOIN creature_types ct ON mt.creature_type_id = ct.id
-- JOIN characters c ON c.id = ?  -- The caster
-- WHERE
--   -- Same creature type (Humanoid caster can only choose Humanoid forms)
--   mt.creature_type_id = c.creature_type_id
--
--   -- Size restriction (within 1 category: Medium can choose Small, Medium, or Large)
--   AND ABS(mt.size_category_id - c.size_category_id) <= 1
--
--   -- HD restriction (max = MIN(caster_level, 5))
--   AND mt.hit_dice_count <= LEAST(get_caster_level(c.id), 5)
--
-- ORDER BY mt.name;
--
-- Example results for Medium Humanoid 5th-level caster:
-- - Goblin (Small, 1 HD) ✓
-- - Human Commoner (Medium, 1 HD) ✓
-- - Orc (Medium, 1 HD) ✓
-- - Ogre (Large, 4 HD) ✓
-- - Troll (Large, 6 HD) ✗ (too many HD)
-- - Wolf (Medium, 2 HD) ✗ (wrong creature type - Animal not Humanoid)
--
-- Step 2: Player selects form (e.g., "Goblin")
--
-- Step 3: Apply properties from chosen form
--
-- WITH chosen_form AS (
--   SELECT mt.*, saf.*
--   FROM monster_templates mt
--   CROSS JOIN spell_available_forms saf
--   WHERE mt.id = ?  -- Chosen template (Goblin)
--     AND saf.spell_id = (SELECT id FROM spells WHERE name = 'Alter Self')
-- )
-- -- Size change (grants_size = true)
-- UPDATE characters
-- SET size_category_id = (SELECT size_category_id FROM chosen_form)
-- WHERE id = ?;  -- Caster
--
-- -- Natural armor (grants_natural_armor = true)
-- INSERT INTO character_active_effects (character_id, effect_id, source_type, source_id, duration_minutes)
-- SELECT
--   ?,  -- Caster ID
--   (SELECT id FROM effects WHERE name = 'Natural Armor +' || cf.natural_armor_bonus),
--   'spell',
--   ?,  -- Spell instance ID
--   10 * get_caster_level(?)  -- 10 min/level
-- FROM chosen_form cf
-- WHERE cf.natural_armor_bonus > 0;
--
-- -- Movement speeds (grants_movement = true)
-- -- Cap at 120ft fly, 60ft other per spell description
-- INSERT INTO character_active_effects (character_id, effect_id, source_type, source_id, duration_minutes)
-- SELECT
--   ?,  -- Caster ID
--   create_or_get_movement_effect(
--     'land_speed', LEAST(cf.land_speed, 60),
--     'fly_speed', LEAST(cf.fly_speed, 120),
--     'swim_speed', LEAST(cf.swim_speed, 60),
--     'climb_speed', LEAST(cf.climb_speed, 60),
--     'burrow_speed', LEAST(cf.burrow_speed, 60)
--   ),
--   'spell',
--   ?,
--   10 * get_caster_level(?)
-- FROM chosen_form cf;
--
-- -- Natural weapons (grants_natural_weapons = true)
-- INSERT INTO character_natural_attacks (character_id, natural_attack_id, source_type, source_id)
-- SELECT
--   ?,  -- Caster ID
--   mna.id,
--   'spell',
--   ?  -- Spell instance ID
-- FROM chosen_form cf
-- JOIN monster_natural_attacks mna ON mna.monster_template_id = cf.id;
--
-- -- Racial skill bonuses (grants_racial_skill_bonuses = true)
-- INSERT INTO character_active_effects (character_id, effect_id, source_type, source_id, duration_minutes)
-- SELECT
--   ?,
--   create_skill_bonus_effect(mts.skill_id, mts.ranks),  -- Convert ranks to bonus
--   'spell',
--   ?,
--   10 * get_caster_level(?)
-- FROM chosen_form cf
-- JOIN monster_template_skills mts ON mts.monster_template_id = cf.id;
--
-- -- Racial bonus feats (grants_racial_bonus_feats = true)
-- INSERT INTO character_temporary_feats (character_id, feat_id, source_type, source_id, duration_minutes)
-- SELECT
--   ?,
--   mtf.feat_id,
--   'spell',
--   ?,
--   10 * get_caster_level(?)
-- FROM chosen_form cf
-- JOIN monster_template_feats mtf ON mtf.monster_template_id = cf.id;
--
-- -- DO NOT apply (blocked by flags):
-- -- ✗ Extraordinary abilities (blocks_extraordinary_abilities = true)
-- -- ✗ Supernatural abilities (blocks_supernatural_abilities = true)
-- -- ✗ Spell-like abilities (blocks_spell_like_abilities = true)
-- -- ✗ Special senses like darkvision (blocks_senses = true)
--
-- Step 4: When spell ends (duration expires or dismissed), revert all changes
-- DELETE FROM character_active_effects WHERE source_id = spell_instance_id;
-- DELETE FROM character_natural_attacks WHERE source_id = spell_instance_id;
-- DELETE FROM character_temporary_feats WHERE source_id = spell_instance_id;
-- UPDATE characters SET size_category_id = original_size WHERE id = caster_id;

-- =====================================================
-- EXAMPLE 4: ENERGY DRAIN
-- =====================================================
-- Source: SRD Necromancy [Evil]
-- Level: Clr 9, Sor/Wiz 9
-- Components: V, S
-- Effect: Ray inflicts 2d4 negative levels (living) or grants temp HP (undead)
--
-- Key Features:
-- - Requires ranged touch attack (uses spell_attack_rolls table)
-- - Variable negative levels (2d4) via formula
-- - Conditional effects based on target type (living vs undead)
-- - Manual save/dismissal pattern (no automatic game-time tracking)
-- - Uses applies_when for target-type-specific effects
-- - Demonstrates attack spell + condition pattern

-- Step 1: Insert spell into spells table
INSERT INTO spells (
  name,
  spell_school_id,
  spell_subschool_id,
  is_arcane,
  is_divine,
  casting_time,
  range_type,
  range_formula_id,
  area_of_effect,
  duration,
  allows_spell_resistance,
  description
) VALUES (
  'Energy Drain',
  (SELECT id FROM spell_schools WHERE name = 'Necromancy'),
  NULL,  -- No subschool
  true,  -- Arcane (Sor/Wiz)
  true,  -- Divine (Cleric)
  'standard',
  'close',
  (SELECT id FROM formulas WHERE formula_text = '25 + 5 * (CASTER_LEVEL / 2)'),  -- 25 ft. + 5 ft./2 levels
  'Ray',
  'Instantaneous',
  true,  -- Allows SR
  'This spell functions like enervation, except that the creature struck gains 2d4 negative levels. Twenty-four hours after gaining them, the subject must make a Fortitude saving throw (DC = spell''s save DC) for each negative level. If the save succeeds, that negative level is removed. If it fails, the negative level goes away, but one of the subject''s character levels is permanently drained. An undead creature struck by the ray gains 2d4×5 temporary hit points for 1 hour.'
);

-- Step 2: Link to spell classes and levels
INSERT INTO spell_class_levels (spell_id, class_id, spell_level) VALUES
  ((SELECT id FROM spells WHERE name = 'Energy Drain'), (SELECT id FROM classes WHERE name = 'Cleric'), 9),
  ((SELECT id FROM spells WHERE name = 'Energy Drain'), (SELECT id FROM classes WHERE name = 'Sorcerer'), 9),
  ((SELECT id FROM spells WHERE name = 'Energy Drain'), (SELECT id FROM classes WHERE name = 'Wizard'), 9);

-- Step 3: Define spell components
INSERT INTO spell_components (spell_id, component_type_id, component_description) VALUES
  ((SELECT id FROM spells WHERE name = 'Energy Drain'), (SELECT id FROM spell_component_types WHERE code = 'V'), NULL),
  ((SELECT id FROM spells WHERE name = 'Energy Drain'), (SELECT id FROM spell_component_types WHERE code = 'S'), NULL);

-- Step 4: Link spell descriptors
INSERT INTO spell_descriptors_link (spell_id, spell_descriptor_id) VALUES
  ((SELECT id FROM spells WHERE name = 'Energy Drain'), (SELECT id FROM spell_descriptors WHERE name = 'Evil'));

-- Step 5: Define ranged touch attack requirement
-- This spell requires a ranged touch attack to hit before applying effects
INSERT INTO spell_attack_rolls (
  spell_id,
  throw_id,
  attack_type
) VALUES (
  (SELECT id FROM spells WHERE name = 'Energy Drain'),
  (SELECT id FROM throws WHERE name = 'Ranged Touch Attack'),
  'ranged_touch'
);

-- Step 6: Create "Negative Levels" condition if not already exists
-- This condition represents the mechanical penalty of negative levels
INSERT INTO conditions (
  name,
  condition_category,
  is_supernatural,
  can_stack,
  description
) VALUES (
  'Negative Levels',
  'debuff',
  true,
  true,  -- Multiple negative levels can stack
  'For each negative level possessed, a creature takes a cumulative -1 penalty on all ability checks, attack rolls, combat maneuver checks, Combat Maneuver Defense, saving throws, and skill checks. In addition, the creature reduces its current and total hit points by 5 for each negative level it possesses. The creature is also treated as one level lower for the purpose of level-dependent variables (such as spellcasting) for each negative level possessed. Spellcasters do not lose any prepared spells or slots as a result of negative levels. If a creature''s negative levels equal or exceed its total Hit Dice, it dies.'
);

-- Step 7: Link condition mechanical effects (stat penalties)
-- Each negative level imposes -1 to various rolls
INSERT INTO condition_stat_effects (
  condition_id,
  stat_effect_type,
  ability_score_id,
  value_formula_id,
  duration_type
) VALUES
  -- -1 penalty to attack rolls
  ((SELECT id FROM conditions WHERE name = 'Negative Levels'),
   'attack_modifier',
   NULL,
   (SELECT id FROM formulas WHERE formula_text = '-1'),
   'while_active'),

  -- -1 penalty to saving throws
  ((SELECT id FROM conditions WHERE name = 'Negative Levels'),
   'saving_throw_modifier',
   NULL,
   (SELECT id FROM formulas WHERE formula_text = '-1'),
   'while_active'),

  -- -1 penalty to skill checks
  ((SELECT id FROM conditions WHERE name = 'Negative Levels'),
   'skill_modifier',
   NULL,
   (SELECT id FROM formulas WHERE formula_text = '-1'),
   'while_active'),

  -- -5 current/max hit points
  ((SELECT id FROM conditions WHERE name = 'Negative Levels'),
   'hp_modifier',
   NULL,
   (SELECT id FROM formulas WHERE formula_text = '-5'),
   'while_active');

-- Step 8: Define variable negative levels granted to LIVING creatures
-- Uses spell_granted_conditions with variable amount (2d4)
INSERT INTO spell_granted_conditions (
  spell_id,
  condition_id,
  duration_type,
  duration_formula_id,
  allows_save,
  variable_amount,
  amount_formula_id,
  applies_when
) VALUES (
  (SELECT id FROM spells WHERE name = 'Energy Drain'),
  (SELECT id FROM conditions WHERE name = 'Negative Levels'),
  'permanent',  -- Tracked as permanent until manually dismissed
  NULL,         -- No formula needed for permanent
  true,         -- Fort save after 24 hours (handled manually)
  true,         -- Amount varies per casting
  (SELECT id FROM formulas WHERE formula_text = '2d4'),  -- 2d4 negative levels
  'target_is_living'  -- Only applies to living creatures
);

-- Step 9: Create temporary hit points effect for UNDEAD targets
-- Undead creatures gain temporary HP instead of negative levels
INSERT INTO effects (
  name,
  effect_type,
  is_beneficial,
  is_magical,
  description
) VALUES (
  'Energy Drain - Undead Temp HP',
  'hp_modifier',
  true,  -- Beneficial for undead
  true,
  'Undead creature gains 2d4×5 temporary hit points for 1 hour'
);

-- Link to hp_modifier_effects
INSERT INTO hp_modifier_effects (
  effect_id,
  modifier_type,
  hp_change_formula_id,
  is_temporary,
  duration_type
) VALUES (
  (SELECT id FROM effects WHERE name = 'Energy Drain - Undead Temp HP'),
  'temp_hp',
  (SELECT id FROM formulas WHERE formula_text = '2d4 * 5'),
  true,  -- Temporary hit points
  'hours'
);

-- Step 10: Link undead temp HP effect to spell (conditional)
INSERT INTO spell_effects (
  spell_id,
  caster_level,
  effect_id,
  duration_value,
  applies_when
) VALUES (
  (SELECT id FROM spells WHERE name = 'Energy Drain'),
  1,  -- Same for all caster levels
  (SELECT id FROM effects WHERE name = 'Energy Drain - Undead Temp HP'),
  1,  -- 1 hour duration
  'target_is_undead'  -- Only applies when target is undead
);

-- Step 11: Define Fortitude save (for permanent level drain)
-- Save occurs 24 hours after gaining negative levels (handled manually)
INSERT INTO spell_saves (
  spell_id,
  throw_id,
  save_dc_formula_id,
  save_result_type,
  effect_on_failed_save_id,
  effect_on_successful_save_id
) VALUES (
  (SELECT id FROM spells WHERE name = 'Energy Drain'),
  (SELECT id FROM throws WHERE name = 'Fortitude Save'),
  (SELECT id FROM formulas WHERE formula_text = '10 + SPELL_LEVEL + ABILITY_MODIFIER'),
  'partial',  -- Save is made 24 hours later, per negative level
  NULL,       -- Failed save = level permanently drained (manual tracking)
  NULL        -- Successful save = negative level removed (manual dismissal)
);

-- =====================================================
-- RUNTIME EXAMPLE: ENERGY DRAIN
-- =====================================================
--
-- When cast at runtime (Phase 3):
--
-- Step 1: Make ranged touch attack
--
-- SELECT make_attack_roll(
--   caster_id,
--   'ranged_touch',
--   target_ac
-- ) AS hits;
--
-- If attack misses, spell has no effect.
--
-- Step 2: If attack hits, check spell resistance
--
-- SELECT check_spell_resistance(
--   target_id,
--   spell_id,
--   caster_level
-- ) AS resisted;
--
-- If spell is resisted, no effect.
--
-- Step 3: If attack hits and SR fails, determine target type and apply effect
--
-- -- Check if target is undead
-- SELECT
--   CASE
--     WHEN mt.creature_type_id = (SELECT id FROM creature_types WHERE name = 'Undead')
--     THEN 'undead'
--     ELSE 'living'
--   END AS target_type
-- FROM characters c
-- LEFT JOIN monster_templates mt ON c.monster_template_id = mt.id
-- WHERE c.id = target_id;
--
-- Step 4a: If target is LIVING, apply negative levels
--
-- -- Roll 2d4 for number of negative levels
-- SELECT floor(random() * 4 + 1)::int + floor(random() * 4 + 1)::int AS negative_levels_count;
--
-- -- Apply each negative level as a separate condition instance (stacking)
-- INSERT INTO character_active_conditions (
--   character_id,
--   condition_id,
--   source_type,
--   source_id,
--   stacks_count,
--   notes
-- )
-- SELECT
--   target_id,
--   (SELECT id FROM conditions WHERE name = 'Negative Levels'),
--   'spell',
--   spell_instance_id,
--   negative_levels_count,  -- Number of negative levels to apply
--   'Energy Drain - Fort save required after 24 game hours (manual tracking)'
-- ;
--
-- -- MANUAL TRACKING REQUIRED:
-- -- Players track 24 in-game hours
-- -- After 24 hours, for each negative level:
-- --   - Roll Fort save (DC = 10 + spell level 9 + caster ability modifier)
-- --   - If SUCCEEDS: Manually dismiss that negative level from character_active_conditions
-- --   - If FAILS: Manually note permanent level drain, then dismiss negative level
-- --
-- -- No automatic game-time tracking in database - players handle timing
--
-- Step 4b: If target is UNDEAD, apply temporary hit points
--
-- -- Roll 2d4×5 for temporary HP
-- SELECT (floor(random() * 4 + 1)::int + floor(random() * 4 + 1)::int) * 5 AS temp_hp;
--
-- -- Apply temporary HP
-- INSERT INTO character_active_effects (
--   character_id,
--   effect_id,
--   source_type,
--   source_id,
--   duration_remaining_hours,
--   value_override
-- ) VALUES (
--   target_id,
--   (SELECT id FROM effects WHERE name = 'Energy Drain - Undead Temp HP'),
--   'spell',
--   spell_instance_id,
--   1,  -- 1 hour duration
--   temp_hp
-- );
--
-- -- Temporary HP automatically expire after 1 hour (no manual tracking needed)
--
-- Step 5: Permanent Level Drain (when Fort save fails after 24 hours)
--
-- -- This is tracked manually by players
-- -- When a Fort save fails, the player notes:
-- --   1. Remove the negative level condition
-- --   2. Record permanent level drain in character notes/history
-- --   3. Recalculate character's effective level for all purposes
-- --
-- -- No database table needed for permanent level drain - it's part of character progression tracking
-- -- Similar to how you wouldn't create a special table for "permanently dead characters"

-- =====================================================
-- EXAMPLE 5: FIREBALL
-- =====================================================
-- Source: SRD Evocation [Fire]
-- Level: Sor/Wiz 3
-- Components: V, S, M (a tiny ball of bat guano and sulfur)
-- Effect: 20-ft radius spread deals 1d6 fire damage per caster level (max 10d6)
--
-- Key Features:
-- - Area damage spell (affects all creatures in radius)
-- - Variable damage based on caster level (1d6 per level, max 10d6)
-- - Fire damage type (links to damage_types reference table)
-- - Reflex save for half damage (save_result_type = 'half')
-- - Material component with description
-- - Demonstrates basic "blasting spell" pattern

-- Step 1: Insert spell into spells table
INSERT INTO spells (
  name,
  spell_school_id,
  spell_subschool_id,
  is_arcane,
  is_divine,
  casting_time,
  range_type,
  range_formula_id,
  area_of_effect,
  duration,
  allows_spell_resistance,
  description
) VALUES (
  'Fireball',
  (SELECT id FROM spell_schools WHERE name = 'Evocation'),
  NULL,  -- No subschool
  true,  -- Arcane (Sor/Wiz)
  false, -- Not divine
  'standard',
  'long',
  (SELECT id FROM formulas WHERE formula_text = '400 + 40 * CASTER_LEVEL'),  -- 400 ft. + 40 ft./level
  '20-ft.-radius spread',
  'Instantaneous',
  true,  -- Allows SR
  'A fireball spell is an explosion of flame that detonates with a low roar and deals 1d6 points of fire damage per caster level (maximum 10d6) to every creature within the area. Unattended objects also take this damage. The explosion creates almost no pressure. You point your finger and determine the range (distance and height) at which the fireball is to burst. A glowing, pea-sized bead streaks from the pointing digit and, unless it impacts upon a material body or solid barrier prior to attaining the prescribed range, blossoms into the fireball at that point. (An early impact results in an early detonation.) If you attempt to send the bead through a narrow passage, such as through an arrow slit, you must "hit" the opening with a ranged touch attack, or else the bead strikes the barrier and detonates prematurely. The fireball sets fire to combustibles and damages objects in the area. It can melt metals with low melting points, such as lead, gold, copper, silver, and bronze. If the damage caused to an interposing barrier shatters or breaks through it, the fireball may continue beyond the barrier if the area permits; otherwise it stops at the barrier just as any other spell effect does.'
);

-- Step 2: Link to spell classes and levels
INSERT INTO spell_class_levels (spell_id, class_id, spell_level) VALUES
  ((SELECT id FROM spells WHERE name = 'Fireball'), (SELECT id FROM classes WHERE name = 'Sorcerer'), 3),
  ((SELECT id FROM spells WHERE name = 'Fireball'), (SELECT id FROM classes WHERE name = 'Wizard'), 3);

-- Step 3: Define spell components
INSERT INTO spell_components (spell_id, component_type_id, component_description) VALUES
  ((SELECT id FROM spells WHERE name = 'Fireball'), (SELECT id FROM spell_component_types WHERE code = 'V'), NULL),
  ((SELECT id FROM spells WHERE name = 'Fireball'), (SELECT id FROM spell_component_types WHERE code = 'S'), NULL),
  ((SELECT id FROM spells WHERE name = 'Fireball'), (SELECT id FROM spell_component_types WHERE code = 'M'), 'a tiny ball of bat guano and sulfur');

-- Step 4: Link spell descriptors
INSERT INTO spell_descriptors_link (spell_id, spell_descriptor_id) VALUES
  ((SELECT id FROM spells WHERE name = 'Fireball'), (SELECT id FROM spell_descriptors WHERE name = 'Fire'));

-- Step 5: Create fire damage effect
-- This is a damage effect that scales with caster level (1d6 per level, max 10d6)
INSERT INTO effects (
  name,
  effect_type,
  is_beneficial,
  is_magical,
  description
) VALUES (
  'Fireball - Fire Damage',
  'damage',
  false,  -- Not beneficial
  true,   -- Magical
  'Deals 1d6 fire damage per caster level (maximum 10d6) to all creatures in 20-ft radius'
);

-- Step 6: Link to damage_effects with fire damage type
INSERT INTO damage_effects (
  effect_id,
  damage_formula_id,
  damage_type_id
) VALUES (
  (SELECT id FROM effects WHERE name = 'Fireball - Fire Damage'),
  (SELECT id FROM formulas WHERE formula_text = '1d6 * MIN(CASTER_LEVEL, 10)'),  -- 1d6 per level, max 10d6
  (SELECT id FROM damage_types WHERE name = 'Fire')
);

-- Step 7: Link damage effect to spell
-- All caster levels use the same effect (formula handles scaling)
INSERT INTO spell_effects (
  spell_id,
  caster_level,
  effect_id,
  applies_when
) VALUES (
  (SELECT id FROM spells WHERE name = 'Fireball'),
  1,    -- Same effect for all caster levels (formula scales it)
  (SELECT id FROM effects WHERE name = 'Fireball - Fire Damage'),
  NULL  -- Always applies
);

-- Step 8: Define Reflex save for half damage
INSERT INTO spell_saves (
  spell_id,
  throw_id,
  save_dc_formula_id,
  save_result_type,
  effect_on_failed_save_id,
  effect_on_successful_save_id
) VALUES (
  (SELECT id FROM spells WHERE name = 'Fireball'),
  (SELECT id FROM throws WHERE name = 'Reflex Save'),
  (SELECT id FROM formulas WHERE formula_text = '10 + SPELL_LEVEL + ABILITY_MODIFIER'),
  'half',  -- Successful save reduces damage by half
  NULL,    -- Failed save = full damage (from spell_effects)
  NULL     -- Successful save = half damage (calculated at runtime)
);

-- =====================================================
-- RUNTIME EXAMPLE: FIREBALL
-- =====================================================
--
-- When cast at runtime (Phase 3):
--
-- Step 1: Caster targets a point within range (400 ft + 40 ft/level)
--
-- Step 2: Get all creatures within 20-ft radius of detonation point
--
-- SELECT c.id, c.name
-- FROM characters c
-- WHERE distance_from_point(c.position, detonation_point) <= 20;
--
-- Step 3: For each creature in area, check spell resistance
--
-- SELECT check_spell_resistance(
--   creature_id,
--   (SELECT id FROM spells WHERE name = 'Fireball'),
--   caster_level
-- ) AS resisted;
--
-- If spell is resisted, creature takes no damage. Continue to next creature.
--
-- Step 4: For each creature not resisting, roll Reflex save
--
-- SELECT
--   c.id,
--   c.name,
--   make_saving_throw(
--     c.id,
--     'Reflex',
--     10 + 3 + caster_ability_modifier  -- DC = 10 + spell level 3 + caster's INT/CHA mod
--   ) AS save_succeeded
-- FROM characters c
-- WHERE c.id IN (creatures_in_area);
--
-- Step 5: Calculate and apply damage
--
-- -- Roll damage once for the spell
-- SELECT floor(random() * 6 + 1)::int AS d6_result
-- FROM generate_series(1, LEAST(caster_level, 10));
--
-- -- Example: 5th level caster rolls 5d6 = 18 damage
-- WITH damage_roll AS (
--   SELECT 18 AS total_damage
-- )
-- -- Apply damage to each creature based on save result
-- INSERT INTO character_damage_log (character_id, damage_amount, damage_type_id, source_type, source_id)
-- SELECT
--   c.id,
--   CASE
--     WHEN save_succeeded THEN (total_damage / 2)::int  -- Half damage on successful save
--     ELSE total_damage                                  -- Full damage on failed save
--   END AS damage,
--   (SELECT id FROM damage_types WHERE name = 'Fire'),
--   'spell',
--   spell_instance_id
-- FROM characters c
-- CROSS JOIN damage_roll
-- WHERE c.id IN (creatures_in_area_not_resisting);
--
-- -- Update current HP
-- UPDATE characters c
-- SET current_hp = current_hp - damage_taken
-- WHERE c.id IN (creatures_in_area_not_resisting);
--
-- Step 6: Handle fire ignition effects (narrative)
--
-- -- The spell sets fire to combustibles and can melt low-melting-point metals
-- -- This is handled narratively by DM, not tracked in database
-- -- Examples:
-- --   - Wooden structures catch fire
-- --   - Gold/silver items may melt if unattended
-- --   - Scrolls/books destroyed
--
-- Note: Evasion ability (if creature has it) allows NO damage on successful save
-- This is checked at runtime by examining character feats/class abilities

-- =====================================================
-- ADDITIONAL NOTES
-- =====================================================

-- These examples demonstrate five major spell patterns:
--
-- 1. CONDITION-GRANTING SPELLS (Daze Monster):
--    - Use spell_granted_conditions
--    - Link to existing conditions in conditions table
--    - Use prerequisites for restrictions (HD, creature type, etc.)
--    - Use spell_saves for saving throws
--    - Fully structured, queryable data
--
-- 2. DETECTION/DIVINATION SPELLS (Detect Evil):
--    - Use narrative_effects for complex logic
--    - Runtime queries database for information
--    - No direct effects on targets
--    - Information-gathering, not effect-applying
--    - Aura calculations based on alignments, creature types, HD
--
-- 3. POLYMORPH-TYPE SPELLS (Alter Self):
--    - Use spell_available_forms to link to monster_templates library
--    - Restriction filters (type, size, HD) validated at runtime
--    - Property transfer flags control what caster gains/doesn't gain
--    - Reuses entire monster catalog instead of enumerating forms
--    - Combines structured effects (Disguise bonus) with template selection
--
-- 4. ATTACK + VARIABLE CONDITION SPELLS (Energy Drain):
--    - Use spell_attack_rolls for touch attack requirement
--    - Use spell_granted_conditions with variable_amount and amount_formula_id
--    - Use applies_when for target-type-specific effects (living vs undead)
--    - Manual save/dismissal pattern for complex timing (24-hour delay)
--    - Demonstrates conditional effect branching (negative levels OR temp HP)
--    - Stacking conditions pattern (multiple negative levels)
--
-- 5. AREA DAMAGE SPELLS (Fireball):
--    - Use damage_effects with damage_type_id for typed damage
--    - Variable damage via formula (1d6 * MIN(CASTER_LEVEL, 10))
--    - Reflex save for half damage (save_result_type = 'half')
--    - Area of effect (affects all creatures in radius)
--    - Material component with description
--    - Demonstrates basic "blasting spell" pattern
--    - Damage rolled once, applied to all targets (modified by individual saves)

-- =====================================================
-- END OF SPELL IMPORT EXAMPLES
-- =====================================================
