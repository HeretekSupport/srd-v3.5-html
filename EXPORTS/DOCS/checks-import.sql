-- ============================================================================
-- D&D 3.5 SRD COMPLETE CHECKS & THROWS IMPORT
-- ============================================================================
-- Creates throw records for ALL core d20 mechanics:
--   - Skill Checks (35)
--   - Saving Throws (3)
--   - Attack Rolls (10)
--   - Ability Checks (6)
--   - Special Checks (4)
-- ============================================================================

SET search_path TO pnpo_3_5_dev;

BEGIN;

-- ============================================================================
-- SECTION 1: FORMULAS
-- ============================================================================

INSERT INTO formula_types (name, description)
VALUES
    ('skill_check', 'Formula for skill check rolls'),
    ('saving_throw', 'Formula for saving throw rolls'),
    ('attack_roll', 'Formula for attack rolls'),
    ('ability_check', 'Formula for ability check rolls'),
    ('special_check', 'Formula for special check types')
ON CONFLICT (name) DO NOTHING;

-- Standard formulas
INSERT INTO formulas (formula_type_id, formula_text, description)
VALUES
    ((SELECT id FROM formula_types WHERE name = 'skill_check'),
     '1d20 + skill_rank + ability_modifier + misc_modifiers',
     'Standard skill check formula'),

    ((SELECT id FROM formula_types WHERE name = 'saving_throw'),
     '1d20 + base_save + ability_modifier + misc_modifiers',
     'Standard saving throw formula'),

    ((SELECT id FROM formula_types WHERE name = 'attack_roll'),
     '1d20 + base_attack_bonus + ability_modifier + size_modifier + misc_modifiers',
     'Standard attack roll formula'),

    ((SELECT id FROM formula_types WHERE name = 'ability_check'),
     '1d20 + ability_modifier + misc_modifiers',
     'Standard ability check formula'),

    ((SELECT id FROM formula_types WHERE name = 'special_check'),
     '1d20 + modifier + misc_modifiers',
     'Generic special check formula')
ON CONFLICT DO NOTHING;


-- ============================================================================
-- SECTION 2: SAVING THROWS
-- ============================================================================

-- FORTITUDE SAVE
INSERT INTO throws (name, throw_type, base_ability, base_die, formula_id, dc_source, is_secret, description)
VALUES (
    'Fortitude',
    'save',
    'CON',
    'd20',
    (SELECT id FROM formulas WHERE description = 'Standard saving throw formula'),
    'external',
    false,
    'Fortitude save to resist disease, poison, death effects, and physical hardship'
);

INSERT INTO saves (throw_id, save_subtype)
VALUES (
    (SELECT id FROM throws WHERE name = 'Fortitude'),
    'fortitude'
);

-- REFLEX SAVE
INSERT INTO throws (name, throw_type, base_ability, base_die, formula_id, dc_source, is_secret, description)
VALUES (
    'Reflex',
    'save',
    'DEX',
    'd20',
    (SELECT id FROM formulas WHERE description = 'Standard saving throw formula'),
    'external',
    false,
    'Reflex save to avoid fireballs, traps, and other attacks you can dodge'
);

INSERT INTO saves (throw_id, save_subtype)
VALUES (
    (SELECT id FROM throws WHERE name = 'Reflex'),
    'reflex'
);

-- WILL SAVE
INSERT INTO throws (name, throw_type, base_ability, base_die, formula_id, dc_source, is_secret, description)
VALUES (
    'Will',
    'save',
    'WIS',
    'd20',
    (SELECT id FROM formulas WHERE description = 'Standard saving throw formula'),
    'external',
    false,
    'Will save to resist mental influence, charms, compulsions, and illusions'
);

INSERT INTO saves (throw_id, save_subtype)
VALUES (
    (SELECT id FROM throws WHERE name = 'Will'),
    'will'
);


-- ============================================================================
-- SECTION 3: ATTACK ROLLS
-- ============================================================================

-- MELEE ATTACK
INSERT INTO throws (name, throw_type, base_ability, base_die, formula_id, dc_source, is_secret, description)
VALUES (
    'Melee Attack',
    'attack',
    'STR',
    'd20',
    (SELECT id FROM formulas WHERE description = 'Standard attack roll formula'),
    'external',
    false,
    'Standard melee attack roll'
);

INSERT INTO attacks (throw_id, attack_subtype, is_touch, can_crit, provokes_aoo)
VALUES (
    (SELECT id FROM throws WHERE name = 'Melee Attack'),
    'melee',
    false,
    true,
    false
);

-- RANGED ATTACK
INSERT INTO throws (name, throw_type, base_ability, base_die, formula_id, dc_source, is_secret, description)
VALUES (
    'Ranged Attack',
    'attack',
    'DEX',
    'd20',
    (SELECT id FROM formulas WHERE description = 'Standard attack roll formula'),
    'external',
    false,
    'Standard ranged attack roll'
);

INSERT INTO attacks (throw_id, attack_subtype, is_touch, can_crit, provokes_aoo)
VALUES (
    (SELECT id FROM throws WHERE name = 'Ranged Attack'),
    'ranged',
    false,
    true,
    true
);

-- MELEE TOUCH ATTACK
INSERT INTO throws (name, throw_type, base_ability, base_die, formula_id, dc_source, is_secret, description)
VALUES (
    'Melee Touch Attack',
    'attack',
    'STR',
    'd20',
    (SELECT id FROM formulas WHERE description = 'Standard attack roll formula'),
    'external',
    false,
    'Melee touch attack (ignores armor, shield, and natural armor bonuses)'
);

INSERT INTO attacks (throw_id, attack_subtype, is_touch, can_crit, provokes_aoo)
VALUES (
    (SELECT id FROM throws WHERE name = 'Melee Touch Attack'),
    'melee',
    true,
    true,
    false
);

