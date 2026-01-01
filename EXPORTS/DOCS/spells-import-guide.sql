-- =====================================================
-- SPELL IMPORT IMPLEMENTATION GUIDE
-- =====================================================
-- This file demonstrates how to import spells from D&D 3.5 SRD
-- into the pnpo_3_5_dev schema, covering all major patterns:
--
-- 1. Different spell levels (0-9, cantrips to epic)
-- 2. Different schools (Evocation, Conjuration, Divination, etc.)
-- 3. Different target types (Personal, Touch, Area, Targets)
-- 4. Different durations (Instantaneous, Concentration, rounds/level)
-- 5. Different components (V, S, M, F, DF, XP)
-- 6. Saving throws and spell resistance
-- 7. Variable effects (damage, healing, HD-based)
-- 8. Scaling mechanics (missiles, area, duration)
--
-- PATTERN OVERVIEW:
-- Each spell import follows this structure:
-- 1. Insert into spells table (name, school, range, duration, etc.)
-- 2. Set is_arcane and/or is_divine flags
-- 3. Insert into spell_class_levels (link spell to classes and levels)
-- 4. Insert into spell_components (V, S, M, F, DF, XP)
-- 5. Insert into spell_saves if spell allows saving throw
-- 6. Insert into spell_descriptors_link for subtypes ([Fire], [Force], etc.)
-- 7. Create spell_effects if spell has mechanical effects (optional)
--
-- DECISION FRAMEWORK:
-- Q1: What spell level for each class?
--     Extract from "Level:" line (e.g., "Sor/Wiz 1, Clr 1")
--     Create spell_class_levels entry for each class
--
-- Q2: Is it arcane, divine, or both?
--     Set is_arcane = true for Sor/Wiz/Brd
--     Set is_divine = true for Clr/Drd/Pal/Rgr
--     Both = true if appears on both lists
--
-- Q3: What components are required?
--     V = Verbal, S = Somatic, M = Material, F = Focus
--     DF = Divine Focus, XP = XP cost
--     Insert into spell_components table for each component
--     Document M/F descriptions in component_description
--
-- Q4: What is the targeting mechanism?
--     range_type: 'personal', 'touch', 'close', 'medium', 'long'
--     area_of_effect: Text description of area OR targets
--     Note: No separate 'target' column - use area_of_effect
--
-- Q5: What is the duration?
--     duration: VARCHAR(100) - include (D) if dismissible
--     Examples: 'Instantaneous', '1 min./level (D)', 'Concentration, up to 1 min./level'
--
-- Q6: Does it allow saves or SR?
--     allows_spell_resistance: boolean (true/false)
--     Saves: Use spell_saves table with throw_id (FK to throws)
--
-- Q7: Does it deal damage or have other effects?
--     Optionally create spell_effects entries (pre-computed per CL)
--     Link to effects table
--
-- Q8: What school and descriptors?
--     spell_school_id: FK to spell_schools (required)
--     spell_subschool_id: FK to spell_subschools (optional)
--     Descriptors: Insert into spell_descriptors_link
-- =====================================================

BEGIN;

-- =====================================================
-- DEPENDENCIES (RUN FIRST!)
-- =====================================================
-- These must exist before any spell imports.

-- Spell Schools
INSERT INTO spell_schools (name, description)
VALUES
    ('Abjuration', 'Protective spells that create barriers, negate harmful effects, or banish creatures'),
    ('Conjuration', 'Spells that bring creatures or materials to the caster'),
    ('Divination', 'Spells that reveal information'),
    ('Enchantment', 'Spells that imbue the recipient with some property or grant control over another being'),
    ('Evocation', 'Spells that manipulate energy or create something from nothing'),
    ('Illusion', 'Spells that deceive the senses or minds of others'),
    ('Necromancy', 'Spells that manipulate life force and death'),
    ('Transmutation', 'Spells that transform the recipient physically or change its properties')
ON CONFLICT (name) DO NOTHING;

-- Spell Subschools
INSERT INTO spell_subschools (spell_school_id, name, description)
VALUES
    ((SELECT id FROM spell_schools WHERE name = 'Conjuration'), 'Creation', 'Conjuration spells that create objects or effects'),
    ((SELECT id FROM spell_schools WHERE name = 'Conjuration'), 'Healing', 'Conjuration spells that heal damage'),
    ((SELECT id FROM spell_schools WHERE name = 'Conjuration'), 'Summoning', 'Conjuration spells that summon creatures'),
    ((SELECT id FROM spell_schools WHERE name = 'Enchantment'), 'Compulsion', 'Enchantment spells that force targets to act in specific ways')
ON CONFLICT (spell_school_id, name) DO NOTHING;

-- Spell Descriptors (spell subtypes)
INSERT INTO spell_descriptors (name, description)
VALUES
    ('Fire', 'Spell has the fire descriptor and deals fire damage'),
    ('Force', 'Spell creates force effects that affect incorporeal creatures'),
    ('Mind-Affecting', 'Spell affects the target''s mind'),
    ('Good', 'Spell is aligned with good'),
    ('Evil', 'Spell is aligned with evil'),
    ('Lawful', 'Spell is aligned with law'),
    ('Chaotic', 'Spell is aligned with chaos')
ON CONFLICT (name) DO NOTHING;

-- Spell Component Types (V, S, M, F, DF, XP)
INSERT INTO spell_component_types (code, name, description)
VALUES
    ('V', 'Verbal', 'Verbal component - spoken words or sounds'),
    ('S', 'Somatic', 'Somatic component - gestures and movements'),
    ('M', 'Material', 'Material component - consumed item'),
    ('F', 'Focus', 'Focus component - reusable item'),
    ('DF', 'Divine Focus', 'Divine focus - holy symbol'),
    ('XP', 'Experience', 'Experience point cost')
