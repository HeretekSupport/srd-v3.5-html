-- =====================================================
-- D&D 3.5 SRD SPELLS - SAMPLE INSERT STATEMENTS
-- =====================================================
-- Schema: pnpo_3_5_dev.spells
-- Source: SRD HTML exports (spells-*.html)

SET search_path TO pnpo_3_5_dev;

-- =====================================================
-- PREREQUISITE REFERENCE DATA
-- =====================================================
-- These tables must be populated before importing spells.

-- Spell Schools (8 core schools from SRD)
INSERT INTO spell_schools (name, description)
VALUES
  ('Abjuration', 'Protective spells, dispelling, counterspelling'),
  ('Conjuration', 'Summoning, teleportation, creation'),
  ('Divination', 'Information gathering, detection, scrying'),
  ('Enchantment', 'Mind-affecting spells, charm, compulsion'),
  ('Evocation', 'Energy manipulation, damage spells'),
  ('Illusion', 'Deception, figments, glamers, shadows'),
  ('Necromancy', 'Death, undead, life force manipulation'),
  ('Transmutation', 'Transformation, enhancement, alteration')
ON CONFLICT (name) DO NOTHING;

-- Spell Subschools (common subschools from SRD)
INSERT INTO spell_subschools (spell_school_id, name, description)
VALUES
  ((SELECT id FROM spell_schools WHERE name = 'Conjuration'), 'Calling', 'Transports creatures from another plane'),
  ((SELECT id FROM spell_schools WHERE name = 'Conjuration'), 'Creation', 'Creates objects or effects'),
  ((SELECT id FROM spell_schools WHERE name = 'Conjuration'), 'Healing', 'Restores hit points or cures conditions'),
  ((SELECT id FROM spell_schools WHERE name = 'Conjuration'), 'Summoning', 'Brings creatures to caster'),
  ((SELECT id FROM spell_schools WHERE name = 'Conjuration'), 'Teleportation', 'Instantaneous travel'),
  ((SELECT id FROM spell_schools WHERE name = 'Divination'), 'Scrying', 'Views distant locations or creatures'),
  ((SELECT id FROM spell_schools WHERE name = 'Enchantment'), 'Charm', 'Makes target regard caster as friend'),
  ((SELECT id FROM spell_schools WHERE name = 'Enchantment'), 'Compulsion', 'Forces target to act in certain way'),
  ((SELECT id FROM spell_schools WHERE name = 'Illusion'), 'Figment', 'Creates false sensation'),
  ((SELECT id FROM spell_schools WHERE name = 'Illusion'), 'Glamer', 'Changes subject appearance'),
  ((SELECT id FROM spell_schools WHERE name = 'Illusion'), 'Pattern', 'Creates image affecting the mind'),
  ((SELECT id FROM spell_schools WHERE name = 'Illusion'), 'Phantasm', 'Mental image only target can see'),
  ((SELECT id FROM spell_schools WHERE name = 'Illusion'), 'Shadow', 'Semi-real illusion with partial effect')
ON CONFLICT (name) DO NOTHING;

-- Spell Descriptors (common descriptors from SRD)
INSERT INTO spell_descriptors (name, description)
VALUES
  ('Acid', 'Spell deals acid damage or creates acid'),
  ('Air', 'Spell manipulates air or air creatures'),
  ('Chaotic', 'Spell has chaotic alignment descriptor'),
  ('Cold', 'Spell deals cold damage or creates cold'),
  ('Darkness', 'Spell creates or manipulates darkness'),
  ('Death', 'Spell kills or drains life force'),
  ('Earth', 'Spell manipulates earth or earth creatures'),
  ('Electricity', 'Spell deals electricity damage'),
  ('Evil', 'Spell has evil alignment descriptor'),
  ('Fear', 'Spell creates fear effects'),
  ('Fire', 'Spell deals fire damage or creates fire'),
  ('Force', 'Spell creates pure magical force'),
  ('Good', 'Spell has good alignment descriptor'),
  ('Language-Dependent', 'Target must understand a language'),
  ('Lawful', 'Spell has lawful alignment descriptor'),
  ('Light', 'Spell creates or manipulates light'),
  ('Mind-Affecting', 'Spell affects target mind'),
  ('Sonic', 'Spell deals sonic damage or creates sound'),
  ('Water', 'Spell manipulates water or water creatures')
ON CONFLICT (name) DO NOTHING;

-- Spell Component Types
INSERT INTO spell_component_types (code, name, description)
VALUES
  ('V', 'Verbal', 'A spoken incantation'),
  ('S', 'Somatic', 'Gestures or hand movements'),
  ('M', 'Material', 'Physical components consumed by spell'),
  ('F', 'Focus', 'Physical item not consumed by spell'),
  ('DF', 'Divine Focus', 'Holy symbol for divine casters'),
  ('XP', 'Experience Cost', 'XP cost paid by caster')
ON CONFLICT (code) DO NOTHING;

-- Range Formulas (common spell ranges)
INSERT INTO formulas (name, formula_type, formula_expression, description)
VALUES
  ('Close Range', 'range', '25 + FLOOR(CASTER_LEVEL / 2) * 5', 'Close range: 25 ft + 5 ft per 2 levels'),
  ('Medium Range', 'range', '100 + CASTER_LEVEL * 10', 'Medium range: 100 ft + 10 ft per level'),
  ('Long Range', 'range', '400 + CASTER_LEVEL * 40', 'Long range: 400 ft + 40 ft per level')
ON CONFLICT (name) DO NOTHING;

-- Save DC Formulas (standard spell save DCs)
INSERT INTO formulas (name, formula_type, formula_expression, description)
VALUES
  ('10 + spell level + INT modifier', 'save_dc', '10 + SPELL_LEVEL + INT_MODIFIER', 'Standard arcane spell save DC'),
  ('10 + spell level + WIS modifier', 'save_dc', '10 + SPELL_LEVEL + WIS_MODIFIER', 'Standard divine spell save DC'),
  ('10 + spell level + CHA modifier', 'save_dc', '10 + SPELL_LEVEL + CHA_MODIFIER', 'Bard/Sorcerer spell save DC')
ON CONFLICT (name) DO NOTHING;

-- =====================================================
-- EXAMPLE SPELL INSERTS
-- =====================================================

