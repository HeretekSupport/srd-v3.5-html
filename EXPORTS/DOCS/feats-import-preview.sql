-- ============================================================================
-- D&D 3.5 SRD FEATS IMPORT - PREVIEW (Feats 1-11)
-- ============================================================================
-- This is a PREVIEW showing the import strategy for the first 11 feats
-- ============================================================================

SET search_path TO pnpo_3_5_dev;

BEGIN;

-- ============================================================================
-- DEPENDENCIES SECTION
-- ============================================================================
-- This section creates all the reference data needed for the feats below
-- Must be created FIRST before importing feats
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. BONUS TYPES
-- ----------------------------------------------------------------------------
-- Bonus types define how bonuses stack (same type = doesn't stack, different types = stack)

INSERT INTO pnpo_3_5_dev.bonus_types (name, stacks, description)
VALUES
    ('competence', false, 'Bonus from skill or training - does not stack with other competence bonuses'),
    ('enhancement', false, 'Magical bonus that enhances an existing item or ability - does not stack'),
    ('untyped', true, 'No specific type - usually stacks with everything including itself')
ON CONFLICT (name) DO NOTHING;


-- ----------------------------------------------------------------------------
-- 2. EFFECT TARGET CATEGORIES
-- ----------------------------------------------------------------------------
-- Categories organize effect targets into logical groups

INSERT INTO pnpo_3_5_dev.effect_target_categories (name, description)
VALUES
    ('ability_scores', 'The six core ability scores (STR, DEX, CON, INT, WIS, CHA)'),
    ('skill_checks', 'Skill check bonuses and penalties'),
    ('saving_throws', 'Fortitude, Reflex, and Will saves'),
    ('attack_rolls', 'Attack roll bonuses and penalties'),
    ('armor_class', 'AC and AC component modifiers'),
    ('hit_points', 'HP, temporary HP, and HP-related values')
ON CONFLICT (name) DO NOTHING;


-- ----------------------------------------------------------------------------
-- 3. EFFECT TARGETS - ABILITY SCORES
-- ----------------------------------------------------------------------------
-- The six core ability scores that can be modified by effects

INSERT INTO pnpo_3_5_dev.effect_targets (name, category_id, description)
VALUES
    ('STR', (SELECT id FROM pnpo_3_5_dev.effect_target_categories WHERE name = 'ability_scores'), 'Strength ability score'),
    ('DEX', (SELECT id FROM pnpo_3_5_dev.effect_target_categories WHERE name = 'ability_scores'), 'Dexterity ability score'),
    ('CON', (SELECT id FROM pnpo_3_5_dev.effect_target_categories WHERE name = 'ability_scores'), 'Constitution ability score'),
    ('INT', (SELECT id FROM pnpo_3_5_dev.effect_target_categories WHERE name = 'ability_scores'), 'Intelligence ability score'),
    ('WIS', (SELECT id FROM pnpo_3_5_dev.effect_target_categories WHERE name = 'ability_scores'), 'Wisdom ability score'),
    ('CHA', (SELECT id FROM pnpo_3_5_dev.effect_target_categories WHERE name = 'ability_scores'), 'Charisma ability score')
ON CONFLICT (name) DO NOTHING;


-- ----------------------------------------------------------------------------
-- 4. EFFECT TARGETS - SKILL CHECKS
-- ----------------------------------------------------------------------------
-- Effect targets for skill check bonuses (referenced by the first 10 feats)
-- Naming convention: {Skill_Name}_check

INSERT INTO pnpo_3_5_dev.effect_targets (name, category_id, description)
VALUES
    -- Acrobatic feat skills
    ('Jump_check', (SELECT id FROM pnpo_3_5_dev.effect_target_categories WHERE name = 'skill_checks'), 'Jump skill check modifier'),
    ('Tumble_check', (SELECT id FROM pnpo_3_5_dev.effect_target_categories WHERE name = 'skill_checks'), 'Tumble skill check modifier'),

    -- Agile feat skills
    ('Balance_check', (SELECT id FROM pnpo_3_5_dev.effect_target_categories WHERE name = 'skill_checks'), 'Balance skill check modifier'),
    ('Escape_Artist_check', (SELECT id FROM pnpo_3_5_dev.effect_target_categories WHERE name = 'skill_checks'), 'Escape Artist skill check modifier'),

    -- Alertness feat skills
    ('Listen_check', (SELECT id FROM pnpo_3_5_dev.effect_target_categories WHERE name = 'skill_checks'), 'Listen skill check modifier'),
    ('Spot_check', (SELECT id FROM pnpo_3_5_dev.effect_target_categories WHERE name = 'skill_checks'), 'Spot skill check modifier'),

    -- Animal Affinity feat skills
    ('Handle_Animal_check', (SELECT id FROM pnpo_3_5_dev.effect_target_categories WHERE name = 'skill_checks'), 'Handle Animal skill check modifier'),
    ('Ride_check', (SELECT id FROM pnpo_3_5_dev.effect_target_categories WHERE name = 'skill_checks'), 'Ride skill check modifier'),

    -- Athletic feat skills
    ('Climb_check', (SELECT id FROM pnpo_3_5_dev.effect_target_categories WHERE name = 'skill_checks'), 'Climb skill check modifier'),
    ('Swim_check', (SELECT id FROM pnpo_3_5_dev.effect_target_categories WHERE name = 'skill_checks'), 'Swim skill check modifier')
ON CONFLICT (name) DO NOTHING;


-- ============================================================================
-- END OF DEPENDENCIES SECTION
-- ============================================================================


-- ============================================================================
-- FEAT 1: ACROBATIC [General]
-- Benefit: +2 bonus on Jump and Tumble checks
-- ============================================================================

-- Insert feat
INSERT INTO pnpo_3_5_dev.feats (name, feat_type, description, benefit, choice_required, multiples_allowed)
VALUES (
    'Acrobatic',
    'general',
    'You have excellent body awareness and coordination.',
    'You get a +2 bonus on all Jump checks and Tumble checks.',
    false,
    false
);

-- Create effects for skill bonuses
INSERT INTO pnpo_3_5_dev.effects (name, effect_type, is_beneficial, is_magical, stacks_with_self, description)
VALUES
    ('Acrobatic: Jump Bonus', 'stat', true, false, false, '+2 competence bonus to Jump checks'),
    ('Acrobatic: Tumble Bonus', 'stat', true, false, false, '+2 competence bonus to Tumble checks');

-- Create stat_effects (assumes effect_target records exist for skill checks)
-- Note: Will need to lookup skill IDs and create effect_targets like "Jump_check", "Tumble_check"
INSERT INTO pnpo_3_5_dev.stat_effects (effect_id, effect_target_id, change_type, value, bonus_type_id)
VALUES
    ((SELECT id FROM pnpo_3_5_dev.effects WHERE name = 'Acrobatic: Jump Bonus'),
     (SELECT id FROM pnpo_3_5_dev.effect_targets WHERE name = 'Jump_check'),
     'additive',
     2,
     (SELECT id FROM pnpo_3_5_dev.bonus_types WHERE name = 'competence')),
    ((SELECT id FROM pnpo_3_5_dev.effects WHERE name = 'Acrobatic: Tumble Bonus'),
     (SELECT id FROM pnpo_3_5_dev.effect_targets WHERE name = 'Tumble_check'),
     'additive',
     2,
     (SELECT id FROM pnpo_3_5_dev.bonus_types WHERE name = 'competence'));

-- Link effects to feat
INSERT INTO pnpo_3_5_dev.feat_effects (feat_id, effect_id, applies_when)
VALUES
    ((SELECT id FROM pnpo_3_5_dev.feats WHERE name = 'Acrobatic'),
     (SELECT id FROM pnpo_3_5_dev.effects WHERE name = 'Acrobatic: Jump Bonus'),
     NULL),
    ((SELECT id FROM pnpo_3_5_dev.feats WHERE name = 'Acrobatic'),
     (SELECT id FROM pnpo_3_5_dev.effects WHERE name = 'Acrobatic: Tumble Bonus'),
     NULL);


-- ============================================================================
-- FEAT 2: AGILE [General]
-- Benefit: +2 bonus on Balance and Escape Artist checks
-- ============================================================================

INSERT INTO pnpo_3_5_dev.feats (name, feat_type, description, benefit, choice_required, multiples_allowed)
VALUES (
    'Agile',
    'general',
    'You are particularly dexterous and poised.',
    'You get a +2 bonus on all Balance checks and Escape Artist checks.',
    false,
    false
);

INSERT INTO pnpo_3_5_dev.effects (name, effect_type, is_beneficial, is_magical, stacks_with_self, description)
VALUES
    ('Agile: Balance Bonus', 'stat', true, false, false, '+2 competence bonus to Balance checks'),
    ('Agile: Escape Artist Bonus', 'stat', true, false, false, '+2 competence bonus to Escape Artist checks');

INSERT INTO pnpo_3_5_dev.stat_effects (effect_id, effect_target_id, change_type, value, bonus_type_id)
VALUES
    ((SELECT id FROM pnpo_3_5_dev.effects WHERE name = 'Agile: Balance Bonus'),
     (SELECT id FROM pnpo_3_5_dev.effect_targets WHERE name = 'Balance_check'),
     'additive',
     2,
     (SELECT id FROM pnpo_3_5_dev.bonus_types WHERE name = 'competence')),
    ((SELECT id FROM pnpo_3_5_dev.effects WHERE name = 'Agile: Escape Artist Bonus'),
     (SELECT id FROM pnpo_3_5_dev.effect_targets WHERE name = 'Escape_Artist_check'),
     'additive',
     2,
     (SELECT id FROM pnpo_3_5_dev.bonus_types WHERE name = 'competence'));

INSERT INTO pnpo_3_5_dev.feat_effects (feat_id, effect_id, applies_when)
VALUES
    ((SELECT id FROM pnpo_3_5_dev.feats WHERE name = 'Agile'),
     (SELECT id FROM pnpo_3_5_dev.effects WHERE name = 'Agile: Balance Bonus'),
     NULL),
    ((SELECT id FROM pnpo_3_5_dev.feats WHERE name = 'Agile'),
     (SELECT id FROM pnpo_3_5_dev.effects WHERE name = 'Agile: Escape Artist Bonus'),
     NULL);


-- ============================================================================
-- FEAT 3: ALERTNESS [General]
-- Benefit: +2 bonus on Listen and Spot checks
-- Special: Master of familiar gains benefit when familiar is within arm's reach
-- ============================================================================

INSERT INTO pnpo_3_5_dev.feats (name, feat_type, description, benefit, special, choice_required, multiples_allowed)
VALUES (
    'Alertness',
    'general',
    'You have finely tuned senses.',
    'You get a +2 bonus on all Listen checks and Spot checks.',
    'The master of a familiar gains the benefit of the Alertness feat whenever the familiar is within arm''s reach.',
    false,
    false
);

INSERT INTO pnpo_3_5_dev.effects (name, effect_type, is_beneficial, is_magical, stacks_with_self, description)
VALUES
    ('Alertness: Listen Bonus', 'stat', true, false, false, '+2 competence bonus to Listen checks'),
    ('Alertness: Spot Bonus', 'stat', true, false, false, '+2 competence bonus to Spot checks');

INSERT INTO pnpo_3_5_dev.stat_effects (effect_id, effect_target_id, change_type, value, bonus_type_id)
VALUES
    ((SELECT id FROM pnpo_3_5_dev.effects WHERE name = 'Alertness: Listen Bonus'),
     (SELECT id FROM pnpo_3_5_dev.effect_targets WHERE name = 'Listen_check'),
     'additive',
     2,
     (SELECT id FROM pnpo_3_5_dev.bonus_types WHERE name = 'competence')),
    ((SELECT id FROM pnpo_3_5_dev.effects WHERE name = 'Alertness: Spot Bonus'),
     (SELECT id FROM pnpo_3_5_dev.effect_targets WHERE name = 'Spot_check'),
     'additive',
     2,
     (SELECT id FROM pnpo_3_5_dev.bonus_types WHERE name = 'competence'));

INSERT INTO pnpo_3_5_dev.feat_effects (feat_id, effect_id, applies_when)
VALUES
    ((SELECT id FROM pnpo_3_5_dev.feats WHERE name = 'Alertness'),
     (SELECT id FROM pnpo_3_5_dev.effects WHERE name = 'Alertness: Listen Bonus'),
     NULL),
    ((SELECT id FROM pnpo_3_5_dev.feats WHERE name = 'Alertness'),
     (SELECT id FROM pnpo_3_5_dev.effects WHERE name = 'Alertness: Spot Bonus'),
     NULL);


-- ============================================================================
-- FEAT 4: ANIMAL AFFINITY [General]
-- Benefit: +2 bonus on Handle Animal and Ride checks
-- ============================================================================

INSERT INTO pnpo_3_5_dev.feats (name, feat_type, description, benefit, choice_required, multiples_allowed)
VALUES (
    'Animal Affinity',
    'general',
    'You are good with animals.',
    'You get a +2 bonus on all Handle Animal checks and Ride checks.',
    false,
    false
);

INSERT INTO pnpo_3_5_dev.effects (name, effect_type, is_beneficial, is_magical, stacks_with_self, description)
VALUES
    ('Animal Affinity: Handle Animal Bonus', 'stat', true, false, false, '+2 competence bonus to Handle Animal checks'),
    ('Animal Affinity: Ride Bonus', 'stat', true, false, false, '+2 competence bonus to Ride checks');

INSERT INTO pnpo_3_5_dev.stat_effects (effect_id, effect_target_id, change_type, value, bonus_type_id)
VALUES
    ((SELECT id FROM pnpo_3_5_dev.effects WHERE name = 'Animal Affinity: Handle Animal Bonus'),
     (SELECT id FROM pnpo_3_5_dev.effect_targets WHERE name = 'Handle_Animal_check'),
     'additive',
     2,
     (SELECT id FROM pnpo_3_5_dev.bonus_types WHERE name = 'competence')),
    ((SELECT id FROM pnpo_3_5_dev.effects WHERE name = 'Animal Affinity: Ride Bonus'),
     (SELECT id FROM pnpo_3_5_dev.effect_targets WHERE name = 'Ride_check'),
     'additive',
     2,
     (SELECT id FROM pnpo_3_5_dev.bonus_types WHERE name = 'competence'));

INSERT INTO pnpo_3_5_dev.feat_effects (feat_id, effect_id, applies_when)
VALUES
    ((SELECT id FROM pnpo_3_5_dev.feats WHERE name = 'Animal Affinity'),
     (SELECT id FROM pnpo_3_5_dev.effects WHERE name = 'Animal Affinity: Handle Animal Bonus'),
     NULL),
    ((SELECT id FROM pnpo_3_5_dev.feats WHERE name = 'Animal Affinity'),
     (SELECT id FROM pnpo_3_5_dev.effects WHERE name = 'Animal Affinity: Ride Bonus'),
     NULL);


-- ============================================================================
-- FEAT 5: ARMOR PROFICIENCY (LIGHT) [General]
-- No prerequisites
-- Benefit: Armor check penalty only applies to specific skills
-- Special: All characters except wizards, sorcerers, monks get this as bonus feat
-- ============================================================================

INSERT INTO pnpo_3_5_dev.feats (name, feat_type, description, benefit, special, choice_required, multiples_allowed)
VALUES (
    'Armor Proficiency (Light)',
    'general',
    'You are proficient with light armor.',
    'When you wear a type of armor with which you are proficient, the armor check penalty for that armor applies only to Balance, Climb, Escape Artist, Hide, Jump, Move Silently, Sleight of Hand, and Tumble checks.',
    'All characters except wizards, sorcerers, and monks automatically have Armor Proficiency (light) as a bonus feat. They need not select it.',
    false,
    false
);

-- Create special ability for Light Armor Proficiency
INSERT INTO pnpo_3_5_dev.special_abilities (name, ability_type, is_active, description, source_category)
VALUES (
    'Light Armor Proficiency',
    'extraordinary',
    false,
    'Proficient with light armor - armor check penalty only applies to specific skills',
    'feat'
);

-- Link ability to feat
INSERT INTO pnpo_3_5_dev.feat_granted_abilities (feat_id, special_ability_id, notes)
VALUES (
    (SELECT id FROM pnpo_3_5_dev.feats WHERE name = 'Armor Proficiency (Light)'),
    (SELECT id FROM pnpo_3_5_dev.special_abilities WHERE name = 'Light Armor Proficiency'),
    'Grants proficiency with all light armor types'
);


-- ============================================================================
-- FEAT 6: ARMOR PROFICIENCY (MEDIUM) [General]
-- Prerequisite: Armor Proficiency (Light)
-- Benefit: See Armor Proficiency (Light)
-- Special: Fighters, barbarians, paladins, clerics, druids, bards get bonus feat
-- ============================================================================

INSERT INTO pnpo_3_5_dev.feats (name, feat_type, description, benefit, special, choice_required, multiples_allowed)
VALUES (
    'Armor Proficiency (Medium)',
    'general',
    'You are proficient with medium armor.',
    'When you wear a type of armor with which you are proficient, the armor check penalty for that armor applies only to Balance, Climb, Escape Artist, Hide, Jump, Move Silently, Sleight of Hand, and Tumble checks.',
    'Fighters, barbarians, paladins, clerics, druids, and bards automatically have Armor Proficiency (medium) as a bonus feat. They need not select it.',
    false,
    false
);

-- Create prerequisite group
INSERT INTO pnpo_3_5_dev.prerequisite_groups (name, join_type, description)
VALUES (
    'Armor Proficiency (Medium) Prerequisites',
    'AND',
    'Requires Light armor proficiency'
);

-- Add feat prerequisite and link to group using CTE
WITH new_prereq AS (
    INSERT INTO pnpo_3_5_dev.feat_requirement_prerequisites (required_feat_id)
    VALUES ((SELECT id FROM pnpo_3_5_dev.feats WHERE name = 'Armor Proficiency (Light)'))
    RETURNING id
)
INSERT INTO pnpo_3_5_dev.prerequisite_conditions (prerequisite_group_id, condition_type, prerequisite_id)
SELECT
    (SELECT id FROM pnpo_3_5_dev.prerequisite_groups WHERE name = 'Armor Proficiency (Medium) Prerequisites'),
    'feat_requirement',
    id
FROM new_prereq;

-- Link prerequisite group to feat
INSERT INTO pnpo_3_5_dev.feat_prerequisites (feat_id, prerequisite_group_id)
VALUES (
    (SELECT id FROM pnpo_3_5_dev.feats WHERE name = 'Armor Proficiency (Medium)'),
    (SELECT id FROM pnpo_3_5_dev.prerequisite_groups WHERE name = 'Armor Proficiency (Medium) Prerequisites')
);

-- Create special ability
INSERT INTO pnpo_3_5_dev.special_abilities (name, ability_type, is_active, description, source_category)
VALUES (
    'Medium Armor Proficiency',
    'extraordinary',
    false,
    'Proficient with medium armor - armor check penalty only applies to specific skills',
    'feat'
);

-- Link ability to feat
INSERT INTO pnpo_3_5_dev.feat_granted_abilities (feat_id, special_ability_id, notes)
VALUES (
    (SELECT id FROM pnpo_3_5_dev.feats WHERE name = 'Armor Proficiency (Medium)'),
    (SELECT id FROM pnpo_3_5_dev.special_abilities WHERE name = 'Medium Armor Proficiency'),
    'Grants proficiency with all medium armor types'
);


-- ============================================================================
-- FEAT 7: ARMOR PROFICIENCY (HEAVY) [General]
-- Prerequisites: Armor Proficiency (Light), Armor Proficiency (Medium)
-- Benefit: See Armor Proficiency (Light)
-- Special: Fighters, paladins, clerics get this as bonus feat
-- ============================================================================

INSERT INTO pnpo_3_5_dev.feats (name, feat_type, description, benefit, special, choice_required, multiples_allowed)
VALUES (
    'Armor Proficiency (Heavy)',
    'general',
    'You are proficient with heavy armor.',
    'When you wear a type of armor with which you are proficient, the armor check penalty for that armor applies only to Balance, Climb, Escape Artist, Hide, Jump, Move Silently, Sleight of Hand, and Tumble checks.',
    'Fighters, paladins, and clerics automatically have Armor Proficiency (heavy) as a bonus feat. They need not select it.',
    false,
    false
);

-- Create prerequisite group (AND group - must have both)
INSERT INTO pnpo_3_5_dev.prerequisite_groups (name, join_type, description)
VALUES (
    'Armor Proficiency (Heavy) Prerequisites',
    'AND',
    'Requires both Light and Medium armor proficiency'
);

-- Add feat prerequisites and link to group using CTE
WITH new_prereqs AS (
    INSERT INTO pnpo_3_5_dev.feat_requirement_prerequisites (required_feat_id)
    VALUES
        ((SELECT id FROM pnpo_3_5_dev.feats WHERE name = 'Armor Proficiency (Light)')),
        ((SELECT id FROM pnpo_3_5_dev.feats WHERE name = 'Armor Proficiency (Medium)'))
    RETURNING id
)
INSERT INTO pnpo_3_5_dev.prerequisite_conditions (prerequisite_group_id, condition_type, prerequisite_id)
SELECT
    (SELECT id FROM pnpo_3_5_dev.prerequisite_groups WHERE name = 'Armor Proficiency (Heavy) Prerequisites'),
    'feat_requirement',
    id
FROM new_prereqs;

-- Link prerequisite group to feat
INSERT INTO pnpo_3_5_dev.feat_prerequisites (feat_id, prerequisite_group_id)
VALUES (
    (SELECT id FROM pnpo_3_5_dev.feats WHERE name = 'Armor Proficiency (Heavy)'),
    (SELECT id FROM pnpo_3_5_dev.prerequisite_groups WHERE name = 'Armor Proficiency (Heavy) Prerequisites')
);

-- Create special ability for Heavy Armor Proficiency (mechanics)
INSERT INTO pnpo_3_5_dev.special_abilities (name, ability_type, is_active, description, source_category)
VALUES (
    'Heavy Armor Proficiency',
    'extraordinary',
    false,
    'Proficient with heavy armor - armor check penalty only applies to specific skills',
    'feat'
);

-- Link ability to feat
INSERT INTO pnpo_3_5_dev.feat_granted_abilities (feat_id, special_ability_id, notes)
VALUES (
    (SELECT id FROM pnpo_3_5_dev.feats WHERE name = 'Armor Proficiency (Heavy)'),
    (SELECT id FROM pnpo_3_5_dev.special_abilities WHERE name = 'Heavy Armor Proficiency'),
    'Grants proficiency with all heavy armor types'
);


-- ============================================================================
-- FEAT 8: ATHLETIC [General]
-- Benefit: +2 bonus on Climb and Swim checks
-- ============================================================================

INSERT INTO pnpo_3_5_dev.feats (name, feat_type, description, benefit, choice_required, multiples_allowed)
VALUES (
    'Athletic',
    'general',
    'You have a knack for athletic endeavors.',
    'You get a +2 bonus on all Climb checks and Swim checks.',
    false,
    false
);

INSERT INTO pnpo_3_5_dev.effects (name, effect_type, is_beneficial, is_magical, stacks_with_self, description)
VALUES
    ('Athletic: Climb Bonus', 'stat', true, false, false, '+2 competence bonus to Climb checks'),
    ('Athletic: Swim Bonus', 'stat', true, false, false, '+2 competence bonus to Swim checks');

INSERT INTO pnpo_3_5_dev.stat_effects (effect_id, effect_target_id, change_type, value, bonus_type_id)
VALUES
    ((SELECT id FROM pnpo_3_5_dev.effects WHERE name = 'Athletic: Climb Bonus'),
     (SELECT id FROM pnpo_3_5_dev.effect_targets WHERE name = 'Climb_check'),
     'additive',
     2,
     (SELECT id FROM pnpo_3_5_dev.bonus_types WHERE name = 'competence')),
    ((SELECT id FROM pnpo_3_5_dev.effects WHERE name = 'Athletic: Swim Bonus'),
     (SELECT id FROM pnpo_3_5_dev.effect_targets WHERE name = 'Swim_check'),
     'additive',
     2,
     (SELECT id FROM pnpo_3_5_dev.bonus_types WHERE name = 'competence'));

INSERT INTO pnpo_3_5_dev.feat_effects (feat_id, effect_id, applies_when)
VALUES
    ((SELECT id FROM pnpo_3_5_dev.feats WHERE name = 'Athletic'),
     (SELECT id FROM pnpo_3_5_dev.effects WHERE name = 'Athletic: Climb Bonus'),
     NULL),
    ((SELECT id FROM pnpo_3_5_dev.feats WHERE name = 'Athletic'),
     (SELECT id FROM pnpo_3_5_dev.effects WHERE name = 'Athletic: Swim Bonus'),
     NULL);


-- ============================================================================
-- FEAT 9: SPELL FOCUS [General]
-- Prerequisite: None
-- Benefit: +1 to save DCs for spells of chosen school
-- Special: Requires choosing a spell school (Conjuration, Evocation, etc.)
-- ============================================================================

INSERT INTO pnpo_3_5_dev.feats (name, feat_type, description, benefit, special, choice_required, multiples_allowed)
VALUES (
    'Spell Focus',
    'general',
    'Choose a school of magic. Your spells of that school are more potent than normal.',
    'Add +1 to the Difficulty Class for all saving throws against spells from the school of magic you select.',
    'You can gain this feat multiple times. Its effects do not stack. Each time you take the feat, it applies to a new school of magic.',
    true,
    true
);

-- Note: Spell Focus requires choice validation through feat_choice_constraints
-- The choice_source would be 'spell_schools' or similar reference table
-- This would typically be added via a feat_choice_constraints record pointing to spell schools
-- For now, we're just creating the base feat - choice constraints can be added later


-- ============================================================================
-- FEAT 10: AUGMENT SUMMONING [General]
-- Prerequisite: Spell Focus (Conjuration)
-- Benefit: Summoned creatures gain +4 enhancement to STR and CON
-- ============================================================================

INSERT INTO pnpo_3_5_dev.feats (name, feat_type, description, benefit, choice_required, multiples_allowed)
VALUES (
    'Augment Summoning',
    'general',
    'Your summoned creatures are more powerful than normal.',
    'Each creature you conjure with any summon spell gains a +4 enhancement bonus to Strength and Constitution for the duration of the spell that summoned it.',
    false,
    false
);

-- Create prerequisite group
INSERT INTO pnpo_3_5_dev.prerequisite_groups (name, join_type, description)
VALUES (
    'Augment Summoning Prerequisites',
    'AND',
    'Requires Spell Focus (Conjuration)'
);

-- Add feat prerequisite and link to group using CTE
-- NOTE: This assumes Spell Focus feat exists. Will need choice validation for (Conjuration)
WITH new_prereq AS (
    INSERT INTO pnpo_3_5_dev.feat_requirement_prerequisites (required_feat_id)
    VALUES ((SELECT id FROM pnpo_3_5_dev.feats WHERE name = 'Spell Focus'))
    RETURNING id
)
INSERT INTO pnpo_3_5_dev.prerequisite_conditions (prerequisite_group_id, condition_type, prerequisite_id)
SELECT
    (SELECT id FROM pnpo_3_5_dev.prerequisite_groups WHERE name = 'Augment Summoning Prerequisites'),
    'feat_requirement',
    id
FROM new_prereq;

-- Link prerequisite group to feat
INSERT INTO pnpo_3_5_dev.feat_prerequisites (feat_id, prerequisite_group_id)
VALUES (
    (SELECT id FROM pnpo_3_5_dev.feats WHERE name = 'Augment Summoning'),
    (SELECT id FROM pnpo_3_5_dev.prerequisite_groups WHERE name = 'Augment Summoning Prerequisites')
);

-- Create effects for STR and CON bonuses
INSERT INTO pnpo_3_5_dev.effects (name, effect_type, is_beneficial, is_magical, stacks_with_self, description)
VALUES
    ('Augment Summoning: STR Bonus', 'stat', true, true, false, '+4 enhancement bonus to Strength for summoned creatures'),
    ('Augment Summoning: CON Bonus', 'stat', true, true, false, '+4 enhancement bonus to Constitution for summoned creatures');

INSERT INTO pnpo_3_5_dev.stat_effects (effect_id, effect_target_id, change_type, value, bonus_type_id)
VALUES
    ((SELECT id FROM pnpo_3_5_dev.effects WHERE name = 'Augment Summoning: STR Bonus'),
     (SELECT id FROM pnpo_3_5_dev.effect_targets WHERE name = 'STR'),
     'additive',
     4,
     (SELECT id FROM pnpo_3_5_dev.bonus_types WHERE name = 'enhancement')),
    ((SELECT id FROM pnpo_3_5_dev.effects WHERE name = 'Augment Summoning: CON Bonus'),
     (SELECT id FROM pnpo_3_5_dev.effect_targets WHERE name = 'CON'),
     'additive',
     4,
     (SELECT id FROM pnpo_3_5_dev.bonus_types WHERE name = 'enhancement'));

-- Link effects to feat with conditional application
INSERT INTO pnpo_3_5_dev.feat_effects (feat_id, effect_id, applies_when)
VALUES
    ((SELECT id FROM pnpo_3_5_dev.feats WHERE name = 'Augment Summoning'),
     (SELECT id FROM pnpo_3_5_dev.effects WHERE name = 'Augment Summoning: STR Bonus'),
     'on summoned creatures'),
    ((SELECT id FROM pnpo_3_5_dev.feats WHERE name = 'Augment Summoning'),
     (SELECT id FROM pnpo_3_5_dev.effects WHERE name = 'Augment Summoning: CON Bonus'),
     'on summoned creatures');


-- ============================================================================
-- FEAT 11: BLIND-FIGHT [General]
-- Benefit: Special combat mechanics for fighting blind/concealed opponents
-- Special: Fighter bonus feat option
-- ============================================================================

INSERT INTO pnpo_3_5_dev.feats (name, feat_type, description, benefit, special, choice_required, multiples_allowed)
VALUES (
    'Blind-Fight',
    'general',
    'You are skilled at fighting in conditions with poor visibility.',
    'In melee, every time you miss because of concealment, you can reroll your miss chance percentile roll one time to see if you actually hit. An invisible attacker gets no advantages related to hitting you in melee. That is, you don''t lose your Dexterity bonus to Armor Class, and the attacker doesn''t get the usual +2 bonus for being invisible. The invisible attacker''s bonuses do still apply for ranged attacks, however. You take only half the usual penalty to speed for being unable to see. Darkness and poor visibility in general reduces your speed to three-quarters normal, instead of one-half.',
    'The Blind-Fight feat is of no use against a character who is the subject of a blink spell. A fighter may select Blind-Fight as one of his fighter bonus feats.',
    false,
    false
);

-- Create special ability for Blind-Fight mechanics
INSERT INTO pnpo_3_5_dev.special_abilities (name, ability_type, is_active, description, source_category)
VALUES (
    'Blind-Fight',
    'extraordinary',
    false,
    'Reroll concealment miss chance once; no penalties vs invisible attackers in melee; reduced speed penalty in darkness',
    'feat'
);

-- Link ability to feat
INSERT INTO pnpo_3_5_dev.feat_granted_abilities (feat_id, special_ability_id, notes)
VALUES (
    (SELECT id FROM pnpo_3_5_dev.feats WHERE name = 'Blind-Fight'),
    (SELECT id FROM pnpo_3_5_dev.special_abilities WHERE name = 'Blind-Fight'),
    'Complex mechanics - see feat description for full details'
);

-- Could also create specific effects for:
-- 1. Concealment reroll
-- 2. Immunity to invisible melee penalties
-- 3. Speed penalty reduction
-- (These would be created as narrative_effects or custom effect types)


COMMIT;

-- ============================================================================
-- NOTES AND DEPENDENCIES
-- ============================================================================
--
-- Before running this import, ensure the following reference data exists:
--
-- 1. BONUS TYPES:
--    - 'competence' (for skill bonuses)
--    - 'enhancement' (for ability score bonuses)
--
-- 2. EFFECT TARGETS (skill checks):
--    - 'Jump_check', 'Tumble_check'
--    - 'Balance_check', 'Escape_Artist_check'
--    - 'Listen_check', 'Spot_check'
--    - 'Handle_Animal_check', 'Ride_check'
--    - 'Climb_check', 'Swim_check'
--    - 'STR', 'CON' (ability scores)
--
-- 3. SKILLS (must exist before creating effect_targets):
--    All skills mentioned above must be in the skills table
--
-- 4. PREREQUISITE GROUPS:
--    - join_type column must support 'AND' and 'OR'
--
-- 5. OTHER FEATS (for prerequisites):
--    - Spell Focus (Conjuration) - for Augment Summoning
--
-- ============================================================================
-- MAPPING STRATEGY SUMMARY
-- ============================================================================
--
-- SIMPLE SKILL BONUS FEATS (Acrobatic, Agile, etc.):
--   1. Insert feat record
--   2. Create 2 effect records (one per skill)
--   3. Create stat_effects linking to skill check effect_targets
--   4. Link effects to feat via feat_effects
--
-- PROFICIENCY FEATS (Armor Proficiency):
--   1. Insert feat record
--   2. Create special_ability for the proficiency mechanics
--   3. Link ability to feat via feat_granted_abilities
--   4. For prerequisites: create prerequisite_group + conditions
--
-- FEATS WITH PREREQUISITES (Augment Summoning):
--   1. Insert feat record
--   2. Create prerequisite_group
--   3. Add feat_requirement_prerequisites
--   4. Link via prerequisite_conditions
--   5. Create effects and link to feat
--
-- COMPLEX MECHANICS FEATS (Blind-Fight):
--   1. Insert feat record
--   2. Create special_ability describing the mechanics
--   3. Link ability to feat
--   4. Optionally create specific effects for each mechanic
--
-- ============================================================================
