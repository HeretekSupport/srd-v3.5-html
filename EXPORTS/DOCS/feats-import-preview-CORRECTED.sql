-- ============================================================================
-- D&D 3.5 SRD FEATS IMPORT - CORRECTED (Feats 1-17)
-- ============================================================================
-- This file contains production-ready imports for 17 feats with all
-- prerequisites fully implemented.
--
-- CORRECTIONS FROM ORIGINAL PREVIEW:
-- - Brew Potion: Added caster_level_prerequisite condition
-- - Combat Expertise: Added ability_score_prerequisite condition
-- - Power Attack: Added as new feat (prerequisite for Cleave)
-- - Cleave: Added complete prerequisites (STR 13 + Power Attack)
-- ============================================================================

SET search_path TO pnpo_3_5_dev;

BEGIN;

-- ============================================================================
-- DEPENDENCIES SECTION
-- ============================================================================

-- Bonus Types
INSERT INTO pnpo_3_5_dev.bonus_types (name, can_stack, description)
VALUES
    ('competence', false, 'Bonus from skill or training - does not stack with other competence bonuses'),
    ('enhancement', false, 'Magical bonus that enhances an existing item or ability - does not stack'),
    ('untyped', true, 'No specific type - usually stacks with everything including itself')
ON CONFLICT (name) DO NOTHING;

-- Effect Target Categories
INSERT INTO pnpo_3_5_dev.effect_target_categories (name, description)
VALUES
    ('ability_scores', 'The six core ability scores (STR, DEX, CON, INT, WIS, CHA)'),
    ('skill_checks', 'Skill check bonuses and penalties'),
    ('saving_throws', 'Fortitude, Reflex, and Will saves'),
    ('attack_rolls', 'Attack roll bonuses and penalties'),
    ('armor_class', 'AC and AC component modifiers'),
    ('hit_points', 'HP, temporary HP, and HP-related values')
ON CONFLICT (name) DO NOTHING;

-- Effect Targets - Ability Scores
INSERT INTO pnpo_3_5_dev.effect_targets (name, category_id, description)
VALUES
    ('STR', (SELECT id FROM pnpo_3_5_dev.effect_target_categories WHERE name = 'ability_scores'), 'Strength ability score'),
    ('DEX', (SELECT id FROM pnpo_3_5_dev.effect_target_categories WHERE name = 'ability_scores'), 'Dexterity ability score'),
    ('CON', (SELECT id FROM pnpo_3_5_dev.effect_target_categories WHERE name = 'ability_scores'), 'Constitution ability score'),
    ('INT', (SELECT id FROM pnpo_3_5_dev.effect_target_categories WHERE name = 'ability_scores'), 'Intelligence ability score'),
    ('WIS', (SELECT id FROM pnpo_3_5_dev.effect_target_categories WHERE name = 'ability_scores'), 'Wisdom ability score'),
    ('CHA', (SELECT id FROM pnpo_3_5_dev.effect_target_categories WHERE name = 'ability_scores'), 'Charisma ability score')
ON CONFLICT (name) DO NOTHING;

-- Effect Targets - Skill Checks
INSERT INTO pnpo_3_5_dev.effect_targets (name, category_id, description)
VALUES
    ('Jump_check', (SELECT id FROM pnpo_3_5_dev.effect_target_categories WHERE name = 'skill_checks'), 'Jump skill check modifier'),
    ('Tumble_check', (SELECT id FROM pnpo_3_5_dev.effect_target_categories WHERE name = 'skill_checks'), 'Tumble skill check modifier'),
    ('Balance_check', (SELECT id FROM pnpo_3_5_dev.effect_target_categories WHERE name = 'skill_checks'), 'Balance skill check modifier'),
    ('Escape_Artist_check', (SELECT id FROM pnpo_3_5_dev.effect_target_categories WHERE name = 'skill_checks'), 'Escape Artist skill check modifier'),
    ('Listen_check', (SELECT id FROM pnpo_3_5_dev.effect_target_categories WHERE name = 'skill_checks'), 'Listen skill check modifier'),
    ('Spot_check', (SELECT id FROM pnpo_3_5_dev.effect_target_categories WHERE name = 'skill_checks'), 'Spot skill check modifier'),
    ('Handle_Animal_check', (SELECT id FROM pnpo_3_5_dev.effect_target_categories WHERE name = 'skill_checks'), 'Handle Animal skill check modifier'),
    ('Ride_check', (SELECT id FROM pnpo_3_5_dev.effect_target_categories WHERE name = 'skill_checks'), 'Ride skill check modifier'),
    ('Climb_check', (SELECT id FROM pnpo_3_5_dev.effect_target_categories WHERE name = 'skill_checks'), 'Climb skill check modifier'),
    ('Swim_check', (SELECT id FROM pnpo_3_5_dev.effect_target_categories WHERE name = 'skill_checks'), 'Swim skill check modifier'),
    ('Concentration_check', (SELECT id FROM pnpo_3_5_dev.effect_target_categories WHERE name = 'skill_checks'), 'Concentration skill check modifier')
ON CONFLICT (name) DO NOTHING;

-- ============================================================================
-- FEATS 1-8: Simple skill bonus feats (unchanged from original)
-- ============================================================================

