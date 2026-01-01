-- =====================================================
-- FEAT IMPORT IMPLEMENTATION GUIDE
-- =====================================================
-- This file demonstrates how to import feats from D&D 3.5 SRD
-- into the pnpo_3_5_dev schema, covering all major patterns:
--
-- 1. Simple stat bonuses (skill checks, saves, attacks, AC)
-- 2. Choice-required feats (Weapon Focus, Spell Focus, etc.)
-- 3. Prerequisites (ability scores, BAB, feats, character level)
-- 4. Effects system (effects → stat_effects → feat_effects)
-- 5. Special abilities (extraordinary, supernatural, spell-like)
-- 6. Metamagic feats
-- 7. Feat multiples (stacking vs non-stacking)
-- 8. Conditional bonuses (range, activation, circumstance)
--
-- PATTERN OVERVIEW:
-- Each feat import follows this structure:
-- 1. Insert into feats table (name, type, description, benefit, special, choice_type)
-- 2. Create prerequisite_groups if needed (see prerequisites-creation.sql)
-- 3. Create effects if feat grants mechanical bonuses
-- 4. Create stat_effects linking effects to targets
-- 5. Link feat to effects via feat_effects
-- 6. Create special_abilities if feat grants abilities
-- 7. Link feat to special_abilities via feat_granted_abilities
-- 8. Optionally use feat_choice_constraints for choice validation
--
-- DECISION FRAMEWORK:
-- Q1: Does this feat grant measurable numeric bonuses?
--     YES → Create effects + stat_effects
--     NO → Skip to special_abilities or just create feat entry
--
-- Q2: Does the bonus have a type (competence, enhancement, dodge, etc.)?
--     YES → Use appropriate bonus_type_id
--     NO → Use 'untyped' bonus type
--
-- Q3: Can you take this feat multiple times?
--     Check the "Special" section of feat description
--     multiples_allowed = true/false
--     can_stack = true/false (in bonus_types table)
--
-- Q4: Does the feat require a choice (weapon, skill, spell school)?
--     YES → choice_required = true, set choice_type
--     Consider using feat_choice_constraints if applicable
--
-- Q5: What prerequisites does it have?
--     See prerequisites-creation.sql for full patterns
--     Common types: ability_score, base_attack_bonus, feat_requirement
--
-- Q6: Is there narrative/non-mechanical benefit?
--     Create special_abilities with is_active flag
--     is_active = true for activated abilities
--     is_active = false for passive abilities
-- =====================================================

BEGIN;

-- =====================================================
-- DEPENDENCIES (RUN FIRST!)
-- =====================================================
-- These must exist before any feat imports.
-- In production, these would be in a separate dependencies file.

-- Bonus Types
-- CORRECTED: Column is 'can_stack', not 'stacks'
INSERT INTO bonus_types (name, can_stack, description)
VALUES
    ('untyped', true, 'Untyped bonuses stack with all other bonuses including other untyped bonuses'),
    ('dodge', true, 'Dodge bonuses stack with each other but not with other bonus types'),
    ('competence', false, 'Represents improvement due to training - does not stack with other competence bonuses'),
    ('enhancement', false, 'Magical bonus that enhances natural abilities - does not stack')
ON CONFLICT (name) DO NOTHING;

-- Effect Target Categories
INSERT INTO effect_target_categories (name, description)
VALUES
    ('ability_scores', 'Target is an ability score (STR, DEX, CON, INT, WIS, CHA)'),
    ('skill_checks', 'Target is a skill check'),
    ('saving_throws', 'Target is a saving throw (Fortitude, Reflex, Will)'),
    ('attacks', 'Target is an attack roll'),
    ('armor_class', 'Target is Armor Class'),
    ('initiative', 'Target is initiative checks'),
    ('grapple', 'Target is grapple checks'),
    ('hit_points', 'Target is hit point total')
ON CONFLICT (name) DO NOTHING;

-- Effect Targets - Saving Throws
INSERT INTO effect_targets (name, category_id, description)
VALUES
    ('Fortitude_save', (SELECT id FROM effect_target_categories WHERE name = 'saving_throws'), 'Fortitude saving throw modifier'),
    ('Reflex_save', (SELECT id FROM effect_target_categories WHERE name = 'saving_throws'), 'Reflex saving throw modifier'),
    ('Will_save', (SELECT id FROM effect_target_categories WHERE name = 'saving_throws'), 'Will saving throw modifier')
ON CONFLICT (name) DO NOTHING;

-- Effect Targets - Attacks
INSERT INTO effect_targets (name, category_id, description)
VALUES
    ('melee_attack', (SELECT id FROM effect_target_categories WHERE name = 'attacks'), 'Melee attack roll modifier'),
    ('ranged_attack', (SELECT id FROM effect_target_categories WHERE name = 'attacks'), 'Ranged attack roll modifier'),
    ('melee_damage', (SELECT id FROM effect_target_categories WHERE name = 'attacks'), 'Melee damage roll modifier'),
    ('ranged_damage', (SELECT id FROM effect_target_categories WHERE name = 'attacks'), 'Ranged damage roll modifier')
ON CONFLICT (name) DO NOTHING;