-- RANGED TOUCH ATTACK
INSERT INTO throws (name, throw_type, base_ability, base_die, formula_id, dc_source, is_secret, description)
VALUES (
    'Ranged Touch Attack',
    'attack',
    'DEX',
    'd20',
    (SELECT id FROM formulas WHERE description = 'Standard attack roll formula'),
    'external',
    false,
    'Ranged touch attack (ignores armor, shield, and natural armor bonuses)'
);

INSERT INTO attacks (throw_id, attack_subtype, is_touch, can_crit, provokes_aoo)
VALUES (
    (SELECT id FROM throws WHERE name = 'Ranged Touch Attack'),
    'ranged',
    true,
    true,
    true
);

-- GRAPPLE CHECK
INSERT INTO throws (name, throw_type, base_ability, base_die, formula_id, dc_source, is_secret, description)
VALUES (
    'Grapple',
    'attack',
    'STR',
    'd20',
    (SELECT id FROM formulas WHERE description = 'Standard attack roll formula'),
    'comparative',
    false,
    'Grapple check to grab and hold an opponent'
);

INSERT INTO attacks (throw_id, attack_subtype, is_touch, can_crit, provokes_aoo)
VALUES (
    (SELECT id FROM throws WHERE name = 'Grapple'),
    'melee',
    true,
    false,
    true
);

-- BULL RUSH CHECK
INSERT INTO throws (name, throw_type, base_ability, base_die, formula_id, dc_source, is_secret, description)
VALUES (
    'Bull Rush',
    'attack',
    'STR',
    'd20',
    (SELECT id FROM formulas WHERE description = 'Standard attack roll formula'),
    'comparative',
    false,
    'Bull rush check to push an opponent back'
);

INSERT INTO attacks (throw_id, attack_subtype, is_touch, can_crit, provokes_aoo)
VALUES (
    (SELECT id FROM throws WHERE name = 'Bull Rush'),
    'melee',
    false,
    false,
    true
);

-- DISARM CHECK
INSERT INTO throws (name, throw_type, base_ability, base_die, formula_id, dc_source, is_secret, description)
VALUES (
    'Disarm',
    'attack',
    'STR',
    'd20',
    (SELECT id FROM formulas WHERE description = 'Standard attack roll formula'),
    'comparative',
    false,
    'Disarm check to knock a weapon from opponent''s grasp (can use DEX with light weapons)'
);

INSERT INTO attacks (throw_id, attack_subtype, is_touch, can_crit, provokes_aoo)
VALUES (
    (SELECT id FROM throws WHERE name = 'Disarm'),
    'melee',
    false,
    false,
    true
);

-- OVERRUN CHECK
INSERT INTO throws (name, throw_type, base_ability, base_die, formula_id, dc_source, is_secret, description)
VALUES (
    'Overrun',
    'attack',
    'STR',
    'd20',
    (SELECT id FROM formulas WHERE description = 'Standard attack roll formula'),
    'comparative',
    false,
    'Overrun check to run over an opponent'
);

INSERT INTO attacks (throw_id, attack_subtype, is_touch, can_crit, provokes_aoo)
VALUES (
    (SELECT id FROM throws WHERE name = 'Overrun'),
    'melee',
    false,
    false,
    true
);

-- SUNDER CHECK
INSERT INTO throws (name, throw_type, base_ability, base_die, formula_id, dc_source, is_secret, description)
VALUES (
    'Sunder',
    'attack',
    'STR',
    'd20',
    (SELECT id FROM formulas WHERE description = 'Standard attack roll formula'),
    'comparative',
    false,
    'Sunder check to damage an opponent''s weapon or shield'
);

INSERT INTO attacks (throw_id, attack_subtype, is_touch, can_crit, provokes_aoo)
VALUES (
    (SELECT id FROM throws WHERE name = 'Sunder'),
    'melee',
    false,
    false,
    true
);

-- TRIP CHECK
INSERT INTO throws (name, throw_type, base_ability, base_die, formula_id, dc_source, is_secret, description)
VALUES (
    'Trip',
    'attack',
    'STR',
    'd20',
    (SELECT id FROM formulas WHERE description = 'Standard attack roll formula'),
    'comparative',
    false,
    'Trip check to knock an opponent prone (can use DEX with light weapons)'
);

INSERT INTO attacks (throw_id, attack_subtype, is_touch, can_crit, provokes_aoo)
VALUES (
    (SELECT id FROM throws WHERE name = 'Trip'),
    'melee',
    false,
    false,
    true
);


-- ============================================================================
-- SECTION 4: ABILITY CHECKS
-- ============================================================================

-- STRENGTH CHECK
INSERT INTO throws (name, throw_type, base_ability, base_die, formula_id, dc_source, is_secret, description)
VALUES (
    'Strength Check',
    'check',
    'STR',
    'd20',
    (SELECT id FROM formulas WHERE description = 'Standard ability check formula'),
    'fixed',
    false,
    'Strength check for breaking objects, forcing doors, and raw physical power'
);

INSERT INTO checks (throw_id, check_subtype, take_10_allowed, take_20_allowed, retry_allowed, typical_dc_range)
VALUES (
    (SELECT id FROM throws WHERE name = 'Strength Check'),
    'ability',
    true,
    true,
    true,
    'DC 10 (weak wooden door) to DC 30 (iron bars)'
);

-- DEXTERITY CHECK
INSERT INTO throws (name, throw_type, base_ability, base_die, formula_id, dc_source, is_secret, description)
VALUES (
    'Dexterity Check',
    'check',
    'DEX',
    'd20',
    (SELECT id FROM formulas WHERE description = 'Standard ability check formula'),
    'fixed',
    false,
    'Dexterity check for tasks requiring coordination or agility (when no specific skill applies)'
);

