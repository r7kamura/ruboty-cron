# Ruboty::Cron
Mount cron system to [Ruboty]("https://github.com/r7kamura/ruboty") to schedule messages on a specific time.

## Usage
You can use any [Chrono](https://github.com/r7kamura/chrono/) compatible cron syntax to schedule messages.

```
@ruboty add job "<cron syntax>" <message> - Add a new cron job
@ruboty delete job <id>                   - Delete a cron job
@ruboty suspend job <id>                  - Suspend a cron job
@ruboty resume job <id>                   - Resume a cron job
@ruboty list jobs                         - List all cron jobs
```

The scheduled message will be delivered to your bot on the time. If the message contains any valid command, your bot will try to respond to it.

### Example
```
$ bundle exec ruboty
Type `exit` or `quit` to end the session.
> @ruboty add job "* * * * *" @ruboty ping
Job 3117 created
pong
pong
pong
pong
pong
> @ruboty list jobs
 3117: "* * * * *" @ruboty ping
> @ruboty delete job 3117
Deleted
>
```

### Tips
If you want to schedule Ruboty to say something,
[ruboty-echo](https://github.com/taiki45/ruboty-echo) may help you.

```
> @ruboty add job "0 8 * * 1-5" @ruboty echo It's Time for School!
```

Note that you need to include `@ruboty` before the command name `echo`, because ruboty-echo responds only for any mention to the bot itself. Otherwise your bot will ignore the message as an invalid `echo` command.