-- Effect Targets - Other
INSERT INTO effect_targets (name, category_id, description)
VALUES
    ('AC', (SELECT id FROM effect_target_categories WHERE name = 'armor_class'), 'Armor Class modifier'),
    ('Initiative_check', (SELECT id FROM effect_target_categories WHERE name = 'initiative'), 'Initiative check modifier'),
    ('Grapple_check', (SELECT id FROM effect_target_categories WHERE name = 'grapple'), 'Grapple check modifier'),
    ('HP', (SELECT id FROM effect_target_categories WHERE name = 'hit_points'), 'Hit point modifier')
ON CONFLICT (name) DO NOTHING;

-- =====================================================
-- FEAT 1: IMPROVED INITIATIVE
-- =====================================================
-- PATTERN: Simple check bonus, no prerequisites
-- DECISIONS:
-- - No prerequisites → prerequisite_group_id = NULL
-- - Grants +4 to initiative checks → Create effect + stat_effect
-- - Bonus type: untyped (most bonuses are untyped unless specified)
-- - Can't take multiple times → multiples_allowed = false
-- - No choice required → choice_required = false, choice_type = NULL
-- - No special ability needed (just a numeric bonus)

-- Step 1: Insert feat
INSERT INTO feats (
    name,
    feat_type,
    description,
    benefit,
    special,
    choice_required,
    choice_type,
    multiples_allowed
)
VALUES (
    'Improved Initiative',
    'general',
    'You get a +4 bonus on initiative checks.',
    'You get a +4 bonus on initiative checks.',
    'A fighter may select Improved Initiative as one of his fighter bonus feats.',
    false,  -- No choice required
    NULL,   -- No choice_type since choice_required = false
    false   -- Cannot take multiple times
);