INSERT INTO checks (throw_id, check_subtype, take_10_allowed, take_20_allowed, retry_allowed, typical_dc_range)
VALUES (
    (SELECT id FROM throws WHERE name = 'Dexterity Check'),
    'ability',
    true,
    false,
    true,
    'Varies by task'
);

-- CONSTITUTION CHECK
INSERT INTO throws (name, throw_type, base_ability, base_die, formula_id, dc_source, is_secret, description)
VALUES (
    'Constitution Check',
    'check',
    'CON',
    'd20',
    (SELECT id FROM formulas WHERE description = 'Standard ability check formula'),
    'fixed',
    false,
    'Constitution check for endurance tasks (holding breath, avoiding nonlethal damage from conditions)'
);

INSERT INTO checks (throw_id, check_subtype, take_10_allowed, take_20_allowed, retry_allowed, typical_dc_range)
VALUES (
    (SELECT id FROM throws WHERE name = 'Constitution Check'),
    'ability',
    false,
    false,
    false,
    'DC 10 (hold breath first round) to DC 20+ (extreme endurance)'
);

-- INTELLIGENCE CHECK
INSERT INTO throws (name, throw_type, base_ability, base_die, formula_id, dc_source, is_secret, description)
VALUES (
    'Intelligence Check',
    'check',
    'INT',
    'd20',
    (SELECT id FROM formulas WHERE description = 'Standard ability check formula'),
    'fixed',
    false,
    'Intelligence check for reasoning and problem-solving (when no specific skill applies)'
);

INSERT INTO checks (throw_id, check_subtype, take_10_allowed, take_20_allowed, retry_allowed, typical_dc_range)
VALUES (
    (SELECT id FROM throws WHERE name = 'Intelligence Check'),
    'ability',
    true,
    true,
    true,
    'Varies by task'
);

-- WISDOM CHECK
INSERT INTO throws (name, throw_type, base_ability, base_die, formula_id, dc_source, is_secret, description)
VALUES (
    'Wisdom Check',
    'check',
    'WIS',
    'd20',
    (SELECT id FROM formulas WHERE description = 'Standard ability check formula'),
    'fixed',
    false,
    'Wisdom check for intuition and awareness (when no specific skill applies)'
);

INSERT INTO checks (throw_id, check_subtype, take_10_allowed, take_20_allowed, retry_allowed, typical_dc_range)
VALUES (
    (SELECT id FROM throws WHERE name = 'Wisdom Check'),
    'ability',
    true,
    false,
    true,
    'Varies by task'
);

-- CHARISMA CHECK
INSERT INTO throws (name, throw_type, base_ability, base_die, formula_id, dc_source, is_secret, description)
VALUES (
    'Charisma Check',
    'check',
    'CHA',
    'd20',
    (SELECT id FROM formulas WHERE description = 'Standard ability check formula'),
    'fixed',
    false,
    'Charisma check for force of personality (when no specific skill applies)'
);

INSERT INTO checks (throw_id, check_subtype, take_10_allowed, take_20_allowed, retry_allowed, typical_dc_range)
VALUES (
    (SELECT id FROM throws WHERE name = 'Charisma Check'),
    'ability',
    true,
    false,
    true,
    'Varies by task'
);


-- ============================================================================
-- SECTION 5: SPECIAL CHECKS
-- ============================================================================

-- INITIATIVE
INSERT INTO throws (name, throw_type, base_ability, base_die, formula_id, dc_source, is_secret, description)
VALUES (
    'Initiative',
    'check',
    'DEX',
    'd20',
    (SELECT id FROM formulas WHERE description = 'Standard ability check formula'),
    'comparative',
    false,
    'Initiative check to determine action order in combat'
);

INSERT INTO checks (throw_id, check_subtype, take_10_allowed, take_20_allowed, retry_allowed, typical_dc_range)
VALUES (
    (SELECT id FROM throws WHERE name = 'Initiative'),
    'initiative',
    false,
    false,
    false,
    'Comparative - highest goes first'
);

-- CASTER LEVEL CHECK
INSERT INTO throws (name, throw_type, base_ability, base_die, formula_id, dc_source, is_secret, description)
VALUES (
    'Caster Level Check',
    'check',
    NULL,
    'd20',
    (SELECT id FROM formulas WHERE description = 'Generic special check formula'),
    'fixed',
    false,
    'Caster level check to overcome spell resistance (1d20 + caster level)'
);

INSERT INTO checks (throw_id, check_subtype, take_10_allowed, take_20_allowed, retry_allowed, typical_dc_range)
VALUES (
    (SELECT id FROM throws WHERE name = 'Caster Level Check'),
    'ability',
    false,
    false,
    false,
    'Must meet or exceed target''s spell resistance'
);

-- TURN UNDEAD CHECK
INSERT INTO throws (name, throw_type, base_ability, base_die, formula_id, dc_source, is_secret, description)
VALUES (
    'Turn Undead Check',
    'check',
    'CHA',
    'd20',
    (SELECT id FROM formulas WHERE description = 'Standard ability check formula'),
    'fixed',
    false,
    'Turn/rebuke undead check (1d20 + CHA modifier) to determine HD affected'
);

INSERT INTO checks (throw_id, check_subtype, take_10_allowed, take_20_allowed, retry_allowed, typical_dc_range)
VALUES (
    (SELECT id FROM throws WHERE name = 'Turn Undead Check'),
    'ability',
    false,
    false,
    false,
    'Result determines most powerful undead HD affected (see turning table)'
);

-- LEVEL CHECK (for opposed Intimidate)
INSERT INTO throws (name, throw_type, base_ability, base_die, formula_id, dc_source, is_secret, description)
VALUES (
    'Level Check',
    'check',
    'WIS',
    'd20',
    (SELECT id FROM formulas WHERE description = 'Standard ability check formula'),
    'comparative',
    false,
    'Level check to resist Intimidate (1d20 + character level/HD + WIS mod + fear save mods)'
);

