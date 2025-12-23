-- =====================================================
-- D&D 3.5 SRD MONSTERS - SAMPLE INSERT STATEMENTS
-- =====================================================
-- Schema: pnpo_3_5_dev.monster_templates
-- Source: SRD HTML exports (monsters-*.html)

SET search_path TO pnpo_3_5_dev;

-- =====================================================
-- PREREQUISITE REFERENCE DATA
-- =====================================================
-- These tables must be populated before importing monsters.

-- Creature Type Progressions (BAB, saves, skill points by type)
INSERT INTO creature_type_progressions (
  creature_type_id,
  bab_progression,
  fortitude_progression,
  reflex_progression,
  will_progression,
  skill_points_per_hd
)
SELECT
  ct.id,
  CASE ct.name
    WHEN 'Dragon' THEN 'full'
    WHEN 'Magical Beast' THEN 'full'
    WHEN 'Monstrous Humanoid' THEN 'full'
    WHEN 'Outsider' THEN 'full'
    WHEN 'Fey' THEN 'poor'
    WHEN 'Undead' THEN 'poor'
    ELSE 'medium'
  END,
  CASE ct.name
    WHEN 'Animal' THEN 'good'
    WHEN 'Dragon' THEN 'good'
    WHEN 'Giant' THEN 'good'
    WHEN 'Magical Beast' THEN 'good'
    WHEN 'Monstrous Humanoid' THEN 'good'
    WHEN 'Outsider' THEN 'good'
    WHEN 'Plant' THEN 'good'
    ELSE 'poor'
  END,
  CASE ct.name
    WHEN 'Animal' THEN 'good'
    WHEN 'Dragon' THEN 'good'
    WHEN 'Elemental' THEN 'good'
    WHEN 'Fey' THEN 'good'
    WHEN 'Magical Beast' THEN 'good'
    WHEN 'Monstrous Humanoid' THEN 'good'
    WHEN 'Outsider' THEN 'good'
    ELSE 'poor'
  END,
  CASE ct.name
    WHEN 'Aberration' THEN 'good'
    WHEN 'Dragon' THEN 'good'
    WHEN 'Fey' THEN 'good'
    WHEN 'Outsider' THEN 'good'
    WHEN 'Undead' THEN 'good'
    ELSE 'poor'
  END,
  CASE ct.name
    WHEN 'Construct' THEN 0
    WHEN 'Ooze' THEN 0
    WHEN 'Vermin' THEN 0
    WHEN 'Aberration' THEN 2
    WHEN 'Animal' THEN 2
    WHEN 'Elemental' THEN 2
    WHEN 'Giant' THEN 2
    WHEN 'Humanoid' THEN 2
    WHEN 'Magical Beast' THEN 2
    WHEN 'Monstrous Humanoid' THEN 2
    WHEN 'Plant' THEN 2
    WHEN 'Undead' THEN 2
    WHEN 'Dragon' THEN 6
    WHEN 'Fey' THEN 6
    WHEN 'Outsider' THEN 8
    ELSE 2
  END
FROM creature_types ct
ON CONFLICT (creature_type_id) DO NOTHING;

-- =====================================================
-- EXAMPLE MONSTER INSERTS
-- =====================================================

