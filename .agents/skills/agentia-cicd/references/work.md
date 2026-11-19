<!-- Agentia managed skill file: agentia setup skills -->

# CICD Work Reference

Use this reference for `agentia cicd work ...` and matching MCP tools such as `agentia_work_get`, `agentia_work_commit`, `agentia_work_push`, and `agentia_work_submit`.

## Choose One Workflow

Local and cloud work are separate delivery paths. Do not continue a cloud commit with local `work push` or `work submit`: those commands inspect and push the local Git feature branch.

### Local Repository Flow

Use this path when the change exists in the local repository:

1. Discover and inspect: `agentia cicd work list --assigned-to-me --json`, then `agentia cicd work get <id-or-name> --json`.
2. Activate: `agentia cicd work set <id-or-name> --json`. This fetches the configured base branch, checks out `feature/<story-name>`, and records the story, base branch, dev org branch, and pull-request context in `.agentia/config.user.json`. Use `--base-branch <branch>` only when intentionally overriding the Pipeline default.
3. Implement and stage new files with `git add`. Commit with Git, or use `agentia cicd work commit --local --all --json` when Agentia should also remember permission, full-metadata, or Apex-test selections. `--local` is the default, and `--all` includes tracked changes only.
4. Run project-owned gates: `agentia cicd work test --local --json`. This runs `.agentia_quality_gates.sh` or `.agentia_quality_gates.cmd` from the repository root when present.
5. Register and synchronize: `agentia cicd work push --json`. A plain `git push` does not register a Copado Commit or merge the feature branch into the recorded dev org branch.
6. Validate and open the merge-request flow: `agentia cicd work submit --json`. Submit runs the local gates unless `--skip-local-tests` is explicit, pushes ahead commits, and submits with validate-only behavior.
7. Only with explicit approval to promote and deploy, run `agentia cicd work submit --done --json`. `work done` is a compatibility alias.
8. Check asynchronous results with `agentia cicd work status [id-or-name] --json`.

`work set`, `work push`, and `work submit` require a clean tracked working tree. `work push` also requires the exact `feature/<story-name>` branch, recorded `lastBaseBranch` and `lastDevOrgBranch`, and at least one commit in `lastBaseBranch..HEAD`. `work submit` permits an empty commit range only for a Story with a Salesforce Data Set or Data Template deployment step.

### Copado Cloud Flow

Use this path when Copado should retrieve metadata from a configured source environment instead of using local Git changes:

1. Inspect the Story and pass its Salesforce ID explicitly when possible. An active Story from `work set` is optional, not a prerequisite for the cloud operation.
2. Start a cloud commit with `agentia cicd work commit <story-id> --cloud ... --json`. Use the simple metadata flags for one change, or `--file`/`--stdin` for a multi-change request. Salesforce metadata requires `--metadata-category SFDX`.
3. Let the command wait for its Job Execution by default. After a timeout, use the returned execution ID with `agentia cicd job get` and `agentia cicd job log get`; do not immediately submit a duplicate commit.
4. When explicitly approved to promote an existing Promotion, use `agentia cicd work promote <story-id> --cloud --json`; add `--deploy` only for promote-and-deploy. This is independent of local `work submit`.

Cloud commit checks Story readiness and source credentials before submission. Avoid concurrent cloud commits to one Story. Treat `--recreate-feature-branch` as destructive because it can overwrite Story-branch work.

## Core Commands

| Command             | Use For                                     | Notes                                                                                                                                   |
| ------------------- | ------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------- |
| `work list`         | Find candidate stories                      | Use `--assigned-to-me`, `--status`, `--project-name`, `--name`, pagination flags.                                                       |
| `work get [ID]`     | Read story details                          | ID is optional after `work set`. Human output redacts OAuth signatures; JSON preserves structured fields.                               |
| `work create`       | Create a story                              | Use `--title`, project/team/assignee/theme fields, specs, and short acceptance criteria.                                                |
| `work update [ID]`  | Mutate story fields or status               | ID is optional after `work set`. Acceptance criteria must be fewer than 255 chars.                                                      |
| `work set ID`       | Mark active and prepare branch              | Fetches base branch, creates/checks out `feature/<story-name>`, stores local context.                                                   |
| `work commit`       | Local or cloud commit                       | The flag sets are disjoint. `--local` is default and performs no gateway call; `--cloud` calls Copado commit APIs and polls by default. |
| `work push`         | Push local commits and register with Copado | Requires active story context and clean tree. Sends stored retrieve-only permissions.                                                   |
| `work test --local` | Run local quality gate scripts              | Runs `.agentia_quality_gates.sh` or `.agentia_quality_gates.cmd` from repo root.                                                        |
| `work submit`       | Submit for review/validation or promote     | Runs local gates unless `--skip-local-tests`; can push ahead commits. `--done` matches Copado UI Submit when promoting.                 |
| `work done`         | Compatibility alias                         | Prefer `work submit --done`; both promote and deploy rather than validate-only.                                                         |
| `work promote`      | Story-centric promotion run                 | Requires `--cloud`; use `--deploy` for merge and deploy.                                                                                |
| `work status [ID]`  | Check story and related executions          | Useful after submit, promote, or commit jobs.                                                                                           |
| `work open [ID]`    | Open story in browser                       | CLI-only browser helper.                                                                                                                |

