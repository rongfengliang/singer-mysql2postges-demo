# singer basic running

with docker-compose provider db && > python 3.5  install
&& use virtualenv

## init project

* install virtualenv

> use pip3

```code
pip3 install virtualenv

or: 
pip install virtualenv

```

* create mysql tap virtualenv && install python packages

```code
virtualenv  mysql  
source ./mysql/bin/activate
pip install tap-mysql
```

* create postgres tap virtualenv && install python packages

```code
virtualenv  postgres  
source ./postgres/bin/activate
pip install target-postgres
```

* init some mysql data

docker-compose contains one git server gogs && start && config it 

* mysql tap config

tap.json

```json
{
    "host": "localhost",
    "port": "3306",
    "user": "root",
    "password": "dalongrong"
}
```

* postgres target config

target.json

```json
{
    "host": "localhost",
    "port": 5432,
    "dbname": "postgres",
    "user": "postgres",
    "password": "postgres",
    "schema": "public"
}
```

## discover tables (tap for mysql)

* discover tables && generate  json file

```code
./mysql/bin/tap-mysql --config config.json --discover > properties.json
```

* add sync table conf (with full table)

search  for  `stream`: `repository`,

```diff

          "breadcrumb": [],
          "metadata": {
+            "selected-by-default": true,
            "database-name": "gogs",
            "row-count": 1,
            "is-view": false,
+            "selected": true,
+            "replication-method": "FULL_TABLE",
```

## run sync

* run sync

```code
./mysql/bin/tap-mysql --config tap.json --properties properties.json | ./postgres/bin/target-postgres --config ta
rget.json
```

* some result

```code
./mysql/bin/tap-mysql --config tap.json --properties properties.json | ./postgres/bin/target-postgres --config target.json
INFO Server Parameters: version: 5.7.16, wait_timeout: 2700, innodb_lock_wait_timeout: 2700, max_allowed_packet: 4194304, interactive_timeout: 28800
INFO Server SSL Parameters (blank means SSL is not active): [ssl_version: ], [ssl_cipher: ]
INFO Beginning sync for InnoDB table gogs.repository
INFO Stream repository is using full table replication
INFO Table 'repository' exists
INFO Detected auto-incrementing primary key(s) - will replicate incrementally
INFO Running SELECT `external_wiki_url`,`external_tracker_url`,`num_pulls`,`pulls_ignore_whitespace`,`website`,`size`,`enable_external_wiki`,`updated_unix`,`use_custom_avatar`,`is_private`,`external_tracker_style`,`allow_public_issues`,`num_watches`,`description`,`default_branch`,`allow_public_wiki`,`num_milestones`,`num_closed_milestones`,`enable_external_tracker`,`fork_id`,`owner_id`,`is_fork`,`num_issues`,`is_mirror`,`id`,`num_closed_issues`,`name`,`external_tracker_format`,`enable_issues`,`num_stars`,`pulls_allow_rebase`,`lower_name`,`num_closed_pulls`,`enable_pulls`,`is_bare`,`num_forks`,`created_unix`,`enable_wiki` FROM `gogs`.`repository` WHERE `id` <= 1 ORDER BY `id` ASC
/Users/dalong/mylearning/python-virtualenv/mysql/lib/python3.7/site-packages/pymysql/connections.py:1077: UserWarning: Previous unbuffered result was left incomplete
  warnings.warn("Previous unbuffered result was left incomplete")
INFO METRIC: {"type": "counter", "metric": "record_count", "value": 1, "tags": {"database": "gogs", "table": "repository"}}
INFO METRIC: {"type": "timer", "metric": "job_duration", "value": 0.054605960845947266, "tags": {"job_type": "sync_table", "database": "gogs", "table": "repository", "status": "succeeded"}}
INFO Loading 1 rows into 'repository'
INFO COPY repository_temp ("allow_public_issues", "allow_public_wiki", "created_unix", "default_branch", "description", "enable_external_tracker", "enable_external_wiki", "enable_issues", "enable_pulls", "enable_wiki", "external_tracker_format", "external_tracker_style", "external_tracker_url", "external_wiki_url", "fork_id", "id", "is_bare", "is_fork", "is_mirror", "is_private", "lower_name", "name", "num_closed_issues", "num_closed_milestones", "num_closed_pulls", "num_forks", "num_issues", "num_milestones", "num_pulls", "num_stars", "num_watches", "owner_id", "pulls_allow_rebase", "pulls_ignore_whitespace", "size", "updated_unix", "use_custom_avatar", "website") FROM STDIN WITH (FORMAT CSV, ESCAPE '\')
INFO UPDATE 1
INFO INSERT 0 0
{"currently_syncing": null, "bookmarks": {"gogs-repository": {"initial_full_table_complete": true}}}
```

## for gitlab demo

* create access_token from gitlab app

* create gitlab virtualenv

```code
virtualenv  gitlab  
source ./gitlab/bin/activate
pip install tap-gitlab
```

* add gitlab tap config

```code
{
 "api_url": "https://gitlab.com/api/v4",
 "private_token": "<token>",
 "groups": "<yougroup>",
 "projects": "<you project>",
 "start_date":"2010-01-01T00:00:00Z"
}

```

* running

```code
./gitlab/bin/tap-gitlab -c gitlab.json | ./postgres/bin/target-postgres -c target.json
```

## for mongodb

* config propeerties

```diff
{
  "streams": [
    {
      "table_name": "loginusers",
      "stream": "loginusers",
      "metadata": [
        {
          "breadcrumb": [],
          "metadata": {
            "database-name": "usersapp",
            "row-count": 3,
+ "selected": true,
+ "replication-method": "FULL_TABLE",
+ "custom-select-clause": "_id,name,age"
          }
        }
      ],
      "tap_stream_id": "usersapp-loginusers",
      "schema": {
        "type": "object",
+ "properties": {
+ "name": {
+ "inclusion": "available",
+ "maxLength": 255,
+ "type": [
+ "null",
+ "string"
+ ]
+ },
+ "age": {
+ "inclusion": "available",
+ "maxLength": 255,
+ "type": [
+ "null",
+ "number"
+ ]
+ },
+ "type": {
+ "inclusion": "available",
+ "maxLength": 255,
+ "type": [
+ "null",
+ "string"
+ ]
+ },
+ "_id": {
+ "inclusion": "available",
+ "maxLength": 255,
+ "type": [
+ "null",
+ "string"
+ ]
+ }
+ }
+ }
+ }
+ ]
}

```

* run

```code
./mongodb/bin/tap-mongodb -c mongo.json --properties usersapp.json | ./postgres/bin/target-po
stgres -c target.json
```