-- Step 2: Create effect for initiative bonus
-- DECISION: effect_type = 'stat' because it modifies a check/stat
-- DECISION: is_beneficial = true (bonus helps player)
-- DECISION: is_magical = false (extraordinary ability, not magical)
-- DECISION: stacks_with_self = false (can't take feat multiple times)
INSERT INTO effects (
    name,
    effect_type,
    is_beneficial,
    is_magical,
    stacks_with_self,
    description
)
VALUES (
    'Improved Initiative: Initiative Bonus',
    'stat',
    true,
    false,
    false,
    '+4 untyped bonus to initiative checks'
);

-- Step 3: Create stat_effect linking to initiative check target
-- DECISION: change_type = 'additive' (adds to existing value)
-- DECISION: value = 4 (from benefit text)
-- DECISION: bonus_type = 'untyped' (not specified, so untyped)
INSERT INTO stat_effects (
    effect_id,
    effect_target_id,
    change_type,
    value,
    bonus_type_id
)
VALUES (
    (SELECT id FROM effects WHERE name = 'Improved Initiative: Initiative Bonus'),
    (SELECT id FROM effect_targets WHERE name = 'Initiative_check'),
    'additive',
    4,
    (SELECT id FROM bonus_types WHERE name = 'untyped')
);

-- Step 4: Link effect to feat
-- DECISION: applies_when = NULL (always active, no conditions)
INSERT INTO feat_effects (
    feat_id,
    effect_id,
    applies_when
)
VALUES (
    (SELECT id FROM feats WHERE name = 'Improved Initiative'),
    (SELECT id FROM effects WHERE name = 'Improved Initiative: Initiative Bonus'),
    NULL  -- Always active
);

-- =====================================================
-- FEAT 2: GREAT FORTITUDE
-- =====================================================
-- PATTERN: Save bonus, no prerequisites
-- DECISIONS:
-- - Grants +2 to Fortitude saves → Use Fortitude_save effect_target
-- - Bonus type: untyped (not specified in description)
-- - Simple benefit, no special abilities needed

INSERT INTO feats (
    name,
    feat_type,
    description,
    benefit,
    special,
    choice_required,
    choice_type,
    multiples_allowed
)
VALUES (
    'Great Fortitude',
    'general',
    'You get a +2 bonus on all Fortitude saving throws.',
    'You get a +2 bonus on all Fortitude saving throws.',
    NULL,
    false,
    NULL,
    false
);

INSERT INTO effects (
    name,
    effect_type,
    is_beneficial,
    is_magical,
    stacks_with_self,
    description
)
VALUES (
    'Great Fortitude: Fortitude Bonus',
    'stat',
    true,
    false,
    false,
    '+2 untyped bonus to Fortitude saving throws'
);

INSERT INTO stat_effects (
    effect_id,
    effect_target_id,
    change_type,
    value,
    bonus_type_id
)
VALUES (
    (SELECT id FROM effects WHERE name = 'Great Fortitude: Fortitude Bonus'),
    (SELECT id FROM effect_targets WHERE name = 'Fortitude_save'),
    'additive',
    2,
    (SELECT id FROM bonus_types WHERE name = 'untyped')
);

INSERT INTO feat_effects (
    feat_id,
    effect_id,
    applies_when
)
VALUES (
    (SELECT id FROM feats WHERE name = 'Great Fortitude'),
    (SELECT id FROM effects WHERE name = 'Great Fortitude: Fortitude Bonus'),
    NULL
);

-- =====================================================
-- FEAT 3: TOUGHNESS
-- =====================================================
-- PATTERN: HP increase, can take multiple times (STACKS!)
-- DECISIONS:
-- - Grants +3 HP → Create effect targeting HP
-- - CAN take multiple times and DOES stack → multiples_allowed = true, stacks_with_self = true
-- - This is RARE - most feats that can be taken multiple times DON'T stack
-- - Bonus type: untyped (HP bonuses are typically untyped)

INSERT INTO feats (
    name,
    feat_type,
    description,
    benefit,
    special,
    choice_required,
    choice_type,
    multiples_allowed
)
VALUES (
    'Toughness',
    'general',
    'You gain +3 hit points.',
    'You gain +3 hit points.',
    'A character may gain this feat multiple times. Its effects stack.',  -- KEY: effects STACK
    false,
    NULL,
    true  -- Can take multiple times
);

-- IMPORTANT DECISION: stacks_with_self = true
-- Most feats set this to false, but Toughness explicitly stacks
INSERT INTO effects (
    name,
    effect_type,
    is_beneficial,
    is_magical,
    stacks_with_self,
    description
)
VALUES (
    'Toughness: HP Increase',
    'stat',
    true,
    false,
    true,  -- STACKS with multiple instances of Toughness
    '+3 hit points'
);

INSERT INTO stat_effects (
    effect_id,
    effect_target_id,
    change_type,
    value,
    bonus_type_id
)
VALUES (
    (SELECT id FROM effects WHERE name = 'Toughness: HP Increase'),
    (SELECT id FROM effect_targets WHERE name = 'HP'),
    'additive',
    3,
    (SELECT id FROM bonus_types WHERE name = 'untyped')
);

INSERT INTO feat_effects (
    feat_id,
    effect_id,
    applies_when
)
VALUES (
    (SELECT id FROM feats WHERE name = 'Toughness'),
    (SELECT id FROM effects WHERE name = 'Toughness: HP Increase'),
    NULL
);

-- =====================================================
-- FEAT 4: DODGE
-- =====================================================
-- PATTERN: AC bonus with special stacking rules, ability score prerequisite
-- DECISIONS:
-- - Requires DEX 13 → Create ability_score_prerequisite (see Step 2)
-- - Grants +1 dodge bonus to AC → Use 'dodge' bonus_type
-- - SPECIAL: Dodge bonuses STACK with each other (unique to dodge bonuses)
-- - Has activation condition → Use applies_when field
-- - Bonus stacks with other dodge bonuses → bonus_types.can_stack = true for 'dodge'

-- Step 1: Insert feat
INSERT INTO feats (
    name,
    feat_type,
    description,
    benefit,
    special,
    choice_required,
    choice_type,
    multiples_allowed
)
VALUES (
    'Dodge',
    'general',
    'During your action, you designate an opponent and receive a +1 dodge bonus to Armor Class against attacks from that opponent.',
    'During your action, you designate an opponent and receive a +1 dodge bonus to Armor Class against attacks from that opponent. You can select a new opponent on any action.',
    'A condition that makes you lose your Dexterity bonus to Armor Class (if any) also makes you lose dodge bonuses. Also, dodge bonuses stack with each other, unlike most other types of bonuses. A fighter may select Dodge as one of his fighter bonus feats.',
    false,
    NULL,
    false
);

-- Step 2: Create prerequisite for DEX 13
-- DECISION: Use ability_score_prerequisite pattern from prerequisites-creation.sql
WITH new_ability_prereq AS (
    INSERT INTO ability_score_prerequisites (ability_score, minimum_value)
    VALUES ('DEX', 13)
    RETURNING id
),
new_group AS (
    INSERT INTO prerequisite_groups (logic_operator, description)
    VALUES ('AND', 'Dodge: Requires DEX 13 or higher')
    RETURNING id
)
INSERT INTO prerequisite_conditions (
    parent_group_id,
    condition_type,
    ability_score_prerequisite_id
)
SELECT new_group.id, 'ability_score', new_ability_prereq.id
FROM new_group, new_ability_prereq;

-- Step 3: Link prerequisite group to feat
UPDATE feats
SET prerequisite_group_id = (SELECT id FROM prerequisite_groups WHERE description = 'Dodge: Requires DEX 13 or higher')
WHERE name = 'Dodge';

-- Step 4: Create effect for AC bonus
-- DECISION: Use 'dodge' bonus type (special stacking rules)
INSERT INTO effects (
    name,
    effect_type,
    is_beneficial,
    is_magical,
    stacks_with_self,
    description
)
VALUES (
    'Dodge: AC Bonus',
    'stat',
    true,
    false,
    false,  -- Can't take feat multiple times, but dodge bonuses stack with OTHER dodge bonuses
    '+1 dodge bonus to AC against designated opponent'
);

INSERT INTO stat_effects (
    effect_id,
    effect_target_id,
    change_type,
    value,
    bonus_type_id
)
VALUES (
    (SELECT id FROM effects WHERE name = 'Dodge: AC Bonus'),
    (SELECT id FROM effect_targets WHERE name = 'AC'),
    'additive',
    1,
    (SELECT id FROM bonus_types WHERE name = 'dodge')  -- DODGE bonus type
);

-- Step 5: Link effect to feat with condition
-- DECISION: applies_when describes the activation condition
INSERT INTO feat_effects (
    feat_id,
    effect_id,
    applies_when
)
VALUES (
    (SELECT id FROM feats WHERE name = 'Dodge'),
    (SELECT id FROM effects WHERE name = 'Dodge: AC Bonus'),
    'against attacks from designated opponent'  -- Conditional application
);

-- =====================================================
-- FEAT 5: WEAPON FOCUS
-- =====================================================
-- PATTERN: Choice-required feat, BAB + proficiency prerequisites
-- DECISIONS:
-- - Requires choice of weapon → choice_required = true, choice_type = 'weapon'
-- - Can take multiple times for different weapons → multiples_allowed = true
-- - Effects DON'T stack → stacks_with_self = false
-- - Requires BAB +1 → Create base_attack_bonus_prerequisite
-- - Requires weapon proficiency → Document in special field (no proficiency table yet)
-- - Grants +1 to attack rolls → Create effect for attack bonus

-- Step 1: Insert feat
INSERT INTO feats (
    name,
    feat_type,
    description,
    benefit,
    special,
    choice_required,
    choice_type,
    multiples_allowed
)
VALUES (
    'Weapon Focus',
    'general',
    'Choose one type of weapon. You can also choose unarmed strike or grapple (or ray, if you are a spellcaster) as your weapon for purposes of this feat.',
    'You gain a +1 bonus on all attack rolls you make using the selected weapon.',
    'You can gain this feat multiple times. Its effects do not stack. Each time you take the feat, it applies to a new type of weapon. A fighter may select Weapon Focus as one of his fighter bonus feats. He must have Weapon Focus with a weapon to gain the Weapon Specialization feat for that weapon.',
    true,   -- MUST choose a weapon
    'weapon',  -- CORRECTED: Added choice_type
    true    -- Can take multiple times for different weapons
);

-- Step 2: Create prerequisite for BAB +1
-- DECISION: Weapon proficiency is required but we don't have that table yet
-- For now, document in special field and create BAB prerequisite only
WITH new_bab_prereq AS (
    INSERT INTO base_attack_bonus_prerequisites (minimum_bab)
    VALUES (1)
    RETURNING id
),
new_group AS (
    INSERT INTO prerequisite_groups (logic_operator, description)
    VALUES ('AND', 'Weapon Focus: Requires BAB +1 and proficiency with selected weapon')
    RETURNING id
)
INSERT INTO prerequisite_conditions (
    parent_group_id,
    condition_type,
    base_attack_bonus_prerequisite_id
)
SELECT new_group.id, 'base_attack_bonus', new_bab_prereq.id
FROM new_group, new_bab_prereq;

UPDATE feats
SET prerequisite_group_id = (SELECT id FROM prerequisite_groups WHERE description = 'Weapon Focus: Requires BAB +1 and proficiency with selected weapon')
WHERE name = 'Weapon Focus';

-- Step 3: Create effect for attack bonus
-- DECISION: We can't specify "selected weapon" in effect_target
-- This is a limitation - we'd need weapon-specific effect_targets or a polymorphic system
-- For now, create a generic effect and document that it applies to selected weapon
INSERT INTO effects (
    name,
    effect_type,
    is_beneficial,
    is_magical,
    stacks_with_self,
    description
)
VALUES (
    'Weapon Focus: Attack Bonus',
    'stat',
    true,
    false,
    false,  -- Effects don't stack (taking feat multiple times doesn't stack bonuses)
    '+1 untyped bonus on attack rolls with selected weapon'
);