-- Example 1: MAGIC MISSILE (Simple damage spell, scales missiles, no save)
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
) VALUES (
  'Magic Missile',
  (SELECT id FROM spell_schools WHERE name = 'Evocation'),
  NULL,
  true,
  false,
  'standard',
  'medium',
  NULL,
  (SELECT id FROM formulas WHERE name = 'Medium Range'),  -- 100 ft + 10 ft/level
  'Up to five creatures, no two of which can be more than 15 ft. apart',
  'Instantaneous',
  true,
  'A missile of magical energy darts forth from your fingertip and strikes its target, dealing 1d4+1 points of force damage. The missile strikes unerringly, even if the target is in melee combat or has less than total cover or total concealment. Specific parts of a creature can''t be singled out. Inanimate objects are not damaged by the spell. For every two caster levels beyond 1st, you gain an additional missile—two at 3rd level, three at 5th, four at 7th, and the maximum of five missiles at 9th level or higher. If you shoot multiple missiles, you can have them strike a single creature or several creatures. A single missile can strike only one creature. You must designate targets before you check for spell resistance or roll damage.'
);

-- Example 2: FIREBALL (Area damage spell, Reflex save for half)
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
) VALUES (
  'Fireball',
  (SELECT id FROM spell_schools WHERE name = 'Evocation'),
  NULL,
  true,
  false,
  'standard',
  'long',
  NULL,
  (SELECT id FROM formulas WHERE name = 'Long Range'),  -- 400 ft + 40 ft/level
  '20-ft.-radius spread',
  'Instantaneous',
  true,
  'A fireball spell is an explosion of flame that detonates with a low roar and deals 1d6 points of fire damage per caster level (maximum 10d6) to every creature within the area. Unattended objects also take this damage. The explosion creates almost no pressure. You point your finger and determine the range (distance and height) at which the fireball is to burst. A glowing, pea-sized bead streaks from the pointing digit and, unless it impacts upon a material body or solid barrier prior to attaining the prescribed range, blossoms into the fireball at that point. The fireball sets fire to combustibles and damages objects in the area. It can melt metals with low melting points, such as lead, gold, copper, silver, and bronze.'
);

-- Example 3: CURE LIGHT WOUNDS (Conditional spell: heals living, damages undead)
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
) VALUES (
  'Cure Light Wounds',
  (SELECT id FROM spell_schools WHERE name = 'Conjuration'),
  (SELECT id FROM spell_subschools WHERE name = 'Healing'),
  false,
  true,
  'standard',
  'touch',
  NULL,
  NULL,
  'Creature touched',
  'Instantaneous',
  true,
  'When laying your hand upon a living creature, you channel positive energy that cures 1d8 points of damage +1 point per caster level (maximum +5). Since undead are powered by negative energy, this spell deals damage to them instead of curing their wounds. An undead creature can apply spell resistance, and can attempt a Will save to take half damage.'
);

-- Example 4: SHIELD (Defensive buff, no save, personal range)
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
) VALUES (
  'Shield',
  (SELECT id FROM spell_schools WHERE name = 'Abjuration'),
  NULL,
  true,
  false,
  'standard',
  'personal',
  NULL,
  NULL,
  'You',
  '1 min./level (D)',
  false,
  'Shield creates an invisible, tower shield-sized mobile disk of force that hovers in front of you. It negates magic missile attacks directed at you. The disk also provides a +4 shield bonus to AC. This bonus applies against incorporeal touch attacks, since it is a force effect. The shield has no armor check penalty or arcane spell failure chance. Unlike with a normal tower shield, you can''t use the shield spell for cover.'
);

-- Example 5: HASTE (Multi-effect buff spell)
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
) VALUES (
  'Haste',
  (SELECT id FROM spell_schools WHERE name = 'Transmutation'),
  NULL,
  true,
  false,
  'standard',
  'close',
  NULL,
  (SELECT id FROM formulas WHERE name = 'Close Range'),  -- 25 ft + 5 ft/2 levels
  'One creature/level, no two of which can be more than 30 ft. apart',
  '1 round/level',
  true,
  'The transmuted creatures move and act more quickly than normal. When making a full attack action, a hasted creature may make one extra attack with any weapon he is holding. The attack is made using the creature''s full base attack bonus, plus any modifiers appropriate to the situation. A hasted creature gains a +1 bonus on attack rolls and a +1 dodge bonus to AC and Reflex saves. All of the hasted creature''s modes of movement increase by 30 feet, to a maximum of twice the subject''s normal speed using that form of movement. Multiple haste effects don''t stack. Haste dispels and counters slow.'
);

-- =====================================================
-- SPELL CLASS LEVELS
-- =====================================================

-- Magic Missile class levels
INSERT INTO spell_class_levels (spell_id, class_id, spell_level)
VALUES
  ((SELECT id FROM spells WHERE name = 'Magic Missile'), (SELECT id FROM classes WHERE name = 'Wizard'), 1),
  ((SELECT id FROM spells WHERE name = 'Magic Missile'), (SELECT id FROM classes WHERE name = 'Sorcerer'), 1);

-- Fireball class levels
INSERT INTO spell_class_levels (spell_id, class_id, spell_level)
VALUES
  ((SELECT id FROM spells WHERE name = 'Fireball'), (SELECT id FROM classes WHERE name = 'Wizard'), 3),
  ((SELECT id FROM spells WHERE name = 'Fireball'), (SELECT id FROM classes WHERE name = 'Sorcerer'), 3);

-- Cure Light Wounds class levels
INSERT INTO spell_class_levels (spell_id, class_id, spell_level)
VALUES
  ((SELECT id FROM spells WHERE name = 'Cure Light Wounds'), (SELECT id FROM classes WHERE name = 'Cleric'), 1),
  ((SELECT id FROM spells WHERE name = 'Cure Light Wounds'), (SELECT id FROM classes WHERE name = 'Druid'), 1),
  ((SELECT id FROM spells WHERE name = 'Cure Light Wounds'), (SELECT id FROM classes WHERE name = 'Paladin'), 1),
  ((SELECT id FROM spells WHERE name = 'Cure Light Wounds'), (SELECT id FROM classes WHERE name = 'Ranger'), 2),
  ((SELECT id FROM spells WHERE name = 'Cure Light Wounds'), (SELECT id FROM classes WHERE name = 'Bard'), 1);

-- Shield class levels
INSERT INTO spell_class_levels (spell_id, class_id, spell_level)
VALUES
  ((SELECT id FROM spells WHERE name = 'Shield'), (SELECT id FROM classes WHERE name = 'Wizard'), 1),
  ((SELECT id FROM spells WHERE name = 'Shield'), (SELECT id FROM classes WHERE name = 'Sorcerer'), 1);

