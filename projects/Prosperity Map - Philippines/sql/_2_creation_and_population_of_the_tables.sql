-- (2) Creation and Population of the tables --

-- Main table: prdp_locations
CREATE TABLE prdp_locations (
	psgc varchar(10),
	location_name varchar(100),
	geo_level varchar(10),
	PRIMARY KEY(psgc)
);
-- populate prdp_locations
INSERT INTO prdp_locations (psgc, location_name, geo_level)
	SELECT
		PSGC AS psgc,
		Location_Name AS location_name,
		Geo_Level AS geo_level
	FROM psgc_2020
WHERE psgc IS NOT NULL;

-- Correspondence_Code table
CREATE TABLE prdp_correspondence_code (
	correspondence_code varchar(9) NOT NULL,
	psgc varchar(10),
	FOREIGN KEY (psgc) REFERENCES prdp_locations(psgc)
);
-- populate prdp_correspondence_code
INSERT INTO prdp_correspondence_code (correspondence_code, psgc)
SELECT
	Correspondence_Code AS correspondence_code,
	PSGC AS psgc
FROM psgc_2020
WHERE
	Correspondence_Code IS NOT NULL

-- sre_income_class table
Create TABLE sre_income_class (
	psgc varchar(10),
	income_class varchar(50),
	FOREIGN KEY (psgc) REFERENCES prdp_locations(psgc)
);
-- populate sre_income_class
INSERT INTO sre_income_class (psgc, income_class)
SELECT
	psgc,
	income_class
FROM sre_2023
WHERE
	income_class IS NOT NULL
	AND PSGC IS NOT NULL

-- prdp_city_class table
CREATE TABLE prdp_city_class (
	psgc varchar(10),
	city_class varchar(5),
	FOREIGN KEY (psgc) REFERENCES prdp_locations(psgc)
);
-- populate prdp_city_class
INSERT INTO prdp_city_class (psgc, city_class)
SELECT
	PSGC AS psgc,
	City_Class AS city_class
FROM psgc_2020
WHERE
	City_Class IS NOT NULL
	AND PSGC IS NOT NULL

-- prdp_location_old_name table
CREATE TABLE prdp_location_old_name (
	psgc varchar(10),
	location_old_name varchar(MAX),
	FOREIGN KEY (psgc) REFERENCES prdp_locations(psgc)
);
-- populate prdp_location_old_name
INSERT INTO prdp_location_old_name (psgc, location_old_name)
SELECT
	PSGC AS psgc,
	Old_Names AS location_old_name
FROM psgc_2020
WHERE
	Old_Names IS NOT NULL
	AND PSGC IS NOT NULL

-- prdp_urban_rural table
CREATE TABLE prdp_urban_rural (
	psgc varchar(10),
	urban_rural varchar(1),
	FOREIGN KEY (psgc) REFERENCES prdp_locations(psgc)
);
-- populate prdp_urban_rural
INSERT INTO prdp_urban_rural (psgc, urban_rural)
SELECT
	PSGC AS psgc,
	Urban_Rural AS urban_rural
FROM psgc_2020
WHERE
	Urban_Rural IS NOT NULL
	AND PSGC IS NOT NULL

-- prdp_population table
CREATE TABLE prdp_population (
	psgc varchar(10),
	census_year INT,
	population_count INT,
	PRIMARY KEY (psgc, census_year),
	FOREIGN KEY (psgc) REFERENCES prdp_locations(psgc)
)
-- populate prdp_population
-- if there is an error, check psgc_2015 dataset; Some locations have updated their psgc and needs to be updated first. Check "Updating the 2015 prdp dataset (psgc_2015)" for more details
INSERT INTO prdp_population(psgc, census_year, population_count)
	SELECT
		PSGC AS psgc,
		'2015' AS census_year,
		_2015_Population AS population_count
	FROM psgc_2015
	WHERE
		_2015_Population IS NOT NULL
		AND PSGC IS NOT NULL
	UNION
	SELECT
		PSGC AS psgc,
		'2020' AS census_year,
		_2020_Population AS population_count
	FROM psgc_2020
	WHERE
		_2020_Population IS NOT NULL
		AND PSGC IS NOT NULL
	ORDER BY psgc

-- prdp_population_comments table
CREATE TABLE prdp_population_comments (
	psgc varchar(10),
	census_year INT,
	population_comment varchar(MAX),
	FOREIGN KEY (psgc, census_year) REFERENCES prdp_population(psgc, census_year)
);
-- populate prdp_population_comments
INSERT INTO prdp_population_comments (psgc, census_year, population_comment)
	SELECT
		PSGC AS psgc,
		'2015' AS census_year,
		_2015_Population_Comments AS population_comment
	FROM psgc_2015
	WHERE
		_2015_Population_Comments IS NOT NULL
		AND PSGC IS NOT NULL
	UNION
	SELECT
		PSGC AS psgc,
		'2020' AS census_year,
		_2020_Population_Comments AS population_comment
	FROM psgc_2020
	WHERE
		_2020_Population_Comments IS NOT NULL
		AND PSGC IS NOT NULL
	ORDER BY psgc

