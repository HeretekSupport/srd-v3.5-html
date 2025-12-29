-- =====================================================
-- D&D 3.5 SRD SKILLS IMPORT
-- =====================================================
-- Imports all skills from the D&D 3.5 SRD
-- Source: skills-i.html and skills-ii.html
--
-- Includes:
-- - 36 standard skills
-- - 10 Knowledge categories
-- - 9 Perform categories
-- - 20 common Craft categories
-- - 30 common Profession categories
--
-- Total: 105 skills

SET search_path TO pnpo_3_5_dev;

-- =====================================================
-- STANDARD SKILLS (Alphabetical)
-- =====================================================

INSERT INTO skills (name, key_ability, trained_only, armor_check_penalty, description, try_again) VALUES
('Appraise', 'INT', false, false, 'Estimate the value of objects, from common items to rare treasures.', false),
('Balance', 'DEX', false, true, 'Walk on narrow surfaces, uneven ground, or slippery floors without falling.', true),
('Bluff', 'CHA', false, false, 'Deceive others through lies, feints in combat, or passing hidden messages.', true),
('Climb', 'STR', false, true, 'Scale walls, cliffs, and other vertical surfaces.', true),
('Concentration', 'CON', false, false, 'Maintain focus on spells or tasks despite distractions, damage, or adverse conditions.', true),
('Craft', 'INT', false, false, 'Create items using artisan tools and raw materials. Specific category required (alchemy, weapons, armor, etc.).', true),
('Decipher Script', 'INT', true, false, 'Understand unfamiliar writing, coded messages, or incomplete texts.', false),
('Diplomacy', 'CHA', false, false, 'Persuade others, negotiate deals, and influence NPC attitudes.', true),
('Disable Device', 'INT', true, false, 'Disarm traps, sabotage mechanisms, and open locks with finesse.', true),
('Disguise', 'CHA', false, false, 'Change your appearance to impersonate others or conceal your identity.', true),
('Escape Artist', 'DEX', false, true, 'Slip free from bonds, grapples, and tight spaces.', true),
('Forgery', 'INT', false, false, 'Create false documents, counterfeit signatures, and fake official papers.', true),
('Gather Information', 'CHA', false, false, 'Learn rumors, gossip, and local information through social interaction.', true),
('Handle Animal', 'CHA', true, false, 'Train, command, and calm domestic and wild animals.', true),
('Heal', 'WIS', false, false, 'Treat wounds, diseases, and poisons with medical knowledge.', true),
('Hide', 'DEX', false, true, 'Conceal yourself from observers using cover and stealth.', true),
('Intimidate', 'CHA', false, false, 'Frighten opponents, demoralize enemies in combat, or coerce information.', false),
('Jump', 'STR', false, true, 'Leap across gaps, jump to high places, or hop up onto objects.', true),
('Listen', 'WIS', false, false, 'Hear sounds, detect approaching creatures, and eavesdrop on conversations.', true),
('Move Silently', 'DEX', false, true, 'Sneak quietly without alerting nearby creatures.', true),
('Open Lock', 'DEX', true, false, 'Pick locks on doors, chests, and other secured objects using thieves'' tools.', true),
('Perform', 'CHA', false, false, 'Entertain an audience through acting, music, dance, or other performance arts. Specific category required.', true),
('Profession', 'WIS', true, false, 'Earn money using a specific profession or trade. Specific category required.', true),
('Ride', 'DEX', false, false, 'Control a mount in combat, guide it through difficult terrain, or perform mounted stunts.', true),
('Search', 'INT', false, false, 'Find hidden objects, secret doors, traps, and concealed details.', true),
('Sense Motive', 'WIS', false, false, 'Detect lies, read body language, and understand hidden intentions.', false),
('Sleight of Hand', 'DEX', true, true, 'Pick pockets, palm small objects, hide weapons, and perform stage magic.', true),
('Speak Language', NULL, true, false, 'Learn to speak, read, and write additional languages. Each rank grants one new language.', true),
('Spellcraft', 'INT', true, false, 'Identify spells, magic items, and magical effects as they are cast or activated.', false),
('Spot', 'WIS', false, false, 'Notice details, detect hidden creatures, and see through disguises.', true),
('Survival', 'WIS', false, false, 'Track creatures, forage for food, predict weather, and avoid natural hazards.', true),
('Swim', 'STR', false, true, 'Move through water, swim against currents, and hold your breath.', true),
('Tumble', 'DEX', true, true, 'Perform acrobatic maneuvers, reduce falling damage, and tumble past opponents.', true),
('Use Magic Device', 'CHA', true, false, 'Activate magic items without meeting normal requirements, including scrolls and wands.', true),
('Use Rope', 'DEX', false, false, 'Tie knots, bind prisoners securely, splice rope, and climb with ropes.', true);

