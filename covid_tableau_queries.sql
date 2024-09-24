/*

Queries used for Tableau Project

*/


-- 1. Global Numbers 

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as unsigned)) as total_deaths, SUM(cast(new_deaths as unsigned))/SUM(new_cases)*100 as death_percentage
FROM covid_deaths
-- WHERE location like '%states%'
WHERE continent IS NOT NULL
-- GROUP BY `date`
ORDER BY 1,2;

-- Just a double check based off the data provided
-- numbers are extremely close so we will keep them - The Second includes "International"  Location


-- SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
-- FROM PortfolioProject..CovidDeaths
-- WHERE location like '%states%'
-- WHERE location = 'World'
-- GROUP BY date
-- ORDER BY 1,2


-- 2. Breaking things up by continent because location also contains continent names, and exclude EU because it is part of Europe

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

SELECT location, SUM(cast(new_deaths as signed)) as total_death_count
From covid_deaths
-- WHERE location like '%states%'
WHERE continent IS NULL 
AND location NOT IN ('World', 'European Union', 'International')
GROUP BY location
ORDER BY total_death_count DESC;


-- 3. Countries having high infection rate compared to population

SELECT location, population, MAX(total_cases) as highest_infection_count,  Max((total_cases/population))*100 as percent_population_infected
FROM covid_deaths
-- WHERE location like '%states%'
GROUP BY location, population
ORDER BY percent_population_infected DESC;


-- 4. Countries with the highest infection rate comapared to percent infected per population with date

SELECT location, population, `date`, MAX(total_cases) as highest_infection_count,  Max((total_cases/population))*100 as percent_population_infected
FROM covid_deaths
-- WHERE location like '%states%'
GROUP BY Location, Population, `date`
ORDER BY percent_population_infected DESC;
