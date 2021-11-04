#cloud-config
swap:
  filename: /swap.img
  size: 2048000000 # 2GB in bytes

write_files:
  - path: /tmp/bootstrap-discourse-db.sql
    permissions: '0644'
    content: |
      ---User is created with random password by terraform, see: postgres.tf
      ---CREATE USER discourse PASSWORD 's3kr1t';
      GRANT discourse TO doadmin;
      CREATE DATABASE discourse OWNER discourse;
      \c discourse
      CREATE EXTENSION hstore;
      CREATE EXTENSION pg_trgm;

  - path: /tmp/standalone-no-postgres.yml
    permissions: '0644'
    content: |
      templates:
        - "templates/redis.template.yml"
        - "templates/web.template.yml"
        - "templates/web.ratelimited.template.yml"
      expose:
        - "80:80"   # http
        - "443:443" # https
      params:
        # We need to do this below as seen in `hooks.after_code` to checkout a specific tag/commit
        # see: https://meta.discourse.org/t/shallow-git-fetch-regression-in-discourse-docker/172324/18
        # version: v2.8.0.beta7
      env:
        DISCOURSE_HOSTNAME: 'discourse.gabe.tech'
        DISCOURSE_DEVELOPER_EMAILS: 'root@gabe.tech'
        DISCOURSE_DB_USERNAME: '${discourse_db_user}'
        DISCOURSE_DB_PASSWORD: '${discourse_db_pass}'
        DISCOURSE_DB_HOST: '${discourse_db_host}'
        DISCOURSE_DB_PORT: '${discourse_db_port}'
        DISCOURSE_DB_NAME: discourse
      volumes:
        - volume:
            host: /var/discourse/shared/standalone
            guest: /shared
        - volume:
            host: /var/discourse/shared/standalone/log/var-log
            guest: /var/log
      hooks:
        after_code:
          - exec:
              cd: $home/plugins
              cmd:
                - git clone https://github.com/discourse/docker_manager.git
          - exec:
              cd: $home
              cmd:
                - git fetch --depth=1 origin tag v2.8.0.beta7
                - git checkout v2.8.0.beta7
      run:
        ## If you want to set the 'From' email address for your first registration, uncomment and change:
        ## After getting the first signup email, re-comment the line. It only needs to run once.
        #- exec: rails r "SiteSetting.notification_email='info@unconfigured.discourse.org'"

runcmd:
  - apt install -y docker.io git postgresql-client
  - psql ${doadmin_defaultdb_uri} -f /tmp/bootstrap-discourse-db.sql
  - git clone https://github.com/discourse/discourse_docker.git /var/discourse
  - mv /tmp/standalone-no-postgres.yml /var/discourse/containers/app.yml
  - cd /var/discourse && ./launcher rebuild app