-- Haste class levels
INSERT INTO spell_class_levels (spell_id, class_id, spell_level)
VALUES
  ((SELECT id FROM spells WHERE name = 'Haste'), (SELECT id FROM classes WHERE name = 'Wizard'), 3),
  ((SELECT id FROM spells WHERE name = 'Haste'), (SELECT id FROM classes WHERE name = 'Sorcerer'), 3),
  ((SELECT id FROM spells WHERE name = 'Haste'), (SELECT id FROM classes WHERE name = 'Bard'), 3);

-- =====================================================
-- SPELL COMPONENTS
-- =====================================================

-- Magic Missile components (V, S)
INSERT INTO spell_components (spell_id, component_type_id, component_description, component_cost_cp, xp_cost)
VALUES
  ((SELECT id FROM spells WHERE name = 'Magic Missile'), (SELECT id FROM spell_component_types WHERE code = 'V'), NULL, NULL, NULL),
  ((SELECT id FROM spells WHERE name = 'Magic Missile'), (SELECT id FROM spell_component_types WHERE code = 'S'), NULL, NULL, NULL);

-- Fireball components (V, S, M)
INSERT INTO spell_components (spell_id, component_type_id, component_description, component_cost_cp, xp_cost)
VALUES
  ((SELECT id FROM spells WHERE name = 'Fireball'), (SELECT id FROM spell_component_types WHERE code = 'V'), NULL, NULL, NULL),
  ((SELECT id FROM spells WHERE name = 'Fireball'), (SELECT id FROM spell_component_types WHERE code = 'S'), NULL, NULL, NULL),
  ((SELECT id FROM spells WHERE name = 'Fireball'), (SELECT id FROM spell_component_types WHERE code = 'M'), 'A tiny ball of bat guano and sulfur', 0, NULL);

-- Cure Light Wounds components (V, S)
INSERT INTO spell_components (spell_id, component_type_id, component_description, component_cost_cp, xp_cost)
VALUES
  ((SELECT id FROM spells WHERE name = 'Cure Light Wounds'), (SELECT id FROM spell_component_types WHERE code = 'V'), NULL, NULL, NULL),
  ((SELECT id FROM spells WHERE name = 'Cure Light Wounds'), (SELECT id FROM spell_component_types WHERE code = 'S'), NULL, NULL, NULL);

-- Shield components (V, S)
INSERT INTO spell_components (spell_id, component_type_id, component_description, component_cost_cp, xp_cost)
VALUES
  ((SELECT id FROM spells WHERE name = 'Shield'), (SELECT id FROM spell_component_types WHERE code = 'V'), NULL, NULL, NULL),
  ((SELECT id FROM spells WHERE name = 'Shield'), (SELECT id FROM spell_component_types WHERE code = 'S'), NULL, NULL, NULL);

-- Haste components (V, S, M)
INSERT INTO spell_components (spell_id, component_type_id, component_description, component_cost_cp, xp_cost)
VALUES
  ((SELECT id FROM spells WHERE name = 'Haste'), (SELECT id FROM spell_component_types WHERE code = 'V'), NULL, NULL, NULL),
  ((SELECT id FROM spells WHERE name = 'Haste'), (SELECT id FROM spell_component_types WHERE code = 'S'), NULL, NULL, NULL),
  ((SELECT id FROM spells WHERE name = 'Haste'), (SELECT id FROM spell_component_types WHERE code = 'M'), 'A shaving of licorice root', 0, NULL);

-- =====================================================
-- SPELL DESCRIPTORS
-- =====================================================

-- Magic Missile descriptors [Force]
INSERT INTO spell_descriptors_link (spell_id, spell_descriptor_id)
VALUES
  ((SELECT id FROM spells WHERE name = 'Magic Missile'), (SELECT id FROM spell_descriptors WHERE name = 'Force'));

-- Fireball descriptors [Fire]
INSERT INTO spell_descriptors_link (spell_id, spell_descriptor_id)
VALUES
  ((SELECT id FROM spells WHERE name = 'Fireball'), (SELECT id FROM spell_descriptors WHERE name = 'Fire'));

-- Shield descriptors [Force]
INSERT INTO spell_descriptors_link (spell_id, spell_descriptor_id)
VALUES
  ((SELECT id FROM spells WHERE name = 'Shield'), (SELECT id FROM spell_descriptors WHERE name = 'Force'));

-- =====================================================
-- SPELL EFFECTS (pre-computed per caster level)
-- =====================================================

-- Magic Missile effects (1 missile at CL 1, 2 at CL 3, 3 at CL 5, 4 at CL 7, 5 at CL 9+)
-- Step 1: Create effects for each missile count
-- INSERT INTO effects (name, effect_type, is_beneficial, is_magical, description)
-- VALUES
--   ('Magic Missile: 1 missile (1d4+1 force)', 'damage', false, true, '1 missile dealing 1d4+1 force damage'),
--   ('Magic Missile: 2 missiles (2×1d4+1 force)', 'damage', false, true, '2 missiles each dealing 1d4+1 force damage'),
--   ('Magic Missile: 3 missiles (3×1d4+1 force)', 'damage', false, true, '3 missiles each dealing 1d4+1 force damage'),
--   ('Magic Missile: 4 missiles (4×1d4+1 force)', 'damage', false, true, '4 missiles each dealing 1d4+1 force damage'),
--   ('Magic Missile: 5 missiles (5×1d4+1 force)', 'damage', false, true, '5 missiles each dealing 1d4+1 force damage')
-- RETURNING id;  -- Assume returns 5001-5005
--
-- Step 2: Create damage_effects for each
-- INSERT INTO damage_effects (effect_id, number_of_dice, die_size, die_addition, allows_save, throw_id, save_result, multiplied_on_crit)
-- VALUES
--   (5001, 1, 4, 1, false, NULL, NULL, false),  -- 1 missile
--   (5002, 2, 4, 2, false, NULL, NULL, false),  -- 2 missiles (simplified: 2d4+2)
--   (5003, 3, 4, 3, false, NULL, NULL, false),  -- 3 missiles
--   (5004, 4, 4, 4, false, NULL, NULL, false),  -- 4 missiles
--   (5005, 5, 4, 5, false, NULL, NULL, false);  -- 5 missiles
--
-- Step 3: Link damage types (force)
-- INSERT INTO damage_effect_types (damage_effect_id, damage_type_id, is_alternative)
-- VALUES
--   ((SELECT id FROM damage_effects WHERE effect_id = 5001), (SELECT id FROM damage_types WHERE name = 'Force'), false),
--   ((SELECT id FROM damage_effects WHERE effect_id = 5002), (SELECT id FROM damage_types WHERE name = 'Force'), false),
--   ((SELECT id FROM damage_effects WHERE effect_id = 5003), (SELECT id FROM damage_types WHERE name = 'Force'), false),
--   ((SELECT id FROM damage_effects WHERE effect_id = 5004), (SELECT id FROM damage_types WHERE name = 'Force'), false),
--   ((SELECT id FROM damage_effects WHERE effect_id = 5005), (SELECT id FROM damage_types WHERE name = 'Force'), false);
--
-- Step 4: Create spell_effects entries
-- INSERT INTO spell_effects (spell_id, caster_level, effect_id, applies_when)
-- VALUES
--   ((SELECT id FROM spells WHERE name = 'Magic Missile'), 1, 5001, NULL),   -- 1 missile
--   ((SELECT id FROM spells WHERE name = 'Magic Missile'), 2, 5001, NULL),   -- 1 missile
--   ((SELECT id FROM spells WHERE name = 'Magic Missile'), 3, 5002, NULL),   -- 2 missiles
--   ((SELECT id FROM spells WHERE name = 'Magic Missile'), 4, 5002, NULL),   -- 2 missiles
--   ((SELECT id FROM spells WHERE name = 'Magic Missile'), 5, 5003, NULL),   -- 3 missiles
--   ((SELECT id FROM spells WHERE name = 'Magic Missile'), 6, 5003, NULL),   -- 3 missiles
--   ((SELECT id FROM spells WHERE name = 'Magic Missile'), 7, 5004, NULL),   -- 4 missiles
--   ((SELECT id FROM spells WHERE name = 'Magic Missile'), 8, 5004, NULL),   -- 4 missiles
--   ((SELECT id FROM spells WHERE name = 'Magic Missile'), 9, 5005, NULL),   -- 5 missiles
--   ((SELECT id FROM spells WHERE name = 'Magic Missile'), 10, 5005, NULL),  -- 5 missiles (capped)
--   ((SELECT id FROM spells WHERE name = 'Magic Missile'), 20, 5005, NULL);  -- 5 missiles (still capped)

