-- =====================================================
-- PREREQUISITE SYSTEM IMPLEMENTATION GUIDE
-- =====================================================
-- This file demonstrates how to create all types of prerequisites
-- using the polymorphic prerequisite system in pnpo_3_5_dev schema.
--
-- ARCHITECTURE OVERVIEW:
-- 1. prerequisite_groups: Container with logic operator (AND/OR)
-- 2. prerequisite_conditions: Polymorphic links to specific prerequisite types
-- 3. Specific prerequisite tables: ability_score_prerequisites, feat_requirement_prerequisites, etc.
--
-- DISCRIMINATOR PATTERN:
-- prerequisite_conditions.condition_type determines which FK column is used:
--   - 'ability_score' → ability_score_prerequisite_id
--   - 'base_attack_bonus' → base_attack_bonus_prerequisite_id
--   - 'caster_level' → caster_level_prerequisite_id
--   - 'class_feature' → class_feature_prerequisite_id
--   - 'class_level' → class_level_prerequisite_id
--   - 'feat_requirement' → feat_prerequisite_id
--   - 'skill_rank' → skill_rank_prerequisite_id
--   - 'spell_known' → spell_known_prerequisite_id
--   - 'race' → race_prerequisite_id
--   - 'size' → size_prerequisite_id
--   - 'alignment' → alignment_prerequisite_id
--   - 'special' → special_prerequisite_id
--   - 'dr_bypass_type' → dr_bypass_type_prerequisite_id
--   - 'nested_group' → nested_group_id
--
-- The fk_count generated column ensures exactly 1 FK is set per condition.
-- =====================================================

-- =====================================================
-- IMPLEMENTATION PATTERN (CTE + RETURNING)
-- =====================================================
-- ALWAYS use this pattern to avoid duplicate-row issues:
--
-- WITH new_prereq AS (
--     INSERT INTO [specific_prerequisite_table] (...)
--     VALUES (...)
--     RETURNING id
-- ),
-- new_group AS (
--     INSERT INTO prerequisite_groups (logic_operator, description)
--     VALUES ('AND', 'Description here')
--     RETURNING id
-- )
-- INSERT INTO prerequisite_conditions (
--     parent_group_id,
--     condition_type,
--     [appropriate_prerequisite_id]
-- )
-- SELECT new_group.id, '[condition_type]', new_prereq.id
-- FROM new_group, new_prereq;
--
-- For multiple prerequisites in same group, use CROSS JOIN pattern.
-- =====================================================

-- =====================================================
-- EXAMPLE 1: ABILITY SCORE PREREQUISITES
-- =====================================================
-- Use for: Feats requiring STR 13+, INT 13+, etc.
-- Table: ability_score_prerequisites
-- Columns: ability_name (VARCHAR 3), minimum_score (INTEGER)

-- Example: Power Attack requires STR 13
WITH new_ability_prereq AS (
    INSERT INTO ability_score_prerequisites (ability_name, minimum_score)
    VALUES ('STR', 13)
    RETURNING id
),
new_group AS (
    INSERT INTO prerequisite_groups (logic_operator, description)
    VALUES ('AND', 'Power Attack: Requires STR 13 or higher')
    RETURNING id
)
INSERT INTO prerequisite_conditions (
    parent_group_id,
    condition_type,
    ability_score_prerequisite_id
)
SELECT new_group.id, 'ability_score', new_ability_prereq.id
FROM new_group, new_ability_prereq;

-- Link to feat (assumes feat already exists):
-- UPDATE feats
-- SET prerequisite_group_id = (SELECT id FROM prerequisite_groups WHERE description = 'Power Attack: Requires STR 13 or higher')
-- WHERE name = 'Power Attack';

-- =====================================================
-- EXAMPLE 2: BASE ATTACK BONUS PREREQUISITES
-- =====================================================
-- Use for: Feats requiring BAB +1, +4, +6, etc.
-- Table: base_attack_bonus_prerequisites
-- Columns: minimum_bab (INTEGER)

-- Example: Dodge requires BAB +1
WITH new_bab_prereq AS (
    INSERT INTO base_attack_bonus_prerequisites (minimum_bab)
    VALUES (1)
    RETURNING id
),
new_group AS (
    INSERT INTO prerequisite_groups (logic_operator, description)
    VALUES ('AND', 'Dodge: Requires BAB +1 or higher')
    RETURNING id
)
INSERT INTO prerequisite_conditions (
    parent_group_id,
    condition_type,
    base_attack_bonus_prerequisite_id
)
SELECT new_group.id, 'base_attack_bonus', new_bab_prereq.id
FROM new_group, new_bab_prereq;