-- DECISION: Use melee_attack as placeholder - in production you'd need weapon-specific targeting
-- This would be implemented via feat_choice_constraints linking to weapon types
INSERT INTO stat_effects (
    effect_id,
    effect_target_id,
    change_type,
    value,
    bonus_type_id
)
VALUES (
    (SELECT id FROM effects WHERE name = 'Weapon Focus: Attack Bonus'),
    (SELECT id FROM effect_targets WHERE name = 'melee_attack'),  -- Placeholder - needs weapon-specific system
    'additive',
    1,
    (SELECT id FROM bonus_types WHERE name = 'untyped')
);

INSERT INTO feat_effects (
    feat_id,
    effect_id,
    applies_when
)
VALUES (
    (SELECT id FROM feats WHERE name = 'Weapon Focus'),
    (SELECT id FROM effects WHERE name = 'Weapon Focus: Attack Bonus'),
    'with selected weapon only'  -- Documents the choice constraint
);

-- Step 4: OPTIONAL - Configure choice constraints
-- DECISION: Use feat_choice_constraints to validate weapon choices
INSERT INTO feat_choice_constraints (
    feat_id,
    min_choices,
    max_choices,
    choice_source,
    description
)
VALUES (
    (SELECT id FROM feats WHERE name = 'Weapon Focus'),
    1,     -- Must choose 1 weapon
    1,     -- Can only choose 1 weapon per instance
    'weapons',  -- Choices come from weapons table
    'Choose one weapon type, unarmed strike, grapple, or ray'
);

