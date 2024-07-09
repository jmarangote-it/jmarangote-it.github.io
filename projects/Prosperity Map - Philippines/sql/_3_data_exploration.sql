-- Ranking NCR Cities/Municipalities
SELECT
	prdp_locations.location_name,
	prdp_locations.geo_level,
	sre_income_class.income_class,
	FORMAT(prdp_population.population_count,'N0') AS population_count,
	FORMAT(sre.current_operating_income_total, 'C', 'EN-PH') AS total_operating_income,
	FORMAT(sre.current_operating_expenditures_total, 'C', 'EN-PH') AS total_operating_expenditures,
	FORMAT(sre.fund_balance, 'C', 'EN-PH') AS fund_balance
FROM
	PortfolioProject.dbo.prdp_locations AS prdp_locations
JOIN
	PortfolioProject.dbo.prdp_population AS prdp_population
ON
	prdp_locations.psgc = prdp_population.psgc
JOIN
	PortfolioProject.dbo.sre_income_class AS sre_income_class
ON
	prdp_locations.psgc = sre_income_class.psgc
JOIN
	PortfolioProject.dbo.statement_of_receipts_and_expenditures AS sre
ON
	prdp_locations.psgc = sre.psgc
WHERE
	prdp_locations.psgc LIKE '13%' --includes all NCR
	AND (prdp_locations.geo_level = 'City' OR prdp_locations.geo_level = 'Special' OR prdp_locations.geo_level = 'Mun')
	AND prdp_population.census_year = 2020
ORDER BY
	sre.current_operating_income_total DESC


-- Counts High Earning Cities in each regions
SELECT
	prdp_locations.location_name AS Region_Name,
	COUNT (*) AS High_Earning_Cities,
	COUNT(CASE WHEN prdp_city_class.city_class = 'HUC' THEN 1 END) AS HUC,
	COUNT(CASE WHEN prdp_city_class.city_class = 'ICC' THEN 1 END) AS ICC,
	COUNT(CASE WHEN prdp_city_class.city_class = 'CC' THEN 1 END) AS CC
FROM
	-- this 'table' will only include 'Reg' entries
	-- the 'City' entries will be included in another JOIN
	PortfolioProject.dbo.prdp_locations AS prdp_locations
JOIN
	PortfolioProject.dbo.sre_income_class AS sre_income_class
ON
	prdp_locations.psgc = CONCAT(SUBSTRING(sre_income_class.psgc, 1, 2), '00000000')
	-- link prdp_locations with the 'region' entries, and sre_income_class with all the entries
JOIN
	-- Because prdp_locations is filtered and the only contains entries with 'Reg' geo_level, we need another JOIN
	-- First, we need to link a new prdp_locations, rename it as prdp_geo_level, and link it with sre_income_class
	-- renaming is important because it will be filtered and should only contain 'City' geo_levels
	-- if we use the same name of the main table, both tables will only contain 'City'; 'Reg' entries will be removed
	PortfolioProject.dbo.prdp_locations AS prdp_geo_level
ON
	sre_income_class.psgc = prdp_geo_level.psgc
	-- This will link all the sre_income_class with prdp_geo_level
	-- It will also include 'Reg' entries and we will have to filter prdp_geo_level in WHERE to only include 'City' geo_level
JOIN
	PortfolioProject.dbo.prdp_city_class AS prdp_city_class
ON
	prdp_geo_level.psgc = prdp_city_class.psgc
WHERE
-- set the parameters that are considered as 'high-earning'
	(
	sre_income_class.income_class = 'special'
	OR sre_income_class.income_class LIKE '1st%'
	OR sre_income_class.income_class LIKE '2nd%'
	OR sre_income_class.income_class LIKE '3rd%'
	)
	AND sre_income_class.income_class NOT LIKE '%as Mun%'
	AND prdp_geo_level.geo_level = 'City' -- filtering the 3rd table to only include entries with 'City' geo_level
GROUP BY
	SUBSTRING(prdp_locations.psgc,1,2),
	prdp_locations.location_name
ORDER BY
	High_Earning_Cities DESC


-- Count Cities and municipalities that earns the same income requirement to become HUC
-- HUC income requirement is 50,000,000 pesos based on 1991 constant prices
-- Assuming that the CPI in 2023 is 130 and the CPI in 1991 is 32, the adjusted required income to become a city is approximately 203,000,000 pesos
SELECT
	prdp_locations.location_name AS Region_Name,
	COUNT(*) AS earns_as_HUC,
	COUNT(CASE WHEN prdp_geo_level.geo_level = 'City' THEN 1 END) AS city,
	COUNT(CASE WHEN prdp_geo_level.geo_level = 'Mun' THEN 1 END) AS municipality
FROM
	PortfolioProject.dbo.prdp_locations AS prdp_locations
	-- this main table will only include 'region' entries
JOIN
	PortfolioProject.dbo.statement_of_receipts_and_expenditures AS sre
ON
	prdp_locations.psgc = CONCAT(SUBSTRING(sre.psgc, 1, 2), '00000000')
	-- link the 'region' entries with sre entries
