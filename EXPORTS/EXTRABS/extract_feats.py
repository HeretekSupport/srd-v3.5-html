#!/usr/bin/env python3
import re
import json
import html

# Read the HTML file
html_file = r'd:\Workspace\WEB\PROJECTS\srd-v3.5-html\basic-rules-and-legal\feats.html'
with open(html_file, 'r', encoding='utf-8') as f:
    content = f.read()

# Function to clean HTML tags and decode entities
def clean_html(text):
    # Remove HTML tags
    text = re.sub(r'<[^>]+>', '', text)
    # Decode HTML entities
    text = html.unescape(text)
    # Clean up whitespace
    text = re.sub(r'\s+', ' ', text).strip()
    return text

# Split content by feat sections (h3 tags)
# Find all feat entries between h3 tags
feat_sections = re.split(r'(?=<h3 id=)', content)

feats = []

for section in feat_sections[1:]:  # Skip first empty split
    # Extract feat name and type
    header_match = re.search(r'<h3[^>]*>([^<]+)<small>\[([^\]]+)\]</small></h3>', section)
    if not header_match:
        continue

    feat_name = header_match.group(1).strip()
    feat_type = header_match.group(2).strip()

    # Extract prerequisites
    prerequisites = ''
    prereq_match = re.search(r'<strong>Prerequisite[s]?:</strong>\s*(.+?)(?=<(?:p|strong)|$)', section, re.DOTALL)
    if prereq_match:
        prerequisites = clean_html(prereq_match.group(1))

    # Extract benefit
    benefit = ''
    benefit_match = re.search(r'<strong>Benefit[s]?:</strong>\s*(.+?)(?=<strong>Normal:|<strong>Special:|<h3|$)', section, re.DOTALL)
    if benefit_match:
        benefit = clean_html(benefit_match.group(1))

    # Extract normal
    normal = ''
    normal_match = re.search(r'<strong>Normal:</strong>\s*(.+?)(?=<strong>Special:|<h3|$)', section, re.DOTALL)
    if normal_match:
        normal = clean_html(normal_match.group(1))

    # Extract special
    special = ''
    special_match = re.search(r'<strong>Special:</strong>\s*(.+?)(?=<h3|$)', section, re.DOTALL)
    if special_match:
        special = clean_html(special_match.group(1))

    # Determine if it's a fighter bonus feat
    is_fighter_bonus = 'fighter may select' in special.lower() or 'fighter bonus feat' in special.lower()

    # Determine if multiples allowed
    allows_multiples = 'multiple times' in special.lower() or 'gain this feat multiple' in special.lower()

    # Determine if requires choice
    requires_choice = False
    choice_description = ''

    # Check if the section starts with "Choose"
    if re.search(r'^<p>Choose', section):
        requires_choice = True
        choose_match = re.search(r'<p>(Choose[^<]+)', section)
        if choose_match:
            choice_description = clean_html(choose_match.group(1))
    elif 'choose' in benefit.lower()[:50]:  # Check in first part of benefit
        requires_choice = True
        choose_match = re.search(r'(Choose[^.]+[.;])', benefit)
        if choose_match:
            choice_description = choose_match.group(1)

    feat_data = {
        'name': feat_name,
        'type': feat_type,
        'prerequisites': prerequisites,
        'benefit': benefit,
        'normal': normal,
        'special': special,
        'is_fighter_bonus': is_fighter_bonus,
        'allows_multiples': allows_multiples,
        'requires_choice': requires_choice,
        'choice_description': choice_description
    }

    feats.append(feat_data)

# Sort by name
feats.sort(key=lambda x: x['name'])

# Output in text format
print("=" * 120)
print(f"D&D 3.5 SRD FEAT EXTRACTION - TOTAL FEATS: {len(feats)}")
print("=" * 120)
print()

for i, feat in enumerate(feats, 1):
    print(f"{i}. {feat['name']} [{feat['type']}]")

    if feat['prerequisites']:
        print(f"   Prerequisites: {feat['prerequisites'][:150]}")

    if feat['benefit']:
        benefit_text = feat['benefit'][:200]
        print(f"   Benefit: {benefit_text}...")

    if feat['normal']:
        print(f"   Normal: {feat['normal'][:150]}...")

    if feat['special']:
        print(f"   Special: {feat['special'][:150]}...")

    if feat['is_fighter_bonus']:
        print(f"   [FIGHTER BONUS FEAT]")

    if feat['allows_multiples']:
        print(f"   [ALLOWS MULTIPLES]")

    if feat['requires_choice']:
        print(f"   [REQUIRES CHOICE] - {feat['choice_description'][:80]}")

    print()

# Save as JSON
output_file = r'd:\Workspace\WEB\PROJECTS\feats_extracted.json'
with open(output_file, 'w', encoding='utf-8') as f:
    json.dump(feats, f, indent=2, ensure_ascii=False)

print(f"\nJSON exported to: {output_file}")

# Generate SQL INSERT statements
sql_output = r'd:\Workspace\WEB\PROJECTS\feats_insert.sql'
with open(sql_output, 'w', encoding='utf-8') as f:
    f.write("-- Auto-generated SQL INSERT statements for D&D 3.5 Feats\n")
    f.write("-- Generated from feats.html\n\n")

    for feat in feats:
        # Escape single quotes for SQL
        name_sql = feat['name'].replace("'", "''")
        type_sql = feat['type'].replace("'", "''")
        prerequisites_sql = feat['prerequisites'].replace("'", "''")
        benefit_sql = feat['benefit'].replace("'", "''")
        normal_sql = feat['normal'].replace("'", "''")
        special_sql = feat['special'].replace("'", "''")

        f.write(f"INSERT INTO feats (name, type, prerequisites, benefit, normal, special, is_fighter_bonus, allows_multiples, requires_choice, choice_description) VALUES\n")
        f.write(f"  ('{name_sql}', '{type_sql}', '{prerequisites_sql}', '{benefit_sql}', '{normal_sql}', '{special_sql}', {1 if feat['is_fighter_bonus'] else 0}, {1 if feat['allows_multiples'] else 0}, {1 if feat['requires_choice'] else 0}, '{feat['choice_description'].replace(chr(39), chr(39)*2)}');\n\n")

print(f"SQL exported to: {sql_output}")
