# Phase I - Builder source
FROM python:3.7-alpine3.9 as builder
ENV PYTHONUNBUFFERED=1 
WORKDIR /usr/src/app/exec
RUN apk add curl
RUN echo DOWNLOADING CONSUL CLI
RUN curl -o ./consul.zip  -O -J -L https://releases.hashicorp.com/consul/1.6.2/consul_1.6.2_linux_amd64.zip 
RUN unzip ./consul.zip -d ./
COPY entry-point.sh ./
COPY envconsul ./
WORKDIR /usr/src/app
COPY ./ .
WORKDIR /wheels
COPY requirements.txt .
RUN pip wheel -r ./requirements.txt 

# Phase II - Lints Code
FROM eeacms/pylint:latest as linting
WORKDIR /code
COPY --from=builder /usr/src/app/pylint.cfg /etc/pylint.cfg
COPY --from=builder /usr/src/app/*.py ./
RUN ["/docker-entrypoint.sh", "pylint"]


# Phase III Running Sonarqube scanner (Sonarqube server also required)
FROM newtmitch/sonar-scanner as sonarqube
WORKDIR /usr/src
COPY --from=builder /usr/src/app/*.py ./
RUN sonar-scanner -Dsonar.projectBaseDir=/usr/src


## Phase IV - Runs Unit Tests
#FROM python:latest as unit-tests
#WORKDIR /usr/src/app
# Copy all packages instead of rerunning pip install
#COPY --from=builder /wheels /wheels
#RUN     pip install -r /wheels/requirements.txt \
#                      -f /wheels \
#       && rm -rf /wheels \
#       && rm -rf /root/.cache/pip/* 

#COPY --from=builder /usr/src/app/ ./
#RUN ["make", "test"]


# Phase V - Start application flask api
FROM python:3.7-alpine3.9 as server
WORKDIR /usr/src/app
EXPOSE 8080
# Copy all packages instead of rerunning pip install
RUN apk add curl
COPY --from=builder /wheels /wheels
RUN     pip install -r /wheels/requirements.txt \
                      -f /wheels \
       && rm -rf /wheels \
       && rm -rf /root/.cache/pip/* 

COPY --from=builder /usr/src/app/*.py ./
COPY --from=builder /usr/src/app/api ./api
COPY --from=builder /usr/src/app/exec/* /usr/bin/
ENTRYPOINT ["entry-point.sh"]
CMD ["python3", "run_app.py"]

