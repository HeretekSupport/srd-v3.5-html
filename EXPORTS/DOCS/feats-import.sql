-- =====================================================
-- D&D 3.5 SRD FEATS - SAMPLE INSERT STATEMENTS
-- =====================================================
-- Schema: pnpo_3_5_dev.feats
-- Source: SRD HTML exports (feats.html)

SET search_path TO pnpo_3_5_dev;

-- =====================================================
-- EXAMPLE FEAT INSERTS
-- =====================================================

-- Example 1: TOUGHNESS (Simple feat, no prerequisites, multiples allowed)
INSERT INTO feats (
  name,
  feat_type,
  description,
  benefit,
  special,
  choice_required,
  choice_type,
  multiples_allowed
) VALUES (
  'Toughness',
  'general',
  'You are tougher than normal, gaining extra hit points.',
  'You gain +3 hit points.',
  'A character may gain this feat multiple times. Its effects stack.',
  false,
  NULL,
  true
);

-- Example 2: POWER ATTACK (Prerequisite: STR 13, Fighter bonus feat)
-- Note: Prerequisites are linked via feat_prerequisites junction table (not shown here)
INSERT INTO feats (
  name,
  feat_type,
  description,
  benefit,
  special,
  choice_required,
  choice_type,
  multiples_allowed
) VALUES (
  'Power Attack',
  'general',
  'You can make exceptionally deadly melee attacks by sacrificing accuracy for power.',
  'On your action, before making attack rolls for a round, you may choose to subtract a number from all melee attack rolls and add the same number to all melee damage rolls. This number may not exceed your base attack bonus. The penalty on attacks and bonus on damage apply until your next turn.',
  'If you attack with a two-handed weapon, or with a one-handed weapon wielded in two hands, instead add twice the number subtracted from your attack rolls. You can''t add the bonus from Power Attack to the damage dealt with a light weapon (except with unarmed strikes or natural weapon attacks), even though the penalty on attack rolls still applies. A fighter may select Power Attack as one of his fighter bonus feats.',
  false,
  NULL,
  false
);

-- Example 3: COMBAT CASTING (Simple benefit feat)
INSERT INTO feats (
  name,
  feat_type,
  description,
  benefit,
  special,
  choice_required,
  choice_type,
  multiples_allowed
) VALUES (
  'Combat Casting',
  'general',
  'You are adept at casting spells in combat.',
  'You get a +4 bonus on Concentration checks made to cast a spell or use a spell-like ability while on the defensive or while you are grappling or pinned.',
  NULL,
  false,
  NULL,
  false
);

-- Example 4: EMPOWER SPELL (Metamagic feat)
INSERT INTO feats (
  name,
  feat_type,
  description,
  benefit,
  special,
  choice_required,
  choice_type,
  multiples_allowed
) VALUES (
  'Empower Spell',
  'metamagic',
  'You can cast spells to greater effect.',
  'All variable, numeric effects of an empowered spell are increased by one-half. Saving throws and opposed rolls are not affected, nor are spells without random variables. An empowered spell uses up a spell slot two levels higher than the spell''s actual level.',
  NULL,
  false,
  NULL,
  false
);

-- Example 5: BREW POTION (Item Creation feat, Prerequisite: Caster level 3rd)
-- Note: Prerequisites are linked via feat_prerequisites junction table (not shown here)
INSERT INTO feats (
  name,
  feat_type,
  description,
  benefit,
  special,
  choice_required,
  choice_type,
  multiples_allowed
) VALUES (
  'Brew Potion',
  'item_creation',
  'You can create magic potions.',
  'You can create a potion of any 3rd-level or lower spell that you know and that targets one or more creatures. Brewing a potion takes one day. When you create a potion, you set the caster level, which must be sufficient to cast the spell in question and no higher than your own level. The base price of a potion is its spell level × its caster level × 50 gp. To brew a potion, you must spend 1/25 of this base price in XP and use up raw materials costing one half this base price.',
  'When you create a potion, you make any choices that you would normally make when casting the spell. Whoever drinks the potion is the target of the spell. Any potion that stores a spell with a costly material component or an XP cost also carries a commensurate cost. In addition to the costs derived from the base price, you must expend the material component or pay the XP when creating the potion.',
  false,
  NULL,
  false
);

