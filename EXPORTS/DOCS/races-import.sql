-- =====================================================
-- RACES IMPORT DATA
-- D&D 3.5 SRD Character Races
-- =====================================================
-- Schema: pnpo_3_5_dev
-- Target Tables: races, race_ability_adjustments, special_abilities (via race_granted_abilities)
-- Source: D&D 3.5 SRD basic-rules-and-legal/races.html
--
-- This file contains INSERT statements for importing the 7 core SRD character races
-- into the normalized races system. Each race includes:
-- - Core race data (size, speed, type, favored class)
-- - Ability score adjustments
-- - Racial traits linked via the unified special_abilities system
--
-- Import Strategy:
-- 1. Import prerequisite reference data (size_categories if needed)
-- 2. Import races into races table
-- 3. Import race_ability_adjustments for ability score modifiers
-- 4. Create racial trait special_abilities entries
-- 5. Link traits to races via race_granted_abilities junction table
-- 6. Verify via query examples at end of file
--
-- Notes:
-- - Racial languages handled in languages.sql (race_languages table)
-- - Favored class uses FK to classes table (import classes first)
-- - Racial traits use same special_abilities system as class/monster abilities
-- - Integration with effects, skills, feats for mechanical benefits
-- =====================================================

SET search_path TO pnpo_3_5_dev;

-- =====================================================
-- PREREQUISITE REFERENCE DATA
-- =====================================================

-- Size Categories (if not already imported)
-- Typically imported in srd-reference-tables.sql, included here for completeness

INSERT INTO size_categories (name, ac_size_modifier, grapple_modifier, hide_modifier, carrying_capacity_multiplier)
VALUES
  ('Fine', 8, -16, 16, 0.125),
  ('Diminutive', 4, -12, 12, 0.25),
  ('Tiny', 2, -8, 8, 0.50),
  ('Small', 1, -4, 4, 0.75),
  ('Medium', 0, 0, 0, 1.0),
  ('Large', -1, 4, -4, 2.0),
  ('Huge', -2, 8, -8, 4.0),
  ('Gargantuan', -4, 12, -12, 8.0),
  ('Colossal', -8, 16, -16, 16.0)
ON CONFLICT (name) DO NOTHING;

-- =====================================================
-- CORE RACES TABLE
-- =====================================================
-- 5 Example Races: Human, Dwarf, Elf, Halfling, Half-Orc
-- (Gnome and Half-Elf omitted for brevity, follow same pattern)
-- =====================================================

-- Race 1: HUMAN
-- Medium Humanoid (Human), 30 ft speed, no ability adjustments
-- Favored Class: Any (represented as NULL in FK)
-- Traits: Bonus feat, extra skill points (handled via special_abilities)

INSERT INTO races (
  name,
  size_category_id,
  base_speed,
  creature_type,
  creature_subtype,
  favored_class_id,
  description,
  personality,
  physical_description,
  relations,
  alignment,
  lands,
  religion,
  names,
  adventurers
) VALUES (
  'Human',
  (SELECT id FROM size_categories WHERE name = 'Medium'),
  30,
  'Humanoid',
  'Human',
  NULL,  -- Favored Class: Any (no penalty for multiclassing)
  'Humans are the most adaptable, flexible, and ambitious people among the common races. They are diverse in their tastes, morals, customs, and habits.',
  'Humans are the most adaptable, flexible, and ambitious among common races. Short-lived compared to dwarves, elves, and gnomes, humans have a drive to achieve great things in their lifetimes.',
  'Humans typically stand from 5 feet to a little over 6 feet tall and weigh from 125 to 250 pounds, with men noticeably taller and heavier than women. Thanks to their penchant for migration and conquest, and to their short lifespans, humans are more physically diverse than other common races. Their skin ranges from nearly black to very pale, their hair from black to blond (curly, kinky, or straight), and facial hair (for men) from sparse to thick. Plenty of humans have a dash of nonhuman blood, and they may demonstrate hints of elf, orc, or other lineages. Humans are often ostentatious or unorthodox in their grooming and dress, sporting unusual hairstyles, fanciful clothes, tattoos, body piercings, and the like. Humans have short life spans, reaching adulthood at about age 15 and rarely living even a single century.',
  'Just as readily as they mix with each other, humans mingle with members of other races. They get along with almost everyone, though they might not be close to many. Humans serve as ambassadors, diplomats, magistrates, merchants, and functionaries of all kinds.',
  'Usually neutral. Humans tend toward no particular alignment, not even neutrality.',
  'Human lands are usually in flux, with new ideas, social changes, innovations, and new leaders constantly coming to the fore. Members of longer-lived races find human culture exciting but eventually a bit wearying or even bewildering.',
  'Unlike members of most other races, humans worship no racial pantheon. Some humans are the most ardent and zealous adherents of a given religion, while others are the most impious people around.',
  'Human names vary greatly. Without a unifying deity to give them a touchstone for their culture, and with such fast-breeding cycles, humans mutate socially at a fast rate. Human culture, therefore, is more diverse than other cultures, and no human names are truly typical. Some human parents give their children dwarven or elven names (pronounced more or less correctly).',
  'Human adventurers are the most audacious, daring, and ambitious members of an audacious, daring, and ambitious race. A human can earn glory in the eyes of her fellows by amassing power, wealth, and fame. Humans, more than other people, champion causes rather than territories or groups.'
);

-- Race 2: DWARF
-- Medium Humanoid (Dwarf), 20 ft speed, +2 CON/-2 CHA
-- Favored Class: Fighter
-- Traits: Darkvision, Stonecunning, Weapon Familiarity, Stability, saves, combat bonuses