-- FEAT 1: ACROBATIC
INSERT INTO pnpo_3_5_dev.feats (name, feat_type, description, benefit, choice_required, choice_type, multiples_allowed)
VALUES ('Acrobatic', 'general', 'You have excellent body awareness and coordination.', 'You get a +2 bonus on all Jump checks and Tumble checks.', false, NULL, false);

INSERT INTO pnpo_3_5_dev.effects (name, effect_type, is_beneficial, is_magical, stacks_with_self, description)
VALUES
    ('Acrobatic: Jump Bonus', 'stat', true, false, false, '+2 competence bonus to Jump checks'),
    ('Acrobatic: Tumble Bonus', 'stat', true, false, false, '+2 competence bonus to Tumble checks');

INSERT INTO pnpo_3_5_dev.stat_effects (effect_id, effect_target_id, change_type, value, bonus_type_id)
VALUES
    ((SELECT id FROM pnpo_3_5_dev.effects WHERE name = 'Acrobatic: Jump Bonus'),
     (SELECT id FROM pnpo_3_5_dev.effect_targets WHERE name = 'Jump_check'), 'additive', 2,
     (SELECT id FROM pnpo_3_5_dev.bonus_types WHERE name = 'competence')),
    ((SELECT id FROM pnpo_3_5_dev.effects WHERE name = 'Acrobatic: Tumble Bonus'),
     (SELECT id FROM pnpo_3_5_dev.effect_targets WHERE name = 'Tumble_check'), 'additive', 2,
     (SELECT id FROM pnpo_3_5_dev.bonus_types WHERE name = 'competence'));

INSERT INTO pnpo_3_5_dev.feat_effects (feat_id, effect_id, applies_when)
VALUES
    ((SELECT id FROM pnpo_3_5_dev.feats WHERE name = 'Acrobatic'), (SELECT id FROM pnpo_3_5_dev.effects WHERE name = 'Acrobatic: Jump Bonus'), NULL),
    ((SELECT id FROM pnpo_3_5_dev.feats WHERE name = 'Acrobatic'), (SELECT id FROM pnpo_3_5_dev.effects WHERE name = 'Acrobatic: Tumble Bonus'), NULL);


-- FEAT 2: AGILE
INSERT INTO pnpo_3_5_dev.feats (name, feat_type, description, benefit, choice_required, choice_type, multiples_allowed)
VALUES ('Agile', 'general', 'You are particularly dexterous and poised.', 'You get a +2 bonus on all Balance checks and Escape Artist checks.', false, NULL, false);

INSERT INTO pnpo_3_5_dev.effects (name, effect_type, is_beneficial, is_magical, stacks_with_self, description)
VALUES
    ('Agile: Balance Bonus', 'stat', true, false, false, '+2 competence bonus to Balance checks'),
    ('Agile: Escape Artist Bonus', 'stat', true, false, false, '+2 competence bonus to Escape Artist checks');

INSERT INTO pnpo_3_5_dev.stat_effects (effect_id, effect_target_id, change_type, value, bonus_type_id)
VALUES
    ((SELECT id FROM pnpo_3_5_dev.effects WHERE name = 'Agile: Balance Bonus'),
     (SELECT id FROM pnpo_3_5_dev.effect_targets WHERE name = 'Balance_check'), 'additive', 2,
     (SELECT id FROM pnpo_3_5_dev.bonus_types WHERE name = 'competence')),
    ((SELECT id FROM pnpo_3_5_dev.effects WHERE name = 'Agile: Escape Artist Bonus'),
     (SELECT id FROM pnpo_3_5_dev.effect_targets WHERE name = 'Escape_Artist_check'), 'additive', 2,
     (SELECT id FROM pnpo_3_5_dev.bonus_types WHERE name = 'competence'));

INSERT INTO pnpo_3_5_dev.feat_effects (feat_id, effect_id, applies_when)
VALUES
    ((SELECT id FROM pnpo_3_5_dev.feats WHERE name = 'Agile'), (SELECT id FROM pnpo_3_5_dev.effects WHERE name = 'Agile: Balance Bonus'), NULL),
    ((SELECT id FROM pnpo_3_5_dev.feats WHERE name = 'Agile'), (SELECT id FROM pnpo_3_5_dev.effects WHERE name = 'Agile: Escape Artist Bonus'), NULL);


-- FEAT 3: ALERTNESS
INSERT INTO pnpo_3_5_dev.feats (name, feat_type, description, benefit, special, choice_required, choice_type, multiples_allowed)
VALUES ('Alertness', 'general', 'You have finely tuned senses.', 'You get a +2 bonus on all Listen checks and Spot checks.',
        'The master of a familiar gains the benefit of the Alertness feat whenever the familiar is within arm''s reach.', false, NULL, false);

INSERT INTO pnpo_3_5_dev.effects (name, effect_type, is_beneficial, is_magical, stacks_with_self, description)
VALUES
    ('Alertness: Listen Bonus', 'stat', true, false, false, '+2 competence bonus to Listen checks'),
    ('Alertness: Spot Bonus', 'stat', true, false, false, '+2 competence bonus to Spot checks');

INSERT INTO pnpo_3_5_dev.stat_effects (effect_id, effect_target_id, change_type, value, bonus_type_id)
VALUES
    ((SELECT id FROM pnpo_3_5_dev.effects WHERE name = 'Alertness: Listen Bonus'),
     (SELECT id FROM pnpo_3_5_dev.effect_targets WHERE name = 'Listen_check'), 'additive', 2,
     (SELECT id FROM pnpo_3_5_dev.bonus_types WHERE name = 'competence')),
    ((SELECT id FROM pnpo_3_5_dev.effects WHERE name = 'Alertness: Spot Bonus'),
     (SELECT id FROM pnpo_3_5_dev.effect_targets WHERE name = 'Spot_check'), 'additive', 2,
     (SELECT id FROM pnpo_3_5_dev.bonus_types WHERE name = 'competence'));