-- Example 1: GOBLIN (Small humanoid, simple stats)
INSERT INTO monster_templates (
  name,
  creature_type_id,
  creature_subtype_ids,
  size_category_id,
  hit_dice_count,
  hit_die_size,
  hit_dice_bonus,
  challenge_rating,
  base_strength,
  base_dexterity,
  base_constitution,
  base_intelligence,
  base_wisdom,
  base_charisma,
  natural_armor_bonus,
  land_speed,
  fly_speed,
  fly_maneuverability,
  swim_speed,
  burrow_speed,
  climb_speed,
  darkvision_range,
  low_light_vision,
  blindsight_range,
  blindsense_range,
  tremorsense_range,
  scent,
  spell_resistance,
  environment,
  organization,
  treasure_type,
  alignment,
  level_adjustment,
  description
) VALUES (
  'Goblin',
  (SELECT id FROM creature_types WHERE name = 'Humanoid'),
  ARRAY[(SELECT id FROM creature_subtypes WHERE name = 'Goblinoid')],
  (SELECT id FROM size_categories WHERE name = 'Small'),
  1,
  8,
  1,
  0.33,
  11,  -- STR
  13,  -- DEX
  12,  -- CON
  10,  -- INT
  9,   -- WIS
  6,   -- CHA
  0,
  30,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  60,
  false,
  NULL,
  NULL,
  NULL,
  false,
  NULL,
  'Temperate plains and forests',
  'Gang (4–9), warband (10–16 plus 100% noncombatants plus 1 leader of 3rd–4th level and 2–4 dire wolves), or tribe (17–60 plus 100% noncombatants plus 1 leader of 4th–6th level, 2–4 lieutenants of 2nd or 3rd level, and 4–6 dire wolves)',
  'standard',
  'Usually neutral evil',
  0,
  'Goblins are small humanoids that many consider little more than a nuisance. They stand 3 to 3-1/2 feet tall with flat faces, broad noses, pointed ears, wide mouths and small, sharp fangs. Their foreheads slope back, and their eyes are usually dull and glazed. They always walk upright, but their arms hang down almost to their knees. Their skin color ranges from yellow through any shade of orange to a deep red; usually all members of a single tribe are about the same color. Goblins wear clothing of dark leather, tending toward dull soiled-looking colors.'
);

-- Example 2: OGRE (Large giant, more hit dice, simple brute)
INSERT INTO monster_templates (
  name,
  creature_type_id,
  creature_subtype_ids,
  size_category_id,
  hit_dice_count,
  hit_die_size,
  hit_dice_bonus,
  challenge_rating,
  base_strength,
  base_dexterity,
  base_constitution,
  base_intelligence,
  base_wisdom,
  base_charisma,
  natural_armor_bonus,
  land_speed,
  fly_speed,
  fly_maneuverability,
  swim_speed,
  burrow_speed,
  climb_speed,
  darkvision_range,
  low_light_vision,
  blindsight_range,
  blindsense_range,
  tremorsense_range,
  scent,
  spell_resistance,
  environment,
  organization,
  treasure_type,
  alignment,
  level_adjustment,
  description
) VALUES (
  'Ogre',
  (SELECT id FROM creature_types WHERE name = 'Giant'),
  NULL,
  (SELECT id FROM size_categories WHERE name = 'Large'),
  4,
  8,
  11,
  3.00,
  21,  -- STR
  8,   -- DEX
  15,  -- CON
  6,   -- INT
  10,  -- WIS
  7,   -- CHA
  5,
  40,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  60,
  false,
  NULL,
  NULL,
  NULL,
  false,
  NULL,
  'Temperate hills',
  'Solitary, pair, gang (3–4), or band (5–8)',
  'standard',
  'Usually chaotic evil',
  NULL,
  'Ogres are big, ugly, greedy humanoids that live by ambushes, raids, and theft. Ill-tempered and nasty, these monsters are often found serving as mercenaries in the ranks of orc tribes, evil clerics, or anyone else willing to pay them. Adult ogres stand 9 to 10 feet tall and weigh 600 to 650 pounds. Their skin color ranges from dull yellow to dull brown. Their clothing consists of poorly cured furs and hides, which add to their naturally repellent odor. Ogres speak Giant, and those specimens who boast Intelligence scores of at least 10 also speak Common.'
);

-- Example 3: GELATINOUS CUBE (Large ooze, special abilities, mindless)
INSERT INTO monster_templates (
  name,
  creature_type_id,
  creature_subtype_ids,
  size_category_id,
  hit_dice_count,
  hit_die_size,
  hit_dice_bonus,
  challenge_rating,
  base_strength,
  base_dexterity,
  base_constitution,
  base_intelligence,
  base_wisdom,
  base_charisma,
  natural_armor_bonus,
  land_speed,
  fly_speed,
  fly_maneuverability,
  swim_speed,
  burrow_speed,
  climb_speed,
  darkvision_range,
  low_light_vision,
  blindsight_range,
  blindsense_range,
  tremorsense_range,
  scent,
  spell_resistance,
  environment,
  organization,
  treasure_type,
  alignment,
  level_adjustment,
  description
) VALUES (
  'Gelatinous Cube',
  (SELECT id FROM creature_types WHERE name = 'Ooze'),
  NULL,
  (SELECT id FROM size_categories WHERE name = 'Large'),
  4,
  10,
  12,
  3.00,
  10,  -- STR
  1,   -- DEX
  14,  -- CON
  NULL,  -- Mindless (no INT)
  1,   -- WIS
  1,   -- CHA
  0,
  15,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  false,
  60,
  NULL,
  NULL,
  false,
  NULL,
  'Underground',
  'Solitary',
  'incidental',
  'Always neutral',
  NULL,
  'Gelatinous cubes scour dungeon passages in silent, predictable patterns, leaving perfectly clean paths in their wake. They consume living tissue while leaving bones and other materials undissolved. A gelatinous cube is all but transparent and is barely visible, making it an ideal trap for the unwary dungeon explorer. A typical gelatinous cube measures 10 feet on a side and weighs about 15,000 pounds. The cube cannot fit through openings smaller than 10 feet across. It must squeeze through passages only 5 feet wide.'
);

