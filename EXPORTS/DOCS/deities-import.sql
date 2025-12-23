-- =====================================================
-- DEITIES IMPORT DATA
-- D&D 3.5 SRD Deities and Domains
-- =====================================================
-- Schema: pnpo_3_5_dev
-- Target Tables: divine_ranks, pantheons, domains, deities, deity_domains,
--                domain_spells, special_abilities (via domain_granted_abilities)
-- Source: D&D 3.5 SRD (domains), Greyhawk pantheon (sample deities)
--
-- This file contains INSERT statements for importing the divine system:
-- - Divine ranks (Greater, Intermediate, Lesser, Demigod, etc.)
-- - Pantheons (groupings of related deities)
-- - Domains (divine spheres with powers and spells)
-- - Sample deities from Greyhawk pantheon
-- - Domain-deity relationships
-- - Domain powers via unified special_abilities system
--
-- Import Strategy:
-- 1. Import divine ranks (power levels)
-- 2. Import pantheons (deity groupings)
-- 3. Import core PHB domains
-- 4. Create domain granted power special_abilities
-- 5. Link domains to powers via domain_granted_abilities
-- 6. Import sample deities
-- 7. Link deities to domains via deity_domains
-- 8. Create deity relationships (allies, enemies, family)
-- 9. Import domain spells (requires spells table populated first)
-- 10. Verify via query examples
--
-- Notes:
-- - Specific deity details (Pelor, Heironeous, etc.) are NOT in SRD
-- - Using Greyhawk pantheon as commonly referenced example
-- - Domains ARE in SRD (PHB Chapter 3: Cleric class)
-- - Domain powers integrate with unified special_abilities system
-- - Domain spells require spells table to be populated first
-- =====================================================

SET search_path TO pnpo_3_5_dev;

-- =====================================================
-- DIVINE RANKS
-- =====================================================
-- Divine power levels for deities

INSERT INTO divine_ranks (name, rank_order, divine_rank_value, description)
VALUES
  ('Greater Deity', 1, 16, 'Most powerful gods with divine rank 16-20. Pelor, Heironeous (in some sources), Nerull. Have cosmic portfolios and millions of worshipers across many worlds.'),
  ('Intermediate Deity', 2, 11, 'Major gods with divine rank 11-15. Significant portfolios and widespread worship. Heironeous, St. Cuthbert, Hextor, Wee Jas, Obad-Hai.'),
  ('Lesser Deity', 3, 6, 'Minor gods with divine rank 6-10. Limited portfolios, regional worship. Many lesser gods serve greater deities.'),
  ('Demigod', 4, 1, 'Divine rank 1-5. Ascended mortals, children of gods, or very powerful outsiders. Limited divine power and worshipers.'),
  ('Quasi-Deity', 5, 0, 'Divine rank 0. Very powerful mortals (level 20+) or unique outsiders. Not true deities but can grant spells to followers.'),
  ('Hero Deity', 6, 0, 'Divine rank 0. Dead heroes worshiped as minor powers. Regional cults, limited divine abilities.')
ON CONFLICT (name) DO NOTHING;

-- =====================================================
-- PANTHEONS
-- =====================================================
-- Groups of related deities

INSERT INTO pantheons (name, pantheon_type, region_or_culture, description)
VALUES
  ('Greyhawk', 'core', 'Flanaess', 'Core D&D 3.5 pantheon from the World of Greyhawk campaign setting. Includes Pelor, Heironeous, Hextor, St. Cuthbert, Nerull, Wee Jas, Obad-Hai, Ehlonna, and many others. This is the default pantheon referenced in D&D 3.5 core books.'),
  ('Forgotten Realms', 'core', 'Faerûn', 'Faerunian pantheon from the Forgotten Realms campaign setting. Includes Mystra, Torm, Bane, Lathander, Shar, Selûne, and hundreds of others organized by race and region.'),
  ('Eberron', 'core', 'Khorvaire', 'The Sovereign Host and Dark Six from the Eberron campaign setting. Unique cosmology with absent gods and the Silver Flame.'),
  ('Dragonlance', 'core', 'Krynn', 'Gods of Good (Paladine, Mishakal), Neutrality (Gilean, Sirrion), and Evil (Takhisis, Sargonnas) from Dragonlance.'),
  ('Greek', 'historical', 'Ancient Greece', 'Historical Greek pantheon: Zeus, Athena, Apollo, Ares, Aphrodite, Poseidon, Hades, and the Olympians.'),
  ('Norse', 'historical', 'Scandinavia', 'Historical Norse pantheon: Odin, Thor, Loki, Freya, Tyr, and the Aesir and Vanir.'),
  ('Egyptian', 'historical', 'Ancient Egypt', 'Historical Egyptian pantheon: Ra, Osiris, Isis, Set, Anubis, Thoth, and the Ennead.'),
  ('Seldarine', 'racial', 'Elven communities worldwide', 'Elven pantheon led by Corellon Larethian. Includes Sehanine Moonbow, Rillifane Rallathil, and other elven deities.'),
  ('Mordinsamman', 'racial', 'Dwarven strongholds worldwide', 'Dwarven pantheon led by Moradin the Soul Forger. Includes Clangeddin, Dumathoin, and other dwarven deities.'),
  ('Yondalla''s Children', 'racial', 'Halfling communities worldwide', 'Halfling pantheon led by Yondalla the Protector. Includes Arvoreen, Brandobaris, and other halfling deities.')
ON CONFLICT (name) DO NOTHING;

-- =====================================================
-- CORE PHB DOMAINS
-- =====================================================
-- 22 core domains from PHB, providing divine powers and spell access

INSERT INTO domains (name, domain_type, description)
VALUES
  ('Air', 'core', 'Power over the element of air, wind, and flight. Granted Power: Turn or destroy earth creatures as a good cleric turns undead. Rebuke, command, or bolster air creatures as an evil cleric rebukes undead. Use these abilities a total number of times per day equal to 3 + Charisma modifier.'),
  ('Animal', 'core', 'Dominion over beasts and natural animals. Granted Power: You can use speak with animals once per day as a spell-like ability. Add Knowledge (nature) to your list of cleric class skills.'),
  ('Chaos', 'core', 'Embodiment of randomness, freedom, and disorder. Granted Power: You cast chaos spells at +1 caster level.'),
  ('Death', 'core', 'Dominion over death, undeath, and the ending of life. Granted Power: You may use a death touch once per day. Your death touch is a supernatural ability that produces a death effect. You must succeed on a melee touch attack against a living creature (using the rules for touch spells). When you touch, roll 1d6 per cleric level you possess. If the total at least equals the creature''s current hit points, it dies (no save).'),
  ('Destruction', 'core', 'Power to destroy objects and creatures. Granted Power: You gain the smite power, the supernatural ability to make a single melee attack with a +4 bonus on attack rolls and a bonus on damage rolls equal to your cleric level (if you hit). You must declare the smite before making the attack. This ability is usable once per day.'),
  ('Earth', 'core', 'Power over the element of earth, stone, and metal. Granted Power: Turn or destroy air creatures as a good cleric turns undead. Rebuke, command, or bolster earth creatures as an evil cleric rebukes undead. Use these abilities a total number of times per day equal to 3 + Charisma modifier.'),
  ('Evil', 'core', 'Embodiment of malevolence, cruelty, and wickedness. Granted Power: You cast evil spells at +1 caster level.'),
  ('Fire', 'core', 'Power over the element of fire, flame, and heat. Granted Power: Turn or destroy water creatures as a good cleric turns undead. Rebuke, command, or bolster fire creatures as an evil cleric rebukes undead. Use these abilities a total number of times per day equal to 3 + Charisma modifier.'),
  ('Good', 'core', 'Embodiment of compassion, virtue, and righteousness. Granted Power: You cast good spells at +1 caster level.'),
  ('Healing', 'core', 'Power to restore life, cure wounds, and heal ailments. Granted Power: You cast healing spells at +1 caster level.'),
  ('Knowledge', 'core', 'Domain of learning, lore, and information. Granted Power: Add all Knowledge skills to your list of cleric class skills. You cast divination spells at +1 caster level.'),
  ('Law', 'core', 'Embodiment of order, rules, and structure. Granted Power: You cast law spells at +1 caster level.'),
  ('Luck', 'core', 'Power over fortune, chance, and fate. Granted Power: You gain the power of good fortune, which is usable once per day. This extraordinary ability allows you to reroll one roll that you have just made before the DM declares whether the roll results in success or failure. You must take the result of the reroll, even if it''s worse than the original roll.'),
  ('Magic', 'core', 'Mastery of arcane and divine magic. Granted Power: Use scrolls, wands, and other devices with spell completion or spell trigger activation as a wizard of one-half your cleric level (at least 1st level). For the purpose of using a scroll or other magic device, if you are also a wizard, actual wizard levels and these effective wizard levels stack.'),
  ('Plant', 'core', 'Dominion over flora, vegetation, and plant life. Granted Power: Rebuke or command plant creatures as an evil cleric rebukes undead. Use this ability a total number of times per day equal to 3 + your Charisma modifier. This granted power is a supernatural ability. Add Knowledge (nature) to your list of cleric class skills.'),
  ('Protection', 'core', 'Power to shield, defend, and ward. Granted Power: You can generate a protective ward as a supernatural ability. Grant someone you touch a resistance bonus equal to your cleric level on his or her next saving throw. Activating this power is a standard action. The protective ward is an abjuration effect with a duration of 1 hour that is usable once per day.'),
  ('Strength', 'core', 'Physical might and prowess. Granted Power: You can perform a feat of strength as a supernatural ability. You gain an enhancement bonus to Strength equal to your cleric level. Activating the power is a free action, the power lasts 1 round, and it is usable once per day.'),
  ('Sun', 'core', 'Power of light, day, and the burning sun. Granted Power: Once per day, you can perform a greater turning against undead in place of a regular turning. The greater turning is like a normal turning except that the undead creatures that would be turned are destroyed instead.'),
  ('Travel', 'core', 'Dominion over movement, journeys, and exploration. Granted Power: For a total time per day of 1 round per cleric level you possess, you can act normally regardless of magical effects that impede movement as if you were affected by the spell freedom of movement. This effect occurs automatically as soon as it applies, lasts until it runs out or is no longer needed, and can operate multiple times per day (up to the total daily limit of rounds). This granted power is a supernatural ability. Add Survival to your list of cleric class skills.'),
  ('Trickery', 'core', 'Deception, stealth, and misdirection. Granted Power: Add Bluff, Disguise, and Hide to your list of cleric class skills.'),
  ('War', 'core', 'Battle, conflict, and martial prowess. Granted Power: Free Martial Weapon Proficiency with deity''s favored weapon (if weapon is exotic, gain Exotic Weapon Proficiency instead) and Weapon Focus with the deity''s favored weapon.'),
  ('Water', 'core', 'Power over the element of water, oceans, and rain. Granted Power: Turn or destroy fire creatures as a good cleric turns undead. Rebuke, command, or bolster water creatures as an evil cleric rebukes undead. Use these abilities a total number of times per day equal to 3 + Charisma modifier.')
ON CONFLICT (name) DO NOTHING;

-- =====================================================
-- DOMAIN GRANTED POWERS (SPECIAL ABILITIES)
-- =====================================================
-- Domain powers use the unified special_abilities system
-- These abilities are linked to domains via domain_granted_abilities junction table

-- Death Domain: Death Touch
INSERT INTO special_abilities (
  name,
  ability_type,
  is_active,
  activation_type,
  uses_per_day_formula_id,
  description,
  source_category
) VALUES (
  'Death Touch',
  'supernatural',
  true,
  'standard',
  NULL,  -- 1/day (static, not formula)
  'You may use a death touch once per day as a supernatural ability. Make a melee touch attack against a living creature. Roll 1d6 per cleric level. If the total at least equals the creature''s current hit points, it dies (no save). This is a death effect.',
  'domain'
) ON CONFLICT (name) DO NOTHING;

-- Destruction Domain: Smite
INSERT INTO special_abilities (
  name,
  ability_type,
  is_active,
  activation_type,
  uses_per_day_formula_id,
  description,
  source_category
) VALUES (
  'Destructive Smite',
  'supernatural',
  true,
  'free',
  NULL,  -- 1/day
  'Once per day, you can make a single melee attack with a +4 bonus on the attack roll and a bonus on the damage roll equal to your cleric level (if you hit). You must declare the smite before making the attack.',
  'domain'
) ON CONFLICT (name) DO NOTHING;

-- Luck Domain: Good Fortune
INSERT INTO special_abilities (
  name,
  ability_type,
  is_active,
  activation_type,
  uses_per_day_formula_id,
  description,
  source_category
) VALUES (
  'Good Fortune',
  'extraordinary',
  true,
  'free',
  NULL,  -- 1/day
  'Once per day, you can reroll one roll that you have just made before the DM declares whether the roll results in success or failure. You must take the result of the reroll, even if it''s worse than the original roll.',
  'domain'
) ON CONFLICT (name) DO NOTHING;

-- Strength Domain: Feat of Strength
INSERT INTO special_abilities (
  name,
  ability_type,
  is_active,
  activation_type,
  uses_per_day_formula_id,
  description,
  source_category
) VALUES (
  'Feat of Strength',
  'supernatural',
  true,
  'free',
  NULL,  -- 1/day
  'You gain an enhancement bonus to Strength equal to your cleric level. Activating this power is a free action, the power lasts 1 round, and it is usable once per day.',
  'domain'
) ON CONFLICT (name) DO NOTHING;

-- Sun Domain: Greater Turning
INSERT INTO special_abilities (
  name,
  ability_type,
  is_active,
  activation_type,
  uses_per_day_formula_id,
  description,
  source_category
) VALUES (
  'Greater Turning',
  'supernatural',
  true,
  'standard',
  NULL,  -- 1/day
  'Once per day, you can perform a greater turning against undead in place of a regular turning. The greater turning is like a normal turning except that the undead creatures that would be turned are destroyed instead.',
  'domain'
) ON CONFLICT (name) DO NOTHING;

-- Protection Domain: Protective Ward
INSERT INTO special_abilities (
  name,
  ability_type,
  is_active,
  activation_type,
  uses_per_day_formula_id,
  description,
  source_category
) VALUES (
  'Protective Ward',
  'supernatural',
  true,
  'standard',
  NULL,  -- 1/day
  'Grant someone you touch a resistance bonus equal to your cleric level on his or her next saving throw. This protective ward is an abjuration effect with a duration of 1 hour and is usable once per day.',
  'domain'
) ON CONFLICT (name) DO NOTHING;

-- Animal Domain: Speak with Animals
INSERT INTO special_abilities (
  name,
  ability_type,
  is_active,
  activation_type,
  uses_per_day_formula_id,
  description,
  source_category
) VALUES (
  'Speak with Animals (Domain Power)',
  'spell-like',
  true,
  'standard',
  NULL,  -- 1/day
  'You can use speak with animals once per day as a spell-like ability (caster level equal to your cleric level).',
  'domain'
) ON CONFLICT (name) DO NOTHING;

-- Travel Domain: Freedom of Movement
INSERT INTO special_abilities (
  name,
  ability_type,
  is_active,
  activation_type,
  uses_per_day_formula_id,
  description,
  source_category
) VALUES (
  'Freedom of Movement (Domain Power)',
  'supernatural',
  false,
  'passive',
  NULL,
  'For a total time per day of 1 round per cleric level, you can act normally regardless of magical effects that impede movement as if affected by freedom of movement. This effect occurs automatically, lasts until it runs out or is no longer needed, and can operate multiple times per day (up to the total daily limit).',
  'domain'
) ON CONFLICT (name) DO NOTHING;

-- Link domain powers to domains via domain_granted_abilities junction table
-- This is defined in special_abilities.sql (domain_granted_abilities table)
-- Sample linking (execute after both domains and special_abilities exist):

-- INSERT INTO domain_granted_abilities (domain_id, special_ability_id, granted_at_level, notes)
-- VALUES
--   ((SELECT id FROM domains WHERE name = 'Death'),
--    (SELECT id FROM special_abilities WHERE name = 'Death Touch'), 1, '1/day, 1d6 per cleric level'),
--   ((SELECT id FROM domains WHERE name = 'Destruction'),
--    (SELECT id FROM special_abilities WHERE name = 'Destructive Smite'), 1, '1/day, +4 attack, +cleric level damage'),
--   ((SELECT id FROM domains WHERE name = 'Luck'),
--    (SELECT id FROM special_abilities WHERE name = 'Good Fortune'), 1, '1/day reroll'),
--   ((SELECT id FROM domains WHERE name = 'Strength'),
--    (SELECT id FROM special_abilities WHERE name = 'Feat of Strength'), 1, '1/day, +cleric level STR for 1 round'),
--   ((SELECT id FROM domains WHERE name = 'Sun'),
--    (SELECT id FROM special_abilities WHERE name = 'Greater Turning'), 1, '1/day, destroy instead of turn'),
--   ((SELECT id FROM domains WHERE name = 'Protection'),
--    (SELECT id FROM special_abilities WHERE name = 'Protective Ward'), 1, '1/day, +cleric level resistance bonus'),
--   ((SELECT id FROM domains WHERE name = 'Animal'),
--    (SELECT id FROM special_abilities WHERE name = 'Speak with Animals (Domain Power)'), 1, '1/day spell-like ability'),
--   ((SELECT id FROM domains WHERE name = 'Travel'),
--    (SELECT id FROM special_abilities WHERE name = 'Freedom of Movement (Domain Power)'), 1, '1 round/level per day');