-- =====================================================
-- FEAT 6: POINT BLANK SHOT
-- =====================================================
-- PATTERN: Conditional bonus based on range
-- DECISIONS:
-- - Grants +1 to attack AND damage with ranged weapons
-- - Only within 30 feet → Use applies_when field
-- - No prerequisites → prerequisite_group_id = NULL
-- - Need TWO effects: one for attack, one for damage

INSERT INTO feats (
    name,
    feat_type,
    description,
    benefit,
    special,
    choice_required,
    choice_type,
    multiples_allowed
)
VALUES (
    'Point Blank Shot',
    'general',
    'You get a +1 bonus on attack and damage rolls with ranged weapons at ranges of up to 30 feet.',
    'You get a +1 bonus on attack and damage rolls with ranged weapons at ranges of up to 30 feet.',
    'A fighter may select Point Blank Shot as one of his fighter bonus feats.',
    false,
    NULL,
    false
);

-- Effect 1: Attack bonus
INSERT INTO effects (
    name,
    effect_type,
    is_beneficial,
    is_magical,
    stacks_with_self,
    description
)
VALUES (
    'Point Blank Shot: Attack Bonus',
    'stat',
    true,
    false,
    false,
    '+1 untyped bonus on ranged attack rolls within 30 feet'
);

INSERT INTO stat_effects (
    effect_id,
    effect_target_id,
    change_type,
    value,
    bonus_type_id
)
VALUES (
    (SELECT id FROM effects WHERE name = 'Point Blank Shot: Attack Bonus'),
    (SELECT id FROM effect_targets WHERE name = 'ranged_attack'),
    'additive',
    1,
    (SELECT id FROM bonus_types WHERE name = 'untyped')
);

INSERT INTO feat_effects (
    feat_id,
    effect_id,
    applies_when
)
VALUES (
    (SELECT id FROM feats WHERE name = 'Point Blank Shot'),
    (SELECT id FROM effects WHERE name = 'Point Blank Shot: Attack Bonus'),
    'with ranged weapons at ranges up to 30 feet'  -- Conditional
);

-- Effect 2: Damage bonus
INSERT INTO effects (
    name,
    effect_type,
    is_beneficial,
    is_magical,
    stacks_with_self,
    description
)
VALUES (
    'Point Blank Shot: Damage Bonus',
    'stat',
    true,
    false,
    false,
    '+1 untyped bonus on ranged damage rolls within 30 feet'
);

INSERT INTO stat_effects (
    effect_id,
    effect_target_id,
    change_type,
    value,
    bonus_type_id
)
VALUES (
    (SELECT id FROM effects WHERE name = 'Point Blank Shot: Damage Bonus'),
    (SELECT id FROM effect_targets WHERE name = 'ranged_damage'),
    'additive',
    1,
    (SELECT id FROM bonus_types WHERE name = 'untyped')
);

INSERT INTO feat_effects (
    feat_id,
    effect_id,
    applies_when
)
VALUES (
    (SELECT id FROM feats WHERE name = 'Point Blank Shot'),
    (SELECT id FROM effects WHERE name = 'Point Blank Shot: Damage Bonus'),
    'with ranged weapons at ranges up to 30 feet'
);

-- =====================================================
-- FEAT 7: IMPROVED GRAPPLE
-- =====================================================
-- PATTERN: Multiple prerequisites (ability score + feat), multiple benefits
-- DECISIONS:
-- - Requires DEX 13 AND Improved Unarmed Strike → Multiple prerequisites in same group
-- - Grants +4 to grapple checks → Create effect
-- - Prevents attacks of opportunity → Create special_ability
-- - Has both mechanical (effect) and narrative (special ability) components

INSERT INTO feats (
    name,
    feat_type,
    description,
    benefit,
    special,
    choice_required,
    choice_type,
    multiples_allowed
)
VALUES (
    'Improved Grapple',
    'general',
    'You do not provoke an attack of opportunity when you make a touch attack to start a grapple. You also gain a +4 bonus on all grapple checks.',
    'You do not provoke an attack of opportunity when you make a touch attack to start a grapple. You also gain a +4 bonus on all grapple checks, regardless of whether you started the grapple.',
    'A fighter may select Improved Grapple as one of his fighter bonus feats. A monk may select Improved Grapple as a bonus feat at 1st level, even if she does not meet the prerequisites.',
    false,
    NULL,
    false
);

-- Prerequisites: DEX 13 AND Improved Unarmed Strike
-- DECISION: Multiple prerequisites in same AND group (see Example 14 in prerequisites-creation.sql)
-- For this example, we'll create the DEX prereq and document the feat prereq
WITH new_ability_prereq AS (
    INSERT INTO ability_score_prerequisites (ability_score, minimum_value)
    VALUES ('DEX', 13)
    RETURNING id
),
new_group AS (
    INSERT INTO prerequisite_groups (logic_operator, description)
    VALUES ('AND', 'Improved Grapple: Requires DEX 13 and Improved Unarmed Strike')
    RETURNING id
)
INSERT INTO prerequisite_conditions (
    parent_group_id,
    condition_type,
    ability_score_prerequisite_id
)
SELECT new_group.id, 'ability_score', new_ability_prereq.id
FROM new_group, new_ability_prereq;