-- Example 4: SKELETON (Medium undead template, no CON)
-- Note: Skeleton is a template, not a base creature
-- This example shows a Human Skeleton (Medium humanoid → Medium undead)
INSERT INTO monster_templates (
  name,
  creature_type_id,
  creature_subtype_ids,
  size_category_id,
  hit_dice_count,
  hit_die_size,
  hit_dice_bonus,
  challenge_rating,
  base_strength,
  base_dexterity,
  base_constitution,
  base_intelligence,
  base_wisdom,
  base_charisma,
  natural_armor_bonus,
  land_speed,
  fly_speed,
  fly_maneuverability,
  swim_speed,
  burrow_speed,
  climb_speed,
  darkvision_range,
  low_light_vision,
  blindsight_range,
  blindsense_range,
  tremorsense_range,
  scent,
  spell_resistance,
  environment,
  organization,
  treasure_type,
  alignment,
  level_adjustment,
  description
) VALUES (
  'Human Skeleton',
  (SELECT id FROM creature_types WHERE name = 'Undead'),
  NULL,
  (SELECT id FROM size_categories WHERE name = 'Medium'),
  1,
  12,
  0,
  0.33,
  13,  -- STR
  13,  -- DEX
  NULL,  -- Undead have no CON
  NULL,  -- Mindless
  10,  -- WIS
  1,   -- CHA
  2,
  30,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  60,
  false,
  NULL,
  NULL,
  NULL,
  false,
  NULL,
  'Any',
  'Any',
  'none',
  'Always neutral',
  NULL,
  'Skeletons are the animated bones of the dead, mindless automatons that obey the orders of their evil masters. A skeleton is seldom garbed in anything more than the rotting remnants of any clothing or armor it was wearing when slain. A skeleton does only what it is ordered to do. It can draw no conclusions of its own and takes no initiative. Because of this limitation, its instructions must always be simple. A skeleton attacks until destroyed.'
);

-- Example 5: ORC (Medium humanoid, light sensitivity)
INSERT INTO monster_templates (
  name,
  creature_type_id,
  creature_subtype_ids,
  size_category_id,
  hit_dice_count,
  hit_die_size,
  hit_dice_bonus,
  challenge_rating,
  base_strength,
  base_dexterity,
  base_constitution,
  base_intelligence,
  base_wisdom,
  base_charisma,
  natural_armor_bonus,
  land_speed,
  fly_speed,
  fly_maneuverability,
  swim_speed,
  burrow_speed,
  climb_speed,
  darkvision_range,
  low_light_vision,
  blindsight_range,
  blindsense_range,
  tremorsense_range,
  scent,
  spell_resistance,
  environment,
  organization,
  treasure_type,
  alignment,
  level_adjustment,
  description
) VALUES (
  'Orc',
  (SELECT id FROM creature_types WHERE name = 'Humanoid'),
  ARRAY[(SELECT id FROM creature_subtypes WHERE name = 'Orc')],
  (SELECT id FROM size_categories WHERE name = 'Medium'),
  1,
  8,
  1,
  0.50,
  15,  -- STR
  10,  -- DEX
  12,  -- CON
  9,   -- INT
  8,   -- WIS
  8,   -- CHA
  0,
  30,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  60,
  false,
  NULL,
  NULL,
  NULL,
  false,
  NULL,
  'Temperate hills',
  'Gang (2–4), squad (11–20 plus 2 3rd-level sergeants and 1 leader of 3rd–6th level), or band (30–100 plus 150% noncombatants plus 1 3rd-level sergeant per 10 adults, 5 5th-level lieutenants, and 3 7th-level captains)',
  'standard',
  'Often chaotic evil',
  0,
  'Orcs are aggressive humanoids that raid, pillage, and battle other creatures. They have a hatred of elves and dwarves that began generations ago, and often kill such creatures on sight. The language an orc speaks varies slightly from tribe to tribe, but any orc is understandable by someone else who speaks Orc. Some orcs know Goblin or Giant as well. Most orcs encountered away from their homes are warriors; the information in the statistics block is for one of 1st level.'
);

