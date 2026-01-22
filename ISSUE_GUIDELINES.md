# Issue Naming & Tracking Guidelines

To ensure our project backlog remains scannable, professional, and easy to manage, all contributors must follow these naming conventions when creating GitHub Issues.

## 1. The Naming Formula

Issue titles must follow this strict format:

`[Category] (Scope) Short, Imperative Description`

* **Category:** A standardized tag indicating the type of work.
* **Scope:** *(Optional)* The specific module or system affected (e.g., Player, UI, Inventory).
* **Description:** A concise command describing the action to be taken.

---

## 2. Standard Categories

Please use only the following prefixes:

| Prefix | Meaning | Usage Example |
| :--- | :--- | :--- |
| **[Feat]** | **Feature** | New gameplay mechanics, content, or systems. |
| **[Bug]** | **Bug Fix** | Fixing errors, crashes, or unintended behavior. |
| **[Art]** | **Art & Assets** | 2D/3D assets, animations, textures, or VFX. |
| **[Audio]** | **Sound** | SFX implementation, music composition, or mixing. |
| **[UI]** | **User Interface** | Menu layout, HUD implementation, or styles. |
| **[Refactor]** | **Refactoring** | Restructuring code without changing external behavior. |
| **[Docs]** | **Documentation** | Updating GDD, README, or code comments. |
| **[Chore]** | **Maintenance** | Engine updates, file organization, CI/CD setup. |

---

## 3. Style Rules

### A. Use the Imperative Mood
Write the title as if you are giving a command to the computer or the developer. Do not use past tense.
* ❌ **Bad:** "Fixed the double jump bug"
* ❌ **Bad:** "I added a new enemy"
* ✅ **Good:** "Fix double jump physics"
* ✅ **Good:** "Implement new Orc enemy"

### B. Keep it Concise
The title should be scannable in under 2 seconds. Move details to the issue body.
* ❌ **Bad:** "The health bar isn't working right when the player takes poison damage"
* ✅ **Good:** "Fix health bar update on poison damage"

### C. Capitalization
* Capitalize the first letter of the description.
* Capitalize proper nouns (Godot, Player, NPC).

---

## 4. Examples

**Feature Requests**
* `[Feat] Implement save/load system`
* `[Feat] (Combat) Add hit-stop effect on damage`

**Bug Reports**
* `[Bug] Fix crash when changing scenes`
* `[Bug] (UI) Correct typo in Main Menu`

**Art & Audio**
* `[Art] Import Level 1 tilemap assets`
* `[Audio] Add footstep SFX for stone surfaces`

**Maintenance**
* `[Refactor] Decouple PlayerMovement from InputManager`
* `[Chore] Update Godot to version 4.3`