INSERT INTO pnpo_3_5_dev.feat_effects (feat_id, effect_id, applies_when)
VALUES
    ((SELECT id FROM pnpo_3_5_dev.feats WHERE name = 'Alertness'), (SELECT id FROM pnpo_3_5_dev.effects WHERE name = 'Alertness: Listen Bonus'), NULL),
    ((SELECT id FROM pnpo_3_5_dev.feats WHERE name = 'Alertness'), (SELECT id FROM pnpo_3_5_dev.effects WHERE name = 'Alertness: Spot Bonus'), NULL);


-- FEAT 4: ANIMAL AFFINITY
INSERT INTO pnpo_3_5_dev.feats (name, feat_type, description, benefit, choice_required, choice_type, multiples_allowed)
VALUES ('Animal Affinity', 'general', 'You are good with animals.', 'You get a +2 bonus on all Handle Animal checks and Ride checks.', false, NULL, false);

INSERT INTO pnpo_3_5_dev.effects (name, effect_type, is_beneficial, is_magical, stacks_with_self, description)
VALUES
    ('Animal Affinity: Handle Animal Bonus', 'stat', true, false, false, '+2 competence bonus to Handle Animal checks'),
    ('Animal Affinity: Ride Bonus', 'stat', true, false, false, '+2 competence bonus to Ride checks');

INSERT INTO pnpo_3_5_dev.stat_effects (effect_id, effect_target_id, change_type, value, bonus_type_id)
VALUES
    ((SELECT id FROM pnpo_3_5_dev.effects WHERE name = 'Animal Affinity: Handle Animal Bonus'),
     (SELECT id FROM pnpo_3_5_dev.effect_targets WHERE name = 'Handle_Animal_check'), 'additive', 2,
     (SELECT id FROM pnpo_3_5_dev.bonus_types WHERE name = 'competence')),
    ((SELECT id FROM pnpo_3_5_dev.effects WHERE name = 'Animal Affinity: Ride Bonus'),
     (SELECT id FROM pnpo_3_5_dev.effect_targets WHERE name = 'Ride_check'), 'additive', 2,
     (SELECT id FROM pnpo_3_5_dev.bonus_types WHERE name = 'competence'));

INSERT INTO pnpo_3_5_dev.feat_effects (feat_id, effect_id, applies_when)
VALUES
    ((SELECT id FROM pnpo_3_5_dev.feats WHERE name = 'Animal Affinity'), (SELECT id FROM pnpo_3_5_dev.effects WHERE name = 'Animal Affinity: Handle Animal Bonus'), NULL),
    ((SELECT id FROM pnpo_3_5_dev.feats WHERE name = 'Animal Affinity'), (SELECT id FROM pnpo_3_5_dev.effects WHERE name = 'Animal Affinity: Ride Bonus'), NULL);


-- FEAT 5: ARMOR PROFICIENCY (LIGHT)
INSERT INTO pnpo_3_5_dev.feats (name, feat_type, description, benefit, special, choice_required, choice_type, multiples_allowed)
VALUES ('Armor Proficiency (Light)', 'general', 'You are proficient with light armor.',
        'When you wear a type of armor with which you are proficient, the armor check penalty for that armor applies only to Balance, Climb, Escape Artist, Hide, Jump, Move Silently, Sleight of Hand, and Tumble checks.',
        'All characters except wizards, sorcerers, and monks automatically have Armor Proficiency (light) as a bonus feat. They need not select it.',
        false, NULL, false);

INSERT INTO pnpo_3_5_dev.special_abilities (name, ability_type, is_active, description, source_category)
VALUES ('Light Armor Proficiency', 'extraordinary', false, 'Proficient with light armor - armor check penalty only applies to specific skills', 'feat');

INSERT INTO pnpo_3_5_dev.feat_granted_abilities (feat_id, special_ability_id, notes)
VALUES ((SELECT id FROM pnpo_3_5_dev.feats WHERE name = 'Armor Proficiency (Light)'),
        (SELECT id FROM pnpo_3_5_dev.special_abilities WHERE name = 'Light Armor Proficiency'),
        'Grants proficiency with all light armor types');


-- FEAT 6: ARMOR PROFICIENCY (MEDIUM)
INSERT INTO pnpo_3_5_dev.feats (name, feat_type, description, benefit, special, choice_required, choice_type, multiples_allowed)
VALUES ('Armor Proficiency (Medium)', 'general', 'You are proficient with medium armor.',
        'When you wear a type of armor with which you are proficient, the armor check penalty for that armor applies only to Balance, Climb, Escape Artist, Hide, Jump, Move Silently, Sleight of Hand, and Tumble checks.',
        'Fighters, barbarians, paladins, clerics, druids, and bards automatically have Armor Proficiency (medium) as a bonus feat. They need not select it.',
        false, NULL, false);

