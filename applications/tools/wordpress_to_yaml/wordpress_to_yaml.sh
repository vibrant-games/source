#!/bin/bash

# Don't use set -o pipefail with head/tail/etc!
set -o pipefail

if test $# -lt 1
then
    echo "Usage: $0 [ (option)... ] (filename.xml)..."
    echo ""
    exit 1
fi

XML_FILENAMES=""
IS_ERRORS=false
for ARG in $*
do
    # FUTURE check for "--option"...
    XML_FILENAME="$ARG"
    if test ! -f "$XML_FILENAME"
    then
        echo "ERROR No such XML file: $XML_FILENAME"
        IS_ERRORS=true
        continue
    fi

    NEW_XML_FILENAMES="$XML_FILENAMES $XML_FILENAME"
    XML_FILENAMES=$NEW_XML_FILENAMES
done

if test "$IS_ERRORS" = "true"
then
    exit 2
fi

for XML_FILENAME in $XML_FILENAMES
do
    cat "$XML_FILENAME" \
        | awk '
               BEGIN {
                   state = "none";
                   sub_state = "none";
                   postmeta_key = "";
                   npc_index = 0;
               }

               state == "npc" && $0 ~ /^.*<\/item>.*$/ {
                   state = "none";
                   sub_state = "none";
                   postmeta_key = "";
                   gsub(/<\/item>.*$/, "", $0);
                   print "---"
                   print "#"
                   print "# Preliminary fields that describe this overall file:"
                   print "#"
                   print "kind: vibrantgames.ca/npc"
                   print "version: 0.0.2"
                   print ""
                   print "#"
                   print "# Information about who submitted the data, when, how, etc.:"
                   print "#"
                   print "metadata:"
                   print "  #"
                   print "  # A unique identified for this submission."
                   print "  # Eventually auto-generated."
                   print "  # For now, I suggest: convert the character name to lower case,"
                   print "  # and replace all spaces and punctuation with underscores (_)"
                   print "  #"
                   print "  id: " npcs[npc_index]["id"]
                   print ""
                   print "  #"
                   print "  # The name of the submitter (your name)."
                   print "  #"
                   print "  author: " "!!!"
                   print ""
                   print "  #"
                   print "  # Email address of the submitter."
                   print "  #"
                   print "  email: " "!!!"
                   print ""
                   print "  #"
                   print "  # Date the NPC was created."
                   print "  # Must be in ISO 8601 format."
                   print "  # You can include the time if you want."
                   print "  #"
                   print "  # E.g. 2021-12-31"
                   print "  #      2021-12-31 23:59:59"
                   print "  #"
                   print "  date: " npcs[npc_index]["date"]
                   print ""
                   print "  #"
                   print "  # Arbitrary labels that are opaque to the system, only"
                   print "  # potentially useful to humans.  For example, the original"
                   print "  # WordPress id of a character (1234 etc)."
                   print "  #"
                   print "  # Optional."
                   print "  #"
                   print "  labels:"
                   print "  - wordpress_id: " npcs[npc_index]["wordpress_id"]
                   print ""
                   print "  #"
                   print "  # In future more metadata will likely be needed."
                   print "  # How the data was submitted, some kind of digital"
                   print "  # signature giving Vibrant Games license to basically"
                   print "  # use the content however it chooses, etc..."
                   print "  #"
                   print ""
                   print "#"
                   print "# The content:"
                   print "#"
                   print "npc:"
                   print "  #"
                   print "  # Full name of the NPC."
                   print "  #"
                   print "  # Required."
                   print "  # Max length: ..."
                   print "  #"
                   print "  name: " npcs[npc_index]["name"];
                   print ""
                   print "  #"
                   print "  # The NPC artwork."
                   print "  # Comment out this field if it does not yet exist."
                   print "  # The filename can include a RELATIVE path:"
                   print "  #     path/to/my/image.jpg"
                   print "  # But it CANNOT be an absolute path:"
                   print "  #     C:\\path\\to\\my\\image.jpg"
                   print "  # For now let us keep all images in one directory,"
                   print "  # at least until that becomes a scaling nightmare."
                   print "  #"
                   print "  # image: " "NO_ARTWORK_AT_TIME_OF_CONVERSION"
                   print ""
                   print "  #"
                   print "  # Race, class, etc."
                   print "  # The taupe block on the left of the page."
                   print "  #"
                   print "  traits:"
                   print ""
                   print "    #"
                   print "    # Ages (case insensitive):"
                   print "    #   - child"
                   print "    #   - adolescent"
                   print "    #   - young adult"
                   print "    #   - middle aged adult"
                   print "    #   - older adult"
                   print "    #   - elderly"
                   print "    #"
                   print "    # Required."
                   print "    #"
                   print "    age: " npcs[npc_index]["age"]
                   print ""
                   print "    #"
                   print "    # Races (case insensitive):"
                   print "    #   - dragonborn"
                   print "    #   - drow"
                   print "    #   - dwarf"
                   print "    #   - duergar"
                   print "    #   - elf"
                   print "    #   - gnome"
                   print "    #   - half-elf"
                   print "    #   - halfling"
                   print "    #   - half-orc"
                   print "    #   - human"
                   print "    #   - orc"
                   print "    #   - tiefling"
                   print "    #"
                   print "    # Any other race is allowed, too."
                   print "    #"
                   print "    # Required."
                   print "    # Max length: ..."
                   print "    #"
                   print "    race: " npcs[npc_index]["race"]
                   print ""
                   print "    #"
                   print "    # The sub-race can be anything."
                   print "    # For example, swamp gnome or red elf etc."
                   print "    #"
                   print "    # Optional.  Can be commented out."
                   print "    # Max length: ..."
                   print "    #"
                   if (length(npcs[npc_index]["sub_race"]) != 0) {
                       print "    sub-race: " npcs[npc_index]["sub_race"];
                   } else {
                       print "    # sub-race: NONE.";
                   }
                   print ""
                   print "    #"
                   print "    # Pronouns (case insensitive):"
                   print "    # - he/him"
                   print "    # - she/her"
                   print "    # - they/them"
                   print "    #"
                   print "    # Required."
                   print "    #"
                   print "    pronouns: " npcs[npc_index]["pronouns"]
                   print ""
                   print "    #"
                   print "    # Occupation(s)."
                   print "    #"
                   print "    # Required."
                   print "    # Max length per occupation: ..."
                   print "    #"
                   print "    occupation:"
                   for (occupation_index = 1; occupation_index <= npcs[npc_index]["num_occupations"]; occupation_index ++) {
                       print "    - " npcs[npc_index]["occupation"][occupation_index];
                   }
                   print ""
                   print "    #"
                   print "    # D & D classes (case insensitive):"
                   print "    # - civilian"
                   print "    # - artificer"
                   print "    # - barbarian"
                   print "    # - bard"
                   print "    # - bloodhunter"
                   print "    # - cleric"
                   print "    # - druid"
                   print "    # - fighter"
                   print "    # - monk"
                   print "    # - paladin"
                   print "    # - ranger"
                   print "    # - rogue"
                   print "    # - shaman"
                   print "    # - sorcerer"
                   print "    # - warlock"
                   print "    # - wizard"
                   print "    #"
                   print "    # Required."
                   print "    #"
                   print "    class: " npcs[npc_index]["class"]
                   print ""
                   print "    #"
                   print "    # Class level."
                   print "    # 0 for civilian."
                   print "    #"
                   print "    # Required."
                   print "    # Integer."
                   print "    #"
                   print "    level: " npcs[npc_index]["level"]
                   print ""
                   print "    #"
                   print "    # Alignments (case insensitive):"
                   print "    # - lawful good"
                   print "    # - lawful neutral"
                   print "    # - lawful evil"
                   print "    # - neutral good"
                   print "    # - neutral"
                   print "    # - neutral evil"
                   print "    # - chaotic good"
                   print "    # - chaotic neutral"
                   print "    # - chaotic evil"
                   print "    #"
                   print "    # Required."
                   print "    #"
                   print "    alignment: " npcs[npc_index]["alignment"]
                   print ""
                   print "    #"
                   print "    # Alignment tendencies:"
                   print "    # same as alignment, can be 0 or more."
                   print "    #"
                   print "    # Optional."
                   print "    #"
                   npcs[npc_index]["num_tendencies"] ++;
                   npcs[npc_index]["num_tendencies"] --;
                   if (npcs[npc_index]["num_tendencies"] > 0) {
                       print "    tendencies:"
                       for (tendency_index = 1; tendency_index <= npcs[npc_index]["num_tendencies"]; tendency_index ++) {
                           print "    - " npcs[npc_index]["tendencies"][tendency_index];
                       }
                   }
                   print ""
                   print "    #"
                   print "    # Languages the character speaks"
                   print "    # (human, dwarvish, etc)."
                   print "    #"
                   print "    # We should use whatever the D & D language names"
                   print "    # are (dwarvish / dwarven / dwarfish / whatever)."
                   print "    #"
                   print "    # Anybody want to list the D & D languages here as examples?"
                   print "    #"
                   print "    # 0 o more.  (I.e. optional, but most characters speak at least 1.)"
                   print "    #"
                   print "    languages:"
                   print "    - " "!!!"
                   print "    - " "!!!"
                   print "    - " "!!!"
                   print ""
                   print "    #"
                   print "    # Factions:"
                   print "    # These should be ids of factions (similar YAML file format, eventually)."
                   print "    # For example:"
                   print "    #"
                   print "    # factions:"
                   print "    # - id: thieves_guild_of_poliwood"
                   print "    #   name: Thieves Guild of Poliwood"
                   print "    #   role: Associate Professor of Lockpicking"
                   print "    # - id: union_of_seamstresses"
                   print "    #   name: Union of Seamstresses"
                   print "    #   role: Window dressing"
                   print "    # - id: cult_of_sky_anthologies"
                   print "    #   name: Cult of Sky Anthologies"
                   print "    #   role: Going Clear Sky pastor"
                   print "    #"
                   print "    # Optional.  0 or more."
                   print "    #"
                   npcs[npc_index]["num_factions"] ++;
                   npcs[npc_index]["num_factions"] --;
                   if (npcs[npc_index]["num_factions"] > 0) {
                       print "    factions:"
                       for (faction_index = 1; faction_index <= npcs[npc_index]["num_factions"]; faction_index ++) {
                           print "    - id: " npcs[npc_index]["factions"][faction_index]["id"];
                           print "      name: " npcs[npc_index]["factions"][faction_index]["name"];
                           print "      role: " npcs[npc_index]["factions"][faction_index]["role"];
                       }
                   }
                   print ""
                   print "    #"
                   print "    # Adjectives or other tags that can be used for searching."
                   print "    #"
                   print "    # Optional.  0 or more."
                   print "    #"
                   print "    adjectives:"
                   for (adjective_index in npcs[npc_index]["adjectives"]) {
                       print "    - " npcs[npc_index]["adjectives"][adjective_index];
                   }
                   print ""
                   print "  improv:"
                   print ""
                   print "    #"
                   print "    # Introduction:"
                   print "    # A block of text the DM can read out to the party."
                   print "    # A hooded dwarf darts in front of your party and blows a loud, shrill whistle, splitting your ears, before he runs away laughing."
                   print "    #"
                   print "    # Required."
                   print "    # Max 120 characters."
                   print "    #"
                   print "    # Use this as a template:"
                   print "    #             |----------------------------------------------------------------------------------------------------------------------|"
                   print "    #"
                   print "    introduction: " npcs[npc_index]["introduction"]
                   print ""
                   print "    #"
                   print "    # Appearance: a brief description of the character skin, clothes, hair, eyes, etc."
                   print "    #"
                   print "    # Required."
                   print "    # Max 120 characters."
                   print "    #"
                   print "    # Use this as a template:"
                   print "    #             |----------------------------------------------------------------------------------------------------------------------|"
                   print "    #"
                   print "    appearance:   " npcs[npc_index]["appearance"]
                   print ""
                   print "    #"
                   print "    # Expressions: things the character says all the time, making their speech distinctive."
                   print "    # Like, oh my gods!"
                   print "    # Detritus!"
                   print "    # Whoah"
                   print "    # Silly goose"
                   print "    # etc."
                   print "    #"
                   print "    # Required."
                   print "    # Max 120 characters."
                   print "    #"
                   print "    # Use this as a template:"
                   print "    #             |----------------------------------------------------------------------------------------------------------------------|"
                   print "    #"
                   print "    expressions:  " npcs[npc_index]["expressions"]
                   print ""
                   print "    #"
                   print "    # Mannerisms: what does the character do with their hands?  And eyes, mouth, etc."
                   print "    # Do they tap their feet incessantly?  sniff their own underarms to figure out where the odour"
                   print "    # is coming from?  Etc."
                   print "    #"
                   print "    # Required."
                   print "    # Max 120 characters."
                   print "    #"
                   print "    # Use this as a template:"
                   print "    #             |----------------------------------------------------------------------------------------------------------------------|"
                   print "    #"
                   print "    mannerisms:   " npcs[npc_index]["mannerisms"]
                   print ""
                   print "  acting:"
                   print "    #"
                   print "    # Motivations:"
                   print "    #"
                   print "    # Required."
                   print "    # ???Maximum length???"
                   print "    #"
                   print "    motivations: |"
                   print "      " npcs[npc_index]["motivations"]
                   print ""
                   print "    #"
                   print "    # Passions:"
                   print "    #"
                   print "    # Required."
                   print "    # ???Maximum length???"
                   print "    #"
                   print "    passions: |"
                   print "      " "!!!"
                   print "      " "!!!"
                   print ""
                   print "    #"
                   print "    # Vulnerabilities:"
                   print "    #"
                   print "    # Required."
                   print "    # ???Maximum length???"
                   print "    #"
                   print "    vulnerabilities: |"
                   print "      " "!!!"
                   print "      " "!!!"
                   print ""
                   print "    #"
                   print "    # Secrets:"
                   print "    #"
                   print "    # Required."
                   print "    # ???Maximum length???"
                   print "    #"
                   print "    secrets: |"
                   print "      " "!!!"
                   print "      " "!!!"
                   print ""
                   print "  #"
                   print "  # The D & D stats block:"
                   print "  # All integers."
                   print "  #"
                   print "  stats:"
                   print "    armour-class: " "!!!"
                   print "    hit-points: " "!!!"
                   print "    speed: " "!!!"
                   print "    str: " "!!!"
                   print "    dex: " "!!!"
                   print "    con: " "!!!"
                   print "    int: " "!!!"
                   print "    wis: " "!!!"
                   print "    cha: " "!!!"
                   print ""
                   print "  #"
                   print "  # Special characteristics."
                   print "  #"
                   print "  # Each is:"
                   print "  # ???Optional???"
                   print "  # ???Max length???"
                   print "  #"
                   print "  specialties:"
                   print "    special-abilities: |"
                   print "      " "!!!"
                   print "      " "!!!"
                   print "    attacks: |"
                   print "      " "!!!"
                   print "      " "!!!"
                   print "    combat-tactics: |"
                   print "      " "!!!"
                   print "      " "!!!"
                   print "    special-equipment:"
                   print "    - " "!!!"
                   print "    - " "!!!"
                   print "    - " "!!!"
                   print ""
                   print "  profile:"
                   print ""
                   print "    #"
                   print "    # Background story:"
                   print "    # The long form character development."
                   print "    #"
                   print "    # Required."
                   print "    # No length limit for now."
                   print "    #"
                   print "    background-story: |"
                   print "      " "!!!"
                   print "      " "!!!"
                   print "      " "!!!"
                   print ""
                   print "    #"
                   print "    # Personality (or something like that):"
                   print "    # Expand on the introduction, appearance, expressions, mannerisms, etc."
                   print "    # without any length limits."
                   print "    #"
                   print "    # Required."
                   print "    # No length limit for now."
                   print "    #"
                   print "    personality: |"
                   print "      " "!!!"
                   print "      " "!!!"
                   print ""
                   print "  #"
                   print "  # Content that does not get displayed, but could be useful"
                   print "  # to humans.  Includes review comments, notes about what to"
                   print "  # do for the NPC art, or whatever else we need."
                   print "  #"
                   print "  # Optional."
                   print "  #"
                   npcs[npc_index]["num_uncategorized"]++;
                   npcs[npc_index]["num_uncategorized"]--;
                   num_uncategorized = npcs[npc_index]["num_uncategorized"];
                   if (num_uncategorized > 0) {
                       print "  uncategorized:"
                       for (uncategorized_index = 1; uncategorized_index <= num_uncategorized; uncategorized_index ++) {
                           print "  - " npcs[npc_index]["uncategorized"][uncategorized_index]["id"] ": " npcs[npc_index]["uncategorized"][uncategorized_index]["value"];
                       }
                   }                  
               }

               state == "none" && $0 ~ /^.*<item>.*$/ {
                   state = "npc";
                   sub_state = "none";
                   postmeta_key = "";
                   gsub(/^.*<item>/, "", $0);
                   npc_index ++;
               }

               state == "npc" && $0 ~ /^.*<title>.*<\/title>.*$/ {
                   npc_name = $0;
                   gsub(/^.*<title>/, "", npc_name);
                   gsub(/<\/title>.*$/, "", npc_name);
                   gsub(/^<!\[CDATA\[/, "", npc_name);
                   gsub(/\]\]>$/, "", npc_name);
                   npcs[npc_index]["name"] = npc_name;
               }

               state == "npc" && $0 ~ /^.*<wp:post_id>.*<\/wp:post_id>.*$/ {
                   npc_wordpress_id = $0;
                   gsub(/^.*<wp:post_id>/, "", npc_wordpress_id);
                   gsub(/<\/wp:post_id>.*$/, "", npc_wordpress_id);
                   gsub(/^<!\[CDATA\[/, "", npc_wordpress_id);
                   gsub(/\]\]>$/, "", npc_wordpress_id);
                   npcs[npc_index]["wordpress_id"] = npc_wordpress_id;
               }

               state == "npc" && $0 ~ /^.*<wp:post_date_gmt>.*<\/wp:post_date_gmt>.*$/ {
                   npc_date = $0;
                   gsub(/^.*<wp:post_date_gmt>/, "", npc_date);
                   gsub(/<\/wp:post_date_gmt>.*$/, "", npc_date);
                   gsub(/^<!\[CDATA\[/, "", npc_date);
                   gsub(/\]\]>$/, "", npc_date);
                   npcs[npc_index]["date"] = npc_date;
               }

               state == "npc" && $0 ~ /^.*<wp:post_name>.*<\/wp:post_name>.*$/ {
                   npc_id = $0;
                   gsub(/^.*<wp:post_name>/, "", npc_id);
                   gsub(/<\/wp:post_name>.*$/, "", npc_id);
                   gsub(/^<!\[CDATA\[/, "", npc_id);
                   gsub(/\]\]>$/, "", npc_id);
                   gsub(/-/, "_", npc_id);
                   npcs[npc_index]["id"] = npc_id;
               }

               state == "npc" && $0 ~ /^.*<category domain="adjectives"[^>]*>.*<\/category>.*$/ {
                   npc_adjective = $0;
                   gsub(/^.*<category domain="adjectives"[^>]*>/, "", npc_adjective);
                   gsub(/<\/category>.*$/, "", npc_adjective);
                   gsub(/^<!\[CDATA\[/, "", npc_adjective);
                   gsub(/\]\]>$/, "", npc_adjective);
                   npcs[npc_index]["num_adjectives"] ++;
                   adjective_index = npcs[npc_index]["num_adjectives"];
                   npcs[npc_index]["adjectives"][adjective_index] = npc_adjective;
               }

               state == "npc" && sub_state == "postmeta" && $0 ~ /^.*<\/wp:postmeta>.*$/ {
                   gsub(/<\/wp:postmeta>.*$/, "", $0);
                   sub_state = "none";
               }

               state == "npc" && sub_state == "none" && $0 ~ /^.*<wp:postmeta>.*$/ {
                   gsub(/^.*<wp:postmeta>/, "", $0);
                   sub_state = "postmeta";
               }

               state == "npc" && sub_state == "postmeta" && $0 ~ /^.*<wp:meta_key>.*<\/wp:meta_key>.*$/ {
                   meta_key = $0;
                   gsub(/^.*<wp:meta_key>/, "", meta_key);
                   gsub(/<\/wp:meta_key>.*$/, "", meta_key);
                   gsub(/^<!\[CDATA\[/, "", meta_key);
                   gsub(/\]\]>$/, "", meta_key);
                   if (meta_key == "_edit_last") {
                       sub_state = "none";
                   } else {
                       postmeta_key = meta_key;
                   }
               }

               state == "npc" && sub_state == "postmeta" && postmeta_key != "" && $0 ~ /^.*<wp:meta_value>.*<\/wp:meta_value>.*$/ {
                   meta_value = $0;
                   gsub(/^.*<wp:meta_value>/, "", meta_value);
                   gsub(/<\/wp:meta_value>.*$/, "", meta_value);
                   gsub(/^<!\[CDATA\[/, "", meta_value);
                   gsub(/\]\]>$/, "", meta_value);
                   switch (postmeta_key) {
                     case "name":
                       npcs[npc_index]["name"] = meta_value;
                       break;
                     case "age":
                       npcs[npc_index]["age"] = meta_value;
                       break;
                     case "race":
                       npcs[npc_index]["race"] = tolower(meta_value);
                       break;
                     case "other":
                       if (meta_value != "") {
                           npcs[npc_index]["num_uncategorized"] ++;
                           uncategorized_index = npcs[npc_index]["num_uncategorized"];
                           npcs[npc_index]["uncategorized"][uncategorized_index]["id"] = "other";
                           npcs[npc_index]["uncategorized"][uncategorized_index]["value"] = meta_value;
                       }
                       break;
                     case "pronouns":
                       npcs[npc_index]["pronouns"] = tolower(meta_value);
                       break;
                     case "occupation":
                       npcs[npc_index]["num_occupations"] ++;
                       occupation_index = npcs[npc_index]["num_occupations"];
                       npcs[npc_index]["occupation"][occupation_index] = meta_value;
                       break;
                     case "alignment":
                       gsub(/\//, " ", meta_value);
                       npcs[npc_index]["alignment"] = tolower(meta_value);
                       break;
                     case "class":
                       gsub(/^[^"]*"/, "", meta_value);
                       gsub(/"[^"]*$/, "", meta_value);
                       npcs[npc_index]["class"] = tolower(meta_value);
                       break;
                     case "level":
                       npcs[npc_index]["level"] = meta_value;
                       break;
                     case "ful-picture":
                       if (meta_value != "") {
                           npcs[npc_index]["num_uncategorized"] ++;
                           uncategorized_index = npcs[npc_index]["num_uncategorized"];
                           npcs[npc_index]["uncategorized"][uncategorized_index]["id"] = "ful-picture";
                           npcs[npc_index]["uncategorized"][uncategorized_index]["value"] = meta_value;
                       }
                       break;
                     case "token-picture":
                       if (meta_value != "") {
                           npcs[npc_index]["num_uncategorized"] ++;
                           uncategorized_index = npcs[npc_index]["num_uncategorized"];
                           npcs[npc_index]["uncategorized"][uncategorized_index]["id"] = "token-picture";
                           npcs[npc_index]["uncategorized"][uncategorized_index]["value"] = meta_value;
                       }
                       break;
                     case "introducing-the-npc":
                       npcs[npc_index]["introduction"] = meta_value;
                       break;
                     case "appearance":
                       npcs[npc_index]["appearance"] = meta_value;
                       break;
                     case "expressions":
                       npcs[npc_index]["expressions"] = meta_value;
                       break;
                     case "mannerisms":
                       npcs[npc_index]["mannerisms"] = meta_value;
                       break;
                     case "motivations":
                       npcs[npc_index]["motivations"] = meta_value;
                       break;
                     case "faction-1":
                       faction_id = meta_value;
                       gsub(/[^a-zA-Z_0-9]/, "_", faction_id);
                       gsub(/__[_]*/, "_", faction_id);
                       faction_id = tolower(faction_id);
                       if (faction_id != "") {
                           npcs[npc_index]["num_factions"] ++;
                           faction_index = npcs[npc_index]["num_factions"];
                           npcs[npc_index]["factions"][faction_index]["id"] = faction_id;
                           npcs[npc_index]["factions"][faction_index]["name"] = meta_value;
                       }
                       break;
                     case "faction-1-role":
                       if (meta_value != "") {
                           faction_index = npcs[npc_index]["num_factions"];
                           npcs[npc_index]["factions"][faction_index]["role"] = meta_value;
                       }
                       break;
                     case "faction-2":
                       faction_id = meta_value;
                       gsub(/[^a-zA-Z_0-9]/, "_", faction_id);
                       gsub(/__[_]*/, "_", faction_id);
                       faction_id = tolower(faction_id);
                       if (faction_id != "") {
                           npcs[npc_index]["num_factions"] ++;
                           faction_index = npcs[npc_index]["num_factions"];
                           npcs[npc_index]["factions"][faction_index]["id"] = faction_id;
                           npcs[npc_index]["factions"][faction_index]["name"] = meta_value;
                       }
                       break;
                     case "faction-2-role":
                       if (meta_value != "") {
                           faction_index = npcs[npc_index]["num_factions"];
                           npcs[npc_index]["factions"][faction_index]["role"] = meta_value;
                       }
                       break;
                     case "faction-3":
                       faction_id = meta_value;
                       gsub(/[^a-zA-Z_0-9]/, "_", faction_id);
                       gsub(/__[_]*/, "_", faction_id);
                       faction_id = tolower(faction_id);
                       if (faction_id != "") {
                           npcs[npc_index]["num_factions"] ++;
                           faction_index = npcs[npc_index]["num_factions"];
                           npcs[npc_index]["factions"][faction_index]["id"] = faction_id;
                           npcs[npc_index]["factions"][faction_index]["name"] = meta_value;
                       }
                       break;
                     case "faction-3-role":
                       if (meta_value != "") {
                           faction_index = npcs[npc_index]["num_factions"];
                           npcs[npc_index]["factions"][faction_index]["role"] = meta_value;
                       }
                       break;
                   }
               }
              ' \
              || exit 3
done

echo ""
echo "SUCCESS converting WordPress XML file(s) to YAML."
echo ""

exit 0

# 
#                state == "npc" && $0 ~ /^.*<!!!>.*<\/!!!>.*$/ {
#                    npc_!!! = $0;
#                    gsub(/^.*<!!!>/, "", npc_!!!);
#                    gsub(/<\/!!!>.*$/, "", npc_!!!);
#                    gsub(/^<!\[CDATA\[/, "", npc_!!!);
#                    gsub(/\]\]>$/, "", npc_!!!);
#                    npcs[npc_index]["!!!"] = npc_!!!;
#                }

#                      case "!!!":
#                        npcs[npc_index]["!!!"] = meta_value;
#                        break;