-- Fireball effects (1d6/level fire, max 10d6)
-- Step 1: Create effects for each damage level
-- INSERT INTO effects (name, effect_type, is_beneficial, is_magical, description)
-- VALUES
--   ('Fireball: 1d6 fire damage', 'damage', false, true, 'Fireball damage at CL 1'),
--   ('Fireball: 2d6 fire damage', 'damage', false, true, 'Fireball damage at CL 2'),
--   ('Fireball: 3d6 fire damage', 'damage', false, true, 'Fireball damage at CL 3'),
--   -- ... continue through 10d6
--   ('Fireball: 10d6 fire damage', 'damage', false, true, 'Fireball damage at CL 10+')
-- RETURNING id;  -- Assume returns 6001-6010
--
-- Step 2: Create damage_effects for each
-- INSERT INTO damage_effects (effect_id, number_of_dice, die_size, die_addition, allows_save, throw_id, save_result, multiplied_on_crit)
-- VALUES
--   (6001, 1, 6, NULL, true, (SELECT id FROM throws WHERE name = 'Reflex'), 'half', false),
--   (6002, 2, 6, NULL, true, (SELECT id FROM throws WHERE name = 'Reflex'), 'half', false),
--   (6003, 3, 6, NULL, true, (SELECT id FROM throws WHERE name = 'Reflex'), 'half', false),
--   -- ... continue through 10d6
--   (6010, 10, 6, NULL, true, (SELECT id FROM throws WHERE name = 'Reflex'), 'half', false);
--
-- Step 3: Link damage types (fire)
-- INSERT INTO damage_effect_types (damage_effect_id, damage_type_id, is_alternative)
-- SELECT de.id, (SELECT id FROM damage_types WHERE name = 'Fire'), false
-- FROM damage_effects de
-- WHERE de.effect_id BETWEEN 6001 AND 6010;
--
-- Step 4: Create spell_effects entries
-- INSERT INTO spell_effects (spell_id, caster_level, effect_id, applies_when)
-- SELECT (SELECT id FROM spells WHERE name = 'Fireball'), level, effect_base_id + level - 1, NULL
-- FROM generate_series(1, 10) AS level;  -- CL 1-10 scale
-- INSERT INTO spell_effects (spell_id, caster_level, effect_id, applies_when)
-- SELECT (SELECT id FROM spells WHERE name = 'Fireball'), level, 6010, NULL
-- FROM generate_series(11, 20) AS level;  -- CL 11+ capped at 10d6

-- Cure Light Wounds effects (1d8+CL healing, max +5, conditional on target type)
-- Step 1: Create healing and damage effects
-- INSERT INTO effects (name, effect_type, is_beneficial, is_magical, description)
-- VALUES
--   ('CLW: 1d8+1 healing', 'healing', true, true, 'Cure Light Wounds healing at CL 1'),
--   ('CLW: 1d8+2 healing', 'healing', true, true, 'Cure Light Wounds healing at CL 2'),
--   -- ... through +5
--   ('CLW: 1d8+5 healing', 'healing', true, true, 'Cure Light Wounds healing at CL 5+'),
--   ('CLW: 1d8+1 damage (undead)', 'damage', false, true, 'CLW damage to undead at CL 1'),
--   ('CLW: 1d8+2 damage (undead)', 'damage', false, true, 'CLW damage to undead at CL 2'),
--   -- ... through +5
--   ('CLW: 1d8+5 damage (undead)', 'damage', false, true, 'CLW damage to undead at CL 5+')
-- RETURNING id;  -- Assume returns 7001-7010 (healing), 7011-7020 (damage)
--
-- Step 2: Create spell_effects entries with conditional applies_when
-- INSERT INTO spell_effects (spell_id, caster_level, effect_id, applies_when)
-- VALUES
--   ((SELECT id FROM spells WHERE name = 'Cure Light Wounds'), 1, 7001, 'target is living'),
--   ((SELECT id FROM spells WHERE name = 'Cure Light Wounds'), 1, 7011, 'target is undead'),
--   ((SELECT id FROM spells WHERE name = 'Cure Light Wounds'), 2, 7002, 'target is living'),
--   ((SELECT id FROM spells WHERE name = 'Cure Light Wounds'), 2, 7012, 'target is undead'),
--   -- ... continue through CL 5
--   ((SELECT id FROM spells WHERE name = 'Cure Light Wounds'), 5, 7005, 'target is living'),
--   ((SELECT id FROM spells WHERE name = 'Cure Light Wounds'), 5, 7015, 'target is undead'),
--   -- CL 6+ capped at +5
--   ((SELECT id FROM spells WHERE name = 'Cure Light Wounds'), 10, 7005, 'target is living'),
--   ((SELECT id FROM spells WHERE name = 'Cure Light Wounds'), 10, 7015, 'target is undead');