-- =====================================================
-- KNOWLEDGE CATEGORIES (10)
-- =====================================================
-- Knowledge is always INT, Trained Only
-- Each category is a separate skill

INSERT INTO skills (name, key_ability, trained_only, armor_check_penalty, description, try_again) VALUES
('Knowledge (arcana)', 'INT', true, false, 'Ancient mysteries, magic traditions, arcane symbols, cryptic phrases, constructs, dragons, and magical beasts.', false),
('Knowledge (architecture and engineering)', 'INT', true, false, 'Buildings, aqueducts, bridges, fortifications, and structural design.', false),
('Knowledge (dungeoneering)', 'INT', true, false, 'Aberrations, caverns, oozes, spelunking, and underground survival.', false),
('Knowledge (geography)', 'INT', true, false, 'Lands, terrain, climate, people, political boundaries, and natural features.', false),
('Knowledge (history)', 'INT', true, false, 'Royalty, wars, colonies, migrations, founding of cities, and historical events.', false),
('Knowledge (local)', 'INT', true, false, 'Legends, personalities, inhabitants, laws, customs, traditions, and humanoids in a specific region.', false),
('Knowledge (nature)', 'INT', true, false, 'Animals, fey, giants, monstrous humanoids, plants, seasons and cycles, weather, and vermin.', false),
('Knowledge (nobility and royalty)', 'INT', true, false, 'Lineages, heraldry, family trees, mottoes, personalities, and noble etiquette.', false),
('Knowledge (religion)', 'INT', true, false, 'Gods and goddesses, mythic history, ecclesiastic tradition, holy symbols, and undead.', false),
('Knowledge (the planes)', 'INT', true, false, 'The Inner Planes, Outer Planes, Astral Plane, Ethereal Plane, outsiders, elementals, and planar magic.', false);

-- =====================================================
-- PERFORM CATEGORIES (9)
-- =====================================================
-- Perform is always CHA, not trained only
-- Each performance type is a separate skill

INSERT INTO skills (name, key_ability, trained_only, armor_check_penalty, description, try_again) VALUES
('Perform (act)', 'CHA', false, false, 'Perform as an actor in plays, theatrical performances, and dramatic readings.', true),
('Perform (comedy)', 'CHA', false, false, 'Entertain through humor, jokes, and comedic performances.', true),
('Perform (dance)', 'CHA', false, false, 'Perform choreographed dances and interpretive movement.', true),
('Perform (keyboard instruments)', 'CHA', false, false, 'Play harpsichords, pianos, organs, and other keyboard instruments.', true),
('Perform (oratory)', 'CHA', false, false, 'Deliver speeches, recite poetry, and perform storytelling.', true),
('Perform (percussion instruments)', 'CHA', false, false, 'Play drums, bells, chimes, gongs, and other percussion instruments.', true),
('Perform (sing)', 'CHA', false, false, 'Perform vocal music through singing and chanting.', true),
('Perform (string instruments)', 'CHA', false, false, 'Play lutes, violins, harps, and other stringed instruments.', true),
('Perform (wind instruments)', 'CHA', false, false, 'Play flutes, trumpets, horns, pipes, and other wind instruments.', true);

-- =====================================================
-- CRAFT CATEGORIES (20 Common Types)
-- =====================================================
-- Craft is always INT, not trained only
-- Common categories from SRD

