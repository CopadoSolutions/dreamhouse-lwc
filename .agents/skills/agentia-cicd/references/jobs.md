<!-- Agentia managed skill file: agentia setup skills -->

# CICD Jobs Reference

Use this reference for Copado CICD JobExecution commands under `agentia cicd job ...`.

`cicd job` is for Copado CICD execution records. It is not the same as CRT `agentia testing job ...` or CRT build runs.

## Commands

| Command          | Use For                         | Notes                                                                                     |
| ---------------- | ------------------------------- | ----------------------------------------------------------------------------------------- |
| `job list`       | Search job executions           | Filter by `--status`, `--type`, `--parent`, `--context`, `--mine`, cursor, and page size. |
| `job get ID`     | Inspect a job and ordered steps | Read before action commands or log lookup.                                                |
| `job log get ID` | Read execution logs             | Use `--step <step-id>` when a specific step is needed.                                    |
| `job run ID`     | Run all steps                   | Use `--restart` only when the user asks to restart from the beginning.                    |
| `job resume ID`  | Resume outstanding steps        | Good after a paused or partially completed job.                                           |
| `job pause ID`   | Pause/cancel resumably          | Confirm intent before interrupting active work.                                           |
| `job kill ID`    | Cancel a job                    | Destructive operational action; confirm target and impact.                                |
| `job open ID`    | Open in browser                 | CLI-only navigation helper.                                                               |

Examples:

```sh
agentia cicd job list --status "In Progress" --json
agentia cicd job get <job-execution-id> --json
agentia cicd job log get <job-execution-id> --step <step-id> --json
agentia cicd job resume <job-execution-id> --json
```

## Monitoring Pattern

1. Use `job list --mine --status "In Progress" --json` or use the job ID returned by another command.
2. Run `job get <id> --json` to inspect status and step ordering.
3. Use `job log get <id> --step <step-id>` only when logs are needed for diagnosis.
4. Use `resume`, `pause`, `kill`, or `run --restart` only after confirming the current status and user intent.

## Gotchas

- Some job tools require user and organization context at the gateway layer. If the CLI reports missing context, inspect auth and user context before retrying.
- Logs can be large. Prefer a specific step when available.
- Do not use CICD job commands for Robot Framework builds; use the `agentia-testing` skill for CRT run status and logs.
