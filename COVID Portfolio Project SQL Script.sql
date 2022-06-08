
Select *
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL

--Select *
--FROM PortfolioProject..CovidVaccinations
--Order By 3,4

--Select the Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
Order By 1,2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid-19 in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location = 'Italy'
WHERE continent IS NOT NULL
Order By 1,2


--Looking at Total Cases vs Population
--Shows what percentage of population has gotten covid

Select location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location = 'Italy'
WHERE continent IS NOT NULL
Order By 1,2


--Looking at Countries with Highest Infection Rate compared to population

Select location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location = 'Italy'
WHERE continent IS NOT NULL
Group By Location, Population 
Order By PercentPopulationInfected DESC


--Looking at Countries with Highest Death Count compared to population

Select location, population, MAX(cast(total_deaths AS int)) AS HighestDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location = 'Italy'
WHERE continent IS NOT NULL
Group By Location, Population 
Order By HighestDeathCount DESC

--Lets break things down by continent
--Showing continents with highest death count

Select continent, MAX(cast(total_deaths AS int)) AS HighestDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location = 'Italy'
WHERE continent IS NOT NULL
Group By continent 
Order By HighestDeathCount DESC


--GLOBAL NUMBERS BY DAY

Select date, SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS int)) AS total_deaths, SUM(cast(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location = 'Italy'
WHERE continent IS NOT NULL 
Group By date
Order By 1,2

--TOTAL GLOBAL NUMBERS

Select SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS int)) AS total_deaths, SUM(cast(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL 
Order By 1,2



--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
,-- (RollingPeopleVaccinated/dea.population)*100
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location=vac.location
	and dea.date=vac.date
WHERE dea.continent IS NOT NULL 
Order By 2,3



--USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location=vac.location
	and dea.date=vac.date
WHERE dea.continent IS NOT NULL 
--Order By 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--TEMP TABLE

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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location=vac.location
	and dea.date=vac.date
WHERE dea.continent IS NOT NULL 
--Order By 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



--Creating View to Store Data for Later Visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location=vac.location
	and dea.date=vac.date
WHERE dea.continent IS NOT NULL 
--Order By 2,3