INSERT INTO races (
  name,
  size_category_id,
  base_speed,
  creature_type,
  creature_subtype,
  favored_class_id,
  description,
  personality,
  physical_description,
  relations,
  alignment,
  lands,
  religion,
  names,
  adventurers
) VALUES (
  'Dwarf',
  (SELECT id FROM size_categories WHERE name = 'Medium'),
  20,
  'Humanoid',
  'Dwarf',
  (SELECT id FROM classes WHERE name = 'Fighter'),
  'Dwarves are known for their skill in warfare, their ability to withstand physical and magical punishment, their knowledge of the earth''s secrets, their hard work, and their capacity for drinking ale. Their kingdoms, carved out from the hearts of mountains, are renowned for the marvelous treasures that they produce as gifts or for trade.',
  'Dwarves are slow to jest and suspicious of strangers, but they are generous to those who earn their trust. They value gold, gems, jewelry, and art objects made from these materials, and they have been known to succumb to greed. They fight neither recklessly nor timidly, but with a careful courage and tenacity. Their sense of justice is strong, but at its worst it can turn into a thirst for vengeance. Among gnomes, who get along famously with dwarves, a mild oath is "If I''m lying, may I cross a dwarf."',
  'Dwarves stand only 4 to 4½ feet tall, but they are so broad and compact that they are, on average, almost as heavy as humans. Dwarven men are slightly taller and noticeably heavier than dwarven women. Dwarves'' skin is typically deep tan or light brown, and their eyes are dark. Their hair is usually black, gray, or brown, and worn long. Dwarven men value their beards highly and groom them very carefully. Dwarves favor simple styles for their hair, beards, and clothes. Dwarves are considered adults at about age 40, and they can live to be more than 400 years old.',
  'Dwarves get along fine with gnomes, and passably with humans, half-elves, and halflings. Dwarves say, "The difference between an acquaintance and a friend is about a hundred years." Humans, with their short life spans, have a hard time forging truly strong friendships with dwarves. The best dwarf-human friendships are between a human and a dwarf who liked the human''s parents and grandparents. Dwarves fail to appreciate elves'' subtlety and art, regarding elves as unpredictable, fickle, and flighty. Still, elves and dwarves have, through the ages, found common cause against the enemies of civilized lands, and they have managed to overlook their differences when the need is great. Dwarves mistrust half-orcs in general, and the feeling is mutual. Luckily, dwarves are fair-minded, and they grant individual half-orcs the opportunity to prove themselves.',
  'Usually lawful good. Dwarves uphold the orderly traditions of their society.',
  'Dwarven kingdoms usually lie deep beneath the stony mountains, where the dwarves mine gems and precious metals and forge items of wonder. Trustworthy members of other races are welcome in such settlements, though some parts of these lands are off limits even to them. Whatever wealth the dwarves can''t find in their mountains, they gain through trade. Dwarves dislike water travel, so enterprising humans frequently handle trade in dwarven goods along water routes. Dwarves in human lands are typically mercenaries, weaponsmiths, armorsmiths, jewelers, and artisans. Dwarf bodyguards are renowned for their courage and loyalty, and they are well rewarded for their virtues.',
  'The chief deity of the dwarves is Moradin, the Soul Forger. He is the creator of the dwarves, and he expects his followers to work for the betterment of the dwarf race.',
  'A dwarf''s name is granted to him by his clan elder, in accordance with tradition. Every proper dwarven name has been used and reused down through the generations. A dwarf''s name belongs to the clan, not to the individual. A dwarf who misuses or brings shame to a clan name is stripped of the name and forbidden by law to use any dwarven name in its place. Male Names: Baern, Barendd, Brottor, Eberk, Einkil, Oskar, Rurik, Taklinn, Tordek, Traubon, Ulfgar, Veit. Female Names: Artin, Audhild, Dagnal, Diesa, Gunnloda, Hlin, Ilde, Liftrasa, Sannl, Torgga. Clan Names: Balderk, Dankil, Gorunn, Holderhek, Loderr, Lutgehr, Rumnaheim, Strakeln, Torunn, Ungart.',
  'A dwarven adventurer may be motivated by crusading zeal, a love of excitement, or simple greed. As long as his accomplishments bring honor to his clan, his deeds earn him respect and status. Defeating giants and claiming powerful magic weapons are sure ways for a dwarf to earn the respect of other dwarves.'
);

-- Race 3: ELF
-- Medium Humanoid (Elf), 30 ft speed, +2 DEX/-2 CON
-- Favored Class: Wizard
-- Traits: Low-Light Vision, Sleep Immunity, +2 saves vs Enchantment, Weapon Proficiency, Keen Senses

INSERT INTO races (
  name,
  size_category_id,
  base_speed,
  creature_type,
  creature_subtype,
  favored_class_id,
  description,
  personality,
  physical_description,
  relations,
  alignment,
  lands,
  religion,
  names,
  adventurers
) VALUES (
  'Elf',
  (SELECT id FROM size_categories WHERE name = 'Medium'),
  30,
  'Humanoid',
  'Elf',
  (SELECT id FROM classes WHERE name = 'Wizard'),
  'Elves are known for their poetry, dance, song, lore, and magical arts. When danger threatens their woodland homes, however, elves reveal a more martial side, demonstrating skill with sword, bow, and battle strategy.',
  'Elves are more often amused than excited, more likely to be curious than greedy. With such long lives, they tend to keep a broad perspective on events, remaining aloof and unfazed by petty happenstance. When pursuing a goal, however, whether an adventurous mission or learning a new skill or art, they can be focused and relentless. They are slow to make friends and enemies, and even slower to forget them. They reply to petty insults with disdain and to serious insults with vengeance.',
  'Elves are short and slim, standing about 4½ to 5½ feet tall and typically weighing 85 to 135 pounds, with elven men the same height as and only marginally heavier than elven women. They are graceful but frail. They tend to be pale-skinned and dark-haired, with deep green eyes. Elves have no facial or body hair. They prefer simple, comfortable clothes, especially in pastel blues and greens, and they enjoy simple yet elegant jewelry. Elves possess unearthly grace and fine features. Many humans and members of other races find them hauntingly beautiful. An elf can live to be over 700 years old.',
  'Elves consider humans rather unrefined, halflings a bit staid, gnomes somewhat trivial, and dwarves not at all fun. They look on half-elves with some degree of pity, and they regard half-orcs with unrelenting suspicion. While haughty, elves are not particular the way halflings and dwarves can be, and they are generally pleasant and gracious even to those who fall short of elven standards (which is, after all, most non-elves).',
  'Usually chaotic good. Elves love freedom, variety, and self-expression. They lean strongly toward the gentler aspects of chaos. Generally, they value and protect others'' freedom as well as their own, and they are more often good than not.',
  'Most elves live in woodland clans numbering less than two hundred souls. Their well-hidden villages blend into the trees, doing little harm to the forest. They hunt game, gather food, and grow vegetables, and their skill and magic allow them to support themselves amply without the need for clearing and plowing land. Their contact with outsiders is usually limited, though some few elves make a good living trading finely worked clothes and crafted items for the metals that they have no interest in mining.',
  'Elves worship Corellon Larethian, the Protector and Preserver of life. They see themselves as his children and his favored followers.',
  'When an elf declares herself an adult, usually some time after her hundredth birthday, she also selects a name. Those who knew her as a youngster may or may not continue to call her by her "child name," and she may or may not care. An elf''s adult name is a unique creation, though it may reflect the names of those she admires or the names of others in her family. In addition, she bears her family name. Family names are combinations of regular Elven words; and some elves traveling among humans translate their names into Common while others use the Elven version. Male Names: Aramil, Aust, Enialis, Heian, Himo, Ivellios, Laucian, Quarion, Soveliss, Thamior, Tharivol. Female Names: Anastrianna, Antinua, Drusilia, Felosial, Ielenia, Lia, Qillathe, Silaqui, Valanthe, Xanaphia. Family Names: Amastacia ("Starflower"), Amakiir ("Gemflower"), Galanodel ("Moonwhisper"), Holimion ("Diamonddew"), Liadon ("Silverfrond"), Meliamne ("Oakenheel"), Naïlo ("Nightbreeze"), Siannodel ("Moonbrook"), Ilphukiir ("Gemblossom"), Xiloscient ("Goldpetal").',
  'Elves take up adventuring out of wanderlust. Life among humans moves at a pace that elves dislike: regimented from day to day but changing from decade to decade. Elves among humans, therefore, find careers that allow them to wander freely and set their own pace. Elves also enjoy demonstrating their prowess with the sword and bow or gaining greater magical power, and adventuring allows them to do so. Good elves may also be rebels or crusaders.'
);

-- Race 4: HALFLING
-- Small Humanoid (Halfling), 20 ft speed, +2 DEX/-2 STR
-- Favored Class: Rogue
-- Traits: +2 racial bonus on Climb/Jump/Move Silently/Listen, +1 all saves, +2 saves vs fear, +1 attack with thrown/sling

INSERT INTO races (
  name,
  size_category_id,
  base_speed,
  creature_type,
  creature_subtype,
  favored_class_id,
  description,
  personality,
  physical_description,
  relations,
  alignment,
  lands,
  religion,
  names,
  adventurers
) VALUES (
  'Halfling',
  (SELECT id FROM size_categories WHERE name = 'Small'),
  20,
  'Humanoid',
  'Halfling',
  (SELECT id FROM classes WHERE name = 'Rogue'),
  'Halflings are clever, capable, and resourceful survivors. They are notoriously curious and show a daring that many larger people can''t match. They can be lured by wealth but tend to spend rather than hoard. Halflings have ruddy skin, hair that is black and straight, and brown or black eyes. Halfling men often have long sideburns, but beards are rare among them and mustaches almost unseen.',
  'Halflings prefer trouble to boredom. They are notoriously curious. Relying on their ability to survive or escape danger, they demonstrate a daring that many larger people can''t match. Halfling clans are nomadic, wandering wherever circumstance and curiosity take them. Halflings enjoy wealth and the pleasure it can buy, but they don''t obsess over it. Even when they''re not adventuring, halflings stir up trouble just to have something to do.',
  'Halflings stand about 3 feet tall and usually weigh between 30 and 35 pounds. Halflings have ruddy skin, hair that is black and straight, and brown or black eyes. Halfling men often have long sideburns, but beards are rare among them and mustaches almost unseen. Halflings prefer simple and practical clothes. Unlike dwarves and elves, halflings don''t typically live in their own kingdoms or lands. Instead, they inhabit the lands of other races, where they can benefit from whatever resources those lands have to offer. Halflings often form tight-knit communities in human or dwarven cities. While they work readily with others, they cherish their privacy, especially of their homes, and they don''t invite others in readily. A halfling reaches adulthood at the age of 20 and generally lives into the middle of her second century.',
  'Halflings try to get along with everyone else. They are adept at fitting into a community of humans, dwarves, elves, or gnomes and making themselves valuable and welcome. Since human society changes faster than the societies of the longer-lived races, it is human society that most frequently offers halflings opportunities to exploit, and halflings are most often found in or around human lands.',
  'Usually lawful good. Halflings tend to be reliable, hardworking, and practical. They tend to be good-hearted and easy-going.',
  'Halflings have no lands of their own. Instead, they live in the lands of other races, where they can benefit from the resources those lands have to offer. Halflings often form tight-knit communities in human or dwarven cities.',
  'The chief halfling deity is Yondalla, the Blessed One, protector of the halfling folk. Yondalla promises blessings and protection to those who heed her guidance, defend their clans, and cherish their families.',
  'A halfling has a given name, a family name, and possibly a nickname. It would seem that family names are nothing more than nicknames that stuck so well that they have been passed down through the generations. Male Names: Alton, Beau, Cade, Eldon, Garret, Lyle, Milo, Osborn, Roscoe, Wellby. Female Names: Amaryllis, Charmaine, Cora, Eunice, Gynnie, Lavinia, Merla, Portia, Seraphina, Verna. Family Names: Brushgather, Goodbarrel, Greenbottle, Highhill, Hilltopple, Leagallow, Tealeaf, Thorngage, Tosscobble, Underbough.',
  'Halflings often set out on the adventurer''s path to defend their communities, support their friends, or explore a wide and wonder-filled world. For them, adventuring is less a career than an opportunity or sometimes a necessity.'
);

-- Race 5: HALF-ORC
-- Medium Humanoid (Orc), 30 ft speed, +2 STR/-2 INT/-2 CHA
-- Favored Class: Barbarian
-- Traits: Darkvision 60 ft., Orc Blood

INSERT INTO races (
  name,
  size_category_id,
  base_speed,
  creature_type,
  creature_subtype,
  favored_class_id,
  description,
  personality,
  physical_description,
  relations,
  alignment,
  lands,
  religion,
  names,
  adventurers
) VALUES (
  'Half-Orc',
  (SELECT id FROM size_categories WHERE name = 'Medium'),
  30,
  'Humanoid',
  'Orc',
  (SELECT id FROM classes WHERE name = 'Barbarian'),
  'Half-orcs are the short-tempered and sullen result of human and orc pairings. They would rather act than ponder and would rather fight than argue. Those who live among or near orcs also tend to have the same attitude. They are not evil by nature, but evil does lurk within them, whether they embrace it or rebel against it.',
  'Half-orcs tend toward sullen aloofness. They would rather act than ponder and would rather fight than argue. Those who live among or near orcs also tend to be superstitious and to share the orcs'' hatred and fear of magic. In lands far from orc populations, however, half-orcs tend to be judged by their temperament and deeds rather than by the reputation of their race. Half-orcs generally have short tempers and lack of patience, characteristics shared with their orc forebears.',
  'Half-orcs stand between 5½ and 6½ feet tall and usually weigh between 150 and 225 pounds. A half-orc''s grayish pigmentation, sloping forehead, jutting jaw, prominent teeth, and coarse body hair make his lineage plain for all to see. Half-orcs mature a little faster than humans and age noticeably faster. Few half-orcs live longer than 75 years. Because orcs are a tribal race and humans are willing to accept non-humans more readily than most other races, half-orcs are more common in human lands than among orc tribes.',
  'Half-orcs inherit a tendency toward chaos from their orc parents, but, like their human parents, they favor good and evil in equal proportions. Half-orcs raised among orcs and willing to live out their lives with them are usually the ones who turn toward evil. Half-orcs are rare among civilized populations, however, and many humans mistrust them. They don''t have their own lands, and they''re not quite welcome in human society either. Most half-orcs wander between both worlds and belong to neither.',
  'Usually chaotic evil or neutral. Half-orcs who live among orcs are usually evil. Half-orcs raised among humans are more variable.',
  'Half-orcs have no lands of their own. Most half-orcs who live among or near orcs are largely indistinguishable from full-blooded orcs. Others live among humans, perhaps as mercenaries or criminals. Some who aren''t welcome in human cities strike off into the wilderness and make a living by strength of arms.',
  'Half-orcs who live among or near orcs adopt the orc deity, Gruumsh. Those who live among humans often worship human gods.',
  'Half-orcs use either human or orc names, depending on which culture they were raised among. A half-orc who wants to fit in among humans might trade an orc name for a human one. Half-orcs who have been raised among orcs have orc names.',
  'Half-orcs living among humans are drawn almost invariably toward violent careers in which they can put their strength to good use. Frequently shunned from polite company, half-orcs often find acceptance and friendship among adventurers, many of whom are fellow wanderers and outsiders.'
);

-- =====================================================
-- RACE ABILITY ADJUSTMENTS
-- =====================================================

-- Humans: No ability adjustments (omitted)

-- Dwarf: +2 CON, -2 CHA
INSERT INTO race_ability_adjustments (race_id, ability, adjustment)
VALUES
  ((SELECT id FROM races WHERE name = 'Dwarf'), 'CON', 2),
  ((SELECT id FROM races WHERE name = 'Dwarf'), 'CHA', -2);

-- Elf: +2 DEX, -2 CON
INSERT INTO race_ability_adjustments (race_id, ability, adjustment)
VALUES
  ((SELECT id FROM races WHERE name = 'Elf'), 'DEX', 2),
  ((SELECT id FROM races WHERE name = 'Elf'), 'CON', -2);

-- Halfling: +2 DEX, -2 STR
INSERT INTO race_ability_adjustments (race_id, ability, adjustment)
VALUES
  ((SELECT id FROM races WHERE name = 'Halfling'), 'DEX', 2),
  ((SELECT id FROM races WHERE name = 'Halfling'), 'STR', -2);

-- Half-Orc: +2 STR, -2 INT, -2 CHA
INSERT INTO race_ability_adjustments (race_id, ability, adjustment)
VALUES
  ((SELECT id FROM races WHERE name = 'Half-Orc'), 'STR', 2),
  ((SELECT id FROM races WHERE name = 'Half-Orc'), 'INT', -2),
  ((SELECT id FROM races WHERE name = 'Half-Orc'), 'CHA', -2);

-- =====================================================
-- RACIAL TRAITS (SPECIAL ABILITIES)
-- =====================================================
-- Racial traits use the unified special_abilities system.
-- Links to races via race_granted_abilities junction table.
-- Integration with effects, skills, feats for mechanical benefits.
-- =====================================================

-- =====================================================
-- HUMAN RACIAL TRAITS
-- =====================================================

-- Human Trait 1: Bonus Feat
INSERT INTO special_abilities (
  name,
  ability_type,
  is_active,
  activation_type,
  description,
  source_category
) VALUES (
  'Human Bonus Feat',
  'extraordinary',
  false,
  'passive',
  'Humans gain one extra feat at 1st level, because they are quick to master specialized tasks and varied in their talents.',
  'race'
) ON CONFLICT (name) DO NOTHING;

-- Human Trait 2: Extra Skill Points
INSERT INTO special_abilities (
  name,
  ability_type,
  is_active,
  activation_type,
  description,
  source_category
) VALUES (
  'Human Skill Versatility',
  'extraordinary',
  false,
  'passive',
  'Humans gain 4 extra skill points at 1st level and 1 extra skill point at each additional level. They are versatile and capable, and humans tend to learn a broad range of skills over their careers.',
  'race'
) ON CONFLICT (name) DO NOTHING;

-- Link human traits to Human race
INSERT INTO race_granted_abilities (race_id, special_ability_id, notes)
VALUES
  ((SELECT id FROM races WHERE name = 'Human'),
   (SELECT id FROM special_abilities WHERE name = 'Human Bonus Feat'),
   'Bonus feat at 1st level'),
  ((SELECT id FROM races WHERE name = 'Human'),
   (SELECT id FROM special_abilities WHERE name = 'Human Skill Versatility'),
   '+4 skill points at 1st level, +1 per level thereafter');

-- =====================================================
-- DWARF RACIAL TRAITS
-- =====================================================

-- Dwarf Trait 1: Darkvision 60 ft.
INSERT INTO special_abilities (
  name,
  ability_type,
  is_active,
  activation_type,
  description,
  source_category
) VALUES (
  'Darkvision 60 ft.',
  'extraordinary',
  false,
  'passive',
  'Can see in the dark up to 60 feet. Darkvision is black and white only, but it is otherwise like normal sight, and the creature can function just fine with no light at all.',
  'general'
) ON CONFLICT (name) DO NOTHING;

-- Dwarf Trait 2: Stonecunning
INSERT INTO special_abilities (
  name,
  ability_type,
  is_active,
  activation_type,
  description,
  source_category
) VALUES (
  'Stonecunning',
  'extraordinary',
  false,
  'passive',
  '+2 racial bonus on Search checks to notice unusual stonework, such as sliding walls, stonework traps, new construction (even when built to match the old), unsafe stone surfaces, shaky stone ceilings, and the like. A dwarf who merely comes within 10 feet of unusual stonework can make a Search check as if actively searching, and can use the Search skill to find stonework traps as a rogue can. A dwarf can also intuit depth, sensing approximate depth underground as naturally as a human can sense which way is up.',
  'race'
) ON CONFLICT (name) DO NOTHING;

-- Dwarf Trait 3: Weapon Familiarity (Dwarven)
INSERT INTO special_abilities (
  name,
  ability_type,
  is_active,
  activation_type,
  description,
  source_category
) VALUES (
  'Dwarven Weapon Familiarity',
  'extraordinary',
  false,
  'passive',
  'Dwarves may treat dwarven waraxes and dwarven urgroshes as martial weapons, rather than exotic weapons.',
  'race'
) ON CONFLICT (name) DO NOTHING;

-- Dwarf Trait 4: Stability
INSERT INTO special_abilities (
  name,
  ability_type,
  is_active,
  activation_type,
  description,
  source_category
) VALUES (
  'Stability',
  'extraordinary',
  false,
  'passive',
  '+4 bonus on ability checks made to resist being bull rushed or tripped when standing on the ground (but not when climbing, flying, riding, or otherwise not standing firmly on the ground).',
  'race'
) ON CONFLICT (name) DO NOTHING;

-- Dwarf Trait 5: +2 saves vs Poison
INSERT INTO special_abilities (
  name,
  ability_type,
  is_active,
  activation_type,
  description,
  source_category
) VALUES (
  'Dwarven Poison Resistance',
  'extraordinary',
  false,
  'passive',
  '+2 racial bonus on saving throws against poison.',
  'race'
) ON CONFLICT (name) DO NOTHING;

-- Dwarf Trait 6: +2 saves vs Spells and Spell-like Effects
INSERT INTO special_abilities (
  name,
  ability_type,
  is_active,
  activation_type,
  description,
  source_category
) VALUES (
  'Dwarven Spell Resistance',
  'extraordinary',
  false,
  'passive',
  '+2 racial bonus on saving throws against spells and spell-like effects.',
  'race'
) ON CONFLICT (name) DO NOTHING;

