# Ellen::Cron
Mount cron system to [Ellen]("https://github.com/r7kamura/ellen") to schedule messages on a specific time.

## Usage
You can use any [Chrono](https://github.com/r7kamura/chrono/) compatible cron syntax to schedule messages.

```
@ellen add job "<cron syntax>" <message> - Add a new cron job
@ellen delete job <id>                   - Delete a cron job
@ellen list jobs                         - List all cron jobs
```
