freehck.script_mysql_backup
=========

This role creates a script that performs mysql backups.

It dumps the database, possibly gzip and encrypt backup with aes256.

It can send messages into slack.

It can store your backup on s3 or/and scp it to some other host.

Role Variables
--------------
##### Base variables
`mysql_backup_host`: mysql host

`mysql_backup_port`: mysql port (default 3306)

`mysql_backup_user`: mysql user

`mysql_backup_pass`: mysql pass

`mysql_backup_db`:   mysql database to backup (if not set, then --all-databases option will be passed to mysqldump)

`mysql_backup_backend_use_s3`: set to true if you want to store your backup on S3

`mysql_backup_backend_use_scp`: set to true if you want to send your backup to some other host using scp

##### S3 backend variables

`mysql_backup_s3cfg_template`: template of your s3fs config (the default is provided, don't worry)

`mysql_backup_s3`: s3 configuration options in format like this

    mysql_backup_s3:
      username: "s3user"
      access_key: "s3user-akey"
      secret_key: "s3user-skey"
      bucket: "bucket-name"

##### SCP backend variables

`mysql_backup_scp_host`: storage host to copy your backup

`mysql_backup_scp_user`: user to log in on storage host as

`mysql_backup_scp_dst`: path on storage host to store your backup

`mysql_backup_scp_identity_src`: identity file to use to log in on storage host (yes, it should be a private key)

##### Naming
`mysql_backup_archive_prefix`: just the backup name or simply everything before timestamp

`mysql_backup_archive_stamp`: timestamp template in `date` tool format (the default is `%F-%Hh%Mm%Ss` and resulted in timestamps seem like `2019-09-23-12h22m07s`)

`mysql_backup_script_name`: if you want to rename the base script, you're welcome

`mysql_backup_custom_script_name`: if you want to set some specific name to job script, that actually performs the backup. The default is `mysql-backup-<database_name>.sh`, where <database_name> can be `all` if no databases were specified to backup.

`mysql_backup_scp_identity_name`: the default is `id_rsa`, but it could be useful to modify it in case you want to have multiple SCP backends that use different keys

`mysql_backup_encrypt_aes_key_name`: the default is `aes256.key`, needed it you want to have different encryption keys for different backup tasks

##### Notifications
`mysql_backup_warn_size`: in GiB, default is 0. Compare your backup with this size. If your backup is less, warn you about it.

`mysql_backup_hostname`: hostname (that will be printed in slack messages)

`mysql_backup_slack_webhook`: as written, it's a slack webhook; set it to get slack notifications

> How to get slack webhook: https://get.slack.help/hc/en-us/articles/115005265063-Incoming-WebHooks-for-Slack


##### Compress and Encrypt variables
`mysql_backup_gzip`: gzip backup file

`mysql_backup_encrypt_aes`: encrypt backup file (if gzip enabled this action will be performed specifically AFTER gzip)

`mysql_backup_encrypt_aes_key_src`: aes256 key to encrypt your backup

> Aes256 key is just 32 bytes of random.
> 
> You can use the following command to create it: **dd if=/dev/urandom of=aes256.key count=1 bs=32**.
> 
> If you prefer string passwords (it's less secure) you can use this: **pwgen -n1 -s 32 | tr -d '\n' >aes256.key**

##### Directories
`mysql_backup_script_dir`: directory to store the base script

`mysql_backup_custom_script_dir`: directory to store scripts specific to appropriate backup jobs

`mysql_backup_conf_dir`: directory to store backup script configuration files

`mysql_backup_encrypt_aes_key_dir`: directory to store aes256 encryption key

`mysql_backup_tmpdir`: directory to keep temporary results (you don't need to create a separate one, it's /tmp by default)

##### Pass data outside the role
`mysql_backup_save_facts_about_custom_script`: if you set it to true then the role will save the full path of the generated job script, that has to be run to perform backup, into the variable `mysql_backup_last_generated_custom_script`. You can use this variable to add a specific cron task for this script.

Example Playbook
----------------

    # create mysql backup job script
    - role: freehck.script_mysql_backup
      # mysql connection parameters
      mysql_backup_host: "{{ db_host }}"
      mysql_backup_user: "{{ db_user }}"
      mysql_backup_pass: "{{ db_pass }}"
      mysql_backup_db: "{{ db_name }}"
      # backend storage parameters
      mysql_backup_backend_use_s3: no
      mysql_backup_backend_use_scp: yes
      mysql_backup_scp_host: "{{ hostvars['storage'].ansible_host }}"
      mysql_backup_scp_identity_src: "{{ playbook_dir }}/files/id_rsa.bkp.db01"
      mysql_backup_scp_user: 'file'
      mysql_backup_scp_dst: '/var/www/file/public/mysql-db-prod-backup'
      # gzip and encrypt
      mysql_backup_gzip: yes
      mysql_backup_encrypt_aes: yes
      mysql_backup_encrypt_aes_key_src: "{{ playbook_dir }}/files/aes256.bkp.key"
      # other
      mysql_backup_save_facts_about_custom_script: yes
      mysql_backup_logfile: "/var/log/mysql-backup.log"
      tags: [ backup, mysql ]

	# it's sane to create the cron job for this job script
    - role: freehck.crontask
      crontask_file: "backups"
      crontask_name: "backup database"
      crontask_hour: "12"
      crontask_minute: "0"
      crontask_job: "{{ mysql_backup_last_generated_custom_script }}"
      crontask_user: "root"
      crontask_commented_out: false
      tags: [ backup, mysql ]

Important info
-------

After you deployed the mysql-backup script on your host, it would be sane to come to the host that performs backup tasks and run the job script from `/opt/scripts` without parameters. If it passed without errors and you see the backup file on storage, then everything's okay. If not -- you'll find out what the problem was. F.e. you could forget to add the strage host to `known_hosts` when configured users. Or your `s3cfg` template could contain a mistake. Do not forget to check everything twice: backup things is a very important task.

After you checked the backup was created and stored on the correct place, check it carefully. You must be sure you can restore using it.

License
-------
MIT

Author Information
------------------
Dmitrii Kashin, <freehck@freehck.ru>
