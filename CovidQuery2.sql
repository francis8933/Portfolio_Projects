SELECT *
FROM PortfolioProject..CovidDeaths$
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..Covidvaccines$
--ORDER BY 3,4

--Select Data that we are going to be using

SELECT location,date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths$
ORDER BY 1,2

--Looking total cases vs. Total Deaths in USA

SELECT location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 AS deaths_percentage
FROM PortfolioProject..CovidDeaths$
WHERE location LIKE '%States%'
ORDER BY 1,2 

--Looking total cases vs. Population 

SELECT location, date, total_cases, population, (total_cases/population) * 100 AS cases_by_population 
FROM PortfolioProject..CovidDeaths$
ORDER BY 1,2

--Countries with highest infection rates compare with population
SELECT location, population, MAX(total_cases) AS highest_infection_count, MAX((total_cases/population))*100 AS highestcases_by_population
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY 4 DESC 

--Countries with highest death count per population
SELECT location, population, MAX(cast(total_deaths as int)) AS highest_death_count, MAX((total_deaths/population))*100 AS highestdeaths_by_population
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY 4 DESC 

--Total death by continent
SELECT continent, MAX(CAST(total_deaths AS int)) AS total_death_count
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY 2 DESC

-- Global Numbers
SELECT date, SUM(new_cases) AS number_of_cases ,SUM(CAST(new_deaths AS int)) AS number_of_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS deaths_percentage
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL 
GROUP BY date
ORDER BY 4 DESC

--Total death and death percentage in the world 
SELECT SUM(new_cases) AS number_of_cases ,SUM(CAST(new_deaths AS int)) AS number_of_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS deaths_percentage
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL 

-- Join the Death tablen and Vaccines
SELECT dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS counting_people_vaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..Covidvaccines$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

--Using CTE to perform calculation on Paritition by previous query
WITH popvsvac (continent, location, date, population, new_vaccinations, counting_people_vaccinated)
AS
(
SELECT dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS counting_people_vaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..Covidvaccines$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)

SELECT *, (counting_people_vaccinated/population)*100 AS people_vaccinated_percentage
FROM popvsvac


--Creating view to store data later visualizations
CREATE VIEW percentagepopulationvaccinated AS
SELECT dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS counting_people_vaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..Covidvaccines$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *
FROM percentagepopulationvaccinated