INSERT INTO skills (name, key_ability, trained_only, armor_check_penalty, description, try_again) VALUES
('Craft (alchemy)', 'INT', false, false, 'Create alchemical items such as acid, alchemist''s fire, antitoxin, and smokesticks.', true),
('Craft (armorsmithing)', 'INT', false, false, 'Forge and repair metal armor and shields.', true),
('Craft (basketweaving)', 'INT', false, false, 'Weave baskets, wicker furniture, and other woven goods.', true),
('Craft (bookbinding)', 'INT', false, false, 'Bind books, create scrolls, and craft leather book covers.', true),
('Craft (bowmaking)', 'INT', false, false, 'Craft bows, crossbows, arrows, and bolts.', true),
('Craft (calligraphy)', 'INT', false, false, 'Create decorative writing, illuminated manuscripts, and artistic lettering.', true),
('Craft (carpentry)', 'INT', false, false, 'Build furniture, wooden structures, and carpentry work.', true),
('Craft (cobbling)', 'INT', false, false, 'Make and repair shoes, boots, and leather footwear.', true),
('Craft (gemcutting)', 'INT', false, false, 'Cut, polish, and appraise gemstones.', true),
('Craft (leatherworking)', 'INT', false, false, 'Create leather armor, saddles, belts, and other leather goods.', true),
('Craft (locksmithing)', 'INT', false, false, 'Forge locks, keys, and security mechanisms.', true),
('Craft (painting)', 'INT', false, false, 'Create paintings, frescoes, and artistic illustrations.', true),
('Craft (pottery)', 'INT', false, false, 'Make ceramic pots, vases, plates, and pottery.', true),
('Craft (sculpting)', 'INT', false, false, 'Sculpt statues and decorative stonework.', true),
('Craft (shipmaking)', 'INT', false, false, 'Build and repair ships, boats, and nautical vessels.', true),
('Craft (stonemasonry)', 'INT', false, false, 'Cut and shape stone for buildings, walls, and monuments.', true),
('Craft (trapmaking)', 'INT', false, false, 'Design and construct mechanical traps and snares.', true),
('Craft (weaponsmithing)', 'INT', false, false, 'Forge and repair metal weapons.', true),
('Craft (weaving)', 'INT', false, false, 'Weave cloth, tapestries, and fabric goods.', true),
('Craft (woodworking)', 'INT', false, false, 'Carve wood, create wooden items, and perform woodworking.', true);

-- =====================================================
-- PROFESSION CATEGORIES (30 Common Types)
-- =====================================================
-- Profession is always WIS, trained only
-- Common categories from SRD

INSERT INTO skills (name, key_ability, trained_only, armor_check_penalty, description, try_again) VALUES
('Profession (apothecary)', 'WIS', true, false, 'Prepare medicines, tinctures, and medicinal compounds.', true),
('Profession (architect)', 'WIS', true, false, 'Design buildings, plan construction projects, and oversee architectural work.', true),
('Profession (baker)', 'WIS', true, false, 'Bake bread, pastries, and other baked goods for sale.', true),
('Profession (barrister)', 'WIS', true, false, 'Practice law, represent clients, and argue legal cases.', true),
('Profession (brewer)', 'WIS', true, false, 'Brew ale, beer, and other alcoholic beverages.', true),
('Profession (butcher)', 'WIS', true, false, 'Prepare and sell meat products.', true),
('Profession (clerk)', 'WIS', true, false, 'Maintain records, manage accounts, and perform administrative work.', true),
('Profession (cook)', 'WIS', true, false, 'Prepare meals in kitchens, inns, and noble households.', true),
('Profession (courtesan)', 'WIS', true, false, 'Provide companionship and entertainment to wealthy patrons.', true),
('Profession (driver)', 'WIS', true, false, 'Drive wagons, carriages, and other vehicles for hire.', true),
('Profession (engineer)', 'WIS', true, false, 'Design and oversee construction of bridges, siege weapons, and mechanical devices.', true),
('Profession (farmer)', 'WIS', true, false, 'Grow crops, raise livestock, and manage farmland.', true),
('Profession (fisherman)', 'WIS', true, false, 'Catch fish and harvest aquatic resources.', true),
('Profession (gambler)', 'WIS', true, false, 'Earn money through games of chance, cards, and gambling.', true),
('Profession (gardener)', 'WIS', true, false, 'Tend gardens, grow ornamental plants, and maintain landscaping.', true),
('Profession (herbalist)', 'WIS', true, false, 'Gather, identify, and sell medicinal herbs and plants.', true),
('Profession (innkeeper)', 'WIS', true, false, 'Manage an inn, serve guests, and oversee lodging operations.', true),
('Profession (librarian)', 'WIS', true, false, 'Organize books, maintain libraries, and assist researchers.', true),
('Profession (merchant)', 'WIS', true, false, 'Buy and sell goods, manage trade, and run commercial enterprises.', true),
('Profession (midwife)', 'WIS', true, false, 'Assist in childbirth and provide prenatal care.', true),
('Profession (miller)', 'WIS', true, false, 'Operate a mill to grind grain into flour.', true),
('Profession (miner)', 'WIS', true, false, 'Extract ore, gems, and minerals from mines.', true),
('Profession (porter)', 'WIS', true, false, 'Carry goods, luggage, and cargo for hire.', true),
('Profession (sailor)', 'WIS', true, false, 'Work aboard ships, navigate, and perform nautical duties.', true),
('Profession (scribe)', 'WIS', true, false, 'Copy documents, write letters, and maintain written records.', true),
('Profession (shepherd)', 'WIS', true, false, 'Tend flocks of sheep, goats, and other livestock.', true),
('Profession (soldier)', 'WIS', true, false, 'Serve in military forces, follow orders, and perform military duties.', true),
('Profession (stableman)', 'WIS', true, false, 'Care for horses, maintain stables, and manage equine needs.', true),
('Profession (tanner)', 'WIS', true, false, 'Cure hides and prepare leather for crafting.', true),
('Profession (trapper)', 'WIS', true, false, 'Set traps for animals and sell pelts and furs.', true),
('Profession (woodcutter)', 'WIS', true, false, 'Fell trees, prepare lumber, and harvest timber.', true);

