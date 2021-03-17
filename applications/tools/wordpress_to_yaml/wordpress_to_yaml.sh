#!/bin/bash

# Don't use set -o pipefail with head/tail/etc!
set -o pipefail

if test $# -lt 1
then
    echo "Usage: $0 [ (option)... ] (filename.xml)..." >&2
    echo "" >&2
    echo "Reads the WordPress-formatted NPCs from the specified file," >&2
    echo "converts them to YAML, and outputs to stdout." >&2
    echo "" >&2
    echo "Options:" >&2
    echo "  --keep (publish/pending/draft/trash/blank/all)" >&2
    echo "    Which wp_trash_meta_status to keep." >&2
    echo "    This option can appear multiple times to keep items" >&2
    echo "    that are in any of the specified published states." >&2
    echo "    Default: publish pending draft" >&2
    echo "" >&2
    exit 1
fi

OPTION_KEEP_PUBLISHED_STATES="default"
OPTION_STATE="none"
XML_FILENAMES=""
IS_ERRORS=false
for ARG in $*
do
    if test "$OPTION_STATE" = "keep"
    then
	if test "$ARG" != "publish" \
		-a "$ARG" != "pending" \
		-a "$ARG" != "draft" \
		-a "$ARG" != "trash" \
		-a "$ARG" != "blank" \
		-a "$ARG" != "all"
	then
	    echo "ERROR Invalid --keep: $ARG" >&2
	    IS_ERRORS=true
	fi

	if test "$OPTION_KEEP_PUBLISHED_STATES" = "default"
	then
	    OPTION_KEEP_PUBLISHED_STATES=""
	fi

	NEW_OPTION_KEEP_PUBLISHED_STATES="$OPTION_KEEP_PUBLISHED_STATES $ARG"
	OPTION_KEEP_PUBLISHED_STATES="$NEW_OPTION_KEEP_PUBLISHED_STATES"

	OPTION_STATE="none"
	continue
    elif test "$OPTION_STATE" != "none"
    then
	echo "ERROR Invalid option state: $OPTION_STATE while trying to parse: $ARG" >&2
	IS_ERRORS=true
    fi

    if test "$ARG" = "--keep"
    then
	OPTION_STATE="keep"
	continue
    fi

    XML_FILENAME="$ARG"
    if test ! -f "$XML_FILENAME"
    then
        echo "ERROR No such XML file: $XML_FILENAME" >&2
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

if test "$OPTION_KEEP_PUBLISHED_STATES" = "default"
then
    OPTION_KEEP_PUBLISHED_STATES="publish pending draft"
fi