-- =====================================================
-- EXAMPLE 3: CASTER LEVEL PREREQUISITES
-- =====================================================
-- Use for: Item creation feats, prestige class requirements
-- Table: caster_level_prerequisites
-- Columns: minimum_caster_level (INTEGER), class_id (INTEGER nullable)
-- class_id = NULL means any caster class
-- class_id = specific ID means that specific class

-- Example 3A: Brew Potion requires caster level 3rd (any class)
WITH new_caster_prereq AS (
    INSERT INTO caster_level_prerequisites (minimum_caster_level, class_id)
    VALUES (3, NULL)  -- NULL = any caster class
    RETURNING id
),
new_group AS (
    INSERT INTO prerequisite_groups (logic_operator, description)
    VALUES ('AND', 'Brew Potion: Requires caster level 3rd or higher')
    RETURNING id
)
INSERT INTO prerequisite_conditions (
    parent_group_id,
    condition_type,
    caster_level_prerequisite_id
)
SELECT new_group.id, 'caster_level', new_caster_prereq.id
FROM new_group, new_caster_prereq;

-- Example 3B: Specific class caster level (e.g., Wizard 5th level)
WITH new_caster_prereq AS (
    INSERT INTO caster_level_prerequisites (minimum_caster_level, class_id)
    VALUES (5, (SELECT id FROM classes WHERE name = 'Wizard'))
    RETURNING id
),
new_group AS (
    INSERT INTO prerequisite_groups (logic_operator, description)
    VALUES ('AND', 'Requires wizard caster level 5th or higher')
    RETURNING id
)
INSERT INTO prerequisite_conditions (
    parent_group_id,
    condition_type,
    caster_level_prerequisite_id
)
SELECT new_group.id, 'caster_level', new_caster_prereq.id
FROM new_group, new_caster_prereq;

-- =====================================================
-- EXAMPLE 4: FEAT REQUIREMENT PREREQUISITES
-- =====================================================
-- Use for: Feats that require other feats
-- Table: feat_requirement_prerequisites
-- Columns: required_feat_id (INTEGER FK to feats)

-- Example: Cleave requires Power Attack
WITH new_feat_prereq AS (
    INSERT INTO feat_requirement_prerequisites (required_feat_id)
    VALUES ((SELECT id FROM feats WHERE name = 'Power Attack'))
    RETURNING id
),
new_group AS (
    INSERT INTO prerequisite_groups (logic_operator, description)
    VALUES ('AND', 'Cleave: Requires Power Attack')
    RETURNING id
)
INSERT INTO prerequisite_conditions (
    parent_group_id,
    condition_type,
    feat_prerequisite_id
)
SELECT new_group.id, 'feat_requirement', new_feat_prereq.id
FROM new_group, new_feat_prereq;

-- =====================================================
-- EXAMPLE 5: SKILL RANK PREREQUISITES
-- =====================================================
-- Use for: Feats requiring skill ranks (e.g., Acrobatic Strike requires Tumble 5 ranks)
-- Table: skill_rank_prerequisites
-- Columns: skill_id (INTEGER FK to skills), minimum_ranks (INTEGER)

-- Example: Stealthy (hypothetical) requires Hide 5 ranks
WITH new_skill_prereq AS (
    INSERT INTO skill_rank_prerequisites (skill_id, minimum_ranks)
    VALUES (
        (SELECT id FROM skills WHERE name = 'Hide'),
        5
    )
    RETURNING id
),
new_group AS (
    INSERT INTO prerequisite_groups (logic_operator, description)
    VALUES ('AND', 'Requires Hide 5 ranks or higher')
    RETURNING id
)
INSERT INTO prerequisite_conditions (
    parent_group_id,
    condition_type,
    skill_rank_prerequisite_id
)
SELECT new_group.id, 'skill_rank', new_skill_prereq.id
FROM new_group, new_skill_prereq;

-- =====================================================
-- EXAMPLE 6: CLASS LEVEL PREREQUISITES
-- =====================================================
-- Use for: Prestige classes, feats requiring class levels
-- Table: class_level_prerequisites
-- Columns: class_id (INTEGER FK to classes), minimum_level (INTEGER)