ON CONFLICT (code) DO NOTHING;

-- =====================================================
-- SPELL 1: DETECT MAGIC (Cantrip with Concentration)
-- =====================================================
-- PATTERN: Cantrip (0-level), concentration duration, area effect
-- DECISIONS:
-- - Spell level 0 (cantrip) for multiple classes
-- - Duration = Concentration, up to 1 min./level (D)
-- - area_of_effect = Cone-shaped emanation (no separate 'target' column)
-- - No saves, no SR → allows_spell_resistance = false
-- - Divination school
-- - is_arcane = true, is_divine = true (both Brd/Wiz and Clr/Drd)

INSERT INTO spells (
    name,
    spell_school_id,
    spell_subschool_id,
    is_arcane,
    is_divine,
    casting_time,
    range_type,
    range_value,
    range_formula_id,
    area_of_effect,
    duration,
    allows_spell_resistance,
    description
)
VALUES (
    'Detect Magic',
    (SELECT id FROM spell_schools WHERE name = 'Divination'),
    NULL,  -- No subschool
    true,  -- is_arcane (Bard, Sorcerer, Wizard)
    true,  -- is_divine (Cleric, Druid)
    '1 standard action',
    'close',  -- DECISION: Use plain value, not 'range_close'
    60,  -- Fixed 60 ft. range
    NULL,  -- No formula needed for fixed range
    'Cone-shaped emanation',  -- DECISION: No separate 'target' column, use area_of_effect
    'Concentration, up to 1 min./level (D)',  -- DECISION: Include (D) in duration text
    false,  -- allows_spell_resistance = false (SR: No)
    'You detect magical auras. The amount of information revealed depends on how long you study a particular area or subject. 1st Round: Presence or absence of magical auras. 2nd Round: Number of different magical auras and the power of the most potent aura. 3rd Round: The strength and location of each aura. If the items or creatures bearing the auras are in line of sight, you can make Spellcraft skill checks to determine the school of magic involved in each. (Make one check per aura; DC 15 + spell level, or 15 + half caster level for a nonspell effect.)'
);

-- Link to classes: Bard 0, Cleric 0, Druid 0, Sorcerer 0, Wizard 0
INSERT INTO spell_class_levels (spell_id, class_id, spell_level)
VALUES
    ((SELECT id FROM spells WHERE name = 'Detect Magic'), (SELECT id FROM classes WHERE name = 'Bard'), 0),
    ((SELECT id FROM spells WHERE name = 'Detect Magic'), (SELECT id FROM classes WHERE name = 'Cleric'), 0),
    ((SELECT id FROM spells WHERE name = 'Detect Magic'), (SELECT id FROM classes WHERE name = 'Druid'), 0),
    ((SELECT id FROM spells WHERE name = 'Detect Magic'), (SELECT id FROM classes WHERE name = 'Sorcerer'), 0),
    ((SELECT id FROM spells WHERE name = 'Detect Magic'), (SELECT id FROM classes WHERE name = 'Wizard'), 0);

-- Components: V, S (no material or focus)
-- DECISION: Use spell_components table, not boolean flags
INSERT INTO spell_components (spell_id, component_type_id, component_description)
VALUES
    ((SELECT id FROM spells WHERE name = 'Detect Magic'), (SELECT id FROM spell_component_types WHERE code = 'V'), NULL),
    ((SELECT id FROM spells WHERE name = 'Detect Magic'), (SELECT id FROM spell_component_types WHERE code = 'S'), NULL);

-- DECISION: No spell_saves entry needed (Saving Throw: None)
-- DECISION: No spell_descriptors_link needed (no descriptors)

-- =====================================================
-- SPELL 2: MAGIC MISSILE (Scaling Damage)
-- =====================================================
-- PATTERN: Auto-hit damage, scales with caster level (more missiles)
-- DECISIONS:
-- - Spell level 1 for Sor/Wiz
-- - Evocation school, [Force] descriptor
-- - Instantaneous duration
-- - No save (auto-hit), allows SR = true
-- - is_arcane only (not divine)
-- - area_of_effect used for "Up to five creatures" description

INSERT INTO spells (
    name,
    spell_school_id,
    spell_subschool_id,
    is_arcane,
    is_divine,
    casting_time,
    range_type,
    range_value,
    range_formula_id,
    area_of_effect,
    duration,
    allows_spell_resistance,
    description
)
VALUES (
    'Magic Missile',
    (SELECT id FROM spell_schools WHERE name = 'Evocation'),
    NULL,
    true,   -- is_arcane
    false,  -- is_divine (not on divine lists)
    '1 standard action',
    'medium',  -- Medium (100 ft. + 10 ft./level)
    NULL,  -- No fixed value for medium range
    NULL,  -- In production: link to range formula
    'Up to five creatures, no two of which can be more than 15 ft. apart',
    'Instantaneous',
    true,  -- allows_spell_resistance (SR: Yes)
    'A missile of magical energy darts forth from your fingertip and strikes its target, dealing 1d4+1 points of force damage. The missile strikes unerringly, even if the target is in melee combat or has less than total cover or total concealment. For every two caster levels beyond 1st, you gain an additional missile—two at 3rd level, three at 5th, four at 7th, and the maximum of five missiles at 9th level or higher. If you shoot multiple missiles, you can have them strike a single creature or several creatures. A single missile can strike only one creature.'
);

INSERT INTO spell_class_levels (spell_id, class_id, spell_level)
VALUES
    ((SELECT id FROM spells WHERE name = 'Magic Missile'), (SELECT id FROM classes WHERE name = 'Sorcerer'), 1),
    ((SELECT id FROM spells WHERE name = 'Magic Missile'), (SELECT id FROM classes WHERE name = 'Wizard'), 1);