for XML_FILENAME in $XML_FILENAMES
do
    cat "$XML_FILENAME" \
        | awk \
	      -v "keep_states_string=$OPTION_KEEP_PUBLISHED_STATES" \
              '
               BEGIN {
                   state = "none";
                   sub_state = "none";
                   meta_key = "";
                   meta_value = "";
                   npc_index = 0;

		   split(keep_states_string, keep_states, "[ ][ ]*");
               }

               state == "npc" && $0 ~ /^.*<\/item>.*$/ {
                   state = "none";
                   sub_state = "none";
                   meta_key = "";
                   meta_value = "";
                   gsub(/<\/item>.*$/, "", $0);

                   if (npcs[npc_index]["name"] == "Name") {
                       npcs[npc_index]["name"] = "";
                   } else if (npcs[npc_index]["name"] == "test name") {
                       npcs[npc_index]["name"] = "";
                   }

		   is_kept_state = "false";
		   for (keep_state_index in keep_states) {
		       keep_state = keep_states[keep_state_index];
		       if (npcs[npc_index]["state"] == keep_state) {
		           is_kept_state = "true";
		       } else if (keep_state == "blank" && npcs[npc_index]["state"] == "") {
		           is_kept_state = "true";
		       } else if (keep_state == "all") {
		           is_kept_state = "true";
		       }
		   }

                   if (npcs[npc_index]["name"] != "" && is_kept_state == "true") {
                       print "---";
                       print "#";
                       print "# Preliminary fields that describe this overall file:";
                       print "#";
                       print "kind: vibrantgames.ca/npc";
                       print "version: 0.0.2";
                       print "";
                       print "#";
                       print "# Information about who submitted the data, when, how, etc.:";
                       print "#";
                       print "metadata:";
                       print "  #";
                       print "  # A unique identified for this submission.";
                       print "  # Eventually auto-generated.";
                       print "  # For now, I suggest: convert the character name to lower case,";
                       print "  # and replace all spaces and punctuation with underscores (_)";
                       print "  #";
                       print "  id: " npcs[npc_index]["id"];
                       print "";
                       print "  #";
                       print "  # The name of the submitter (your name).";
                       print "  #";
                       print "  author: " npcs[npc_index]["author"];
                       print "";
                       print "  #";
                       print "  # Email address of the submitter.";
                       print "  #";
                       print "  # WordPress to YAML conversion:";
                       print "  # Unfortunately I do not see the author email";
                       print "  # addresses anywhere in the export file.  :(";
                       print "  # I guess we decided it was not an important field.";
                       print "  # This was a pretty bad oversigh.  :(";
                       print "  #";
                       print "  email: " "UNKNOWN@example.com";
                       print "";
                       print "  #";
                       print "  # Date the NPC was created.";
                       print "  # Must be in ISO 8601 format.";
                       print "  # You can include the time if you want.";
                       print "  #";
                       print "  # E.g. 2021-12-31";
                       print "  #      2021-12-31 23:59:59";
                       print "  #";
                       print "  date: " npcs[npc_index]["date"];
                       print "";
                       print "  #";
                       print "  # Arbitrary labels that are opaque to the system, only";
                       print "  # potentially useful to humans.  For example, the original";
                       print "  # WordPress id of a character (1234 etc).";
                       print "  #";
                       print "  # Optional.";
                       print "  #";
                       print "  labels:";
                       print "  - wordpress_id: " npcs[npc_index]["wordpress_id"];
                       print "";
                       print "  #";
                       print "  # In future more metadata will likely be needed.";
                       print "  # How the data was submitted, some kind of digital";
                       print "  # signature giving Vibrant Games license to basically";
                       print "  # use the content however it chooses, etc...";
                       print "  #";
                       print "";
                       print "#";
                       print "# The content:";
                       print "#";
                       print "npc:";
                       print "  #";
                       print "  # Full name of the NPC.";
                       print "  #";
                       print "  # Required.";
                       print "  # Max length: ...";
                       print "  #";
                       print "  name: " npcs[npc_index]["name"];
                       print "";
                       print "  #";
                       print "  # The NPC artwork.";
                       print "  # Comment out this field if it does not yet exist.";
                       print "  # The filename can include a RELATIVE path:";
                       print "  #     path/to/my/image.jpg";
                       print "  # But it CANNOT be an absolute path:";
                       print "  #     C:\\path\\to\\my\\image.jpg";
                       print "  # For now let us keep all images in one directory,";
                       print "  # at least until that becomes a scaling nightmare.";
                       print "  #";
                       print "  # image: " "NO_ARTWORK_AT_TIME_OF_CONVERSION";
                       print "";
                       print "  #";
                       print "  # Race, class, etc.";
                       print "  # The taupe block on the left of the page.";
                       print "  #";
                       print "  traits:";
                       print "";
                       print "    #";
                       print "    # Ages (case insensitive):";
                       print "    #   - child";
                       print "    #   - adolescent";
                       print "    #   - young adult";
                       print "    #   - middle aged adult";
                       print "    #   - older adult";
                       print "    #   - elderly";
                       print "    #";
                       print "    # Required.";
                       print "    #";
                       print "    age: " npcs[npc_index]["age"];
                       print "";
                       print "    #";
                       print "    # Races (case insensitive):";
                       print "    #   - dragonborn";
                       print "    #   - drow";
                       print "    #   - dwarf";
                       print "    #   - duergar";
                       print "    #   - elf";
                       print "    #   - gnome";
                       print "    #   - half-elf";
                       print "    #   - halfling";
                       print "    #   - half-orc";
                       print "    #   - human";
                       print "    #   - orc";
                       print "    #   - tiefling";
                       print "    #";
                       print "    # Any other race is allowed, too.";
                       print "    #";
                       print "    # Required.";
                       print "    # Max length: ...";
                       print "    #";
                       print "    race: " npcs[npc_index]["race"];
                       print "";
                       print "    #";
                       print "    # The sub-race can be anything.";
                       print "    # For example, swamp gnome or red elf etc.";
                       print "    #";
                       print "    # Optional.  Can be commented out.";
                       print "    # Max length: ...";
                       print "    #";
                       if (length(npcs[npc_index]["sub_race"]) != 0) {
                           print "    sub-race: " npcs[npc_index]["sub_race"];
                       } else {
                           print "    # sub-race: NONE.";
                       }
                       print "";
                       print "    #";
                       print "    # Pronouns (case insensitive):";
                       print "    # - he/him";
                       print "    # - she/her";
                       print "    # - they/them";
                       print "    #";
                       print "    # Required.";
                       print "    #";
                       print "    pronouns: " npcs[npc_index]["pronouns"];
                       print "";
                       print "    #";
                       print "    # Occupation(s).";
                       print "    #";
                       print "    # Required.";
                       print "    # Max length per occupation: ...";
                       print "    #";
                       print "    occupation:";
                       for (occupation_index = 1; occupation_index <= npcs[npc_index]["num_occupations"]; occupation_index ++) {
                           print "    - " npcs[npc_index]["occupation"][occupation_index];
                       }
                       print "";
                       print "    #";
                       print "    # D & D classes (case insensitive):";
                       print "    # - civilian";
                       print "    # - artificer";
                       print "    # - barbarian";
                       print "    # - bard";
                       print "    # - bloodhunter";
                       print "    # - cleric";
                       print "    # - druid";
                       print "    # - fighter";
                       print "    # - monk";
                       print "    # - paladin";
                       print "    # - ranger";
                       print "    # - rogue";
                       print "    # - shaman";
                       print "    # - sorcerer";
                       print "    # - warlock";
                       print "    # - wizard";
                       print "    #";
                       print "    # Required.";
                       print "    #";
                       print "    class: " npcs[npc_index]["class"];
                       print "";
                       print "    #";
                       print "    # Class level.";
                       print "    # 0 for civilian.";
                       print "    #";
                       print "    # Required.";
                       print "    # Integer.";
                       print "    #";
                       print "    level: " npcs[npc_index]["level"];
                       print "";
                       print "    #";
                       print "    # Alignments (case insensitive):";
                       print "    # - lawful good";
                       print "    # - lawful neutral";
                       print "    # - lawful evil";
                       print "    # - neutral good";
                       print "    # - neutral";
                       print "    # - neutral evil";
                       print "    # - chaotic good";
                       print "    # - chaotic neutral";
                       print "    # - chaotic evil";
                       print "    #";
                       print "    # Required.";
                       print "    #";
                       print "    alignment: " npcs[npc_index]["alignment"];
                       print "";
                       print "    #";
                       print "    # Alignment tendencies:";
                       print "    # same as alignment, can be 0 or more.";
                       print "    #";
                       print "    # Optional.";
                       print "    #";
                       npcs[npc_index]["num_tendencies"] ++;
                       npcs[npc_index]["num_tendencies"] --;
                       if (npcs[npc_index]["num_tendencies"] > 0) {
                           print "    tendencies:";
                           for (tendency_index = 1; tendency_index <= npcs[npc_index]["num_tendencies"]; tendency_index ++) {
                               print "    - " npcs[npc_index]["tendencies"][tendency_index];
                           }
                       }
                       print "";
                       print "    #";
                       print "    # Languages the character speaks";
                       print "    # (human, dwarvish, etc).";
                       print "    #";
                       print "    # We should use whatever the D & D language names";
                       print "    # are (dwarvish / dwarven / dwarfish / whatever).";
                       print "    #";
                       print "    # Anybody want to list the D & D languages here as examples?";
                       print "    #";
                       print "    # 0 o more.  (I.e. optional, but most characters speak at least 1.)";
                       print "    #";
                       npcs[npc_index]["num_languages"]++;
                       npcs[npc_index]["num_languages"]--;
                       num_languages = npcs[npc_index]["num_languages"];
                       if (num_languages > 0) {
                           print "    languages:";
                           for (language_index = 1; language_index <= num_languages; language_index ++) {
                               print "    - " npcs[npc_index]["languages"][language_index];
                           }
                       }
                       print "";
                       print "    #";
                       print "    # Factions:";
                       print "    # These should be ids of factions (similar YAML file format, eventually).";
                       print "    # For example:";
                       print "    #";
                       print "    # factions:";
                       print "    # - id: thieves_guild_of_poliwood";
                       print "    #   name: Thieves Guild of Poliwood";
                       print "    #   role: Associate Professor of Lockpicking";
                       print "    # - id: union_of_seamstresses";
                       print "    #   name: Union of Seamstresses";
                       print "    #   role: Window dressing";
                       print "    # - id: cult_of_sky_anthologies";
                       print "    #   name: Cult of Sky Anthologies";
                       print "    #   role: Going Clear Sky pastor";
                       print "    #";
                       print "    # Optional.  0 or more.";
                       print "    #";
                       npcs[npc_index]["num_factions"] ++;
                       npcs[npc_index]["num_factions"] --;
                       if (npcs[npc_index]["num_factions"] > 0) {
                           print "    factions:";
                           for (faction_index = 1; faction_index <= npcs[npc_index]["num_factions"]; faction_index ++) {
                               print "    - id: " npcs[npc_index]["factions"][faction_index]["id"];
                               print "      name: " npcs[npc_index]["factions"][faction_index]["name"];
                               if (npcs[npc_index]["factions"][faction_index]["role"] != "") {
                                   print "      role: " npcs[npc_index]["factions"][faction_index]["role"];
                               }
                           }
                       }
                       print "";
                       print "    #";
                       print "    # Adjectives or other tags that can be used for searching.";
                       print "    #";
                       print "    # Optional.  0 or more.";
                       print "    #";
                       npcs[npc_index]["num_adjectives"] ++;
                       npcs[npc_index]["num_adjectives"] --;
                       if (npcs[npc_index]["num_adjectives"] > 0) {
                           print "    adjectives:";
                           for (adjective_index in npcs[npc_index]["adjectives"]) {
                               print "    - " npcs[npc_index]["adjectives"][adjective_index];
                           }
                       }
                       print "";
                       print "  improv:";
                       print "";
                       print "    #";
                       print "    # Introduction:";
                       print "    # A block of text the DM can read out to the party.";
                       print "    # A hooded dwarf darts in front of your party and blows a loud, shrill whistle, splitting your ears, before he runs away laughing.";
                       print "    #";
                       print "    # Required.";
                       print "    # Max 120 characters.";
                       print "    #";
                       print "    # Use this as a template:";
                       print "    #             |----------------------------------------------------------------------------------------------------------------------|";
                       print "    #";
                       print "    introduction: " npcs[npc_index]["introduction"];
                       print "";
                       print "    #";
                       print "    # Appearance: a brief description of the character skin, clothes, hair, eyes, etc.";
                       print "    #";
                       print "    # Required.";
                       print "    # Max 120 characters.";
                       print "    #";
                       print "    # Use this as a template:";
                       print "    #             |----------------------------------------------------------------------------------------------------------------------|";
                       print "    #";
                       print "    appearance:   " npcs[npc_index]["appearance"];
                       print "";
                       print "    #";
                       print "    # Expressions: things the character says all the time, making their speech distinctive.";
                       print "    # Like, oh my gods!";
                       print "    # Detritus!";
                       print "    # Whoah";
                       print "    # Silly goose";
                       print "    # etc.";
                       print "    #";
                       print "    # Required.";
                       print "    # Max 120 characters.";
                       print "    #";
                       print "    # Use this as a template:";
                       print "    #             |----------------------------------------------------------------------------------------------------------------------|";
                       print "    #";
                       print "    expressions:  " npcs[npc_index]["expressions"];
                       print "";
                       print "    #";
                       print "    # Mannerisms: what does the character do with their hands?  And eyes, mouth, etc.";
                       print "    # Do they tap their feet incessantly?  sniff their own underarms to figure out where the odour";
                       print "    # is coming from?  Etc.";
                       print "    #";
                       print "    # Required.";
                       print "    # Max 120 characters.";
                       print "    #";
                       print "    # Use this as a template:";
                       print "    #             |----------------------------------------------------------------------------------------------------------------------|";
                       print "    #";
                       print "    mannerisms:   " npcs[npc_index]["mannerisms"];
                       print "";
                       print "  acting:";
                       print "    #";
                       print "    # Motivations:";
                       print "    #";
                       print "    # Required.";
                       print "    # ???Maximum length???";
                       print "    #";
                       print "    motivations: |";
                       print "      " npcs[npc_index]["motivations"];
                       print "";
                       print "    #";
                       print "    # Passions:";
                       print "    #";
                       print "    # Required.";
                       print "    # ???Maximum length???";
                       print "    #";
                       passions = npcs[npc_index]["passions"];
                       if (passions != "") {
                           print "    passions: |";
                           gsub(/[\n]/, "\n      ", passions);
                           print "      " passions;
                       }
                       print "";
                       print "    #";
                       print "    # Vulnerabilities:";
                       print "    #";
                       print "    # Required.";
                       print "    # ???Maximum length???";
                       print "    #";
                       vulnerabilities = npcs[npc_index]["vulnerabilities"];
                       if (vulnerabilities != "") {
                           print "    vulnerabilities: |";
                           gsub(/[\n]/, "\n      ", vulnerabilities);
                           print "      " vulnerabilities;
                       }
                       print "";
                       print "    #";
                       print "    # Secrets:";
                       print "    #";
                       print "    # Required.";
                       print "    # ???Maximum length???";
                       print "    #";
                       secrets = npcs[npc_index]["secrets"];
                       if (secrets != "") {
                           print "    secrets: |";
                           gsub(/[\n]/, "\n      ", secrets);
                           print "      " secrets;
                       }
                       print "";
                       print "  #";
                       print "  # The D & D stats block:";
                       print "  # All integers.";
                       print "  #";
                       print "  stats:";
                       print "    armour-class: " npcs[npc_index]["armour-class"];
                       print "    hit-points: " npcs[npc_index]["hit-points"];
                       print "    speed: " npcs[npc_index]["speed"];
                       print "    str: " npcs[npc_index]["str"];
                       print "    dex: " npcs[npc_index]["dex"];
                       print "    con: " npcs[npc_index]["con"];
                       print "    int: " npcs[npc_index]["int"];
                       print "    wis: " npcs[npc_index]["wis"];
                       print "    cha: " npcs[npc_index]["cha"];
                       print "";
                       print "  #";
                       print "  # Special characteristics.";
                       print "  #";
                       print "  # Each is:";
                       print "  # ???Optional???";
                       print "  # ???Max length???";
                       print "  #";
                       print "  specialties:";
                       npcs[npc_index]["num_skills"]++;
                       npcs[npc_index]["num_skills"]--;
                       num_skills = npcs[npc_index]["num_skills"];
                       if (num_skills > 0) {
                           print "    skills:";
                           for (skill_index = 1; skill_index <= num_skills; skill_index ++) {
                               print "    - " npcs[npc_index]["skills"][skill_index];
                           }
                       }
                       special_abilities = npcs[npc_index]["special-abilities"];
                       if (special_abilities != "") {
                           print "    special-abilities: |";
                           gsub(/[\n]/, "\n      ", special_abilities);
                           print "      " special_abilities;
                       }
                       attacks = npcs[npc_index]["attacks"];
                       if (attacks != "") {
                           print "    attacks: |";
                           gsub(/[\n]/, "\n      ", attacks);
                           print "      " attacks;
                       }
                       combat_tactics = npcs[npc_index]["combat-tactics"];
                       if (combat_tactics != "") {
                           print "    combat-tactics: |";
                           gsub(/[\n]/, "\n      ", combat_tactics);
                           print "      " combat_tactics;
                       }
                       npcs[npc_index]["num_special_equipment"]++;
                       npcs[npc_index]["num_special_equipment"]--;
                       num_special_equipment = npcs[npc_index]["num_special_equipment"];
                       if (num_special_equipment > 0) {
                           print "    special-equipment:";
                           for (special_equipment_index = 1; special_equipment_index <= num_special_equipment; special_equipment_index ++) {
                               print "    - " npcs[npc_index]["special_equipment"][special_equipment_index];
                           }
                       }
                       print "";
                       print "  profile:";
                       print "";
                       print "    #";
                       print "    # Background story:";
                       print "    # The long form character development.";
                       print "    #";
                       print "    # Required.";
                       print "    # No length limit for now.";
                       print "    #";
                       print "    background-story: |";
                       background_story = npcs[npc_index]["background-story"];
                       gsub(/[\n]/, "\n      ", background_story);
                       print "      " background_story;
                       print "";
                       print "    #";
                       print "    # Personality (or something like that):";
                       print "    # Expand on the introduction, appearance, expressions, mannerisms, etc.";
                       print "    # without any length limits.";
                       print "    #";
                       print "    # Required.";
                       print "    # No length limit for now.";
                       print "    #";
                       personality = npcs[npc_index]["personality"];
                       if (personality != "") {
                           print "    personality: |";
                           gsub(/[\n]/, "\n      ", personality);
                           print "      " personality;
                       }
                       print "";
                       print "  #";
                       print "  # Content that does not get displayed, but could be useful";
                       print "  # to humans.  Includes review comments, notes about what to";
                       print "  # do for the NPC art, or whatever else we need.";
                       print "  #";
                       print "  # Optional.";
                       print "  #";
                       npcs[npc_index]["num_uncategorized"]++;
                       npcs[npc_index]["num_uncategorized"]--;
                       num_uncategorized = npcs[npc_index]["num_uncategorized"];
                       if (num_uncategorized > 0) {
                           print "  uncategorized:";
                           for (uncategorized_index = 1; uncategorized_index <= num_uncategorized; uncategorized_index ++) {
                               print "  - " npcs[npc_index]["uncategorized"][uncategorized_index]["id"] ": " npcs[npc_index]["uncategorized"][uncategorized_index]["value"];
                           }
                       }
                   }
               }

               state == "none" && $0 ~ /^.*<item>.*$/ {
                   state = "npc";
                   sub_state = "none";
                   meta_key = "";
                   meta_value = "";
                   gsub(/^.*<item>/, "", $0);
                   npc_index ++;
               }

               state == "npc" && $0 ~ /^.*<dc:creator>.*<\/dc:creator>.*$/ {
                   npc_author = $0;
                   gsub(/^.*<dc:creator>/, "", npc_author);
                   gsub(/<\/dc:creator>.*$/, "", npc_author);
                   gsub(/^<!\[CDATA\[/, "", npc_author);
                   gsub(/\]\]>$/, "", npc_author);
                   npcs[npc_index]["author"] = npc_author;
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

               state == "npc" && $0 ~ /^.*<wp:status>.*<\/wp:status>.*$/ {
                   npc_state = $0;
                   gsub(/^.*<wp:status>/, "", npc_state);
                   gsub(/<\/wp:status>.*$/, "", npc_state);
                   gsub(/^<!\[CDATA\[/, "", npc_state);
                   gsub(/\]\]>$/, "", npc_state);
                   npcs[npc_index]["state"] = npc_state;
                   if (npc_state != "") {
                       npcs[npc_index]["num_uncategorized"] ++;
                       uncategorized_index = npcs[npc_index]["num_uncategorized"];
                       npcs[npc_index]["uncategorized"][uncategorized_index]["id"] = "wp:status";
                       npcs[npc_index]["uncategorized"][uncategorized_index]["value"] = npc_state;
                   }
               }

               state == "npc" && $0 ~ /^.*<wp:post_name>.*<\/wp:post_name>.*$/ {
                   npc_id = $0;
                   gsub(/^.*<wp:post_name>/, "", npc_id);
                   gsub(/<\/wp:post_name>.*$/, "", npc_id);
                   gsub(/^<!\[CDATA\[/, "", npc_id);
                   gsub(/\]\]>$/, "", npc_id);
                   gsub(/[^a-zA-Z_0-9]/, "_", npc_id);
                   gsub(/__/, "_", npc_id);
                   npc_id = tolower(npc_id);
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

               state == "npc" && ( sub_state == "postmeta_start" || sub_state == "postmeta_value" || sub_state == "postmeta_end" ) && $0 ~ /^.*<\/wp:postmeta>.*$/ {
                   gsub(/<\/wp:postmeta>.*$/, "", $0);
                   sub_state = "none";
               }

               state == "npc" && sub_state == "none" && $0 ~ /^.*<wp:postmeta>.*$/ {
                   gsub(/^.*<wp:postmeta>/, "", $0);
                   sub_state = "postmeta_start";
               }

               state == "npc" && sub_state == "postmeta_start" && $0 ~ /^.*<wp:meta_key>.*<\/wp:meta_key>.*$/ {
                   meta_key = $0;
                   gsub(/^.*<wp:meta_key>/, "", meta_key);
                   gsub(/<\/wp:meta_key>.*$/, "", meta_key);
                   gsub(/^<!\[CDATA\[/, "", meta_key);
                   gsub(/\]\]>$/, "", meta_key);
                   if (meta_key == "_edit_last") {
                       sub_state = "none";
                       meta_key = "";
                       meta_value = "";
                   }
               }

               state == "npc" && sub_state == "postmeta_start" && meta_key != "" && $0 ~ /^.*<wp:meta_value>.*$/ {
                   meta_value = "";
                   sub_state = "postmeta_value";
               }

               state == "npc" && sub_state == "postmeta_value" {
                   append_meta_value = $0;
                   gsub(/^.*<wp:meta_value>/, "", append_meta_value);
                   gsub(/<\/wp:meta_value>.*$/, "", append_meta_value);
                   gsub(/^<!\[CDATA\[/, "", append_meta_value);
                   gsub(/\]\]>$/, "", append_meta_value);
                   if (meta_value == "") {
                       meta_value = append_meta_value;
                   } else {
                       meta_value = meta_value "\n" append_meta_value;
                   }
               }

               state == "npc" && sub_state == "postmeta_value" && $0 ~ /^.*<\/wp:meta_value>.*$/ {
                   sub_state = "postmeta_end";
               }

               state == "npc" && sub_state == "postmeta_end" && meta_key != "" {
                   switch (meta_key) {
                     case "_wp_trash_meta_status":
                       if (meta_value != "") {
                           npcs[npc_index]["num_uncategorized"] ++;
                           uncategorized_index = npcs[npc_index]["num_uncategorized"];
                           npcs[npc_index]["uncategorized"][uncategorized_index]["id"] = "_wp_trash_meta_status";
                           npcs[npc_index]["uncategorized"][uncategorized_index]["value"] = meta_value;
                       }
                       break;
                     case "name":
                       npcs[npc_index]["name"] = meta_value;
                       if ( npcs[npc_index]["id"] == "" ) {
                           npc_id = npcs[npc_index]["name"];
                           gsub(/[^a-zA-Z_0-9]/, "_", npc_id);
                           gsub(/__/, "_", npc_id);
                           npc_id = tolower(npc_id);
                           npcs[npc_index]["id"] = npc_id;
                       }
                       break;
                     case "age":
                       npcs[npc_index]["age"] = tolower(meta_value);
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
                     case "background":
                       gsub(/[\r]/, "", meta_value);
                       gsub(/[\n][ ]*[\n]/, "\n|\n", meta_value);
                       if (meta_value != "") {
                           npcs[npc_index]["background-story"] = meta_value;
                       }
                       break;
                     case "str":
                       npcs[npc_index]["str"] = meta_value;
                       break;
                     case "dex":
                       npcs[npc_index]["dex"] = meta_value;
                       break;
                     case "con":
                       npcs[npc_index]["con"] = meta_value;
                       break;
                     case "int":
                       npcs[npc_index]["int"] = meta_value;
                       break;
                     case "wis":
                       npcs[npc_index]["wis"] = meta_value;
                       break;
                     case "cha":
                       npcs[npc_index]["cha"] = meta_value;
                       break;
                     case "armour-class":
                       npcs[npc_index]["armour-class"] = meta_value;
                       break;
                     case "hit-points":
                       npcs[npc_index]["hit-points"] = meta_value;
                       break;
                     case "speed-in-feet":
                       npcs[npc_index]["speed"] = meta_value;
                       break;
                     case "notable-skills":
                       if (meta_value != "") {
                           split(meta_value, npc_skills, "[ ]*,[ ]*");
                           for (npc_skill_index in npc_skills) {
                               npc_skill = npc_skills[npc_skill_index];
                               if (npc_skill != "") {
                                   npcs[npc_index]["num_skills"] ++;
                                   skill_index = npcs[npc_index]["num_skills"];
                                   npcs[npc_index]["skills"][skill_index] = npc_skill;
                               }
                           }
                       }
                       break;
                     case "languages":
                       if (meta_value != "") {
                           split(meta_value, npc_languages, "[ ]*,[ ]*");
                           for (npc_language_index in npc_languages) {
                               npc_language = npc_languages[npc_language_index];
                               if (npc_language != "") {
                                   npcs[npc_index]["num_languages"] ++;
                                   language_index = npcs[npc_index]["num_languages"];
                                   npcs[npc_index]["languages"][language_index] = npc_language;
                               }
                           }
                       }
                       break;
                     case "special-abilities":
                       gsub(/[\r]/, "", meta_value);
                       gsub(/[\n][ ]*[\n]/, "\n|\n", meta_value);
                       if (meta_value != "") {
                           if (npcs[npc_index]["special-abilities"] == "") {
                               npcs[npc_index]["special-abilities"] = meta_value;
                           } else {
                               npcs[npc_index]["special-abilities"] = npcs[npc_index]["special-abilities"] "\n|\n" meta_value;
                           }
                       }
                       break;
                     case "combat-tactics":
                       gsub(/[\r]/, "", meta_value);
                       gsub(/[\n][ ]*[\n]/, "\n|\n", meta_value);
                       if (meta_value != "") {
                           npcs[npc_index]["combat-tactics"] = meta_value;
                       }
                       break;
                     case "magical-or-unique-equipment":
                       if (meta_value != "") {
                           split(meta_value, npc_special_equipments, "[ ]*,[ ]*");
                           for (npc_special_equipment_index in npc_special_equipments) {
                               npc_special_equipment = npc_special_equipments[npc_special_equipment_index];
                               if (npc_special_equipment != "") {
                                   npcs[npc_index]["num_special_equipment"] ++;
                                   special_equipment_index = npcs[npc_index]["num_special_equipment"];
                                   npcs[npc_index]["special_equipment"][special_equipment_index] = npc_special_equipment;
                               }
                           }
                       }
                       break;
                     case "challenge":
                       if (meta_value != "") {
                           npcs[npc_index]["num_uncategorized"] ++;
                           uncategorized_index = npcs[npc_index]["num_uncategorized"];
                           npcs[npc_index]["uncategorized"][uncategorized_index]["id"] = "challenge";
                           npcs[npc_index]["uncategorized"][uncategorized_index]["value"] = meta_value;
                       }
                       break;
                     case "passions":
                       gsub(/[\r]/, "", meta_value);
                       gsub(/[\n][ ]*[\n]/, "\n|\n", meta_value);
                       if (meta_value != "") {
                           npcs[npc_index]["passions"] = meta_value;
                       }
                       break;
                     case "secrets":
                       gsub(/[\r]/, "", meta_value);
                       gsub(/[\n][ ]*[\n]/, "\n|\n", meta_value);
                       if (meta_value != "") {
                           npcs[npc_index]["secrets"] = meta_value;
                       }
                       break;
                     case "vulnerabilities":
                       gsub(/[\r]/, "", meta_value);
                       gsub(/[\n][ ]*[\n]/, "\n|\n", meta_value);
                       if (meta_value != "") {
                           npcs[npc_index]["vulnerabilities"] = meta_value;
                       }
                       break;
                     case "special-abilities-2":
                       gsub(/[\r]/, "", meta_value);
                       gsub(/[\n][ ]*[\n]/, "\n|\n", meta_value);
                       if (meta_value != "") {
                           if (npcs[npc_index]["special-abilities"] == "") {
                               npcs[npc_index]["special-abilities"] = meta_value;
                           } else {
                               npcs[npc_index]["special-abilities"] = npcs[npc_index]["special-abilities"] "\n|\n" meta_value;
                           }
                       }
                       break;
                     case "special-abilities-3":
                       gsub(/[\r]/, "", meta_value);
                       gsub(/[\n][ ]*[\n]/, "\n|\n", meta_value);
                       if (meta_value != "") {
                           if (npcs[npc_index]["special-abilities"] == "") {
                               npcs[npc_index]["special-abilities"] = meta_value;
                           } else {
                               npcs[npc_index]["special-abilities"] = npcs[npc_index]["special-abilities"] "\n|\n" meta_value;
                           }
                       }
                       break;
                     case "special-abilities-4":
                       gsub(/[\r]/, "", meta_value);
                       gsub(/[\n][ ]*[\n]/, "\n|\n", meta_value);
                       if (meta_value != "") {
                           if (npcs[npc_index]["special-abilities"] == "") {
                               npcs[npc_index]["special-abilities"] = meta_value;
                           } else {
                               npcs[npc_index]["special-abilities"] = npcs[npc_index]["special-abilities"] "\n|\n" meta_value;
                           }
                       }
                       break;
                     case "special-abilities-5":
                       gsub(/[\r]/, "", meta_value);
                       gsub(/[\n][ ]*[\n]/, "\n|\n", meta_value);
                       if (meta_value != "") {
                           if (npcs[npc_index]["special-abilities"] == "") {
                               npcs[npc_index]["special-abilities"] = meta_value;
                           } else {
                               npcs[npc_index]["special-abilities"] = npcs[npc_index]["special-abilities"] "\n|\n" meta_value;
                           }
                       }
                       break;
                     case "attack-1":
                       gsub(/[\r]/, "", meta_value);
                       gsub(/[\n][ ]*[\n]/, "\n|\n", meta_value);
                       if (meta_value != "") {
                           if (npcs[npc_index]["attacks"] == "") {
                               npcs[npc_index]["attacks"] = meta_value;
                           } else {
                               npcs[npc_index]["attacks"] = npcs[npc_index]["attacks"] "\n|\n" meta_value;
                           }
                       }
                       break;
                     case "attack-2":
                       gsub(/[\r]/, "", meta_value);
                       gsub(/[\n][ ]*[\n]/, "\n|\n", meta_value);
                       if (meta_value != "") {
                           if (npcs[npc_index]["attacks"] == "") {
                               npcs[npc_index]["attacks"] = meta_value;
                           } else {
                               npcs[npc_index]["attacks"] = npcs[npc_index]["attacks"] "\n|\n" meta_value;
                           }
                       }
                       break;
                     default:
                       if (meta_value != "") {
                           npcs[npc_index]["num_uncategorized"] ++;
                           uncategorized_index = npcs[npc_index]["num_uncategorized"];
                           npcs[npc_index]["uncategorized"][uncategorized_index]["id"] = meta_key;
                           npcs[npc_index]["uncategorized"][uncategorized_index]["value"] = meta_value;
                       }
                   }
               }
              ' \
              || exit 3
done

echo "" >&2
echo "SUCCESS converting WordPress XML file(s) to YAML." >&2
echo "" >&2

exit 0