-- Example: Requires Rogue 3rd level
WITH new_class_prereq AS (
    INSERT INTO class_level_prerequisites (class_id, minimum_level)
    VALUES (
        (SELECT id FROM classes WHERE name = 'Rogue'),
        3
    )
    RETURNING id
),
new_group AS (
    INSERT INTO prerequisite_groups (logic_operator, description)
    VALUES ('AND', 'Requires Rogue level 3 or higher')
    RETURNING id
)
INSERT INTO prerequisite_conditions (
    parent_group_id,
    condition_type,
    class_level_prerequisite_id
)
SELECT new_group.id, 'class_level', new_class_prereq.id
FROM new_group, new_class_prereq;

-- =====================================================
-- EXAMPLE 7: CLASS FEATURE PREREQUISITES
-- =====================================================
-- Use for: Feats requiring specific class features (sneak attack, turn undead, etc.)
-- Table: class_feature_prerequisites
-- Columns: feature_id (INTEGER FK to class_features)

-- Example: Requires Turn Undead class feature
WITH new_feature_prereq AS (
    INSERT INTO class_feature_prerequisites (feature_id)
    VALUES ((SELECT id FROM class_features WHERE name = 'Turn Undead'))
    RETURNING id
),
new_group AS (
    INSERT INTO prerequisite_groups (logic_operator, description)
    VALUES ('AND', 'Requires Turn Undead class feature')
    RETURNING id
)
INSERT INTO prerequisite_conditions (
    parent_group_id,
    condition_type,
    class_feature_prerequisite_id
)
SELECT new_group.id, 'class_feature', new_feature_prereq.id
FROM new_group, new_feature_prereq;

-- =====================================================
-- EXAMPLE 8: SPELL KNOWN PREREQUISITES
-- =====================================================
-- Use for: Feats requiring knowledge of specific spells
-- Table: spell_known_prerequisites
-- Columns: spell_id (INTEGER FK to spells)

-- Example: Requires ability to cast fireball
WITH new_spell_prereq AS (
    INSERT INTO spell_known_prerequisites (spell_id)
    VALUES ((SELECT id FROM spells WHERE name = 'Fireball'))
    RETURNING id
),
new_group AS (
    INSERT INTO prerequisite_groups (logic_operator, description)
    VALUES ('AND', 'Requires ability to cast fireball')
    RETURNING id
)
INSERT INTO prerequisite_conditions (
    parent_group_id,
    condition_type,
    spell_known_prerequisite_id
)
SELECT new_group.id, 'spell_known', new_spell_prereq.id
FROM new_group, new_spell_prereq;

-- =====================================================
-- EXAMPLE 9: RACE PREREQUISITES
-- =====================================================
-- Use for: Racial feats (Dwarven racial feats, Elf racial feats, etc.)
-- Table: race_prerequisites
-- Columns: race_id (INTEGER FK to races)

-- Example: Requires Dwarf race
WITH new_race_prereq AS (
    INSERT INTO race_prerequisites (race_id)
    VALUES ((SELECT id FROM races WHERE name = 'Dwarf'))
    RETURNING id
),
new_group AS (
    INSERT INTO prerequisite_groups (logic_operator, description)
    VALUES ('AND', 'Requires Dwarf race')
    RETURNING id
)
INSERT INTO prerequisite_conditions (
    parent_group_id,
    condition_type,
    race_prerequisite_id
)
SELECT new_group.id, 'race', new_race_prereq.id
FROM new_group, new_race_prereq;

-- =====================================================
-- EXAMPLE 10: SIZE PREREQUISITES
-- =====================================================
-- Use for: Feats requiring specific size (Improved Natural Attack, etc.)
-- Table: size_prerequisites
-- Columns: size_category (VARCHAR 20)

-- Example: Requires Medium size or larger
WITH new_size_prereq AS (
    INSERT INTO size_prerequisites (size_category)
    VALUES ('Medium')
    RETURNING id
),
new_group AS (
    INSERT INTO prerequisite_groups (logic_operator, description)
    VALUES ('AND', 'Requires Medium size or larger')
    RETURNING id
)
INSERT INTO prerequisite_conditions (
    parent_group_id,
    condition_type,
    size_prerequisite_id
)
SELECT new_group.id, 'size', new_size_prereq.id
FROM new_group, new_size_prereq;

-- =====================================================
-- EXAMPLE 11: ALIGNMENT PREREQUISITES
-- =====================================================
-- Use for: Alignment-restricted feats (some divine feats, etc.)
-- Table: alignment_prerequisites
-- Columns: allowed_alignment (VARCHAR 20)