INSERT INTO checks (throw_id, check_subtype, take_10_allowed, take_20_allowed, retry_allowed, typical_dc_range)
VALUES (
    (SELECT id FROM throws WHERE name = 'Level Check'),
    'ability',
    false,
    false,
    false,
    'Opposes Intimidate check'
);


-- ============================================================================
-- SECTION 6: SKILL CHECKS (35 skills)
-- ============================================================================

-- SKILL 1: APPRAISE (Int)
INSERT INTO throws (name, throw_type, base_ability, base_die, formula_id, dc_source, is_secret, description)
VALUES (
    'Appraise',
    'check',
    'INT',
    'd20',
    (SELECT id FROM formulas WHERE description = 'Standard skill check formula'),
    'fixed',
    false,
    'Appraise check to determine item value'
);

INSERT INTO checks (throw_id, check_subtype, take_10_allowed, take_20_allowed, retry_allowed, typical_dc_range)
VALUES (
    (SELECT id FROM throws WHERE name = 'Appraise'),
    'skill',
    true,
    true,
    false,
    'DC 12 (common items) to DC 20+ (rare items)'
);

-- SKILL 2: BALANCE (Dex; Armor Check Penalty)
INSERT INTO throws (name, throw_type, base_ability, base_die, formula_id, dc_source, is_secret, description)
VALUES (
    'Balance',
    'check',
    'DEX',
    'd20',
    (SELECT id FROM formulas WHERE description = 'Standard skill check formula'),
    'fixed',
    false,
    'Balance check to move across narrow or unstable surfaces'
);

INSERT INTO checks (throw_id, check_subtype, take_10_allowed, take_20_allowed, retry_allowed, typical_dc_range)
VALUES (
    (SELECT id FROM throws WHERE name = 'Balance'),
    'skill',
    true,
    false,
    false,
    'DC 10 (narrow surface) to DC 20+ (angled narrow surface)'
);

-- SKILL 3: BLUFF (Cha)
INSERT INTO throws (name, throw_type, base_ability, base_die, formula_id, dc_source, is_secret, description)
VALUES (
    'Bluff',
    'check',
    'CHA',
    'd20',
    (SELECT id FROM formulas WHERE description = 'Standard skill check formula'),
    'comparative',
    false,
    'Bluff check to deceive others (opposed by Sense Motive)'
);

INSERT INTO checks (throw_id, check_subtype, take_10_allowed, take_20_allowed, retry_allowed, typical_dc_range)
VALUES (
    (SELECT id FROM throws WHERE name = 'Bluff'),
    'skill',
    true,
    false,
    false,
    'Opposed by target''s Sense Motive check'
);

-- SKILL 4: CLIMB (Str; Armor Check Penalty)
INSERT INTO throws (name, throw_type, base_ability, base_die, formula_id, dc_source, is_secret, description)
VALUES (
    'Climb',
    'check',
    'STR',
    'd20',
    (SELECT id FROM formulas WHERE description = 'Standard skill check formula'),
    'fixed',
    false,
    'Climb check to scale walls and slopes'
);

INSERT INTO checks (throw_id, check_subtype, take_10_allowed, take_20_allowed, retry_allowed, typical_dc_range)
VALUES (
    (SELECT id FROM throws WHERE name = 'Climb'),
    'skill',
    true,
    true,
    true,
    'DC 0 (rope with wall) to DC 30 (overhang or ceiling)'
);

-- SKILL 5: CONCENTRATION (Con)
INSERT INTO throws (name, throw_type, base_ability, base_die, formula_id, dc_source, is_secret, description)
VALUES (
    'Concentration',
    'check',
    'CON',
    'd20',
    (SELECT id FROM formulas WHERE description = 'Standard skill check formula'),
    'fixed',
    false,
    'Concentration check to maintain focus while casting or concentrating on a spell'
);

INSERT INTO checks (throw_id, check_subtype, take_10_allowed, take_20_allowed, retry_allowed, typical_dc_range)
VALUES (
    (SELECT id FROM throws WHERE name = 'Concentration'),
    'skill',
    false,
    false,
    true,
    'DC 10 + damage dealt, or DC 15 + spell level (casting defensively)'
);

-- SKILL 6: CRAFT (Int)
INSERT INTO throws (name, throw_type, base_ability, base_die, formula_id, dc_source, is_secret, description)
VALUES (
    'Craft',
    'check',
    'INT',
    'd20',
    (SELECT id FROM formulas WHERE description = 'Standard skill check formula'),
    'fixed',
    false,
    'Craft check to create items'
);

INSERT INTO checks (throw_id, check_subtype, take_10_allowed, take_20_allowed, retry_allowed, typical_dc_range)
VALUES (
    (SELECT id FROM throws WHERE name = 'Craft'),
    'skill',
    true,
    true,
    true,
    'DC 10 (simple items) to DC 20+ (complex or high-quality items)'
);

-- SKILL 7: DECIPHER SCRIPT (Int; Trained Only)
INSERT INTO throws (name, throw_type, base_ability, base_die, formula_id, dc_source, is_secret, description)
VALUES (
    'Decipher Script',
    'check',
    'INT',
    'd20',
    (SELECT id FROM formulas WHERE description = 'Standard skill check formula'),
    'fixed',
    true,
    'Decipher Script check to understand unfamiliar writing'
);

INSERT INTO checks (throw_id, check_subtype, take_10_allowed, take_20_allowed, retry_allowed, typical_dc_range)
VALUES (
    (SELECT id FROM throws WHERE name = 'Decipher Script'),
    'skill',
    true,
    true,
    false,
    'DC 20 (simple message) to DC 30 (exotic or ancient writing)'
);