-- Shield effects (+4 shield bonus to AC, negates magic missile)
-- Step 1: Create AC bonus effect
-- INSERT INTO effects (name, effect_type, is_beneficial, is_magical, description)
-- VALUES
--   ('Shield: +4 shield bonus to AC', 'ac', true, true, 'Invisible force disk providing +4 shield bonus to AC'),
--   ('Shield: Negates Magic Missile', 'immunity', true, true, 'Blocks magic missile attacks')
-- RETURNING id;  -- Assume returns 8001, 8002
--
-- Step 2: Create AC effect details
-- INSERT INTO ac_effects (effect_id, ac_bonus_type, value, applies_to)
-- VALUES
--   (8001, 'shield', 4, 'all attacks');
--
-- Step 3: Create spell_effects entries (no scaling, same for all CLs)
-- INSERT INTO spell_effects (spell_id, caster_level, effect_id, applies_when)
-- SELECT (SELECT id FROM spells WHERE name = 'Shield'), level, 8001, NULL
-- FROM generate_series(1, 20) AS level;

-- Haste effects (multiple buffs: +1 attack, +1 AC, +1 Reflex, extra attack, +30 ft speed)
-- Step 1: Create individual effects
-- INSERT INTO effects (name, effect_type, is_beneficial, is_magical, description)
-- VALUES
--   ('Haste: +1 bonus on attack rolls', 'attack', true, true, '+1 bonus on attack rolls from haste'),
--   ('Haste: +1 dodge bonus to AC', 'ac', true, true, '+1 dodge bonus to AC from haste'),
--   ('Haste: +1 bonus on Reflex saves', 'save', true, true, '+1 bonus on Reflex saves from haste'),
--   ('Haste: One extra attack', 'special', true, true, 'One extra attack per round at full BAB'),
--   ('Haste: +30 ft enhancement to all movement', 'movement', true, true, '+30 ft enhancement bonus to all movement modes')
-- RETURNING id;  -- Assume returns 9001-9005
--
-- Step 2: Create spell_effects entries (all effects apply at all CLs)
-- INSERT INTO spell_effects (spell_id, caster_level, effect_id, applies_when)
-- SELECT (SELECT id FROM spells WHERE name = 'Haste'), level, 9001, NULL FROM generate_series(1, 20) AS level
-- UNION ALL
-- SELECT (SELECT id FROM spells WHERE name = 'Haste'), level, 9002, NULL FROM generate_series(1, 20) AS level
-- UNION ALL
-- SELECT (SELECT id FROM spells WHERE name = 'Haste'), level, 9003, NULL FROM generate_series(1, 20) AS level
-- UNION ALL
-- SELECT (SELECT id FROM spells WHERE name = 'Haste'), level, 9004, NULL FROM generate_series(1, 20) AS level
-- UNION ALL
-- SELECT (SELECT id FROM spells WHERE name = 'Haste'), level, 9005, NULL FROM generate_series(1, 20) AS level;

-- =====================================================
-- SPELL SAVES
-- =====================================================

-- Fireball save (Reflex half)
INSERT INTO spell_saves (spell_id, throw_id, save_dc_formula_id, effect_on_failed_save_id, effect_on_successful_save_id, save_result_type)
VALUES (
  (SELECT id FROM spells WHERE name = 'Fireball'),
  (SELECT id FROM throws WHERE name = 'Reflex'),
  (SELECT id FROM formulas WHERE name = '10 + spell level + INT modifier'),
  NULL,  -- Uses spell_effects on failure (full damage)
  NULL,  -- Runtime halves damage on success
  'half'
);

-- Cure Light Wounds save (Will half for undead)
INSERT INTO spell_saves (spell_id, throw_id, save_dc_formula_id, effect_on_failed_save_id, effect_on_successful_save_id, save_result_type)
VALUES (
  (SELECT id FROM spells WHERE name = 'Cure Light Wounds'),
  (SELECT id FROM throws WHERE name = 'Will'),
  (SELECT id FROM formulas WHERE name = '10 + spell level + WIS modifier'),
  NULL,  -- Uses spell_effects with "target is undead" (full damage)
  NULL,  -- Runtime halves damage on success
  'half'
);

-- Haste save (Fortitude negates - harmless, typically not rolled)
INSERT INTO spell_saves (spell_id, throw_id, save_dc_formula_id, effect_on_failed_save_id, effect_on_successful_save_id, save_result_type)
VALUES (
  (SELECT id FROM spells WHERE name = 'Haste'),
  (SELECT id FROM throws WHERE name = 'Fortitude'),
  (SELECT id FROM formulas WHERE name = '10 + spell level + INT modifier'),
  NULL,  -- Effect applies on failed save (willing target)
  NULL,  -- No effect on successful save (unwilling target resists)
  'negates'
);

-- =====================================================
-- COMPLETE WORKING EXAMPLE: MAGIC MISSILE EFFECTS
-- =====================================================
-- This section shows the complete data flow for creating spell effects.
-- Follow this pattern for all damage/healing spells.

-- Step 1: Create base effects in effects table
INSERT INTO effects (name, effect_type, is_beneficial, is_magical, description)
VALUES
  ('Magic Missile: 1 missile (1d4+1 force)', 'damage', false, true, '1 missile dealing 1d4+1 force damage'),
  ('Magic Missile: 2 missiles (2d4+2 force)', 'damage', false, true, '2 missiles each dealing 1d4+1 force damage'),
  ('Magic Missile: 3 missiles (3d4+3 force)', 'damage', false, true, '3 missiles each dealing 1d4+1 force damage'),
  ('Magic Missile: 4 missiles (4d4+4 force)', 'damage', false, true, '4 missiles each dealing 1d4+1 force damage'),
  ('Magic Missile: 5 missiles (5d4+5 force)', 'damage', false, true, '5 missiles each dealing 1d4+1 force damage');
-- Note: In production, capture RETURNING id values for next steps

-- Step 2: Create damage_effects entries (assumes effect IDs 10001-10005 from previous step)
-- Replace with actual IDs from RETURNING clause in production
INSERT INTO damage_effects (effect_id, number_of_dice, die_size, die_addition, allows_save, throw_id, save_result, multiplied_on_crit)
VALUES
  (10001, 1, 4, 1, false, NULL, NULL, false),  -- 1d4+1
  (10002, 2, 4, 2, false, NULL, NULL, false),  -- 2d4+2
  (10003, 3, 4, 3, false, NULL, NULL, false),  -- 3d4+3
  (10004, 4, 4, 4, false, NULL, NULL, false),  -- 4d4+4
  (10005, 5, 4, 5, false, NULL, NULL, false);  -- 5d4+5

