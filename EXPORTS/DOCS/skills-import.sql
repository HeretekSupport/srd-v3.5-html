-- =====================================================
-- D&D 3.5 SRD SKILLS - SAMPLE INSERT STATEMENTS
-- =====================================================
-- Schema: pnpo_3_5_dev.skills
-- Source: SRD HTML exports (skills-i.html, skills-ii.html)

SET search_path TO pnpo_3_5_dev;

-- =====================================================
-- EXAMPLE SKILL INSERTS
-- =====================================================

-- Example 1: HEAL (Wisdom-based, no armor penalty, not trained only)
INSERT INTO skills (
  name,
  key_ability,
  trained_only,
  armor_check_penalty,
  description,
  action_type_required,
  try_again,
  special,
  synergy
) VALUES (
  'Heal',
  'WIS',
  false,
  false,
  'Use this skill to keep a dying character from losing hit points, to help others recover faster from wounds, or to treat poison and disease. The DC and effect depend on the task you attempt: First aid (DC 15) to stabilize a dying character; Long-term care (DC 15) to help patients recover at twice the normal rate; Treat wound from caltrops/spike growth/spike stones (DC 15); Treat poison (DC = poison''s save DC); Treat disease (DC = disease''s save DC).',
  'standard',
  false,
  'A character with the Self-Sufficient feat gets a +2 bonus on Heal checks. A healer''s kit gives you a +2 circumstance bonus on Heal checks.',
  NULL
);

-- Example 2: CONCENTRATION (Constitution-based, required for spellcasting)
INSERT INTO skills (
  name,
  key_ability,
  trained_only,
  armor_check_penalty,
  description,
  action_type_required,
  try_again,
  special,
  synergy
) VALUES (
  'Concentration',
  'CON',
  false,
  false,
  'You must make a Concentration check whenever you might potentially be distracted (by taking damage, by harsh weather, and so on) while engaged in some action that requires your full attention. Such actions include casting a spell, concentrating on an active spell, directing a spell, using a spell-like ability, or using a skill that would provoke an attack of opportunity. If the check succeeds, you may continue with the action as normal. If the check fails, the action automatically fails and is wasted.',
  'not-an-action',
  true,
  'You can use Concentration to cast a spell, use a spell-like ability, or use a skill defensively, so as to avoid attacks of opportunity altogether. This doesn''t apply to other actions that might provoke attacks of opportunity. The DC of the check is 15 (plus the spell''s level, if casting a spell or using a spell-like ability defensively). If the Concentration check succeeds, you may attempt the action normally without provoking attacks of opportunity.',
  NULL
);

-- Example 3: BLUFF (Charisma-based, used for deception)
INSERT INTO skills (
  name,
  key_ability,
  trained_only,
  armor_check_penalty,
  description,
  action_type_required,
  try_again,
  special,
  synergy
) VALUES (
  'Bluff',
  'CHA',
  false,
  false,
  'Use this skill to deceive others through verbal communication. A Bluff check is opposed by the target''s Sense Motive check. Favorable and unfavorable circumstances weigh heavily on the outcome of a bluff. Circumstances can modify the check by as much as +10 for extreme cases (such as telling a outrageous lie) to –10 (such as a bluff that puts the target in little danger).',
  'standard',
  false,
  'A character with the Persuasive feat gets a +2 bonus on Bluff checks. Feinting in combat uses Bluff as an opposed check against the target''s Sense Motive to gain a bonus on your next attack.',
  'If you have 5 or more ranks in Bluff, you get a +2 bonus on Diplomacy, Intimidate, and Sleight of Hand checks. If you have 5 or more ranks in Bluff, you get a +2 bonus on Disguise checks when you know you''re being observed and you try to act in character.'
);

-- Example 4: INTIMIDATE (Charisma-based, used to demoralize opponents)
INSERT INTO skills (
  name,
  key_ability,
  trained_only,
  armor_check_penalty,
  description,
  action_type_required,
  try_again,
  special,
  synergy
) VALUES (
  'Intimidate',
  'CHA',
  false,
  false,
  'Use this skill to get a bully to back down, to frighten an opponent, or to make a prisoner give you the information you want. Your Intimidate check is opposed by the target''s modified level check (1d20 + character level or Hit Dice + target''s Wisdom bonus [if any] + target''s modifiers on saves against fear). If you beat your target''s check result, you may treat the target as friendly, but only for the purpose of actions taken while it remains intimidated. The effect lasts as long as the target remains in your presence, and for 1d6×10 minutes afterward. After this time, the target''s default attitude toward you shifts to unfriendly.',
  'standard',
  false,
  'A character with the Persuasive feat gets a +2 bonus on Intimidate checks. You gain a +4 bonus on your Intimidate check for every size category that you are larger than your target. Conversely, you take a –4 penalty on your Intimidate check for every size category that you are smaller than your target.',
  'If you have 5 or more ranks in Bluff, you get a +2 bonus on Intimidate checks.'
);

-- Example 5: SPOT (Wisdom-based, used to notice things)
INSERT INTO skills (
  name,
  key_ability,
  trained_only,
  armor_check_penalty,
  description,
  action_type_required,
  try_again,
  special,
  synergy
) VALUES (
  'Spot',
  'WIS',
  false,
  false,
  'Use this skill to notice details, see someone hiding, or hear something approaching. The Spot skill is used primarily to detect characters or creatures who are hiding. Typically, your Spot check is opposed by the Hide check of the creature trying not to be seen. Sometimes a creature isn''t intentionally hiding but is still difficult to see, so a successful Spot check is necessary to notice it. A Spot check result higher than 20 generally lets you become aware of an invisible creature near you, though you can''t actually see it. Spot is also used to detect someone in disguise (opposed by the Disguise check), to read lips, and to notice small details.',
  'standard',
  true,
  'A character with the Alertness feat gets a +2 bonus on Spot checks. A fascinated creature takes a –4 penalty on Spot checks made as reactions. If you have the Track feat, you can use the Survival skill to follow tracks.',
  'If you have 5 or more ranks in Spot, you get a +2 bonus on Search checks.'
);

-- =====================================================
-- NOTES ON SCHEMA MAPPING
-- =====================================================
--
-- Fields mapped from SRD HTML:
-- - name: Extracted from h2/h3 heading
-- - key_ability: From heading suffix (Wis), (Con), (Cha) → converted to uppercase
-- - trained_only: Determined from "Trained Only" restriction in SRD
-- - armor_check_penalty: Determined from "Armor Check Penalty" in heading
-- - description: Main "Check:" section content, summarized
-- - action_type_required: From "Action:" section → mapped to enum values
-- - try_again: From "Try Again:" section → converted to boolean
-- - special: From "Special:" section verbatim
-- - synergy: From "Synergy:" section verbatim
--
-- Action type mapping:
--   "standard action" → 'standard'
--   "not an action" → 'not-an-action'
--   "varies" → NULL (store in description)
--   "1 minute" → stored in description, action_type_required = NULL
--
-- Edge cases:
-- - Skills with subtypes (Craft, Knowledge, Perform, Profession) need separate entries
-- - Some skills have complex DC tables that should be in separate check_details table
-- - Synergy bonuses should also link to skill_synergy_effects table for mechanical bonuses
-- - Special modifiers (feats, equipment) captured in text but could normalize later
--
-- =====================================================