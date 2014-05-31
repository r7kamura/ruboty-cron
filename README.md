# Ruboty::Cron
Mount cron system to [Ruboty]("https://github.com/r7kamura/ruboty") to schedule messages on a specific time.

## Usage
You can use any [Chrono](https://github.com/r7kamura/chrono/) compatible cron syntax to schedule messages.

```
@ruboty add job "<cron syntax>" <message> - Add a new cron job
@ruboty delete job <id>                   - Delete a cron job
@ruboty list jobs                         - List all cron jobs
```

![](https://raw.githubusercontent.com/r7kamura/ruboty-cron/master/images/screenshot.png)