-- Dwarf Trait 7: +1 attack vs Orcs and Goblinoids
INSERT INTO special_abilities (
  name,
  ability_type,
  is_active,
  activation_type,
  description,
  source_category
) VALUES (
  'Dwarven Combat Training (Orcs/Goblinoids)',
  'extraordinary',
  false,
  'passive',
  '+1 racial bonus on attack rolls against orcs and goblinoids. Dwarves are trained in the special combat techniques that allow them to fight their common enemies.',
  'race'
) ON CONFLICT (name) DO NOTHING;

-- Dwarf Trait 8: +4 dodge bonus to AC vs Giants
INSERT INTO special_abilities (
  name,
  ability_type,
  is_active,
  activation_type,
  description,
  source_category
) VALUES (
  'Defensive Training (Giants)',
  'extraordinary',
  false,
  'passive',
  '+4 dodge bonus to Armor Class against monsters of the giant type. Any time a creature loses its Dexterity bonus (if any) to Armor Class, such as when caught flat-footed, it loses its dodge bonus, too.',
  'race'
) ON CONFLICT (name) DO NOTHING;

-- Dwarf Trait 9: +2 Appraise (stone/metal)
INSERT INTO special_abilities (
  name,
  ability_type,
  is_active,
  activation_type,
  description,
  source_category
) VALUES (
  'Dwarven Appraisal',
  'extraordinary',
  false,
  'passive',
  '+2 racial bonus on Appraise checks that are related to stone or metal items.',
  'race'
) ON CONFLICT (name) DO NOTHING;

-- Dwarf Trait 10: +2 Craft (stone/metal)
INSERT INTO special_abilities (
  name,
  ability_type,
  is_active,
  activation_type,
  description,
  source_category
) VALUES (
  'Dwarven Craftsmanship',
  'extraordinary',
  false,
  'passive',
  '+2 racial bonus on Craft checks that are related to stone or metal.',
  'race'
) ON CONFLICT (name) DO NOTHING;

-- Link dwarf traits to Dwarf race
INSERT INTO race_granted_abilities (race_id, special_ability_id, notes)
VALUES
  ((SELECT id FROM races WHERE name = 'Dwarf'),
   (SELECT id FROM special_abilities WHERE name = 'Darkvision 60 ft.'),
   NULL),
  ((SELECT id FROM races WHERE name = 'Dwarf'),
   (SELECT id FROM special_abilities WHERE name = 'Stonecunning'),
   NULL),
  ((SELECT id FROM races WHERE name = 'Dwarf'),
   (SELECT id FROM special_abilities WHERE name = 'Dwarven Weapon Familiarity'),
   NULL),
  ((SELECT id FROM races WHERE name = 'Dwarf'),
   (SELECT id FROM special_abilities WHERE name = 'Stability'),
   NULL),
  ((SELECT id FROM races WHERE name = 'Dwarf'),
   (SELECT id FROM special_abilities WHERE name = 'Dwarven Poison Resistance'),
   NULL),
  ((SELECT id FROM races WHERE name = 'Dwarf'),
   (SELECT id FROM special_abilities WHERE name = 'Dwarven Spell Resistance'),
   NULL),
  ((SELECT id FROM races WHERE name = 'Dwarf'),
   (SELECT id FROM special_abilities WHERE name = 'Dwarven Combat Training (Orcs/Goblinoids)'),
   NULL),
  ((SELECT id FROM races WHERE name = 'Dwarf'),
   (SELECT id FROM special_abilities WHERE name = 'Defensive Training (Giants)'),
   NULL),
  ((SELECT id FROM races WHERE name = 'Dwarf'),
   (SELECT id FROM special_abilities WHERE name = 'Dwarven Appraisal'),
   NULL),
  ((SELECT id FROM races WHERE name = 'Dwarf'),
   (SELECT id FROM special_abilities WHERE name = 'Dwarven Craftsmanship'),
   NULL);

-- =====================================================
-- ELF RACIAL TRAITS
-- =====================================================

-- Elf Trait 1: Low-Light Vision
INSERT INTO special_abilities (
  name,
  ability_type,
  is_active,
  activation_type,
  description,
  source_category
) VALUES (
  'Low-Light Vision',
  'extraordinary',
  false,
  'passive',
  'Can see twice as far as a human in starlight, moonlight, torchlight, and similar conditions of poor illumination. Retains the ability to distinguish color and detail under these conditions.',
  'general'
) ON CONFLICT (name) DO NOTHING;

-- Elf Trait 2: Immunity to Sleep
INSERT INTO special_abilities (
  name,
  ability_type,
  is_active,
  activation_type,
  description,
  source_category
) VALUES (
  'Immunity to Sleep',
  'extraordinary',
  false,
  'passive',
  'Immunity to magic sleep effects.',
  'race'
) ON CONFLICT (name) DO NOTHING;

-- Elf Trait 3: +2 saves vs Enchantment
INSERT INTO special_abilities (
  name,
  ability_type,
  is_active,
  activation_type,
  description,
  source_category
) VALUES (
  'Elven Enchantment Resistance',
  'extraordinary',
  false,
  'passive',
  '+2 racial saving throw bonus against enchantment spells or effects.',
  'race'
) ON CONFLICT (name) DO NOTHING;

