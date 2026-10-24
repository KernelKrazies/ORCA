-- =========================================================
-- ORCA SAMPLE DATA
-- Development / Testing Only
-- =========================================================

-- =========================================================
-- DATA SOURCES
-- =========================================================

INSERT INTO public.data_sources
(name, organization, source_type, description)
VALUES
(
    'INCOIS',
    'Indian National Centre for Ocean Information Services',
    'Ocean Information',
    'Indian ocean and marine information source'
),
(
    'ISRO',
    'Indian Space Research Organisation',
    'Satellite / Earth Observation',
    'Satellite-based Earth observation data'
),
(
    'IMD',
    'India Meteorological Department',
    'Weather',
    'Weather and meteorological information'
),
(
    'CMEMS',
    'Copernicus Marine Service',
    'Ocean Data',
    'Marine and oceanographic data'
);


-- =========================================================
-- OCEAN REGIONS
-- =========================================================

INSERT INTO public.ocean_regions
(name, description, latitude, longitude)
VALUES
(
    'Arabian Sea',
    'Marine region west of the Indian peninsula',
    15.000000,
    70.000000
),
(
    'Bay of Bengal',
    'Marine region east of the Indian peninsula',
    15.000000,
    88.000000
),
(
    'Indian Ocean',
    'Major ocean region surrounding the Indian subcontinent',
    10.000000,
    75.000000
);