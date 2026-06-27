ARG PYTHON_VERSION=3.13
FROM python:${PYTHON_VERSION}-bookworm AS base

WORKDIR /app

COPY requirements.txt pyproject.toml /app/
RUN pip install -r requirements.txt

COPY . /app
RUN pip install -e .

USER 10017

ENTRYPOINT ["./entrypoint.sh"]

FROM base AS test

RUN mkdir /tmp/app
RUN touch /tmp/app/test.db
ENV DB_PATH=/tmp/app/test.db

CMD ["./test-entrypoint.sh"]