WITH new_group AS (
    INSERT INTO pnpo_3_5_dev.prerequisite_groups (logic_operator, description)
    VALUES ('AND', 'Armor Proficiency (Medium): Requires Light armor proficiency')
    RETURNING id
),
new_prereq AS (
    INSERT INTO pnpo_3_5_dev.feat_requirement_prerequisites (required_feat_id)
    VALUES ((SELECT id FROM pnpo_3_5_dev.feats WHERE name = 'Armor Proficiency (Light)'))
    RETURNING id
)
INSERT INTO pnpo_3_5_dev.prerequisite_conditions (parent_group_id, condition_type, feat_prerequisite_id)
SELECT new_group.id, 'feat_requirement', new_prereq.id
FROM new_group, new_prereq;

INSERT INTO pnpo_3_5_dev.feat_prerequisites (feat_id, prerequisite_group_id)
VALUES ((SELECT id FROM pnpo_3_5_dev.feats WHERE name = 'Armor Proficiency (Medium)'),
        (SELECT id FROM pnpo_3_5_dev.prerequisite_groups WHERE description = 'Armor Proficiency (Medium): Requires Light armor proficiency'));

INSERT INTO pnpo_3_5_dev.special_abilities (name, ability_type, is_active, description, source_category)
VALUES ('Medium Armor Proficiency', 'extraordinary', false, 'Proficient with medium armor - armor check penalty only applies to specific skills', 'feat');

INSERT INTO pnpo_3_5_dev.feat_granted_abilities (feat_id, special_ability_id, notes)
VALUES ((SELECT id FROM pnpo_3_5_dev.feats WHERE name = 'Armor Proficiency (Medium)'),
        (SELECT id FROM pnpo_3_5_dev.special_abilities WHERE name = 'Medium Armor Proficiency'),
        'Grants proficiency with all medium armor types');


-- FEAT 7: ARMOR PROFICIENCY (HEAVY)
INSERT INTO pnpo_3_5_dev.feats (name, feat_type, description, benefit, special, choice_required, choice_type, multiples_allowed)
VALUES ('Armor Proficiency (Heavy)', 'general', 'You are proficient with heavy armor.',
        'When you wear a type of armor with which you are proficient, the armor check penalty for that armor applies only to Balance, Climb, Escape Artist, Hide, Jump, Move Silently, Sleight of Hand, and Tumble checks.',
        'Fighters, paladins, and clerics automatically have Armor Proficiency (heavy) as a bonus feat. They need not select it.',
        false, NULL, false);

WITH new_group AS (
    INSERT INTO pnpo_3_5_dev.prerequisite_groups (logic_operator, description)
    VALUES ('AND', 'Armor Proficiency (Heavy): Requires both Light and Medium armor proficiency')
    RETURNING id
),
new_prereq_light AS (
    INSERT INTO pnpo_3_5_dev.feat_requirement_prerequisites (required_feat_id)
    VALUES ((SELECT id FROM pnpo_3_5_dev.feats WHERE name = 'Armor Proficiency (Light)'))
    RETURNING id
),
new_prereq_medium AS (
    INSERT INTO pnpo_3_5_dev.feat_requirement_prerequisites (required_feat_id)
    VALUES ((SELECT id FROM pnpo_3_5_dev.feats WHERE name = 'Armor Proficiency (Medium)'))
    RETURNING id
),
condition1 AS (
    INSERT INTO pnpo_3_5_dev.prerequisite_conditions (parent_group_id, condition_type, feat_prerequisite_id, sequence_order)
    SELECT new_group.id, 'feat_requirement', new_prereq_light.id, 0
    FROM new_group, new_prereq_light
    RETURNING parent_group_id
)
INSERT INTO pnpo_3_5_dev.prerequisite_conditions (parent_group_id, condition_type, feat_prerequisite_id, sequence_order)
SELECT new_group.id, 'feat_requirement', new_prereq_medium.id, 1
FROM new_group, new_prereq_medium;

INSERT INTO pnpo_3_5_dev.feat_prerequisites (feat_id, prerequisite_group_id)
VALUES ((SELECT id FROM pnpo_3_5_dev.feats WHERE name = 'Armor Proficiency (Heavy)'),
        (SELECT id FROM pnpo_3_5_dev.prerequisite_groups WHERE description = 'Armor Proficiency (Heavy): Requires both Light and Medium armor proficiency'));

INSERT INTO pnpo_3_5_dev.special_abilities (name, ability_type, is_active, description, source_category)
VALUES ('Heavy Armor Proficiency', 'extraordinary', false, 'Proficient with heavy armor - armor check penalty only applies to specific skills', 'feat');

INSERT INTO pnpo_3_5_dev.feat_granted_abilities (feat_id, special_ability_id, notes)
VALUES ((SELECT id FROM pnpo_3_5_dev.feats WHERE name = 'Armor Proficiency (Heavy)'),
        (SELECT id FROM pnpo_3_5_dev.special_abilities WHERE name = 'Heavy Armor Proficiency'),
        'Grants proficiency with all heavy armor types');


-- FEAT 8: ATHLETIC
INSERT INTO pnpo_3_5_dev.feats (name, feat_type, description, benefit, choice_required, choice_type, multiples_allowed)
VALUES ('Athletic', 'general', 'You have a knack for athletic endeavors.', 'You get a +2 bonus on all Climb checks and Swim checks.', false, NULL, false);