-- Add feat prerequisite (Improved Unarmed Strike must exist first)
-- WITH new_feat_prereq AS (
--     INSERT INTO feat_requirement_prerequisites (required_feat_id)
--     VALUES ((SELECT id FROM feats WHERE name = 'Improved Unarmed Strike'))
--     RETURNING id
-- )
-- INSERT INTO prerequisite_conditions (
--     parent_group_id,
--     condition_type,
--     feat_prerequisite_id
-- )
-- SELECT
--     (SELECT id FROM prerequisite_groups WHERE description = 'Improved Grapple: Requires DEX 13 and Improved Unarmed Strike'),
--     'feat_requirement',
--     id
-- FROM new_feat_prereq;

UPDATE feats
SET prerequisite_group_id = (SELECT id FROM prerequisite_groups WHERE description = 'Improved Grapple: Requires DEX 13 and Improved Unarmed Strike')
WHERE name = 'Improved Grapple';

-- Benefit 1: +4 grapple bonus (mechanical effect)
INSERT INTO effects (
    name,
    effect_type,
    is_beneficial,
    is_magical,
    stacks_with_self,
    description
)
VALUES (
    'Improved Grapple: Grapple Bonus',
    'stat',
    true,
    false,
    false,
    '+4 untyped bonus on all grapple checks'
);

INSERT INTO stat_effects (
    effect_id,
    effect_target_id,
    change_type,
    value,
    bonus_type_id
)
VALUES (
    (SELECT id FROM effects WHERE name = 'Improved Grapple: Grapple Bonus'),
    (SELECT id FROM effect_targets WHERE name = 'Grapple_check'),
    'additive',
    4,
    (SELECT id FROM bonus_types WHERE name = 'untyped')
);

INSERT INTO feat_effects (
    feat_id,
    effect_id,
    applies_when
)
VALUES (
    (SELECT id FROM feats WHERE name = 'Improved Grapple'),
    (SELECT id FROM effects WHERE name = 'Improved Grapple: Grapple Bonus'),
    NULL  -- Always applies during grapple
);

-- Benefit 2: No attacks of opportunity (narrative benefit)
-- DECISION: Use special_abilities for non-numeric benefits
-- DECISION: is_active = false (passive benefit, not activated)
INSERT INTO special_abilities (
    name,
    ability_type,
    is_active,
    description,
    source_category
)
VALUES (
    'Improved Grapple: No AoO',
    'extraordinary',
    false,  -- Passive benefit
    'You do not provoke an attack of opportunity when you make a touch attack to start a grapple',
    'feat'
);

-- CORRECTED: Table name is feat_granted_abilities, not feat_special_abilities
INSERT INTO feat_granted_abilities (
    feat_id,
    special_ability_id
)
VALUES (
    (SELECT id FROM feats WHERE name = 'Improved Grapple'),
    (SELECT id FROM special_abilities WHERE name = 'Improved Grapple: No AoO')
);

-- =====================================================
-- FEAT 8: EMPOWER SPELL
-- =====================================================
-- PATTERN: Metamagic feat (no effects, only special ability)
-- DECISIONS:
-- - feat_type = 'metamagic' (different from 'general')
-- - No mechanical bonus to model in effects system
-- - Entire benefit is narrative → Use special_abilities only
-- - No prerequisites
-- - is_active = true (you choose when to apply it)

INSERT INTO feats (
    name,
    feat_type,
    description,
    benefit,
    special,
    choice_required,
    choice_type,
    multiples_allowed
)
VALUES (
    'Empower Spell',
    'metamagic',  -- METAMAGIC feat type
    'All variable, numeric effects of an empowered spell are increased by one-half.',
    'All variable, numeric effects of an empowered spell are increased by one-half. Saving throws and opposed rolls are not affected, nor are spells without random variables. An empowered spell uses up a spell slot two levels higher than the spell''s actual level.',
    NULL,
    false,
    NULL,
    false
);

-- DECISION: No effects created - metamagic modifies spells, not character stats
-- Create special_ability instead
INSERT INTO special_abilities (
    name,
    ability_type,
    is_active,
    description,
    source_category
)
VALUES (
    'Empower Spell',
    'extraordinary',
    true,  -- ACTIVE - you choose when to empower a spell
    'All variable, numeric effects of an empowered spell are increased by one-half. An empowered spell uses up a spell slot two levels higher than the spell''s actual level.',
    'feat'
);

-- CORRECTED: Table name is feat_granted_abilities
INSERT INTO feat_granted_abilities (
    feat_id,
    special_ability_id
)
VALUES (
    (SELECT id FROM feats WHERE name = 'Empower Spell'),
    (SELECT id FROM special_abilities WHERE name = 'Empower Spell')
);

-- =====================================================
-- FEAT 9: QUICKEN SPELL
-- =====================================================
-- PATTERN: Metamagic feat with complex rules
-- DECISIONS:
-- - feat_type = 'metamagic'
-- - Complex narrative rules → special_abilities
-- - is_active = true (choose when to use)
-- - Special notes about spontaneous casting → document in description

