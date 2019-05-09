FROM python:3.7-alpine

LABEL maintainer="polonsky.irena@gmail.com"

COPY /app/requirements.txt /

RUN pip install -r /app/requirements.txt

ADD /app/app.py /

CMD [ "python3", "./app.py" ]