-- Elf Trait 4: Weapon Proficiency (Elven)
INSERT INTO special_abilities (
  name,
  ability_type,
  is_active,
  activation_type,
  description,
  source_category
) VALUES (
  'Elven Weapon Proficiency',
  'extraordinary',
  false,
  'passive',
  'Elves receive the Martial Weapon Proficiency feats for the longsword, rapier, longbow (including composite longbow), and shortbow (including composite shortbow) as bonus feats.',
  'race'
) ON CONFLICT (name) DO NOTHING;

-- Elf Trait 5: Keen Senses
INSERT INTO special_abilities (
  name,
  ability_type,
  is_active,
  activation_type,
  description,
  source_category
) VALUES (
  'Elven Keen Senses',
  'extraordinary',
  false,
  'passive',
  '+2 racial bonus on Listen, Search, and Spot checks. An elf who merely passes within 5 feet of a secret or concealed door is entitled to a Search check to notice it as if actively looking for it.',
  'race'
) ON CONFLICT (name) DO NOTHING;

-- Link elf traits to Elf race
INSERT INTO race_granted_abilities (race_id, special_ability_id, notes)
VALUES
  ((SELECT id FROM races WHERE name = 'Elf'),
   (SELECT id FROM special_abilities WHERE name = 'Low-Light Vision'),
   NULL),
  ((SELECT id FROM races WHERE name = 'Elf'),
   (SELECT id FROM special_abilities WHERE name = 'Immunity to Sleep'),
   NULL),
  ((SELECT id FROM races WHERE name = 'Elf'),
   (SELECT id FROM special_abilities WHERE name = 'Elven Enchantment Resistance'),
   NULL),
  ((SELECT id FROM races WHERE name = 'Elf'),
   (SELECT id FROM special_abilities WHERE name = 'Elven Weapon Proficiency'),
   NULL),
  ((SELECT id FROM races WHERE name = 'Elf'),
   (SELECT id FROM special_abilities WHERE name = 'Elven Keen Senses'),
   NULL);

-- =====================================================
-- HALFLING RACIAL TRAITS
-- =====================================================

-- Halfling Trait 1: +2 Climb, Jump, Move Silently
INSERT INTO special_abilities (
  name,
  ability_type,
  is_active,
  activation_type,
  description,
  source_category
) VALUES (
  'Halfling Nimbleness',
  'extraordinary',
  false,
  'passive',
  '+2 racial bonus on Climb, Jump, and Move Silently checks.',
  'race'
) ON CONFLICT (name) DO NOTHING;

-- Halfling Trait 2: +1 all saves
INSERT INTO special_abilities (
  name,
  ability_type,
  is_active,
  activation_type,
  description,
  source_category
) VALUES (
  'Halfling Luck',
  'extraordinary',
  false,
  'passive',
  '+1 racial bonus on all saving throws.',
  'race'
) ON CONFLICT (name) DO NOTHING;

-- Halfling Trait 3: +2 morale bonus on saves vs fear
INSERT INTO special_abilities (
  name,
  ability_type,
  is_active,
  activation_type,
  description,
  source_category
) VALUES (
  'Halfling Bravery',
  'extraordinary',
  false,
  'passive',
  '+2 morale bonus on saving throws against fear. This bonus stacks with the halfling''s +1 bonus on saving throws in general.',
  'race'
) ON CONFLICT (name) DO NOTHING;

-- Halfling Trait 4: +1 attack with thrown weapons and slings
INSERT INTO special_abilities (
  name,
  ability_type,
  is_active,
  activation_type,
  description,
  source_category
) VALUES (
  'Halfling Weapon Familiarity',
  'extraordinary',
  false,
  'passive',
  '+1 racial bonus on attack rolls with thrown weapons and slings.',
  'race'
) ON CONFLICT (name) DO NOTHING;

-- Halfling Trait 5: +2 Listen
INSERT INTO special_abilities (
  name,
  ability_type,
  is_active,
  activation_type,
  description,
  source_category
) VALUES (
  'Halfling Keen Hearing',
  'extraordinary',
  false,
  'passive',
  '+2 racial bonus on Listen checks.',
  'race'
) ON CONFLICT (name) DO NOTHING;

-- Link halfling traits to Halfling race
INSERT INTO race_granted_abilities (race_id, special_ability_id, notes)
VALUES
  ((SELECT id FROM races WHERE name = 'Halfling'),
   (SELECT id FROM special_abilities WHERE name = 'Halfling Nimbleness'),
   NULL),
  ((SELECT id FROM races WHERE name = 'Halfling'),
   (SELECT id FROM special_abilities WHERE name = 'Halfling Luck'),
   NULL),
  ((SELECT id FROM races WHERE name = 'Halfling'),
   (SELECT id FROM special_abilities WHERE name = 'Halfling Bravery'),
   NULL),
  ((SELECT id FROM races WHERE name = 'Halfling'),
   (SELECT id FROM special_abilities WHERE name = 'Halfling Weapon Familiarity'),
   NULL),
  ((SELECT id FROM races WHERE name = 'Halfling'),
   (SELECT id FROM special_abilities WHERE name = 'Halfling Keen Hearing'),
   NULL);

-- =====================================================
-- HALF-ORC RACIAL TRAITS
-- =====================================================

-- Half-Orc Trait 1: Darkvision 60 ft. (already created for dwarves)

-- Half-Orc Trait 2: Orc Blood
INSERT INTO special_abilities (
  name,
  ability_type,
  is_active,
  activation_type,
  description,
  source_category
) VALUES (
  'Orc Blood',
  'extraordinary',
  false,
  'passive',
  'For all effects related to race, a half-orc is considered an orc. Half-orcs, for example, are just as vulnerable to special effects that affect orcs as their orc ancestors are, and they can use magic items that are only usable by orcs.',
  'race'
) ON CONFLICT (name) DO NOTHING;