-- Example: Requires Lawful Good alignment
WITH new_alignment_prereq AS (
    INSERT INTO alignment_prerequisites (allowed_alignment)
    VALUES ('Lawful Good')
    RETURNING id
),
new_group AS (
    INSERT INTO prerequisite_groups (logic_operator, description)
    VALUES ('AND', 'Requires Lawful Good alignment')
    RETURNING id
)
INSERT INTO prerequisite_conditions (
    parent_group_id,
    condition_type,
    alignment_prerequisite_id
)
SELECT new_group.id, 'alignment', new_alignment_prereq.id
FROM new_group, new_alignment_prereq;

-- =====================================================
-- EXAMPLE 12: SPECIAL PREREQUISITES
-- =====================================================
-- Use for: Narrative/unusual prerequisites not captured in other tables
-- Table: special_prerequisites
-- Columns: description (TEXT)

-- Example: "Must have been killed and raised from the dead"
WITH new_special_prereq AS (
    INSERT INTO special_prerequisites (description)
    VALUES ('Must have been killed and raised from the dead')
    RETURNING id
),
new_group AS (
    INSERT INTO prerequisite_groups (logic_operator, description)
    VALUES ('AND', 'Requires having been raised from the dead')
    RETURNING id
)
INSERT INTO prerequisite_conditions (
    parent_group_id,
    condition_type,
    special_prerequisite_id
)
SELECT new_group.id, 'special', new_special_prereq.id
FROM new_group, new_special_prereq;

-- =====================================================
-- EXAMPLE 13: DR BYPASS TYPE PREREQUISITES
-- =====================================================
-- Use for: Feats requiring damage reduction with specific bypass types
-- Table: dr_bypass_type_prerequisites
-- Columns: bypass_type (VARCHAR 50), minimum_dr_value (INTEGER)

-- Example: Requires DR 10/- or better
WITH new_dr_prereq AS (
    INSERT INTO dr_bypass_type_prerequisites (bypass_type, minimum_dr_value)
    VALUES ('-', 10)
    RETURNING id
),
new_group AS (
    INSERT INTO prerequisite_groups (logic_operator, description)
    VALUES ('AND', 'Requires DR 10/- or better')
    RETURNING id
)
INSERT INTO prerequisite_conditions (
    parent_group_id,
    condition_type,
    dr_bypass_type_prerequisite_id
)
SELECT new_group.id, 'dr_bypass_type', new_dr_prereq.id
FROM new_group, new_dr_prereq;

-- =====================================================
-- EXAMPLE 14: MULTIPLE PREREQUISITES IN SAME GROUP (AND)
-- =====================================================
-- Use for: Feats requiring MULTIPLE conditions ALL satisfied
-- Pattern: Create group once, insert multiple conditions

-- Example: Improved Trip requires INT 13 AND Combat Expertise feat
WITH new_ability_prereq AS (
    INSERT INTO ability_score_prerequisites (ability_name, minimum_score)
    VALUES ('INT', 13)
    RETURNING id
),
new_feat_prereq AS (
    INSERT INTO feat_requirement_prerequisites (required_feat_id)
    VALUES ((SELECT id FROM feats WHERE name = 'Combat Expertise'))
    RETURNING id
),
new_group AS (
    INSERT INTO prerequisite_groups (logic_operator, description)
    VALUES ('AND', 'Improved Trip: Requires INT 13 AND Combat Expertise')
    RETURNING id
)
INSERT INTO prerequisite_conditions (
    parent_group_id,
    condition_type,
    ability_score_prerequisite_id,
    feat_prerequisite_id
)
SELECT
    new_group.id,
    'ability_score',
    new_ability_prereq.id,
    NULL
FROM new_group, new_ability_prereq
UNION ALL
SELECT
    new_group.id,
    'feat_requirement',
    NULL,
    new_feat_prereq.id
FROM new_group, new_feat_prereq;

-- =====================================================
-- EXAMPLE 15: NESTED GROUPS (COMPLEX OR LOGIC)
-- =====================================================
-- Use for: (A OR B) AND C logic patterns
-- Pattern: Create child groups for OR conditions, parent group for AND