-- =====================================================
-- MONSTER ADVANCEMENT RANGES
-- =====================================================

-- Goblin advancement
INSERT INTO monster_advancement_ranges (
  monster_template_id,
  min_hit_dice,
  max_hit_dice,
  size_category_id,
  strength_adjustment,
  dexterity_adjustment,
  constitution_adjustment,
  natural_armor_adjustment,
  cr_adjustment,
  notes
) VALUES
  (
    (SELECT id FROM monster_templates WHERE name = 'Goblin'),
    1,
    1,
    (SELECT id FROM size_categories WHERE name = 'Small'),
    0, 0, 0, 0, 0.00,
    'Base goblin stats'
  ),
  (
    (SELECT id FROM monster_templates WHERE name = 'Goblin'),
    2,
    3,
    (SELECT id FROM size_categories WHERE name = 'Small'),
    0, 0, 0, 0, 0.50,
    '2-3 HD remains Small'
  ),
  (
    (SELECT id FROM monster_templates WHERE name = 'Goblin'),
    4,
    6,
    (SELECT id FROM size_categories WHERE name = 'Medium'),
    4, -2, 2, 2, 1.00,
    'Advances to Medium size, gains size adjustments'
  );

-- Ogre advancement
INSERT INTO monster_advancement_ranges (
  monster_template_id,
  min_hit_dice,
  max_hit_dice,
  size_category_id,
  strength_adjustment,
  dexterity_adjustment,
  constitution_adjustment,
  natural_armor_adjustment,
  cr_adjustment,
  notes
) VALUES
  (
    (SELECT id FROM monster_templates WHERE name = 'Ogre'),
    4,
    7,
    (SELECT id FROM size_categories WHERE name = 'Large'),
    0, 0, 0, 0, 0.00,
    'Base ogre stats'
  ),
  (
    (SELECT id FROM monster_templates WHERE name = 'Ogre'),
    8,
    11,
    (SELECT id FROM size_categories WHERE name = 'Large'),
    0, 0, 0, 0, 1.00,
    '8-11 HD remains Large, CR +1'
  ),
  (
    (SELECT id FROM monster_templates WHERE name = 'Ogre'),
    12,
    15,
    (SELECT id FROM size_categories WHERE name = 'Huge'),
    8, -2, 4, 3, 2.00,
    'Advances to Huge size'
  );

-- =====================================================
-- MONSTER SPECIAL ABILITIES
-- =====================================================
-- Monster abilities link to unified special_abilities system.
-- See special_abilities.sql for the special_abilities table.

-- Create common monster special abilities
INSERT INTO special_abilities (name, ability_type, is_active, activation_type, description, source_category)
VALUES
  ('Darkvision 60 ft.', 'extraordinary', false, 'passive', 'Can see in darkness up to 60 feet. Darkvision is black and white only.', 'general'),
  ('Darkvision 120 ft.', 'extraordinary', false, 'passive', 'Can see in darkness up to 120 feet. Darkvision is black and white only.', 'general'),
  ('Scent', 'extraordinary', false, 'passive', 'Can detect approaching enemies, sniff out hidden foes, and track by sense of smell.', 'general'),
  ('Light Sensitivity', 'extraordinary', false, 'passive', 'In bright sunlight or within the radius of a daylight spell, takes a -1 penalty on attack rolls and -1 penalty on Search and Spot checks.', 'general'),
  ('Blindsight 60 ft.', 'extraordinary', false, 'passive', 'Can sense surroundings without relying on sight within 60 feet.', 'general'),
  ('Acid', 'extraordinary', false, 'passive', 'Deals acid damage on contact.', 'general'),
  ('Engulf', 'extraordinary', true, 'standard', 'Can flow over and around creatures to engulf them.', 'general'),
  ('Paralysis', 'extraordinary', false, 'passive', 'Paralysis on successful attack. Fortitude save negates.', 'general'),
  ('Transparent', 'extraordinary', false, 'passive', 'Difficult to notice (+15 DC to Spot checks when motionless).', 'general'),
  ('Immunity to Cold', 'extraordinary', false, 'passive', 'Immune to cold damage.', 'general'),
  ('Undead Traits', 'extraordinary', false, 'passive', 'No Constitution score, immunity to mind-affecting, poison, sleep, paralysis, stunning, disease, death effects, necromancy effects, and critical hits.', 'general')