-- statement_of_receipts_and_expenditures table
CREATE TABLE statement_of_receipts_and_expenditures (
	psgc varchar(10),
	census_year INT,
	current_operating_income_local_tax_real_property_general decimal(18,2),
	current_operating_income_local_tax_real_property_special_education decimal(18,2),
	current_operating_income_local_tax_real_property_total decimal(18,2),
	current_operating_income_local_tax_business decimal(18,2),
	current_operating_income_local_tax_other decimal(18,2),
	current_operating_income_local_tax_total decimal(18,2),
	current_operating_income_local_nontax_regulatory_fees decimal(18,2),
	current_operating_income_local_nontax_service_user_charges decimal(18,2),
	current_operating_income_local_nontax_economic_enterprise_receipts decimal(18,2),
	current_operating_income_local_nontax_other_receipts decimal(18,2),
	current_operating_income_local_nontax_total decimal(18,2),
	current_operating_income_local_total decimal(18,2),
	current_operating_income_external_national_tax_allotment decimal(18,2),
	current_operating_income_external_national_tax_other_shares decimal(18,2),
	current_operating_income_external_interlocal_transfers decimal(18,2),
	current_operating_income_external_extraordinary_donations decimal(18,2),
	current_operating_income_external_total decimal(18,2),
	current_operating_income_total decimal(18,2),
	current_operating_expenditures_general_public_services decimal(18,2),
	current_operating_expenditures_social_services_manpower_development decimal(18,2),
	current_operating_expenditures_social_services_health_nutrition_population decimal(18,2),
	current_operating_expenditures_social_services_labor_employment decimal(18,2),
	current_operating_expenditures_social_services_housing_community_development decimal(18,2),
	current_operating_expenditures_social_services_welfare decimal(18,2),
	current_operating_expenditures_social_services_total decimal(18,2),
	current_operating_expenditures_economic_services decimal(18,2),
	current_operating_expenditures_debt_services decimal(18,2),
	current_operating_expenditures_total decimal(18,2),
	net_operating_income decimal(18,2),
	non_income_receipts_capital_investment_asset_sale_proceeds decimal(18,2),
	non_income_receipts_capital_investment_others_debt_securities_sales_proceeds decimal(18,2),
	non_income_receipts_capital_investment_loans_receivable_collections decimal(18,2),
	non_income_receipts_capital_investment_total decimal(18,2),
	non_income_receipts_loans_borrowings_loans_acquisitions decimal(18,2),
	non_income_receipts_loans_borrowings_bonds_issuance decimal(18,2),
	non_income_receipts_loans_borrowings_total decimal(18,2),
	non_income_receipts_others decimal(18,2),
	non_income_receipts_total decimal(18,2),
	nonoperating_expenditures_capital_investment_property_plant_equipment decimal(18,2),
	nonoperating_expenditures_capital_investment_other_entities_debt_securities decimal(18,2),
	nonoperating_expenditures_capital_investment_other_entities_grant_loan decimal(18,2),
	nonoperating_expenditures_capital_investment_total decimal(18,2),
	nonoperating_expenditures_debt_service_loan_amortization_payment decimal(18,2),
	nonoperating_expenditures_debt_service_retirement_bonds_redemption_debt_securities decimal(18,2),
	nonoperating_expenditures_debt_service_total decimal(18,2),
	nonoperating_expenditures_other decimal(18,2),
	nonoperating_expenditures_total decimal(18,2),
	funds_net_increase decimal(18,2),
	cash_balance_beginning decimal(18,2),
	fund_available decimal(18,2),
	accounts_payable_payment_of_prior_years decimal(18,2),
	continuing_appropriation decimal(18,2),
	fund_balance decimal(18,2),
	PRIMARY KEY (psgc, census_year),
	FOREIGN KEY (psgc) REFERENCES prdp_locations(psgc)
);
-- populate statement_of_receipts_and_expenditures
INSERT INTO statement_of_receipts_and_expenditures (
	psgc,
	census_year,
	current_operating_income_local_tax_real_property_general,
	current_operating_income_local_tax_real_property_special_education,
	current_operating_income_local_tax_real_property_total,
	current_operating_income_local_tax_business,
	current_operating_income_local_tax_other,
	current_operating_income_local_tax_total,
	current_operating_income_local_nontax_regulatory_fees,
	current_operating_income_local_nontax_service_user_charges,
	current_operating_income_local_nontax_economic_enterprise_receipts,
	current_operating_income_local_nontax_other_receipts,
	current_operating_income_local_nontax_total,
	current_operating_income_local_total,
	current_operating_income_external_national_tax_allotment,
	current_operating_income_external_national_tax_other_shares,
	current_operating_income_external_interlocal_transfers,
	current_operating_income_external_extraordinary_donations,
	current_operating_income_external_total,
	current_operating_income_total,
	current_operating_expenditures_general_public_services,
	current_operating_expenditures_social_services_manpower_development,
	current_operating_expenditures_social_services_health_nutrition_population,
	current_operating_expenditures_social_services_labor_employment,
	current_operating_expenditures_social_services_housing_community_development,
	current_operating_expenditures_social_services_welfare,
	current_operating_expenditures_social_services_total,
	current_operating_expenditures_economic_services,
	current_operating_expenditures_debt_services,
	current_operating_expenditures_total,
	net_operating_income,
	non_income_receipts_capital_investment_asset_sale_proceeds,
	non_income_receipts_capital_investment_others_debt_securities_sales_proceeds,
	non_income_receipts_capital_investment_loans_receivable_collections,
	non_income_receipts_capital_investment_total,
	non_income_receipts_loans_borrowings_loans_acquisitions,
	non_income_receipts_loans_borrowings_bonds_issuance,
	non_income_receipts_loans_borrowings_total,
	non_income_receipts_others,
	non_income_receipts_total,
	nonoperating_expenditures_capital_investment_property_plant_equipment,
	nonoperating_expenditures_capital_investment_other_entities_debt_securities,
	nonoperating_expenditures_capital_investment_other_entities_grant_loan,
	nonoperating_expenditures_capital_investment_total,
	nonoperating_expenditures_debt_service_loan_amortization_payment,
	nonoperating_expenditures_debt_service_retirement_bonds_redemption_debt_securities,
	nonoperating_expenditures_debt_service_total,
	nonoperating_expenditures_other,
	nonoperating_expenditures_total,
	funds_net_increase,
	cash_balance_beginning,
	fund_available,
	accounts_payable_payment_of_prior_years,
	continuing_appropriation,
	fund_balance
)
SELECT
	psgc,
	'2023' AS census_year,
	current_operating_income_local_tax_real_property_general,
	current_operating_income_local_tax_real_property_special_education,
	current_operating_income_local_tax_real_property_total,
	current_operating_income_local_tax_business,
	current_operating_income_local_tax_other,
	current_operating_income_local_tax_total,
	current_operating_income_local_nontax_regulatory_fees,
	current_operating_income_local_nontax_service_user_charges,
	current_operating_income_local_nontax_economic_enterprise_receipts,
	current_operating_income_local_nontax_other_receipts,
	current_operating_income_local_nontax_total,
	current_operating_income_local_total,
	current_operating_income_external_national_tax_allotment,
	current_operating_income_external_national_tax_other_shares,
	current_operating_income_external_interlocal_transfers,
	current_operating_income_external_extraordinary_donations,
	current_operating_income_external_total,
	current_operating_income_total,
	current_operating_expenditures_general_public_services,
	current_operating_expenditures_social_services_manpower_development,
	current_operating_expenditures_social_services_health_nutrition_population,
	current_operating_expenditures_social_services_labor_employment,
	current_operating_expenditures_social_services_housing_community_development,
	current_operating_expenditures_social_services_welfare,
	current_operating_expenditures_social_services_total,
	current_operating_expenditures_economic_services,
	current_operating_expenditures_debt_services,
	current_operating_expenditures_total,
	net_operating_income,
	non_income_receipts_capital_investment_asset_sale_proceeds,
	non_income_receipts_capital_investment_others_debt_securities_sales_proceeds,
	non_income_receipts_capital_investment_loans_receivable_collections,
	non_income_receipts_capital_investment_total,
	non_income_receipts_loans_borrowings_loans_acquisitions,
	non_income_receipts_loans_borrowings_bonds_issuance,
	non_income_receipts_loans_borrowings_total,
	non_income_receipts_others,
	non_income_receipts_total,
	nonoperating_expenditures_capital_investment_property_plant_equipment,
	nonoperating_expenditures_capital_investment_other_entities_debt_securities,
	nonoperating_expenditures_capital_investment_other_entities_grant_loan,
	nonoperating_expenditures_capital_investment_total,
	nonoperating_expenditures_debt_service_loan_amortization_payment,
	nonoperating_expenditures_debt_service_retirement_bonds_redemption_debt_securities,
	nonoperating_expenditures_debt_service_total,
	nonoperating_expenditures_other,
	nonoperating_expenditures_total,
	funds_net_increase,
	cash_balance_beginning,
	fund_available,
	accounts_payable_payment_of_prior_years,
	continuing_appropriation,
	fund_balance
FROM
	sre_2023
ORDER BY
	psgc