-- Example: Requires (Wizard 5 OR Sorcerer 5) AND Spell Focus (Evocation)
-- Step 1: Create child group for class levels (Wizard 5 OR Sorcerer 5)
WITH wizard_prereq AS (
    INSERT INTO class_level_prerequisites (class_id, minimum_level)
    VALUES ((SELECT id FROM classes WHERE name = 'Wizard'), 5)
    RETURNING id
),
sorcerer_prereq AS (
    INSERT INTO class_level_prerequisites (class_id, minimum_level)
    VALUES ((SELECT id FROM classes WHERE name = 'Sorcerer'), 5)
    RETURNING id
),
child_group AS (
    INSERT INTO prerequisite_groups (logic_operator, description)
    VALUES ('OR', 'Wizard 5 OR Sorcerer 5')
    RETURNING id
)
INSERT INTO prerequisite_conditions (
    parent_group_id,
    condition_type,
    class_level_prerequisite_id
)
SELECT child_group.id, 'class_level', wizard_prereq.id
FROM child_group, wizard_prereq
UNION ALL
SELECT child_group.id, 'class_level', sorcerer_prereq.id
FROM child_group, sorcerer_prereq;

-- Step 2: Create parent group linking child group AND feat requirement
WITH feat_prereq AS (
    INSERT INTO feat_requirement_prerequisites (required_feat_id)
    VALUES ((SELECT id FROM feats WHERE name = 'Spell Focus'))  -- Assume Evocation choice
    RETURNING id
),
parent_group AS (
    INSERT INTO prerequisite_groups (logic_operator, description)
    VALUES ('AND', '(Wizard 5 OR Sorcerer 5) AND Spell Focus (Evocation)')
    RETURNING id
)
INSERT INTO prerequisite_conditions (
    parent_group_id,
    condition_type,
    nested_group_id,
    feat_prerequisite_id
)
SELECT
    parent_group.id,
    'nested_group',
    (SELECT id FROM prerequisite_groups WHERE description = 'Wizard 5 OR Sorcerer 5'),
    NULL
FROM parent_group
UNION ALL
SELECT
    parent_group.id,
    'feat_requirement',
    NULL,
    feat_prereq.id
FROM parent_group, feat_prereq;

-- =====================================================
-- QUICK REFERENCE: CONDITION_TYPE → PREREQUISITE TABLE
-- =====================================================
-- condition_type            | prerequisite_table                  | FK column
-- --------------------------|-------------------------------------|-------------------------------
-- 'ability_score'           | ability_score_prerequisites         | ability_score_prerequisite_id
-- 'base_attack_bonus'       | base_attack_bonus_prerequisites     | base_attack_bonus_prerequisite_id
-- 'caster_level'            | caster_level_prerequisites          | caster_level_prerequisite_id
-- 'class_feature'           | class_feature_prerequisites         | class_feature_prerequisite_id
-- 'class_level'             | class_level_prerequisites           | class_level_prerequisite_id
-- 'feat_requirement'        | feat_requirement_prerequisites      | feat_prerequisite_id
-- 'skill_rank'              | skill_rank_prerequisites            | skill_rank_prerequisite_id
-- 'spell_known'             | spell_known_prerequisites           | spell_known_prerequisite_id
-- 'race'                    | race_prerequisites                  | race_prerequisite_id
-- 'size'                    | size_prerequisites                  | size_prerequisite_id
-- 'alignment'               | alignment_prerequisites             | alignment_prerequisite_id
-- 'special'                 | special_prerequisites               | special_prerequisite_id
-- 'dr_bypass_type'          | dr_bypass_type_prerequisites        | dr_bypass_type_prerequisite_id
-- 'nested_group'            | prerequisite_groups                 | nested_group_id

-- =====================================================
-- TEMPLATE FOR NEW PREREQUISITES
-- =====================================================
-- Copy and modify this template for new prerequisites:
/*
WITH new_prereq AS (
    INSERT INTO [prerequisite_table] ([columns...])
    VALUES ([values...])
    RETURNING id
),
new_group AS (
    INSERT INTO prerequisite_groups (logic_operator, description)
    VALUES ('AND', '[Description of requirement]')
    RETURNING id
)
INSERT INTO prerequisite_conditions (
    parent_group_id,
    condition_type,
    [appropriate_prerequisite_id]
)
SELECT new_group.id, '[condition_type]', new_prereq.id
FROM new_group, new_prereq;

-- Link to feat/class/race/etc:
UPDATE [target_table]
SET prerequisite_group_id = (SELECT id FROM prerequisite_groups WHERE description = '[Description of requirement]')
WHERE name = '[Target name]';
*/

-- =====================================================
-- END OF PREREQUISITE IMPLEMENTATION GUIDE
-- =====================================================
