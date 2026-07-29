FROM metabase/metabase:latest

ENV MB_SITE_NAME="AQI Global Dashboard"
ENV JAVA_TIMEZONE=UTC
ENV JAVA_OPTS="-Xmx180m"

EXPOSE 3000