## Local Repository Details

Use local commits for normal source changes. Stage new files explicitly because `--all` behaves like `git commit -a`:

```sh
git add -A
agentia cicd work commit --local --all --permissions CustomField:Account.SLA__c,ApexClass:AccountService --json
agentia cicd work test --local --json
agentia cicd work push --json
agentia cicd work submit --json
```

`--permissions` records metadata that Copado should treat as Retrieve Only during push. List the components whose access changed, not the permission set or profile files. Use `--full-metadata` only when a profile or permission set should travel as a complete file, because it can overwrite permissions the Story did not touch. Both selections are sticky in local user config until replaced or cleared with an empty value. Push-time selections apply only to that push.

`--apex-test-classes` records story-related test class names for later reference. `work test --local` and `work submit` still take `--apex-test-classes` explicitly when you want the local gate script to receive them.

`work push` detects nested metadata across the full branch diff from the merge base to `HEAD`, applies Copado environment-variable and YAML replacements, registers every commit in the range, and merges into the recorded dev org branch. Review unexpected Retrieve Only, Full Metadata, or nested-deletion output before continuing.

## Cloud Operation Details

Use cloud commits when Copado should retrieve metadata itself:

```sh
agentia cicd work commit <story-id> --cloud --message "Commit AccountService" --metadata-name AccountService --metadata-type ApexClass --metadata-category SFDX --json
agentia cicd work commit <story-id> --cloud --file commit-request.json --json
```

For Salesforce metadata, include `--metadata-category SFDX`. Without the SFDX category, Copado deploy logs can report "Salesforce changes not found."

For a cloud promotion, the Story must already belong to a Promotion:

```sh
agentia cicd work promote <story-id> --cloud --json
agentia cicd work promote <story-id> --cloud --deploy --json
```

Cloud commit and promotion wait for Job Executions by default and return nonzero on failed or timed-out jobs while preserving diagnostic IDs. If a Promotion reaches Merge Conflict, resolve it and resume the original execution; do not start a replacement run.

## Deployment Steps

Deployment steps are attached to a user story and run during promotion.

| Command                                 | Use For                                                                                           |
| --------------------------------------- | ------------------------------------------------------------------------------------------------- |
| `work deployment-step types`            | List supported standard/custom step types.                                                        |
| `work deployment-step salesforce-flows` | List directly invocable Salesforce Flows.                                                         |
| `work deployment-step list`             | Inspect current story steps.                                                                      |
| `work deployment-step create`           | Add Manual Task, Salesforce Flow, Function, Apex, Data Set, Data Template, or Robotic Test steps. |
| `work deployment-step update`           | Apply sparse step updates.                                                                        |
| `work deployment-step reorder`          | Submit a complete before/after ordering snapshot from file or stdin.                              |
| `work deployment-step delete`           | Delete an owned step by ID.                                                                       |

Prefer explicit flags for standard step types. Use `--config-json`, `--file`, or `--stdin` only when the step has expert configuration not covered by flags. Read `types` first when unsure.

## Gotchas

- `work test --local` is not CRT. For Robot Framework execution, use the `agentia-testing` skill.
- Local `work commit` rejects Story IDs and cloud-only flags; cloud `work commit --cloud` rejects local-only flags.
- `work submit` may push ahead commits, but the local flow still needs story and branch context from `work set`.
- `work submit --done` promotes/deploys. Do not run it unless the user explicitly asked to promote or finish the story.
- `work promote --cloud` is not the next step after a local commit; local delivery uses `work push` and `work submit`.
- `work delete` is destructive; read the story and confirm intent first.