INSERT INTO feats (
    name,
    feat_type,
    description,
    benefit,
    special,
    choice_required,
    choice_type,
    multiples_allowed
)
VALUES (
    'Quicken Spell',
    'metamagic',
    'Casting a quickened spell is a free action.',
    'Casting a quickened spell is a free action. You can perform another action, even casting another spell, in the same round as you cast a quickened spell. You may cast only one quickened spell per round. A spell whose casting time is more than 1 full round action cannot be quickened. A quickened spell uses up a spell slot four levels higher than the spell''s actual level. Casting a quickened spell doesn''t provoke an attack of opportunity.',
    'This feat can''t be applied to any spell cast spontaneously (including sorcerer spells, bard spells, and cleric or druid spells cast spontaneously), since applying a metamagic feat to a spontaneously cast spell automatically increases the casting time to a full-round action.',
    false,
    NULL,
    false
);

INSERT INTO special_abilities (
    name,
    ability_type,
    is_active,
    description,
    source_category
)
VALUES (
    'Quicken Spell',
    'extraordinary',
    true,  -- Choose when to quicken
    'Cast a spell as a free action. Uses spell slot 4 levels higher. Cannot quicken spells cast spontaneously. Only one quickened spell per round.',
    'feat'
);

-- CORRECTED: Table name is feat_granted_abilities
INSERT INTO feat_granted_abilities (
    feat_id,
    special_ability_id
)
VALUES (
    (SELECT id FROM feats WHERE name = 'Quicken Spell'),
    (SELECT id FROM special_abilities WHERE name = 'Quicken Spell')
);

-- =====================================================
-- FEAT 10: LEADERSHIP
-- =====================================================
-- PATTERN: Character level prerequisite, complex special ability
-- DECISIONS:
-- - Requires character level 6 → Use character_level_prerequisites table
-- - NOTE: character_level_prerequisites is for TOTAL character level (sum of all class levels)
-- - This is different from class_level_prerequisites which requires specific class levels
-- - No mechanical bonuses → special_abilities only
-- - Complex rules about cohorts/followers → narrative description

INSERT INTO feats (
    name,
    feat_type,
    description,
    benefit,
    special,
    choice_required,
    choice_type,
    multiples_allowed
)
VALUES (
    'Leadership',
    'general',
    'Having this feat enables the character to attract loyal companions and devoted followers.',
    'Having this feat enables the character to attract loyal companions and devoted followers, subordinates who assist her. Leadership score = character level + Cha modifier.',
    'A character cannot have more than one Leadership feat. Leadership Modifiers affect the base score based on reputation, fairness, treatment of followers, etc. See Core Rulebook for full Leadership tables and rules.',
    false,
    NULL,
    false
);

-- Create prerequisite for total character level 6
-- DECISION: Use character_level_prerequisites (not class_level_prerequisites)
-- character_level_prerequisites = total level across all classes
-- class_level_prerequisites = specific class level (e.g., "Fighter 4")
WITH new_char_level_prereq AS (
    INSERT INTO character_level_prerequisites (minimum_level)
    VALUES (6)
    RETURNING id
),
new_group AS (
    INSERT INTO prerequisite_groups (logic_operator, description)
    VALUES ('AND', 'Leadership: Requires character level 6th')
    RETURNING id
)
INSERT INTO prerequisite_conditions (
    parent_group_id,
    condition_type,
    character_level_prerequisite_id
)
SELECT new_group.id, 'character_level', new_char_level_prereq.id
FROM new_group, new_char_level_prereq;

UPDATE feats
SET prerequisite_group_id = (SELECT id FROM prerequisite_groups WHERE description = 'Leadership: Requires character level 6th')
WHERE name = 'Leadership';

-- Create special ability for Leadership
INSERT INTO special_abilities (
    name,
    ability_type,
    is_active,
    description,
    source_category
)
VALUES (
    'Leadership',
    'extraordinary',
    false,  -- Passive - always attracting followers
    'Attract cohort and followers. Leadership score = character level + Cha modifier + reputation modifiers. See Leadership tables for cohort level and follower counts.',
    'feat'
);

-- CORRECTED: Table name is feat_granted_abilities
INSERT INTO feat_granted_abilities (
    feat_id,
    special_ability_id
)
VALUES (
    (SELECT id FROM feats WHERE name = 'Leadership'),
    (SELECT id FROM special_abilities WHERE name = 'Leadership')
);