ON CONFLICT (name) DO NOTHING;

-- Link special abilities to monsters
INSERT INTO monster_template_special_abilities (monster_template_id, special_ability_id, override_uses_per_day, notes)
VALUES
  -- Goblin: Darkvision
  (
    (SELECT id FROM monster_templates WHERE name = 'Goblin'),
    (SELECT id FROM special_abilities WHERE name = 'Darkvision 60 ft.'),
    NULL,
    NULL
  ),
  -- Ogre: Darkvision
  (
    (SELECT id FROM monster_templates WHERE name = 'Ogre'),
    (SELECT id FROM special_abilities WHERE name = 'Darkvision 60 ft.'),
    NULL,
    NULL
  ),
  -- Gelatinous Cube: Multiple abilities
  (
    (SELECT id FROM monster_templates WHERE name = 'Gelatinous Cube'),
    (SELECT id FROM special_abilities WHERE name = 'Blindsight 60 ft.'),
    NULL,
    NULL
  ),
  (
    (SELECT id FROM monster_templates WHERE name = 'Gelatinous Cube'),
    (SELECT id FROM special_abilities WHERE name = 'Acid'),
    NULL,
    '1d6 acid damage per round of contact'
  ),
  (
    (SELECT id FROM monster_templates WHERE name = 'Gelatinous Cube'),
    (SELECT id FROM special_abilities WHERE name = 'Engulf'),
    NULL,
    'DC 13 Reflex save to avoid'
  ),
  (
    (SELECT id FROM monster_templates WHERE name = 'Gelatinous Cube'),
    (SELECT id FROM special_abilities WHERE name = 'Paralysis'),
    NULL,
    'DC 13 Fortitude save, 3d6 rounds'
  ),
  (
    (SELECT id FROM monster_templates WHERE name = 'Gelatinous Cube'),
    (SELECT id FROM special_abilities WHERE name = 'Transparent'),
    NULL,
    'DC 15 Spot check to notice when motionless'
  ),
  (
    (SELECT id FROM monster_templates WHERE name = 'Gelatinous Cube'),
    (SELECT id FROM special_abilities WHERE name = 'Immunity to Cold'),
    NULL,
    NULL
  ),
  -- Skeleton: Undead traits and darkvision
  (
    (SELECT id FROM monster_templates WHERE name = 'Human Skeleton'),
    (SELECT id FROM special_abilities WHERE name = 'Darkvision 60 ft.'),
    NULL,
    NULL
  ),
  (
    (SELECT id FROM monster_templates WHERE name = 'Human Skeleton'),
    (SELECT id FROM special_abilities WHERE name = 'Undead Traits'),
    NULL,
    NULL
  ),
  -- Orc: Darkvision and light sensitivity
  (
    (SELECT id FROM monster_templates WHERE name = 'Orc'),
    (SELECT id FROM special_abilities WHERE name = 'Darkvision 60 ft.'),
    NULL,
    NULL
  ),
  (
    (SELECT id FROM monster_templates WHERE name = 'Orc'),
    (SELECT id FROM special_abilities WHERE name = 'Light Sensitivity'),
    NULL,
    NULL
  );

-- =====================================================
-- MONSTER NATURAL ATTACKS
-- =====================================================
-- Natural attacks use the actions system
-- See actions.sql for natural_attack_actions table