-- Components: V, S
INSERT INTO spell_components (spell_id, component_type_id, component_description)
VALUES
    ((SELECT id FROM spells WHERE name = 'Magic Missile'), (SELECT id FROM spell_component_types WHERE code = 'V'), NULL),
    ((SELECT id FROM spells WHERE name = 'Magic Missile'), (SELECT id FROM spell_component_types WHERE code = 'S'), NULL);

-- Add [Force] descriptor
-- DECISION: Use spell_descriptors_link table, not spell_spell_descriptors
INSERT INTO spell_descriptors_link (spell_id, spell_descriptor_id)
VALUES (
    (SELECT id FROM spells WHERE name = 'Magic Missile'),
    (SELECT id FROM spell_descriptors WHERE name = 'Force')
);

-- DECISION: No spell_saves entry (Saving Throw: None)

-- OPTIONAL: Pre-compute spell_effects for each caster level
-- This is optional - your schema supports pre-computed effects per CL
-- In production, you might generate these programmatically
-- Example for CL 1:
-- INSERT INTO spell_effects (spell_id, caster_level, effect_id, applies_when)
-- VALUES (
--     (SELECT id FROM spells WHERE name = 'Magic Missile'),
--     1,
--     (SELECT id FROM effects WHERE name = 'Magic Missile: 1 missile'),
--     NULL
-- );

-- =====================================================
-- SPELL 3: MAGE ARMOR (AC Buff with Duration)
-- =====================================================
-- PATTERN: Long-duration buff, requires focus component
-- DECISIONS:
-- - Spell level 1 Sor/Wiz
-- - Conjuration (Creation) [Force]
-- - Duration: 1 hour/level (D) - includes (D) in text
-- - Range: Touch
-- - area_of_effect = 'Creature touched'
-- - Has Focus component (piece of cured leather)

INSERT INTO spells (
    name,
    spell_school_id,
    spell_subschool_id,
    is_arcane,
    is_divine,
    casting_time,
    range_type,
    range_value,
    range_formula_id,
    area_of_effect,
    duration,
    allows_spell_resistance,
    description
)
VALUES (
    'Mage Armor',
    (SELECT id FROM spell_schools WHERE name = 'Conjuration'),
    (SELECT id FROM spell_subschools WHERE name = 'Creation'),
    true,   -- is_arcane
    false,  -- is_divine
    '1 standard action',
    'touch',
    NULL,
    NULL,
    'Creature touched',  -- DECISION: Use area_of_effect for target
    '1 hour/level (D)',  -- DECISION: (D) included in duration text
    false,  -- allows_spell_resistance (SR: No)
    'An invisible but tangible field of force surrounds the subject of a mage armor spell, providing a +4 armor bonus to AC. Unlike mundane armor, mage armor entails no armor check penalty, arcane spell failure chance, or speed reduction. Since mage armor is made of force, incorporeal creatures can''t bypass it the way they do normal armor.'
);

INSERT INTO spell_class_levels (spell_id, class_id, spell_level)
VALUES
    ((SELECT id FROM spells WHERE name = 'Mage Armor'), (SELECT id FROM classes WHERE name = 'Sorcerer'), 1),
    ((SELECT id FROM spells WHERE name = 'Mage Armor'), (SELECT id FROM classes WHERE name = 'Wizard'), 1);

-- Components: V, S, F
-- DECISION: Document focus description in component_description
INSERT INTO spell_components (spell_id, component_type_id, component_description)
VALUES
    ((SELECT id FROM spells WHERE name = 'Mage Armor'), (SELECT id FROM spell_component_types WHERE code = 'V'), NULL),
    ((SELECT id FROM spells WHERE name = 'Mage Armor'), (SELECT id FROM spell_component_types WHERE code = 'S'), NULL),
    ((SELECT id FROM spells WHERE name = 'Mage Armor'), (SELECT id FROM spell_component_types WHERE code = 'F'), 'A piece of cured leather');

-- Add [Force] descriptor
INSERT INTO spell_descriptors_link (spell_id, spell_descriptor_id)
VALUES (
    (SELECT id FROM spells WHERE name = 'Mage Armor'),
    (SELECT id FROM spell_descriptors WHERE name = 'Force')
);

-- Saving throw: Will negates (harmless)
-- DECISION: Use spell_saves table
INSERT INTO spell_saves (spell_id, throw_id, save_dc_formula_id, save_result_type)
VALUES (
    (SELECT id FROM spells WHERE name = 'Mage Armor'),
    (SELECT id FROM throws WHERE name = 'Will'),
    NULL,  -- In production: link to formula for 10 + spell_level + ability_mod
    'negates'  -- Will negates (harmless)
);

-- =====================================================
-- SPELL 4: SHIELD (Personal Defensive Spell)
-- =====================================================
-- PATTERN: Personal range (self only), multiple effects
-- DECISIONS:
-- - range_type = 'personal'
-- - area_of_effect = 'You' (personal spells target self)
-- - Duration: 1 min./level (D)
-- - No saves/SR for personal spells (allows_spell_resistance can be false or true)

INSERT INTO spells (
    name,
    spell_school_id,
    spell_subschool_id,
    is_arcane,
    is_divine,
    casting_time,
    range_type,
    range_value,
    range_formula_id,
    area_of_effect,
    duration,
    allows_spell_resistance,
    description
)
VALUES (
    'Shield',
    (SELECT id FROM spell_schools WHERE name = 'Abjuration'),
    NULL,
    true,   -- is_arcane
    false,  -- is_divine
    '1 standard action',
    'personal',  -- DECISION: Personal range
    NULL,
    NULL,
    'You',  -- DECISION: Personal spells target 'You'
    '1 min./level (D)',
    false,  -- No SR for personal spells
    'Shield creates an invisible, tower shield-sized mobile disk of force that hovers in front of you. It negates magic missile attacks directed at you. The disk also provides a +4 shield bonus to AC. This bonus applies against incorporeal touch attacks, since it is a force effect. The shield has no armor check penalty or arcane spell failure chance. Unlike with a normal tower shield, you can''t use the shield spell for cover.'
);

