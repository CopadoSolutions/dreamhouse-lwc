##Helper

Use always agentia cli to work with Copado stories and jobs and other tools.
Check agentia skills how to perform actions in the cli.

for deploying to the dev env metadata changes send

Workflow Rules:

1. when we do a new task: create the story in copado, use 'agentia cicd work create', include my default environment is: ARM Dev1
2. do the 'agentia cicd work set' to ensure the correct feature branch is ready
3. after doing the metadata changes or data changes lets run local quality gates, with agentia cicd work test
4. when i am done, lets do a agentia cicd work commit , and agentia cicd work push. assume the initial json result, DO NOT pull on the jobId, for the async part.
5. when i confirm you can promote to the next environment, using "work submit --done"
6. if the job fails lets download the logs and review the errors, and re-run the job.