-- =====================================================
-- VERIFICATION QUERY
-- =====================================================
-- Query to verify all skills were inserted correctly

/*
SELECT
  CASE
    WHEN name LIKE 'Knowledge%' THEN 'Knowledge'
    WHEN name LIKE 'Perform%' THEN 'Perform'
    WHEN name LIKE 'Craft%' THEN 'Craft'
    WHEN name LIKE 'Profession%' THEN 'Profession'
    ELSE 'Standard'
  END AS category,
  COUNT(*) AS skill_count
FROM skills
GROUP BY category
ORDER BY category;

-- Expected output:
-- Craft: 20
-- Knowledge: 10
-- Perform: 9
-- Profession: 30
-- Standard: 36
-- Total: 105
*/

-- =====================================================
-- NOTES
-- =====================================================
--
-- SKILL CATEGORIES:
-- - Knowledge, Craft, Perform, and Profession each have multiple subcategories
-- - Players can create custom categories in Phase 2 (e.g., Craft (dragonscale armor))
-- - Each category functions as a completely separate skill
--
-- SPECIAL SKILLS:
-- - Speak Language has key_ability = NULL (no check is made)
-- - Each rank in Speak Language = 1 new language learned
--
-- ARMOR CHECK PENALTY:
-- - Applies to: Balance, Climb, Escape Artist, Hide, Jump, Move Silently,
--   Sleight of Hand, Swim, Tumble
-- - Penalty depends on armor type worn
--
-- TRAINED ONLY:
-- - Requires at least 1 rank to attempt
-- - Includes: Decipher Script, Disable Device, Handle Animal, Knowledge (all),
--   Open Lock, Profession (all), Sleight of Hand, Speak Language, Spellcraft,
--   Tumble, Use Magic Device
--
-- TRY AGAIN:
-- - Most skills can be retried
-- - Exceptions: Appraise (same object), Decipher Script (same text),
--   Intimidate (usually), Knowledge (you know it or you don't),
--   Sense Motive (one attempt per behavior)
--
-- SYNERGIES:
-- - Tracked separately in skill_synergy_effects table
-- - Most synergies require 5 ranks in source skill
-- - Grant +2 bonus to related skill checks
-- - See skills.sql for complete synergy examples
--
-- CLASS SKILLS:
-- - Tracked in class_skills junction table
-- - Each class has different list of class skills
-- - See classes-import.sql for wizard class skills example
