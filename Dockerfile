FROM python:3.9-slim

ENV PYTHONUNBUFFERED=1
ENV PYTHONIOENCODING=utf-8

WORKDIR /root

ADD send_sms.py requirements.txt /root/

RUN apt-get update && \
    pip install -r requirements.txt

EXPOSE 5000

CMD ["/usr/local/bin/python", "-u", "/root/send_sms.py"]