-- SKILL 8: DIPLOMACY (Cha)
INSERT INTO throws (name, throw_type, base_ability, base_die, formula_id, dc_source, is_secret, description)
VALUES (
    'Diplomacy',
    'check',
    'CHA',
    'd20',
    (SELECT id FROM formulas WHERE description = 'Standard skill check formula'),
    'fixed',
    false,
    'Diplomacy check to change NPC attitudes or negotiate'
);

INSERT INTO checks (throw_id, check_subtype, take_10_allowed, take_20_allowed, retry_allowed, typical_dc_range)
VALUES (
    (SELECT id FROM throws WHERE name = 'Diplomacy'),
    'skill',
    true,
    false,
    false,
    'DC varies by initial attitude (hostile = DC 25+, friendly = DC 0)'
);

-- SKILL 9: DISABLE DEVICE (Int; Trained Only)
INSERT INTO throws (name, throw_type, base_ability, base_die, formula_id, dc_source, is_secret, description)
VALUES (
    'Disable Device',
    'check',
    'INT',
    'd20',
    (SELECT id FROM formulas WHERE description = 'Standard skill check formula'),
    'fixed',
    false,
    'Disable Device check to disarm traps or open locks'
);

INSERT INTO checks (throw_id, check_subtype, take_10_allowed, take_20_allowed, retry_allowed, typical_dc_range)
VALUES (
    (SELECT id FROM throws WHERE name = 'Disable Device'),
    'skill',
    true,
    true,
    true,
    'DC 20 (simple device) to DC 30+ (complex or magical traps)'
);

-- SKILL 10: DISGUISE (Cha)
INSERT INTO throws (name, throw_type, base_ability, base_die, formula_id, dc_source, is_secret, description)
VALUES (
    'Disguise',
    'check',
    'CHA',
    'd20',
    (SELECT id FROM formulas WHERE description = 'Standard skill check formula'),
    'comparative',
    false,
    'Disguise check to alter appearance (opposed by Spot)'
);

INSERT INTO checks (throw_id, check_subtype, take_10_allowed, take_20_allowed, retry_allowed, typical_dc_range)
VALUES (
    (SELECT id FROM throws WHERE name = 'Disguise'),
    'skill',
    true,
    true,
    true,
    'Opposed by Spot check (modifiers for different gender, race, age, size)'
);

-- SKILL 11: ESCAPE ARTIST (Dex; Armor Check Penalty)
INSERT INTO throws (name, throw_type, base_ability, base_die, formula_id, dc_source, is_secret, description)
VALUES (
    'Escape Artist',
    'check',
    'DEX',
    'd20',
    (SELECT id FROM formulas WHERE description = 'Standard skill check formula'),
    'fixed',
    false,
    'Escape Artist check to slip bonds or squeeze through tight spaces'
);

INSERT INTO checks (throw_id, check_subtype, take_10_allowed, take_20_allowed, retry_allowed, typical_dc_range)
VALUES (
    (SELECT id FROM throws WHERE name = 'Escape Artist'),
    'skill',
    true,
    true,
    true,
    'DC varies by restraint: ropes (binder''s Dex check +10), manacles (DC 30), masterwork manacles (DC 35)'
);

-- SKILL 12: FORGERY (Int)
INSERT INTO throws (name, throw_type, base_ability, base_die, formula_id, dc_source, is_secret, description)
VALUES (
    'Forgery',
    'check',
    'INT',
    'd20',
    (SELECT id FROM formulas WHERE description = 'Standard skill check formula'),
    'comparative',
    false,
    'Forgery check to create false documents (opposed by Forgery)'
);

INSERT INTO checks (throw_id, check_subtype, take_10_allowed, take_20_allowed, retry_allowed, typical_dc_range)
VALUES (
    (SELECT id FROM throws WHERE name = 'Forgery'),
    'skill',
    true,
    false,
    false,
    'Opposed by reader''s Forgery check'
);

-- SKILL 13: GATHER INFORMATION (Cha)
INSERT INTO throws (name, throw_type, base_ability, base_die, formula_id, dc_source, is_secret, description)
VALUES (
    'Gather Information',
    'check',
    'CHA',
    'd20',
    (SELECT id FROM formulas WHERE description = 'Standard skill check formula'),
    'fixed',
    false,
    'Gather Information check to learn rumors and information in a settlement'
);

INSERT INTO checks (throw_id, check_subtype, take_10_allowed, take_20_allowed, retry_allowed, typical_dc_range)
VALUES (
    (SELECT id FROM throws WHERE name = 'Gather Information'),
    'skill',
    true,
    true,
    true,
    'DC 10 (common knowledge) to DC 25+ (obscure or secret information)'
);

-- SKILL 14: HANDLE ANIMAL (Cha; Trained Only)
INSERT INTO throws (name, throw_type, base_ability, base_die, formula_id, dc_source, is_secret, description)
VALUES (
    'Handle Animal',
    'check',
    'CHA',
    'd20',
    (SELECT id FROM formulas WHERE description = 'Standard skill check formula'),
    'fixed',
    false,
    'Handle Animal check to train and control animals'
);

INSERT INTO checks (throw_id, check_subtype, take_10_allowed, take_20_allowed, retry_allowed, typical_dc_range)
VALUES (
    (SELECT id FROM throws WHERE name = 'Handle Animal'),
    'skill',
    true,
    true,
    true,
    'DC 10 (handle animal) to DC 25 (teach unusual purpose or rear wild animal)'
);

-- SKILL 15: HEAL (Wis)
INSERT INTO throws (name, throw_type, base_ability, base_die, formula_id, dc_source, is_secret, description)
VALUES (
    'Heal',
    'check',
    'WIS',
    'd20',
    (SELECT id FROM formulas WHERE description = 'Standard skill check formula'),
    'fixed',
    false,
    'Heal check to provide medical aid'
);

