FROM metabase/metabase:latest

ENV MB_SITE_NAME="AQI Global Dashboard"
ENV JAVA_TIMEZONE=UTC
ENV MB_JAVA_OPTS="-Xmx200m"

EXPOSE 3000