-- =====================================================
-- SAMPLE DEITIES (GREYHAWK PANTHEON)
-- =====================================================
-- 5 example deities with complete data

-- Deity 1: PELOR - Greater Deity of Sun, Light, Strength, Healing
INSERT INTO deities (
  name,
  title,
  divine_rank_id,
  alignment,
  portfolio,
  holy_symbol,
  favored_weapon_id,
  worshiper_alignments,
  description,
  dogma,
  clergy_and_temples,
  is_core_deity
) VALUES (
  'Pelor',
  'The Shining One',
  (SELECT id FROM divine_ranks WHERE name = 'Greater Deity'),
  'NG',
  'Sun, light, strength, healing',
  'Sun face (radiant sun with a smiling face)',
  (SELECT id FROM weapons WHERE name = 'Heavy Mace'),
  ARRAY['LG', 'NG', 'CG', 'LN', 'TN', 'CN'],
  'Pelor is the god of the sun, light, strength, and healing. He is widely worshiped by common folk, especially farmers and those who depend on the sun. He is also revered by paladins who champion the cause of good. Pelor is one of the most popular and widely worshiped gods in the D&D multiverse. He opposes all forms of evil, but his special enemies are the undead and creatures of darkness.',
  'The light of the sun brings life, warmth, and growth to the world. All living things depend on Pelor''s light. His clergy teach that strength used in the service of righteousness is the greatest gift mortals can give. Evil and darkness must be opposed wherever they appear. The sick must be healed, the weak must be strengthened, and the dead must be honored by destroying undead abominations. Pelor''s faithful are encouraged to show kindness, alleviate suffering, and bring hope to the downtrodden.',
  'Pelor''s temples are usually tall structures with many windows to let in natural light. They are commonly built on hilltops or high ground where the sun''s rays reach them first each morning. His clergy wear white and gold robes and are known for their charitable works, healing the sick and aiding communities in need. The church of Pelor is one of the largest in the world, with temples in almost every civilized land. Many paladins and clerics of Pelor undertake quests to root out evil and destroy undead.',
  true
);

-- Deity 2: HEIRONEOUS - Intermediate Deity of Valor, Chivalry, Justice
INSERT INTO deities (
  name,
  title,
  divine_rank_id,
  alignment,
  portfolio,
  holy_symbol,
  favored_weapon_id,
  worshiper_alignments,
  description,
  dogma,
  clergy_and_temples,
  is_core_deity
) VALUES (
  'Heironeous',
  'The Invincible',
  (SELECT id FROM divine_ranks WHERE name = 'Intermediate Deity'),
  'LG',
  'Valor, chivalry, justice, honor, war, daring',
  'Lightning bolt',
  (SELECT id FROM weapons WHERE name = 'Longsword'),
  ARRAY['LG', 'NG', 'LN'],
  'Heironeous is the god of valor, chivalry, justice, honor, war, and daring. He is the patron of paladins and honorable warriors who fight for righteous causes. He is the eternal enemy of his half-brother Hextor, the god of tyranny and war. Heironeous promotes justice, valor, chivalry, and honor. He urges his followers to uphold the highest ideals of chivalry and to defend the weak and innocent.',
  'The world is a dangerous place where those who fight for justice and righteousness must be ever vigilant. Ware must be met with steel. Uphold the virtues of valor, chivalry, and honor in all that you do. Defend the weak and innocent with your life. Oppose tyranny and oppression wherever you find them. Be brave, be just, and be merciful to the vanquished. The warrior who fights with honor brings glory to Heironeous.',
  'Temples of Heironeous are often fortress-like structures that also serve as training grounds for warriors and paladins. His clergy are warriors first and foremost, training constantly in martial skills. Many are paladins or fighter/clerics. The church of Heironeous is militant and organized, with a strict hierarchy modeled on military ranks. Priests of Heironeous often lead crusades against evil and serve as battlefield chaplains for armies of good.',
  true
);

-- Deity 3: HEXTOR - Intermediate Deity of Tyranny, War, Discord
INSERT INTO deities (
  name,
  title,
  divine_rank_id,
  alignment,
  portfolio,
  holy_symbol,
  favored_weapon_id,
  worshiper_alignments,
  description,
  dogma,
  clergy_and_temples,
  is_core_deity
) VALUES (
  'Hextor',
  'Champion of Evil, The Herald of Hell',
  (SELECT id FROM divine_ranks WHERE name = 'Intermediate Deity'),
  'LE',
  'War, discord, massacres, conflict, fitness, tyranny',
  'Six arrows facing downward (fist with six arrows)',
  (SELECT id FROM weapons WHERE name = 'Flail'),
  ARRAY['LE', 'NE', 'LN'],
  'Hextor is the god of tyranny, war, discord, massacres, conflict, and fitness. He is the half-brother and eternal enemy of Heironeous, the god of valor. Hextor promotes the rule of the strong over the weak and teaches that might makes right. He is worshiped by evil fighters, tyrants, and those who seek power through strength and domination. His symbol of six arrows represents his six attributes: tyranny, war, discord, massacres, conflict, and fitness.',
  'The world belongs to the strong. The weak exist to serve the strong. Might makes right, and the strongest should rule. Use your strength to dominate others and spread fear. Order through tyranny is the highest virtue. Crush your enemies utterly and show no mercy. Chaos and disorder are weaknesses - impose rigid order through force. Train constantly to become stronger, for only the fit deserve to survive. Hextor rewards those who use their strength to oppress others.',
  'Temples of Hextor are dark, forbidding fortresses where the weak are not welcome. His clergy are militant and ruthless, often leading armies of conquest or serving as the iron fist of tyrannical rulers. The church is strictly hierarchical, with advancement based on strength and success in battle. Priests of Hextor train in martial combat and are expected to be powerful warriors. Many are blackguards or fighter/clerics who use their power to dominate the weak.',
  true
);