INSERT INTO pnpo_3_5_dev.effects (name, effect_type, is_beneficial, is_magical, stacks_with_self, description)
VALUES
    ('Athletic: Climb Bonus', 'stat', true, false, false, '+2 competence bonus to Climb checks'),
    ('Athletic: Swim Bonus', 'stat', true, false, false, '+2 competence bonus to Swim checks');

INSERT INTO pnpo_3_5_dev.stat_effects (effect_id, effect_target_id, change_type, value, bonus_type_id)
VALUES
    ((SELECT id FROM pnpo_3_5_dev.effects WHERE name = 'Athletic: Climb Bonus'),
     (SELECT id FROM pnpo_3_5_dev.effect_targets WHERE name = 'Climb_check'), 'additive', 2,
     (SELECT id FROM pnpo_3_5_dev.bonus_types WHERE name = 'competence')),
    ((SELECT id FROM pnpo_3_5_dev.effects WHERE name = 'Athletic: Swim Bonus'),
     (SELECT id FROM pnpo_3_5_dev.effect_targets WHERE name = 'Swim_check'), 'additive', 2,
     (SELECT id FROM pnpo_3_5_dev.bonus_types WHERE name = 'competence'));

INSERT INTO pnpo_3_5_dev.feat_effects (feat_id, effect_id, applies_when)
VALUES
    ((SELECT id FROM pnpo_3_5_dev.feats WHERE name = 'Athletic'), (SELECT id FROM pnpo_3_5_dev.effects WHERE name = 'Athletic: Climb Bonus'), NULL),
    ((SELECT id FROM pnpo_3_5_dev.feats WHERE name = 'Athletic'), (SELECT id FROM pnpo_3_5_dev.effects WHERE name = 'Athletic: Swim Bonus'), NULL);


-- ============================================================================
-- FEAT 9: SPELL FOCUS [General]
-- ============================================================================

INSERT INTO pnpo_3_5_dev.feats (name, feat_type, description, benefit, special, choice_required, choice_type, multiples_allowed)
VALUES ('Spell Focus', 'general', 'Choose a school of magic. Your spells of that school are more potent than normal.',
        'Add +1 to the Difficulty Class for all saving throws against spells from the school of magic you select.',
        'You can gain this feat multiple times. Its effects do not stack. Each time you take the feat, it applies to a new school of magic.',
        true, 'spell_school', true);


-- ============================================================================
-- FEAT 10: AUGMENT SUMMONING [General]
-- ============================================================================

INSERT INTO pnpo_3_5_dev.feats (name, feat_type, description, benefit, choice_required, choice_type, multiples_allowed)
VALUES ('Augment Summoning', 'general', 'Your summoned creatures are more powerful than normal.',
        'Each creature you conjure with any summon spell gains a +4 enhancement bonus to Strength and Constitution for the duration of the spell that summoned it.',
        false, NULL, false);

WITH new_group AS (
    INSERT INTO pnpo_3_5_dev.prerequisite_groups (logic_operator, description)
    VALUES ('AND', 'Augment Summoning: Requires Spell Focus (Conjuration)')
    RETURNING id
),
new_prereq AS (
    INSERT INTO pnpo_3_5_dev.feat_requirement_prerequisites (required_feat_id)
    VALUES ((SELECT id FROM pnpo_3_5_dev.feats WHERE name = 'Spell Focus'))
    RETURNING id
)
INSERT INTO pnpo_3_5_dev.prerequisite_conditions (parent_group_id, condition_type, feat_prerequisite_id)
SELECT new_group.id, 'feat_requirement', new_prereq.id
FROM new_group, new_prereq;

INSERT INTO pnpo_3_5_dev.feat_prerequisites (feat_id, prerequisite_group_id)
VALUES ((SELECT id FROM pnpo_3_5_dev.feats WHERE name = 'Augment Summoning'),
        (SELECT id FROM pnpo_3_5_dev.prerequisite_groups WHERE description = 'Augment Summoning: Requires Spell Focus (Conjuration)'));

INSERT INTO pnpo_3_5_dev.effects (name, effect_type, is_beneficial, is_magical, stacks_with_self, description)
VALUES
    ('Augment Summoning: STR Bonus', 'stat', true, true, false, '+4 enhancement bonus to Strength for summoned creatures'),
    ('Augment Summoning: CON Bonus', 'stat', true, true, false, '+4 enhancement bonus to Constitution for summoned creatures');

INSERT INTO pnpo_3_5_dev.stat_effects (effect_id, effect_target_id, change_type, value, bonus_type_id)
VALUES
    ((SELECT id FROM pnpo_3_5_dev.effects WHERE name = 'Augment Summoning: STR Bonus'),
     (SELECT id FROM pnpo_3_5_dev.effect_targets WHERE name = 'STR'), 'additive', 4,
     (SELECT id FROM pnpo_3_5_dev.bonus_types WHERE name = 'enhancement')),
    ((SELECT id FROM pnpo_3_5_dev.effects WHERE name = 'Augment Summoning: CON Bonus'),
     (SELECT id FROM pnpo_3_5_dev.effect_targets WHERE name = 'CON'), 'additive', 4,
     (SELECT id FROM pnpo_3_5_dev.bonus_types WHERE name = 'enhancement'));

