freehck.crontask
=========
This role is just a wrapper for the cron module.

It creates the cron job in the same way.

Role Variables
--------------
`crontask_file`: filename under `/etc/cron.d` to store your jobs in

`crontask_name`: name for the job to perform

`crontask_day`: day to run (default `'*'`)

`crontask_hour`: hour to run (default `'*'`)

`crontask_minute`: minute to run (default `'*'`)

`crontask_month`: month to run (default `'*'`)

`crontask_weekday`: weekday to run (default `'*'`)

`crontask_job`: command or script to run

`crontask_state`: state (default `present`, can be set to `absent`)

`crontask_user`: user that will run this job (default `root`)

`crontask_commented_out`: set to `true` to temporary disable task

Example Playbook
----------------

    - role: freehck.crontask
      crontask_file: "backups"
      crontask_name: "backup database"
      crontask_hour: "12"
      crontask_minute: "0"
      crontask_job: "/opt/scripts/mysql-backup-all.sh"
      crontask_user: "root"
      tags: [ backup, mysql ]


License
-------
MIT

Author Information
------------------
Dmitrii Kashin, <freehck@freehck.ru>
