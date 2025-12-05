---
description: Create a new Flyway database migration
argument-hint: description of migration
---

Create a new database migration for: $ARGUMENTS

Steps:
1. Run the migration file generator script to create a properly named file:
   ```bash
   cd db-migrations && ./new-migration-file.sh "$ARGUMENTS"
   ```
2. Write the SQL migration in the created file
3. Include both the "up" migration and a commented-out rollback section
4. Explain what the migration does in plain language

If I didn't specify what the migration should do, ask me what tables/columns/changes I need.
