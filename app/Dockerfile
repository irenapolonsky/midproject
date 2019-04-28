FROM python:3.7-alpine

LABEL maintainer="polonsky.irena@gmail.com"

COPY requirements.txt /

RUN pip install -r /requirements.txt

ADD app.py /

CMD [ "python3", "./app.py" ]


