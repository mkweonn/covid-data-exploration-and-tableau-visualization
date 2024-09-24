/* 

COVID-19 Data Exploration (2019-2021)
Skills used: Joins, CTEs, Temp Tables, Window Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

SELECT *
FROM covid_deaths
WHERE continent IS NOT NULL -- includes datasets where the "location" is the entire continent as a whole
ORDER BY 3, 4;	-- ordering by location and date


-- Selecting starting data

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM covid_deaths
WHERE continent IS NOT NULL
ORDER BY 1, 2;


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract COVID in USA

SELECT location, `date`, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM covid_deaths
WHERE location LIKE '%states%'
AND continent IS NOT NULL
ORDER BY 1, 2;


-- Total Cases vs Population
-- Shows what percentage of population got COVID

SELECT location, `date`, population, total_cases, (total_cases/population)*100 AS percent_infected
FROM covid_deaths
-- WHERE location LIKE '%states%'
ORDER BY 1, 2;


-- Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) AS highest_infection_count, MAX((total_cases/population))*100 AS percent_population_infected
FROM covid_deaths
GROUP BY location, population
ORDER BY percent_population_infected DESC;

-- Countries with Highest Death Count per Population 

SELECT location, MAX(cast(total_deaths as unsigned)) as total_death_count
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY total_death_count DESC;



-- Breaking things up by continent

-- Continents with the highest death count per population

SELECT continent, MAX(cast(total_deaths as unsigned)) as total_death_count
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_death_count DESC;

/*
-- more accurate than continent (which includes datasets looking at continents as a whole)
SELECT location, MAX(cast(total_deaths as signed)) as total_death_count
FROM covid_deaths
WHERE continent IS NULL
GROUP BY location
ORDER BY total_death_count DESC;
*/


-- Global Numbers

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as unsigned)) as total_deaths, SUM(cast(new_deaths as unsigned))/SUM(new_cases)*100 AS death_percentage
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY `date`
ORDER BY 1, 2;

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT dea.continent, dea.location, dea.`date`, dea.population, vac.new_vaccinations
FROM covid_deaths dea
JOIN covid_vaccinations vac
	ON dea.location = vac.location
		AND dea.`date` = vac.`date`
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3;

-- Getting running total of new vaccinations using Window Function

SELECT dea.continent, dea.location, dea.`date`, dea.population, vac.new_vaccinations
, SUM(CONVERT(vac.new_vaccinations, unsigned)) OVER (PARTITION by dea.location ORDER BY dea.location, dea.`date`) as RollingPeopleVaccinated
FROM covid_deaths dea
JOIN covid_vaccinations vac
	ON dea.location = vac.location
		AND dea.`date` = vac.`date`
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3;

-- Calculate max total vaccinations for each location with aggregation

SELECT dea.continent, dea.location, dea.date, dea.population
, MAX(vac.total_vaccinations) as MaxTotalVaccinations
-- , (RollingPeopleVaccinated/population)*100
FROM covid_deaths dea
JOIN covid_vaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null 
GROUP BY dea.continent, dea.location, dea.date, dea.population
ORDER BY 1,2,3;


-- Using CTE to perform Calculation on Partition By in previous query

WITH PopVsVac(Continent, Location, `Date`, Population, New_Vaccinations, RollingPeopleVaccinated)
AS 
(
SELECT dea.continent, dea.location, dea.`date`, dea.population, vac.new_vaccinations
, SUM(CONVERT(vac.new_vaccinations, unsigned)) OVER (PARTITION by dea.location ORDER BY dea.location, dea.`date`) as RollingPeopleVaccinated
FROM covid_deaths dea
JOIN covid_vaccinations vac
	ON dea.location = vac.location
		AND dea.`date` = vac.`date`
WHERE dea.continent IS NOT NULL
-- ORDER BY 2, 3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopVsVac;

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP TEMPORARY TABLE IF EXISTS PercentPopulationVaccinated;

CREATE TEMPORARY TABLE PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
);

INSERT INTO PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.`date`, dea.population, vac.new_vaccinations
, SUM(CONVERT(vac.new_vaccinations, unsigned)) OVER (PARTITION by dea.location ORDER BY dea.location, dea.`date`) as RollingPeopleVaccinated
FROM covid_deaths dea
JOIN covid_vaccinations vac
	ON dea.location = vac.location
		AND dea.`date` = vac.`date`;
-- WHERE dea.continent IS NOT NULL;

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PercentPopulationVaccinated;

 

-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.`date`, dea.population, vac.new_vaccinations
, SUM(CONVERT(vac.new_vaccinations, unsigned)) OVER (PARTITION by dea.location ORDER BY dea.location, dea.`date`) as RollingPeopleVaccinated
FROM covid_deaths dea
JOIN covid_vaccinations vac
	ON dea.location = vac.location
		AND dea.`date` = vac.`date`
WHERE dea.continent IS NOT NULL;