INSERT INTO spell_class_levels (spell_id, class_id, spell_level)
VALUES
    ((SELECT id FROM spells WHERE name = 'Shield'), (SELECT id FROM classes WHERE name = 'Sorcerer'), 1),
    ((SELECT id FROM spells WHERE name = 'Shield'), (SELECT id FROM classes WHERE name = 'Wizard'), 1);

-- Components: V, S
INSERT INTO spell_components (spell_id, component_type_id, component_description)
VALUES
    ((SELECT id FROM spells WHERE name = 'Shield'), (SELECT id FROM spell_component_types WHERE code = 'V'), NULL),
    ((SELECT id FROM spells WHERE name = 'Shield'), (SELECT id FROM spell_component_types WHERE code = 'S'), NULL);

-- [Force] descriptor
INSERT INTO spell_descriptors_link (spell_id, spell_descriptor_id)
VALUES (
    (SELECT id FROM spells WHERE name = 'Shield'),
    (SELECT id FROM spell_descriptors WHERE name = 'Force')
);

-- No saves for personal spell

-- =====================================================
-- SPELL 5: BLESS (Area Buff, Multiple Targets)
-- =====================================================
-- PATTERN: Area effect buff, affects allies
-- DECISIONS:
-- - is_divine only (Cleric, Paladin)
-- - area_of_effect describes the area burst
-- - Enchantment (Compulsion) [Mind-Affecting]
-- - Has Divine Focus component
-- - allows_spell_resistance = true (harmless)

INSERT INTO spells (
    name,
    spell_school_id,
    spell_subschool_id,
    is_arcane,
    is_divine,
    casting_time,
    range_type,
    range_value,
    range_formula_id,
    area_of_effect,
    duration,
    allows_spell_resistance,
    description
)
VALUES (
    'Bless',
    (SELECT id FROM spell_schools WHERE name = 'Enchantment'),
    (SELECT id FROM spell_subschools WHERE name = 'Compulsion'),
    false,  -- is_arcane (not on arcane lists)
    true,   -- is_divine
    '1 standard action',
    'close',
    50,  -- 50 ft. burst
    NULL,
    'The caster and all allies within a 50-ft. burst, centered on the caster',
    '1 min./level',
    true,  -- allows_spell_resistance (SR: Yes (harmless))
    'Bless fills your allies with courage. Each ally gains a +1 morale bonus on attack rolls and on saving throws against fear effects. Bless counters and dispels bane.'
);

INSERT INTO spell_class_levels (spell_id, class_id, spell_level)
VALUES
    ((SELECT id FROM spells WHERE name = 'Bless'), (SELECT id FROM classes WHERE name = 'Cleric'), 1),
    ((SELECT id FROM spells WHERE name = 'Bless'), (SELECT id FROM classes WHERE name = 'Paladin'), 1);

-- Components: V, S, DF
INSERT INTO spell_components (spell_id, component_type_id, component_description)
VALUES
    ((SELECT id FROM spells WHERE name = 'Bless'), (SELECT id FROM spell_component_types WHERE code = 'V'), NULL),
    ((SELECT id FROM spells WHERE name = 'Bless'), (SELECT id FROM spell_component_types WHERE code = 'S'), NULL),
    ((SELECT id FROM spells WHERE name = 'Bless'), (SELECT id FROM spell_component_types WHERE code = 'DF'), NULL);

-- [Mind-Affecting] descriptor
INSERT INTO spell_descriptors_link (spell_id, spell_descriptor_id)
VALUES (
    (SELECT id FROM spells WHERE name = 'Bless'),
    (SELECT id FROM spell_descriptors WHERE name = 'Mind-Affecting')
);

-- Saving Throw: None (no save)

-- =====================================================
-- SPELL 6: CURE LIGHT WOUNDS (Healing with Variable Effect)
-- =====================================================
-- PATTERN: Healing spell, variable roll, reverse effect on undead
-- DECISIONS:
-- - Multiple classes at different levels
-- - Conjuration (Healing) subschool
-- - is_divine only
-- - Undead: Will half damage, can apply SR

INSERT INTO spells (
    name,
    spell_school_id,
    spell_subschool_id,
    is_arcane,
    is_divine,
    casting_time,
    range_type,
    range_value,
    range_formula_id,
    area_of_effect,
    duration,
    allows_spell_resistance,
    description
)
VALUES (
    'Cure Light Wounds',
    (SELECT id FROM spell_schools WHERE name = 'Conjuration'),
    (SELECT id FROM spell_subschools WHERE name = 'Healing'),
    false,  -- is_arcane (not on arcane lists)
    true,   -- is_divine
    '1 standard action',
    'touch',
    NULL,
    NULL,
    'Creature touched',
    'Instantaneous',
    true,  -- allows_spell_resistance (SR: Yes (harmless); see text for undead)
    'When laying your hand upon a living creature, you channel positive energy that cures 1d8 points of damage +1 point per caster level (maximum +5). Since undead are powered by negative energy, this spell deals damage to them instead of curing their wounds. An undead creature can apply spell resistance, and can attempt a Will save to take half damage.'
);