INSERT INTO checks (throw_id, check_subtype, take_10_allowed, take_20_allowed, retry_allowed, typical_dc_range)
VALUES (
    (SELECT id FROM throws WHERE name = 'Heal'),
    'skill',
    true,
    false,
    false,
    'DC 15 (first aid, long-term care, treat caltrops) or poison/disease DC'
);

-- SKILL 16: HIDE (Dex; Armor Check Penalty)
INSERT INTO throws (name, throw_type, base_ability, base_die, formula_id, dc_source, is_secret, description)
VALUES (
    'Hide',
    'check',
    'DEX',
    'd20',
    (SELECT id FROM formulas WHERE description = 'Standard skill check formula'),
    'comparative',
    true,
    'Hide check to avoid detection (opposed by Spot)'
);

INSERT INTO checks (throw_id, check_subtype, take_10_allowed, take_20_allowed, retry_allowed, typical_dc_range)
VALUES (
    (SELECT id FROM throws WHERE name = 'Hide'),
    'skill',
    false,
    false,
    true,
    'Opposed by Spot check (requires cover or concealment)'
);

-- SKILL 17: INTIMIDATE (Cha)
INSERT INTO throws (name, throw_type, base_ability, base_die, formula_id, dc_source, is_secret, description)
VALUES (
    'Intimidate',
    'check',
    'CHA',
    'd20',
    (SELECT id FROM formulas WHERE description = 'Standard skill check formula'),
    'comparative',
    false,
    'Intimidate check to demoralize or coerce (opposed by level check)'
);

INSERT INTO checks (throw_id, check_subtype, take_10_allowed, take_20_allowed, retry_allowed, typical_dc_range)
VALUES (
    (SELECT id FROM throws WHERE name = 'Intimidate'),
    'skill',
    true,
    false,
    false,
    'Opposed by target''s level check (1d20 + HD + Wis mod + save vs fear mods)'
);

-- SKILL 18: JUMP (Str; Armor Check Penalty)
INSERT INTO throws (name, throw_type, base_ability, base_die, formula_id, dc_source, is_secret, description)
VALUES (
    'Jump',
    'check',
    'STR',
    'd20',
    (SELECT id FROM formulas WHERE description = 'Standard skill check formula'),
    'fixed',
    false,
    'Jump check to leap across distances or reach heights'
);

INSERT INTO checks (throw_id, check_subtype, take_10_allowed, take_20_allowed, retry_allowed, typical_dc_range)
VALUES (
    (SELECT id FROM throws WHERE name = 'Jump'),
    'skill',
    true,
    false,
    true,
    'DC = distance in feet (long jump) or DC = 4x height in feet (high jump)'
);

-- SKILL 19: KNOWLEDGE (Int; Trained Only)
INSERT INTO throws (name, throw_type, base_ability, base_die, formula_id, dc_source, is_secret, description)
VALUES (
    'Knowledge',
    'check',
    'INT',
    'd20',
    (SELECT id FROM formulas WHERE description = 'Standard skill check formula'),
    'fixed',
    true,
    'Knowledge check to recall information'
);

INSERT INTO checks (throw_id, check_subtype, take_10_allowed, take_20_allowed, retry_allowed, typical_dc_range)
VALUES (
    (SELECT id FROM throws WHERE name = 'Knowledge'),
    'skill',
    true,
    true,
    false,
    'DC 10 (common) to DC 30 (obscure or legendary knowledge)'
);

-- SKILL 20: LISTEN (Wis)
INSERT INTO throws (name, throw_type, base_ability, base_die, formula_id, dc_source, is_secret, description)
VALUES (
    'Listen',
    'check',
    'WIS',
    'd20',
    (SELECT id FROM formulas WHERE description = 'Standard skill check formula'),
    'fixed',
    true,
    'Listen check to hear sounds or eavesdrop'
);

INSERT INTO checks (throw_id, check_subtype, take_10_allowed, take_20_allowed, retry_allowed, typical_dc_range)
VALUES (
    (SELECT id FROM throws WHERE name = 'Listen'),
    'skill',
    true,
    true,
    true,
    'DC 0 (people talking) to DC 20+ (through door or at great distance)'
);

-- SKILL 21: MOVE SILENTLY (Dex; Armor Check Penalty)
INSERT INTO throws (name, throw_type, base_ability, base_die, formula_id, dc_source, is_secret, description)
VALUES (
    'Move Silently',
    'check',
    'DEX',
    'd20',
    (SELECT id FROM formulas WHERE description = 'Standard skill check formula'),
    'comparative',
    true,
    'Move Silently check to move quietly (opposed by Listen)'
);

INSERT INTO checks (throw_id, check_subtype, take_10_allowed, take_20_allowed, retry_allowed, typical_dc_range)
VALUES (
    (SELECT id FROM throws WHERE name = 'Move Silently'),
    'skill',
    false,
    false,
    true,
    'Opposed by Listen check'
);

-- SKILL 22: OPEN LOCK (Dex; Trained Only)
INSERT INTO throws (name, throw_type, base_ability, base_die, formula_id, dc_source, is_secret, description)
VALUES (
    'Open Lock',
    'check',
    'DEX',
    'd20',
    (SELECT id FROM formulas WHERE description = 'Standard skill check formula'),
    'fixed',
    false,
    'Open Lock check to pick locks'
);

INSERT INTO checks (throw_id, check_subtype, take_10_allowed, take_20_allowed, retry_allowed, typical_dc_range)
VALUES (
    (SELECT id FROM throws WHERE name = 'Open Lock'),
    'skill',
    true,
    true,
    true,
    'DC 20 (simple lock) to DC 40 (amazing lock)'
);

