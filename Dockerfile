FROM python:3.9-slim

ENV PYTHONUNBUFFERED=1
ENV PYTHONIOENCODING=utf-8

RUN apt-get update && \
    pip install Flask==2.0.1 && \
    pip install gevent==21.1.2 && \
    pip install kavenegar==1.1.2 && \
    pip install PyYAML==5.4.1 && \
    apt-get clean

WORKDIR /root

ADD send_sms.py entrypoint.sh /root/

RUN chmod +x /root/entrypoint.sh

EXPOSE 5000

#ENTRYPOINT ["entrypoint.sh"]

CMD ["/usr/local/bin/python", "-u", "/root/send_sms.py"]