JOIN
	-- because the main table only contain region_entries, we will need to add another prdp_locations as a 3rd table
	PortfolioProject.dbo.prdp_locations AS prdp_geo_level
ON
	-- and link the '3rd' table with the 2nd table
	-- the '3rd' table will include 'province' entries and those entries need to be filtered out
	prdp_geo_level.psgc = sre.psgc
WHERE
	prdp_geo_level.geo_level <> 'Prov' -- filters the '3rd' table 
	AND sre.current_operating_income_local_total >= 203000000
GROUP BY
	SUBSTRING(prdp_locations.psgc,1,2),
	prdp_locations.location_name
ORDER BY
	earns_as_HUC DESC


-- Find municipalities that has enough income to become a city (20,000,000 pesos based on 1991 constant prices)
-- Assuming that the CPI in 2023 is 130 and the CPI in 2000 is 32, the adjusted required income to become a city is approximately 81,200,000
-- population required to become a city is 150,000 or more

SELECT
	prdp_region.location_name AS region,
	prdp_province.location_name AS province,
	prdp_locations.location_name,
	FORMAT(prdp_population.population_count,'N0') AS population_count,
	(CASE
		WHEN prdp_population.population_count >= 150000 THEN 'True'
		ELSE 'False'
	END) AS population_reached,
	(CASE
		WHEN sre.current_operating_income_local_total >= 400000000 THEN '1st'
		WHEN sre.current_operating_income_local_total >= 320000000 THEN '2nd'
		WHEN sre.current_operating_income_local_total >= 240000000 THEN '3rd'
		WHEN sre.current_operating_income_local_total >= 160000000 THEN '4th'
		WHEN sre.current_operating_income_local_total >= 80000000 THEN '5th'
	END) AS city_income_class,
	FORMAT(sre.current_operating_income_local_total, 'C', 'EN-PH') AS local_income,
	FORMAT(sre.current_operating_income_external_national_tax_allotment, 'C', 'EN-PH') AS national_tax_allotment,
	FORMAT(sre.Current_Operating_Income_Total, 'C', 'EN-PH') AS total_operating_income,
	FORMAT(sre.current_operating_expenditures_total, 'C', 'EN-PH') AS total_operating_expenditures,
	FORMAT(sre.fund_balance, 'C', 'en-PH') AS fund_balance
FROM
	PortfolioProject.dbo.prdp_locations AS prdp_locations
JOIN
	PortfolioProject.dbo.statement_of_receipts_and_expenditures AS sre
ON
	prdp_locations.psgc = sre.psgc
JOIN
	PortfolioProject.dbo.prdp_locations AS prdp_region
ON
	prdp_region.psgc = CONCAT(SUBSTRING(prdp_locations.psgc, 1, 2), '00000000')
JOIN
	PortfolioProject.dbo.prdp_locations AS prdp_province
ON
	prdp_province.psgc = CONCAT(SUBSTRING(prdp_locations.psgc, 1, 5), '00000')
JOIN
	PortfolioProject.dbo.prdp_population AS prdp_population
ON
	prdp_locations.psgc = prdp_population.psgc
WHERE
	prdp_locations.geo_level = 'Mun'
	AND sre.current_operating_income_local_total >= 81200000
	AND prdp_population.census_year = 2020
ORDER BY
	population_reached,
	city_income_class,
	prdp_locations.psgc


-- which cities/municipalities spends a lot on services
-- NOTE: general public services is separate from social services
SELECT
	prdp_locations.location_name,
	prdp_locations.geo_level,
	FORMAT(sre.current_operating_expenditures_total, 'C', 'EN-PH') AS total_operating_expenditures,
	FORMAT(sre.current_operating_expenditures_general_public_services, 'C', 'EN-PH') AS general_public_services,
	FORMAT(sre.current_operating_expenditures_economic_services, 'C', 'EN-PH') AS economic_services,
	FORMAT(sre.current_operating_expenditures_debt_services, 'C', 'EN-PH') AS debt_services,
	FORMAT(sre.current_operating_expenditures_social_services_total, 'C', 'EN-PH') AS total_social_services,
	FORMAT(sre.current_operating_expenditures_social_services_manpower_development, 'C', 'EN-PH') AS manpower_development,
	FORMAT(sre.current_operating_expenditures_social_services_health_nutrition_population, 'C', 'EN-PH') AS health_nutrition_population,
	FORMAT(sre.current_operating_expenditures_social_services_labor_employment, 'C', 'EN-PH') AS labor_employment,
	FORMAT(sre.current_operating_expenditures_social_services_housing_community_development, 'C', 'EN-PH') AS housing_community_development,
	FORMAT(sre.current_operating_expenditures_social_services_welfare, 'C', 'EN-PH') AS welfare
FROM
	PortfolioProject.dbo.prdp_locations AS prdp_locations
JOIN
	PortfolioProject.dbo.statement_of_receipts_and_expenditures AS sre
ON
	sre.psgc = prdp_locations.psgc
WHERE
	prdp_locations.geo_level = 'City' OR prdp_locations.geo_level = 'Mun'
ORDER BY
	sre.current_operating_expenditures_total DESC