-- Step 3: Link damage types via damage_effect_types junction
INSERT INTO damage_effect_types (damage_effect_id, damage_type_id, is_alternative)
SELECT
  de.id,
  (SELECT id FROM damage_types WHERE name = 'Force'),
  false
FROM damage_effects de
WHERE de.effect_id BETWEEN 10001 AND 10005;

-- Step 4: Create spell_effects entries linking spell to effects at each caster level
-- Magic Missile gains missiles at CL 1, 3, 5, 7, 9+
INSERT INTO spell_effects (spell_id, caster_level, effect_id, applies_when)
VALUES
  -- CL 1-2: 1 missile
  ((SELECT id FROM spells WHERE name = 'Magic Missile'), 1, 10001, NULL),
  ((SELECT id FROM spells WHERE name = 'Magic Missile'), 2, 10001, NULL),
  -- CL 3-4: 2 missiles
  ((SELECT id FROM spells WHERE name = 'Magic Missile'), 3, 10002, NULL),
  ((SELECT id FROM spells WHERE name = 'Magic Missile'), 4, 10002, NULL),
  -- CL 5-6: 3 missiles
  ((SELECT id FROM spells WHERE name = 'Magic Missile'), 5, 10003, NULL),
  ((SELECT id FROM spells WHERE name = 'Magic Missile'), 6, 10003, NULL),
  -- CL 7-8: 4 missiles
  ((SELECT id FROM spells WHERE name = 'Magic Missile'), 7, 10004, NULL),
  ((SELECT id FROM spells WHERE name = 'Magic Missile'), 8, 10004, NULL),
  -- CL 9+: 5 missiles (capped)
  ((SELECT id FROM spells WHERE name = 'Magic Missile'), 9, 10005, NULL),
  ((SELECT id FROM spells WHERE name = 'Magic Missile'), 10, 10005, NULL),
  ((SELECT id FROM spells WHERE name = 'Magic Missile'), 11, 10005, NULL),
  ((SELECT id FROM spells WHERE name = 'Magic Missile'), 12, 10005, NULL),
  ((SELECT id FROM spells WHERE name = 'Magic Missile'), 13, 10005, NULL),
  ((SELECT id FROM spells WHERE name = 'Magic Missile'), 14, 10005, NULL),
  ((SELECT id FROM spells WHERE name = 'Magic Missile'), 15, 10005, NULL),
  ((SELECT id FROM spells WHERE name = 'Magic Missile'), 16, 10005, NULL),
  ((SELECT id FROM spells WHERE name = 'Magic Missile'), 17, 10005, NULL),
  ((SELECT id FROM spells WHERE name = 'Magic Missile'), 18, 10005, NULL),
  ((SELECT id FROM spells WHERE name = 'Magic Missile'), 19, 10005, NULL),
  ((SELECT id FROM spells WHERE name = 'Magic Missile'), 20, 10005, NULL);

-- Alternative bulk insert for CL 9-20 (more efficient):
-- INSERT INTO spell_effects (spell_id, caster_level, effect_id, applies_when)
-- SELECT
--   (SELECT id FROM spells WHERE name = 'Magic Missile'),
--   level,
--   10005,
--   NULL
-- FROM generate_series(9, 20) AS level;

-- =====================================================
-- COMPLETE WORKING EXAMPLE: FIREBALL EFFECTS
-- =====================================================
-- Fireball scales 1d6 per level, max 10d6 at CL 10+

-- Step 1: Create effects for each damage tier
INSERT INTO effects (name, effect_type, is_beneficial, is_magical, description)
VALUES
  ('Fireball: 1d6 fire damage', 'damage', false, true, 'Fireball explosion at CL 1'),
  ('Fireball: 2d6 fire damage', 'damage', false, true, 'Fireball explosion at CL 2'),
  ('Fireball: 3d6 fire damage', 'damage', false, true, 'Fireball explosion at CL 3'),
  ('Fireball: 4d6 fire damage', 'damage', false, true, 'Fireball explosion at CL 4'),
  ('Fireball: 5d6 fire damage', 'damage', false, true, 'Fireball explosion at CL 5'),
  ('Fireball: 6d6 fire damage', 'damage', false, true, 'Fireball explosion at CL 6'),
  ('Fireball: 7d6 fire damage', 'damage', false, true, 'Fireball explosion at CL 7'),
  ('Fireball: 8d6 fire damage', 'damage', false, true, 'Fireball explosion at CL 8'),
  ('Fireball: 9d6 fire damage', 'damage', false, true, 'Fireball explosion at CL 9'),
  ('Fireball: 10d6 fire damage', 'damage', false, true, 'Fireball explosion at CL 10+');
-- Assumes effect IDs 11001-11010

-- Step 2: Create damage_effects (linked to Reflex save for half via spell_saves table)
INSERT INTO damage_effects (effect_id, number_of_dice, die_size, die_addition, allows_save, throw_id, save_result, multiplied_on_crit)
VALUES
  (11001, 1, 6, NULL, true, (SELECT id FROM throws WHERE name = 'Reflex'), 'half', false),
  (11002, 2, 6, NULL, true, (SELECT id FROM throws WHERE name = 'Reflex'), 'half', false),
  (11003, 3, 6, NULL, true, (SELECT id FROM throws WHERE name = 'Reflex'), 'half', false),
  (11004, 4, 6, NULL, true, (SELECT id FROM throws WHERE name = 'Reflex'), 'half', false),
  (11005, 5, 6, NULL, true, (SELECT id FROM throws WHERE name = 'Reflex'), 'half', false),
  (11006, 6, 6, NULL, true, (SELECT id FROM throws WHERE name = 'Reflex'), 'half', false),
  (11007, 7, 6, NULL, true, (SELECT id FROM throws WHERE name = 'Reflex'), 'half', false),
  (11008, 8, 6, NULL, true, (SELECT id FROM throws WHERE name = 'Reflex'), 'half', false),
  (11009, 9, 6, NULL, true, (SELECT id FROM throws WHERE name = 'Reflex'), 'half', false),
  (11010, 10, 6, NULL, true, (SELECT id FROM throws WHERE name = 'Reflex'), 'half', false);

