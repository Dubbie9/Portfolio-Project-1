--SELECT *
--FROM PortfolioProject..CovidDeaths$
--ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations$
--ORDER BY 3,4

-- select data that we are going to be using

--SELECT location, date, total_cases, new_cases, total_deaths, population 
--FROM PortfolioProject..CovidDeaths$
--ORDER BY 1,2

-- Lookiong at Total Cases vs Total deaths
-- Shows the likelihood of dying if you contract covid in your country

SELECT Date, total_cases, total_Deaths, (total_deaths/total_cases)*100 as Deathpercentage
FROM PortfolioProject..CovidDeaths$
WHERE location like '%states%' 
ORDER BY 1,2

-- Looking at Total cases vs Population
-- Shows what percentage of population got covid

SELECT Location, Date, total_cases, population, (total_deaths/population)*100 as covidpercentage
FROM PortfolioProject..CovidDeaths$
--WHERE location like '%states%' 
ORDER BY 1,2

-- Countries with the highest infection rate compared to population

SELECT Location, Population, MAx(total_cases) as Highestinfectioncount, MAX((total_cases/population))*100 as percentpopulationinfected
FROM PortfolioProject..CovidDeaths$
--WHERE location like '%states%' 
GROUP BY Location, Population
ORDER BY percentpopulationinfected desc


--countries with the highest death count per population

SELECT continent, MAX(CAST(total_deaths as int)) as TotalDeathcount 
FROM PortfolioProject..CovidDeaths$
--WHERE location like '%states%' 
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathcount desc

--Showing the continent with the highest death count per population

SELECT continent, MAX(CAST(total_deaths as int)) as TotalDeathcount 
FROM PortfolioProject..CovidDeaths$
--WHERE location like '%states%' 
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathcount desc

-- GLOBAL NUMBERS

SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as Total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
--WHERE location like '%states%' 
WHERE continent is not null
--GROUP BY continent
ORDER BY 1,2

--Total population vs vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3




-- USE CTE

--With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingpeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3
)

SELECT *
FROM PopvsVac


-- TEMP TABLE
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingpeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