-- Deity 4: ST. CUTHBERT - Intermediate Deity of Retribution, Honesty, Zeal
INSERT INTO deities (
  name,
  title,
  divine_rank_id,
  alignment,
  portfolio,
  holy_symbol,
  favored_weapon_id,
  worshiper_alignments,
  description,
  dogma,
  clergy_and_temples,
  is_core_deity
) VALUES (
  'St. Cuthbert',
  'St. Cuthbert of the Cudgel',
  (SELECT id FROM divine_ranks WHERE name = 'Intermediate Deity'),
  'LN',
  'Retribution, honesty, truth, zeal, justice, discipline',
  'Wooden club bound in bronze (or a starburst of rubies)',
  (SELECT id FROM weapons WHERE name = 'Heavy Mace'),
  ARRAY['LG', 'LN', 'LE'],
  'St. Cuthbert is the god of retribution, honesty, truth, and zeal. He exacts justice and maintains the balance of law in the world. He is stern and unforgiving, quick to punish those who stray from righteousness but equally quick to reward the faithful. St. Cuthbert brooks no moral ambiguity - you are either with him or against him. He is worshiped by those who value law, honesty, and retribution, and his faithful are known for their uncompromising zeal.',
  'Honesty, truth, and righteousness are the highest virtues. Chaos and evil must be opposed with discipline and retribution. Those who transgress must be punished swiftly and appropriately. Never tell a lie or allow dishonesty to stand unchallenged. Uphold the law and maintain order. Be zealous in your pursuit of justice, but temper zeal with wisdom. Tolerate no deviation from righteousness - those who stray must be brought back to the path, by force if necessary. St. Cuthbert rewards the honest and the disciplined.',
  'St. Cuthbert''s temples are stern, austere buildings that emphasize discipline and order. His clergy are known for their uncompromising adherence to law and their fierce zeal in punishing wrongdoers. They often serve as judges, lawkeepers, and investigators of corruption. The church is hierarchical and well-organized, with strict rules governing conduct. Priests of St. Cuthbert carry the cudgel (heavy mace) as a symbol of their authority to mete out retribution. They are respected and feared in equal measure.',
  true
);

-- Deity 5: NERULL - Greater Deity of Death, Darkness, Murder
INSERT INTO deities (
  name,
  title,
  divine_rank_id,
  alignment,
  portfolio,
  holy_symbol,
  favored_weapon_id,
  worshiper_alignments,
  description,
  dogma,
  clergy_and_temples,
  is_core_deity
) VALUES (
  'Nerull',
  'The Reaper, The Foe of All Good, The Hater of Life',
  (SELECT id FROM divine_ranks WHERE name = 'Greater Deity'),
  'NE',
  'Death, darkness, murder, the underworld',
  'Skull and scythe',
  (SELECT id FROM weapons WHERE name = 'Scythe'),
  ARRAY['LE', 'NE', 'CE'],
  'Nerull is the god of death, darkness, murder, and the underworld. He is one of the most feared and hated of all deities. Nerull delights in death and suffering, and he encourages his followers to spread fear and death wherever they go. He is the patron of necromancers, assassins, and those who traffic with the undead. Nerull is the enemy of all life-giving deities, especially Pelor. His ultimate goal is to extinguish all life in the multiverse.',
  'Death is the only certainty. Life is a fleeting illusion that must be extinguished. Embrace the darkness and the cold finality of death. Kill without mercy or remorse. Create undead to serve you and spread the dominion of death. Fear is a weapon - use it to control the living. The strong should hasten the weak to their inevitable end. Nerull rewards those who bring death to the living and who create lasting monuments to mortality through undeath. All things must die, and it is your sacred duty to ensure they do.',
  'Nerull''s temples are hidden places of darkness, often underground tombs or abandoned crypts. His clergy are secretive and feared, practicing dark rituals and creating undead servants. Many are necromancers or clerics who rebuke undead rather than turn them. The church of Nerull operates in the shadows, for few civilized lands tolerate open worship of the Reaper. His priests often serve as assassins, undertakers, or keepers of crypts. They wear black robes and skull masks, and they spread fear wherever they go.',
  true
);

-- =====================================================
-- DEITY-PANTHEON MEMBERSHIP
-- =====================================================

INSERT INTO deity_pantheons (deity_id, pantheon_id, prominence, role_in_pantheon)
VALUES
  ((SELECT id FROM deities WHERE name = 'Pelor'),
   (SELECT id FROM pantheons WHERE name = 'Greyhawk'),
   'major',
   'One of the most widely worshiped gods, patron of light and healing'),

  ((SELECT id FROM deities WHERE name = 'Heironeous'),
   (SELECT id FROM pantheons WHERE name = 'Greyhawk'),
   'major',
   'Champion of good and law, eternal enemy of Hextor'),

  ((SELECT id FROM deities WHERE name = 'Hextor'),
   (SELECT id FROM pantheons WHERE name = 'Greyhawk'),
   'major',
   'Champion of evil and tyranny, eternal enemy of Heironeous'),

  ((SELECT id FROM deities WHERE name = 'St. Cuthbert'),
   (SELECT id FROM pantheons WHERE name = 'Greyhawk'),
   'major',
   'God of retribution and zeal, enforcer of law'),

  ((SELECT id FROM deities WHERE name = 'Nerull'),
   (SELECT id FROM pantheons WHERE name = 'Greyhawk'),
   'major',
   'God of death and the underworld, enemy of all life');

-- =====================================================
-- DEITY RELATIONSHIPS
-- =====================================================

