-- Updating the 2015 prdp dataset (psgc_2015) --

-- check if there are psgc changes in the old dataset
SELECT
	PSGC,
	Location_Name
FROM
	psgc_2015
WHERE PSGC NOT IN (SELECT PSGC FROM psgc_2020)

-- find the new osgc of the locations
SELECT
	PSGC,
	Location_Name
FROM
	psgc_2020
WHERE
	Location_Name = 'Guintolan'
	OR Location_Name = 'Panicupan'
	OR Location_Name = 'Macabual'
	OR Location_Name = 'Dunguan'

-- check if the psgc doesn't exist in the old dataset
SELECT
	PSGC
FROM
	psgc_2015
WHERE
	PSGC = '0908304019'
	OR PSGC = '1999904007'
	OR PSGC = '1999908009'
	OR PSGC = '1999908010'

-- update the old dataset
-- For Guintolan
UPDATE psgc_2015
SET psgc = '0908304019'
WHERE psgc = '0908311008'
-- For Dunguan
UPDATE psgc_2015
SET psgc = '1999904007'
WHERE psgc = '1999908003'
-- For Macabual
UPDATE psgc_2015
SET psgc = '1999908009'
WHERE psgc = '1999907007'
-- For Panicupan
UPDATE psgc_2015
SET psgc = '1999908010'
WHERE psgc = '1999906008'