-- SKILL 23: PERFORM (Cha)
INSERT INTO throws (name, throw_type, base_ability, base_die, formula_id, dc_source, is_secret, description)
VALUES (
    'Perform',
    'check',
    'CHA',
    'd20',
    (SELECT id FROM formulas WHERE description = 'Standard skill check formula'),
    'fixed',
    false,
    'Perform check to entertain audiences'
);

INSERT INTO checks (throw_id, check_subtype, take_10_allowed, take_20_allowed, retry_allowed, typical_dc_range)
VALUES (
    (SELECT id FROM throws WHERE name = 'Perform'),
    'skill',
    true,
    true,
    true,
    'DC 10 (routine performance) to DC 30 (extraordinary performance)'
);

-- SKILL 24: PROFESSION (Wis; Trained Only)
INSERT INTO throws (name, throw_type, base_ability, base_die, formula_id, dc_source, is_secret, description)
VALUES (
    'Profession',
    'check',
    'WIS',
    'd20',
    (SELECT id FROM formulas WHERE description = 'Standard skill check formula'),
    'fixed',
    false,
    'Profession check to earn money practicing a trade'
);

INSERT INTO checks (throw_id, check_subtype, take_10_allowed, take_20_allowed, retry_allowed, typical_dc_range)
VALUES (
    (SELECT id FROM throws WHERE name = 'Profession'),
    'skill',
    true,
    true,
    true,
    'DC 10+ determines weekly income (check result x 1/2 = gp earned per week)'
);

-- SKILL 25: RIDE (Dex)
INSERT INTO throws (name, throw_type, base_ability, base_die, formula_id, dc_source, is_secret, description)
VALUES (
    'Ride',
    'check',
    'DEX',
    'd20',
    (SELECT id FROM formulas WHERE description = 'Standard skill check formula'),
    'fixed',
    false,
    'Ride check to control mounts in difficult situations'
);

INSERT INTO checks (throw_id, check_subtype, take_10_allowed, take_20_allowed, retry_allowed, typical_dc_range)
VALUES (
    (SELECT id FROM throws WHERE name = 'Ride'),
    'skill',
    true,
    false,
    true,
    'DC 5 (guide with knees) to DC 20 (fast mount/dismount)'
);

-- SKILL 26: SEARCH (Int)
INSERT INTO throws (name, throw_type, base_ability, base_die, formula_id, dc_source, is_secret, description)
VALUES (
    'Search',
    'check',
    'INT',
    'd20',
    (SELECT id FROM formulas WHERE description = 'Standard skill check formula'),
    'fixed',
    true,
    'Search check to find hidden objects, traps, or secret doors'
);

INSERT INTO checks (throw_id, check_subtype, take_10_allowed, take_20_allowed, retry_allowed, typical_dc_range)
VALUES (
    (SELECT id FROM throws WHERE name = 'Search'),
    'skill',
    true,
    true,
    true,
    'DC 10 (simple secret door) to DC 30+ (well-hidden trap or compartment)'
);

-- SKILL 27: SENSE MOTIVE (Wis)
INSERT INTO throws (name, throw_type, base_ability, base_die, formula_id, dc_source, is_secret, description)
VALUES (
    'Sense Motive',
    'check',
    'WIS',
    'd20',
    (SELECT id FROM formulas WHERE description = 'Standard skill check formula'),
    'comparative',
    true,
    'Sense Motive check to detect lies and read behavior (opposes Bluff)'
);

INSERT INTO checks (throw_id, check_subtype, take_10_allowed, take_20_allowed, retry_allowed, typical_dc_range)
VALUES (
    (SELECT id FROM throws WHERE name = 'Sense Motive'),
    'skill',
    true,
    false,
    false,
    'Opposes Bluff check or DC 20 (detect enchantment)'
);

-- SKILL 28: SLEIGHT OF HAND (Dex; Trained Only; Armor Check Penalty)
INSERT INTO throws (name, throw_type, base_ability, base_die, formula_id, dc_source, is_secret, description)
VALUES (
    'Sleight of Hand',
    'check',
    'DEX',
    'd20',
    (SELECT id FROM formulas WHERE description = 'Standard skill check formula'),
    'comparative',
    true,
    'Sleight of Hand check for pickpocketing and legerdemain (opposed by Spot)'
);

INSERT INTO checks (throw_id, check_subtype, take_10_allowed, take_20_allowed, retry_allowed, typical_dc_range)
VALUES (
    (SELECT id FROM throws WHERE name = 'Sleight of Hand'),
    'skill',
    true,
    false,
    true,
    'DC 10 (palm coin-sized object) to DC 20 (take from another, opposed by Spot)'
);

-- SKILL 30: SPELLCRAFT (Int; Trained Only)
INSERT INTO throws (name, throw_type, base_ability, base_die, formula_id, dc_source, is_secret, description)
VALUES (
    'Spellcraft',
    'check',
    'INT',
    'd20',
    (SELECT id FROM formulas WHERE description = 'Standard skill check formula'),
    'fixed',
    false,
    'Spellcraft check to identify spells and magic effects'
);

INSERT INTO checks (throw_id, check_subtype, take_10_allowed, take_20_allowed, retry_allowed, typical_dc_range)
VALUES (
    (SELECT id FROM throws WHERE name = 'Spellcraft'),
    'skill',
    true,
    true,
    false,
    'DC 15 + spell level (identify spell being cast) or DC 20 + caster level (identify magic item properties)'
);

-- SKILL 31: SPOT (Wis)
INSERT INTO throws (name, throw_type, base_ability, base_die, formula_id, dc_source, is_secret, description)
VALUES (
    'Spot',
    'check',
    'WIS',
    'd20',
    (SELECT id FROM formulas WHERE description = 'Standard skill check formula'),
    'comparative',
    true,
    'Spot check to notice things and oppose Hide/Disguise/Sleight of Hand'
);