-- Heironeous and Hextor: Sibling rivalry, eternal enemies
INSERT INTO deity_relationships (deity_id, related_deity_id, relationship_type, description)
VALUES
  ((SELECT id FROM deities WHERE name = 'Heironeous'),
   (SELECT id FROM deities WHERE name = 'Hextor'),
   'sibling',
   'Half-brothers who represent opposing philosophies of good vs evil'),

  ((SELECT id FROM deities WHERE name = 'Heironeous'),
   (SELECT id FROM deities WHERE name = 'Hextor'),
   'enemy',
   'Eternal enemies representing valor vs tyranny, justice vs oppression'),

  ((SELECT id FROM deities WHERE name = 'Hextor'),
   (SELECT id FROM deities WHERE name = 'Heironeous'),
   'sibling',
   'Half-brothers locked in eternal conflict'),

  ((SELECT id FROM deities WHERE name = 'Hextor'),
   (SELECT id FROM deities WHERE name = 'Heironeous'),
   'enemy',
   'Seeks to destroy his brother and all he represents');

-- Pelor and Heironeous: Allies in good
INSERT INTO deity_relationships (deity_id, related_deity_id, relationship_type, description)
VALUES
  ((SELECT id FROM deities WHERE name = 'Pelor'),
   (SELECT id FROM deities WHERE name = 'Heironeous'),
   'ally',
   'Both champion goodness, light, and justice against darkness'),

  ((SELECT id FROM deities WHERE name = 'Heironeous'),
   (SELECT id FROM deities WHERE name = 'Pelor'),
   'ally',
   'United in opposition to evil and tyranny');

-- Pelor and Nerull: Enemies (life vs death)
INSERT INTO deity_relationships (deity_id, related_deity_id, relationship_type, description)
VALUES
  ((SELECT id FROM deities WHERE name = 'Pelor'),
   (SELECT id FROM deities WHERE name = 'Nerull'),
   'enemy',
   'Light and life versus death and darkness - eternal opposition'),

  ((SELECT id FROM deities WHERE name = 'Nerull'),
   (SELECT id FROM deities WHERE name = 'Pelor'),
   'enemy',
   'The Reaper seeks to extinguish the light of the sun');

-- Hextor and Nerull: Allies in evil
INSERT INTO deity_relationships (deity_id, related_deity_id, relationship_type, description)
VALUES
  ((SELECT id FROM deities WHERE name = 'Hextor'),
   (SELECT id FROM deities WHERE name = 'Nerull'),
   'ally',
   'Both serve the cause of evil, though their methods differ'),

  ((SELECT id FROM deities WHERE name = 'Nerull'),
   (SELECT id FROM deities WHERE name = 'Hextor'),
   'ally',
   'United against the forces of good and life');

-- =====================================================
-- DEITY DOMAINS
-- =====================================================
-- Links deities to the domains they offer to their clerics

-- Pelor: Good, Healing, Strength, Sun (primary: Healing, Sun)
INSERT INTO deity_domains (deity_id, domain_id, is_primary, notes)
VALUES
  ((SELECT id FROM deities WHERE name = 'Pelor'),
   (SELECT id FROM domains WHERE name = 'Good'), false, NULL),

  ((SELECT id FROM deities WHERE name = 'Pelor'),
   (SELECT id FROM domains WHERE name = 'Healing'), true, 'Primary domain - Pelor is the greatest healer'),

  ((SELECT id FROM deities WHERE name = 'Pelor'),
   (SELECT id FROM domains WHERE name = 'Strength'), false, NULL),

  ((SELECT id FROM deities WHERE name = 'Pelor'),
   (SELECT id FROM domains WHERE name = 'Sun'), true, 'Primary domain - Pelor is the sun god');

-- Heironeous: Good, Law, War (primary: Good, War)
INSERT INTO deity_domains (deity_id, domain_id, is_primary, notes)
VALUES
  ((SELECT id FROM deities WHERE name = 'Heironeous'),
   (SELECT id FROM domains WHERE name = 'Good'), true, 'Primary domain - champion of good'),

  ((SELECT id FROM deities WHERE name = 'Heironeous'),
   (SELECT id FROM domains WHERE name = 'Law'), false, NULL),

  ((SELECT id FROM deities WHERE name = 'Heironeous'),
   (SELECT id FROM domains WHERE name = 'War'), true, 'Primary domain - god of just warfare');

-- Hextor: Evil, Law, War, Destruction (primary: Evil, War)
INSERT INTO deity_domains (deity_id, domain_id, is_primary, notes)
VALUES
  ((SELECT id FROM deities WHERE name = 'Hextor'),
   (SELECT id FROM domains WHERE name = 'Evil'), true, 'Primary domain - champion of evil'),

  ((SELECT id FROM deities WHERE name = 'Hextor'),
   (SELECT id FROM domains WHERE name = 'Law'), false, 'Order through tyranny'),

  ((SELECT id FROM deities WHERE name = 'Hextor'),
   (SELECT id FROM domains WHERE name = 'War'), true, 'Primary domain - god of tyrannical warfare'),

  ((SELECT id FROM deities WHERE name = 'Hextor'),
   (SELECT id FROM domains WHERE name = 'Destruction'), false, NULL);

-- St. Cuthbert: Law, Protection, Strength, Destruction (primary: Law)
INSERT INTO deity_domains (deity_id, domain_id, is_primary, notes)
VALUES
  ((SELECT id FROM deities WHERE name = 'St. Cuthbert'),
   (SELECT id FROM domains WHERE name = 'Law'), true, 'Primary domain - enforcer of order'),

  ((SELECT id FROM deities WHERE name = 'St. Cuthbert'),
   (SELECT id FROM domains WHERE name = 'Protection'), false, NULL),

  ((SELECT id FROM deities WHERE name = 'St. Cuthbert'),
   (SELECT id FROM domains WHERE name = 'Strength'), false, NULL),

  ((SELECT id FROM deities WHERE name = 'St. Cuthbert'),
   (SELECT id FROM domains WHERE name = 'Destruction'), false, 'Retribution against wrongdoers');