-- Link to multiple classes at different levels
INSERT INTO spell_class_levels (spell_id, class_id, spell_level)
VALUES
    ((SELECT id FROM spells WHERE name = 'Cure Light Wounds'), (SELECT id FROM classes WHERE name = 'Bard'), 1),
    ((SELECT id FROM spells WHERE name = 'Cure Light Wounds'), (SELECT id FROM classes WHERE name = 'Cleric'), 1),
    ((SELECT id FROM spells WHERE name = 'Cure Light Wounds'), (SELECT id FROM classes WHERE name = 'Druid'), 1),
    ((SELECT id FROM spells WHERE name = 'Cure Light Wounds'), (SELECT id FROM classes WHERE name = 'Paladin'), 1),
    ((SELECT id FROM spells WHERE name = 'Cure Light Wounds'), (SELECT id FROM classes WHERE name = 'Ranger'), 2);  -- Different level!

-- Components: V, S
INSERT INTO spell_components (spell_id, component_type_id, component_description)
VALUES
    ((SELECT id FROM spells WHERE name = 'Cure Light Wounds'), (SELECT id FROM spell_component_types WHERE code = 'V'), NULL),
    ((SELECT id FROM spells WHERE name = 'Cure Light Wounds'), (SELECT id FROM spell_component_types WHERE code = 'S'), NULL);

-- Saving throw: Will half (harmless); see text
-- DECISION: Normal case is harmless, but undead get Will half
INSERT INTO spell_saves (spell_id, throw_id, save_dc_formula_id, save_result_type)
VALUES (
    (SELECT id FROM spells WHERE name = 'Cure Light Wounds'),
    (SELECT id FROM throws WHERE name = 'Will'),
    NULL,  -- Formula ID
    'half'  -- Will half for undead
);

-- =====================================================
-- SPELL 7: SLEEP (HD-Based Effect, Material Component)
-- =====================================================
-- PATTERN: HD-based targeting, material component, enchantment
-- DECISIONS:
-- - Enchantment (Compulsion) [Mind-Affecting]
-- - Affects 4 HD of creatures (documented in description)
-- - Material component with description
-- - Casting time: 1 round (longer than standard)

INSERT INTO spells (
    name,
    spell_school_id,
    spell_subschool_id,
    is_arcane,
    is_divine,
    casting_time,
    range_type,
    range_value,
    range_formula_id,
    area_of_effect,
    duration,
    allows_spell_resistance,
    description
)
VALUES (
    'Sleep',
    (SELECT id FROM spell_schools WHERE name = 'Enchantment'),
    (SELECT id FROM spell_subschools WHERE name = 'Compulsion'),
    true,   -- is_arcane
    false,  -- is_divine
    '1 round',  -- DECISION: Longer casting time
    'medium',
    NULL,
    NULL,
    'One or more living creatures within a 10-ft.-radius burst',
    '1 min./level',
    true,  -- allows_spell_resistance
    'A sleep spell causes a magical slumber to come upon 4 Hit Dice of creatures. Creatures with the fewest HD are affected first. Among creatures with equal HD, those who are closest to the spell''s point of origin are affected first. Hit Dice that are not sufficient to affect a creature are wasted. Sleeping creatures are helpless. Slapping or wounding awakens an affected creature, but normal noise does not. Awakening a creature is a standard action (an application of the aid another action). Sleep does not target unconscious creatures, constructs, or undead creatures.'
);

INSERT INTO spell_class_levels (spell_id, class_id, spell_level)
VALUES
    ((SELECT id FROM spells WHERE name = 'Sleep'), (SELECT id FROM classes WHERE name = 'Bard'), 1),
    ((SELECT id FROM spells WHERE name = 'Sleep'), (SELECT id FROM classes WHERE name = 'Sorcerer'), 1),
    ((SELECT id FROM spells WHERE name = 'Sleep'), (SELECT id FROM classes WHERE name = 'Wizard'), 1);

-- Components: V, S, M
-- DECISION: Material component with description
INSERT INTO spell_components (spell_id, component_type_id, component_description)
VALUES
    ((SELECT id FROM spells WHERE name = 'Sleep'), (SELECT id FROM spell_component_types WHERE code = 'V'), NULL),
    ((SELECT id FROM spells WHERE name = 'Sleep'), (SELECT id FROM spell_component_types WHERE code = 'S'), NULL),
    ((SELECT id FROM spells WHERE name = 'Sleep'), (SELECT id FROM spell_component_types WHERE code = 'M'), 'A pinch of fine sand, rose petals, or a live cricket');

-- [Mind-Affecting] descriptor
INSERT INTO spell_descriptors_link (spell_id, spell_descriptor_id)
VALUES (
    (SELECT id FROM spells WHERE name = 'Sleep'),
    (SELECT id FROM spell_descriptors WHERE name = 'Mind-Affecting')
);

-- Saving throw: Will negates
INSERT INTO spell_saves (spell_id, throw_id, save_dc_formula_id, save_result_type)
VALUES (
    (SELECT id FROM spells WHERE name = 'Sleep'),
    (SELECT id FROM throws WHERE name = 'Will'),
    NULL,
    'negates'
);

-- =====================================================
-- SPELL 8: FIREBALL (Classic Area Damage, Save for Half)
-- =====================================================
-- PATTERN: Area damage, save for half, material component
-- DECISIONS:
-- - Evocation [Fire]
-- - 3rd level spell
-- - Damage: 1d6/level (max 10d6) - documented in description
-- - Reflex save for half
-- - Material component with cost
-- - area_of_effect = '20-ft.-radius spread'