INSERT INTO checks (throw_id, check_subtype, take_10_allowed, take_20_allowed, retry_allowed, typical_dc_range)
VALUES (
    (SELECT id FROM throws WHERE name = 'Spot'),
    'skill',
    true,
    true,
    true,
    'Opposes Hide check, or DC 20+ to notice invisible creature'
);

-- SKILL 32: SURVIVAL (Wis)
INSERT INTO throws (name, throw_type, base_ability, base_die, formula_id, dc_source, is_secret, description)
VALUES (
    'Survival',
    'check',
    'WIS',
    'd20',
    (SELECT id FROM formulas WHERE description = 'Standard skill check formula'),
    'fixed',
    false,
    'Survival check to track, get along in the wild, or avoid hazards'
);

INSERT INTO checks (throw_id, check_subtype, take_10_allowed, take_20_allowed, retry_allowed, typical_dc_range)
VALUES (
    (SELECT id FROM throws WHERE name = 'Survival'),
    'skill',
    true,
    true,
    true,
    'DC 10 (get along in wild) to DC 20+ (track, avoid natural hazards)'
);

-- SKILL 33: SWIM (Str; Armor Check Penalty)
INSERT INTO throws (name, throw_type, base_ability, base_die, formula_id, dc_source, is_secret, description)
VALUES (
    'Swim',
    'check',
    'STR',
    'd20',
    (SELECT id FROM formulas WHERE description = 'Standard skill check formula'),
    'fixed',
    false,
    'Swim check to move through water'
);

INSERT INTO checks (throw_id, check_subtype, take_10_allowed, take_20_allowed, retry_allowed, typical_dc_range)
VALUES (
    (SELECT id FROM throws WHERE name = 'Swim'),
    'skill',
    true,
    false,
    true,
    'DC 10 (calm water) to DC 20 (stormy water)'
);

-- SKILL 34: TUMBLE (Dex; Trained Only; Armor Check Penalty)
INSERT INTO throws (name, throw_type, base_ability, base_die, formula_id, dc_source, is_secret, description)
VALUES (
    'Tumble',
    'check',
    'DEX',
    'd20',
    (SELECT id FROM formulas WHERE description = 'Standard skill check formula'),
    'fixed',
    false,
    'Tumble check for acrobatics and avoiding attacks of opportunity'
);

INSERT INTO checks (throw_id, check_subtype, take_10_allowed, take_20_allowed, retry_allowed, typical_dc_range)
VALUES (
    (SELECT id FROM throws WHERE name = 'Tumble'),
    'skill',
    false,
    false,
    false,
    'DC 15 (avoid AoO while moving through threatened area) to DC 25+ (advanced maneuvers)'
);

-- SKILL 35: USE MAGIC DEVICE (Cha; Trained Only)
INSERT INTO throws (name, throw_type, base_ability, base_die, formula_id, dc_source, is_secret, description)
VALUES (
    'Use Magic Device',
    'check',
    'CHA',
    'd20',
    (SELECT id FROM formulas WHERE description = 'Standard skill check formula'),
    'fixed',
    false,
    'Use Magic Device check to activate magic items'
);

INSERT INTO checks (throw_id, check_subtype, take_10_allowed, take_20_allowed, retry_allowed, typical_dc_range)
VALUES (
    (SELECT id FROM throws WHERE name = 'Use Magic Device'),
    'skill',
    false,
    false,
    true,
    'DC 20 (activate blindly) to DC 30+ (emulate ability score or alignment)'
);

-- SKILL 36: USE ROPE (Dex)
INSERT INTO throws (name, throw_type, base_ability, base_die, formula_id, dc_source, is_secret, description)
VALUES (
    'Use Rope',
    'check',
    'DEX',
    'd20',
    (SELECT id FROM formulas WHERE description = 'Standard skill check formula'),
    'fixed',
    false,
    'Use Rope check to tie knots, bind prisoners, or splice ropes'
);

INSERT INTO checks (throw_id, check_subtype, take_10_allowed, take_20_allowed, retry_allowed, typical_dc_range)
VALUES (
    (SELECT id FROM throws WHERE name = 'Use Rope'),
    'skill',
    true,
    true,
    true,
    'DC 10 (tie firm knot) to DC 15 (tie special knot or bind struggling creature)'
);


COMMIT;

-- ============================================================================
-- COMPLETE SUMMARY
-- ============================================================================
--
-- TOTAL THROWS CREATED: 58
-- TOTAL CHECKS CREATED: 45
-- TOTAL SAVES CREATED: 3
-- TOTAL ATTACKS CREATED: 10
--
-- BREAKDOWN BY CATEGORY:
--
-- 1. SAVING THROWS (3 throws + 3 saves):
--    - Fortitude, Reflex, Will
--
-- 2. ATTACK ROLLS (10 throws + 10 attacks):
--    Standard Attacks:
--      - Melee Attack, Ranged Attack
--      - Melee Touch Attack, Ranged Touch Attack
--    Special Combat Maneuvers (all melee subtype):
--      - Grapple, Bull Rush, Disarm, Overrun, Sunder, Trip
--
-- 3. ABILITY CHECKS (6 throws + 6 checks):
--    - Strength, Dexterity, Constitution
--    - Intelligence, Wisdom, Charisma
--
-- 4. SPECIAL CHECKS (4 throws + 4 checks):
--    - Initiative
--    - Caster Level Check
--    - Turn Undead Check
--    - Level Check (for Intimidate opposition)
--
-- 5. SKILL CHECKS (35 throws + 35 checks):
--    All standard D&D 3.5 skills except Speak Language
--
-- ============================================================================