-- Create natural attack actions for monsters
-- Example: Gelatinous Cube slam attack
-- INSERT INTO actions (name, action_type, action_timing, description)
-- VALUES (
--   'Gelatinous Cube Slam',
--   'attack',
--   'standard',
--   'Slam attack dealing damage and paralysis'
-- ) RETURNING id;  -- Assume returns 1001
--
-- INSERT INTO natural_attack_actions (
--   action_id,
--   attack_type,
--   number_of_attacks,
--   damage_dice_count,
--   damage_die_size,
--   damage_bonus,
--   critical_threat_range,
--   critical_multiplier,
--   reach,
--   special_properties
-- ) VALUES (
--   1001,
--   'slam',
--   1,
--   1,
--   6,
--   0,
--   20,
--   2,
--   10,
--   'Plus paralysis (DC 13 Fort negates, 3d6 rounds) and acid (1d6)'
-- );
--
-- Link to monster:
-- INSERT INTO monster_template_natural_attacks (monster_template_id, natural_attack_action_id, is_primary)
-- VALUES (
--   (SELECT id FROM monster_templates WHERE name = 'Gelatinous Cube'),
--   1001,
--   true
-- );

-- =====================================================
-- MONSTER SKILLS
-- =====================================================
-- Monsters have racial bonuses to certain skills
-- Uses monster_template_skills junction table

-- Example: Goblin skills (Move Silently +4, Ride +4)
-- INSERT INTO monster_template_skills (monster_template_id, skill_id, racial_bonus, always_class_skill)
-- VALUES
--   ((SELECT id FROM monster_templates WHERE name = 'Goblin'), (SELECT id FROM skills WHERE name = 'Move Silently'), 4, false),
--   ((SELECT id FROM monster_templates WHERE name = 'Goblin'), (SELECT id FROM skills WHERE name = 'Ride'), 4, false);
--
-- Example: Gelatinous Cube has no skills (mindless, 0 skill points)

-- =====================================================
-- MONSTER FEATS
-- =====================================================
-- Monsters gain feats based on HD
-- Uses monster_template_feats junction table

-- Example: Ogre feats (Toughness, Weapon Focus: greatclub)
-- INSERT INTO monster_template_feats (monster_template_id, feat_id, is_bonus_feat, notes)
-- VALUES
--   ((SELECT id FROM monster_templates WHERE name = 'Ogre'), (SELECT id FROM feats WHERE name = 'Toughness'), false, NULL),
--   ((SELECT id FROM monster_templates WHERE name = 'Ogre'), (SELECT id FROM feats WHERE name = 'Weapon Focus (Greatclub)'), false, NULL);

-- =====================================================
-- QUERY EXAMPLES
-- =====================================================

-- Get full monster stats with abilities:
-- SELECT
--   mt.name,
--   ct.name AS creature_type,
--   sc.name AS size,
--   mt.hit_dice_count || 'd' || mt.hit_die_size || '+' || mt.hit_dice_bonus AS hit_dice,
--   mt.challenge_rating,
--   mt.base_strength,
--   mt.base_dexterity,
--   mt.base_constitution,
--   mt.base_intelligence,
--   mt.base_wisdom,
--   mt.base_charisma,
--   mt.natural_armor_bonus,
--   mt.land_speed,
--   mt.darkvision_range,
--   STRING_AGG(sa.name, ', ' ORDER BY sa.name) AS special_abilities
-- FROM monster_templates mt
-- JOIN creature_types ct ON mt.creature_type_id = ct.id
-- JOIN size_categories sc ON mt.size_category_id = sc.id
-- LEFT JOIN monster_template_special_abilities mtsa ON mt.id = mtsa.monster_template_id
-- LEFT JOIN special_abilities sa ON mtsa.special_ability_id = sa.id
-- WHERE mt.name = 'Gelatinous Cube'
-- GROUP BY mt.id, ct.name, sc.name;

-- Get monsters by CR range:
-- SELECT
--   mt.name,
--   ct.name AS type,
--   sc.name AS size,
--   mt.challenge_rating,
--   mt.hit_dice_count
-- FROM monster_templates mt
-- JOIN creature_types ct ON mt.creature_type_id = ct.id
-- JOIN size_categories sc ON mt.size_category_id = sc.id
-- WHERE mt.challenge_rating BETWEEN 1 AND 5
-- ORDER BY mt.challenge_rating, mt.name;