INSERT INTO spells (
    name,
    spell_school_id,
    spell_subschool_id,
    is_arcane,
    is_divine,
    casting_time,
    range_type,
    range_value,
    range_formula_id,
    area_of_effect,
    duration,
    allows_spell_resistance,
    description
)
VALUES (
    'Fireball',
    (SELECT id FROM spell_schools WHERE name = 'Evocation'),
    NULL,
    true,   -- is_arcane
    false,  -- is_divine
    '1 standard action',
    'long',  -- Long (400 ft. + 40 ft./level)
    NULL,
    NULL,
    '20-ft.-radius spread',
    'Instantaneous',
    true,  -- allows_spell_resistance
    'A fireball spell is an explosion of flame that detonates with a low roar and deals 1d6 points of fire damage per caster level (maximum 10d6) to every creature within the area. Unattended objects also take this damage. The explosion creates almost no pressure. You point your finger and determine the range (distance and height) at which the fireball is to burst. A glowing, pea-sized bead streaks from the pointing digit and, unless it impacts upon a material body or solid barrier prior to attaining the prescribed range, blossoms into the fireball at that point. The fireball sets fire to combustibles and damages objects in the area. It can melt metals with low melting points, such as lead, gold, copper, silver, and bronze.'
);

INSERT INTO spell_class_levels (spell_id, class_id, spell_level)
VALUES
    ((SELECT id FROM spells WHERE name = 'Fireball'), (SELECT id FROM classes WHERE name = 'Sorcerer'), 3),
    ((SELECT id FROM spells WHERE name = 'Fireball'), (SELECT id FROM classes WHERE name = 'Wizard'), 3);

-- Components: V, S, M
INSERT INTO spell_components (spell_id, component_type_id, component_description)
VALUES
    ((SELECT id FROM spells WHERE name = 'Fireball'), (SELECT id FROM spell_component_types WHERE code = 'V'), NULL),
    ((SELECT id FROM spells WHERE name = 'Fireball'), (SELECT id FROM spell_component_types WHERE code = 'S'), NULL),
    ((SELECT id FROM spells WHERE name = 'Fireball'), (SELECT id FROM spell_component_types WHERE code = 'M'), 'A tiny ball of bat guano and sulfur');

-- [Fire] descriptor
INSERT INTO spell_descriptors_link (spell_id, spell_descriptor_id)
VALUES (
    (SELECT id FROM spells WHERE name = 'Fireball'),
    (SELECT id FROM spell_descriptors WHERE name = 'Fire')
);

-- Saving throw: Reflex half
INSERT INTO spell_saves (spell_id, throw_id, save_dc_formula_id, save_result_type)
VALUES (
    (SELECT id FROM spells WHERE name = 'Fireball'),
    (SELECT id FROM throws WHERE name = 'Reflex'),
    NULL,
    'half'
);

-- =====================================================
-- SPELL 9: HASTE (Multi-Target Buff, Multiple Effects)
-- =====================================================
-- PATTERN: Complex buff with multiple simultaneous effects
-- DECISIONS:
-- - Transmutation, 3rd level
-- - area_of_effect = 'One creature/level, no two of which can be more than 30 ft. apart'
-- - Material component
-- - Multiple benefits documented in description

INSERT INTO spells (
    name,
    spell_school_id,
    spell_subschool_id,
    is_arcane,
    is_divine,
    casting_time,
    range_type,
    range_value,
    range_formula_id,
    area_of_effect,
    duration,
    allows_spell_resistance,
    description
)
VALUES (
    'Haste',
    (SELECT id FROM spell_schools WHERE name = 'Transmutation'),
    NULL,
    true,   -- is_arcane
    false,  -- is_divine
    '1 standard action',
    'close',
    NULL,
    NULL,
    'One creature/level, no two of which can be more than 30 ft. apart',
    '1 round/level',
    true,  -- allows_spell_resistance (SR: Yes (harmless))
    'The transmuted creatures move and act more quickly than normal. When making a full attack action, a hasted creature may make one extra attack with any weapon he is holding. The attack is made using the creature''s full base attack bonus, plus any modifiers appropriate to the situation. A hasted creature gains a +1 bonus on attack rolls and a +1 dodge bonus to AC and Reflex saves. All of the hasted creature''s modes of movement increase by 30 feet, to a maximum of twice the subject''s normal speed using that form of movement. This increase counts as an enhancement bonus. Multiple haste effects don''t stack. Haste dispels and counters slow.'
);

INSERT INTO spell_class_levels (spell_id, class_id, spell_level)
VALUES
    ((SELECT id FROM spells WHERE name = 'Haste'), (SELECT id FROM classes WHERE name = 'Bard'), 3),
    ((SELECT id FROM spells WHERE name = 'Haste'), (SELECT id FROM classes WHERE name = 'Sorcerer'), 3),
    ((SELECT id FROM spells WHERE name = 'Haste'), (SELECT id FROM classes WHERE name = 'Wizard'), 3);

-- Components: V, S, M
INSERT INTO spell_components (spell_id, component_type_id, component_description)
VALUES
    ((SELECT id FROM spells WHERE name = 'Haste'), (SELECT id FROM spell_component_types WHERE code = 'V'), NULL),
    ((SELECT id FROM spells WHERE name = 'Haste'), (SELECT id FROM spell_component_types WHERE code = 'S'), NULL),
    ((SELECT id FROM spells WHERE name = 'Haste'), (SELECT id FROM spell_component_types WHERE code = 'M'), 'A shaving of licorice root');

-- Saving throw: Fortitude negates (harmless)
INSERT INTO spell_saves (spell_id, throw_id, save_dc_formula_id, save_result_type)
VALUES (
    (SELECT id FROM spells WHERE name = 'Haste'),
    (SELECT id FROM throws WHERE name = 'Fortitude'),
    NULL,
    'negates'
);

-- =====================================================
-- SPELL 10: DISPEL MAGIC (Caster Level Checks, Variable Targeting)
-- =====================================================
-- PATTERN: Counter/removal spell, uses caster level checks, multiple modes
-- DECISIONS:
-- - Abjuration, 3rd level (multiple classes, different levels for Druid)
-- - area_of_effect can describe both target and area modes
-- - No save, No SR (targets spells, not creatures)
-- - Both is_arcane and is_divine

