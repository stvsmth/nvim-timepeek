# Code Conventions

This document outlines the conventions and guidelines we should strive to adhere to when
developing and maintaining the codebase. Following these conventions will help ensure
clear diffs, consistency, readability, and maintainability of the code.

The `stylua.toml` file is the authoritative source for formatting rules. In brief:

* Use 4 spaces for indentation.
* Use single quotes for strings.

## Linting

Before committing changes, run the following

* `stylua **/*.lua`
  * Stage any formatting changes to files that were already staged.

## Running tests

* `nvim --headless -c 'PlenaryBustedDirectory tests'`
  * Do not commit if tests fail.

## Commit messages

* Start with a short summary "subject" in the imperative mood.
  * The summary should be 50 chars or less.
  * The summary should end in a period.
* Leave a blank line after the summary.
* Provide a detailed explanation "body" of the changes.
  * Lines in the body should be 72 chars or less.
  * Only include the detailed explanation for larger changes that impact
    functionality.
  * include reasoning and context.