INSERT INTO pnpo_3_5_dev.feat_effects (feat_id, effect_id, applies_when)
VALUES
    ((SELECT id FROM pnpo_3_5_dev.feats WHERE name = 'Augment Summoning'),
     (SELECT id FROM pnpo_3_5_dev.effects WHERE name = 'Augment Summoning: STR Bonus'), 'on summoned creatures'),
    ((SELECT id FROM pnpo_3_5_dev.feats WHERE name = 'Augment Summoning'),
     (SELECT id FROM pnpo_3_5_dev.effects WHERE name = 'Augment Summoning: CON Bonus'), 'on summoned creatures');


-- ============================================================================
-- FEAT 11: BLIND-FIGHT [General]
-- ============================================================================

INSERT INTO pnpo_3_5_dev.feats (name, feat_type, description, benefit, special, choice_required, choice_type, multiples_allowed)
VALUES ('Blind-Fight', 'general', 'You are skilled at fighting in conditions with poor visibility.',
        'In melee, every time you miss because of concealment, you can reroll your miss chance percentile roll one time to see if you actually hit. An invisible attacker gets no advantages related to hitting you in melee. That is, you don''t lose your Dexterity bonus to Armor Class, and the attacker doesn''t get the usual +2 bonus for being invisible. The invisible attacker''s bonuses do still apply for ranged attacks, however. You take only half the usual penalty to speed for being unable to see. Darkness and poor visibility in general reduces your speed to three-quarters normal, instead of one-half.',
        'The Blind-Fight feat is of no use against a character who is the subject of a blink spell. A fighter may select Blind-Fight as one of his fighter bonus feats.',
        false, NULL, false);

INSERT INTO pnpo_3_5_dev.special_abilities (name, ability_type, is_active, description, source_category)
VALUES ('Blind-Fight', 'extraordinary', false,
        'Reroll concealment miss chance once; no penalties vs invisible attackers in melee; reduced speed penalty in darkness',
        'feat');

INSERT INTO pnpo_3_5_dev.feat_granted_abilities (feat_id, special_ability_id, notes)
VALUES ((SELECT id FROM pnpo_3_5_dev.feats WHERE name = 'Blind-Fight'),
        (SELECT id FROM pnpo_3_5_dev.special_abilities WHERE name = 'Blind-Fight'),
        'Complex mechanics - see feat description for full details');


-- ============================================================================
-- FEAT 12: BREW POTION [Item Creation] - CORRECTED
-- ============================================================================

INSERT INTO pnpo_3_5_dev.feats (name, feat_type, description, benefit, choice_required, choice_type, multiples_allowed)
VALUES ('Brew Potion', 'item_creation', 'You can create magic potions.',
        'You can create a potion of any 3rd-level or lower spell that you know and that targets one or more creatures. Brewing a potion takes one day. When you create a potion, you set the caster level, which must be sufficient to cast the spell in question and no higher than your own level. The base price of a potion is its spell level x its caster level x 50 gp. To brew a potion, you must spend 1/25 of this base price in XP and use up raw materials costing one half this base price.',
        false, NULL, false);

-- CORRECTED: Complete prerequisite implementation
WITH new_caster_prereq AS (
    INSERT INTO pnpo_3_5_dev.caster_level_prerequisites (minimum_caster_level, class_id)
    VALUES (3, NULL)  -- NULL = any caster class
    RETURNING id
),
new_group AS (
    INSERT INTO pnpo_3_5_dev.prerequisite_groups (logic_operator, description)
    VALUES ('AND', 'Brew Potion: Requires caster level 3rd')
    RETURNING id
)
INSERT INTO pnpo_3_5_dev.prerequisite_conditions (parent_group_id, condition_type, caster_level_prerequisite_id, sequence_order)
SELECT new_group.id, 'caster_level', new_caster_prereq.id, 0
FROM new_group, new_caster_prereq;

INSERT INTO pnpo_3_5_dev.feat_prerequisites (feat_id, prerequisite_group_id)
VALUES ((SELECT id FROM pnpo_3_5_dev.feats WHERE name = 'Brew Potion'),
        (SELECT id FROM pnpo_3_5_dev.prerequisite_groups WHERE description = 'Brew Potion: Requires caster level 3rd'));

INSERT INTO pnpo_3_5_dev.special_abilities (name, ability_type, is_active, description, source_category)
VALUES ('Brew Potion', 'extraordinary', false, 'Can create magic potions of spells known (3rd level or lower)', 'feat');

INSERT INTO pnpo_3_5_dev.feat_granted_abilities (feat_id, special_ability_id, notes)
VALUES ((SELECT id FROM pnpo_3_5_dev.feats WHERE name = 'Brew Potion'),
        (SELECT id FROM pnpo_3_5_dev.special_abilities WHERE name = 'Brew Potion'),
        'Item creation feat - see PHB for full crafting rules');


-- ============================================================================
-- FEAT 13: POWER ATTACK [General] - NEW (Prerequisite for Cleave)
-- ============================================================================

INSERT INTO pnpo_3_5_dev.feats (name, feat_type, description, benefit, special, choice_required, choice_type, multiples_allowed)
VALUES ('Power Attack', 'general',
        'You can make exceptionally deadly melee attacks by sacrificing accuracy for power.',
        'On your action, before making attack rolls for a round, you may choose to subtract a number from all melee attack rolls and add the same number to all melee damage rolls. This number may not exceed your base attack bonus. The penalty on attacks and bonus on damage apply until your next turn.',
        'A fighter may select Power Attack as one of his fighter bonus feats.',
        false, NULL, false);