-- =====================================================
-- PREREQUISITES EXAMPLES
-- =====================================================
--
-- Prerequisites are stored in the normalized prerequisites system.
-- See D:\Workspace\WEB\PROJECTS\pnpo\database\schemas\pnpo_3_5_dev\tables\underlying-systems\prerequisites.sql
--
-- Example: Power Attack prerequisite (STR 13 AND BAB +1)
--
-- Step 1: Create prerequisite_group (AND logic by default)
-- INSERT INTO prerequisite_groups (logic_operator, description)
-- VALUES ('AND', 'Power Attack prerequisites: STR 13 AND BAB +1')
-- RETURNING id;  -- Assume returns group_id = 100
--
-- Step 2: Create ability score prerequisite
-- INSERT INTO ability_score_prerequisites (ability_name, minimum_value)
-- VALUES ('STR', 13)
-- RETURNING id;  -- Assume returns prerequisite_id = 1001
--
-- Step 3: Create BAB prerequisite
-- INSERT INTO base_attack_bonus_prerequisites (minimum_bab)
-- VALUES (1)
-- RETURNING id;  -- Assume returns prerequisite_id = 1002
--
-- Step 4: Link prerequisites to group
-- INSERT INTO prerequisite_conditions (prerequisite_group_id, prerequisite_id, prerequisite_type)
-- VALUES
--   (100, 1001, 'ability_score'),
--   (100, 1002, 'base_attack_bonus');
--
-- Step 5: Link group to feat
-- INSERT INTO feat_prerequisites (feat_id, prerequisite_group_id)
-- VALUES (
--   (SELECT id FROM feats WHERE name = 'Power Attack'),
--   100
-- );
--
-- Example: Brew Potion prerequisite (Caster level 3rd)
--
-- INSERT INTO caster_level_prerequisites (minimum_caster_level)
-- VALUES (3) RETURNING id;  -- Assume returns 2001
--
-- INSERT INTO prerequisite_groups (logic_operator, description)
-- VALUES ('AND', 'Brew Potion prerequisite: Caster level 3rd')
-- RETURNING id;  -- Assume returns 200
--
-- INSERT INTO prerequisite_conditions (prerequisite_group_id, prerequisite_id, prerequisite_type)
-- VALUES (200, 2001, 'caster_level');
--
-- INSERT INTO feat_prerequisites (feat_id, prerequisite_group_id)
-- VALUES (
--   (SELECT id FROM feats WHERE name = 'Brew Potion'),
--   200
-- );

-- =====================================================
-- NOTES ON SCHEMA MAPPING
-- =====================================================
--
-- Fields mapped from SRD HTML:
-- - name: Extracted from h3 heading, before "[Type]"
-- - feat_type: From heading suffix [General], [Metamagic], [Item Creation]
--     → mapped to: 'general', 'metamagic', 'item_creation'
-- - description: Introductory sentence (not always present in SRD)
-- - benefit: From "Benefit:" section verbatim
-- - special: From "Special:" section (NULL if not present)
-- - choice_required: Analyzed from feat mechanics (Weapon Focus, Skill Focus, etc.)
-- - choice_type: weapon, skill, school, creature_type, etc.
-- - multiples_allowed: From "Special" section (e.g., "may gain this feat multiple times")
--
-- Feat type mapping:
--   [General] → 'general'
--   [Item Creation] → 'item_creation'
--   [Metamagic] → 'metamagic'
--   [Special] → 'special'
--   (Fighter bonus) → 'fighter_bonus' (stored in feat_type or as tag)
--
-- Prerequisites handling:
-- - NOT stored in feats table directly
-- - Uses normalized prerequisite system via feat_prerequisites junction
-- - Supports complex AND/OR/nested logic
-- - See prerequisites.sql for details
--
-- Choice-based feats:
-- - Skill Focus: choice_required=true, choice_type='skill', multiples_allowed=true
-- - Spell Focus: choice_required=true, choice_type='school', multiples_allowed=false
-- - Weapon Focus: EXPLOSION PATTERN (see feats.sql lines 87-167)
--     → Create separate feat for each weapon: "Weapon Focus (Longsword)", etc.
--     → Avoids cross-choice validation complexity in prerequisite chains
--
-- Effects and abilities:
-- - Feat effects stored in feat_effects table (links to effects system)
-- - Feat-granted abilities stored in feat_granted_abilities (links to special_abilities)
-- - Example: Toughness grants effect (+3 HP)
-- - Example: Power Attack grants special ability (trade attack for damage)
--
-- Edge cases:
-- - Fighter bonus feats: feat_type can include 'fighter_bonus' or track via separate table
-- - Metamagic feats: affect spell slot level (stored in description/special)
-- - Item creation feats: crafting rules (XP costs, time) in benefit/special text
-- - Feats with variable benefits: "Special" section describes stacking/multiples
--
-- Import strategy:
-- 1. Import all basic feats (name, type, benefit, special)
-- 2. Build prerequisite_groups and link via feat_prerequisites
-- 3. Explode weapon feats (Weapon Focus × 50 weapons = 50 feat records)
-- 4. Link effects via feat_effects junction
-- 5. Link granted abilities via feat_granted_abilities junction
--
-- =====================================================