-- Step 3: Link fire damage type
INSERT INTO damage_effect_types (damage_effect_id, damage_type_id, is_alternative)
SELECT
  de.id,
  (SELECT id FROM damage_types WHERE name = 'Fire'),
  false
FROM damage_effects de
WHERE de.effect_id BETWEEN 11001 AND 11010;

-- Step 4: Create spell_effects entries for scaling (CL 1-10, then capped at 10d6)
INSERT INTO spell_effects (spell_id, caster_level, effect_id, applies_when)
VALUES
  ((SELECT id FROM spells WHERE name = 'Fireball'), 1, 11001, NULL),
  ((SELECT id FROM spells WHERE name = 'Fireball'), 2, 11002, NULL),
  ((SELECT id FROM spells WHERE name = 'Fireball'), 3, 11003, NULL),
  ((SELECT id FROM spells WHERE name = 'Fireball'), 4, 11004, NULL),
  ((SELECT id FROM spells WHERE name = 'Fireball'), 5, 11005, NULL),
  ((SELECT id FROM spells WHERE name = 'Fireball'), 6, 11006, NULL),
  ((SELECT id FROM spells WHERE name = 'Fireball'), 7, 11007, NULL),
  ((SELECT id FROM spells WHERE name = 'Fireball'), 8, 11008, NULL),
  ((SELECT id FROM spells WHERE name = 'Fireball'), 9, 11009, NULL),
  ((SELECT id FROM spells WHERE name = 'Fireball'), 10, 11010, NULL);

-- CL 11-20: Capped at 10d6
INSERT INTO spell_effects (spell_id, caster_level, effect_id, applies_when)
SELECT
  (SELECT id FROM spells WHERE name = 'Fireball'),
  level,
  11010,  -- 10d6 effect
  NULL
FROM generate_series(11, 20) AS level;

-- =====================================================
-- METAMAGIC MODIFIERS
-- =====================================================
-- Metamagic feats modify spells by increasing spell slot level.
-- See spells.sql for full metamagic system documentation.

-- Example: Empower Spell metamagic modifier
-- INSERT INTO metamagic_modifiers (feat_id, name, spell_slot_increase, description)
-- VALUES (
--   (SELECT id FROM feats WHERE name = 'Empower Spell'),
--   'Empower Spell',
--   2,
--   'All variable, numeric effects of an empowered spell are increased by one-half. An empowered spell uses up a spell slot two levels higher than the spell''s actual level.'
-- ) RETURNING id;  -- Assume returns 1001
--
-- Link modifier to formula for 1.5x scaling:
-- INSERT INTO metamagic_modifier_formulas (metamagic_modifier_id, formula_id, modification_type)
-- VALUES (
--   1001,
--   (SELECT id FROM formulas WHERE name = 'Multiply by 1.5'),
--   'damage_multiplier'
-- );

-- =====================================================
-- SPELL PREREQUISITES (RARE)
-- =====================================================
-- Some spells have prerequisites (rare in SRD, but system supports it).
-- Uses normalized prerequisites system via spell_prerequisites junction.

-- Example: Hypothetical spell requiring Fireball known
-- Step 1: Create prerequisite group
-- INSERT INTO prerequisite_groups (logic_operator, description)
-- VALUES ('AND', 'Delayed Blast Fireball prerequisite: Must know Fireball')
-- RETURNING id;  -- Assume returns 5001
--
-- Step 2: Create spell known prerequisite
-- INSERT INTO spell_known_prerequisites (spell_id, minimum_caster_level)
-- VALUES (
--   (SELECT id FROM spells WHERE name = 'Fireball'),
--   NULL  -- Just need to know it, any CL
-- ) RETURNING id;  -- Assume returns 6001
--
-- Step 3: Link prerequisite to group
-- INSERT INTO prerequisite_conditions (prerequisite_group_id, prerequisite_id, prerequisite_type)
-- VALUES (5001, 6001, 'spell_known');
--
-- Step 4: Link group to spell
-- INSERT INTO spell_prerequisites (spell_id, prerequisite_group_id)
-- VALUES (
--   (SELECT id FROM spells WHERE name = 'Delayed Blast Fireball'),
--   5001
-- );

-- =====================================================
-- SPELL GRANTED CONDITIONS
-- =====================================================
-- Many spells grant conditions (buffs/debuffs).
-- Example: Invisibility grants "invisible" condition

-- INSERT INTO spell_granted_conditions (spell_id, condition_id, duration_type, duration_formula_id)
-- VALUES (
--   (SELECT id FROM spells WHERE name = 'Invisibility'),
--   (SELECT id FROM conditions WHERE name = 'Invisible'),
--   'minutes_per_level',
--   (SELECT id FROM formulas WHERE name = 'Caster Level')
-- );

-- Example: Haste grants "hasted" condition (bundles all haste effects)
-- INSERT INTO spell_granted_conditions (spell_id, condition_id, duration_type, duration_formula_id)
-- VALUES (
--   (SELECT id FROM spells WHERE name = 'Haste'),
--   (SELECT id FROM conditions WHERE name = 'Hasted'),
--   'rounds_per_level',
--   (SELECT id FROM formulas WHERE name = 'Caster Level')
-- );

-- =====================================================
-- QUERY EXAMPLES FOR RUNTIME SPELL RESOLUTION
-- =====================================================

-- Get spell details with all components and descriptors:
-- SELECT
--   s.name,
--   ss.name AS school,
--   sub.name AS subschool,
--   s.casting_time,
--   s.range_type,
--   s.duration,
--   s.allows_spell_resistance,
--   STRING_AGG(DISTINCT sct.code, ', ' ORDER BY sct.code) AS components,
--   STRING_AGG(DISTINCT sd.name, ', ' ORDER BY sd.name) AS descriptors
-- FROM spells s
-- JOIN spell_schools ss ON s.spell_school_id = ss.id
-- LEFT JOIN spell_subschools sub ON s.spell_subschool_id = sub.id
-- LEFT JOIN spell_components sc ON s.id = sc.spell_id
-- LEFT JOIN spell_component_types sct ON sc.component_type_id = sct.id
-- LEFT JOIN spell_descriptors_link sdl ON s.id = sdl.spell_id
-- LEFT JOIN spell_descriptors sd ON sdl.spell_descriptor_id = sd.id
-- WHERE s.name = 'Fireball'
-- GROUP BY s.id, ss.name, sub.name;