-- Link half-orc traits to Half-Orc race
INSERT INTO race_granted_abilities (race_id, special_ability_id, notes)
VALUES
  ((SELECT id FROM races WHERE name = 'Half-Orc'),
   (SELECT id FROM special_abilities WHERE name = 'Darkvision 60 ft.'),
   NULL),
  ((SELECT id FROM races WHERE name = 'Half-Orc'),
   (SELECT id FROM special_abilities WHERE name = 'Orc Blood'),
   NULL);

-- =====================================================
-- QUERY EXAMPLES
-- =====================================================

-- Get all races with their size and favored class:
-- SELECT r.name, sc.name AS size, r.base_speed, c.name AS favored_class
-- FROM races r
-- JOIN size_categories sc ON r.size_category_id = sc.id
-- LEFT JOIN classes c ON r.favored_class_id = c.id
-- ORDER BY r.name;

-- Get all ability adjustments for a specific race:
-- SELECT r.name AS race, raa.ability, raa.adjustment
-- FROM races r
-- JOIN race_ability_adjustments raa ON r.id = raa.race_id
-- WHERE r.name = 'Dwarf'
-- ORDER BY raa.ability;

-- Get all racial traits for a specific race:
-- SELECT r.name AS race, sa.name AS trait, sa.description
-- FROM races r
-- JOIN race_granted_abilities rga ON r.id = rga.race_id
-- JOIN special_abilities sa ON rga.special_ability_id = sa.id
-- WHERE r.name = 'Elf'
-- ORDER BY sa.name;

-- Get races by creature type:
-- SELECT name, creature_type, creature_subtype, base_speed
-- FROM races
-- WHERE creature_type = 'Humanoid'
-- ORDER BY name;

-- Get all races with ability score adjustments:
-- SELECT DISTINCT r.name
-- FROM races r
-- JOIN race_ability_adjustments raa ON r.id = raa.race_id
-- ORDER BY r.name;

-- Get races with darkvision:
-- SELECT DISTINCT r.name
-- FROM races r
-- JOIN race_granted_abilities rga ON r.id = rga.race_id
-- JOIN special_abilities sa ON rga.special_ability_id = sa.id
-- WHERE sa.name LIKE '%Darkvision%'
-- ORDER BY r.name;

-- =====================================================
-- SCHEMA MAPPING FROM SRD TO DATABASE
-- =====================================================
--
-- RACES TABLE MAPPING:
-- SRD Field              → Database Column           → Example
-- -------------------------------------------------------------------
-- Race Name              → races.name                → 'Dwarf'
-- Size                   → size_category_id          → Medium (FK)
-- Speed                  → base_speed                → 20 (feet)
-- Creature Type          → creature_type             → 'Humanoid'
-- Creature Subtype       → creature_subtype          → 'Dwarf'
-- Favored Class          → favored_class_id          → Fighter (FK) or NULL
-- Personality            → personality               → TEXT
-- Physical Description   → physical_description      → TEXT
-- Relations              → relations                 → TEXT
-- Alignment              → alignment                 → TEXT
-- Lands                  → lands                     → TEXT
-- Religion               → religion                  → TEXT
-- Names                  → names                     → TEXT
-- Adventurers            → adventurers               → TEXT
--
-- RACE_ABILITY_ADJUSTMENTS TABLE MAPPING:
-- SRD Field              → Database Column           → Example
-- -------------------------------------------------------------------
-- Ability Adjustment     → ability + adjustment      → 'CON', +2
-- Multiple Adjustments   → Multiple rows             → CON +2, CHA -2
--
-- SPECIAL_ABILITIES TABLE MAPPING (via race_granted_abilities):
-- SRD Field              → Database Column           → Example
-- -------------------------------------------------------------------
-- Racial Trait Name      → special_abilities.name    → 'Stonecunning'
-- Trait Type             → ability_type              → 'extraordinary'
-- Trait Description      → description               → '+2 racial bonus on Search...'
-- Is Active Ability      → is_active                 → false (passive trait)
-- Activation Type        → activation_type           → 'passive'
-- Source Category        → source_category           → 'race'
--
-- INTEGRATION WITH OTHER SYSTEMS:
-- - Racial skill bonuses: Link via skill_condition_modifiers or effects
-- - Racial saves bonuses: Link via save_bonuses or effects
-- - Racial weapon proficiencies: Link via character_weapon_proficiencies
-- - Racial spell-like abilities: Link via spells and character_spells
-- - Racial languages: Link via race_languages (languages.sql)
--
-- =====================================================
-- IMPORT STRATEGY NOTES
-- =====================================================
--
-- 1. Prerequisites:
--    - Import size_categories first (srd-reference-tables.sql)
--    - Import classes first (classes-import.sql)
--    - Import languages first (languages.sql) for race_languages
--
-- 2. Import Order:
--    a. races table (core race data)
--    b. race_ability_adjustments (ability score modifiers)
--    c. special_abilities (racial traits)
--    d. race_granted_abilities (junction table)
--
-- 3. Verification:
--    - Query each race to ensure all traits are linked
--    - Verify ability adjustments sum correctly
--    - Check that favored_class_id references valid classes
--
-- 4. Remaining Races:
--    Follow the same pattern for:
--    - Gnome (Small, +2 CON/-2 STR, favored class: Bard)
--    - Half-Elf (Medium, no adjustments, favored class: Any)
--    Plus any additional races from other SRD sources
--
-- =====================================================
-- END OF RACES IMPORT DATA
-- =====================================================