-- Prerequisites: STR 13
WITH new_ability_prereq AS (
    INSERT INTO pnpo_3_5_dev.ability_score_prerequisites (ability_score, minimum_value)
    VALUES ('STR', 13)
    RETURNING id
),
new_group AS (
    INSERT INTO pnpo_3_5_dev.prerequisite_groups (logic_operator, description)
    VALUES ('AND', 'Power Attack: Requires Str 13')
    RETURNING id
)
INSERT INTO pnpo_3_5_dev.prerequisite_conditions (parent_group_id, condition_type, ability_score_prerequisite_id, sequence_order)
SELECT new_group.id, 'ability_score', new_ability_prereq.id, 0
FROM new_group, new_ability_prereq;

INSERT INTO pnpo_3_5_dev.feat_prerequisites (feat_id, prerequisite_group_id)
VALUES ((SELECT id FROM pnpo_3_5_dev.feats WHERE name = 'Power Attack'),
        (SELECT id FROM pnpo_3_5_dev.prerequisite_groups WHERE description = 'Power Attack: Requires Str 13'));

INSERT INTO pnpo_3_5_dev.special_abilities (name, ability_type, is_active, description, source_category)
VALUES ('Power Attack', 'extraordinary', true,
        'Trade attack penalty for equal damage bonus (max = BAB). Activated tactical option.',
        'feat');

INSERT INTO pnpo_3_5_dev.feat_granted_abilities (feat_id, special_ability_id, notes)
VALUES ((SELECT id FROM pnpo_3_5_dev.feats WHERE name = 'Power Attack'),
        (SELECT id FROM pnpo_3_5_dev.special_abilities WHERE name = 'Power Attack'),
        'Fighter bonus feat option - variable magnitude tactical option');


-- ============================================================================
-- FEAT 14: CLEAVE [General] - CORRECTED
-- ============================================================================

INSERT INTO pnpo_3_5_dev.feats (name, feat_type, description, benefit, special, choice_required, choice_type, multiples_allowed)
VALUES ('Cleave', 'general', 'You can follow through with powerful blows.',
        'If you deal a creature enough damage to make it drop (typically by dropping it to below 0 hit points or killing it), you get an immediate, extra melee attack against another creature within reach. You cannot take a 5-foot step before making this extra attack. The extra attack is with the same weapon and at the same bonus as the attack that dropped the previous creature. You can use this ability once per round.',
        'A fighter may select Cleave as one of his fighter bonus feats.',
        false, NULL, false);

-- CORRECTED: Complete prerequisites (STR 13 AND Power Attack)
WITH new_ability_prereq AS (
    INSERT INTO pnpo_3_5_dev.ability_score_prerequisites (ability_score, minimum_value)
    VALUES ('STR', 13)
    RETURNING id
),
new_feat_prereq AS (
    INSERT INTO pnpo_3_5_dev.feat_requirement_prerequisites (required_feat_id)
    VALUES ((SELECT id FROM pnpo_3_5_dev.feats WHERE name = 'Power Attack'))
    RETURNING id
),
new_group AS (
    INSERT INTO pnpo_3_5_dev.prerequisite_groups (logic_operator, description)
    VALUES ('AND', 'Cleave: Requires Str 13 and Power Attack feat')
    RETURNING id
),
condition1 AS (
    INSERT INTO pnpo_3_5_dev.prerequisite_conditions (parent_group_id, condition_type, ability_score_prerequisite_id, sequence_order)
    SELECT new_group.id, 'ability_score', new_ability_prereq.id, 0
    FROM new_group, new_ability_prereq
    RETURNING parent_group_id
)
INSERT INTO pnpo_3_5_dev.prerequisite_conditions (parent_group_id, condition_type, feat_prerequisite_id, sequence_order)
SELECT new_group.id, 'feat_requirement', new_feat_prereq.id, 1
FROM new_group, new_feat_prereq;

INSERT INTO pnpo_3_5_dev.feat_prerequisites (feat_id, prerequisite_group_id)
VALUES ((SELECT id FROM pnpo_3_5_dev.feats WHERE name = 'Cleave'),
        (SELECT id FROM pnpo_3_5_dev.prerequisite_groups WHERE description = 'Cleave: Requires Str 13 and Power Attack feat'));

INSERT INTO pnpo_3_5_dev.special_abilities (name, ability_type, is_active, description, source_category)
VALUES ('Cleave', 'extraordinary', false, 'Extra melee attack after dropping a foe (once per round)', 'feat');

INSERT INTO pnpo_3_5_dev.feat_granted_abilities (feat_id, special_ability_id, notes)
VALUES ((SELECT id FROM pnpo_3_5_dev.feats WHERE name = 'Cleave'),
        (SELECT id FROM pnpo_3_5_dev.special_abilities WHERE name = 'Cleave'),
        'Fighter bonus feat option');


-- ============================================================================
-- FEAT 15: COMBAT CASTING [General]
-- ============================================================================

INSERT INTO pnpo_3_5_dev.feats (name, feat_type, description, benefit, choice_required, choice_type, multiples_allowed)
VALUES ('Combat Casting', 'general', 'You are adept at casting spells in combat.',
        'You get a +4 bonus on Concentration checks made to cast a spell or use a spell-like ability while on the defensive or while you are grappling or pinned.',
        false, NULL, false);

INSERT INTO pnpo_3_5_dev.effects (name, effect_type, is_beneficial, is_magical, stacks_with_self, description)
VALUES ('Combat Casting: Concentration Bonus', 'stat', true, false, false,
        '+4 bonus to Concentration checks when casting defensively or grappled');