-- =====================================================
-- SUMMARY: DECISION TREE FOR FEAT IMPORTS
-- =====================================================
-- Use this flowchart when importing new feats:
--
-- 1. READ THE FEAT DESCRIPTION CAREFULLY
--    ├─ Identify feat_type (general, metamagic, item_creation, etc.)
--    ├─ Identify all prerequisites
--    ├─ Identify all benefits (mechanical + narrative)
--    └─ Check Special section for multiples/stacking rules
--
-- 2. DETERMINE FEAT FLAGS
--    ├─ choice_required: Does it require choosing weapon/skill/spell school?
--    ├─ choice_type: What type of choice ('weapon', 'skill', 'school', etc.)
--    └─ multiples_allowed: Can you take it multiple times?
--
-- 3. CREATE PREREQUISITES (if any)
--    ├─ See prerequisites-creation.sql for patterns
--    ├─ Common types: ability_score, base_attack_bonus, feat_requirement
--    └─ Use AND groups for multiple prerequisites
--
-- 4. IDENTIFY MECHANICAL BENEFITS
--    ├─ Does it grant numeric bonuses? → Create effects
--    │  ├─ Determine bonus type (untyped, dodge, competence, etc.)
--    │  ├─ Determine effect_target (which stat/check/save?)
--    │  ├─ Set stacks_with_self based on Special section
--    │  └─ Use applies_when for conditional bonuses
--    └─ No numeric bonuses? → Skip to step 5
--
-- 5. IDENTIFY NARRATIVE BENEFITS
--    ├─ Does it grant abilities that can't be modeled as numbers?
--    │  ├─ Create special_abilities
--    │  ├─ Set is_active = true if player chooses when to use
--    │  └─ Set is_active = false if always on
--    └─ No narrative benefits? → Done
--
-- 6. LINK EVERYTHING TOGETHER
--    ├─ UPDATE feats SET prerequisite_group_id
--    ├─ INSERT INTO feat_effects (for each effect)
--    └─ INSERT INTO feat_granted_abilities (for each ability)
--
-- 7. CONFIGURE CHOICE CONSTRAINTS (if choice_required = true)
--    ├─ INSERT INTO feat_choice_constraints
--    └─ Optionally INSERT INTO feat_choice_filters for complex filtering
--
-- =====================================================
-- COMMON PATTERNS REFERENCE
-- =====================================================
--
-- PATTERN: Simple skill bonus
-- Example: Acrobatic (+2 Jump, +2 Tumble)
-- → Create 2 effects, 2 stat_effects, 2 feat_effects
-- → bonus_type = 'competence' for skill bonuses
--
-- PATTERN: Save bonus
-- Example: Great Fortitude (+2 Fort)
-- → Create 1 effect targeting Fortitude_save
-- → bonus_type = 'untyped' (unless specified)
--
-- PATTERN: Attack bonus
-- Example: Weapon Focus (+1 attack)
-- → Create effect targeting melee_attack or ranged_attack
-- → Document weapon choice in applies_when
-- → Use feat_choice_constraints for weapon validation
--
-- PATTERN: Metamagic feat
-- Example: Empower Spell, Quicken Spell
-- → feat_type = 'metamagic'
-- → NO effects (doesn't modify character stats)
-- → Create special_ability with is_active = true
--
-- PATTERN: Multiple prerequisites (AND)
-- Example: Improved Grapple (DEX 13 AND Improved Unarmed Strike)
-- → Create 1 prerequisite_group with logic_operator = 'AND'
-- → Insert multiple prerequisite_conditions referencing same group
-- → See Example 14 in prerequisites-creation.sql
--
-- PATTERN: Choice-required feat
-- Example: Weapon Focus, Spell Focus, Skill Focus
-- → choice_required = true
-- → choice_type = 'weapon'/'skill'/'school'/etc.
-- → multiples_allowed = usually true
-- → Use feat_choice_constraints to define valid choices
-- → Document choice in applies_when field
--
-- PATTERN: Stackable feat
-- Example: Toughness (can take multiple times, effects stack)
-- → multiples_allowed = true
-- → stacks_with_self = true in effects table
-- → NOTE: This is RARE - most multiples don't stack
--
-- PATTERN: Mixed benefits (mechanical + narrative)
-- Example: Improved Grapple (+4 grapple, no AoO)
-- → Create effects for numeric bonuses
-- → Create special_abilities for narrative benefits
-- → Link both to feat via feat_effects and feat_granted_abilities
--
-- =====================================================
-- SCHEMA REFERENCE
-- =====================================================
-- FEATS TABLE COLUMNS:
-- - id: SERIAL PRIMARY KEY
-- - name: VARCHAR(100) NOT NULL UNIQUE
-- - feat_type: VARCHAR(30) NOT NULL ('general', 'metamagic', 'item_creation', etc.)
-- - description: TEXT NOT NULL
-- - benefit: TEXT NOT NULL
-- - special: TEXT (optional special rules)
-- - choice_required: BOOLEAN NOT NULL DEFAULT false
-- - choice_type: VARCHAR(30) (what to choose: 'weapon', 'skill', 'school', etc.)
-- - multiples_allowed: BOOLEAN NOT NULL DEFAULT false
-- - created_at: TIMESTAMP NOT NULL DEFAULT NOW()
--
-- RELATED TABLES:
-- - feat_effects: Links feats to effects they grant (with applies_when condition)
-- - feat_granted_abilities: Links feats to special_abilities they grant
-- - feat_prerequisites: Links feats to prerequisite_groups
-- - feat_choice_constraints: Defines valid choices for choice-required feats
-- - feat_choice_filters: Filter conditions for valid choices (WHERE clauses)
-- - feat_variable_effects: Variable magnitude feats (Power Attack, Combat Expertise)
-- - feat_granted_conditions: Links feats to conditions they can grant
--
-- BONUS_TYPES TABLE:
-- - name: VARCHAR(50) NOT NULL UNIQUE
-- - can_stack: BOOLEAN NOT NULL DEFAULT false
-- - description: TEXT
--
-- =====================================================
-- END OF FEAT IMPORT GUIDE
-- =====================================================

COMMIT;
