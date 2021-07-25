# Send SMS Alertmanager

## Image to communicate between alertmanager and sms api provider

you can build this image and use with your prometheus monitoring stack for push notification via sms

lets build image :

```bash
docker build -t send_sms_alertmanager:latest .
```

This image serve a REST webhook to receive response from alertmanager

Webhook is available on `http://{Listen_IP_Address}:{PORT}/send_sms`

Example: `Webhook is available on http://127.0.0.1:5000/send_sms`

## Manage phone numbers

python code send_sms.py read contacts.yml file from path /root/contacts.yml in container

`contacts.yml` be like this :

```contacts.yml
team_name1:
  - person1: person1_phoneNumber
```

```contacts.yml
admin:
  - admin1: 12345678910
  #- admin2: 10987654321

#developer:
  #- developer1: 12345678910
```

if you want enable sms notify for any alerts you should add custom labels to specific rule in prometheus rules file --> **`sms_enable: true`**.

and to define which team should be receive message's you can add **`team: team_name`** label to the rules.

Example of `/etc/prometheus/alerts/rules.yml`:

```rules.yml
groups:
  - name: example
    rules:
      - alert: cpu-Usage-crit
        expr: 100 - (avg by (instance) (irate(node_cpu_seconds_total{job="node-exporter_metrics", mode='idle'}[5m])) * 100) > 85
        for: 1m
        labels:
          severity: critical
          team: admin
          sms_enable: true
        annotations:
          summary: Machine under heavy load
```

if you don't set team label, application set the `admin` for default.

### Define Send SMS webhook in Alertmanager

add these lines to `/etc/alertmanager/alertmanager.yml` in alertmanager.

```alertmanager.yml
receivers:
- name: 'web.hook'
  webhook_configs:
  - url: http://{IP_Address}}:{PORT}/send_sms
    send_resolved: true
```

### Send SMS Alertmanager work with `kavenegar` sms provider

so we need to add `SMS_API_KEY` environment to container for send message's.

## Run container

```bash
docker run -d -p 5000:5000 -v "./contacts.yml:/root/contacts.yml" -e "SMS_API_KEY={$API_KEY}" send_sms_alertmanager:{TAG}
```

## Use in compose file

`docker-compose.yml` :

```docker-compose.yml
version: '3.9'

services:

  send-sms:
    image: send_sms_alertmanager:{$Tag}
    environment:
      - SMS_API_KEY: "{$KAVENEGAR_API_KEY}"
    volumes:
      - "./contacts.yml:/root/contacts.yml"
    ports:
      - "5000:5000"
    restart: always
    networks:
      - monitoring

networks:
  monitoring:
```

###TODO:
- [ ] Secure connection
- [ ] Make log persistent
- [ ] Time management for send sms