-- Nerull: Death, Evil, Trickery (primary: Death, Evil)
INSERT INTO deity_domains (deity_id, domain_id, is_primary, notes)
VALUES
  ((SELECT id FROM deities WHERE name = 'Nerull'),
   (SELECT id FROM domains WHERE name = 'Death'), true, 'Primary domain - the Reaper'),

  ((SELECT id FROM deities WHERE name = 'Nerull'),
   (SELECT id FROM domains WHERE name = 'Evil'), true, 'Primary domain - foe of all good'),

  ((SELECT id FROM deities WHERE name = 'Nerull'),
   (SELECT id FROM domains WHERE name = 'Trickery'), false, 'Deception and stealth in spreading death');

-- =====================================================
-- DOMAIN SPELLS (SAMPLE)
-- =====================================================
-- Each domain grants bonus spells at each spell level
-- NOTE: Requires spells table to be populated first
-- Full domain spell lists should be imported after spells are loaded

-- Sample: Death domain spell list (spell level 1-9)
-- INSERT INTO domain_spells (domain_id, spell_id, spell_level)
-- VALUES
--   ((SELECT id FROM domains WHERE name = 'Death'),
--    (SELECT id FROM spells WHERE name = 'Cause Fear'), 1),
--   ((SELECT id FROM domains WHERE name = 'Death'),
--    (SELECT id FROM spells WHERE name = 'Death Knell'), 2),
--   ((SELECT id FROM domains WHERE name = 'Death'),
--    (SELECT id FROM spells WHERE name = 'Animate Dead'), 3),
--   ((SELECT id FROM domains WHERE name = 'Death'),
--    (SELECT id FROM spells WHERE name = 'Death Ward'), 4),
--   ((SELECT id FROM domains WHERE name = 'Death'),
--    (SELECT id FROM spells WHERE name = 'Slay Living'), 5),
--   ((SELECT id FROM domains WHERE name = 'Death'),
--    (SELECT id FROM spells WHERE name = 'Create Undead'), 6),
--   ((SELECT id FROM domains WHERE name = 'Death'),
--    (SELECT id FROM spells WHERE name = 'Destruction'), 7),
--   ((SELECT id FROM domains WHERE name = 'Death'),
--    (SELECT id FROM spells WHERE name = 'Create Greater Undead'), 8),
--   ((SELECT id FROM domains WHERE name = 'Death'),
--    (SELECT id FROM spells WHERE name = 'Wail of the Banshee'), 9);

-- Sample: War domain spell list
-- INSERT INTO domain_spells (domain_id, spell_id, spell_level)
-- VALUES
--   ((SELECT id FROM domains WHERE name = 'War'),
--    (SELECT id FROM spells WHERE name = 'Magic Weapon'), 1),
--   ((SELECT id FROM domains WHERE name = 'War'),
--    (SELECT id FROM spells WHERE name = 'Spiritual Weapon'), 2),
--   ((SELECT id FROM domains WHERE name = 'War'),
--    (SELECT id FROM spells WHERE name = 'Magic Vestment'), 3),
--   ((SELECT id FROM domains WHERE name = 'War'),
--    (SELECT id FROM spells WHERE name = 'Divine Power'), 4),
--   ((SELECT id FROM domains WHERE name = 'War'),
--    (SELECT id FROM spells WHERE name = 'Flame Strike'), 5),
--   ((SELECT id FROM domains WHERE name = 'War'),
--    (SELECT id FROM spells WHERE name = 'Blade Barrier'), 6),
--   ((SELECT id FROM domains WHERE name = 'War'),
--    (SELECT id FROM spells WHERE name = 'Power Word Blind'), 7),
--   ((SELECT id FROM domains WHERE name = 'War'),
--    (SELECT id FROM spells WHERE name = 'Power Word Stun'), 8),
--   ((SELECT id FROM domains WHERE name = 'War'),
--    (SELECT id FROM spells WHERE name = 'Power Word Kill'), 9);

-- =====================================================
-- QUERY EXAMPLES
-- =====================================================

-- Get complete deity information with domains:
-- SELECT
--   d.name,
--   d.title,
--   dr.name AS divine_rank,
--   d.alignment,
--   d.portfolio,
--   d.holy_symbol,
--   w.name AS favored_weapon,
--   STRING_AGG(dom.name, ', ' ORDER BY dom.name) AS domains
-- FROM deities d
-- JOIN divine_ranks dr ON d.divine_rank_id = dr.id
-- LEFT JOIN weapons w ON d.favored_weapon_id = w.id
-- LEFT JOIN deity_domains dd ON d.id = dd.deity_id
-- LEFT JOIN domains dom ON dd.domain_id = dom.id
-- WHERE d.name = 'Pelor'
-- GROUP BY d.id, d.name, d.title, dr.name, d.alignment, d.portfolio, d.holy_symbol, w.name;

-- Get all deities in Greyhawk pantheon:
-- SELECT
--   d.name,
--   d.title,
--   dr.name AS divine_rank,
--   d.alignment,
--   d.portfolio,
--   dp.prominence
-- FROM deities d
-- JOIN divine_ranks dr ON d.divine_rank_id = dr.id
-- JOIN deity_pantheons dp ON d.id = dp.deity_id
-- JOIN pantheons p ON dp.pantheon_id = p.id
-- WHERE p.name = 'Greyhawk'
-- ORDER BY dr.rank_order, dp.prominence, d.name;

-- Find all deities offering War domain:
-- SELECT
--   d.name,
--   d.alignment,
--   d.portfolio,
--   dd.is_primary,
--   STRING_AGG(dom.name, ', ' ORDER BY dom.name) AS all_domains
-- FROM deities d
-- JOIN deity_domains dd ON d.id = dd.deity_id
-- JOIN domains dom ON dd.domain_id = dom.id
-- WHERE dd.domain_id = (SELECT id FROM domains WHERE name = 'War')
-- GROUP BY d.name, d.alignment, d.portfolio, dd.is_primary
-- ORDER BY d.name;

