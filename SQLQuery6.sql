SELECT *
FROM PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--order by 3,4

-- Select Data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
order by 1,2

-- Looking at the Total Cases vs Total Deaths
-- shows likelihood of dying if you contract Covid in different countries
SELECT Location, date, total_cases , total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
FROM PortfolioProject..CovidDeaths
where location like '%states%'
where continent is not null
order by 1,2

-- Looking at Total cases vs Population
-- Shows what percentage of population got Covid
SELECT Location, date, Population  ,total_cases , (total_cases/Population)*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
where location like '%states%'
where continent is not null
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population

SELECT Location, Population  ,MAX(total_cases)  as highestInfectionCount, MAX((total_cases/Population))*100 as PercentPopulationInfected 
FROM PortfolioProject..CovidDeaths
where continent is not null
Group by Location, Population
order by PercentPopulationInfected desc

-- Showing Countries with Highest Death Count per Capita

SELECT Location  ,MAX(cast(total_deaths as int))  as TotalDeathCount
FROM PortfolioProject..CovidDeaths
where continent is not null
Group by Location
order by TotalDeathCount desc

-- LET'S BREAK THINGS DOWN BY CONTINENT

SELECT location  ,MAX(cast(total_deaths as int))  as TotalDeathCount
FROM PortfolioProject..CovidDeaths
where continent is  null
Group by location
order by TotalDeathCount desc

SELECT continent  ,MAX(cast(total_deaths as int))  as TotalDeathCount
FROM PortfolioProject..CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCount desc

-- Global Numbers

SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths , SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
where continent is not null
Group by date
order by 1,2


-- Looking at Total Poulation vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM PortfolioProject..CovidDeaths as dea
Join PortfolioProject..CovidVaccinations as vac
	On dea.Location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations )) OVER (Partition by dea.location Order by 
dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
FROM PortfolioProject..CovidDeaths as dea
Join PortfolioProject..CovidVaccinations as vac
	On dea.Location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3
-- Using CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations )) OVER (Partition by dea.location Order by 
dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths as dea
Join PortfolioProject..CovidVaccinations as vac
	On dea.Location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
Select *,(RollingPeopleVaccinated/Population)*100
From PopvsVac

--Using Temp Table
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations )) OVER (Partition by dea.location Order by 
dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths as dea
Join PortfolioProject..CovidVaccinations as vac
	On dea.Location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
Select *,(RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for late visualizations

Create View PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations )) OVER (Partition by dea.location Order by 
dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths as dea
Join PortfolioProject..CovidVaccinations as vac
	On dea.Location = vac.location
	and dea.date = vac.date
where dea.continent is not null