INSERT INTO spells (
    name,
    spell_school_id,
    spell_subschool_id,
    is_arcane,
    is_divine,
    casting_time,
    range_type,
    range_value,
    range_formula_id,
    area_of_effect,
    duration,
    allows_spell_resistance,
    description
)
VALUES (
    'Dispel Magic',
    (SELECT id FROM spell_schools WHERE name = 'Abjuration'),
    NULL,
    true,   -- is_arcane (Bard, Sorcerer, Wizard)
    true,   -- is_divine (Cleric, Druid, Paladin)
    '1 standard action',
    'medium',
    NULL,
    NULL,
    'One spellcaster, creature, or object; or 20-ft.-radius burst',  -- Variable targeting
    'Instantaneous',
    false,  -- allows_spell_resistance (SR: No)
    'You can use dispel magic to end ongoing spells that have been cast on a creature or object, to temporarily suppress the magical abilities of a magic item, to end ongoing spells (or at least their effects) within an area, or to counter another spellcaster''s spell. A dispelled spell ends as if its duration had expired. You choose to use dispel magic in one of three ways: Targeted Dispel (one object, creature, or spell), Area Dispel (all spells in 20-ft. radius), or Counterspell. The DC for the dispel check is 11 + the spell''s caster level. You make a dispel check (1d20 + your caster level, maximum +10) against each ongoing spell. Note: The effect of a spell with an instantaneous duration can''t be dispelled.'
);

-- Link to multiple classes at different levels
INSERT INTO spell_class_levels (spell_id, class_id, spell_level)
VALUES
    ((SELECT id FROM spells WHERE name = 'Dispel Magic'), (SELECT id FROM classes WHERE name = 'Bard'), 3),
    ((SELECT id FROM spells WHERE name = 'Dispel Magic'), (SELECT id FROM classes WHERE name = 'Cleric'), 3),
    ((SELECT id FROM spells WHERE name = 'Dispel Magic'), (SELECT id FROM classes WHERE name = 'Druid'), 4),  -- Different level!
    ((SELECT id FROM spells WHERE name = 'Dispel Magic'), (SELECT id FROM classes WHERE name = 'Paladin'), 3),
    ((SELECT id FROM spells WHERE name = 'Dispel Magic'), (SELECT id FROM classes WHERE name = 'Sorcerer'), 3),
    ((SELECT id FROM spells WHERE name = 'Dispel Magic'), (SELECT id FROM classes WHERE name = 'Wizard'), 3);

-- Components: V, S
INSERT INTO spell_components (spell_id, component_type_id, component_description)
VALUES
    ((SELECT id FROM spells WHERE name = 'Dispel Magic'), (SELECT id FROM spell_component_types WHERE code = 'V'), NULL),
    ((SELECT id FROM spells WHERE name = 'Dispel Magic'), (SELECT id FROM spell_component_types WHERE code = 'S'), NULL);

-- No saving throw (Saving Throw: None)
-- No descriptors