-- List deities suitable for lawful good character:
-- SELECT
--   d.name,
--   d.title,
--   d.alignment AS deity_alignment,
--   d.portfolio,
--   STRING_AGG(DISTINCT dom.name, ', ' ORDER BY dom.name) AS available_domains
-- FROM deities d
-- LEFT JOIN deity_domains dd ON d.id = dd.deity_id
-- LEFT JOIN domains dom ON dd.domain_id = dom.id
-- WHERE 'LG' = ANY(d.worshiper_alignments)
-- GROUP BY d.id, d.name, d.title, d.alignment, d.portfolio
-- ORDER BY d.name;

-- Get deity relationships:
-- SELECT
--   d1.name AS deity,
--   dr.relationship_type,
--   d2.name AS related_deity,
--   dr.description
-- FROM deity_relationships dr
-- JOIN deities d1 ON dr.deity_id = d1.id
-- JOIN deities d2 ON dr.related_deity_id = d2.id
-- WHERE d1.name = 'Heironeous'
-- ORDER BY dr.relationship_type;

-- Get domain details with granted power:
-- SELECT
--   dom.name AS domain,
--   dom.description,
--   sa.name AS power_name,
--   sa.ability_type,
--   sa.activation_type,
--   sa.description AS power_description
-- FROM domains dom
-- LEFT JOIN domain_granted_abilities dga ON dom.id = dga.domain_id
-- LEFT JOIN special_abilities sa ON dga.special_ability_id = sa.id
-- WHERE dom.name = 'Death';

-- =====================================================
-- SCHEMA MAPPING FROM SRD TO DATABASE
-- =====================================================
--
-- DEITIES TABLE MAPPING:
-- Conceptual Field        → Database Column           → Example
-- -------------------------------------------------------------------
-- Deity Name              → deities.name              → 'Pelor'
-- Title/Epithet           → title                     → 'The Shining One'
-- Power Level             → divine_rank_id            → Greater Deity (FK)
-- Alignment               → alignment                 → 'NG'
-- Portfolio               → portfolio                 → 'Sun, light, strength, healing'
-- Holy Symbol             → holy_symbol               → 'Sun face'
-- Favored Weapon          → favored_weapon_id         → Heavy Mace (FK)
-- Worshiper Alignments    → worshiper_alignments      → ARRAY['LG','NG','CG','LN','TN','CN']
-- Description             → description               → TEXT
-- Dogma                   → dogma                     → TEXT
-- Clergy Info             → clergy_and_temples        → TEXT
--
-- DEITY_DOMAINS TABLE MAPPING:
-- Conceptual Field        → Database Column           → Example
-- -------------------------------------------------------------------
-- Deity → Domain link     → deity_id + domain_id      → Pelor → Healing domain
-- Primary Domain          → is_primary                → true (for Healing, Sun)
-- Notes                   → notes                     → 'Primary domain - Pelor is sun god'
--
-- DOMAINS TABLE MAPPING:
-- SRD Field               → Database Column           → Example
-- -------------------------------------------------------------------
-- Domain Name             → domains.name              → 'Death'
-- Domain Type             → domain_type               → 'core' (from PHB)
-- Granted Power           → description               → TEXT (full description)
--
-- DOMAIN POWERS MAPPING (via special_abilities):
-- SRD Field               → Database Column           → Example
-- -------------------------------------------------------------------
-- Power Name              → special_abilities.name    → 'Death Touch'
-- Power Type              → ability_type              → 'supernatural'
-- Activation              → activation_type           → 'standard'
-- Uses per Day            → uses_per_day_formula_id   → NULL (static 1/day)
-- Description             → description               → 'Roll 1d6 per cleric level...'
-- Source                  → source_category           → 'domain'
--
-- INTEGRATION WITH OTHER SYSTEMS:
-- - Domain powers: Link via domain_granted_abilities → special_abilities
-- - Domain spells: Link via domain_spells → spells
-- - Deity weapons: Link via favored_weapon_id → weapons
-- - Character deities: Link via characters.deity_id → deities
-- - Character domains: Link via character_domains → domains
--
-- =====================================================
-- IMPORT STRATEGY NOTES
-- =====================================================
--
-- 1. Prerequisites:
--    - Import weapons first (for favored_weapon_id FK)
--    - Import spells first (for domain_spells)
--    - special_abilities table must exist
--    - Junction tables must exist (domain_granted_abilities, deity_domains)
--
-- 2. Import Order:
--    a. divine_ranks (power levels)
--    b. pantheons (deity groupings)
--    c. domains (divine spheres)
--    d. special_abilities (domain powers)
--    e. domain_granted_abilities (link domains to powers)
--    f. deities (gods themselves)
--    g. deity_domains (link deities to domains)
--    h. deity_pantheons (link deities to pantheons)
--    i. deity_relationships (allies, enemies, family)
--    j. domain_spells (requires spells imported first)
--
-- 3. Verification:
--    - Query each deity to ensure all domains are linked
--    - Verify domain powers are accessible
--    - Check that relationships are bidirectional where appropriate
--    - Ensure worshiper_alignments arrays are valid
--
-- 4. Remaining Content:
--    Follow the same pattern for:
--    - Other Greyhawk deities (Obad-Hai, Ehlonna, Wee Jas, etc.)
--    - Racial pantheons (Seldarine for elves, Mordinsamman for dwarves)
--    - Other campaign pantheons (Forgotten Realms, Eberron, etc.)
--    - Additional domains from supplemental books
--    - Complete domain spell lists for all 22 core domains
--
-- =====================================================
-- END OF DEITIES IMPORT DATA
-- =====================================================