-- Get spell effects at specific caster level:
-- SELECT
--   s.name AS spell_name,
--   se.caster_level,
--   e.name AS effect_name,
--   e.effect_type,
--   de.number_of_dice,
--   de.die_size,
--   de.die_addition,
--   dt.name AS damage_type,
--   se.applies_when
-- FROM spell_effects se
-- JOIN spells s ON se.spell_id = s.id
-- JOIN effects e ON se.effect_id = e.id
-- LEFT JOIN damage_effects de ON e.id = de.effect_id
-- LEFT JOIN damage_effect_types det ON de.id = det.damage_effect_id
-- LEFT JOIN damage_types dt ON det.damage_type_id = dt.id
-- WHERE s.name = 'Fireball' AND se.caster_level = 5;

-- Get spell save information:
-- SELECT
--   s.name AS spell_name,
--   t.name AS save_type,
--   ss.save_result_type,
--   f.formula_expression AS dc_formula
-- FROM spell_saves ss
-- JOIN spells s ON ss.spell_id = s.id
-- JOIN throws t ON ss.throw_id = t.id
-- JOIN formulas f ON ss.save_dc_formula_id = f.id
-- WHERE s.name = 'Fireball';

-- Get all spells for a class at a specific level:
-- SELECT
--   s.name,
--   ss.name AS school,
--   scl.spell_level,
--   s.casting_time,
--   s.range_type
-- FROM spell_class_levels scl
-- JOIN spells s ON scl.spell_id = s.id
-- JOIN spell_schools ss ON s.spell_school_id = ss.id
-- JOIN classes c ON scl.class_id = c.id
-- WHERE c.name = 'Wizard' AND scl.spell_level = 3
-- ORDER BY s.name;

-- Get conditional effects (like Cure Light Wounds):
-- SELECT
--   s.name,
--   se.caster_level,
--   e.name AS effect_name,
--   se.applies_when
-- FROM spell_effects se
-- JOIN spells s ON se.spell_id = s.id
-- JOIN effects e ON se.effect_id = e.id
-- WHERE s.name = 'Cure Light Wounds' AND se.caster_level = 5
-- ORDER BY se.applies_when;

-- =====================================================
-- NOTES ON SCHEMA MAPPING
-- =====================================================
--
-- Fields mapped from SRD HTML:
-- - name: Spell name from h2 heading
-- - spell_school_id: From spell school line (Evocation, Conjuration, etc.)
-- - spell_subschool_id: From parenthetical (Healing, Teleportation, etc.)
-- - is_arcane: True if "Sor/Wiz" or "Brd" appears in Level line
-- - is_divine: True if "Clr", "Drd", "Pal", "Rgr" appears in Level line
-- - casting_time: From "Casting Time:" line
--     → "1 standard action" → 'standard'
--     → "1 full-round action" → 'full-round'
--     → "1 round" → '1 round'
--     → etc.
-- - range_type: From "Range:" line
--     → "Personal" → 'personal'
--     → "Touch" → 'touch'
--     → "Close (25 ft. + 5 ft./2 levels)" → 'close'
--     → "Medium (100 ft. + 10 ft./level)" → 'medium'
--     → "Long (400 ft. + 40 ft./level)" → 'long'
-- - range_formula_id: Link to formula for close/medium/long
-- - area_of_effect: From "Area:" or "Targets:" line
-- - duration: From "Duration:" line (stored as text, e.g., "1 min./level (D)")
-- - allows_spell_resistance: From "Spell Resistance:" line
--     → "Yes" → true
--     → "No" → false
--     → "Yes (harmless)" → true (spell is beneficial)
-- - description: Combined spell description paragraphs
--
-- Spell class levels mapping:
-- - Extract from "Level:" line
-- - Parse "Sor/Wiz 3" → Sorcerer level 3, Wizard level 3
-- - Parse "Clr 1, Drd 1, Pal 1, Rgr 2" → multiple class level entries
-- - Class name abbreviations:
--     Sor → Sorcerer, Wiz → Wizard, Clr → Cleric, Drd → Druid,
--     Pal → Paladin, Rgr → Ranger, Brd → Bard
--
-- Spell components mapping:
-- - Extract from "Components:" line
-- - V → Verbal, S → Somatic, M → Material, F → Focus, DF → Divine Focus, XP → XP cost
-- - Material component description from "Material Component:" paragraph
-- - Component cost extracted from description (typically 0 gp for free components)
--
-- Spell descriptors mapping:
-- - Extract from brackets in school line: "Evocation [Fire]" → Fire descriptor
-- - Multiple descriptors: "Enchantment (Compulsion) [Mind-Affecting]" → Mind-Affecting
-- - Common descriptors: Fire, Cold, Electricity, Acid, Sonic, Force, Mind-Affecting, Fear, Evil, Good, Lawful, Chaotic, Death, etc.
--
-- Spell effects mapping (pre-computed approach):
-- - Parse damage/healing from description
-- - Identify scaling pattern (1d6/level, 1d8+1/level, etc.)
-- - Identify cap (max 10d6, max +5, etc.)
-- - Create effect entry for each caster level
-- - For non-scaling spells, duplicate effect across all CLs
-- - For conditional spells, use applies_when column
--
-- Spell saves mapping:
-- - Extract from "Saving Throw:" line
-- - "None" → No spell_saves entry
-- - "Reflex half" → save_result_type = 'half', throw_id = Reflex
-- - "Will negates" → save_result_type = 'negates', throw_id = Will
-- - "Fortitude partial" → save_result_type = 'custom' with effect IDs
-- - "(harmless)" → Beneficial spell, save allows unwilling target to resist
-- - "see text" → Complex save, requires custom effect handling
--
-- Edge cases:
-- - Spells with choices (Bestow Curse, Polymorph) → Multiple spell_effects with applies_when
-- - Conditional spells (Cure/Inflict series) → applies_when for target type
-- - Multi-effect spells (Haste, Bless) → Multiple spell_effects per CL
-- - Spells with special materials → component_cost_cp for expensive components
-- - Spells with XP cost → xp_cost field in spell_components
-- - Spells that scale beyond CL 20 (epic) → spell_effects entries up to CL 30
--
-- Import strategy:
-- 1. Import spell schools and subschools
-- 2. Import spell descriptors
-- 3. Import spell component types (V, S, M, F, DF, XP)
-- 4. Import base spell data (name, school, range, duration, etc.)
-- 5. Import spell_class_levels (which classes can cast, at what level)
-- 6. Import spell_components (V/S/M/F/DF/XP requirements)
-- 7. Import spell_descriptors_link (Fire, Cold, Mind-Affecting, etc.)
-- 8. Create effects for spell scaling (damage, healing, buffs)
-- 9. Import spell_effects (link spells to effects at each CL)
-- 10. Import spell_saves (save DCs and results)
--
-- =====================================================
