FROM python:3.12-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .

ARG APP_VERSION=dev
ARG GIT_COMMIT=local
ARG GIT_BRANCH=local
ARG BUILD_TIME=unknown
ENV APP_VERSION=$APP_VERSION \
    GIT_COMMIT=$GIT_COMMIT \
    GIT_BRANCH=$GIT_BRANCH \
    BUILD_TIME=$BUILD_TIME

EXPOSE 8501
CMD ["streamlit", "run", "app.py", "--server.port=8501", "--server.address=0.0.0.0"]