-- Get monster advancement options:
-- SELECT
--   mt.name,
--   mar.min_hit_dice || '-' || mar.max_hit_dice || ' HD' AS hd_range,
--   sc.name AS size,
--   mar.strength_adjustment,
--   mar.dexterity_adjustment,
--   mar.constitution_adjustment,
--   mar.natural_armor_adjustment,
--   mar.cr_adjustment,
--   mar.notes
-- FROM monster_advancement_ranges mar
-- JOIN monster_templates mt ON mar.monster_template_id = mt.id
-- JOIN size_categories sc ON mar.size_category_id = sc.id
-- WHERE mt.name = 'Goblin'
-- ORDER BY mar.min_hit_dice;

-- Get monsters by environment:
-- SELECT
--   mt.name,
--   ct.name AS type,
--   mt.challenge_rating,
--   mt.environment,
--   mt.organization
-- FROM monster_templates mt
-- JOIN creature_types ct ON mt.creature_type_id = ct.id
-- WHERE mt.environment ILIKE '%underground%'
-- ORDER BY mt.challenge_rating;

-- =====================================================
-- NOTES ON SCHEMA MAPPING
-- =====================================================
--
-- Fields mapped from SRD HTML:
-- - name: Monster name from h2/h3 heading
-- - creature_type_id: From stat block (Humanoid, Giant, Undead, Ooze, etc.)
-- - creature_subtype_ids: From parentheses after type (Goblinoid, Orc, Fire, etc.)
-- - size_category_id: From stat block (Small, Medium, Large, Huge, etc.)
-- - hit_dice_count, hit_die_size, hit_dice_bonus: From "Hit Dice:" line
--     → "4d8+11" → count=4, size=8, bonus=11
-- - challenge_rating: From "Challenge Rating:" line
-- - base_strength through base_charisma: From ability scores line
--     → Extract STR/DEX/CON/INT/WIS/CHA values
--     → "—" means NULL (undead CON, mindless INT)
-- - natural_armor_bonus: From AC breakdown
--     → "AC 16 (+5 natural)" → 5
-- - land_speed: From "Speed:" line
--     → "30 ft. (6 squares)" → 30
-- - darkvision_range: From "Special Qualities:" line
--     → "Darkvision 60 ft." → 60
-- - environment: From "Environment:" line
-- - organization: From "Organization:" line
-- - treasure_type: From "Treasure:" line
--     → none, standard, double, triple, incidental
-- - alignment: From "Alignment:" line
-- - level_adjustment: From "Level Adjustment:" line (for playable monsters)
--
-- Special abilities mapping:
-- - Extract from "Special Attacks:" and "Special Qualities:" lines
-- - Create special_abilities entries for unique abilities
-- - Link via monster_template_special_abilities junction
-- - Common abilities (Darkvision, Scent, etc.) are reused
-- - Unique abilities (Breath Weapon, Engulf, etc.) need parameters
--
-- Natural attacks mapping:
-- - Extract from "Attack:" and "Full Attack:" lines
-- - Parse attack type (slam, bite, claw, gore, etc.)
-- - Parse damage dice (1d6, 2d4+3, etc.)
-- - Create natural_attack_actions entries
-- - Link via monster_template_natural_attacks junction
--
-- Skills and feats mapping:
-- - Skills: From "Skills:" line with racial bonuses
-- - Feats: From "Feats:" line
-- - Create junction table entries
--
-- Advancement mapping:
-- - From "Advancement:" line
-- - Parse HD ranges and size changes
-- - Calculate stat adjustments for size changes
-- - Create monster_advancement_ranges entries
--
-- Edge cases:
-- - Mindless creatures: base_intelligence = NULL, 0 skill points
-- - Undead/Constructs: base_constitution = NULL
-- - Templates (Skeleton, Zombie, etc.): Applied to base creatures
-- - Class levels: Monsters with class levels use character system
-- - Spell-like abilities: Link to spells via monster_spell_like_abilities
-- - Damage reduction: Use creature_dr table from damage-reduction.sql
--
-- Import strategy:
-- 1. Import creature_type_progressions
-- 2. Import monster_templates (base stats)
-- 3. Import monster_advancement_ranges
-- 4. Create special_abilities for unique monster abilities
-- 5. Link abilities via monster_template_special_abilities
-- 6. Create natural_attack_actions
-- 7. Link attacks via monster_template_natural_attacks
-- 8. Link skills via monster_template_skills
-- 9. Link feats via monster_template_feats
-- 10. Link DR via creature_dr and dr_bypass_requirements
--
-- =====================================================
