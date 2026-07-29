SET search_path TO public;

CREATE TABLE IF NOT EXISTS aqi_measurements (
    id          SERIAL PRIMARY KEY,
    city        VARCHAR(100)   NOT NULL,
    country     VARCHAR(100)   NOT NULL,
    latitude    DECIMAL(9,6)   NOT NULL,
    longitude   DECIMAL(9,6)   NOT NULL,
    date        DATE           NOT NULL,
    aqi         INTEGER        NOT NULL CHECK (aqi >= 0 AND aqi <= 500),
    pm25        DECIMAL(8,2)   NOT NULL CHECK (pm25 >= 0),
    pm10        DECIMAL(8,2)   NOT NULL CHECK (pm10 >= 0),
    no2         DECIMAL(8,2)   NOT NULL CHECK (no2 >= 0),
    so2         DECIMAL(8,2)   NOT NULL CHECK (so2 >= 0),
    co          DECIMAL(8,2)   NOT NULL CHECK (co >= 0),
    o3          DECIMAL(8,2)   NOT NULL CHECK (o3 >= 0),
    category    VARCHAR(50)    NOT NULL
);

CREATE INDEX idx_aqi_date     ON aqi_measurements (date);
CREATE INDEX idx_aqi_city     ON aqi_measurements (city);
CREATE INDEX idx_aqi_country  ON aqi_measurements (country);
CREATE INDEX idx_aqi_category ON aqi_measurements (category);
CREATE INDEX idx_aqi_aqi      ON aqi_measurements (aqi);