-- =====================================================
-- SUMMARY: DECISION TREE FOR SPELL IMPORTS
-- =====================================================
-- Use this flowchart when importing new spells:
--
-- 1. READ THE SPELL DESCRIPTION CAREFULLY
--    ├─ Identify school and subschool
--    ├─ Identify all class/level combinations
--    ├─ Identify components (V, S, M, F, DF, XP)
--    └─ Identify descriptors [Fire], [Mind-Affecting], etc.
--
-- 2. DETERMINE ARCANE/DIVINE FLAGS
--    ├─ is_arcane = true if on Bard, Sorcerer, or Wizard lists
--    ├─ is_divine = true if on Cleric, Druid, Paladin, or Ranger lists
--    └─ Both can be true for spells like Dispel Magic
--
-- 3. DETERMINE TARGETING
--    ├─ range_type: 'personal', 'touch', 'close', 'medium', 'long'
--    ├─ range_value: Integer for fixed ranges (60 ft., 50 ft., etc.)
--    ├─ area_of_effect: Text description of targets, area, or effect
--    └─ No separate 'target' column - use area_of_effect
--
-- 4. DETERMINE DURATION
--    ├─ duration: VARCHAR(100)
--    ├─ Include (D) in text if dismissible
--    └─ Examples: 'Instantaneous', '1 min./level (D)', 'Concentration'
--
-- 5. DETERMINE SAVES AND SR
--    ├─ allows_spell_resistance: boolean (true/false, not text)
--    └─ Saves: Use spell_saves table with throw_id and save_result_type
--
-- 6. INSERT INTO SPELLS TABLE
--    ├─ All required columns: name, spell_school_id, casting_time, range_type, duration, description
--    ├─ Set is_arcane and/or is_divine flags
--    └─ Set allows_spell_resistance boolean
--
-- 7. LINK TO CLASSES
--    ├─ INSERT INTO spell_class_levels for each class
--    ├─ Some spells available to same class at different levels (domain spells)
--    └─ Some classes get spell at higher level than others (Dispel Magic: Drd 4, others 3)
--
-- 8. ADD COMPONENTS
--    ├─ INSERT INTO spell_components for each component (V, S, M, F, DF, XP)
--    ├─ Document M/F in component_description
--    └─ Set component_cost_cp for expensive materials
--
-- 9. ADD SAVES (IF ANY)
--    ├─ INSERT INTO spell_saves if spell allows saving throw
--    ├─ save_result_type: 'negates', 'half', 'partial', 'custom'
--    └─ Link to appropriate throw (Fortitude, Reflex, Will)
--
-- 10. ADD DESCRIPTORS
--     ├─ INSERT INTO spell_descriptors_link for each [Descriptor]
--     └─ Common: [Fire], [Force], [Mind-Affecting], [Good], [Evil], [Lawful], [Chaotic]
--
-- =====================================================
-- COMMON PATTERNS REFERENCE
-- =====================================================
--
-- PATTERN: Cantrip (0-level spell)
-- Example: Detect Magic
-- → spell_level = 0 in spell_class_levels
-- → Often utility or minor effects
--
-- PATTERN: Damage spell with save for half
-- Example: Fireball
-- → spell_saves with save_result_type = 'half'
-- → Damage documented in description
-- → Scales with caster level
--
-- PATTERN: Healing spell
-- Example: Cure Light Wounds
-- → Conjuration (Healing) subschool
-- → Usually damages undead (document in description)
-- → spell_saves for undead (Will half)
--
-- PATTERN: Buff spell with duration
-- Example: Mage Armor, Shield, Haste
-- → Duration: rounds/level, minutes/level, hours/level
-- → Include (D) in duration if dismissible
-- → Benefits documented in description
--
-- PATTERN: Area effect spell
-- Example: Bless, Fireball
-- → area_of_effect defined (radius burst, cone, etc.)
-- → Affects all creatures in area
-- → May allow save (spell_saves)
--
-- PATTERN: Personal spell (self only)
-- Example: Shield
-- → range_type = 'personal'
-- → area_of_effect = 'You'
-- → No save or SR (or allows_spell_resistance can be false)
--
-- PATTERN: Touch spell
-- Example: Cure Light Wounds, Mage Armor
-- → range_type = 'touch'
-- → area_of_effect = 'Creature touched'
-- → Usually harmless (spell_saves with negates (harmless))
--
-- PATTERN: Spell with material/focus component
-- Example: Fireball (M), Mage Armor (F)
-- → spell_components entry with component_type_id
-- → component_description for M or F
-- → component_cost_cp for expensive materials (in copper pieces)
--
-- PATTERN: Spell with divine focus
-- Example: Bless
-- → spell_components entry for DF
-- → Divine casters use holy symbol (no cost)
--
-- PATTERN: Concentration duration
-- Example: Detect Magic
-- → duration = 'Concentration, up to 1 min./level (D)'
-- → Requires standard action to maintain
-- → Ends if concentration broken
--
-- PATTERN: Instantaneous duration
-- Example: Fireball, Cure Light Wounds, Dispel Magic
-- → duration = 'Instantaneous'
-- → Effect happens immediately and can't be dispelled
-- → Damage/healing permanent
--
-- PATTERN: HD-based targeting
-- Example: Sleep
-- → Affects X Hit Dice of creatures
-- → Document in description
-- → Usually affects weakest first
--
-- PATTERN: Variable caster level effects
-- Example: Magic Missile (missiles), Fireball (damage)
-- → Document scaling in description (e.g., "1d6 per caster level (maximum 10d6)")
-- → Optionally pre-compute spell_effects entries for each CL
--
-- PATTERN: Dispel/Counter spell
-- Example: Dispel Magic
-- → Uses caster level checks (document in description)
-- → DC = 11 + target spell's caster level
-- → No save or SR
--
-- PATTERN: Multi-class spell at different levels
-- Example: Cure Light Wounds (Clr 1, Rgr 2), Dispel Magic (Drd 4, others 3)
-- → Create multiple spell_class_levels entries
-- → Same spell, different access points
--
-- PATTERN: Both arcane and divine
-- Example: Dispel Magic
-- → is_arcane = true AND is_divine = true
-- → Available to both arcane and divine casters
--
-- =====================================================
-- SCHEMA REFERENCE
-- =====================================================
-- SPELLS TABLE COLUMNS:
-- - id: SERIAL PRIMARY KEY
-- - name: VARCHAR(100) NOT NULL UNIQUE
-- - spell_school_id: INTEGER NOT NULL (FK to spell_schools)
-- - spell_subschool_id: INTEGER (FK to spell_subschools, optional)
-- - is_arcane: BOOLEAN NOT NULL DEFAULT false
-- - is_divine: BOOLEAN NOT NULL DEFAULT false
-- - casting_time: VARCHAR(50) NOT NULL
-- - range_type: VARCHAR(30) NOT NULL ('personal', 'touch', 'close', 'medium', 'long')
-- - range_value: INTEGER (for fixed ranges like 60 ft.)
-- - range_formula_id: INTEGER (FK to formulas, for variable ranges)
-- - area_of_effect: TEXT (describes targets, area, or effect)
-- - duration: VARCHAR(100) NOT NULL (include (D) if dismissible)
-- - allows_spell_resistance: BOOLEAN NOT NULL DEFAULT true
-- - description: TEXT NOT NULL
-- - created_at: TIMESTAMP NOT NULL DEFAULT NOW()
--
-- RELATED TABLES:
-- - spell_class_levels: Links spells to classes and spell levels
-- - spell_components: Links spells to component types (V, S, M, F, DF, XP)
-- - spell_saves: Saving throw information (throw_id, save_result_type)
-- - spell_descriptors_link: Links spells to descriptors ([Fire], [Force], etc.)
-- - spell_effects: Pre-computed effects at specific caster levels (optional)
-- - spell_schools: Spell schools (Evocation, Conjuration, etc.)
-- - spell_subschools: Spell subschools (Creation, Healing, Summoning, etc.)
-- - spell_descriptors: Spell descriptors (Fire, Mind-Affecting, etc.)
-- - spell_component_types: Component types (V, S, M, F, DF, XP)
--
-- =====================================================
-- END OF SPELL IMPORT GUIDE
-- =====================================================

COMMIT;