INSERT INTO pnpo_3_5_dev.stat_effects (effect_id, effect_target_id, change_type, value, bonus_type_id)
VALUES ((SELECT id FROM pnpo_3_5_dev.effects WHERE name = 'Combat Casting: Concentration Bonus'),
        (SELECT id FROM pnpo_3_5_dev.effect_targets WHERE name = 'Concentration_check'), 'additive', 4,
        (SELECT id FROM pnpo_3_5_dev.bonus_types WHERE name = 'competence'));

INSERT INTO pnpo_3_5_dev.feat_effects (feat_id, effect_id, applies_when)
VALUES ((SELECT id FROM pnpo_3_5_dev.feats WHERE name = 'Combat Casting'),
        (SELECT id FROM pnpo_3_5_dev.effects WHERE name = 'Combat Casting: Concentration Bonus'),
        'while casting defensively, grappling, or pinned');


-- ============================================================================
-- FEAT 16: COMBAT EXPERTISE [General] - CORRECTED
-- ============================================================================

INSERT INTO pnpo_3_5_dev.feats (name, feat_type, description, benefit, normal, special, choice_required, choice_type, multiples_allowed)
VALUES ('Combat Expertise', 'general',
        'You are trained at using your combat skill for defense as well as offense.',
        'When you use the attack action or the full attack action in melee, you can take a penalty of as much as –5 on your attack roll and add the same number (+5 or less) as a dodge bonus to your Armor Class. This number may not exceed your base attack bonus. The changes to attack rolls and Armor Class last until your next action.',
        'A character without the Combat Expertise feat can fight defensively while using the attack or full attack action to take a –4 penalty on attack rolls and gain a +2 dodge bonus to Armor Class.',
        'A fighter may select Combat Expertise as one of his fighter bonus feats.',
        false, NULL, false);

-- CORRECTED: Complete prerequisite (INT 13)
WITH new_ability_prereq AS (
    INSERT INTO pnpo_3_5_dev.ability_score_prerequisites (ability_score, minimum_value)
    VALUES ('INT', 13)
    RETURNING id
),
new_group AS (
    INSERT INTO pnpo_3_5_dev.prerequisite_groups (logic_operator, description)
    VALUES ('AND', 'Combat Expertise: Requires Int 13')
    RETURNING id
)
INSERT INTO pnpo_3_5_dev.prerequisite_conditions (parent_group_id, condition_type, ability_score_prerequisite_id, sequence_order)
SELECT new_group.id, 'ability_score', new_ability_prereq.id, 0
FROM new_group, new_ability_prereq;

INSERT INTO pnpo_3_5_dev.feat_prerequisites (feat_id, prerequisite_group_id)
VALUES ((SELECT id FROM pnpo_3_5_dev.feats WHERE name = 'Combat Expertise'),
        (SELECT id FROM pnpo_3_5_dev.prerequisite_groups WHERE description = 'Combat Expertise: Requires Int 13'));

INSERT INTO pnpo_3_5_dev.special_abilities (name, ability_type, is_active, description, source_category)
VALUES ('Combat Expertise', 'extraordinary', true,
        'Trade up to -5 attack penalty for equal dodge bonus to AC (max = BAB)',
        'feat');

INSERT INTO pnpo_3_5_dev.feat_granted_abilities (feat_id, special_ability_id, notes)
VALUES ((SELECT id FROM pnpo_3_5_dev.feats WHERE name = 'Combat Expertise'),
        (SELECT id FROM pnpo_3_5_dev.special_abilities WHERE name = 'Combat Expertise'),
        'Fighter bonus feat option - activated tactical option');


-- ============================================================================
-- FEAT 17: COMBAT REFLEXES [General]
-- ============================================================================

INSERT INTO pnpo_3_5_dev.feats (name, feat_type, description, benefit, normal, special, choice_required, choice_type, multiples_allowed)
VALUES ('Combat Reflexes', 'general',
        'You can respond quickly and repeatedly to opponents who let their defenses down.',
        'You may make a number of additional attacks of opportunity equal to your Dexterity bonus. With this feat, you may also make attacks of opportunity while flat-footed.',
        'A character without this feat can make only one attack of opportunity per round and can''t make attacks of opportunity while flat-footed.',
        'The Combat Reflexes feat does not allow a rogue to use her opportunist ability more than once per round. A fighter may select Combat Reflexes as one of his fighter bonus feats. A monk may select Combat Reflexes as a bonus feat at 2nd level.',
        false, NULL, false);

INSERT INTO pnpo_3_5_dev.special_abilities (name, ability_type, is_active, description, source_category)
VALUES ('Combat Reflexes', 'extraordinary', false,
        'Extra attacks of opportunity = DEX modifier; can make AoO while flat-footed',
        'feat');

INSERT INTO pnpo_3_5_dev.feat_granted_abilities (feat_id, special_ability_id, notes)
VALUES ((SELECT id FROM pnpo_3_5_dev.feats WHERE name = 'Combat Reflexes'),
        (SELECT id FROM pnpo_3_5_dev.special_abilities WHERE name = 'Combat Reflexes'),
        'Fighter/monk bonus feat option');


COMMIT;

-- ============================================================================
-- END OF CORRECTED FEAT IMPORT
-- ============================================================================
