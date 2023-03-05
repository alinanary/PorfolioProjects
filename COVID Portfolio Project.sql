/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

SELECT *
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

-- Select Data that we are going to be starting with

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE location = 'Argentina'
AND continent IS NOT NULL
ORDER BY 1, 2


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

SELECT location, date, total_cases, population, (total_cases/population)*100 AS PercentPopulationInfected
FROM CovidDeaths
WHERE location = 'Argentina'
ORDER BY 1, 2


-- Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)*100) AS PercentPopulationInfected
FROM CovidDeaths
GROUP BY population, location
ORDER BY PercentPopulationInfected DESC


-- Countries with Highest Death Count per Population

SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


-- BREAKING THINGS DOWN BY CONTINENT

-- Showing Continents with Highest Infection Rate compared to Population

SELECT continent, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)*100) AS PercentPopulationInfected
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY PercentPopulationInfected DESC


-- Showing Continents with Highest Death Count per Population

SELECT continent, MAX(total_deaths) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC



-- GLOBAL NUMBERS

SELECT SUM(CAST(new_cases AS FLOAT)) AS total_cases, SUM(CAST(new_deaths AS FLOAT)) AS total_deaths,
SUM(CAST(new_deaths AS FLOAT))/SUM(CAST(new_cases AS FLOAT))*100 AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations3 vac
    ON dea.location = vac.location 
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


-- Using CTE to perform Calculation on Partition By in previous query

WITH PopVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations3 vac
    ON dea.location = vac.location 
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/CAST(Population AS FLOAT))*100 AS PercentPopulationVaccinated
FROM PopVsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations3 vac
    ON dea.location = vac.location 
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *, (RollingPeopleVaccinated/CAST(Population AS FLOAT))*100 AS PercentPopulationVaccinated
FROM #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations3 vac
    ON dea.location = vac.location 
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL